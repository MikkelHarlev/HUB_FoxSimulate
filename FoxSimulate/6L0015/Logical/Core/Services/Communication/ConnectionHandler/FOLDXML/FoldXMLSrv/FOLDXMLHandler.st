PROGRAM _INIT
	
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.FoldXML);
	
	CASE pThis.Runtime.initState OF
	
		INIT:

			// Get maximum numbers of connections
			pThis.Runtime.maxConnections	:= SIZEOF(pThis.Runtime.connection) / SIZEOF(pThis.Runtime.connection[0]);
			HandleNewInstances				:= 0;
		
	END_CASE

END_PROGRAM

PROGRAM _CYCLIC

	CASE pThis.Runtime.initState OF
	
		INIT:
			// Initialize the M2M Connection Handler.
			IF (g_Core.System.Runtime.isInitDone AND g_Core.Services.Communication.XMLRPCServer.Runtime.isServerStarted AND g_Core.Services.Communication.ConnectionManager.Runtime.initState = RUNTIME) THEN
				// Register XML RPC Callback functions.
				// Moved to run at first instance.
				
				// Go in runtime mode.
				pThis.Runtime.initState := RUNTIME;
			
			END_IF

		RUNTIME:	
			// Run Servers & Clients
			maxLoop := LIMIT(0, pThis.Runtime.serversRunning, pThis.Runtime.maxConnections);
			
			IF (USINT_TO_BOOL(maxLoop)) THEN
				FOR No := 0 TO (maxLoop - 1) DO
					CASE pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].roleType OF
						
						SERVER:
							// Run Flat Servers
							//pThis.Runtime.connection[No].data.ClientInfo.MachineStatus := -1;
							RunFoldServer(ADR(pThis.Runtime.connection[No].data)); 
					
						CLIENT:
							// Run Flat Clients
							RunFoldClient(ADR(pThis.Runtime.connection[No].data)); 
					END_CASE
				END_FOR
			END_IF
		
			CASE HandleNewInstances OF
				
				0: // Check for new connections.
					FOR No := 0 TO pConnectionManager.Runtime.maxConnections - 1 DO
						// Access the connection.
						pConnection ACCESS ADR(pConnectionManager.Runtime.connection[0]) + No * SIZEOF(pConnection); 
						// Set port for visuals only;)
						IF (pConnectionManager.Interface.connection[No].transportType = FOLDXML) THEN
							pConnection.metaData.port := g_Core.Services.Communication.XMLRPCServer.Runtime.port;
						END_IF
						// Found a connection that is enabled but not initialized and not running.
						IF (pConnection.metaData.isEnabled AND pConnection.initState = INIT AND pConnectionManager.Interface.connection[No].isEnabled) THEN
							IF 	pConnection.metaData.connectionID > 0 AND strlen(ADR(pConnection.metaData.address)) > 0 AND pConnection.metaData.isEnabled AND (g_Core.Services.Communication.ConnectionManager.Interface.connection[No].transportType = FOLDXML) THEN

								IF (pThis.Runtime.serversRunning < pThis.Runtime.maxConnections - 1) AND (pConnectionManager.Interface.connection[No].roleType > 0) THEN
									// set connection Manager ID
									pThis.Runtime.connection[pThis.Runtime.serversRunning].connectionManagerID	:= No;
									
									// Set max connection ID.
									pConnectionManager.Interface.connection[No].maxConnectionID := 19;
									
									// Set data for swaning a new connection
									//IF (pConnection.metaData.serverStartusRefreshTime < 300) THEN
									//	pConnection.metaData.serverStartusRefreshTime := 300;
									//END_IF
									
									IF (pConnection.metaData.refreshTime < 150) THEN
										pConnection.metaData.refreshTime := 150;
									END_IF
									
									clientStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime) / 10;	// Need to have a general way to make the HMI = ms and not 10ms ticks
									serverStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime*2);
								
									serverAdr					:= pConnection.metaData.address;
									connectionID				:= UDINT_TO_USINT(pConnection.metaData.connectionID);
									enableBASE64				:= 1;// pConnection.isBASE64Enabled;
									HandleNewInstances			:= 1;
							
									// Set connection TYPE ;)
									// We only have M2M...
																		
									// How to set this correctly!?
									pConnection.initState := RUNTIME;
									EXIT;
								ELSIF (pConnectionManager.Interface.connection[No].roleType = 0) THEN
		
									pThis.Runtime.initState 	:= ERROR;
									pThis.Runtime.statusString	:= 'Error no role type defined!!!';
									
								ELSE
									
									pThis.Runtime.initState 	:= ERROR;
									pThis.Runtime.statusString	:= 'Error Creating New Client/Server Connection, Out of Connections';
								
								END_IF
							END_IF
							
						END_IF
					END_FOR
				
				
				1:
					// Spawn new Client/Server (INSTANCE) from:
					// Register FoldXML Functions
					IF (pThis.Runtime.serversRunning = 0) THEN
						InitAllFolderServers();
						SetFoldXMLPortNumber(g_Core.Services.Communication.XMLRPCServer.Runtime.port);
						RegisterFoldFunctions( g_Core.Services.Communication.XMLRPCServer.Runtime.serverStatus, rpc2dCBGet());
					END_IF
					
					newInstanceNo := pThis.Runtime.serversRunning;
					
					CASE pConnectionManager.Interface.connection[pThis.Runtime.connection[newInstanceNo].connectionManagerID].roleType OF
						
						SERVER:
							// Init Servers. NOT TESTED missing machinetype!																			fortløbende M2M Data her neden for
							InitFoldServer(1,connectionID, ADR(pThis.Runtime.connection[newInstanceNo].data), serverStartusRefreshTime);
							pThis.Runtime.connection[newInstanceNo].data.MachineId			:= connectionID;
							pThis.Runtime.connection[newInstanceNo].data.MachineType 		:= 1;
							pThis.Runtime.connection[newInstanceNo].data.StatusRefreshTime 	:= serverStartusRefreshTime;
							pThis.Runtime.connection[newInstanceNo].pServer 				:= ADR(pThis.Runtime.connection[newInstanceNo].data);
							
						CLIENT:
							// Init Clients.
							InitFoldClient(2,connectionID, ADR(pThis.Runtime.connection[newInstanceNo].data), serverAdr, clientStartusRefreshTime); 
							pThis.Runtime.connection[newInstanceNo].data.MachineId			:= connectionID;
							pThis.Runtime.connection[newInstanceNo].data.MachineType 		:= 2;
							pThis.Runtime.connection[newInstanceNo].data.StatusRefreshTime 	:= clientStartusRefreshTime; 
							pThis.Runtime.connection[newInstanceNo].pClient 				:= ADR(pThis.Runtime.connection[newInstanceNo].data);
					END_CASE
					

					// setting new number of running instances.
					
					pThis.Runtime.serversRunning := pThis.Runtime.serversRunning + 1;
					HandleNewInstances := 0;
			
			END_CASE
		
			
				
				IF (USINT_TO_BOOL(maxLoop)) THEN
					FOR No := 0 TO (maxLoop - 1) DO
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pServerHandler := pThis.Runtime.connection[No].pServer;
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pClientHandler := pThis.Runtime.connection[No].pClient;
						// Check connection status
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.clientState 								:= pThis.Runtime.connection[No].data.ClientInfo.MachineStatus >= 0;
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.serverState 								:= pThis.Runtime.connection[No].data.ServerInfo.MachineStatus >= 0;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.txErrors	  	:= pThis.Runtime.connection[No].data.Statistic.NoAnswerCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.txCounts		:= pThis.Runtime.connection[No].data.Statistic.StatusTransmitCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.rxErrors	  	:= pThis.Runtime.connection[No].data.Statistic.ClosedCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.rxCounts	  	:= pThis.Runtime.connection[No].data.Statistic.StatusOkCounter;

						IF OldRefreshTime[No] <> pThis.Runtime.connection[No].data.StatusRefreshTimer THEN
							pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.RefreshTime    := pThis.Runtime.connection[No].data.StatusRefreshTimer - OldRefreshTime[No];
							OldRefreshTime[No] := pThis.Runtime.connection[No].data.StatusRefreshTimer;
						END_IF
					END_FOR

			END_IF
		
		ERROR:			
			g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].descriptionAscii 	:= 'FoldXML Error: Please select roletype!';
			g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].isActive			:= TRUE;
	END_CASE

END_PROGRAM