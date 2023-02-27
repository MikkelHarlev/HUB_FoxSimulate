// This is a demonstration task on how to setup the core platform.

PROGRAM _INIT
	ISEmergencyOk;
	ISControlPlc;
	ISafeSBit0;
	ISafeSBit1;
	QHBuzz;
	g_HCfg;
	g_MCfg;
	g_RCfg;
	g_Axis;
	g_Inverter;
	g_ModuleFuseFault;
	
	g_Core.System.Configuration.isTimerDescriptionEnabled 			:= TRUE;
	// Set the User Ethernet port for TCPIP Apps (IF5, ethernet port on the PP65).
	g_Core.System.Configuration.hwID								:= 60170; // PP065 = 45895, X20CP1382 = 55995, X20CP0484 = 60170
	g_Core.System.Configuration.userUsbIF := '/bd0';     		// PP065 = IF6.ST1, X20CP1382, X20CP0484 = /bd0
	g_Core.System.Configuration.userEthernetIF						:= 'IF2';
	g_Core.System.Configuration.ipRange.IPAddressMinString 			:= '172.16.01.0';
	g_Core.System.Configuration.ipRange.IPAddressMaxString 			:= '172.16.50.0';
	g_Core.System.Configuration.ipRange.IPSubnetMaskString 			:= '255.255.0.0';
	g_Core.System.Configuration.ipRange.IPDefaultGatewayString 		:= '172.16.200.1';
	g_Core.Services.Alarmhandler.Interface.MachineAlarmPage			:= 400;
	//	// Set machine Info for info screen!
	//	g_Core.System.Configuration.SystemDescription.MachineType		:= 'FOX';
	//	g_Core.System.Configuration.SystemDescription.ProgramVersion 	:= '3.0(a) ';
	
	// Linking IOS to core
	g_Core.System.Configuration.isBlockIcons						:= TRUE;
	g_Core.System.Configuration.isShowAlarmAckButton				:= FALSE;
	g_Core.System.Configuration.isArrayZeroBased					:= FALSE;
	g_Core.System.Configuration.isHideUnForceHMI 					:= TRUE; 
	g_Core.System.Configuration.isHidePlcHalt 						:= FALSE;
	g_Core.System.Configuration.adrEStopVarName						:= ADR('ISEmergencyOk');
	g_Core.System.Configuration.adrInOperationVarName				:= ADR('ISControlPlc');
	g_Core.System.Configuration.adrSafeBit0VarName					:= ADR('ISafeSBit0');
	g_Core.System.Configuration.adrSafeBit1VarName					:= ADR('ISafeSBit1');
	g_Core.System.Configuration.adrBuzzerVarName					:= ADR('QHBuzz');
	g_Core.System.Configuration.adrInverterVarName					:= ADR('g_Inverter');
	g_Core.System.Configuration.adrHCfgVarName						:= ADR('g_HCfg');
	g_Core.System.Configuration.isBlockSaveHCfg						:= FALSE;
	g_Core.System.Configuration.adrMCfgVarName						:= ADR('g_MCfg');
	g_Core.System.Configuration.adrRCfgVarName						:= ADR('g_RCfg');
	g_Core.System.Configuration.arrSizeRCfg							:= SIZEOF(g_RCfg) / SIZEOF(g_RCfg[0]);
	g_Core.System.Configuration.adrRCfgNameVarName					:= ADR('Name');
	g_Core.System.Configuration.adrRCfgNormVarName					:= ADR('Norm'); // Must be UINT!
	g_Core.System.Configuration.arrSizeRCfg							:= SIZEOF(g_ACfg) / SIZEOF(g_ACfg[0]);
	g_Core.System.Configuration.adrACfgVarName						:= ADR('g_ACfg');
	g_Core.System.Configuration.adrACfgNameVarName					:= ADR('Name');
	g_Core.System.Configuration.adrAxisVarName						:= ADR('g_Axis');
	
	// Blackbox setup
	g_Core.Services.Blackbox.Configuration.mode						:= BLACKBOX_SQL;
	g_Core.Services.Blackbox.Configuration.Master.Enabled 			:= 1;
	// should be forced!!!
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[0] 	:= 'oplist';
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[1] 	:= 'AlarmHandl';
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[2] 	:= 'crossb';
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[3] 	:= 'stacker';
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[4] 	:= 'BlackTest';
	g_Core.Services.Blackbox.Configuration.Master.LogTaskName[5] 	:= 'BBTest';

	//	g_Core.Services.Blackbox.Configuration.Slave.Enabled			:= 1;
	//	g_Core.Services.Blackbox.Configuration.Slave.LogTaskName[0] 	:= 'stacker';
	
	
	g_Core.Services.Blackbox.Configuration.Master.MachineType		:= 'FOX';
	g_Core.Services.Blackbox.Configuration.Master.ProductionUnits	:= 1;
	g_Core.Services.Blackbox.Configuration.Master.subIDName			:= 'Stacker: ';
	g_Core.Services.Blackbox.Configuration.Slave.subIDName			:= 'Stack';
	g_Core.Services.Blackbox.Configuration.Slave.ProductionUnits	:= 4;
	
	// Cockpit PEC ID
	g_Core.System.Configuration.pecID								:= 6;	 
	g_Core.System.Configuration.machineType							:= 8;
	
	// Alarm System setup
	g_Core.Services.Alarmhandler.Interface.UserGroupID[0]				:= 2;
	g_Core.Services.Alarmhandler.Interface.UserGroupID[1]				:= 4;
	
	// Statistics Setup
	g_Core.Services.Statistics.Interface.configuration.isDrop 			:= TRUE;
	g_Core.Services.Statistics.Interface.configuration.isPreproduction 	:= TRUE;
	g_Core.Services.Statistics.Interface.configuration.isRepair 		:= TRUE;
	g_Core.Services.Statistics.Interface.configuration.isRewash 		:= TRUE;
	g_Core.Services.Statistics.Interface.configuration.Flow1Type 		:= 63;
	g_Core.Services.Statistics.Interface.configuration.Flow2Type 		:= 64;
	g_Core.Services.Statistics.Interface.configuration.Flow3Type 		:= 65;
	
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].AddOnName		:= 'Grade';
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].MinValue		:= 0;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].MessageB		:= '';
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].MaxValue		:= 4000;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].MultiplierValue	:= 1;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].Mode			:= 8;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].VarName			:= 'g_TempTest';
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].Limiter			:= 20;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].Log				:= 1;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].RegType			:= 1;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].SubRegType		:= 18;
	g_Core.Services.Blackbox.Configuration.Master.AddOns[0].Unit			:= 10;
	g_Core.Services.Blackbox.Configuration.Master.LogOperators				:= TRUE;
	

	//

	
