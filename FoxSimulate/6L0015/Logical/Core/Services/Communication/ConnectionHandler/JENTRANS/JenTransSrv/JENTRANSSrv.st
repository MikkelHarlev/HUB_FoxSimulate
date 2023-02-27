PROGRAM _INIT

	// Pointers for Runtime / Interface, sorry no namespace here.
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.JenTrans);

	// Init here, we can not do it cyclicly due to the use of tmp_alloc!
	InitAllXMLServerAndClients();

	CASE pThis.Runtime.initState OF
	
		INIT:

			// Initialiaze values.	
			pThis.Runtime.serversRunning	:= 0;
			pThis.Runtime.maxConnections	:= SIZEOF(pThis.Runtime.connection) / SIZEOF(pThis.Runtime.connection[0]);
	
			// Due to limitations in JENTRANS we can not hold the data in g_Core, the data structure can not be an atribute of a datatype.
			// We need to implement different data structure types here.
			
			// InterCom & InterProcess
			templateServerString[INTERCOM]	:= 'JenTransSr:lServerInterCom';
			templateClientString[INTERCOM]	:= 'JenTransSr:lClientInterCom';
			// Variable needs to be seen by the compiler.
			lServerInterCom;
			lClientInterCom;
			
			// Remote Panels.
			templateServerString[REMOTECOM] := 'JenTransSr:lServerRemoteCom';
			templateClientString[REMOTECOM] := 'JenTransSr:lClientRemoteCom';
			// Variable needs to be seen by the compiler.
			lServerRemoteCom;
			lClientRemoteCom;
			
			// Futurail
			templateServerString[FUTURAIL] := 'JenTransSr:lServerFuturailCom';
			templateClientString[FUTURAIL] := 'JenTransSr:lClientFuturailCom';
			// Variable needs to be seen by the compiler.
			lServerFuturailCom;
			lClientFuturailCom;
						
			// JenwayV1
			templateServerString[JENWAYV1] := 'JenTransSr:lServerJenwayV1Com';
			templateClientString[JENWAYV1] := 'JenTransSr:lClientJenwayV1Com';
			// Variable needs to be seen by the compiler.
			lServerJenwayV1Com;
			lClientJenwayV1Com;
			// You can add more....
			
			// Calculating the required memory size
			FOR i := 0 TO SIZEOF(templateServerString) / SIZEOF(templateServerString[0]) - 1 DO
				IF (strlen(ADR(templateServerString[i])) > 0) THEN
					strcpy(ADR(convertedString),ADR(templateServerString[i]));
					strcat(ADR(convertedString),ADR('[0]'));
					status := PV_xgetadr(ADR(convertedString),ADR(pvAdresse),ADR(pvDataLen));
					// Set sizes for spawn time...
					structSizes[i] := pvDataLen;
					// Check if we got the size and if it is bigger.
					IF (status = 0) AND (pvDataLen > dataMemorySize) THEN
						dataMemorySize := (pvDataLen);
					END_IF 
				END_IF
			END_FOR
		
			// Set total max data size needed.
			dataMemorySize := dataMemorySize * (pThis.Runtime.maxConnections * 2);
			
			AsMemPartCreate_0(enable := 1, len := dataMemorySize);
			
			convertedString						:= '';
			
			HandleNewInstances					:= 0;
			
	END_CASE
	
END_PROGRAM

