PROGRAM _INIT
	
	// No namespace to for easy access.
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	pHMIHandler ACCESS ADR(g_Core.Services.HMIHandler.Runtime.Handler[0]);
	
	// Use max from g_System.File?
	pThis.Runtime.maxConnections	:= SIZEOF(pThis.Runtime.connection) / SIZEOF(pThis.Runtime.connection[0]);
	
	connectionPageCount := 1;
		
	pThis.Runtime.initState := INIT;
	
	// Status Page - How Often to change between values
	changeValueAfter := 2; (* Sekunds *)

	// Get numbers of storable connection settings from systemfile
	sysNoSetting := (SIZEOF(g_Core.Services.System.Runtime.file.Connection) / SIZEOF(g_Core.Services.System.Runtime.file.Connection[0]));

END_PROGRAM


PROGRAM _CYCLIC
	// Reaccess..
	pThis ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	
	CASE pThis.Runtime.initState OF
		// Should we have to states? Another one inside runtime?
		INIT:	
			IF (g_Core.Services.System.Runtime.initState = RUNTIME) THEN
				
				FOR No := 0 TO (SIZEOF(connectionHMI) / SIZEOF(connectionHMI[0])) - 1 DO
					// Init HMI containers
					memset(ADR(connectionHMI[No]),0,SIZEOF(connectionHMI[0]));
					connectionHMI[No].isHidden	:= TRUE;
				END_FOR
		
				connectionDetails.displayConnectionNo 	:= 0;
				connectionStatus.displayConnectionNo 	:= 0;
				connectionPage 							:= 1;
				connectionPageChanged 					:= 1;
		
				FOR No := 0 TO (pThis.Runtime.maxConnections - 1) DO
							
					// Set default first 2 segments
					pThis.Runtime.connection[No].serverIPSegments[0]				:= 172;
					pThis.Runtime.connection[No].serverIPSegments[1]				:= 16; 
								
					pThis.Runtime.connection[No].initState							:= NA;
					pThis.Runtime.connection[No].metaData.refreshTime		 		:= 0;
					pThis.Runtime.connection[No].metaData.options				 	:= '';
					pThis.Runtime.connection[No].metaData.connectionID				:= 0;
					pThis.Runtime.connection[No].metaData.address					:= '';
					//pThis.Runtime.connection[No].metaData.isEnabled					:= 0;
				END_FOR
			
				connectionDetails.isHidden 				:= TRUE;
				connectionStatus.isHidden 				:= TRUE;
				connectionDetails.isHiddenErrorDialog 	:= TRUE;
				
				pThis.Runtime.loadState			:= INIT;
				pThis.Runtime.saveState			:= INIT;
			
				pThis.Interface.cmd				:= CMD_NONE;
			
				// Set default Segment max value, if not set from interface.
				FOR No := 0 TO 3 DO
					CASE No OF
						0:
							IF pThis.Interface.serverIPSegmentMax[No] = 0 THEN
								pThis.Interface.serverIPSegmentMax[No] := 172;
							END_IF
							IF pThis.Interface.serverIPSegmentMin[No] = 0 THEN
								pThis.Interface.serverIPSegmentMin[No] := 172;
							END_IF
						1:
							IF pThis.Interface.serverIPSegmentMax[No] = 0 THEN
								pThis.Interface.serverIPSegmentMax[No] := 16;
							END_IF
							IF pThis.Interface.serverIPSegmentMin[No] = 0 THEN
								pThis.Interface.serverIPSegmentMin[No] := 16;
							END_IF
						2,3:
							IF pThis.Interface.serverIPSegmentMax[No] = 0 THEN
								pThis.Interface.serverIPSegmentMax[No] := 254;
							END_IF
					END_CASE
				END_FOR
				
				// Go to load connections.
				pThis.Runtime.state		:= RS_LOAD;
				pThis.Runtime.initState := RUNTIME;
				
			END_IF
			
		RUNTIME:
			
			isExternalConnected[2] := g_PrinterComHMI.CommunicationStatus = 1 OR Test[0];
		
			CASE pThis.Runtime.state OF
					
					RS_IDLE:
						// Check for errors on any connection not just the current screen.
						FOR No := 0 TO (SIZEOF(pThis.Runtime.connection) / SIZEOF(pThis.Runtime.connection[0])) - 1 DO
							// Check is connection is enabled and initialized
							//Simple alarm reset
							pThis.Runtime.connection[No].isConnected := g_Core.Services.Alarmhandler.Interface.AlarmGroup[0].Alarm[49+pThis.Interface.connection[No].descriptionID] := 0;
							
							// This trigger should not be used anymore!
							g_Core.System.Runtime.isConnectionError := FALSE;
							
							pThis.Runtime.connection[No].pClientHandler := pThis.Interface.connection[No].pClientHandler;
							pThis.Runtime.connection[No].pClientLogic 	:= pThis.Interface.connection[No].pClientLogic;
							pThis.Runtime.connection[No].pServerHandler := pThis.Interface.connection[No].pServerHandler;
							pThis.Runtime.connection[No].pServerLogic 	:= pThis.Interface.connection[No].pServerLogic;
							
							IF (pThis.Runtime.connection[No].metaData.isEnabled AND pThis.Runtime.connection[No].initState = RUNTIME) THEN
								// Set filter for allowing a short cut in the connection
								TON_CommCheck[No](IN:=(pThis.Interface.connection[No].status.clientState = 0 OR pThis.Interface.connection[No].status.serverState = 0), PT:=500);
								IF (TON_CommCheck[No].IN) THEN
									lagTimer[No] := lagTimer[No] + 1;
								ELSE
									lagTimer[No] := 0;
								END_IF
								// Check is the connection is lost for more than n Seconds.
								g_Core.Services.Alarmhandler.Interface.AlarmGroup[0].Alarm[49+pThis.Interface.connection[No].descriptionID] := TON_CommCheck[No].Q;
								pThis.Runtime.connection[No].isConnected :=  NOT TON_CommCheck[No].Q OR isExternalConnected[No];
								IF (NOT pThis.Runtime.connection[No].isConnected) THEN
									g_Core.System.Runtime.isConnectionError := TRUE;
								END_IF
							END_IF
						END_FOR
						
						// Update connectionHMI	
												
						FOR No := 0 TO (SIZEOF(connectionHMI) / SIZEOF(connectionHMI[0])) - 1 DO
							IF (NOT connectionPageChanged) THEN
								connectionHMI[No].connectionNumber  := No + ((connectionPage - 1) * 5);
								
								connectionHMI[No].isEnabled 		:= pThis.Runtime.connection[connectionHMI[No].connectionNumber].metaData.isEnabled;
								connectionHMI[No].isHidden			:= NOT pThis.Interface.connection[connectionHMI[No].connectionNumber].isEnabled;
								connectionHMI[No].descriptionID		:= pThis.Interface.connection[connectionHMI[No].connectionNumber].descriptionID;
							END_IF
							
							pThis.Runtime.connection[connectionHMI[No].connectionNumber].metaData.isEnabled := connectionHMI[No].isEnabled;
							IF NOT (connectionHMI[No].isEnabled) THEN
										connectionHMI[No].statusTextID			:= 0;
										connectionHMI[No].statusColor			:= 4093;
							ELSE
								CASE pThis.Runtime.connection[connectionHMI[No].connectionNumber].initState OF
								INIT:
									
									connectionHMI[No].statusTextID			:= 1;
									IF NOT g_Core.Services.Alarmhandler.Runtime.blinkPulse THEN
										connectionHMI[No].statusColor			:= 3881;
									ELSE
										connectionHMI[No].statusColor			:= 4093;
									END_IF						
									IF isExternalConnected[No] THEN
										pThis.Runtime.connection[connectionHMI[No].connectionNumber].initState := RUNTIME;
									END_IF
									
									
								RUNTIME:
																							
									// 3 cases here, server not ok, client not ok & server & client not ok.
									// ERROR
									IF (pThis.Interface.connection[connectionHMI[No].connectionNumber].status.clientState = 0 AND 
										pThis.Interface.connection[connectionHMI[No].connectionNumber].status.serverState = 0) AND NOT isExternalConnected[No] THEN
										connectionHMI[No].statusTextID			:= 2;
										IF NOT g_Core.Services.Alarmhandler.Runtime.blinkPulse THEN
											connectionHMI[No].statusColor			:= 3885;
										ELSE
											connectionHMI[No].statusColor			:= 4093;
										END_IF
									// Link up.
									ELSIF (pThis.Interface.connection[connectionHMI[No].connectionNumber].status.clientState = 1 AND 
										pThis.Interface.connection[connectionHMI[No].connectionNumber].status.serverState = 1) OR isExternalConnected[No] THEN
										connectionHMI[No].statusColor			:= 3850;
										connectionHMI[No].statusTextID			:= 3;
									// Server down.
									ELSIF (pThis.Interface.connection[connectionHMI[No].connectionNumber].status.serverState = 1) THEN
										connectionHMI[No].statusTextID			:= 4;
										IF NOT g_Core.Services.Alarmhandler.Runtime.blinkPulse THEN
											connectionHMI[No].statusColor			:= 3885;
										ELSE
											connectionHMI[No].statusColor			:= 4093;
										END_IF
									// Client Down.
									ELSIF (pThis.Interface.connection[connectionHMI[No].connectionNumber].status.clientState = 1) THEN
										connectionHMI[No].statusTextID			:= 5;
										IF NOT g_Core.Services.Alarmhandler.Runtime.blinkPulse THEN
											connectionHMI[No].statusColor			:= 3885;
										ELSE
											connectionHMI[No].statusColor			:= 4093;
										END_IF
									END_IF						
								END_CASE
							END_IF
						END_FOR
						
						connectionPageChanged := TRUE;
						
						// Check if we are on the M2M Page.
						IF (pHMIHandler.PageControllerID = 16) THEN 
							// Check for page change?
							IF (pHMIHandler.KeyPressed = 0 AND oldInput > 0 AND oldInput < 3 ) THEN
								connectionPageChanged	:= FALSE;
								CASE oldInput OF
									1:
										IF (connectionPage > 1) THEN
											connectionPage := connectionPage - 1;
										END_IF
									2:
										IF (connectionPage < connectionPageCount) THEN
											connectionPage := connectionPage + 1;
										END_IF
								END_CASE
							END_IF
							oldInput := pHMIHandler.KeyPressed;
						END_IF

						// Check for Commands. 
						CASE pThis.Interface.cmd OF
					
							// Sorry for Party Rocking!
							CMD_LOAD:
								pThis.Runtime.state := RS_LOAD;
								Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
								
							CMD_REFRESH:
								pThis.Runtime.state := RS_LOAD;
										 
							CMD_SAVE:
								//checkConnections;
								pThis.Runtime.state := RS_SAVE;
								Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				
							CMD_SAVE_AND_REBOOT:
								//checkConnections;
								pThis.Runtime.state	:= RS_SAVE;
								reboot 				:= TRUE;
								Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
						END_CASE
				
						pThis.Interface.cmd			:= CMD_NONE;		
				
									
						IF (connectionDetails.displayConnectionNo > 0) THEN
							connectionDetails.isHidden	:= FALSE;
							pThis.Runtime.state			:= RS_EDIT;
							
							// Get details for the selected connection
							getConnectionDetails;
							
						END_IF
						
					IF (connectionStatus.displayConnectionNo > 0) THEN
						IF (connectionHMI[connectionStatus.displayConnectionNo - 1].isEnabled) THEN
							connectionStatus.isHidden	:= FALSE;
							pThis.Runtime.state			:= RS_STATUS;
						END_IF
					END_IF	
				
					RS_STATUS:
						getConnectionStatus;
						CASE connectionStatus.cmd OF
							0:
								// Set the color of the button
								CASE connectionStatus.pingStatus OF	
									0:	// Neutral.... Like Sweden
										connectionStatus.pingColor 			:= 252;
									1:	// Testing
										connectionStatus.pingColor 			:= 46;
									2:  // It´s Rocking!!
										connectionStatus.pingColor 			:= 220;
									3: 	// ERROR
										connectionStatus.pingColor 			:= 45;								
								END_CASE
								
	  						1:	//Close.. It TIME TO go
								pThis.Runtime.state						:= RS_IDLE;
								connectionStatus.isHidden				:= TRUE;
								connectionStatus.displayConnectionNo 	:= 0;
								connectionStatus.cmd 					:= 0;
								ICMPping_0( enable := FALSE);
								TON_10ms_0(IN:= FALSE);
								connectionStatus.pingStatus 			:= 0;
								connectionStatus.pingEnable				:= 0;
															
										
							2: // PING												
								connectionStatus.serverAdr				:= pThis.Runtime.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.address;
								//connectionStatus.pingIPNetworkByteOrdre	:= inet_addr(ADR(connectionStatus.serverAdr));
								IF connectionStatus.pingEnable = 0 THEN
									connectionStatus.pingEnable			:= TRUE;
									connectionStatus.pingColor 			:= 46;
									connectionStatus.pingStatus			:= 0;
									connectionStatus.pingTimeout		:= 0;
								END_IF
								
								ICMPping_0( enable := connectionStatus.pingEnable, pHost := ADR(connectionStatus.serverAdr), timeout := 1000 );
								TON_10ms_0( IN := connectionStatus.pingEnable, PT :=  1000 );
								
								connectionStatus.pingStatus				:= 1;
								
								// Result = OK
								IF ICMPping_0.status = 0 THEN
									ICMPping_0( enable := FALSE);
									TON_10ms_0(IN:= FALSE);
									connectionStatus.pingStatus 		:= 2;
									connectionStatus.pingEnable			:= 0;
									connectionStatus.cmd				:= 0;
								END_IF
								
								// Timeout			
								IF TON_10ms_0.Q = 1 THEN
									ICMPping_0( enable := FALSE);
									TON_10ms_0(IN:= FALSE);
									connectionStatus.pingStatus			:= 3;
									connectionStatus.cmd				:= 0;
									connectionStatus.pingEnable			:= 0;	
								END_IF;	
						END_CASE
						
						(*----------------------------------------------*)
						(* Connection Status | Respons And Refresh time *)
						(*----------------------------------------------*)
						IF (pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.RefreshTime <> OldstatusRefreshRate) THEN
							itoa(pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.RefreshTime,ADR(TempStr));
							strcpy(ADR(TempStrFinal),ADR(TempStr));
							strcat(ADR(TempStrFinal),ADR(' / '));
							itoa(pThis.Runtime.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.refreshTime*2,ADR(TempStr));
							strcat(ADR(TempStrFinal),ADR(TempStr));
							strcpy(ADR(connectionStatus.CCstring),ADR(TempStrFinal));
							OldstatusRefreshRate := pThis.Interface.connection[connectionStatus.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].status.RefreshTime;
						END_IF
						
									
					RS_EDIT:
						
						
						IF	(connectionDetails.isConnectionIDEntered) THEN
							connectionDetails.isConnectionIDEntered := FALSE;
							// Check the ID Number
							checkConnectionID;
							
							// Open Dialog for ConnectionID error.
							IF (invalidConnectionID) THEN
								invalidConnectionID					  := FALSE;
								connectionDetails.errorDialogString	  := 'The connection ID is not valid: ';
								itoa(connectionDetails.connectionID, ADR(tmpStr));
								strcat(ADR(connectionDetails.errorDialogString),ADR(tmpStr));
								connectionDetails.isHiddenErrorDialog := FALSE;
								connectionDetails.connectionID		  := pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.connectionID;
							END_IF
						END_IF
						
						IF (connectionDetails.isServerAdrEntered) THEN
							connectionDetails.isServerAdrEntered := FALSE;
							// Check the IP
							checkIpAddress;	
							
							// Open Dialog for IP error.
							IF (invalidIP) THEN
								invalidIP							  := FALSE;
								connectionDetails.errorDialogString	  := 'The IP entered is not valid: ';
								strcat(ADR(connectionDetails.errorDialogString),ADR(connectionDetails.serverAdr));
								connectionDetails.isHiddenErrorDialog := FALSE;
								connectionDetails.serverAdr			  := pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1+ ((connectionPage - 1) * 5)].metaData.address;
								// restore adr?
							END_IF	
						END_IF
								
						
						CASE (connectionDetails.cmd) OF
							CD_CANCEL:
								// Close and do not save changes!
								connectionDetails.cmd 		:= CD_IDLE;	
					
								connectionDetails.isHidden	:= TRUE;
								pThis.Runtime.state			:= RS_IDLE;
								// Reset requested connectio no.
								connectionDetails.displayConnectionNo := 0;
						
							CD_UNDO:
								// Close error dialog incase it is open.
								connectionDetails.isHiddenErrorDialog 	:= TRUE;
								// Reset error string.
								connectionDetails.errorDialogString		:= '';
								
								// Undo changes!
								getConnectionDetails;
								connectionDetails.cmd 		:= CD_IDLE;	
					
							CD_SAVE:
								// Close and save changes!
								connectionDetails.cmd 		:= CD_IDLE;
					
								connectionDetails.isHidden	:= TRUE;
								pThis.Runtime.state			:= RS_SAVE;
								
								// Copy new settings to runtime.
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.port		 			:= connectionDetails.port;
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.connectionID 			:= connectionDetails.connectionID;
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.address	 			:= connectionDetails.serverAdr;
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.isBASE64Enabled 		:= connectionDetails.isBase64Enabled;
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.refreshTime			:= connectionDetails.refreshTime;
								pThis.Runtime.connection[connectionDetails.displayConnectionNo - 1 + ((connectionPage - 1) * 5)].metaData.options				:= connectionDetails.options;
								
								// Reset requested connectio no.
								connectionDetails.displayConnectionNo := 0;
						END_CASE
						
						
			
				RS_SAVE:
					// Save new Connection Settings.
					CASE pThis.Runtime.saveState OF
				
						INIT:
							
							// Make connection IP String.
							FOR No := 0 TO (pThis.Runtime.maxConnections - 1) DO
								IF (pThis.Interface.connection[No].isEnabled AND pThis.Interface.connection[No].sysID <= sysNoSetting ) THEN
																								
									// Save all connections 
									// Set data in g_System.File!
									g_Core.Services.System.Runtime.file.Connection[pThis.Interface.connection[No].sysID-1]	:= pThis.Runtime.connection[No].metaData;
								END_IF
							END_FOR
					
							saveCounter := g_Core.Services.System.Runtime.saveCount;
							g_Core.Services.System.Interface.isCmdSave := TRUE;
							pThis.Runtime.saveState := CHECK;
						
						CHECK:
							IF (g_Core.Services.System.Runtime.saveCount > saveCounter) THEN
								//g_Core.System.Interface.isRequestReboot := TRUE;
								pThis.Runtime.saveState := INIT;
								pThis.Runtime.state := RS_IDLE;
							END_IF
						
						END_CASE

				RS_LOAD:
			
					CASE pThis.Runtime.loadState OF
			
						INIT:
							// Wait for system file to be loaded.
							newavailableConnections	:= 0;
							// Load all connections 
							FOR No := 0 TO (pThis.Runtime.maxConnections - 1) DO
								IF (pThis.Interface.connection[No].isEnabled) THEN
									//pThis.Runtime.connection[No].changeID					:= pThis.Interface.connection[No].modeID = SELECTABLE;
									IF ( pThis.Interface.connection[No].sysID <= sysNoSetting) THEN
										pThis.Runtime.connection[No].metaData				 	:= g_Core.Services.System.Runtime.file.Connection[pThis.Interface.connection[No].sysID-1];
									END_IF
									// Overload Connection ID if set.
									IF (pThis.Interface.connection[No].connectionID > 0) THEN
										pThis.Runtime.connection[No].metaData.connectionID := pThis.Interface.connection[No].connectionID;
									END_IF
									// Overload Connection Address.
									IF (pThis.Interface.connection[No].adrAddress > 0) THEN
										strcpy(ADR(pThis.Runtime.connection[No].metaData.address), pThis.Interface.connection[No].adrAddress);
									END_IF
									// Overload Connection Options.
									IF (pThis.Interface.connection[No].adrOptions > 0) THEN
										strcpy(ADR(pThis.Runtime.connection[No].metaData.options), pThis.Interface.connection[No].adrOptions);
									END_IF
									
									// Set state to NA
									IF (pThis.Runtime.connection[No].initState = NA) THEN
										pThis.Runtime.connection[No].initState				:= INIT; // ready for hugging!
									END_IF
									newavailableConnections 								:= newavailableConnections + 1;
									
								END_IF
							END_FOR
							pThis.Runtime.availableConnections := newavailableConnections;
							// Put in seperate HMI logic?
							IF pThis.Runtime.availableConnections > 5 THEN // Disable extra screen if connections are below 6.
								connectionPageCount := REAL_TO_USINT(ceil(USINT_TO_REAL(pThis.Runtime.availableConnections) / 5));
								UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 16, 1, 29, 0, 1000);
								UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 16, 2, 30, 0, 1000);
							END_IF
							
							pThis.Runtime.loadState := RUNTIME;
				
							
						RUNTIME:
					
							// Do we need to check what we load? (Red system alarm?) Check after input? DONE
							pThis.Runtime.state := RS_IDLE;
							// Everything is ok reset loadState
							pThis.Runtime.loadState	:= IDLE;
							connectionPageChanged	:= FALSE;
					
					
						ERROR:
							pThis.Runtime.state := RS_ERROR;
			
					END_CASE
			END_CASE
		
		END_CASE
END_PROGRAM


