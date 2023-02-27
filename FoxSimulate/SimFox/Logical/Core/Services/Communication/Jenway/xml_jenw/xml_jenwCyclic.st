PROGRAM _CYCLIC
(*--------------------------------------------------------------------------------------------------------------------
	Author:			Jensen Denmark

	Filename:		xml_jenw.st

	Description: 	Implementation of program comhandler
 								Simple state machine to handle the client function block

	History:		01-01-2005		V1.00		XX
					11-08-2016		V2.06		AHO		Fixed/Changed: Batch ID/Track ID, Stacker length + clean up
					04-09-2016		V2.06.1		AHO		Fixed: Clear .Go if case of too long/many 
					21-09-2016		V2.07		AHO		Changed: pJenwayCom.outlet[No], connection is now 0 based, even if no crossconv. 0 is for stacker 1 if no crossconv, and for all stackers if crossconv
					14-12-2017		V2.08		AHO		Changed: Only set pJenwayCom.outlet[No].interface.isTransferingDone if pJenwayCom.outlet[No].runtime.isTransfered 
					14-12-2018		V2.09		AHO		Added: New variables inuse if delivery rollOff with Jenway XML
									
--------------------------------------------------------------------------------------------------------------------*)
	
IF NOT g_Core.System.Runtime.isInitDone THEN
	RETURN;
END_IF
//	jenwayComIdent := g_Core.Services.Communication.ConnectionLogic.Interconnect.Runtime.clientLogicIdents[0];
	//	pJenwayCom ACCESS (jenwayComIdent);
	getLogicIdent_0(sysID :=4 , roleType := CLIENT );
	IF getLogicIdent_0.logicIdent >0 THEN
			pJenwayCom ACCESS (getLogicIdent_0.logicIdent );
					
//			pJenwayCom.outlet[0].data := pJenwayCom.outlet[0].data;
//			pJenwayCom.outlet[0].interface := pJenwayCom.outlet[0].interface;
//
//			pJenwayCom.outlet[0].runtime := pJenwayCom.outlet[0].runtime;
//		(*	pJenwayCom.outlet[0].step		:= pJenwayCom.outlet[0].step;*)

		(*----------------------*)
//		IF EDGEPOS (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output) OR ( EDGEPOS(g_Core.System.Runtime.isRunning) AND g_OutletProcess.StackerUnit[1].BeltEndSensor.Output )
//			OR (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output AND (pJenwayCom.outlet[0].step = INTERCOM_IDLE) AND NOT g_Jenway.No[0].Request   ) THEN	// send request to Jenway
//			g_Jenway.No[0].Request := 1;
//		END_IF
		
			// Handshaking with Delivery
			IF isAbortAcknowledged THEN
				isAbortAcknowledged := FALSE;
				pJenwayCom.outlet[0].interface.isAbortAcknowledged := FALSE;
			END_IF
			IF pJenwayCom.outlet[0].interface.isAbortAcknowledged THEN
				isAbortAcknowledged := TRUE;
			END_IF
			//pJenwayCom.outlet[0].interface.isAbort := FALSE;
			pJenwayCom.outlet[0].interface.isAbort := FALSE;
			pJenwayCom.outlet[0].interface.isAborting	:= FALSE;
	
		g_OutletProcess.NextMachineReady[1]	:= pJenwayCom.outlet[0].runtime.isReady;
		IF EDGEPOS (pJenwayCom.outlet[0].runtime.isTransfered)  THEN		// shift bufferData array
			g_ShiftBufferData	:= TRUE;
		END_IF;
		// done
		IF EDGENEG (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output) THEN			// stack transfered to Jenway
			g_Jenway.No[0].Done := 1;
		END_IF
		// abort if stack removed manually
		IF  EDGENEG (g_OutletProcess.StackerUnit[1].BeltEndSensor.Output)  AND NOT pJenwayCom.outlet[0].runtime.isReady THEN
			pJenwayCom.outlet[0].interface.isAborting	:= TRUE;
			pJenwayCom.outlet[0].interface.isRequesting	:= FALSE;
				g_ShiftBufferData	:= TRUE;
		END_IF
	
	IF g_HCfg.DeliveryExternalCommunication = 2 THEN
	// Numbers of outlets
	//IF g_HCfg.InMachine.CrossConv.Conv THEN
		NoOutlets := 0;
