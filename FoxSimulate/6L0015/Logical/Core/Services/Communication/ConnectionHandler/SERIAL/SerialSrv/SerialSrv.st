
PROGRAM _INIT

	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);	
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.Serial);
	
	pThis.Runtime.initState      := INIT;
	pThis.Runtime.maxConnections := 10;

END_PROGRAM


PROGRAM _CYCLIC


	CASE pThis.Runtime.initState OF
	
		INIT:
			// Initialize the M2M Connection Handler.
			IF (g_Core.System.Runtime.isInitDone AND pConnectionManager.Runtime.initState = RUNTIME) THEN
				
				// Go in runtime mode.
				HandleNewInstances := 0;
				pThis.Runtime.initState := RUNTIME;
			
			END_IF

		RUNTIME:
		
			maxLoop := LIMIT(0, pThis.Runtime.serversRunning, pThis.Runtime.maxConnections);
			
			IF (USINT_TO_BOOL(maxLoop)) THEN
				FOR No := 0 TO (maxLoop - 1) DO
					serialCom[No]();
					IF (serialCom[No].Status = 8252) THEN
						localStatus[No] := 'Error Serial Device Not Found!';
					END_IF	
				END_FOR
			END_IF	

			CASE HandleNewInstances OF
				0:
					FOR No := 0 TO pConnectionManager.Runtime.maxConnections - 1 DO
						// Access the connection.
						pConnection ACCESS ADR(pConnectionManager.Runtime.connection[0]) + No * SIZEOF(pConnection); 
						
						// Found a connection that is enabled but not initialized and not running.
						IF (pConnection.metaData.isEnabled AND pConnection.initState = INIT AND pConnectionManager.Interface.connection[No].isEnabled) THEN
							IF strlen(ADR(pConnection.metaData.address)) > 0 AND pConnection.metaData.isEnabled AND (pConnectionManager.Interface.connection[No].transportType = SERIAL) THEN

								IF (pThis.Runtime.serversRunning < pThis.Runtime.maxConnections - 1) THEN
									
									// set connection Manager ID for callbacks.
									pThis.Runtime.connection[pThis.Runtime.serversRunning].connectionManagerID	:= No;
									
									IF (pConnection.metaData.refreshTime = 0) THEN
										pConnection.metaData.refreshTime := 9600;
									END_IF
									logicType 			:= pConnectionManager.Interface.connection[No].logicType;
									refreshTime 		:= pConnection.metaData.refreshTime;
									serverAdr			:= pConnection.metaData.address;
									options				:= pConnection.metaData.options;
									HandleNewInstances 	:= 1;
									
									EXIT;
								
								ELSE
									
									pThis.Runtime.initState	:= ERROR;
									//statusString	:= 'Error Creating New Client/Server Connection, Out of Connections';
								
								END_IF
							END_IF
							
						END_IF
					END_FOR
				1:
					newInstanceNo := pThis.Runtime.serversRunning;
					
					// Generate Com settings
					comSettings := '/BD=';
					itoa(refreshTime, ADR(tempString));
					strcat(ADR(comSettings), ADR(tempString));
					IF (strlen(ADR(options)) > 0) THEN
						// Configure Options
						strcat(ADR(comSettings), ADR(' /DB='));
						memset(ADR(tempString),0,SIZEOF(tempString));
						memcpy(ADR(tempString),ADR(options),1);
						strcat(ADR(comSettings), ADR(tempString));
						
						strcat(ADR(comSettings), ADR(' /PA='));
						memset(ADR(tempString),0,SIZEOF(tempString));
						memcpy(ADR(tempString),ADR(options)+1,1);
						strcat(ADR(comSettings), ADR(tempString));
						
						strcat(ADR(comSettings), ADR(' /SB='));
						memset(ADR(tempString),0,SIZEOF(tempString));
						memcpy(ADR(tempString),ADR(options)+2,1);
						strcat(ADR(comSettings), ADR(tempString));
						
					END_IF
					
					// Initialize Serial Com.
					serialCom[newInstanceNo].Port 		 := serverAdr;
					serialCom[newInstanceNo].ComSettings := comSettings;
					serialCom[newInstanceNo]();
					pThis.Runtime.connection[newInstanceNo].pSerialCom := serialCom[newInstanceNo].DataAdr;
					pThis.Runtime.connection[newInstanceNo].logicType  := logicType;
					// Adding Status callback to connection manager.
					localStatus[newInstanceNo] := 'Initializing...';
					pConnectionManager.Interface.connection[pThis.Runtime.connection[pThis.Runtime.serversRunning].connectionManagerID].status.adrStatusString := ADR(localStatus[newInstanceNo]);
					
					pThis.Runtime.serversRunning := pThis.Runtime.serversRunning + 1;
					
					pConnection.initState := RUNTIME;
					HandleNewInstances	  := 0;

			END_CASE
		ERROR:
			// Error Handling
			g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].descriptionAscii 	:= 'Serial Com Error: Connection limit reached';
			g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].isActive			:= TRUE;
	END_CASE
	
END_PROGRAM
