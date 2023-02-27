(********************************************************************
 * COPYRIGHT -- IT
 ********************************************************************
 * PROGRAM: statalarms
 * File: statalarmsCyclic.st
 * Author: mariw
 * Created: May 21, 2011
 ********************************************************************
 * Implementation OF PROGRAM statalarms
 ********************************************************************)

PROGRAM _CYCLIC
	IF NOT Enable THEN
		RETURN;//SFX
	END_IF
	
	//--------- Get Date ---------------- // 
	// For statistic - Date and Time
	g_DTGetTime_0(enable := TRUE);
	 
	//-------------- Any Alarm Active ---------------------------------------------------------------//
	ActiveAlarm := FALSE;
	FOR n:=0 TO 19 DO
		IF g_HangerInletProcess.Common.AlarmList.Alarm[n] OR g_HangerOpenerProcess.Common.AlarmList.Alarm[n] OR g_TopConveyorProcess.Common.AlarmList.Alarm[n] 
			OR g_LateralProcess.Common.AlarmList.Alarm[n] OR g_CrossFoldAProcess.Common.AlarmList.Alarm[n] OR g_CrossFoldBProcess.Common.AlarmList.Alarm[n]
			OR g_ManualInletProcess.Common.AlarmList.Alarm[n] 
			OR g_StackerProcess[1].Common.AlarmList.Alarm[n] OR g_StackerProcess[2].Common.AlarmList.Alarm[n] OR g_StackerProcess[3].Common.AlarmList.Alarm[n] 
			OR g_StackerProcess[4].Common.AlarmList.Alarm[n] OR g_StackerProcess[5].Common.AlarmList.Alarm[n]			
			OR g_OutletProcess.Common.AlarmList.Alarm[n] OR g_DeliveryProcess.Common.AlarmList.Alarm[n]   
			OR g_MiniJenwayProcess.Common.AlarmList.Alarm[n] 
			OR g_MainAlarms.Alarm[n]
			THEN
			n:= 20;
			ActiveAlarm := TRUE;
		END_IF;
	END_FOR;

 
	//-------------- Pass Alarms ---------------------------------------------------------------//
	n:= 0;
	
	IF g_HCfg.FeedManual THEN
		//inlet 
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[2];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[4];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[5];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[6];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[7];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[8];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[9];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[12];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_ManualInletProcess.Common.AlarmList.Alarm[13];		
		//-> 7 9stk

	ELSE

		//inlet 
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[2]; 
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[3];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[4];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[5];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[6];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[7];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerInletProcess.Common.AlarmList.Alarm[8];

		//-> 5 6stk

		//opener
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[2];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[3];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[4];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[5];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[6];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[7];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[8];
		n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[9];

		// -> 6 8stk --> 14stk
	END_IF

	//top convoyer
	//n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_TopConveyorProcess.Common.AlarmList.Alarm[1];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_TopConveyorProcess.Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_TopConveyorProcess.Common.AlarmList.Alarm[3]; 
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_TopConveyorProcess.Common.AlarmList.Alarm[4]; 
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_TopConveyorProcess.Common.AlarmList.Alarm[5];
	
	//lateral
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_LateralProcess.Common.AlarmList.Alarm[2]; 
	
	//Cross A
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_CrossFoldAProcess.Common.AlarmList.Alarm[2];
	 
	//Cross B
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_CrossFoldBProcess.Common.AlarmList.Alarm[2];
	
	//STG 1-5
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[1].Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[1].Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[1].Common.AlarmList.Alarm[5];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[1].Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[1].Common.AlarmList.Alarm[7];
		
	//IF (g_HCfg.NumberOfStackers > 2) THEN
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[2].Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[2].Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[2].Common.AlarmList.Alarm[5];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[2].Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[2].Common.AlarmList.Alarm[7];
	//END_IF
	
	//IF (g_HCfg.NumberOfStackers > 4) THEN
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[3].Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[3].Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[3].Common.AlarmList.Alarm[5];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[3].Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[3].Common.AlarmList.Alarm[7];
	//END_IF 
	
	//IF (g_HCfg.NumberOfStackers > 6) THEN
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[4].Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[4].Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[4].Common.AlarmList.Alarm[5];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[4].Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[4].Common.AlarmList.Alarm[7];
	//END_IF
	
	//IF (g_HCfg.NumberOfStackers > 8) THEN
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[5].Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[5].Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[5].Common.AlarmList.Alarm[5];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[5].Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_StackerProcess[5].Common.AlarmList.Alarm[7];			
	//END_IF
	
	//Outlet
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[2];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[3];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[6];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[10];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[11];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[12];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[13];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[14];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[15];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[16];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[17];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[18];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_OutletProcess.Common.AlarmList.Alarm[19];
	 

	//Main
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_MainAlarms.Alarm[0]; 
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_MainAlarms.Alarm[1]; 
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_MainAlarms.Alarm[16];
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_MainAlarms.Alarm[17];
	 
	//--> 50stk --> 64 of array[70]
	
	// Extras
	
	// Garment under deloader
	n:=n+1;StatAlarms.CurrentAlrmList[n].Alarm := g_HangerOpenerProcess.Common.AlarmList.Alarm[11];

	MHATest;

	//-------------- Count Timers---------------------------------------------------------------//

	FOR n:=1 TO MAX_ALM_LIST DO //used to be 50, now 70
		
		StatAlarms.CurrentAlrmList[n].Index:= n;

		// reset FirtAlarms
		IF NOT ActiveAlarm THEN
			StatAlarms.CurrentAlrmList[n].FirstAlarm:= FALSE; 			
		ELSE
			IF StatAlarms.CurrentAlrmList[n].Alarm THEN
				IF NOT StatAlarms.CurrentAlrmList[n].AlarmSaved AND NOT ActiveAlarmSaved THEN
					StatAlarms.CurrentAlrmList[n].Count := StatAlarms.CurrentAlrmList[n].Count+1;
					StatAlarms.CurrentAlrmList[n].FirstAlarm := TRUE; 
				END_IF;
				IF StatAlarms.CurrentAlrmList[n].FirstAlarm THEN
					StatAlarms.CurrentAlrmList[n].Timer_10ms := StatAlarms.CurrentAlrmList[n].Timer_10ms+ 1;			
					// make sec of 10ms 
					IF StatAlarms.CurrentAlrmList[n].Timer_10ms >= 100 THEN
						StatAlarms.CurrentAlrmList[n].Timer_10ms:= 0; 
						StatAlarms.CurrentAlrmList[n].Time_Sec := StatAlarms.CurrentAlrmList[n].Time_Sec+1;	
						StatAlarms.CurrentAlrmList[n].Time := (StatAlarms.CurrentAlrmList[n].Time_Sec /60 );
						IF StatAlarms.CurrentAlrmList[n].Count>0 THEN
							StatAlarms.CurrentAlrmList[n].TimePerTrig := (StatAlarms.CurrentAlrmList[n].Time/StatAlarms.CurrentAlrmList[n].Count);
						END_IF;
								
					END_IF;
				ELSE
					//	RETURN ;
				END_IF;
			END_IF;
		END_IF;
		StatAlarms.CurrentAlrmList[n].AlarmSaved := StatAlarms.CurrentAlrmList[n].Alarm;
			
	END_FOR;


	(* Pieces Total *)
	(* -------------- *)
	g_HMIStatistic.Total.NumberOfPiecesTotalLast 	:= g_HMIStatistic.Total.NumberOfPiecesTotal	; 
	g_HMIStatistic.Total.NumberOfPiecesTotal		:= 0;
	FOR i := 1 TO g_HCfg.NumberOfStackers DO
		g_HMIStatistic.Total.NumberOfPiecesTotal	:= g_HMIStatistic.Total.NumberOfPiecesTotal + g_Statistic[0].Pieces[i];
	END_FOR
	g_HMIStatistic.Total.NumberOfPiecesTotalCur := g_HMIStatistic.Total.NumberOfPiecesTotal	; 

	IF g_HMIStatistic.Total.NumberOfPiecesTotalCur> g_HMIStatistic.Total.NumberOfPiecesTotalLast THEN
		//StatAlarms.NumberOfPiecesTotal := StatAlarms.NumberOfPiecesTotal +(g_HMIStatistic.Total.NumberOfPiecesTotalCur -g_HMIStatistic.Total.NumberOfPiecesTotalLast);  // Removed because the different numbers confused the SSCs
		StatAlarms.NumberOfPiecesTotal := g_HMIStatistic.Total.NumberOfPiecesTotal;
	END_IF;

	//////////////////
	IF g_HCfg.FeedManual THEN
		;//SFXg_HMIStatistic.Total.Utilisation := UDINT_TO_UINT(StatAlarms.CurrentAlrmList[55].Time);
	ELSE	
		;//SFXg_HMIStatistic.Total.Utilisation := UDINT_TO_UINT(StatAlarms.CurrentAlrmList[61].Time);
	END_IF
	//////////////////

	//-------------- Visu ---------------------------------------------------------------//
	FOR n:=1 TO MAX_ALM_LIST DO
		g_HMIStatistic.Alarms.CurrentAlrmList[n]:= StatAlarms.CurrentAlrmList[n];
	END_FOR
	// Switch by Right -Left Row 
	IF  EDGEPOS( INT_TO_BOOL(vis_Cat_Layer.Layer[0].BTN =1)) AND g_HMIStatistic.Alarms.CurLayer >0 THEN  // left
		g_HMIStatistic.Alarms.CurLayer := g_HMIStatistic.Alarms.CurLayer-1 ;
	ELSIF EDGEPOS( INT_TO_BOOL(vis_Cat_Layer.Layer[0].BTN =2)) AND g_HMIStatistic.Alarms.CurLayer < 7 THEN	// right 3	
		g_HMIStatistic.Alarms.CurLayer:= g_HMIStatistic.Alarms.CurLayer+1;
	END_IF
	vis_Cat_Layer.Layer[0].BTN :=0;
	IF g_HMIStatistic.Alarms.CurLayer =0 THEN
		g_HMIStatistic.Alarms.CurLayer:=1;
	END_IF;
	
	// Pass Data to curent visu 
	FOR n:=1 TO 10 DO
		j := (g_HMIStatistic.Alarms.CurLayer*10)-10+n;
		g_HMIStatistic.Alarms.CurrentAlrmList[n]:= StatAlarms.CurrentAlrmList[j];
	END_FOR

	//datapoint: Local.g_HMIStatistic.Alarms.CurrentAlrmList[1].Index
	//textgroup: StatAlarms_Hanger
	
	
	
	(* Delete All Statistic *)
	IF g_HMIStatistic.Total.Delete = 1 THEN
		g_HMIStatistic.Total.Delete := 0;
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, 0, 'HMI reset statistics');
		memset(ADR(StatAlarms), 0, SIZEOF(StatAlarms));
		g_ExternalCom.ExternalFeed.NoExternalFeedTime:= 0; 
		g_Statistic[1].NoHangersInletTime := g_Statistic[0].NoHangersInletTime / 60000;
		
		g_Statistic[0].ProductionStop := 0;
		g_Statistic[0].EmptyHangerWaitTime := 0;
		g_Statistic[0].NoHangersInletTime := 0;
	END_IF
	IF  StatAlarms.Delete THEN
		StatAlarms.Delete := 0; 
		memset(ADR(StatAlarms), 0, SIZEOF(StatAlarms));
		// Reset Record start Time 
		StatAlarms.Date := g_DTGetTime_0.DT1;
	END_IF;
	IF DelEmercStop THEN
		DelEmercStop := FALSE;	
		IF g_HCfg.FeedManual THEN
			;//SFXStatAlarms.CurrentAlrmList[55].Time_Sec		:= 0;
			//			IF StatAlarms.CurrentAlrmList[55].Alarm THEN
			// 				StatAlarms.CurrentAlrmList[55].FirstAlarm	:= TRUE;
			//			END_IF
		ELSE	
			;//SFXStatAlarms.CurrentAlrmList[61].Time_Sec		:= 0;
			//			IF StatAlarms.CurrentAlrmList[61].Alarm THEN
			//				StatAlarms.CurrentAlrmList[61].FirstAlarm	:= TRUE;
			//			END_IF
		END_IF
	END_IF

	ActiveAlarmSaved := ActiveAlarm;
	
	// --------------------------------------------------------------------------------
	// Flow counters
	// --------------------------------------------------------------------------------

	IF NOT RInit THEN

		// No garment at inlet
		IF g_NoHangersAtInlet THEN
			g_Statistic[0].NoHangersInletTime := g_Statistic[0].NoHangersInletTime + (g_MilliSeconds - OldMilliseconds);
		END_IF
		g_Statistic[1].NoHangersInletTime := g_Statistic[0].NoHangersInletTime / 60000;
		
		// Feeding stopped by operator
		IF g_EnableFeedingWaiting AND NOT g_NoHangersAtInlet THEN
			g_Statistic[0].ProductionStop := g_Statistic[0].ProductionStop + (g_MilliSeconds - OldMilliseconds);
		END_IF
		g_Statistic[1].ProductionStop := g_Statistic[0].ProductionStop / 60000;
		
		// Metricon blocked
		IF g_EmptyHangerBlock AND NOT g_EnableFeedingWaiting AND NOT g_NoHangersAtInlet THEN
			g_Statistic[0].EmptyHangerWaitTime := g_Statistic[0].EmptyHangerWaitTime + (g_MilliSeconds - OldMilliseconds);
		END_IF
		g_Statistic[1].EmptyHangerWaitTime := g_Statistic[0].EmptyHangerWaitTime / 60000;
		
		// Total
		g_Statistic[1].Stopping := g_Statistic[1].NoHangersInletTime + g_Statistic[1].ProductionStop + g_Statistic[1].EmptyHangerWaitTime;
		
	END_IF

	OldMilliseconds := g_MilliSeconds;
	
	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'statalarm Cyclic init');
	END_IF

	RInit := 0;

END_PROGRAM



