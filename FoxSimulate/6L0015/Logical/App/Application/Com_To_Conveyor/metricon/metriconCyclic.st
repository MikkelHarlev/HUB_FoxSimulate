PROGRAM _CYCLIC
(* cyclic program *)


(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt.

Desription:				This task manage the communication with Metricon .

History:
10-02-08				V1.02.1	PO Nilsson			Fixed the connection TO g_MCfg.CommunicationMode.0..	
10-01-24				V1.02.0	Sten / PO			PVI communication added, cleaned up some variables...			
													Added configuration FOR communication type
09-11-19				V1.01.5	PO Nilsson			Bug with I/O connection, I thing ComStat is NOT zero when no connection...
09-09-30				V1.01.4 SF					Bug that we dod NOT check on the comstate, could take old hanger data..
09-06-30				V1.01.3 SF					New FoldXML-lib AND reconnect IF ip address is changed.
09-06-29				V1.01.2 SF					Corrected IP address settings.
09-06-24				V1.01.1 SF					Use g_MCfg TO set some varibles.
09-06-23				V1.01   SF					Handle intern/extern status. Data values set correct.
09-04-23				V1.00   SF					First edition.

---------------------------------------------------------------------------------------*)

	IF NOT g_SystemInitialized THEN
		RETURN;
	END_IF	

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)

	BCD_FoldProg_1		:=	ISBCDProgram1;
	BCD_FoldProg_2		:=	ISBCDProgram2;
	BCD_FoldProg_4		:=	ISBCDProgram4;
	BCD_FoldProg_8		:=	ISBCDProgram8;
	BCD_FoldProg_10		:=	ISBCDProgram10;
	BCD_FoldProg_20		:=	ISBCDProgram20;
	BCD_FoldProg_40		:=	ISBCDProgram40;
	BCD_FoldProg_80		:=	ISBCDProgram80;
	BCD_Stackchange		:=	ISBCDStackChange;
	BCD_DataComplete	:=	ISBCDDataComplete;
 
	(*######################*)
	(* Connect timer values *)
	(*######################*)

	BCDRequestTime			:= g_MCfg.Metricon.BCD_RequestTime;
	BCDReadDelayTime		:= g_MCfg.Metricon.BCD_ReadDelay;
	BCDDelayHangerAwayTime	:= g_MCfg.Metricon.BCD_HangerAwayDelay;


	//g_MCfg.Metricon.UseExternalStatus := METRIC_STATUS_EXTERN_1;// SFX hard coded, but should be configurable. 
	//IF (g_MCfg.Metricon.IpAddressByte3 > 0) AND (g_MCfg.Metricon.IpAddressByte4 > 0) THEN
	//IF (nisse) THEN
	////	IF (g_MCfg.Metricon.IpAddressByte3 <> lastip3) OR (g_MCfg.Metricon.IpAddressByte4 <> lastip4) OR
	//		(g_ExternalCom.Ethernet.ServerInfo.IPAddress = '') THEN
	// 		g_ExternalCom.Ethernet.ServerInfo.IPAddress := JENSEN_IP_PREFIX;
	//		itoa(g_MCfg.Metricon.IpAddressByte3,ADR(tmpstr));
	//		strcat(ADR(g_ExternalCom.Ethernet.ServerInfo.IPAddress),ADR(tmpstr));
	//		strcat(ADR(g_ExternalCom.Ethernet.ServerInfo.IPAddress),ADR('.'));
	//		itoa(g_MCfg.Metricon.IpAddressByte4,ADR(tmpstr));
	//		strcat(ADR(g_ExternalCom.Ethernet.ServerInfo.IPAddress),ADR(tmpstr));
	//		lastip3 := g_MCfg.Metricon.IpAddressByte3;
	//		lastip4 := g_MCfg.Metricon.IpAddressByte4;
	////	END_IF	
	//ELSE
	//	g_ExternalCom.Ethernet.ServerInfo.IPAddress := '';
	//END_IF
	//IF g_MCfg.Metricon.ComRefreshTime > 0 THEN
	//	g_ExternalCom.Ethernet.StatusRefreshTime := g_MCfg.Metricon.ComRefreshTime;
	//ELSE
	//	g_ExternalCom.Ethernet.StatusRefreshTime := 300;
	//END_IF	

	g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.GarmentData.ArticleId;
	// Setting the type of communication..

	IF g_MCfg.Metricon.ComMode = 0 THEN 		// No com
		;
	ELSIF g_MCfg.Metricon.ComMode = 1 THEN 		// Ethernet XML	
		g_ExternalCom.ConnectionType := CONNECTION_TYPE_ETHERNET_1;
	ELSIF g_MCfg.Metricon.ComMode = 2 THEN 		// Ethernet PVI
		g_ExternalCom.ConnectionType := CONNECTION_TYPE_PVI_8;
	ELSIF g_MCfg.Metricon.ComMode = 3 THEN 		// Serial
		g_ExternalCom.ConnectionType := CONNECTION_TYPE_SERIAL_3;
	ELSIF g_MCfg.Metricon.ComMode = 4 THEN 		// BCD relays		
		g_ExternalCom.ConnectionType := CONNECTION_TYPE_BCD_4;
	END_IF


	(* Using BCD relays *)
	IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
		IF g_HangerInletProcess.Common.State >= 98 THEN
			BCD_Conntection := 0;
		END_IF

		IF g_ExternalCom.ConnectionType <> CONNECTION_TYPE_BCD_4 THEN
			; (* No connection over BCD *)
		ELSE
			CASE BCD_Conntection OF
				0:	
					IF g_ExternalCom.HangerState = EXTERN_HANGER_REQUEST_1 THEN
						BCDRequestTimer				:= g_HangerInletProcess.Common.CurTimer;
						g_ExternalCom.HangerState 	:= EXTERN_HANGER_WAIT_2;
						BCD_HangerAway				:= FALSE;
						BCD_DataRequest				:= TRUE;
						BCD_RequestTries			:= 0;
						BCD_Conntection				:= 1;
					ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2 THEN // try to read again
						IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, BCDRequestTimer) >= (BCDRequestTime/2)) THEN
							BCD_RequestTries		:= BCD_RequestTries +1;
							BCD_DataRequest			:= TRUE;
							BCDRequestTimer			:= g_HangerInletProcess.Common.CurTimer;
							BCD_Conntection			:= 1;
						END_IF
					END_IF
			
				1:
					IF g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2 THEN
						IF (BCD_DataRequest AND BCD_DataComplete) THEN
							BCDReadDelayTimer		:= g_HangerInletProcess.Common.CurTimer;
							BCD_RequestTries		:= 0;
							BCD_Conntection			:= 2;				
						ELSIF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, BCDRequestTimer) >= BCDRequestTime) THEN
							IF (BCD_DataRequest AND (NOT BCD_DataComplete)) THEN
								IF BCD_RequestTries < g_MCfg.Metricon.BCD_RequestTries THEN
									BCDRequestTimer				:= g_HangerInletProcess.Common.CurTimer;
									BCD_DataRequest 			:= FALSE;	 				
									BCD_Conntection				:= 0;
								ELSE
									g_ExternalCom.HangerState	:= EXTERN_HANGER_FAIL_9;
									BCD_DataRequest 			:= FALSE;
									BCD_NewStack				:= TRUE;
									BCD_Conntection				:= 3;
								END_IF				
							END_IF
						END_IF
					END_IF
				
				2:
					IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, BCDReadDelayTimer) >= BCDReadDelayTime) THEN
						IF g_HCfg.KGHanger THEN //Needs to be tested...
							CalcProgramHigh				:= BIT_USINT(BCD_FoldProg_1, BCD_FoldProg_2, BCD_FoldProg_4, BCD_FoldProg_8,
								BCD_FoldProg_10, BCD_FoldProg_20, BCD_FoldProg_40, 0);
							IF ((CalcProgramHigh > 99) OR (CalcProgramHigh < 1)) THEN
								g_ExternalCom.Recipe	:= 1;
							ELSE				
								g_ExternalCom.Recipe 	:= CalcProgramHigh;
							END_IF
							g_ExternalCom.StackChange	:= BCD_Stackchange;
							IF BCD_NewStack THEN
								g_ExternalCom.StackChange	:= 1;
								BCD_NewStack				:= FALSE;
							END_IF
							BCD_DataRequest 			:= FALSE;
							g_ExternalCom.HangerState 	:= EXTERN_HANGER_FOUND_6;
							BCD_Conntection				:= 3;				
						ELSE
							CalcProgramHigh 			:= BIT_USINT(BCD_FoldProg_10, BCD_FoldProg_20, BCD_FoldProg_40, BCD_FoldProg_80, 0, 0, 0, 0);
							CalcProgramHigh 			:= (CalcProgramHigh * 10);
	
							CalcProgramLow 				:= BIT_USINT(BCD_FoldProg_1, BCD_FoldProg_2, BCD_FoldProg_4, BCD_FoldProg_8, 0, 0, 0, 0);
					
					
							IF g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1 THEN
								g_ExternalCom.Recipe 		:= CalcProgramHigh + CalcProgramLow;
							ELSIF g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2 THEN	
								g_ExternalCom.Recipe 		:= CalcProgramHigh + CalcProgramLow;
								g_ExternalCom.StackChange	:= BCD_Stackchange;
							ELSIF g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4 THEN
								g_ExternalCom.Recipe 		:= g_AutoProgram.OperatorAutoProgram;
								g_ExternalCom.StackChange	:= BCD_Stackchange;
							END_IF
							IF BCD_NewStack THEN
								g_ExternalCom.StackChange	:= 1;
								BCD_NewStack				:= FALSE;
							END_IF
					
							BCD_DataRequest 			:= FALSE;				
							g_ExternalCom.HangerState 	:= EXTERN_HANGER_FOUND_6;
							BCD_Conntection				:= 3; 
						END_IF
					END_IF
	
				3:
					IF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_3 THEN
						g_ExternalCom.HangerState	:= EXTERN_HANGER_AWAY_WAIT_4;
						BCDDelayHangerAwayTimer		:= g_HangerInletProcess.Common.CurTimer;
						BCD_Conntection				:= 4;
					END_IF
		
				4:		
					IF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_WAIT_4 THEN	
						IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, BCDDelayHangerAwayTimer) >= BCDDelayHangerAwayTime) THEN
							g_ExternalCom.HangerState	:= EXTERN_HANGER_AWAY_WAIT_4;
							BCDDelayHangerAwayTimer		:= g_HangerInletProcess.Common.CurTimer;
							BCD_HangerAway				:= TRUE;
							BCD_Conntection				:= 5;
						END_IF
					END_IF
			
				5:
					IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, BCDDelayHangerAwayTimer) >= 800) THEN
						BCD_HangerAway				:= FALSE;
						g_ExternalCom.HangerState	:= EXTERN_HANGER_IDLE_0;
						BCD_Conntection				:= 0;
					END_IF
			
			END_CASE				
		END_IF
	
	
		(* Using Serial communication *)
	
	ELSIF g_ExternalCom.ConnectionType = CONNECTION_TYPE_ETHERNET_1 THEN
	
		(* Using XMLRPC over Ethernet *)
		IF g_ExternalCom.ConnectionType <> CONNECTION_TYPE_ETHERNET_1 THEN
			//;(* No connection over Ethernet *)
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_REQUEST_1 THEN
			g_ExternalCom.HangerState 							:= EXTERN_HANGER_WAIT_2;
			pThis.Runtime.connection[0].data.ClientInfo.RequestHangerData := 1;
			//g_ExternalCom.Ethernet.ClientInfo.RequestHangerData := 1;
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2 THEN
			IF (pThis.Runtime.connection[0].data.ComState = FOLD_COMSTATE_DATA_OK) AND (pThis.Runtime.connection[0].data.ClientInfo.RequestHangerData = 0) THEN
				IF pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_OK THEN
					pThis.Runtime.connection[1].data := pThis.Runtime.connection[0].data;
					DataMakeIdOfStr(ADR(g_ExternalCom.HangerId) ,ADR(pThis.Runtime.connection[0].data.GarmentData.HangerId));
					g_ExternalCom.MetricHangerReadStatus 	:= pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus;
					IF pThis.Runtime.connection[0].data.GarmentData.SeqId > 0 THEN 
						g_ExternalCom.SeqId 					:= pThis.Runtime.connection[0].data.GarmentData.SeqId;
					ELSE
						g_ExternalCom.SeqId 					:= pThis.Runtime.connection[0].data.GarmentData.SeqId;
					END_IF
					DataMakeIdOfStr(ADR(g_ExternalCom.HangerId) ,ADR(pThis.Runtime.connection[0].data.GarmentData.GarmentId));
					// garment/hanger ID to local structure
					g_ExternalCom.Ethernet.GarmentData	:= pThis.Runtime.connection[0].data.GarmentData;
					g_ExternalCom.StackChange 				:= pThis.Runtime.connection[0].data.GarmentData.StackChange;
					IF pThis.Runtime.connection[0].data.GarmentData.Destination > 0 THEN
						g_ExternalCom.Destination 				:= pThis.Runtime.connection[0].data.GarmentData.Destination;
					ELSE
						g_ExternalCom.Destination 				:= 0;
					END_IF
					IF pThis.Runtime.connection[0].data.GarmentData.CustomerId > 0 THEN
						g_ExternalCom.CustomerId				:= pThis.Runtime.connection[0].data.GarmentData.CustomerId;
					ELSE	
						g_ExternalCom.CustomerId				:= 0;
					END_IF
					IF pThis.Runtime.connection[0].data.GarmentData.ArticleId > 0 THEN
						g_ExternalCom.ArticleId 				:= pThis.Runtime.connection[0].data.GarmentData.ArticleId;
					ELSE	
						g_ExternalCom.ArticleId 				:= 0;
					END_IF	
					IF pThis.Runtime.connection[0].data.GarmentData.Program > 0 THEN 
						g_ExternalCom.Recipe					:= pThis.Runtime.connection[0].data.GarmentData.Program;
					ELSE	
						g_ExternalCom.Recipe					:= 0;
					END_IF
					g_ExternalCom.HangerState 				:= EXTERN_HANGER_FOUND_6;
				ELSIF 	(pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_READ) OR
					(pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_HANGER) OR
					(pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_DATA) THEN
					g_ExternalCom.MetricHangerReadStatus 	:= pThis.Runtime.connection[0].data.GarmentData.MetricHangerReadStatus;
					g_ExternalCom.HangerState 				:= EXTERN_HANGER_FAIL_9;
				END_IF
			ELSIF pThis.Runtime.connection[0].data.ComState = FOLD_COMSTATE_NO_RESPONSE THEN
				g_ExternalCom.HangerState 					:= EXTERN_HANGER_FAIL_9;
			END_IF
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_3 THEN
			pThis.Runtime.connection[0].data.ClientInfo.AwayHangerUpdate 	:= 1;
			g_ExternalCom.HangerState 							:= EXTERN_HANGER_AWAY_WAIT_4;
			TestCounter := TestCounter + 1;
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_WAIT_4 THEN
			IF (pThis.Runtime.connection[0].data.ComState = FOLD_COMSTATE_DATA_OK) AND(pThis.Runtime.connection[0].data.ClientInfo.AwayHangerUpdate = 0) THEN
				g_ExternalCom.HangerState := EXTERN_HANGER_IDLE_0;
			ELSIF pThis.Runtime.connection[0].data.ComState = FOLD_COMSTATE_NO_RESPONSE THEN
				(* Just leave it and continue *)
				g_ExternalCom.HangerState 						:= EXTERN_HANGER_FAIL_9;
			END_IF
		END_IF
		//	IF (g_ExternalCom.Ethernet.ServerInfo.IPAddress <> '') THEN
		//		RunFoldClient(ADR(g_ExternalCom.Ethernet));
		//	END_IF	
		(* Status signal exchange with Ethernet *)
		IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_ETHERNET_1 THEN
			IF g_MCfg.Metricon.UseExternalStatus = METRIC_STATUS_INTERN_0 THEN
				;// Do nothing, this is set by internal IO outside of this task;
			ELSIF pThis.Runtime.connection[0].data.ComState > 0 THEN
				g_ExternalCom.OutletHalfFull 					:= pThis.Runtime.connection[0].data.ServerInfo.OutletHalfFull;
				g_ExternalCom.OutletFull 						:= pThis.Runtime.connection[0].data.ServerInfo.OutletFull;
				g_ExternalCom.HangersWaiting 					:= pThis.Runtime.connection[0].data.ServerInfo.HangersWaiting;
			ELSE // Set safe values.
				g_ExternalCom.OutletHalfFull 					:= 1;
				g_ExternalCom.OutletFull 						:= 1;
				g_ExternalCom.HangersWaiting 					:= 0;
			END_IF
			pThis.Runtime.connection[0].data.ClientInfo.InletActive		:= g_ExternalCom.InletActive;
			pThis.Runtime.connection[0].data.ClientInfo.InletFull			:= g_ExternalCom.InletFull;
			pThis.Runtime.connection[0].data.ClientInfo.InternalAlarm	 	:= g_ExternalCom.InternalAlarm;
		END_IF
		
	ELSIF g_ExternalCom.ConnectionType = CONNECTION_TYPE_PVI_8 THEN
		(* Using PVI over Ethernet *)
		IF g_ExternalCom.ConnectionType <> CONNECTION_TYPE_PVI_8 THEN
			;(* No connection via PVI, Do nothing here *)
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_REQUEST_1 THEN
			g_ExternalCom.HangerState 							:= EXTERN_HANGER_WAIT_2;
			g_ExternalPVICom.RequestHangerData := 1;
			g_ExternalPVICom.AwayHangerUpdate 	:= 0;
			g_ExternalPVICom.RequestTimeOutTimer := g_Timers._1_ms;
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2 THEN
			g_ExternalPVICom.CurTimer := g_Timers._1_ms;
			IF (g_ExternalPVICom.RequestHangerData = 2) THEN
				IF g_ExternalPVICom.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_OK THEN
					DataMakeIdOfStr(ADR(g_ExternalCom.HangerId),ADR(g_ExternalPVICom.GarmentData.HangerId));
					g_ExternalCom.MetricHangerReadStatus 	:= g_ExternalPVICom.GarmentData.MetricHangerReadStatus;
					IF g_ExternalPVICom.GarmentData.SeqId > 0 THEN 
						g_ExternalCom.SeqId 					:= g_ExternalPVICom.GarmentData.SeqId;
					ELSE
						g_ExternalCom.SeqId 					:= g_ExternalPVICom.GarmentData.SeqId;
					END_IF
					DataMakeIdOfStr(ADR(g_ExternalCom.HangerId),ADR(g_ExternalPVICom.GarmentData.GarmentId));
					g_ExternalCom.StackChange 				:= g_ExternalPVICom.GarmentData.StackChange;
					IF g_ExternalPVICom.GarmentData.Destination > 0 THEN
						g_ExternalCom.Destination 				:= g_ExternalPVICom.GarmentData.Destination;
					ELSE
						g_ExternalCom.Destination 				:= 0;
					END_IF
					IF g_ExternalPVICom.GarmentData.CustomerId > 0 THEN
						g_ExternalCom.CustomerId				:= g_ExternalPVICom.GarmentData.CustomerId;
					ELSE	
						g_ExternalCom.CustomerId				:= 0;
					END_IF
					IF g_ExternalPVICom.GarmentData.ArticleId > 0 THEN
						g_ExternalCom.ArticleId 				:= g_ExternalPVICom.GarmentData.ArticleId;
					ELSE	
						g_ExternalCom.ArticleId 				:= 0;
					END_IF	
					IF g_ExternalPVICom.GarmentData.Program > 0 THEN 
						g_ExternalCom.Recipe					:= g_ExternalPVICom.GarmentData.Program;
					ELSE	
						g_ExternalCom.Recipe					:= 0;
					END_IF
					g_ExternalCom.HangerState 				:= EXTERN_HANGER_FOUND_6;
				ELSIF 	(g_ExternalPVICom.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_READ) OR
					(g_ExternalPVICom.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_HANGER) OR
					(g_ExternalPVICom.GarmentData.MetricHangerReadStatus = HANGER_READ_STATE_NO_DATA) THEN
					g_ExternalCom.MetricHangerReadStatus 	:= g_ExternalPVICom.GarmentData.MetricHangerReadStatus;
					g_ExternalCom.HangerState 				:= EXTERN_HANGER_FAIL_9;
				END_IF
				g_ExternalPVICom.RequestHangerData := 0; // Reset request
			ELSIF ElapsedMsTime(g_ExternalPVICom.CurTimer, g_ExternalPVICom.RequestTimeOutTimer) >= g_ExternalPVICom.RequestTimeOutTime THEN	
				g_ExternalCom.HangerState 					:= EXTERN_HANGER_FAIL_9;
				g_ExternalPVICom.RequestHangerData := 0; // Reset request
			END_IF
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_3 THEN
			g_ExternalPVICom.AwayHangerUpdate 	:= 1;
			g_ExternalCom.HangerState 							:= EXTERN_HANGER_AWAY_WAIT_4;
			g_ExternalPVICom.RequestTimeOutTimer := g_Timers._1_ms;
			TestCounter := TestCounter + 1;
		ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_AWAY_WAIT_4 THEN
			g_ExternalPVICom.CurTimer := g_Timers._1_ms;
			IF (g_ExternalPVICom.AwayHangerUpdate = 0) THEN
				g_ExternalCom.HangerState := EXTERN_HANGER_IDLE_0;
			ELSIF ElapsedMsTime(g_ExternalPVICom.CurTimer, g_ExternalPVICom.RequestTimeOutTimer) >= g_ExternalPVICom.RequestTimeOutTime THEN	
				(* Just leave it and continue *)
				g_ExternalCom.HangerState 						:= EXTERN_HANGER_FAIL_9;
			END_IF
		END_IF
	
		(* Status signal exchange over PVI *)
		IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_PVI_8 THEN
			// Keep alive signal from external unit sets this value to like 1000 regulary
			IF g_ExternalPVICom.ComState > 0 THEN
				g_ExternalPVICom.ComState := g_ExternalPVICom.ComState - 1;
			END_IF		
			IF g_MCfg.Metricon.UseExternalStatus = METRIC_STATUS_INTERN_0 THEN
				;// Do nothing, this is set by internal IO outside of this task;
			ELSIF g_ExternalPVICom.ComState > 0 THEN
				g_ExternalCom.OutletHalfFull 					:= g_ExternalPVICom.OutletHalfFull;
				g_ExternalCom.OutletFull 						:= g_ExternalPVICom.OutletFull;
				g_ExternalCom.HangersWaiting 					:= g_ExternalPVICom.HangersWaiting;
			ELSE // Set safe values.
				g_ExternalCom.OutletHalfFull 					:= 1;
				g_ExternalCom.OutletFull 						:= 1;
				g_ExternalCom.HangersWaiting 					:= 0;
			END_IF
			g_ExternalPVICom.InletActive		:= g_ExternalCom.InletActive;
			g_ExternalPVICom.InletFull			:= g_ExternalCom.InletFull;
			g_ExternalPVICom.InternalAlarm	 	:= g_ExternalCom.InternalAlarm;
		END_IF
	
		// No communication type found automatically
		IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_NONE_0 THEN
			IF g_MCfg.Metricon.UseExternalStatus = METRIC_STATUS_INTERN_0 THEN
				;// Do nothing, this is set by internal IO outside of this task;
			ELSE // Set safe values.
				g_ExternalCom.OutletHalfFull 					:= 1;
				g_ExternalCom.OutletFull 						:= 1;
				g_ExternalCom.HangersWaiting 					:= 0;
			END_IF
		END_IF

	END_IF
	// Dett är nog inte OK kolla vilka state.. Man har när man inte har koppling
	//IF g_ExternalCom.Ethernet.ComState > 0 THEN
	//	g_ExternalCom.ConnectionType 						:= CONNECTION_TYPE_ETHERNET_1;
	//END_IF
	//
	// SFX 100121 Select type of communication g_ExternalCom.ConnectionType
	// Should be CONNECTION_TYPE_NONE_0, CONNECTION_TYPE_ETHERNET_1, CONNECTION_TYPE_PVI_8 or serial or bcd or...
	// Set from machine config or can it be set automatically when a machine connects
	//g_ExternalCom.ConnectionType := g_MCfg.Metricon.UseExternalStatus; // This is wrong
	// Hard coded for now
	g_ExternalPVICom.ComState := 50;// Should be set by external machine
	IF g_ExternalPVICom.RequestHangerData = 1 THEN
		strcpy(ADR(g_ExternalPVICom.GarmentData.HangerId),ADR('77777'));
		g_ExternalPVICom.GarmentData.MetricHangerReadStatus := HANGER_READ_STATE_OK;
		g_ExternalPVICom.GarmentData.SeqId := 12345;
		strcpy(ADR(g_ExternalPVICom.GarmentData.GarmentId),ADR('123789'));
		g_ExternalPVICom.GarmentData.StackChange := 6;
		g_ExternalPVICom.GarmentData.Destination := 5;
		g_ExternalPVICom.GarmentData.CustomerId := 123;
		g_ExternalPVICom.GarmentData.ArticleId := 4;
		g_ExternalPVICom.GarmentData.Program := 3; 
		g_ExternalPVICom.RequestHangerData := 2;
	END_IF
		
	(*#################*)
	(* Connect Outputs *)
	(*#################*)
	QKBCDDataRequest	:= BCD_DataRequest;
	QKBCDHangerAway		:= BCD_HangerAway;


END_PROGRAM


