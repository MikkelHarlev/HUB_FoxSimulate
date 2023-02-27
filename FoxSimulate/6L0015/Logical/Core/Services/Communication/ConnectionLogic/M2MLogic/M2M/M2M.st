(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: M2M
 * File: M2M.st
 * Author: eg
 * Created: May 23, 2014
 ********************************************************************
 * Implementation of program M2M
 ********************************************************************)

PROGRAM _INIT
	
	taskState := INIT;
	pFlatXML ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.FlatXML);
	pConnectionManager ACCESS ADR(g_Core.Services.Communication.ConnectionManager);
	
END_PROGRAM


PROGRAM _CYCLIC
	
	CASE taskState OF
		
		INIT:
			
			taskState := RUNTIME;
			// Clear Logic.
			memset(ADR(M2MLogicCom),0,SIZEOF(M2MLogicCom));
		
		RUNTIME:
		
			IF (pFlatXML.Runtime.serversRunning > 0) THEN
				FOR No := 0 TO pFlatXML.Runtime.serversRunning - 1 DO
			
					// Found a connection that is enabled and initialized by the connection manager and bring it in runtime.
					IF ((pConnectionManager.Runtime.connection[pFlatXML.Runtime.connection[No].connectionManagerID].initState = RUNTIME) AND 
							(pConnectionManager.Runtime.connection[pFlatXML.Runtime.connection[No].connectionManagerID].logicState = INIT) AND
								 (pFlatXML.Runtime.connection[No].logicType = M2M) ) THEN
				
						// Add connection count
						connectionsRunning := connectionsRunning + 1;
						
						// Set refresh time
						M2MLogicCom[No].ResendInterval := pConnectionManager.Runtime.connection[pFlatXML.Runtime.connection[No].connectionManagerID].metaData.refreshTime;
						
						// Set Logic State to RUNTIME.
						pConnectionManager.Runtime.connection[pFlatXML.Runtime.connection[No].connectionManagerID].logicState := RUNTIME;
				
					END_IF
				END_FOR
		
				IF (connectionsRunning > 0) THEN
					FOR No := 0 TO connectionsRunning - 1 DO
						// DO LOGIC HERE!	
						// Fetch Client Data, dada da...
						pClient ACCESS ADR(pFlatXML.Runtime.connection[No].client);
						pTxLane ACCESS ADR(M2MLogicCom[No].TxLane);
						// Implementing "old" M2M Logic from machines.....
						// A reimplementation using memcmp could speed it up alot.
						IF NOT M2MLogicCom[No].TxSend THEN
							M2MLogicCom[No].TxLaneOld := pTxLane;
							REPEAT
								// MAX???
								IF pTxLane > 7 THEN
									pTxLane := 0;
								ELSE
									pTxLane := pTxLane + 1;
								END_IF
								
								// Making aliases for TxLane and FlatworkData
								pFlatworkData ACCESS ADR(M2MLogicCom[No].FlatworkData[pTxLane]);
								
								// Check for Customer Change.
								IF pClient.FlatworkData[pTxLane].CustomerNo <> pFlatworkData.CustomerNo THEN
									pFlatworkData.CustomerNo := pClient.FlatworkData[pTxLane].CustomerNo;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for Article Change.
								IF pClient.FlatworkData[pTxLane].ArticleNo <> pFlatworkData.ArticleNo THEN
									pFlatworkData.ArticleNo := pClient.FlatworkData[pTxLane].ArticleNo;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for Recipe Change.
								IF pClient.FlatworkData[pTxLane].RcpNo <> pFlatworkData.RcpNo THEN
									pFlatworkData.RcpNo := pClient.FlatworkData[pTxLane].RcpNo;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for Status Change.
								IF pClient.FlatworkData[pTxLane].Status <> pFlatworkData.Status THEN
									pFlatworkData.Status := pClient.FlatworkData[pTxLane].Status;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for OperatorNo Change.
								IF pClient.FlatworkData[pTxLane].OperatorNo <> pFlatworkData.OperatorNo THEN
									pFlatworkData.OperatorNo := pClient.FlatworkData[pTxLane].OperatorNo;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareDATE Change.
								IF pClient.FlatworkData[pTxLane].SpareDATE <> pFlatworkData.SpareDATE THEN
									pFlatworkData.SpareDATE := pClient.FlatworkData[pTxLane].SpareDATE;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareREAL Change.
								IF pClient.FlatworkData[pTxLane].SpareREAL <> pFlatworkData.SpareREAL THEN
									pFlatworkData.SpareREAL := pClient.FlatworkData[pTxLane].SpareREAL;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareTIME Change.
								IF pClient.FlatworkData[pTxLane].SpareTIME <> pFlatworkData.SpareTIME THEN
									pFlatworkData.SpareTIME := pClient.FlatworkData[pTxLane].SpareTIME;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareUDINT Change.
								IF pClient.FlatworkData[pTxLane].SpareUDINT <> pFlatworkData.SpareUDINT THEN
									pFlatworkData.SpareUDINT := pClient.FlatworkData[pTxLane].SpareUDINT;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareUINT Change.
								IF pClient.FlatworkData[pTxLane].SpareUINT <> pFlatworkData.SpareUINT THEN
									pFlatworkData.SpareUINT := pClient.FlatworkData[pTxLane].SpareUINT;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for SpareUSINT Change.
								IF pClient.FlatworkData[pTxLane].SpareUSINT <> pFlatworkData.SpareUSINT THEN
									pFlatworkData.SpareUSINT := pClient.FlatworkData[pTxLane].SpareUSINT;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for Text Change.
								IF pClient.FlatworkData[pTxLane].Text <> pFlatworkData.Text THEN
									pFlatworkData.Text := pClient.FlatworkData[pTxLane].Text;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for TextNo Change.
								IF pClient.FlatworkData[pTxLane].TextNo <> pFlatworkData.TextNo THEN
									pFlatworkData.TextNo := pClient.FlatworkData[pTxLane].TextNo;
									M2MLogicCom[No].TxSend := 1;
								END_IF
								
								// Check for Info Change.
								IF pClient.FlatworkData[M2MLogicCom[No].TxLane].Info > 0 THEN
									M2MLogicCom[No].RInfo[pTxLane] := TRUE;
									M2MLogicCom[No].TxSend := 1;
								END_IF
			
								// Check for SortingClassNo Change.
								IF pClient.FlatworkData[pTxLane].SortingClassNo > 0 THEN
									M2MLogicCom[No].RSrt[pTxLane] := TRUE;
									M2MLogicCom[No].TxSend := 1;
								END_IF
	
	                          	IF (pTxLane = 0) AND (pClient.FlatworkData[pTxLane].Speed > pFlatworkData.Speed + 10) OR (pClient.FlatworkData[pTxLane].Speed + 10 < pFlatworkData.Speed) THEN
	                            	pFlatworkData.Speed := pClient.FlatworkData[pTxLane].Speed;
	                            	M2MLogicCom[No].TxSend := 1;
                               	END_IF

							UNTIL M2MLogicCom[No].TxSend OR ( M2MLogicCom[No].TxLane = M2MLogicCom[No].TxLaneOld ) END_REPEAT;
						END_IF

						// Update Every 5 Second
						M2MLogicCom[No].TxResendCounter := M2MLogicCom[No].TxResendCounter + 1;
						IF NOT M2MLogicCom[No].TxSend THEN
							FOR M2MLogicCom[No].Update := 0 TO 8 DO
								IF M2MLogicCom[No].TxResendCounter > ( M2MLogicCom[No].TxResend[M2MLogicCom[No].Update] + M2MLogicCom[No].ResendInterval ) AND M2MLogicCom[No].RResendEnable[M2MLogicCom[No].Update] THEN
									pTxLane := M2MLogicCom[No].Update;
									M2MLogicCom[No].TxSend := 1;
									EXIT;
								END_IF
							END_FOR
						END_IF

						// Send
						IF (M2MLogicCom[No].TxSend AND NOT M2MLogicCom[No].TxWait) THEN
							pClient.LaneNo           				:= pTxLane;
							pClient.SendFlatworkData 				:= 1;
							pClient.RequestOk        				:= 0;
							M2MLogicCom[No].RResendEnable[pTxLane] 	:= 1;
							M2MLogicCom[No].TimeOut    				:= 0;
							M2MLogicCom[No].TxWait     				:= 1;
						END_IF

						// Wait for Request Ok
						IF (M2MLogicCom[No].TxWait) THEN
							
							IF (pClient.RequestOk) THEN
							
								IF (M2MLogicCom[No].RSrt[pTxLane]) THEN
									M2MLogicCom[No].RSrt[pTxLane] 				:= FALSE;
									pClient.FlatworkData[pTxLane].SortingClassNo := 0;
								END_IF
								
								IF (M2MLogicCom[No].RInfo[pTxLane]) THEN
									M2MLogicCom[No].RInfo[pTxLane] 		:= FALSE;
									pClient.FlatworkData[pTxLane].Info	:= 0;
								END_IF
								
								M2MLogicCom[No].TxResend[pTxLane] := M2MLogicCom[No].TxResendCounter;
								M2MLogicCom[No].TxWait := 0;
								M2MLogicCom[No].TxSend := 0;
							ELSE
								M2MLogicCom[No].TimeOut := M2MLogicCom[No].TimeOut + 1;
								IF M2MLogicCom[No].TimeOut > 6 THEN
									M2MLogicCom[No].TxWait := 0;
								END_IF
							END_IF
							
						END_IF
			
					END_FOR
			
				END_IF
		
			END_IF
	
	END_CASE
	
END_PROGRAM