PROGRAM _CYCLIC
	CASE pThis.Runtime.initState OF
		
		INIT:
				// Check if the B&R XML RPC Server is started and running.
				IF (g_Core.Services.Communication.XMLRPCServer.Runtime.isServerStarted AND g_Core.System.Runtime.isInitDone AND g_Core.Services.Communication.ConnectionManager.Runtime.initState = RUNTIME) THEN
				
					pThis.Runtime.initState := RUNTIME;
				END_IF
		
		RUNTIME:
				
			// Run Loop for servers running.
			maxLoop := LIMIT(0, pThis.Runtime.serversRunning, pThis.Runtime.maxConnections);
			
			// Stupid ST for loop!!!
			IF (USINT_TO_BOOL(maxLoop)) THEN
				FOR No := 0 TO maxLoop - 1 DO

					// Generel for loopback search for remote connection number (real number)
					IF (loopBackClient[No] = 0 AND pThis.Runtime.connection[No].isLoopBack) THEN
						// Locate other client pointer.
						// Local my remote connection ID
						IF (arrConnectionPort[No] > 0) THEN
							IF (arrConnectionIDIdent[arrConnectionPort[No]] > 0) THEN
								IF (pThis.Runtime.connection[No].client.pData > 0 AND pThis.Runtime.connection[No].server.pData > 0) THEN
									loopBackClient[No] := (arrConnectionIDIdent[arrConnectionPort[No]]);
									loopBackServer[No] := (arrConnectionIDIdent[arrConnectionPort[No]]);
									XMLServerComInfo[No].Statistic.ErrorCounter := 0;
									XMLClientComInfo[No].Statistic.ErrorCounter := 0;
								END_IF
							END_IF
						END_IF
					END_IF
				
					// RUN Server.
					IF (NOT pThis.Runtime.connection[No].isLoopBack) THEN
						RunXMLServer(ADR(XMLServerComInfo[No]));
					ELSE
						// Handle Loopback
						// Copy data from other client to server.
						IF (loopBackClient[No] = 0) THEN
							XMLServerComInfo[No].ComState := -1;
							XMLServerComInfo[No].Statistic.ErrorCounter := XMLServerComInfo[No].Statistic.ErrorCounter + 1;
						ELSE
							XMLServerComInfo[No].ComState := 5;
							IF (XMLServerComInfo[No].UpdateTrigger = TRUE) THEN
								XMLServerComInfo[No].Statistic.UpdateOkCounter := XMLServerComInfo[No].Statistic.UpdateOkCounter + 1;
								memcpy( pThis.Runtime.connection[No].server.pData, pThis.Runtime.connection[loopBackClient[No]-1].client.pData, pThis.Runtime.connection[No].client.size);
								XMLServerComInfo[No].UpdateTrigger := 1;
							END_IF
						END_IF
					END_IF
					
					pThis.Runtime.connection[No].server.com.ComState      		:= XMLServerComInfo[No].ComState;
					IF (XMLServerComInfo[No].UpdateTrigger > 0) THEN
						pThis.Runtime.connection[No].server.com.UpdateTrigger 	:= XMLServerComInfo[No].UpdateTrigger;
					END_IF
					XMLServerComInfo[No].UpdateTrigger 							:= 0;
					// We need a solution for this!, REMEMBER TO SET THE POINTER!!!
					//memcpy(pThis.Runtime.connection[No].server.pData, AdrServerConnection[No], pThis.Runtime.connection[No].server.size);
					
					// RUN Client. REMEMBER TO SET THE POINTER!!!
					//memcpy(AdrClientConnection[No], pThis.Runtime.connection[No].client.pData, pThis.Runtime.connection[No].client.size);
					XMLClientComInfo[No].UpdateTrigger 							:= pThis.Runtime.connection[No].client.com.UpdateTrigger;
					IF (NOT pThis.Runtime.connection[No].isLoopBack) THEN
						RunXMLClient(ADR(XMLClientComInfo[No]));
					ELSE
						// Handle Loopback
						// Copy data from client to other server.
						
						IF (loopBackServer[No] = 0) THEN
							// Locate other client pointer.
							
							XMLClientComInfo[No].ComState := -1;
							IF (XMLClientComInfo[No].UpdateTrigger = TRUE) THEN
								XMLClientComInfo[No].Statistic.ErrorCounter := XMLClientComInfo[No].Statistic.ErrorCounter + 1;
							END_IF
						ELSE
							XMLClientComInfo[No].ComState := 5;
							// Copy update data from local client to remote server
							IF (XMLClientComInfo[No].UpdateTrigger = TRUE) THEN
								memcpy( pThis.Runtime.connection[loopBackServer[No]-1].server.pData, pThis.Runtime.connection[No].client.pData, pThis.Runtime.connection[loopBackServer[No]-1].server.size);
								// Copy update trigger from local client to remote server
								XMLClientComInfo[No].Statistic.UpdateOkCounter := XMLClientComInfo[No].Statistic.UpdateOkCounter + 1;
								XMLClientComInfo[No].UpdateTrigger := FALSE;
								XMLServerComInfo[loopBackServer[No]-1].UpdateTrigger := TRUE;
								
							END_IF
						END_IF
					END_IF
					pThis.Runtime.connection[No].client.com.ComState      		:= XMLClientComInfo[No].ComState;
					pThis.Runtime.connection[No].client.com.UpdateTrigger 		:= XMLClientComInfo[No].UpdateTrigger;

					// Check for connection Errors.

				END_FOR
			END_IF
		
			CASE HandleNewInstances OF	
				
				0: // Check for new connection, do not check currently running connections.
					
					FOR No := 0 TO pConnectionManager.Runtime.maxConnections - 1 DO
						// Access the connection.
						pConnection ACCESS ADR(pConnectionManager.Runtime.connection[No]); 
						// Set port for visuals only;)
						IF (pConnectionManager.Interface.connection[No].transportType = JENTRANS) THEN
							pConnection.metaData.port := g_Core.Services.Communication.XMLRPCServer.Runtime.port;
						END_IF
						// Found a connection that is enabled and initialized by the connection manager and bring it in runtime.
						IF (pConnection.metaData.isEnabled AND pConnection.initState = INIT AND pConnectionManager.Interface.connection[No].isEnabled)  THEN
							IF pConnection.metaData.connectionID > 0 AND strlen(ADR(pConnection.metaData.address)) > 0 AND (pConnectionManager.Interface.connection[No].transportType = JENTRANS OR pConnectionManager.Interface.connection[No].transportType = JENTRANS_LOOPBACK)  THEN

								IF (pThis.Runtime.serversRunning < pThis.Runtime.maxConnections )THEN
									// set connection Manager ID
									pThis.Runtime.connection[newInstanceNo].connectionManagerID	:= No;
									
																
									// Set data for swaning a new connection 
									//IF (pConnection.metaData.serverStartusRefreshTime < 1200) THEN
									//	pConnection.metaData.serverStartusRefreshTime := 1200;
									//END_IF
									
									IF (pConnection.metaData.refreshTime < 600) THEN
										pConnection.metaData.refreshTime := 600;
									END_IF
									
									isLoopBack 					:= pConnectionManager.Interface.connection[No].transportType = JENTRANS_LOOPBACK;
									
									clientStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime);
									serverStartusRefreshTime 	:= UDINT_TO_UINT(pConnection.metaData.refreshTime*2);
									
									serverIP					:= pConnection.metaData.address;
									connectionID				:= UDINT_TO_USINT(pConnection.metaData.connectionID);
									connectionPort				:= UDINT_TO_USINT(pConnection.metaData.port);
									enableBASE64				:= pConnection.metaData.isBASE64Enabled;
									HandleNewInstances			:= 1;
							
									// Set connection TYPE ;)
									roleType 					:= pConnectionManager.Interface.connection[No].roleType;
									logicType 					:= pConnectionManager.Interface.connection[No].logicType;
									
									// How to set this correctly!?
									pConnection.initState 		:= RUNTIME;
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
					IF (pThis.Runtime.serversRunning = 0) THEN
						// Special Port command for JENTRANS?
						SetXMLPortNumber(g_Core.Services.Communication.XMLRPCServer.Runtime.port);
						// Register JENTRANS XML Callback functions. -- this should be done in the jentrasns server task.
						RegisterXMLFunctions( g_Core.Services.Communication.XMLRPCServer.Runtime.serverStatus, rpc2dCBGet());
					END_IF
					
					newInstanceNo := pThis.Runtime.serversRunning;				
					
					// Set connection TYPE ;)
					pThis.Runtime.connection[newInstanceNo].roleType 	:= roleType;
					pThis.Runtime.connection[newInstanceNo].logicType 	:= logicType;
					pThis.Runtime.connection[newInstanceNo].isLoopBack  := isLoopBack;
					
					// Local and remote lookup list for loopback devices
					IF (pThis.Runtime.connection[newInstanceNo].isLoopBack) THEN
						// setting connection ID
						// Collect connection number assosiated with connectionIDs
						IF (arrConnectionIDIdent[connectionID] = 0) THEN
							arrConnectionIDIdent[connectionID] := newInstanceNo+1;
						ELSE
							// ERROR TWO processes using the same connection id!!!
							// Error Handling
							g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].descriptionAscii 	:= 'LoopBack device Error: Duplicate ID';
							g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].isActive			:= TRUE;
							pThis.Runtime.initState := ERROR;
							RETURN;
						END_IF
						// Set remote connectionID for connection number.
						arrConnectionPort[newInstanceNo]   := connectionPort;
					END_IF
					
					// Get strunct name + connection id.
					// Generate Variable Name
					// We should make a new newInstanceNo pr. struct type for new we will spread it across all.
					GenerateXMLString(newInstanceNo, templateServerString[pThis.Runtime.connection[newInstanceNo].logicType], ADR(convertedString));
	
					// Initialize Server.
					IF (NOT pThis.Runtime.connection[newInstanceNo].isLoopBack) THEN
						InitXMLServer(1, connectionID, ADR(XMLServerComInfo[newInstanceNo]), convertedString, serverStartusRefreshTime);
						// Set Base 64 flag on XML object, flag value is 4.
						IF enableBASE64 THEN
							XMLServerComInfo[newInstanceNo].Flag := XMLServerComInfo[newInstanceNo].Flag OR 4; 
						END_IF
					END_IF
					// Get the Pointer for the Server Connection
					status := PV_xgetadr(ADR(convertedString),ADR(pvAdresse),ADR(pvDataLen));
					IF (status <> 0) THEN
						isError := TRUE;
						RETURN;
					END_IF
					AdrServerConnection[newInstanceNo] := pvAdresse;
					
					// Allocate memory for externel Server data set
					AsMemPartAllocClear_0(enable := 1, ident := AsMemPartCreate_0.ident, len := structSizes[pThis.Runtime.connection[newInstanceNo].logicType]);
					// Check for memory allocation error
					IF (AsMemPartAllocClear_0.status <> 0) THEN
						isError := TRUE;
						RETURN; 
					END_IF
					
					pThis.Runtime.connection[newInstanceNo].server.size		:= AsMemPartAllocClear_0.len;
					pThis.Runtime.connection[newInstanceNo].server.pData 	:= AdrServerConnection[newInstanceNo];
					//pThis.Runtime.connection[newInstanceNo].server.pData 	:= AsMemPartAllocClear_0.mem;
					pThis.Runtime.connection[newInstanceNo].pServer 		:= ADR(pThis.Runtime.connection[newInstanceNo].server);
					
					// Generate Variable Name
					// We should make a new newInstanceNo pr. struct type for new we will spread it across all.
					GenerateXMLString(newInstanceNo, templateClientString[pThis.Runtime.connection[newInstanceNo].logicType], ADR(convertedString));
					
					
					
					// Initialize Client.
					IF (NOT pThis.Runtime.connection[newInstanceNo].isLoopBack) THEN
						InitXMLClient(1, connectionID, ADR(XMLClientComInfo[newInstanceNo]), convertedString, serverIP, clientStartusRefreshTime);
						// Set Base 64 flag on XML object, flag value is 4.
						IF enableBASE64 THEN
							XMLClientComInfo[newInstanceNo].Flag := XMLClientComInfo[newInstanceNo].Flag OR 4; 
						END_IF
					END_IF
					// Get the Pointer for the Client Connection
					status := PV_xgetadr(ADR(convertedString),ADR(pvAdresse),ADR(pvDataLen));
					IF (status <> 0) THEN
						isError := TRUE;
						RETURN;
					END_IF
					AdrClientConnection[newInstanceNo] := pvAdresse;
					
					// Allocate memory for externel Client data set
					AsMemPartAllocClear_0(enable := 1, ident := AsMemPartCreate_0.ident, len := structSizes[pThis.Runtime.connection[newInstanceNo].logicType]);
					// Check for memory allocation error
					IF (AsMemPartAllocClear_0.status <> 0) THEN
						isError := TRUE;
						RETURN; 
					END_IF
					
					pThis.Runtime.connection[newInstanceNo].client.size 	:= AsMemPartAllocClear_0.len;
					pThis.Runtime.connection[newInstanceNo].client.pData 	:= AdrClientConnection[newInstanceNo];
					//pThis.Runtime.connection[newInstanceNo].client.pData 	:= AsMemPartAllocClear_0.mem;
					pThis.Runtime.connection[newInstanceNo].pClient 		:= ADR(pThis.Runtime.connection[newInstanceNo].client);
					
					// setting new number of running instances.
					newInstanceNo := pThis.Runtime.serversRunning := pThis.Runtime.serversRunning + 1;
					HandleNewInstances := 0;
				
			END_CASE
					
			// M2M Communication check					   	
			
				// Stupid ST for loop!!!
				IF (USINT_TO_BOOL(maxLoop)) THEN
					FOR No := 0 TO maxLoop - 1 DO
						
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pServerHandler := pThis.Runtime.connection[No].pServer;
						pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].pClientHandler := pThis.Runtime.connection[No].pClient;
						// Check Connection Status
						pStatus ACCESS ADR(pConnectionManager.Interface.connection[pThis.Runtime.connection[No].connectionManagerID].status);
						
						pStatus.clientState := pThis.Runtime.connection[No].client.com.ComState <> -1;
						pStatus.serverState := pThis.Runtime.connection[No].server.com.ComState <> -1;
						pStatus.txErrors	  := XMLClientComInfo[No].Statistic.ErrorCounter;
						pStatus.txCounts	  := XMLClientComInfo[No].Statistic.UpdateOkCounter;
						pStatus.rxErrors	  := XMLServerComInfo[No].Statistic.ErrorCounter;
						pStatus.rxCounts	  := XMLServerComInfo[No].Statistic.UpdateOkCounter;
						IF OldRefreshTime[No] <> XMLServerComInfo[No].StatusRefreshTimer THEN
							pStatus.RefreshTime    := XMLServerComInfo[No].StatusRefreshTimer - OldRefreshTime[No];
							OldRefreshTime[No] := XMLServerComInfo[No].StatusRefreshTimer;
						END_IF
					END_FOR
				END_IF
			
		ERROR:
		
	END_CASE

END_PROGRAM