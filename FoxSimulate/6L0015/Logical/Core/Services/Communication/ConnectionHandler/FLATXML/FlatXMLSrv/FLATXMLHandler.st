PROGRAM _INIT
	
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.FlatXML);
	
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
								
				// Go in runtime mode.
				pThis.Runtime.initState := RUNTIME;
			
			END_IF
		
		RUNTIME:	
			// Run Servers & Clients
			maxLoop := LIMIT(0, pThis.Runtime.serversRunning, pThis.Runtime.maxConnections);

			IF (USINT_TO_BOOL(maxLoop)) THEN
				FOR No := 0 TO (maxLoop - 1) DO
						
					// Run Flat Servers 
					RunFlatServer(ADR(pThis.Runtime.connection[No].server)); 
					
					// Run Flat Clients
					RunFlatClient(ADR(pThis.Runtime.connection[No].client), g_Core.Services.Communication.XMLRPCServer.Runtime.port); 
				END_FOR
			END_IF
		
			CASE HandleNewInstances OF
				
				0: // Check for new connections.
					FOR No := 0 TO g_Core.Services.Communication.ConnectionManager.Runtime.maxConnections - 1 DO
						// Access the connection.
						pConnection ACCESS ADR(g_Core.Services.Communication.ConnectionManager.Runtime.connection[0]) + No * SIZEOF(pConnection); 
						// Set port for visuals only;)
						IF (g_Core.Services.Communication.ConnectionManager.Interface.connection[No].transportType = FLATXML) THEN
							pConnection.metaData.port := g_Core.Services.Communication.XMLRPCServer.Runtime.port;
						END_IF
						// Found a connection that is enabled but not initialized and not running.
						IF (pConnection.metaData.isEnabled AND pConnection.initState = INIT AND g_Core.Services.Communication.ConnectionManager.Interface.connection[No].isEnabled) THEN
							IF 	pConnection.metaData.connectionID > 0 AND strlen(ADR(pConnection.metaData.address)) > 0 AND pConnection.metaData.isEnabled AND (g_Core.Services.Communication.ConnectionManager.Interface.connection[No].transportType = FLATXML)  THEN

								IF (pThis.Runtime.serversRunning < pThis.Runtime.maxConnections - 1) THEN
									// set connection Manager ID
									pThis.Runtime.connection[pThis.Runtime.serversRunning].connectionManagerID	:= No;
									
									// Set max connection ID.
									g_Core.Services.Communication.ConnectionManager.Interface.connection[No].maxConnectionID := 10;
									
									// Set data for swaning a new connection
									//IF (pConnection.metaData.serverStartusRefreshTime < 300) THEN
									//	pConnection.metaData.serverStartusRefreshTime := 300;
									//END_IF
									
									IF (pConnection.metaData.refreshTime < 150) THEN
										pConnection.metaData.refreshTime := 150;
									END_IF
									
									clientStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime);
									serverStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime*2);
								
									serverAdr					:= pConnection.metaData.address;
									connectionID				:= UDINT_TO_USINT(pConnection.metaData.connectionID);
									enableBASE64				:= 1;// pConnection.isBASE64Enabled;
									logicType					:= g_Core.Services.Communication.ConnectionManager.Interface.connection[No].logicType;
									HandleNewInstances			:= 1;
							
									// Set connection TYPE ;)
									// We only have M2M...
																		
									// How to set this correctly!?
									pConnection.initState := RUNTIME;
									EXIT;
								ELSE
									
									pThis.Runtime.initState 	:= ERROR;
									pThis.Runtime.statusString	:= 'Error Creating New Client/Server Connection, Out of Connections';
								
								END_IF
							END_IF
							
						END_IF
					END_FOR
				
				
				1:
					// Spawn new Client/Server (INSTANCE) from:
					IF (pThis.Runtime.serversRunning = 0 ) THEN
						// Register XML RPC Callback functions.
						//
						InitAllFlatServers();
						RegisterFlatFunctions( g_Core.Services.Communication.XMLRPCServer.Runtime.serverStatus, rpc2dCBGet());
					END_IF
					
					newInstanceNo := pThis.Runtime.serversRunning ;
				
					// Init Servers.																			fortløbende M2M Data her neden for
					InitFlatServer(connectionID, ADR(pThis.Runtime.connection[newInstanceNo].server), serverStartusRefreshTime, 0, enableBASE64); 
					pThis.Runtime.connection[newInstanceNo].pServer := ADR(pThis.Runtime.connection[newInstanceNo].server);
					
					// Init Clients.
					InitFlatClient(connectionID, ADR(pThis.Runtime.connection[newInstanceNo].client), serverAdr, clientStartusRefreshTime, 0, enableBASE64); 
					pThis.Runtime.connection[newInstanceNo].pClient := ADR(pThis.Runtime.connection[newInstanceNo].client);
					
					// Set logic type
					pThis.Runtime.connection[newInstanceNo].logicType := logicType;
					
					// setting new number of running instances.
					pThis.Runtime.serversRunning := pThis.Runtime.serversRunning + 1;
					HandleNewInstances := 0;
			
			END_CASE
			
				IF (USINT_TO_BOOL(maxLoop)) THEN
					FOR No := 0 TO (maxLoop - 1) DO
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pServerHandler := pThis.Runtime.connection[No].pServer;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pClientHandler := pThis.Runtime.connection[No].pClient;
						// Check connection status
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.clientState := pThis.Runtime.connection[No].client.ServerMachineStatus <> -1;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.serverState := pThis.Runtime.connection[No].server.ClientMachineStatus <> -1;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.txErrors	  := pThis.Runtime.connection[No].client.Statistic.StatusTransmitCounter - pThis.Runtime.connection[No].client.Statistic.StatusOkCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.txCounts	  := pThis.Runtime.connection[No].client.Statistic.StatusOkCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.rxErrors	  := 0;// N/A pThis.Runtime.connection[No].server.Statistic.ErrorCounter;
						g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.rxCounts	  := pThis.Runtime.connection[No].server.Statistic.StatusTransmitCounter;
						IF OldRefreshTime[No] <> pThis.Runtime.connection[No].server.StatusRefreshTimer THEN
							g_Core.Services.Communication.ConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status.RefreshTime    := pThis.Runtime.connection[No].server.StatusRefreshTimer - OldRefreshTime[No];
							OldRefreshTime[No] := pThis.Runtime.connection[No].server.StatusRefreshTimer;
						END_IF

					END_FOR

			END_IF
		
		ERROR:			
		
	END_CASE

END_PROGRAM