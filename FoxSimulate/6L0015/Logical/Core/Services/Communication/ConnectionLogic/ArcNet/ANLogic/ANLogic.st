(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: ANLogic
 * File: ANLogic.st
 * Author: eg
 * Created: May 27, 2014
 ********************************************************************
 * Implementation of program ANLogic
 ********************************************************************)

PROGRAM _INIT

	pSerial ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.Serial);
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionLogic.ArcNet);
	
END_PROGRAM


PROGRAM _CYCLIC

	IF (pSerial.Runtime.serversRunning > 0) THEN
		FOR No := 0 TO pSerial.Runtime.serversRunning - 1 DO
	
			// Found a connection that is enabled and initialized by the connection manager and bring it in runtime.
			IF ((pConnectionManager.Runtime.connection[pSerial.Runtime.connection[No].connectionManagerID].initState = RUNTIME) AND 
					(pConnectionManager.Runtime.connection[pSerial.Runtime.connection[No].connectionManagerID].logicState = INIT) AND
						 (pSerial.Runtime.connection[No].logicType = ARCNET) ) THEN
				
				// Add connection count
				pThis.Runtime.connection[pThis.Runtime.connectionsRunning].pArcNet := ADR(ArcNetCT[pThis.Runtime.connectionsRunning]);
				pArcNet ACCESS pThis.Runtime.connection[pThis.Runtime.connectionsRunning].pArcNet;
				
				// Configure CT290 FUB
				CT290Com[pThis.Runtime.connectionsRunning].CT290DataAdr := ADR(pArcNet);
				CT290Com[pThis.Runtime.connectionsRunning].SerialDataAdr := pSerial.Runtime.connection[No].pSerialCom;

				// Request Data 
				pArcNet.Get[0].Enable				:= 1;		// OFF  = 0, ON = 1									
				pArcNet.Get[0].Output.First		   	:= 144;		// 0 = 1.1, 16 = 2.1, ..... 144 = 10.1			 	
				pArcNet.Get[0].Register.First		:= 0;		// 0 = 1, 1 = 2, ...255 = 256			 			
				pArcNet.Get[0].ActualTimer.First	:= 215;		// 0 = 1, 1 = 2, ...255 = 256			 			

				pArcNet.Set.Enable					:= 1;		// OFF  = 0, ON = 1									
				pArcNet.Set.Output.First		   	:= 144;		// 0 = 1.1, 16 = 2.1, ..... 144 = 10.1			 	
				pArcNet.Set.Register.First			:= 0;		// 0 = 1, 1 = 2, ...255 = 256			 			
				pArcNet.Set.ActualTimer.First		:= 224;		// 0 = 1, 1 = 2, ...255 = 256		
				
				pThis.Runtime.connectionsRunning := pThis.Runtime.connectionsRunning + 1;
			
				// Set Logic State to RUNTIME.
				pConnectionManager.Runtime.connection[pSerial.Runtime.connection[No].connectionManagerID].logicState := RUNTIME;
		
			END_IF
		END_FOR
	END_IF
	IF (pThis.Runtime.connectionsRunning > 0) THEN
		FOR No := 0 TO pThis.Runtime.connectionsRunning - 1 DO
			// Access ArcNet FUB
			pArcNet ACCESS pThis.Runtime.connection[No].pArcNet;
			// Modify code from Old com tasks.
			// Get Enabled Status from Connection Manager
			//getConnectionInfo_0(sysID := pConnectionManager.Interface.connection[pSerial.Runtime.connection[No].connectionManagerID].sysID);
			
			pArcNet.Enable                := (getConnectionInfo_0.status = 0); // Get enabled flag from CM
			pArcNet.CT290Node             := UINT_TO_USINT(pConnectionManager.Runtime.connection[pSerial.Runtime.connection[No].connectionManagerID].metaData.port);
			pArcNet.Set.Enable            := pArcNet.Enable;
			pArcNet.Set.Output.No[44]     := g_Core.System.Runtime.isRunning;

			pArcNet.Get[0].Enable         := pArcNet.Enable;
			pArcNet.Get[0].ConnectionNode := UDINT_TO_USINT(pConnectionManager.Runtime.connection[pSerial.Runtime.connection[No].connectionManagerID].metaData.connectionID);

			// Connection to CT290 
			CT290Com[No]();

			// Call backs to Connection Manager.
			IF pArcNet.Enable THEN
				pStatus ACCESS ADR(pConnectionManager.Interface.connection[pSerial.Runtime.connection[No].connectionManagerID].status);
				pStatus.clientState := NOT ((pArcNet.Status <> 11) OR (pArcNet.Get[0].Status <> 1));
				IF strlen(pStatus.adrStatusString) = 0 THEN
					strcpy(pStatus.adrStatusString, ADR(pArcNet.StatusString));
				END_IF
			END_IF
			
		END_FOR
	END_IF

END_PROGRAM
