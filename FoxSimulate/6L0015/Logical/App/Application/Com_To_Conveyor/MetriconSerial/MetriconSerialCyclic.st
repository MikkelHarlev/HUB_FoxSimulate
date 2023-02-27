PROGRAM _CYCLIC

(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson	.

Desription:				This task does the serial communication with Metricon

#################################
Basic flow of communication:


Metric		Maximat
		<-	h0001	Hanger in read position
C0015	->			fold category 15 
G0023	->			garment type 23
B0003	->			belt category 3
H0001	->			all hanger data transferred.
		<-	h0002	Hanger data received......
		<-	h0003	Hanger feed into folder. (No hanger in read position)
.......
		<-	s0001	Make sure SXA is running.
S0002	->			No alarm after folder (SoutOk)

#################################


History:
10-06-29				V1.00.2		PO Nilsson		Removed test part that could disturbe...
10-05-10				V1.00.1		PO Nilsson		Bench tested against Metricon simulator...	
10-05-05				V1.00.0		PO Nilsson		First edition.	

---------------------------------------------------------------------------------------*)

IF NOT g_SystemInitialized THEN
	RETURN;
END_IF	



CurTimer := g_Timers._1_ms;		// Get current time 


// Test snurra 




IF (g_ExternalCom.ConnectionType = CONNECTION_TYPE_SERIAL_3) THEN

	// Get telegrams from serial port...
	DataLength := GetTelegramFromNode(g_ComBus, 01, ADR(InBuffer), 0, 0);

	CASE g_ExternalCom.HangerState OF

		// Send reguest for Hanger data 	
		EXTERN_HANGER_REQUEST_1:
		
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Start h0001');
			g_ExternalCom.ArticleId 	:= 0;
			g_ExternalCom.Destination 	:= 0;
			g_ExternalCom.StackChange 	:= 0;
			OutBuffer[0] := 104;	// h
			OutBuffer[1] := 48;		// 0
			OutBuffer[2] := 48;		// 0
			OutBuffer[3] := 48;		// 0
			OutBuffer[4] := 49;		// 1
			SendStatus	:= SendToNode(g_ComBus, 01, ADR(OutBuffer), 13);
			IF SendStatus = 0 THEN
				UpdateOutList 				:= TRUE;
				DiagCounter.Request 		:= DiagCounter.Request + 1; 
				TimeOutRequest				:= CurTimer;
				TimeOutRequestTimer			:= CurTimer;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Sent h0001');
				g_ExternalCom.HangerState 	:= EXTERN_HANGER_WAIT_2;
			ELSE	
				DiagCounter.TxError := DiagCounter.TxError + 1;	// Error...
			END_IF	

		EXTERN_HANGER_WAIT_2:
			// Time out if communication is not finished in time, set hanger failed to application...		
			IF (ElapsedMsTime(CurTimer, TimeOutRequestTimer) >= 1500) THEN
				g_ExternalCom.Recipe 		:= 0;	
				g_ExternalCom.ArticleId 	:= 0;
				g_ExternalCom.Destination	:= 0;
				g_ExternalCom.StackChange 	:= 0;					
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Time out');
				g_ExternalCom.HangerState 	:= EXTERN_HANGER_FAIL_9;	
			END_IF	
			
			// Make a new request if first failed..
			IF (ElapsedMsTime(CurTimer, TimeOutRequest) >= 500) THEN
				DiagCounter.Resend				:= DiagCounter.Resend + 1;
				IF DiagCounter.Resend < 2 THEN
					DiagCounter.TotalResend		:= DiagCounter.TotalResend + 1;
					g_ExternalCom.HangerState 	:= EXTERN_HANGER_REQUEST_1;
				ELSE
					DiagCounter.Resend			:= 0;						// Reset counter for next try by application...
					g_ExternalCom.HangerState 	:= EXTERN_HANGER_FAIL_9;
				END_IF
			END_IF	
				
			// Read telegrams in parts of Yxxxx...
			IF (DataLength > 0) AND (DataLength < 1000) THEN 		
				CASE InBuffer[0] OF

					// "C" Fold program 
					67:
						ThirdPart 	:= InBuffer[3] - 48;
						FourthPart 	:= InBuffer[4] - 48;
						ThirdPart 	:= ThirdPart * 10;
						g_ExternalCom.Recipe := ThirdPart + FourthPart;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Fold prog Rx');
						TimeOutRequest		:= CurTimer;
					
					// "G" garment type 
					71:
						FirstPart 	:= InBuffer[1] - 48;
						SecondPart 	:= InBuffer[2] - 48;
						ThirdPart 	:= InBuffer[3] - 48;
						FourthPart 	:= InBuffer[4] - 48;
						FirstPart 	:= FirstPart * 1000;
						SecondPart 	:= SecondPart * 100;
						ThirdPart	:= ThirdPart * 10;
						g_ExternalCom.ArticleId := FirstPart + SecondPart +  ThirdPart + FourthPart;
						TimeOutRequest		:= CurTimer;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Garment Rx');
					
					// "B" Belt category 
					66:
						ThirdPart 	:= InBuffer[3] - 48;
						FourthPart 	:= InBuffer[4] - 48;
						ThirdPart	:= ThirdPart * 10;	
						g_ExternalCom.Destination := ThirdPart + FourthPart;
						TimeOutRequest		:= CurTimer;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Belt Rx');
		
					// "P" global stack change 
					80:
						g_ExternalCom.StackChange := 1;	
						TimeOutRequest		:= CurTimer;				
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Stack change Rx');
					
					// "S0002" status exchange 
					83:
						IF (InBuffer[4] = 50) THEN 
							DiagCounter.S2Recieved 		:= DiagCounter.S2Recieved + 1;
							OutletFullTimeOut			:= CurTimer;
							g_ExternalCom.OutletFull	:= FALSE;
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Status in H-D Rx');
						END_IF						
						TimeOutRequest		:= CurTimer;

					// "H" transmission is completed 
					72:
						IF (InBuffer[4] = 49) THEN 
							// Send Recieved data to Metricon
							OutBuffer[0] := 104;	// h
							OutBuffer[1] := 48;		// 0
							OutBuffer[2] := 48;		// 0
							OutBuffer[3] := 48;		// 0
							OutBuffer[4] := 50;		// 2
							SendStatus	:= SendToNode(g_ComBus, 01, ADR(OutBuffer), 13);
							IF SendStatus = 0 THEN
								UpdateOutList 				:= TRUE;
								DiagCounter.Resend			:= 0;	
								DiagCounter.DataRecieved	:= DiagCounter.DataRecieved + 1;	
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'h0002 Tx');
								g_ExternalCom.HangerState 	:= EXTERN_HANGER_FOUND_6;
							ELSE	
								DiagCounter.TxError 		:= DiagCounter.TxError + 1;	// Error...
							END_IF	
						END_IF
						
					ELSE
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'Unknown char');
						ErrorCounter := ErrorCounter + 1;
				END_CASE	
				UpdateInList := TRUE;
			ELSIF DataLength >= 1000 THEN
				DiagCounter.RxError := DiagCounter.RxError + 1;	// Error
			END_IF

		EXTERN_HANGER_AWAY_3:
			// Send hanger away to Metricon
			OutBuffer[0] := 104;	// h
			OutBuffer[1] := 48;		// 0
			OutBuffer[2] := 48;		// 0
			OutBuffer[3] := 48;		// 0
			OutBuffer[4] := 51;		// 3
			SendStatus	:= SendToNode(g_ComBus, 01, ADR(OutBuffer), 13);
			IF SendStatus = 0 THEN
				UpdateOutList 				:= TRUE;
				DiagCounter.HangerAway 		:= DiagCounter.HangerAway + 1;
				g_ExternalCom.ArticleId 	:= 0;
				g_ExternalCom.Destination 	:= 0;
				g_ExternalCom.StackChange 	:= 0;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'h0003 Tx');
				g_ExternalCom.HangerState 	:= EXTERN_HANGER_IDLE_0;	
				;
			ELSE	
				DiagCounter.TxError := DiagCounter.TxError + 1;	// Error...
			END_IF	
		// Hanger flow is idle waiting for status data telegrams
		ELSE	
			IF (DataLength > 0) AND (DataLength < 1000) THEN 	
				// "S0002" status exchange 
				IF (InBuffer[0] = 83) AND (InBuffer[4] = 50) THEN 
					DiagCounter.S2Recieved 		:= DiagCounter.S2Recieved + 1;
					OutletFullTimeOut			:= CurTimer;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 'S0002 Rx in Idle');
					g_ExternalCom.OutletFull	:= FALSE;
				END_IF					
				UpdateInList := TRUE;
			ELSIF DataLength >= 1000 THEN
				DiagCounter.RxError := DiagCounter.RxError + 1;	// Error
			END_IF	
	END_CASE	




	//#########################################
	// Set outlet full if no S0002 in time.
	//#########################################
	
	IF (ElapsedMsTime(CurTimer, OutletFullTimeOut) >= 1100) THEN
		g_ExternalCom.OutletFull	:= TRUE;
	END_IF




	//#########################################
	// Send s0001 
	//#########################################
	
	IF g_ExternalCom.InletActive = TRUE THEN
		IF (ElapsedMsTime(CurTimer, InletActiveTimeOut) >= 2000) THEN
			// Send s0001 to Metricon
			OutBuffer[0] := 115;	// s
			OutBuffer[1] := 48;		// 0
			OutBuffer[2] := 48;		// 0
			OutBuffer[3] := 48;		// 0
			OutBuffer[4] := 49;		// 1
			SendStatus	:= SendToNode(g_ComBus, 01, ADR(OutBuffer), 13);
			IF SendStatus = 0 THEN
				;
			ELSE	
				DiagCounter.TxError := DiagCounter.TxError + 1;	// Error...
			END_IF	
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 's0001 Tx');
			UpdateOutList 		:= TRUE;
			DiagCounter.s1Sent 	:= DiagCounter.s1Sent + 1;
			InletActiveTimeOut 	:= CurTimer;
		END_IF
	END_IF


	//#########################################
	// Send s0002 
	//#########################################
	
	IF g_ExternalCom.InletFull = TRUE THEN
		IF (ElapsedMsTime(CurTimer, InletFullTimeOut) >= 500) THEN
			// Send s0001 to Metricon
			OutBuffer[0] := 115;	// s
			OutBuffer[1] := 48;		// 0
			OutBuffer[2] := 48;		// 0
			OutBuffer[3] := 48;		// 0
			OutBuffer[4] := 50;		// 2
			SendStatus	:= SendToNode(g_ComBus, 01, ADR(OutBuffer), 13);
			IF SendStatus = 0 THEN
				;
			ELSE	
				DiagCounter.TxError := DiagCounter.TxError + 1;	// Error...
			END_IF	
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, LogFlag, CurTimer, 's0002 Tx');
			UpdateOutList 		:= TRUE;
			DiagCounter.s2Sent 	:= DiagCounter.s2Sent + 1;
			InletFullTimeOut 	:= CurTimer;
		END_IF
	END_IF



	//###################################
	// HMI Diagnostics part 
	//###################################


	//IF g_HMIHandler.CurrentPage = 543 THEN
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMetSerial THEN

		// Make string from USINT arrays.
		memcpy(ADR(InString), ADR(InBuffer), 48);
		memcpy(ADR(OutString), ADR(OutBuffer), 48);

		// Stop update list from HMI to be able to look at it...
		IF NOT PauseList THEN
			// Make a list of telegrams recived
			IF UpdateInList THEN 
				UpdateInList := FALSE;	
				FOR ListIndex := 10 TO 1 BY -1 DO
					InList[ListIndex] := InList[ListIndex - 1];
				END_FOR
				InList[0] := InString;
			END_IF
	
			// Make a list of telegrams transmitted
			IF UpdateOutList THEN 
				UpdateOutList := FALSE;	
				FOR ListIndex := 10 TO 1 BY -1 DO
					OutList[ListIndex] := OutList[ListIndex - 1];
				END_FOR
				OutList[0] := OutString;
			END_IF
		END_IF
	END_IF
END_IF

END_PROGRAM
