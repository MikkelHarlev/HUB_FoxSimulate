(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: CockpitLogic
 * File: CockpitLogicCyclic.st
 * Author: duem
 * Created: November 11, 2014
 ********************************************************************
 * Implementation of program CockpitLogic
 ********************************************************************)
PROGRAM _INIT

	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pThis ACCESS ADR(localCockpit);
	g_Core.Services.Communication.ConnectionLogic.Cockpit := ADR(pThis);
	// Default values;
	defaultSQLServerAdr := '172.16.200.100';
	defaultSQLPort		:= 1433;
	defaultRefreshRate	:= 10000;
	
	// default SQL cridentials
	//pThis.Runtime.SQLUsername	:= g_MCfg.GlobeUserName;
	//pThis.Runtime.SQLPassword	:= g_MCfg.GlobePassword;
	pThis.Runtime.SQLDBName		:= 'JEGR_DB';
	
	IF (NOT g_Core.System.Configuration.isRemotePanelModeEnabled AND g_Core.Services.Blackbox.Configuration.mode = BLACKBOX_SQL) THEN
		addConnection_0(modeAddress := SELECTABLE, sysID := 1, descriptionID := 19, modeID := SELECTABLE, transportType := SQL, roleType := CLIENT, logicType := COCKPIT, modeBASE64 := OFF, modeRefreshTime := SELECTABLE, maxConnectionID := 10000, hierarchy := GLOBAL, modePort := SELECTABLE);
	END_IF
	IF (pThis.Runtime.initState <> RUNTIME) THEN
		pThis.Runtime.initState := INIT;
	END_IF
	
	pThis.Runtime.isReady				:= FALSE;
END_PROGRAM


PROGRAM _CYCLIC
	
	CASE pThis.Runtime.initState OF
		INIT:
			// Prepare for a jazz fuzion!
		
			// Check if connection manager are serving connections and system init is done.
			IF (g_Core.System.Runtime.isInitDone) THEN
				pThis.Runtime.SQLUsername	:= g_MCfg.GlobeUserName;
				pThis.Runtime.SQLPassword	:= g_MCfg.GlobePassword;
			
				FOR No := 0 TO pConnectionManager.Runtime.maxConnections - 1 DO
					IF (pConnectionManager.Interface.connection[No].logicType = COCKPIT AND pConnectionManager.Runtime.connection[No].metaData.isEnabled) THEN
						// Check if port is set, if not set default.
						IF (pConnectionManager.Runtime.connection[No].metaData.port = 0) THEN
							pConnectionManager.Runtime.connection[No].metaData.port := defaultSQLPort;
						END_IF
						
						// Check refresh rate, if not set default.
						IF (pConnectionManager.Runtime.connection[No].metaData.refreshTime = 0) THEN
							pConnectionManager.Runtime.connection[No].metaData.refreshTime := defaultRefreshRate;
						END_IF
						
						// Check if server adr is set, if not set default.
						IF (strlen(ADR(pConnectionManager.Runtime.connection[connectionManagerID].metaData.address)) = 0) THEN
							pConnectionManager.Runtime.connection[connectionManagerID].metaData.address := defaultSQLServerAdr;
						END_IF
					
						// Found a connection that is enabled and initialized by the connection manager and bring it in runtime.
						IF ((pConnectionManager.Runtime.connection[No].initState = INIT) AND 
							(pConnectionManager.Runtime.connection[No].logicState = INIT) AND
							(pConnectionManager.Runtime.connection[No].metaData.connectionID > 0) ) THEN
						
							// We found the cockpit connection....
							connectionManagerID := No;
			
							// Setup link to machineInfo...
							IF AdrMachineInfo = 0 THEN
								GetAdr(ADR(AdrMachineInfo), ADR('pancfg:MachineInfo_0'));
			      				IF AdrMachineInfo > 0 THEN
			            			pMachineInfo ACCESS AdrMachineInfo;
								ELSE
								  	isError := TRUE;
								END_IF
							END_IF
		
							IF NOT isError THEN
								pThis.Runtime.initState := RUNTIME;
							ELSE
								//Error Handling...
								pThis.Runtime.initState := ERROR;
							END_IF
							EXIT;
						END_IF		
					END_IF
				END_FOR
			END_IF
		
		RUNTIME:
			
			// Setting machine counters
			//	
			pThis.Runtime.companyID			:= g_Core.System.Configuration.pecID;
			pThis.Runtime.machineID			:= pConnectionManager.Runtime.connection[connectionManagerID].metaData.connectionID;
			pThis.Runtime.subIDName			:= g_Core.Services.Blackbox.Configuration.Master.subIDName;
			
			// Setting refreshtimer
			pThis.Runtime.updateInterval	:= pConnectionManager.Runtime.connection[connectionManagerID].metaData.refreshTime;
						
			pThis.Runtime.totalPowerOnHours := pMachineInfo.PowerOnHours;
			pThis.Runtime.totalRunHours		:= pMachineInfo.OperatingHours;
			pThis.Runtime.totalCount		:= (pMachineInfo.ProductionCounts * 1000)+ pMachineInfo.ProductionCountsSmall ;
			pThis.Runtime.SQLServerAddress	:= pConnectionManager.Runtime.connection[connectionManagerID].metaData.address;
			//
			// Setting SQL Server address string
			strcat(ADR(pThis.Runtime.SQLServerAddress),ADR(':'));
			itoa(pConnectionManager.Runtime.connection[connectionManagerID].metaData.port,ADR(tmpstr));
			strcat(ADR(pThis.Runtime.SQLServerAddress),ADR(tmpstr));
			
			// Client State
			IF (pThis.Interface.logData.isInitDone) AND (pThis.Interface.realtime.isInitDone) THEN
				pConnectionManager.Interface.connection[connectionManagerID].status.clientState			:= 1;
			ELSE
				pConnectionManager.Interface.connection[connectionManagerID].status.clientState			:= 0;
			END_IF
			
			// Server State
			IF (pThis.Interface.logData.isConnected) AND (pThis.Interface.realtime.isConnected) THEN
				pConnectionManager.Interface.connection[connectionManagerID].status.serverState			:= 1;
			ELSE
				pConnectionManager.Interface.connection[connectionManagerID].status.serverState			:= 0;
			END_IF
			
			// Connection Init State
			IF (pThis.Interface.logData.isInitDone) AND (pThis.Interface.realtime.isInitDone) THEN
				pConnectionManager.Runtime.connection[connectionManagerID].initState					:= RUNTIME;
			END_IF
			
			// Sendt Count
			pConnectionManager.Interface.connection[connectionManagerID].status.txCounts				:= pThis.Interface.logData.sentCount + pThis.Interface.realtime.sentCount;
			
			// Error Count
			pConnectionManager.Interface.connection[connectionManagerID].status.txErrors				:= pThis.Interface.logData.errorCount + pThis.Interface.realtime.errorCount;
			
			// Is Ready
			pThis.Runtime.isReady																		:= TRUE;
			
	END_CASE
END_PROGRAM