//	ELSE
//		NoOutlets := g_HCfg.InMachine.Stack.Numbers-1;	
//	END_IF
		
	FOR No := 0 TO NoOutlets DO			
			// Send request to Jenway
		IF g_Jenway.No[No].Request THEN
			g_Jenway.No[No].Request := 0;
			pJenwayCom.outlet[No].interface.isRequesting := TRUE;
		END_IF
		
		// Don't request while stopped
		IF NOT g_Core.System.Runtime.isRunning THEN
			pJenwayCom.outlet[No].interface.isRequesting := FALSE;
		END_IF

		// Blocked or not ?
		 g_Jenway.No[No].Blocked := NOT pJenwayCom.outlet[No].runtime.isReady;
		 g_Jenway.No[No].ShowBlocked := pJenwayCom.outlet[No].interface.isRequesting AND NOT pJenwayCom.outlet[No].runtime.isReady;
		 
		// 	Ready
		IF pJenwayCom.outlet[No].runtime.isReady THEN

			// Send new 
			IF g_Jenway.No[No].Go THEN
				g_Jenway.No[No].Go := 0;
				pJenwayCom.outlet[No].interface.isTransfering := TRUE;
		
				TrackID := TrackID +1;

						pJenwayCom.outlet[No].data.CustomerNumber	:= UDINT_TO_DINT(g_OutletProcess.JenwayExchange[0].Stack.CustomerId);
						pJenwayCom.outlet[No].data.ArticleNumber 		:= UINT_TO_DINT(g_OutletProcess.JenwayExchange[0].Stack.ArticleId);
						pJenwayCom.outlet[No].data.CategoryNumber 	:=  UINT_TO_INT (g_OutletProcess.JenwayExchange[0].Stack.FoldProgram);
						pJenwayCom.outlet[No].data.ExitNumber			 := 1; // Actual stacker
						pJenwayCom.outlet[No].data.ArticleCount 			:= UINT_TO_INT (g_OutletProcess.JenwayExchange[0].Stack.Count);
						pJenwayCom.outlet[No].data.ExpectedCount 		:= g_RCfg[LIMIT(0, (g_OutletProcess.JenwayExchange[0].Stack.FoldProgram - 1), MAX_NUMBER_OF_CATEGORIES)].Outlet.NumberOfProducts;
						pJenwayCom.outlet[No].data.Option 					:= UINT_TO_DINT (g_OutletProcess.JenwayExchange[0].Stack.Destination); // to sealer or strapper
						pJenwayCom.outlet[No].data.BatchID 				:= UDINT_TO_DINT (TrackID); // Track ID
						pJenwayCom.outlet[No].data.SourceID 				:= INT_TO_DINT (g_MCfg.MachineID); // Machine ID				
						//pJenwayCom.outlet[No].data.Weight					:= UINT_TO_INT (g_OutletProcess.JenwayExchange[0].Stack.Destination); //  to sealer or strapper -->test purpose
						pJenwayCom.outlet[No].data.HangerId := g_OutletProcess.JenwayExchange[0].Stack.ItemData[1].HangerId;
						pJenwayCom.outlet[No].data.GarmentId := g_OutletProcess.JenwayExchange[0].Stack.ItemData[1].GarmentId;

			END_IF	
		END_IF	

		// check
//		IF (g_OutletProcess.JenwayExchange[bufcnt].StackIndex - TrackID) > 0 THEN
		// Transfered
		IF g_Jenway.No[No].Done AND pJenwayCom.outlet[No].runtime.isTransfered THEN
			g_Jenway.No[No].Done := 0;
			g_Jenway.No[No].Go := 0;
			pJenwayCom.outlet[No].interface.isTransferingDone := TRUE;
		END_IF

		// Safe reset
		IF pJenwayCom.outlet[No].step = INTERCOM_IDLE THEN
			pJenwayCom.outlet[No].interface.isTransferingDone := FALSE;
		END_IF

		// Abort check
		IF pJenwayCom.outlet[No].runtime.isAborted THEN
			pJenwayCom.outlet[No].interface.isAbortAcknowledged := TRUE;
		END_IF
	END_FOR
END_IF

END_IF		
		//HMIJenwayColor := SEL(NOT g_Jenway.No[0].ShowBlocked,52,10);
END_PROGRAM