END_PROGRAM


PROGRAM _CYCLIC
	
	// Check if it is a remote panel.
	IF (g_Core.System.Runtime.nodeID < 100) THEN
		CASE initConnections OF
			
			0:	// FoldXML Server for Folder #1, Id=11;
				addConnection_0.sysID 			:= 2;
				addConnection_0.descriptionID 	:= 16;
				addConnection_0.isEnabled 		:= TRUE;
				addConnection_0.modeAddress 	:= SELECTABLE; 
				//addConnection_0.adrAddress 	:= ADR('172.16.43.99');// Server don't need IP, but client will
				addConnection_0.modeID 			:= SELECTABLE;
				// Add forced connection ID?
				addConnection_0.transportType	:= FOLDXML; 
				addConnection_0.roleType 		:= CLIENT; 
				addConnection_0.logicType 		:= NO_PROTOCOL_TYPE;
				addConnection_0.modeBASE64 		:= OFF;
				addConnection_0.modeRefreshTime := SELECTABLE; 
				addConnection_0.maxConnectionID := 19;// Finisher 1-9, Folder 11-19
				addConnection_0.hierarchy 		:= BEHIND;
				//addConnection_0.connectionID	:= 11;
				//addConnection_0.port			:= 81;
				addConnection_0();
				IF (addConnection_0.status = 0 OR addConnection_0.status = 3) THEN
					// Adding connections done.
					TON_AddConnection(IN :=TRUE , PT := T#200ms);
					IF 	TON_AddConnection.Q THEN			
						initConnections := 1;
					END_IF	
				END_IF
			1:
			// Jenway test
				addConnection_0.sysID 			:= 4; // connection ID on com page
				addConnection_0.descriptionID 	:= 41;
				addConnection_0.isEnabled 		:= TRUE;
				addConnection_0.modeAddress     := SELECTABLE;
				addConnection_0.modePort		:= SELECTABLE;
				addConnection_0.modeID 			:= SELECTABLE;
				addConnection_0.modeBASE64 		:= SELECTABLE;
				addConnection_0.modeRefreshTime := SELECTABLE;
				addConnection_0.transportType	:= JENTRANS;
				addConnection_0.logicType 		:= INTERCOM;
				addConnection_0.roleType 		:= CLIENT;
				addConnection_0.maxConnectionID := 100;
				addConnection_0.hierarchy 		:= AFTER;
				addConnection_0();
				IF (addConnection_0.status = 0 OR addConnection_0.status = 3) THEN
					// Adding connections done.
					initConnections := 2;
				END_IF

		END_CASE

	END_IF

	IF (NOT g_Core.System.Runtime.isAppReady) THEN
		g_Core.Services.Alarmhandler.Interface.ExternInfo[0].descriptionAscii := '(-.-)';
		IF ((g_Core.Services.Time.Runtime.MilliSeconds MOD 100) = 0) THEN
			IF count > 3 THEN
				count := 0;
			ELSE
				count := count + 1;
			END_IF
		END_IF
		CASE count OF
			0: tmpString := 'Zzz.';
			1: tmpString := 'Zzz..';
			2: tmpString := 'Zzz...';
			3: tmpString := 'Zzz....';
		END_CASE
		strcat(ADR(g_Core.Services.Alarmhandler.Interface.ExternInfo[0]), ADR(tmpString));
		
		g_Core.Services.Alarmhandler.Interface.ExternInfo[0].isActive := TRUE;
	ELSE
		g_Core.Services.Alarmhandler.Interface.ExternInfo[0].isActive := FALSE;
	END_IF
	
	// Runtime Configuration of Core System!
	g_Core.System.Interface.isCustomerEnabled := g_MCfg.EnableCustArt;
	g_Core.System.Interface.isOperatorEnabled := g_MCfg.EnableOperator;
	g_Core.System.Interface.showLevel := LIMIT(0, g_HCfg.Showlevel, 254);
	//g_Core.System.Interface.timelineIntervalInSec := g_MCfg.TimelineIntervalInSec;
	g_Core.System.Interface.timelineIntervalInSec := 0;
	g_Core.System.Interface.remotePanelMode := 0;

	// Blackbox No-Flow association // SFX dynamically set to 'cockPit number of stackers'
	// If stacker is active 
	g_HCfg.NumberOfStackers := LIMIT(1, g_HCfg.NumberOfStackers, MAX_NUMBER_OF_STACKERS);
	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		g_Core.Services.Blackbox.Interface.Master.ActiveProductionUnits[i - 1] := (i*10)+1;
	END_FOR
	IF (g_Core.System.Runtime.isInitDone) THEN
		g_Core.System.Interface.isAppReady := TRUE;
	END_IF
	
	END_PROGRAM
