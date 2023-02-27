PROGRAM _INIT
	
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pJenTrans ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.JenTrans);
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionLogic.Interconnect);
	pThis.Runtime.initState := INIT;
	clientLogic;
	serverLogic;

END_PROGRAM


PROGRAM _CYCLIC
	 // FOR ERROR HANDLING
	pThis.Runtime.initState := RUNTIME;
	// INIT
		IF (pJenTrans.Runtime.serversRunning > 0) THEN
		FOR No := 0 TO pJenTrans.Runtime.serversRunning - 1 DO
		 
			// Found a connection that is enabled and initialized by the connection manager and bring it in runtime.
			IF ((pConnectionManager.Runtime.connection[pJenTrans.Runtime.connection[No].connectionManagerID].initState = RUNTIME) AND 
					(pConnectionManager.Runtime.connection[pJenTrans.Runtime.connection[No].connectionManagerID].logicState = INIT) AND
						 (pJenTrans.Runtime.connection[No].logicType = INTERCOM) ) THEN
				
						CASE pJenTrans.Runtime.connection[No].roleType OF
							SERVER:
								// Initialize Logic
								arrXMLServerConnection[pThis.Runtime.serversRunning].pClientUpdateTrigger		:= ADR(pJenTrans.Runtime.connection[No].client.com.UpdateTrigger);
								arrXMLServerConnection[pThis.Runtime.serversRunning].pServerUpdateTrigger		:= ADR(pJenTrans.Runtime.connection[No].server.com.UpdateTrigger);
								arrXMLServerConnection[pThis.Runtime.serversRunning].pSendStruct 				:= pJenTrans.Runtime.connection[No].client.pData;
								arrXMLServerConnection[pThis.Runtime.serversRunning].pReceiveStruct 			:= pJenTrans.Runtime.connection[No].server.pData; 
								arrXMLServerConnection[pThis.Runtime.serversRunning].pServerConnectionControl	:= ADR(arrServerConnectionControl[pThis.Runtime.serversRunning]);
								arrXMLServerConnection[pThis.Runtime.serversRunning].pConnected					:= ADR(pConnectionManager.Runtime.connection[pJenTrans.Runtime.connection[No].connectionManagerID].isConnected);
								
								pConnectionManager.Interface.connection[pJenTrans.Runtime.connection[No].connectionManagerID].pServerLogic	:= ADR(serverLogic[pThis.Runtime.serversRunning]);
								pThis.Runtime.serverLogicIdents[pThis.Runtime.serversRunning]					:= ADR(serverLogic[pThis.Runtime.serversRunning]);
								pThis.Runtime.servers[pThis.Runtime.serversRunning].ident 						:= ADR(arrServerConnectionControl[pThis.Runtime.serversRunning]);
								pThis.Runtime.servers[pThis.Runtime.serversRunning].connectionManagerID 		:= pJenTrans.Runtime.connection[No].connectionManagerID;
								pThis.Runtime.serversRunning													:= pThis.Runtime.serversRunning + 1;
			
							CLIENT:
								// Initialize Logic
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pClientUpdateTrigger		:= ADR(pJenTrans.Runtime.connection[No].client.com.UpdateTrigger);
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pServerUpdateTrigger		:= ADR(pJenTrans.Runtime.connection[No].server.com.UpdateTrigger);
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pSendStruct 				:= pJenTrans.Runtime.connection[No].client.pData;
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pReceiveStruct 			:= pJenTrans.Runtime.connection[No].server.pData;
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pClientConnectionControl	:= ADR(arrClientConnectionControl[pThis.Runtime.clientsRunning]);
								arrXMLClientConnection[pThis.Runtime.clientsRunning].pConnected					:= ADR(pConnectionManager.Runtime.connection[pJenTrans.Runtime.connection[No].connectionManagerID].isConnected);
								
								pConnectionManager.Interface.connection[pJenTrans.Runtime.connection[No].connectionManagerID].pClientLogic	:= ADR(clientLogic[pThis.Runtime.clientsRunning]);												
								pThis.Runtime.clientLogicIdents[pThis.Runtime.clientsRunning]					:= ADR(clientLogic[pThis.Runtime.clientsRunning]);
								pThis.Runtime.clients[pThis.Runtime.clientsRunning].ident 						:= ADR(arrClientConnectionControl[pThis.Runtime.clientsRunning]);
								pThis.Runtime.clients[pThis.Runtime.clientsRunning].connectionManagerID 		:= pJenTrans.Runtime.connection[No].connectionManagerID;
								pThis.Runtime.clientsRunning 													:= pThis.Runtime.clientsRunning + 1;
						END_CASE
					
						pConnectionManager.Runtime.connection[pJenTrans.Runtime.connection[No].connectionManagerID].logicState := RUNTIME;
					END_IF
		END_FOR

		IF (pThis.Runtime.serversRunning > 0) THEN
			FOR No := 1 TO pThis.Runtime.serversRunning DO
				
				// TODO ACCESSS THE CORE INTERFACE HERE!!! PLC WILL CRASH IF IT IS NOT FIXED!
				pServerCom ACCESS ADR(serverLogic[No-1]);

				// Ready state.
		
				// Check if jentrans connection is open.
				pIsConnected ACCESS arrXMLServerConnection[No - 1].pConnected;
				pServerCom.isConnected := pIsConnected;
			
				// Activete the function block
				// ERROR!!!!! no edgepos inside a FOR LOOP!!!!
				IF (pServerCom.isConnected AND NOT isServerActivated[No - 1]) THEN
					arrServerConnectionControl[No - 1].xActivate	:= TRUE;
					isServerActivated[No - 1] := TRUE;
				END_IF
				
				// Run function block if comStep is initialized
				arrXMLServerConnection[No - 1]();
			
				// check for various inlet states
							
				// Check if the client is 'Ready to Start' or 'In Operation
				pServerCom.isRunning := (NOT arrServerConnectionControl[No - 1].xIN_ClientOP_ModeOff) AND pServerCom.isConnected;
				
				// Check if there is an error on the client
				pServerCom.isError := (arrServerConnectionControl[No - 1].xIN_ClientError);
				
				// Check is there is an external error on the jenway
				pServerCom.isExternalError := (arrServerConnectionControl[No - 1].xIN_ClientExternalError);
				
				// Get information from client.
				IF (pServerCom.isConnected) THEN
					pServerCom.InfomationString := arrServerConnectionControl[No - 1].xIN_InformationString;
				ELSE
					pServerCom.InfomationString := '';
				END_IF
				
				// Set various states for client to read
				
				arrServerConnectionControl[No - 1].xOUT_InformationString  	:= g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
				arrServerConnectionControl[No - 1].xOUT_ServerError			:= g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0;
				arrServerConnectionControl[No - 1].xOUT_ServerOP_ModeOff	:= NOT g_Core.System.Runtime.isRunning;  
				
				// Setup the callback hook to the connection manager status information- CLIENT
				pStatus ACCESS ADR(pConnectionManager.Interface.connection[pThis.Runtime.servers[No - 1].connectionManagerID].status);
				serverStatusString[No-1] := '';
				pStatus.adrStatusString := ADR(serverStatusString[No-1]);
				// Generate Message for the status field.
				strcpy(ADR(serverStatusString[No-1]),ADR('-> '));
				strcat(ADR(serverStatusString[No-1]),ADR(arrServerConnectionControl[No - 1].xOUT_InformationString));
				strcat(ADR(serverStatusString[No-1]),ADR('$L$R'));
				strcat(ADR(serverStatusString[No-1]),ADR('<- '));
				strcat(ADR(serverStatusString[No-1]),ADR(arrServerConnectionControl[No - 1].xIN_InformationString));
				
				pServerCom.debug.aborts		:= arrServerConnectionControl[No - 1].uiAbortCounter;
				pServerCom.debug.userErrors	:= arrServerConnectionControl[No - 1].uiUserErrorCounter;
				
				FOR i := 0 TO 9 DO
					CASE pServerCom.inlet[i].step OF
						
						// Intercom Is offline!!!
						INTERCOM_OFFLINE:
							// Raise alarm????
							IF (pServerCom.isConnected) THEN
								pServerCom.inlet[i].step := INTERCOM_IDLE; 
							END_IF
						
							
						// Check for Readyness and outlet request from the stacker
						INTERCOM_IDLE:
		
							// Reset Ready signal from Inlet.
							arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerCallForLoad   := FALSE;
							arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerReadyToLoad   := FALSE;
							arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone := FALSE;
							
							IF (arrServerConnectionControl[No - 1].xAbortFlag OR pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step 											:= INTERCOM_ABORTED;
							END_IF
							
							IF (NOT pServerCom.isConnected) THEN
								pServerCom.inlet[i].step := INTERCOM_OFFLINE;
							// Check states, is client requesting unload or do we call for load?
							ELSIF (pServerCom.isRunning) THEN
								// Check if client is requesting unload.
								IF(arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientReadyToUnload) THEN
									pServerCom.inlet[i].step						:= INTERCOM_REQUESTING_TRANSFER;
									pServerCom.inlet[i].runtime.isRequesting 		:= TRUE;
									pServerCom.inlet[i].runtime.isReceiving			:= FALSE;
									pServerCom.inlet[i].runtime.isReceivingDone		:= FALSE;
									pServerCom.inlet[i].interface.isCallForLoad		:= FALSE;
								// Call for load!								
								ELSIF(pServerCom.inlet[i].interface.isCallForLoad) THEN
									pServerCom.inlet[i].step 						:= INTERCOM_CALL_FOR_LOAD;
									pServerCom.inlet[i].runtime.isCallingForLoad	:= TRUE;
									pServerCom.inlet[i].interface.isReady			:= FALSE;
									pServerCom.inlet[i].interface.isReceived		:= FALSE;
									pServerCom.inlet[i].runtime.isRequesting 		:= FALSE;
									// Set Fub command
									arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerCallForLoad := TRUE;
								// reset		
								ELSE
									pServerCom.inlet[i].runtime.isRequesting 		:= FALSE;
								END_IF
							END_IF
							
						INTERCOM_CALL_FOR_LOAD:
							// Server is calling for a load, used on Vikings.
							IF (arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientReadyToUnload) THEN
								pServerCom.inlet[i].step 					:= INTERCOM_IDLE;
								pServerCom.inlet[i].interface.isCallForLoad := FALSE;
								// Set fub state 
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerCallForLoad := FALSE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerReadyToLoad   := FALSE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone := FALSE;
							
							// Check for abort command or call for load flag is low.	
							ELSIF(pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step 						:= INTERCOM_ABORTED;
								pServerCom.inlet[i].runtime.isCallingForLoad	:= FALSE;
								// Set fub state
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerCallForLoad := FALSE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerReadyToLoad   := FALSE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone := FALSE;
							ELSIF (pServerCom.inlet[i].interface.isCallForLoad) THEN
								pServerCom.inlet[i].runtime.isCallingForLoad:= FALSE;
								pServerCom.inlet[i].step 					:= INTERCOM_IDLE;
							END_IF

						// Wait for reply from Client and check for abort signal.	
						INTERCOM_REQUESTING_TRANSFER:
							// Get data from client.
							pServerCom.inlet[i].data := arrServerConnectionControl[No - 1].udtServerData; 
							pServerCom.inlet[i].runtime.isRequesting := TRUE;
							
							// RESET FROM REQUESTING
							IF (NOT arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientReadyToUnload) THEN
								pServerCom.inlet[i].step 				 := INTERCOM_ABORTED;
							END_IF
							
							IF (arrServerConnectionControl[No - 1].xAbortFlag OR pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF (pServerCom.inlet[i].interface.isReady) THEN
								pServerCom.inlet[i].step 						:= INTERCOM_READY_TO_TRANSFER;	
								// Set fub state ready to load
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerReadyToLoad := TRUE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerCallForLoad 	:= FALSE;
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone	:= FALSE;
							END_IF
							
						// Send signal to client that we are unloading.	
						INTERCOM_READY_TO_TRANSFER: 
							// Abort handling
							IF (arrServerConnectionControl[No - 1].xAbortFlag OR pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF NOT(pServerCom.inlet[i].runtime.isRequesting) THEN
								(* Abort *)
								pServerCom.inlet[i].step := INTERCOM_ABORTED;
							ELSIF (arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientUnloading) THEN
								pServerCom.inlet[i].data := arrServerConnectionControl[No - 1].udtServerData; 
								pServerCom.inlet[i].runtime.isRequesting			:= FALSE;
								pServerCom.inlet[i].runtime.isReceivingDone			:= FALSE;
								pServerCom.inlet[i].runtime.isReceiving		 		:= TRUE;
									
								pServerCom.inlet[i].interface.isReady				:= FALSE;
								pServerCom.inlet[i].interface.isCallForLoad			:= FALSE;
								pServerCom.inlet[i].interface.isReceived			:= FALSE;
								pServerCom.inlet[i].step 				 			:= INTERCOM_TRANSFERING;
							END_IF
							
						// Send unloading signal to outlet.
						INTERCOM_TRANSFERING:
							IF (arrServerConnectionControl[No - 1].xAbortFlag OR pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF (pServerCom.inlet[i].interface.isReceived) THEN
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone 	:= TRUE;
								// Everything is ok reset step.
								pServerCom.inlet[i].step 					:= INTERCOM_TRANSFERED;
							END_IF
							
						INTERCOM_TRANSFERED:	
							IF (arrServerConnectionControl[No - 1].xAbortFlag OR pServerCom.inlet[i].interface.isAbort) THEN
								pServerCom.inlet[i].step := INTERCOM_ABORTED;
								// check is we got it.
							ELSIF ((arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientUnloadingDone) OR (arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientReadyToUnload = FALSE AND arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientUnloading = FALSE AND arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientUnloadingDone = FALSE) OR (arrServerConnectionControl[No - 1].arrInlet[i].xIN_ClientReadyToUnload = TRUE)) THEN
								pServerCom.inlet[i].runtime.isReceivingDone								:= TRUE;
								pServerCom.inlet[i].runtime.isRequesting								:= FALSE;
								pServerCom.inlet[i].runtime.isReceiving									:= FALSE;
								pServerCom.inlet[i].step 													:= INTERCOM_RESET;
								// Set fub state
								arrServerConnectionControl[No - 1].arrInlet[i].xOUT_ServerUnloadingDone 	:= TRUE;
							END_IF
							
						// Error handling Inlet Aborted!!! handle error.	
						INTERCOM_ABORTED:
							pServerCom.inlet[i].runtime.isRequesting := FALSE; 
							IF pServerCom.inlet[i].interface.isAbort THEN
								arrServerConnectionControl[No - 1].xAbortFlag	:= FALSE;
								pServerCom.inlet[i].step := INTERCOM_RESET;
							ELSE 
								pServerCom.inlet[i].runtime.isAborted := TRUE;
								IF (pServerCom.inlet[i].interface.isAbortAcknowledged) THEN
									arrServerConnectionControl[No - 1].xAbortFlag	:= FALSE;
									pServerCom.inlet[i].step 						:= INTERCOM_RESET;
								END_IF
							END_IF
						
						// Reset variables.
						INTERCOM_RESET:
							// Runtime states
							pServerCom.inlet[i].runtime.isAborted 				:= FALSE;
							pServerCom.inlet[i].runtime.isRequesting			:= FALSE;
							pServerCom.inlet[i].runtime.isCallingForLoad		:= FALSE;
							pServerCom.inlet[i].runtime.isReceiving				:= FALSE;
							pServerCom.inlet[i].runtime.isReceivingDone			:= FALSE;
							
							// Interface states
							pServerCom.inlet[i].interface.isAbort				:= FALSE;
							pServerCom.inlet[i].interface.isAbortAcknowledged	:= FALSE;
							pServerCom.inlet[i].interface.isCallForLoad			:= FALSE;
							pServerCom.inlet[i].interface.isReady	 			:= FALSE;
							pServerCom.inlet[i].interface.isReceived			:= FALSE;
							pServerCom.inlet[i].step						 	:= INTERCOM_IDLE;
					END_CASE
				END_FOR
			END_FOR
		END_IF
		
		IF (pThis.Runtime.clientsRunning > 0) THEN
			FOR No := 1 TO pThis.Runtime.clientsRunning DO
				// TODO ACCESSS THE CORE INTERFACE HERE!!! PLC WILL CRASH IF IT IS NOT FIXED!
				pClientCom ACCESS ADR(clientLogic[No-1]);
				// Initial Back Port, it should be on it own?
				// Ready state.
		
				// Check if jentrans connection is open.
				pIsConnected ACCESS arrXMLClientConnection[No - 1].pConnected; 
				pClientCom.isConnected := pIsConnected;
			
				// Activete the function block
				IF (pClientCom.isConnected AND NOT isClientActivated[No - 1]) THEN
					arrClientConnectionControl[No - 1].xActivate	:= TRUE;
					isClientActivated[No - 1] := TRUE;
				END_IF
				
				// Run function block if comStep is initialized
				arrXMLClientConnection[No - 1]();
			
				// check for various inlet states
							
				// Check if Jenway is 'Ready to Start' or 'In Operation
				pClientCom.isRunning := (NOT arrClientConnectionControl[No - 1].xIN_ServerOP_ModeOff) AND pClientCom.isConnected;
				
				// Check if there is an error on the jenway
				pClientCom.isError := (arrClientConnectionControl[No - 1].xIN_ServerError);
				
				// Check is there is an external error on the jenway
				pClientCom.isExternalError := (arrClientConnectionControl[No - 1].xIN_ServerExternalError);
				
				// Get information from inlet.
				IF (pClientCom.isConnected) THEN
					pClientCom.InfomationString := arrClientConnectionControl[No - 1].xIN_InformationString;
				ELSE
					pClientCom.InfomationString := '';
				END_IF
				
				// check for various inlet states
				
				arrClientConnectionControl[No - 1].xOUT_InformationString  	:= g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
				arrClientConnectionControl[No - 1].xOUT_ClientError			:= g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0;
				arrClientConnectionControl[No - 1].xOUT_ClientOP_ModeOff	:= NOT g_Core.System.Runtime.isRunning;  
				
				pClientCom.debug.aborts		:= arrClientConnectionControl[No - 1].uiAbortCounter;
				pClientCom.debug.userErrors	:= arrClientConnectionControl[No - 1].uiUserErrorCounter;
				
				// Setup the callback hook to the connection manager status information- CLIENT
				pStatus ACCESS ADR(pConnectionManager.Interface.connection[pThis.Runtime.clients[No - 1].connectionManagerID].status);
				clientStatusString[No-1] := '';
				pStatus.adrStatusString := ADR(clientStatusString[No-1]);
				// Generate Message for the status field.
				strcpy(ADR(clientStatusString[No-1]),ADR('Receiving: '));
				strcat(ADR(clientStatusString[No-1]),ADR(arrClientConnectionControl[No - 1].xOUT_InformationString));
				strcat(ADR(clientStatusString[No-1]),ADR('$L$R'));
				strcat(ADR(clientStatusString[No-1]),ADR('Sending: '));
				strcat(ADR(clientStatusString[No-1]),ADR(arrClientConnectionControl[No - 1].xIN_InformationString));
				
				FOR i := 0 TO 9 DO
					CASE pClientCom.outlet[i].step OF
						
						// Intercom Is offline!!!
						INTERCOM_OFFLINE:
							// Raise alarm????
							IF (pClientCom.isConnected) THEN
								pClientCom.outlet[i].step := INTERCOM_IDLE; 
							END_IF
						
						INTERCOM_CALL_FOR_LOAD:
							// Server is calling for a load, used on Vikings.
							IF (NOT arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerCallForLoad) THEN
								pClientCom.outlet[i].step := INTERCOM_IDLE; 
							ELSIF(pClientCom.outlet[i].interface.isRequesting) THEN
								pClientCom.outlet[i].step := INTERCOM_IDLE;
							END_IF
							
						// Check for Readyness and outlet request from the stacker
						INTERCOM_IDLE:
						
							// Reset Ready signal from Inlet.
							arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientUnloading	 := FALSE;
							arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientUnloadingDone := FALSE;
							arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientReadyToUnload := FALSE;
							
							IF (arrClientConnectionControl[No - 1].xAbortFlag OR pClientCom.outlet[i].interface.isAbort) THEN
								pClientCom.outlet[i].step := INTERCOM_ABORTED;
							END_IF
							
							IF (arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerCallForLoad) THEN
								pClientCom.outlet[i].step := INTERCOM_CALL_FOR_LOAD; 
							END_IF
		
							IF (NOT pClientCom.isConnected) THEN
								pClientCom.outlet[i].step := INTERCOM_OFFLINE;
							ELSIF (pClientCom.isRunning) THEN
								IF (pClientCom.outlet[i].interface.isRequesting) THEN
									pClientCom.outlet[i].step 					:= INTERCOM_REQUESTING_TRANSFER;
									pClientCom.outlet[i].runtime.isRequesting 	:= FALSE;
								ELSIF(arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerCallForLoad) THEN
									pClientCom.outlet[i].runtime.isRequesting := TRUE;
								ELSE
									pClientCom.outlet[i].runtime.isRequesting := FALSE;
								END_IF
							END_IF
							
							
						// Wait for reply from Jenway and check for abort signal.	
						INTERCOM_REQUESTING_TRANSFER:
							arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientReadyToUnload 	:= TRUE;
							arrClientConnectionControl[No - 1].udtClientData							:= pClientCom.outlet[i].data; 
							
							// RESET FROM REQUESTING
							IF (pClientCom.outlet[i].interface.isRequesting = FALSE) THEN
								IF (arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerReadyToLoad) THEN
									pClientCom.outlet[i].step := INTERCOM_ABORTED;
								ELSE	
									pClientCom.outlet[i].step := INTERCOM_IDLE;
								END_IF
							END_IF
							
							IF (arrClientConnectionControl[No - 1].xAbortFlag OR pClientCom.outlet[i].interface.isAbort) THEN
								pClientCom.outlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF (arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerReadyToLoad) THEN
								pClientCom.outlet[i].interface.isRequesting := FALSE;
								pClientCom.outlet[i].runtime.isReady 		:= TRUE;
								pClientCom.outlet[i].step 					:= INTERCOM_READY_TO_TRANSFER;	
							END_IF
							
						// Send signal to jenway that we are unloading.	
						INTERCOM_READY_TO_TRANSFER: 
							IF (arrClientConnectionControl[No - 1].xAbortFlag OR pClientCom.outlet[i].interface.isAbort) THEN
								pClientCom.outlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF (pClientCom.outlet[i].interface.isTransfering) THEN
								arrClientConnectionControl[No - 1].udtClientData						:= pClientCom.outlet[i].data;
								pClientCom.outlet[i].runtime.isReady 									:= FALSE;
								arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientUnloading 	:= TRUE;
								pClientCom.outlet[i].step 												:= INTERCOM_TRANSFERING;
							END_IF
							
						// Send unloading signal to outlet.
						INTERCOM_TRANSFERING:
							IF (arrClientConnectionControl[No - 1].xAbortFlag OR pClientCom.outlet[i].interface.isAbort) THEN
								pClientCom.outlet[i].step := INTERCOM_ABORTED;
							// Set outlet
							ELSIF (arrClientConnectionControl[No - 1].arrOutlet[i].xIN_ServerUnloadingDone) THEN
								// Everything is ok reset step.
								pClientCom.outlet[i].runtime.isReady		:= FALSE;
								pClientCom.outlet[i].runtime.isRequesting	:= FALSE;
								pClientCom.outlet[i].runtime.isTransfered	:= TRUE;
								
								pClientCom.outlet[i].interface.isTransfering 		:= FALSE;
								pClientCom.outlet[i].interface.isRequesting			:= FALSE;
								pClientCom.outlet[i].interface.isTransferingDone	:= FALSE;
								pClientCom.outlet[i].step 					:= INTERCOM_TRANSFERED;
							END_IF
							
						INTERCOM_TRANSFERED:	
							IF (arrClientConnectionControl[No - 1].xAbortFlag OR pClientCom.outlet[i].interface.isAbort) THEN
								pClientCom.outlet[i].step := INTERCOM_ABORTED;
							ELSIF (pClientCom.outlet[i].interface.isTransferingDone ) THEN
								pClientCom.outlet[i].interface.isTransfering								:= FALSE;
								arrClientConnectionControl[No - 1].arrOutlet[i].xOUT_ClientUnloadingDone 	:= TRUE;
								pClientCom.outlet[i].step 													:= INTERCOM_RESET;
							END_IF
							
						// Error handling Inlet Aborted!!! handle error.	
						INTERCOM_ABORTED:
							pClientCom.outlet[i].runtime.isReady := FALSE; 
							IF pClientCom.outlet[i].interface.isAbort THEN
								pClientCom.outlet[i].step := INTERCOM_RESET;
							ELSE 
								pClientCom.outlet[i].runtime.isAborted := TRUE;
								IF (pClientCom.outlet[i].interface.isAbortAcknowledged) THEN
									arrClientConnectionControl[No - 1].xAbortFlag	:= FALSE;
									pClientCom.outlet[i].step 						:= INTERCOM_RESET;
								END_IF
							END_IF
						
						// Reset variables.
						INTERCOM_RESET:
							pClientCom.outlet[i].runtime.isTransfered			:= FALSE;
							pClientCom.outlet[i].interface.isRequesting			:= FALSE;
							pClientCom.outlet[i].interface.isAbortAcknowledged	:= FALSE;
							pClientCom.outlet[i].runtime.isAborted 				:= FALSE;
							pClientCom.outlet[i].interface.isAbort	 			:= FALSE;
							pClientCom.outlet[i].step						 	:= INTERCOM_IDLE;
							pClientCom.outlet[i].interface.isTransfering		:= FALSE;
							pClientCom.outlet[i].interface.isTransferingDone	:= FALSE;
					END_CASE
				END_FOR
				
			END_FOR
		END_IF
	END_IF
END_PROGRAM
