PROGRAM _CYCLIC
	IF g_Core.Services.Blackbox.Runtime.server.ServersRunning = 0 OR g_Core.Services.Blackbox.Runtime.server.Status <> 0 OR g_Core.System.Runtime.isInitDone = 0 THEN
		RETURN;
	END_IF
	
	// Draw test.
	
	IF dTest THEN
		Access_Status := VA_Saccess (1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
		IF Access_Status = 0 THEN
			
			VA_Line(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler,x1,y1,x2,y2,color);
			VA_Srelease(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
		END_IF
		dTest := FALSE;
	END_IF
	
	
	
	IF RInit THEN
		NumberOfPUs := UDINT_TO_USINT(GetData(ServerNo := 1, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));	
	
		FOR No := 0 TO NumberOfPUs - 1 DO // Generate the default no flow for each station / lane.
			IF g_Core.Services.Statistics.Interface.configuration.Flow1Type > 0 THEN
				Flow1Counter[No](adrMillicounter := ADR(g_Core.Services.Time.Runtime.MilliSeconds));
			END_IF
			IF g_Core.Services.Statistics.Interface.configuration.Flow2Type > 0 THEN
				Flow2Counter[No](adrMillicounter := ADR(g_Core.Services.Time.Runtime.MilliSeconds));
			END_IF
			IF g_Core.Services.Statistics.Interface.configuration.Flow3Type > 0 THEN
				Flow3Counter[No](adrMillicounter := ADR(g_Core.Services.Time.Runtime.MilliSeconds));
			END_IF	
		END_FOR
	END_IF
	
	// Forarbejde til tidslinje rapport.
	// Sæt en timer på at sætte RInit := TRUE ved n interval, f.eks 5 minutter samtidigt med at g_Core.System.Runtime.isRunning = TRUE; 
	
	
	(* Controls - User input *)
	RStatPage := FALSE;
	
	IF DEBUG THEN
		pDYNITEM ACCESS DYNADDR;
	END_IF
	
	EdgePosISControlPlc := EDGEPOS(g_Core.System.Runtime.isStatisticsRunning);
	EdgeNegISControlPlc := EDGENEG(g_Core.System.Runtime.isStatisticsRunning);
	
	// Forarbejde til tidslinje rapport.
	// Sæt en timer på at sætte RInit := TRUE ved n interval, f.eks 5 minutter samtidigt med at g_Core.System.Runtime.isRunning = TRUE; 
	// Test
	// for hver server!!!
	//
	// Implement a simple watchdog - the cheap software UPS solution:
	//
	IF g_Core.System.Runtime.isStatisticsRunning THEN
		IF ( 0 <> memcmp(ADR(watchdogProduction), ADR(g_PermLogData[0].Production), SIZEOF(g_PermLogData[0].Production)) ) THEN
			memcpy(ADR(watchdogProduction),ADR(g_PermLogData[0].Production),SIZEOF(g_PermLogData[0].Production));
			watchdogTimer := 0;
		ELSE
			// Compare all elements to 16 zero bytes, if any bit / byte of watchdogProduction if greater than zero we have production. 
			IF (memcmp(ADR(watchdogProduction),ADR('$00$00$00$00$00$00$00$00$00$00$00$00$00$00$00$00'), SIZEOF(watchdogProduction)) > 0) THEN
				watchdogTimer := watchdogTimer + 1;
			END_IF
		END_IF 
		IF (watchdogTimer >= 2400) THEN // 2 minutes EG Timer to mcfg.
			watchdogTimer := 0;
			// Hook into the timeline function to log the production.
			alarmSet := TRUE; 
		END_IF
	END_IF
	
	// Catch MachineAlarms.
	IF g_Core.System.Runtime.timelineIntervalInSec > 29 THEN
		IF EDGEPOS(g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii <> DescOld) THEN
			alarmSet := TRUE;
			DescOld := g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
			// Set alarm text
			IF ( strlen(ADR(g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii)) > 0 ) THEN
				g_PermLogData[0].Error[0] := '';
				itoa(((g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000) + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID) ,ADR(g_PermLogData[0].Error[0]));
				strcat(ADR(g_PermLogData[0].Error[0]), ADR(': '));
				TmpStr74 := g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
				strcat(ADR(g_PermLogData[0].Error[0]), ADR(TmpStr74)); // locksout a potentional buffer overrun
			// Remove Alarm text
			ELSE
				g_PermLogData[0].Error[0] := '';
				DescOld := '';
			END_IF
		END_IF
	END_IF
	
	IF (*(g_Core.System.Runtime.isRunning OR alarmSet) AND*) g_Core.System.Runtime.timelineIntervalInSec > 29 AND IncreseShifIndex[0].LoadID[0] = 0 THEN
		TON_10ms_0(IN := NOT TON_10ms_0.Q, PT := g_Core.System.Runtime.timelineIntervalInSec * 100 );
		IF TON_10ms_0.Q OR alarmSet THEN
			FOR ServerNo := 1 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
				FOR No := 0 TO UDINT_TO_USINT(GetData(ServerNo := ServerNo, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))) - 1 DO
					g_Core.Services.CAR.Interface.No[No].isCmdIncrementLoadID := TRUE;
				END_FOR
			END_FOR
		END_IF
		// Reset alarm change trigger.
		alarmSet := FALSE; 
	ELSE
		TON_10ms_0(IN :=FALSE);
	END_IF
	
	DT_TO_DTStructure(g_Core.Services.Time.Runtime.Date_Time, ADR(DTStructure_0));
	DT_TO_DTStructure(newDate, ADR(DTStructure_1));
	(*Check dates*)
	IF (DTStructure_0.day > DTStructure_1.day OR DTStructure_0.month > DTStructure_1.month  OR DTStructure_0.year > DTStructure_1.year) THEN
		(*Set new date*)
		newDate := g_Core.Services.Time.Runtime.Date_Time;
		Rename := TRUE;
	END_IF
	
	IF Rename THEN
		itoa(DTStructure_0.year,ADR(tmpStr));
		strcpy(ADR(CurrentfName),ADR(tmpStr));
		strcat(ADR(CurrentfName),ADR('-'));
		itoa(DTStructure_0.month,ADR(tmpStr));
		strcat(ADR(CurrentfName),ADR(tmpStr));
		strcat(ADR(CurrentfName),ADR('-'));
		itoa(DTStructure_0.day,ADR(tmpStr));
		strcat(ADR(CurrentfName),ADR(tmpStr));
		strcat(ADR(CurrentfName),ADR('_'));
		strcat(ADR(CurrentfName),ADR(fName));
		Rename := FALSE;
		FilenameTest := CurrentfName;
		g_Core.Services.Statistics.Interface.isDeleteOldFiles := TRUE;
	END_IF
	
	(*Update statistics when activating the stats page*)
	IF (TryReset) THEN
		TryReset := FALSE;
		LocPassword.String := ResetInput;
		ResetInput := '';
		EnCode_0(PassWordAdr:=ADR(LocPassword));
		IF (LocPassword.Code = g_Core.Services.System.Runtime.file.Password[0] OR LocPassword.Code = g_Core.Services.System.Runtime.file.Password[1] OR LocPassword.Code = g_Core.Services.System.Runtime.file.Password[2]) THEN
			FOR ServerNo := 1 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
				FOR No := 0 TO 9 DO
					IncreseShifIndex[ServerNo-1].LoadID[No] := TRUE;
					Shift 		:= g_PermLogData[ServerNo-1].ShiftIndex;
				END_FOR
			END_FOR
			g_Core.Services.CAR.Interface.No[0].isCmdIncrementLoadID := TRUE;
	
			// Password OK
			FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
				IF (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = StatisticsPage) THEN
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 20, 25);
				END_IF
			END_FOR		
		ELSE
			// Password Wrong
			FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
				IF (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = StatisticsPage) THEN
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler, 21, 25);
				END_IF
			END_FOR		
		END_IF
	END_IF
	
	FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
		IF g_Core.Services.HMIHandler.Runtime.Handler[i].PasswordLevel = 0 AND RSetup[i] THEN
			RSetupCancel := TRUE;
			RSetup[i] := FALSE;
		END_IF
	
		IF (g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = StatisticsPage) THEN
			RStatPage := TRUE;
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].KeyPressed = 5 AND g_Core.Services.HMIHandler.Runtime.Handler[i].PasswordLevel > 2 THEN
				TempSetupCmd := TRUE;
				Term := i;
			END_IF
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].KeyPressed = 0 AND g_Core.Services.HMIHandler.Runtime.Handler[i].PasswordLevel > 1 AND TempSetupCmd AND Term = i THEN
				TempSetupCmd := FALSE;
				IF RSetup[i] THEN
					RSetupCancel := TRUE;
					RSetup[i] := FALSE;
				ELSE
					RSetup[i] := TRUE;
				END_IF
			END_IF
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].KeyPressed = 1 THEN
				RHistory := 1;
				Term := i;
			END_IF
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].KeyPressed = 0 AND RHistory = 1 AND Term = i THEN (*Wait for button release to fire off the shif*)
				RHistory := 2;
			END_IF
		ELSE // BKY exit save close wish ;)
			IF RSetup[i] THEN
				RSetup[i] := FALSE;
				RSetupCancel := TRUE;
			END_IF
		END_IF
	END_FOR
	
	IF RStatPage THEN
		SelectedRcpNo := g_Core.Services.Recipe.Runtime.selectedRcpNo;
		(*Henter texter her*)
		IF (StatsNotUpdated) THEN
			StatsNotUpdated := FALSE;
			GenStatisticsTotal := TRUE;
			GotTexts := FALSE;
		END_IF
	ELSE
		StatsNotUpdated := TRUE;
		StatisticsMain.Vis.DateBoxShow := 1;
	END_IF
	
	// Safety check.
	SelectedRcpNo := LIMIT(1,SelectedRcpNo,99);
	
	setup;
	
	IF EDGEPOS(g_Core.System.Runtime.isInitDone) THEN
		HistToggle := 1;
		RHistory := 2;
	END_IF
	
	IF (RHistory = 2) THEN
		CASE HistToggle OF
			0:
				FOR x := 0 TO g_Core.Services.HMIHandler.Runtime.HandlersRunning - 1 DO
					IF g_Core.Services.HMIHandler.Runtime.Handler[x].pPanelHandler > 0 THEN
						UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[x].pPanelHandler, StatisticsPage, 1, 60, 0, 1000); (*History button*)
					END_IF
				END_FOR
				HistToggle := 1;
				RHistory := 0;
				HideHistory := 1;
			1:
				FOR x := 0 TO g_Core.Services.HMIHandler.Runtime.HandlersRunning - 1 DO
					IF g_Core.Services.HMIHandler.Runtime.Handler[x].pPanelHandler > 0 THEN
						UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[x].pPanelHandler, StatisticsPage, 1, 125, 0, 1000); (*Live Data button*)
					END_IF
				END_FOR
				HistToggle := 0;
				RHistory := 0;
				HideHistory := 0;
				StatisticsMain.Vis.DateBoxShow := 1; (*PMS*)
		END_CASE
	END_IF
	(* ~Controls - User input *)
	
	(*Get Running Time*)
	
	(*Live counter*)
	IF g_Core.Services.Blackbox.Runtime.server.ServersRunning > 0 AND ReadStatisticsDataObject = 0 THEN
		FOR ServerNo := 1 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
			(*Loop all active lanes*)
			DisableTimeCounter := FALSE; // test for timefix
			
			FOR No := 0 TO UDINT_TO_USINT(GetData(ServerNo := ServerNo, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))) - 1 DO
				// Check if lane is active! for correct time messuring.
				IF UDINT_TO_BOOL(GetData(ServerNo := ServerNo, Type:= 29, Lane:= 1+No, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))) OR (IncreseShifIndex[ServerNo-1].LoadID[No] = 1) THEN // 29 = IS PU ACTIVE?
					Operator := No + 1;
					(*Loop for master and slaves*)
					LoadID[ServerNo-1].LoadID[No] := GetData(ServerNo := ServerNo, Type:= LOADID, Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
					IF LoadID[ServerNo-1].LoadID[No] > 0 OR RInit THEN
					
						TmpSecCounter := GetData(ServerNo:=ServerNo, Type:=40, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
						IF ( TmpSecCounter > 0 AND LoadID[ServerNo-1].LoadID[No] = OldLoadID[ServerNo-1].LoadID[No] AND ((NOT DisableTimeCounter AND NOT g_Core.Services.Blackbox.Configuration.Master.MultiRcp) OR g_Core.Services.Blackbox.Configuration.Master.MultiRcp)) THEN // Get current time used if not writing the log
							g_PermLogData[ServerNo-1].TimeInSec[No] := TmpSecCounter;
							DisableTimeCounter := TRUE; //Maybe time can be calculated correctly based on the PUState. (firstnumer is the lane combo / lane no. the second is the active station, single lane)
						END_IF
						
									
						PcsCnt   			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_PRODUCTION, 		Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Production Count for lane x*)
						SortACnt 			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_REWASH, 			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Rewash Count for lane x*)
						SortBCnt 			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_REPAIR, 			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Repair Count for lane x*)
						DropCnt  			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_DROP, 			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Drop Count for lane x*)
						QualityCnt  		:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_QUALITY, 		Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Quality Count for lane x*)
						OverSizeCnt  		:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_OVERSIZE, 		Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Quality Count for lane x*)
						TooCloseCnt  		:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_TOO_CLOSE, 		Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Quality Count for lane x*)
						PreProductionCnt  	:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_PREPRODUCTION, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Quality Count for lane x*)
						Option1Cnt 			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_EXTRA_1,			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Option1 Count for lane x*)
						Option2Cnt 			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_EXTRA_2,			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Option2 Count for lane x*)
						Option3Cnt 			:= GetData(ServerNo := ServerNo, Type:= PRODUCTION_EXTRA_3,			Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)); (*Get Option3 Count for lane x*)
						
						// Her i Danmark går vi også med livrem og seler! (og nogle går i lederhosen)
						IF CountPcs[ServerNo-1].Count[Operator-1] < PcsCnt THEN
							g_PermLogData[ServerNo-1].Production[No] := CountPcs[ServerNo-1].Count[Operator-1] := PcsCnt;
							IF (ServerNo = 1) THEN // Count only master machine!!!
								g_Core.Services.PanConfig.Interface.productionEvent[No] := TRUE; (*Send info to MachineInfo - Pcs counter*)
							END_IF
						END_IF
					
						(*SortA counter*)
						IF CountSortA[ServerNo-1].Count[Operator-1] < SortACnt THEN
							g_PermLogData[ServerNo-1].SortA[No] := CountSortA[ServerNo-1].Count[Operator-1] := SortACnt; 
						END_IF
						(*SortB counter*)
						IF CountSortB[ServerNo-1].Count[Operator-1] < SortBCnt THEN
							g_PermLogData[ServerNo-1].SortB[No] := CountSortB[ServerNo-1].Count[Operator-1] := SortBCnt;
						END_IF
						(*Drop counter*)
						IF CountDrop[ServerNo-1].Count[Operator-1] < DropCnt THEN
							g_PermLogData[ServerNo-1].Drop[No] := CountDrop[ServerNo-1].Count[Operator-1] := DropCnt;
						END_IF
						(*Quality counter*)
						IF CountQuality[ServerNo-1].Count[Operator-1] < QualityCnt THEN
							g_PermLogData[ServerNo-1].Quality[No] := CountQuality[ServerNo-1].Count[Operator-1] := QualityCnt;
						END_IF
						(*OverSize counter*)
						IF CountOverSize[ServerNo-1].Count[Operator-1] < OverSizeCnt THEN
							g_PermLogData[ServerNo-1].OverSize[No] := CountOverSize[ServerNo-1].Count[Operator-1] := OverSizeCnt;
						END_IF
						(*TooClose counter*)
						IF CountTooClose[ServerNo-1].Count[Operator-1] < TooCloseCnt THEN
							g_PermLogData[ServerNo-1].TooClose[No] := CountTooClose[ServerNo-1].Count[Operator-1] := TooCloseCnt;
						END_IF
						(*PreProduction counter*)
						IF CountPreProduction[ServerNo-1].Count[Operator-1] < PreProductionCnt THEN
							g_PermLogData[ServerNo-1].PreProduction[No] := CountPreProduction[ServerNo-1].Count[Operator-1] := PreProductionCnt;
						END_IF
						(*Option1 counter*)
						IF CountOption1[ServerNo-1].Count[Operator-1] < Option1Cnt THEN
							g_PermLogData[ServerNo-1].Option1[No] := CountOption1[ServerNo-1].Count[Operator-1] := Option1Cnt;
						END_IF
						(*Option2 counter*)
						IF CountOption2[ServerNo-1].Count[Operator-1] < Option2Cnt THEN
							g_PermLogData[ServerNo-1].Option2[No] :=CountOption2[ServerNo-1].Count[Operator-1] := Option2Cnt;
						END_IF
						(*Option3 counter*)
						IF CountOption3[ServerNo-1].Count[Operator-1] < Option3Cnt THEN
							g_PermLogData[ServerNo-1].Option3[No] := CountOption3[ServerNo-1].Count[Operator-1] := Option3Cnt;
						END_IF
					
						// FOR MASTER ONLY!
						IF ServerNo = 1 THEN
							// Making the flow abit more intelligent!
							IF No = 0 THEN
								LastServerFlowNo[ServerNo-1] := 0; // Reset last Server flow no
							END_IF
							TmpFlowNo := UDINT_TO_USINT(GetData(ServerNo:=ServerNo, Type:=66, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)))   ;	
							
							ServerFlowNo[ServerNo-1] := (TmpFlowNo - (TmpFlowNo MOD 10) ) / 10; // Strip the last number.
							IF ServerFlowNo[ServerNo-1] <> LastServerFlowNo[ServerNo-1] AND ServerFlowNo[ServerNo-1] > 0 THEN
								LastServerFlowNo[ServerNo-1] := ServerFlowNo[ServerNo-1];
								AllowFlow := g_Core.System.Runtime.isStatisticsRunning;
							ELSE
								AllowFlow := FALSE;
							END_IF
							IF g_Core.Services.Statistics.Interface.configuration.Flow1Type > 0 THEN
								Flow1Counter[No](set := AllowFlow AND UDINT_TO_BOOL(GetData(ServerNo:=ServerNo, Type:=g_Core.Services.Statistics.Interface.configuration.Flow1Type, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))));
								g_PermLogData[ServerNo-1].Flow1[No] := Flow1Counter[No].timer / 1000; // transmute to seconds
							END_IF
							IF g_Core.Services.Statistics.Interface.configuration.Flow2Type > 0 THEN
								Flow2Counter[No](set := AllowFlow AND UDINT_TO_BOOL(GetData(ServerNo:=ServerNo, Type:=g_Core.Services.Statistics.Interface.configuration.Flow2Type, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))));
								g_PermLogData[ServerNo-1].Flow2[No] := Flow2Counter[No].timer / 1000; // transmute to seconds
							END_IF
							IF g_Core.Services.Statistics.Interface.configuration.Flow3Type > 0 THEN
								Flow3Counter[No](set := AllowFlow AND UDINT_TO_BOOL(GetData(ServerNo:=ServerNo, Type:=g_Core.Services.Statistics.Interface.configuration.Flow3Type, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server))));
								g_PermLogData[ServerNo-1].Flow3[No] := Flow3Counter[No].timer / 1000; // transmute to seconds
							END_IF
						END_IF
						// Slut med seler og weissbier
						// TODO FIX SHIFT ID
						(*Reset - after cat shift*)
						IF LoadID[ServerNo-1].LoadID[No] > OldLoadID[ServerNo-1].LoadID[No] OR EdgeNegISControlPlc OR RInit OR (IncreseShifIndex[ServerNo-1].LoadID[No] = 1) THEN
							// Set lane mode for næste LoadID
							
							
							OldLoadID[ServerNo-1].LoadID[No] 						:= LoadID[ServerNo-1].LoadID[No];
						
							memset(ADR(CountPcs[ServerNo-1].Count[No]),				0,SIZEOF(CountPcs[ServerNo-1].Count[No]));
							memset(ADR(CountSortA[ServerNo-1].Count[No]),			0,SIZEOF(CountSortA[ServerNo-1].Count[No]));
							memset(ADR(CountSortB[ServerNo-1].Count[No]),			0,SIZEOF(CountSortB[ServerNo-1].Count[No]));
							memset(ADR(CountDrop[ServerNo-1].Count[No]),			0,SIZEOF(CountDrop[ServerNo-1].Count[No]));
							memset(ADR(CountQuality[ServerNo-1].Count[No]),			0,SIZEOF(CountQuality[ServerNo-1].Count[No]));
							memset(ADR(CountOverSize[ServerNo-1].Count[No]),		0,SIZEOF(CountOverSize[ServerNo-1].Count[No]));
							memset(ADR(CountTooClose[ServerNo-1].Count[No]),		0,SIZEOF(CountTooClose[ServerNo-1].Count[No]));
							memset(ADR(CountPreProduction[ServerNo-1].Count[No]),	0,SIZEOF(CountPreProduction[ServerNo-1].Count[No]));
							memset(ADR(CountOption1[ServerNo-1].Count[No]),			0,SIZEOF(CountOption1[ServerNo-1].Count[No]));
							memset(ADR(CountOption2[ServerNo-1].Count[No]),			0,SIZEOF(CountOption2[ServerNo-1].Count[No]));
							memset(ADR(CountOption3[ServerNo-1].Count[No]),			0,SIZEOF(CountOption3[ServerNo-1].Count[No]));
							Flow1Counter[No](reset := TRUE);
		  					Flow2Counter[No](reset := TRUE);
							Flow3Counter[No](reset := TRUE);	
							InitStat[ServerNo-1].LoadID[No] := 1;
							emil[No] := 1;
							timecounter[No] := g_PermLogData[ServerNo-1].TimeInSec[No];
							(*Dump current stat*)
						END_IF
	
						IF (InitStat[ServerNo-1].LoadID[No] = 1) THEN
							(*Copy data for logfile and faststat screen*)
							// TODO ADD MISSING Counters!
							IF ((g_PermLogData[ServerNo-1].Production[No] > 0 OR 
									g_PermLogData[ServerNo-1].SortA[No] > 0 OR 
										g_PermLogData[ServerNo-1].SortB[No] > 0 OR 
											g_PermLogData[ServerNo-1].Drop[No] > 0 OR 
												g_PermLogData[ServerNo-1].Quality[No] > 0 OR 
													g_PermLogData[ServerNo-1].OverSize[No] > 0 OR 
														g_PermLogData[ServerNo-1].PreProduction[No] > 0 OR 
															(strlen(ADR(g_PermLogData[ServerNo-1].Error[No])) > 0) OR
																g_PermLogData[ServerNo-1].Option1[No] > 0 OR
																	g_PermLogData[ServerNo-1].Option2[No] > 0 OR
																		g_PermLogData[ServerNo-1].Option3[No] > 0 OR
																			g_PermLogData[ServerNo-1].TimeInSec[No] > 0)) THEN
															emil[No] := 2;
								// Bruge samme datatype i Perm og logger???
								LogCore[ServerNo-1].PU[No].Data.CustomerNumber 	:= g_PermLogData[ServerNo-1].CustomerNumber[No];
								LogCore[ServerNo-1].PU[No].Data.ArticleNumber	:= g_PermLogData[ServerNo-1].ArticleNumber[No];
								LogCore[ServerNo-1].PU[No].Data.RecipeNumber	:= g_PermLogData[ServerNo-1].RecipeNumber[No] + 1; (*Bump rcpno + 1*)
								LogCore[ServerNo-1].PU[No].Data.CustomerName 	:= g_PermLogData[ServerNo-1].CustomerName[No];
								LogCore[ServerNo-1].PU[No].Data.ArticleName 	:= g_PermLogData[ServerNo-1].ArticleName[No];
								LogCore[ServerNo-1].PU[No].Data.RecipeName 		:= g_PermLogData[ServerNo-1].RecipeName[No];
								LogCore[ServerNo-1].PU[No].Data.Production		:= g_PermLogData[ServerNo-1].Production[No];
								LogCore[ServerNo-1].PU[No].Data.SortA 			:= g_PermLogData[ServerNo-1].SortA[No];
								LogCore[ServerNo-1].PU[No].Data.SortB 			:= g_PermLogData[ServerNo-1].SortB[No];
								LogCore[ServerNo-1].PU[No].Data.Drop 			:= g_PermLogData[ServerNo-1].Drop[No];
								LogCore[ServerNo-1].PU[No].Data.Quality 		:= g_PermLogData[ServerNo-1].Quality[No];
								LogCore[ServerNo-1].PU[No].Data.OverSize 		:= g_PermLogData[ServerNo-1].OverSize[No];
								LogCore[ServerNo-1].PU[No].Data.PreProduction 	:= g_PermLogData[ServerNo-1].PreProduction[No];
								LogCore[ServerNo-1].PU[No].Data.PU				:= No + 1;
								LogCore[ServerNo-1].PU[No].Data.TimeStart		:= g_PermLogData[ServerNo-1].TimeStart[No];
								LogCore[ServerNo-1].PU[No].Data.TimeStop		:= g_PermLogData[ServerNo-1].TimeStop[No];
								LogCore[ServerNo-1].PU[No].Data.TimeInSec		:= g_PermLogData[ServerNo-1].TimeInSec[No];
								LogCore[ServerNo-1].PU[No].Data.Option1			:= g_PermLogData[ServerNo-1].Option1[No];
								LogCore[ServerNo-1].PU[No].Data.Option2			:= g_PermLogData[ServerNo-1].Option2[No];
								LogCore[ServerNo-1].PU[No].Data.Option3			:= g_PermLogData[ServerNo-1].Option3[No];
								LogCore[ServerNo-1].PU[No].Data.Flow1			:= g_PermLogData[ServerNo-1].Flow1[No];
								LogCore[ServerNo-1].PU[No].Data.Flow2			:= g_PermLogData[ServerNo-1].Flow2[No];
								LogCore[ServerNo-1].PU[No].Data.Flow3			:= g_PermLogData[ServerNo-1].Flow3[No];
								LogCore[ServerNo-1].PU[No].Data.TooClose		:= g_PermLogData[ServerNo-1].TooClose[No];
								LogCore[ServerNo-1].PU[No].Data.ShiftIndex		:= g_PermLogData[ServerNo-1].ShiftIndex;
								LogCore[ServerNo-1].PU[No].Data.LastReset		:= g_PermLogData[ServerNo-1].LastReset[No];
								LogCore[ServerNo-1].PU[No].Data.Target			:= g_PermLogData[ServerNo-1].Target[No];
								LogCore[ServerNo-1].PU[No].Data.Error			:= g_PermLogData[ServerNo-1].Error[No];
								LogCore[ServerNo-1].PU[No].Write 				:= TRUE;
														
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Production[No] 	:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Production[No] 		+ g_PermLogData[ServerNo-1].Production[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].SortA[No] 			:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].SortA[No] 			+ g_PermLogData[ServerNo-1].SortA[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].SortB[No] 			:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].SortB[No]			+ g_PermLogData[ServerNo-1].SortB[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Drop[No]  			:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Drop[No] 			+ g_PermLogData[ServerNo-1].Drop[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Quality[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Quality[No] 		+ g_PermLogData[ServerNo-1].Quality[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].OverSize[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].OverSize[No] 		+ g_PermLogData[ServerNo-1].OverSize[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].PreProduction[No]  := ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].PreProduction[No] 	+ g_PermLogData[ServerNo-1].PreProduction[No];
				
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].TimeInSec[No]  	:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].TimeInSec[No] 		+ g_PermLogData[ServerNo-1].TimeInSec[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].TooClose[No] 		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].TooClose[No]  		+ g_PermLogData[ServerNo-1].TooClose[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option1[No] 		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option1[No]  		+ g_PermLogData[ServerNo-1].Option1[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option2[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option2[No] 		+ g_PermLogData[ServerNo-1].Option2[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option3[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Option3[No] 		+ g_PermLogData[ServerNo-1].Option3[No];
								
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow1[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow1[No] 		+ g_PermLogData[ServerNo-1].Flow1[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow2[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow2[No] 		+ g_PermLogData[ServerNo-1].Flow2[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow3[No]  		:= ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Flow3[No] 		+ g_PermLogData[ServerNo-1].Flow3[No];
								ArrStatistics[ServerNo-1].Statistics[g_PermLogData[ServerNo-1].RecipeNumber[No]].Target[No]  		:= g_PermLogData[ServerNo-1].Target[No];
								UpdateStatisticsDataObject := TRUE;
							END_IF
	
							(*Setup new stat*)
							(*Clear counters*)
							// TODO Can we use memset instead?
							g_PermLogData[ServerNo-1].ArticleName[No] 	:= '';	
							g_PermLogData[ServerNo-1].ArticleNumber[No] := 0;
							g_PermLogData[ServerNo-1].CustomerName[No] 	:= '';
							g_PermLogData[ServerNo-1].CustomerNumber[No]:= 0;
							g_PermLogData[ServerNo-1].Drop[No] 			:= 0;
							g_PermLogData[ServerNo-1].Option1[No] 		:= 0;
							g_PermLogData[ServerNo-1].Option2[No] 		:= 0;
							g_PermLogData[ServerNo-1].Option3[No] 		:= 0;
							g_PermLogData[ServerNo-1].Flow1[No] 		:= 0;
							g_PermLogData[ServerNo-1].Flow2[No] 		:= 0;
							g_PermLogData[ServerNo-1].Flow3[No] 		:= 0;
							g_PermLogData[ServerNo-1].OverSize[No] 		:= 0;
							g_PermLogData[ServerNo-1].PreProduction[No] := 0;
							g_PermLogData[ServerNo-1].Production[No] 	:= 0;
							g_PermLogData[ServerNo-1].Quality[No] 		:= 0;
							g_PermLogData[ServerNo-1].RecipeName[No] 	:= '';
							g_PermLogData[ServerNo-1].SortA[No] 		:= 0;
							g_PermLogData[ServerNo-1].SortB[No] 		:= 0;
							g_PermLogData[ServerNo-1].TimeInSec[No] 	:= 0;
							g_PermLogData[ServerNo-1].TimeStart[No] 	:= 0;
							g_PermLogData[ServerNo-1].TimeStop[No] 		:= 0;
							g_PermLogData[ServerNo-1].TooClose[No] 		:= 0;
							g_PermLogData[ServerNo-1].Target[No] 		:= 0;
							// Set bane combi til næste skift.
							TmpFlowNo := UDINT_TO_USINT(GetData(ServerNo:=ServerNo, Type:=66, Lane:=(No+1), Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)))   ;	
							g_PermLogData[ServerNo-1].Target[No] := (TmpFlowNo - (TmpFlowNo MOD 10) ) / 10; // Strip the last number.
						IF (IncreseShifIndex[ServerNo-1].LoadID[No] = 1) THEN
								(*Reset*)
								g_PermLogData[ServerNo-1].LastReset[No] := g_Core.Services.Time.Runtime.Date_Time;
							
								memset(ADR(ArrStatistics[ServerNo-1]),0,SIZEOF(ArrStatistics[ServerNo-1]));
								IF (No = 0) THEN
									Shift 							:= Shift + 1;
								END_IF
								IncreseShifIndex[ServerNo-1].LoadID[No] := FALSE;
								RNewShift 						:= 0;
								UpdateStatisticsDataObject 		:= TRUE;
						
							END_IF
							g_PermLogData[ServerNo-1].ShiftIndex 	:= Shift;
							g_PermLogData[ServerNo-1].TimeStart[No]	:= g_Core.Services.Time.Runtime.Date_Time;
	
							(*Get new rcp nr, text etc...*)
							g_PermLogData[ServerNo-1].RecipeNumber[No] 		:= UDINT_TO_UINT(	GetData(ServerNo := ServerNo, Type:= RECIPE_NUMBER, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
							g_PermLogData[ServerNo-1].ArticleNumber[No] 	:= 					GetData(ServerNo := ServerNo, Type:= ARTICLE_NUMBER, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
							g_PermLogData[ServerNo-1].CustomerNumber[No] 	:= 					GetData(ServerNo := ServerNo, Type:= CUSTOMER_NUMBER, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
	
							strcpy(ADR(g_PermLogData[ServerNo-1].CustomerName[No]), GetData(ServerNo := ServerNo, Type:= ADR_CUSTOMER_TEXT, Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
							strcpy(ADR(g_PermLogData[ServerNo-1].ArticleName[No]), 	GetData(ServerNo := ServerNo, Type:= ADR_ARTICLE_TEXT, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
							strcpy(ADR(g_PermLogData[ServerNo-1].RecipeName[No]), 	GetData(ServerNo := ServerNo, Type:= ADR_RECIPE_TEXT, 	Lane:= Operator, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)));
	
							InitStat[ServerNo-1].LoadID[No] := 0;
							ResetTimeInUDINT 				:= DT_TO_UDINT(g_PermLogData[ServerNo-1].LastReset[No]);
						END_IF
	
						IF EdgePosISControlPlc THEN (*Refresh start time*)
							g_PermLogData[ServerNo-1].TimeStart[No] := g_Core.Services.Time.Runtime.Date_Time;
						END_IF
						g_PermLogData[ServerNo-1].TimeStop[No] := g_Core.Services.Time.Runtime.Date_Time;
					END_IF
	
				
		
				(*Get Running Time*)
				END_IF //!Check if PU is active.
			END_FOR
		END_FOR
		RInit := FALSE;
	END_IF
	(*~Get Running Time*)
	(*~Live counter*)
	
	(*Update vis live statistics*)
	IF RStatPage THEN
		(*Get Data source for the dynamic displays*)
		memset(ADR(LiveData),0,SIZEOF(LiveData));
		
		FOR i := 0 TO SIZEOF(ArrStatistics[0].Statistics)/SIZEOF(ArrStatistics[0].Statistics[0]) - 1 DO
			
			maxTarget := 1;
			FOR No := 0 TO 9 DO
				IF ArrStatistics[DisplayServer].Statistics[i].Target[No] > maxTarget THEN
					maxTarget := ArrStatistics[DisplayServer].Statistics[i].Target[No];
				END_IF
			END_FOR
			
			FOR No := 0 TO 9 DO
				LiveData[0].Production[No] 	:= LiveData[0].Production[No] 	+ ArrStatistics[DisplayServer].Statistics[i].Production[No];
				LiveData[0].SortA 			:= LiveData[0].SortA 			+ ArrStatistics[DisplayServer].Statistics[i].SortA[No];
				LiveData[0].SortB 			:= LiveData[0].SortB 			+ ArrStatistics[DisplayServer].Statistics[i].SortB[No];
				LiveData[0].Drop  			:= LiveData[0].Drop 			+ ArrStatistics[DisplayServer].Statistics[i].Drop[No];
				LiveData[0].Quality  		:= LiveData[0].Quality 			+ ArrStatistics[DisplayServer].Statistics[i].Quality[No];
				LiveData[0].OverSize  		:= LiveData[0].OverSize 		+ ArrStatistics[DisplayServer].Statistics[i].OverSize[No];
				LiveData[0].TooClose  		:= LiveData[0].TooClose 		+ ArrStatistics[DisplayServer].Statistics[i].TooClose[No];
				LiveData[0].PreProduction	:= LiveData[0].PreProduction 	+ ArrStatistics[DisplayServer].Statistics[i].PreProduction[No];
				LiveData[0].TimeInSec  		:= LiveData[0].TimeInSec 		+ ArrStatistics[DisplayServer].Statistics[i].TimeInSec[No];
				LiveData[0].Total 			:= LiveData[0].Total 			+ ArrStatistics[DisplayServer].Statistics[i].Production[No];
				LiveData[0].Option1 		:= LiveData[0].Option1 			+ ArrStatistics[DisplayServer].Statistics[i].Option1[No];
				LiveData[0].Option2 		:= LiveData[0].Option2 			+ ArrStatistics[DisplayServer].Statistics[i].Option2[No];
				LiveData[0].Option3 		:= LiveData[0].Option3 			+ ArrStatistics[DisplayServer].Statistics[i].Option3[No];
				LiveData[0].Flow1 			:= LiveData[0].Flow1 			+ ArrStatistics[DisplayServer].Statistics[i].Flow1[No]/maxTarget;
				LiveData[0].Flow2 			:= LiveData[0].Flow2 			+ ArrStatistics[DisplayServer].Statistics[i].Flow2[No]/maxTarget;
				LiveData[0].Flow3 			:= LiveData[0].Flow3 			+ ArrStatistics[DisplayServer].Statistics[i].Flow3[No]/maxTarget;
			END_FOR
			
		END_FOR
		
		maxTarget := 1;
		FOR No := 0 TO 9 DO
			IF g_PermLogData[DisplayServer].Target[No] > maxTarget THEN
				maxTarget := g_PermLogData[DisplayServer].Target[No];
			END_IF
		END_FOR
		
		FOR No := 0 TO 9 DO
			LiveData[0].Production[No] 	:= LiveData[0].Production[No] 	+ g_PermLogData[DisplayServer].Production[No];
			LiveData[0].SortA 			:= LiveData[0].SortA 			+ g_PermLogData[DisplayServer].SortA[No];
			LiveData[0].SortB			:= LiveData[0].SortB			+ g_PermLogData[DisplayServer].SortB[No];
			LiveData[0].Drop			:= LiveData[0].Drop 			+ g_PermLogData[DisplayServer].Drop[No];
			LiveData[0].Quality 		:= LiveData[0].Quality 			+ g_PermLogData[DisplayServer].Quality[No];
			LiveData[0].OverSize		:= LiveData[0].OverSize 		+ g_PermLogData[DisplayServer].OverSize[No];
			LiveData[0].TooClose 		:= LiveData[0].TooClose 		+ g_PermLogData[DisplayServer].TooClose[No];
			LiveData[0].PreProduction  	:= LiveData[0].PreProduction 	+ g_PermLogData[DisplayServer].PreProduction[No];
			LiveData[0].TimeInSec 	 	:= LiveData[0].TimeInSec 		+ g_PermLogData[DisplayServer].TimeInSec[No];
			LiveData[0].Total 			:= LiveData[0].Total 			+ g_PermLogData[DisplayServer].Production[No];
			LiveData[0].Option1 		:= LiveData[0].Option1 			+ g_PermLogData[DisplayServer].Option1[No];
			LiveData[0].Option2 		:= LiveData[0].Option2 			+ g_PermLogData[DisplayServer].Option2[No];
			LiveData[0].Option3 		:= LiveData[0].Option3 			+ g_PermLogData[DisplayServer].Option3[No];
			LiveData[0].Flow1	 		:= LiveData[0].Flow1 			+ g_PermLogData[DisplayServer].Flow1[No]/maxTarget;
			LiveData[0].Flow2	 		:= LiveData[0].Flow2 			+ g_PermLogData[DisplayServer].Flow2[No]/maxTarget;
			LiveData[0].Flow3	 		:= LiveData[0].Flow3 			+ g_PermLogData[DisplayServer].Flow3[No]/maxTarget;
		END_FOR
		
		maxTarget := 1;
		FOR No := 0 TO 9 DO
			IF ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Target[No] > maxTarget THEN
				maxTarget := ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Target[No];
			END_IF
		END_FOR
		
		FOR No := 0 TO 9 DO
			(*~Update Total data from permdata*)
			LiveData[1].Production[No]	:= LiveData[1].Production[No] + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Production[No];
			LiveData[1].SortA 			:= LiveData[1].SortA + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].SortA[No];
			LiveData[1].SortB	 		:= LiveData[1].SortB + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].SortB[No];
			LiveData[1].Drop  			:= LiveData[1].Drop + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Drop[No];
			LiveData[1].Quality  		:= LiveData[1].Quality + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Quality[No];
			LiveData[1].OverSize  		:= LiveData[1].OverSize + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].OverSize[No];
			LiveData[1].TooClose  		:= LiveData[1].TooClose + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].TooClose[No];
			LiveData[1].PreProduction  	:= LiveData[1].PreProduction + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].PreProduction[No];
			LiveData[1].TimeInSec 		:= LiveData[1].TimeInSec + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].TimeInSec[No];
			LiveData[1].Total 			:= LiveData[1].Total + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Production[No];
			LiveData[1].Option1			:= LiveData[1].Option1 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option1[No];
			LiveData[1].Option2			:= LiveData[1].Option2 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option2[No];
			LiveData[1].Option3			:= LiveData[1].Option3 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option3[No];
			LiveData[1].Flow1			:= LiveData[1].Flow1 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow1[No]/maxTarget;
			LiveData[1].Flow2			:= LiveData[1].Flow2 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow2[No]/maxTarget;
			LiveData[1].Flow3			:= LiveData[1].Flow3 + ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow3[No]/maxTarget;
			// Experimental
			// Try to set detailed data for each PU.
			LiveData[2+No].Production[No]	:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Production[No];
			LiveData[2+No].SortA 			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].SortA[No];
			LiveData[2+No].SortB	 		:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].SortB[No];
			LiveData[2+No].Drop  			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Drop[No];
			LiveData[2+No].Quality  		:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Quality[No];
			LiveData[2+No].OverSize  		:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].OverSize[No];
			LiveData[2+No].TooClose  		:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].TooClose[No];
			LiveData[2+No].PreProduction  	:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].PreProduction[No];
			LiveData[2+No].TimeInSec 		:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].TimeInSec[No];
			LiveData[2+No].Total 			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Production[No];
			LiveData[2+No].Option1			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option1[No];
			LiveData[2+No].Option2			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option2[No];
			LiveData[2+No].Option3			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Option3[No];
			LiveData[2+No].Flow1			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow1[No];
			LiveData[2+No].Flow2			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow2[No];
			LiveData[2+No].Flow3			:= ArrStatistics[DisplayServer].Statistics[SelectedRcpNo-1].Flow3[No];
		END_FOR
		
		maxTarget := 1;
		FOR No := 0 TO 9 DO
			IF g_PermLogData[DisplayServer].Target[No] > maxTarget THEN
				maxTarget := g_PermLogData[DisplayServer].Target[No];
			END_IF
		END_FOR
		
		FOR No := 0 TO 9 DO
			
			IF (g_PermLogData[DisplayServer].RecipeNumber[No] = SelectedRcpNo-1) THEN
				LiveData[1].Production[No] 	:= LiveData[1].Production[No] 	+ g_PermLogData[DisplayServer].Production[No];
				LiveData[1].SortA 			:= LiveData[1].SortA 			+ g_PermLogData[DisplayServer].SortA[No];
				LiveData[1].SortB 			:= LiveData[1].SortB 			+ g_PermLogData[DisplayServer].SortB[No];
				LiveData[1].Drop  			:= LiveData[1].Drop 			+ g_PermLogData[DisplayServer].Drop[No];
				LiveData[1].Quality  		:= LiveData[1].Quality 			+ g_PermLogData[DisplayServer].Quality[No];
				LiveData[1].OverSize  		:= LiveData[1].OverSize 		+ g_PermLogData[DisplayServer].OverSize[No];
				LiveData[1].TooClose  		:= LiveData[1].TooClose 		+ g_PermLogData[DisplayServer].TooClose[No];
				LiveData[1].PreProduction  	:= LiveData[1].PreProduction 	+ g_PermLogData[DisplayServer].PreProduction[No];
				LiveData[1].TimeInSec  		:= LiveData[1].TimeInSec 		+ g_PermLogData[DisplayServer].TimeInSec[No];
				LiveData[1].Total 			:= LiveData[1].Total 			+ g_PermLogData[DisplayServer].Production[No];
				LiveData[1].Option1 		:= LiveData[1].Option1 			+ g_PermLogData[DisplayServer].Option1[No];
				LiveData[1].Option2 		:= LiveData[1].Option2 			+ g_PermLogData[DisplayServer].Option2[No];
				LiveData[1].Option3 		:= LiveData[1].Option3 			+ g_PermLogData[DisplayServer].Option3[No];
				LiveData[1].Flow1	 		:= LiveData[1].Flow1 			+ g_PermLogData[DisplayServer].Flow1[No]/maxTarget;
				LiveData[1].Flow2	 		:= LiveData[1].Flow2 			+ g_PermLogData[DisplayServer].Flow2[No]/maxTarget;
				LiveData[1].Flow3	 		:= LiveData[1].Flow3 			+ g_PermLogData[DisplayServer].Flow3[No]/maxTarget;
				// EXPERIMENTAL
				// TRY TO GET THE DETAILED VIEW!
				LiveData[2+No].Production[No] 	:= g_PermLogData[DisplayServer].Production[No];
				LiveData[2+No].SortA 			:= g_PermLogData[DisplayServer].SortA[No];
				LiveData[2+No].SortB 			:= g_PermLogData[DisplayServer].SortB[No];
				LiveData[2+No].Drop  			:= g_PermLogData[DisplayServer].Drop[No];
				LiveData[2+No].Quality  		:= g_PermLogData[DisplayServer].Quality[No];
				LiveData[2+No].OverSize  		:= g_PermLogData[DisplayServer].OverSize[No];
				LiveData[2+No].TooClose  		:= g_PermLogData[DisplayServer].TooClose[No];
				LiveData[2+No].PreProduction  	:= g_PermLogData[DisplayServer].PreProduction[No];
				//IF g_Core.Services.Blackbox.Init.Master.MultiRcp
					LiveData[2+No].TimeInSec  		:= g_PermLogData[DisplayServer].TimeInSec[No];
				//ELSE
				//	LiveData[2+No].TimeInSec  		:= LiveData[1].TimeInSec;
				//END_IF
				LiveData[2+No].Total 			:= g_PermLogData[DisplayServer].Production[No];
				LiveData[2+No].Option1 			:= g_PermLogData[DisplayServer].Option1[No];
				LiveData[2+No].Option2 			:= g_PermLogData[DisplayServer].Option2[No];
				LiveData[2+No].Option3 			:= g_PermLogData[DisplayServer].Option3[No];
				LiveData[2+No].Flow1	 		:= g_PermLogData[DisplayServer].Flow1[No];
				LiveData[2+No].Flow2	 		:= g_PermLogData[DisplayServer].Flow2[No];
				LiveData[2+No].Flow3	 		:= g_PermLogData[DisplayServer].Flow3[No];
			END_IF	
		END_FOR
		(*GenTextTime*)
		// Fix time for multircp.
		//IF g_Core.Services.Blackbox.Init.Master.MultiRcp THEN
		//	LiveData[0].TimeInSec := LiveData[0].TimeInSec / NumberOfProductionUnits;
		//	LiveData[1].TimeInSec := LiveData[1].TimeInSec / NumberOfProductionUnits;
		//END_IF
		FOR x := 0 TO 11 DO
			SecToText(LiveData[x].TimeInSec,ADR(LiveData[x].TimeString),(x > 1));
			//SecToText(LiveData[0].TimeInSec,ADR(LiveData[0].TimeString),0);
			//SecToText(LiveData[1].TimeInSec,ADR(LiveData[1].TimeString),0);
		END_FOR
		(*~Update vis live statistics*)
	
		FOR i := 0 TO 11 DO
			CASE DynamicSetup[i] OF
				1: (*TIME*)
					(*Total*)
					IF HistToggle = 0 THEN
						DynamicData[0].Data[i] := LiveData[0].TimeString;
						(*Actual*)
						DynamicData[1].Data[i] := LiveData[1].TimeString;
						FOR x := 0 TO 9 DO
							DynamicData[2+x].Data[i] := LiveData[2+x].TimeString;
						END_FOR
						(*Text*)
					ELSE
						// multi rcp time fix.
						IF g_Core.Services.Blackbox.Configuration.Master.MultiRcp THEN
							tmpTimeInSec := StatisticsMain.Vis.Counters.TimeInSec / NumberOfProductionUnits;
						ELSE
							tmpTimeInSec := StatisticsMain.Vis.Counters.TimeInSec;
						END_IF
						SecToText(tmpTimeInSec,ADR(DynamicData[0].Data[i]),0);
						
						//tmpTimeInSec := StatisticsMain.Vis.Counters.TimeInSec;
						//SecToText(tmpTimeInSec,ADR(DynamicData[0].Data[i]),0);
					END_IF
					StatisticsMain.Vis.ActiveOptions[i] := 20;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				2: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Total,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Total,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Total,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					(*Text*)
					ELSE
						itoa(StatisticsMain.Vis.Counters.Total,ADR(DynamicData[0].Data[i]));
					END_IF
	
					StatisticsMain.Vis.ActiveOptions[i] := 21;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				10: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[0],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[0],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[0],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[0],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 1;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				11: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[1],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[1],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[1],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[1],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 2;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				12: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[2],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[2],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[2],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[2],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 3;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				13: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[3],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[3],ADR(DynamicData[1].Data[i]));
						(*Text*)
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[3],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[3],ADR(DynamicData[0].Data[i]));
					END_IF
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 4;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				14: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[4],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[4],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[4],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[4],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 5;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				15: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[5],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[5],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[5],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[5],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 6;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				16: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[6],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[6],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[6],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[6],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 7;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				17: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[7],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[7],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[7],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[7],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 8;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				18: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[8],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[8],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[8],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[8],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 9;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				19: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Production[9],ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Production[9],ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Production[9],ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Production[9],ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := MachineType + 10;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
					
				3: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].SortA,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].SortA,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].SortA,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.SortA,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 22;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				4: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].SortB,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].SortB,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].SortB,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.SortB,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 23;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				5: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Drop,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Drop,ADR(DynamicData[1].Data[i]));
						(*Text*)
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Drop,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Drop,ADR(DynamicData[0].Data[i]));
					END_IF
					StatisticsMain.Vis.ActiveOptions[i] := 24;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				6: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Quality,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Quality,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Quality,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Quality,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 25;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				7: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].OverSize,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].OverSize,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].OverSize,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.OverSize,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 26;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				8: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].PreProduction,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].PreProduction,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].PreProduction,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.PreProduction,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 27;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				9: (*Count*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].TooClose,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].TooClose,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].TooClose,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.TooClose,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 28;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
					
				20: (*Option1*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Option1,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Option1,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Option1,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Option1,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 29;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				21: (*Option2*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Option2,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Option2,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Option2,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Option2,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 30;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				22: (*Option3*)
					(*Total*)
					IF HistToggle = 0 THEN
						itoa(LiveData[0].Option3,ADR(DynamicData[0].Data[i]));
						(*Actual*)
						itoa(LiveData[1].Option3,ADR(DynamicData[1].Data[i]));
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Option3,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						itoa(StatisticsMain.Vis.Counters.Option3,ADR(DynamicData[0].Data[i]));
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := 31;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
					
				23: // Flow test!
					(*Total*)
					IF HistToggle = 0 THEN
						SecToText(LiveData[0].Flow1,ADR(DynamicData[0].Data[i]),0);
						(*Actual*)
						SecToText(LiveData[1].Flow1,ADR(DynamicData[1].Data[i]),0);
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Flow1,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						SecToText(StatisticsMain.Vis.Counters.Flow1,ADR(DynamicData[0].Data[i]),0);
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := (g_Core.Services.Statistics.Interface.configuration.Flow1Type - 60)+32;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
				
				24: // Flow test!
					(*Total*)
					IF HistToggle = 0 THEN
						SecToText(LiveData[0].Flow2,ADR(DynamicData[0].Data[i]),0);
						(*Actual*)
						SecToText(LiveData[1].Flow2,ADR(DynamicData[1].Data[i]),0);
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Flow2,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						SecToText(StatisticsMain.Vis.Counters.Flow2,ADR(DynamicData[0].Data[i]),0);
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := (g_Core.Services.Statistics.Interface.configuration.Flow2Type - 60)+32;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
					
				25: // Flow test!
					(*Total*)
					IF HistToggle = 0 THEN
						SecToText(LiveData[0].Flow3,ADR(DynamicData[0].Data[i]),0);
						(*Actual*)
						SecToText(LiveData[1].Flow3,ADR(DynamicData[1].Data[i]),0);
						FOR x := 0 TO 9 DO
							itoa(LiveData[2+x].Flow3,ADR(DynamicData[2+x].Data[i]));
						END_FOR
					ELSE
						SecToText(StatisticsMain.Vis.Counters.Flow3,ADR(DynamicData[0].Data[i]),0);
					END_IF
					(*Text*)
					StatisticsMain.Vis.ActiveOptions[i] := (g_Core.Services.Statistics.Interface.configuration.Flow3Type - 60)+32;
					StatisticsMain.Vis.ShowActiveOptions[i] := 0;
	
			ELSE
				(*Total*)
				DynamicData[0].Data[i] := '';
				(*Actual*)
				DynamicData[1].Data[i] := '';
				(*Text*)
				FOR x := 0 TO 9 DO
					DynamicData[2+x].Data[i] := '';
				END_FOR
				StatisticsMain.Vis.ActiveOptions[i] := 16;
				StatisticsMain.Vis.ShowActiveOptions[i] := 1;
			END_CASE
		END_FOR
	END_IF
	
	IF RSetupCancel THEN
		StatisticsMain.Vis.ShowSetup := 1;
		StatisticsMain.Vis.ScrollBoxShow := 1;
		RSetupCancel := FALSE;
		SetupStep := 0;
		UpdateDynamicSetup := TRUE;
	END_IF
	
	IF (UpdateDynamicSetup) THEN
		g_Core.Services.System.Runtime.file.StatSetup := DynamicSetup;
		(*DatObjWrite_0(enable:=1, ident:=DynamicSetupIdent, Offset:=0, pSource:=ADR(DynamicSetup), len:=SIZEOF(DynamicSetup));
		IF (DatObjWrite_0.status = 0) THEN
			UpdateDynamicSetup := FALSE;
		END_IF*)
		UpdateDynamicSetup := FALSE;
		g_Core.Services.System.Interface.isCmdSave := TRUE;
		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	END_IF
	
	IF RSetup[0] OR RSetup[1] THEN
		CASE SetupStep OF
		0:
			StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[18];
			SetupItmeNo := 0;
			FOR i := 0 TO 11 DO
				StatisticsMain.Vis.SetupColors[i] := 46;
			END_FOR
			StatisticsMain.Vis.ShowSetup := 0;
			SetupStep := 1;
		1:
			IF SetupItmeNo > 0 THEN
				FOR i := 0 TO 11 DO
					IF SetupItmeNo - 1 <> i THEN
						StatisticsMain.Vis.SetupColors[i] := 15;
					ELSE
						StatisticsMain.Vis.SetupColors[i] := 4041;
					END_IF
				END_FOR
				SetupStep := 2;
			END_IF
		2: (*Get list of options*)
			(*Get numbers*)
	
			IF pFirstDynaicStatType = 0 THEN
				FOR i := 0 TO 24 DO
					Add := FALSE;
					CASE i OF
						2:
							IF g_Core.Services.Statistics.Interface.configuration.isRewash THEN
								Add := TRUE;
							END_IF
						3:
							IF g_Core.Services.Statistics.Interface.configuration.isRepair THEN
								Add := TRUE;
							END_IF
	
						4:
							IF g_Core.Services.Statistics.Interface.configuration.isDrop THEN
								Add := TRUE;
							END_IF
	
						5:
							IF g_Core.Services.Statistics.Interface.configuration.isQuality THEN
								Add := TRUE;
							END_IF
						6:
							IF g_Core.Services.Statistics.Interface.configuration.isOversize THEN
								Add := TRUE;
							END_IF
						7:
							IF g_Core.Services.Statistics.Interface.configuration.isPreproduction THEN
								Add := TRUE;
							END_IF
						8:
							IF g_Core.Services.Statistics.Interface.configuration.isTooClose THEN
								Add := TRUE;
							END_IF
						9..18:
							IF NumberOfProductionUnits >= (i - 8) THEN
								Add := TRUE;
							END_IF
						19:
							IF g_Core.Services.Statistics.Interface.configuration.isOption1 THEN
								Add := TRUE;
							END_IF
						20:
							IF g_Core.Services.Statistics.Interface.configuration.isOption2 THEN
								Add := TRUE;
							END_IF
						21:
							IF g_Core.Services.Statistics.Interface.configuration.isOption3 THEN
								Add := TRUE;
							END_IF
						22:
							IF g_Core.Services.Statistics.Interface.configuration.Flow1Type > 0 THEN
								Add := TRUE;
							END_IF
						23:
							IF g_Core.Services.Statistics.Interface.configuration.Flow2Type > 0 THEN
								Add := TRUE;
							END_IF
						24:
							IF g_Core.Services.Statistics.Interface.configuration.Flow3Type > 0 THEN
								Add := TRUE;
							END_IF
							
						ELSE
							Add := TRUE;
	
					END_CASE
					IF Add THEN
						AsMemPartAlloc_0(enable:=1, ident:=LoadBuffer, len:=SIZEOF(pStatisticsDynOption));
						IF (AsMemPartAlloc_0.status = 0) THEN (*Mem allocated ok*)
							IF pFirstDynaicStatType = 0 THEN (*Set first customer*)
								pFirstDynaicStatType := AsMemPartAlloc_0.mem;
							ELSE
								PrevOptionAddr := ADR(pStatisticsDynOption);
								pStatisticsDynOption.pNext := AsMemPartAlloc_0.mem;
							END_IF
							pStatisticsDynOption ACCESS AsMemPartAlloc_0.mem; (*Access correct mem*)
							pStatisticsDynOption.pPrev := PrevOptionAddr; (*Easy access for the scrolllist*)
							pStatisticsDynOption.No := i+1;
							IF (i < 9) THEN
								NameIndex := i + 20;
							ELSIF (i > 18) THEN
								IF (i > 21) THEN // new flows
									CASE i OF
										22:
											FlowType := g_Core.Services.Statistics.Interface.configuration.Flow1Type;
										23:
											FlowType := g_Core.Services.Statistics.Interface.configuration.Flow2Type;
										24:
											FlowType := g_Core.Services.Statistics.Interface.configuration.Flow3Type;
									END_CASE
									NameIndex := (FlowType - 60) + 32; // flow text start offset.
								ELSE
									NameIndex := i + 20 - 10;
								END_IF
							ELSE
								NameIndex := (i - 9) + ((MachineType/100) -1 )* 10 + 38; (*Was 29*)
							END_IF
							pStatisticsDynOption.Name := ArrTexts[NameIndex];
							(*M?ske m?ske ikke...*)
						END_IF
					END_IF
				END_FOR
			END_IF
			SetupStep := 3;
	
		3:
			(*Open dialog*)
			(*StatisticsMain.Vis.ScrollBoxShow := 0;*)
			(*SetupStep := 3;*)
			IF StatisticsMain.ListMode <> 4 THEN
				StatisticsMain.ListMode := 4;
				SubUpdateScroller := TRUE;
				pCurrentTopCustomer := pFirstDynaicStatType;
				(*CustomerAdr := 0 Reset article choice?*);
			ELSE
				StatisticsMain.Vis.ScrollBoxShow := 0;
			END_IF
			SetupStep := 5;
	
		4:
			IF StatisticsMain.Vis.ScrollBoxCmdClose THEN
				StatisticsMain.Vis.ScrollBoxCmdClose := 0;
				SetupStep := 0;
				StatisticsMain.Vis.ScrollBoxShow := 1;
			ELSIF StatisticsMain.Vis.ScrollBoxCmdEnter THEN
				StatisticsMain.Vis.ScrollBoxCmdEnter := 0;
				SetupStep := 0;
				StatisticsMain.Vis.ScrollBoxShow := 1;
			END_IF
		5:
			IF UpdateDynamicOption > 0 THEN
				CASE UpdateDynamicOption OF
					1:
						DynamicSetup[SetupItmeNo-1] := UDINT_TO_USINT(pStatisticsDynOption.No);
					2:
						DynamicSetup[SetupItmeNo-1] := 0;
	
				END_CASE
				UpdateDynamicOption := 0;
				SetupStep := 0;
			END_IF
	
		END_CASE
	END_IF
	
	SetupItmeNo;
	
	CASE OpenStatisticsDataObject OF
		1:
			FileOpen_0(enable:=1, pDevice:=ADR(fDevice), pFile:=ADR('statistics.dat'), mode:=fiREAD_WRITE);
			OpenStatisticsDataObject := 2;
		2:
			CASE FileOpen_0.status OF
				0: (*File opened*)
					StatisticsDataObjectIdent := FileOpen_0.ident;
					OpenStatisticsDataObject := 0;
				65535: (*Call fub again*)
					FileOpen_0();
	
				20708:
					OpenStatisticsDataObject := 0;
					CreateStatisticsDataObject := 1;
					OpenStatisticsDataObject := 3;
			END_CASE
	
		3:
			IF (CreateStatisticsDataObject = 0) THEN
				OpenStatisticsDataObject := 0;
			END_IF
	END_CASE
	
	CASE CreateStatisticsDataObject OF
		1:
			FileCreate_0(enable:=1, pDevice := ADR(fDevice), pFile:=ADR('statistics.dat'));
			CreateStatisticsDataObject := 2;
		2:
			CASE FileCreate_0.status OF
				0: (*All ok*)
					CreateStatisticsDataObject := 0;
					StatisticsDataObjectIdent := FileCreate_0.ident;
				65535:
					FileCreate_0();
			END_CASE
	END_CASE
	
	
	CASE UpdateStatisticsDataObject OF
		1:
			OpenStatisticsDataObject := 1;
			UpdateStatisticsDataObject := 2;
	
		2:
			IF (OpenStatisticsDataObject = 0) AND (StatisticsDataObjectIdent > 0) THEN
				UpdateStatisticsDataObject := 3;
			END_IF
		3:
			FileWrite_0(enable:=1, ident:=StatisticsDataObjectIdent, offset:=0, pSrc:=ADR(ArrStatistics), len:=SIZEOF(ArrStatistics));
			UpdateStatisticsDataObject := 4;
		4:
			IF FileWrite_0.status = 65535 THEN
				FileWrite_0();
			ELSE
				UpdateStatisticsDataObject := 5;
			END_IF
		5:
			CloseStatisticsDataObject := 1;
			UpdateStatisticsDataObject := 6;
		6:
			IF CloseStatisticsDataObject = 0 THEN
				UpdateStatisticsDataObject := 0;
			END_IF
	END_CASE
	
	CASE ReadStatisticsDataObject OF
		1:
	
			OpenStatisticsDataObject := 1;
			ReadStatisticsDataObject := 2;
	
		2:
			IF (OpenStatisticsDataObject = 0 AND (StatisticsDataObjectIdent > 0)) THEN
				ReadStatisticsDataObject := 3;
			END_IF
	
		3:
			FileRead_0(enable:=1, ident:=StatisticsDataObjectIdent, offset:=0, pDest:=ADR(ArrStatistics), len:=SIZEOF(ArrStatistics));
			ReadStatisticsDataObject := 4;
	
		4:
			CASE FileRead_0.status OF
				0:
					ReadStatisticsDataObject := 0; (*All ok*)
				65535:
					FileRead_0(); (*Call fub again*)
			END_CASE
	END_CASE
	
	CASE CloseStatisticsDataObject OF
		1:
			IF (StatisticsDataObjectIdent > 0) THEN
				FileClose_0(enable:=1, ident:=StatisticsDataObjectIdent);
				CloseStatisticsDataObject := 2;
			END_IF
		2:
			CASE FileClose_0.status OF
			0:
				CloseStatisticsDataObject := 0; (*File closed*)
				StatisticsDataObjectIdent := 0;
	
			65535:
				FileClose_0(); (*Fub still working*)
			END_CASE
	END_CASE
	
	(*Filename chanage test*)
	FlatVarHandler_0.pFile := ADR(FilenameTest);
	(*End test*)
	
	DT_TO_DTStructure(g_Core.Services.Time.Runtime.Date_Time, ADR(DTStructure_0));
	DT_TO_DTStructure(newDate, ADR(DTStructure_1));
	
	FileHeadLinesNo := FlatVar.FileHeaderLines;
	FileDataLinesNo := FlatVar.FileDataLines;
	
	(* cyclic program *)
	(*datebox test*)
	Scroll_DateUp( In := StatisticsMain.Vis.DateBoxCmdMUp OR StatisticsMain.Vis.DateBoxCmdDUp OR StatisticsMain.Vis.DateBoxCmdYUp );
	Scroll_DateDown( In := StatisticsMain.Vis.DateBoxCmdMDown OR StatisticsMain.Vis.DateBoxCmdDDown OR StatisticsMain.Vis.DateBoxCmdYDown );
	
	(*Reset Today*)
	IF (Scroll_DateUp.In OR Scroll_DateDown.In) AND Today THEN
		Today := FALSE;
	END_IF
	
	IF (Scroll_DateUp.Out) THEN
		IF (StatisticsMain.Vis.DateBoxCmdMUp) THEN
			UpdateMonthScroller := 2;
		END_IF
		IF (StatisticsMain.Vis.DateBoxCmdDUp) THEN
			UpdateDayScroller := 2;
		END_IF
		IF (StatisticsMain.Vis.DateBoxCmdYUp) THEN
			UpdateYearScroller := 2;
		END_IF
	END_IF
	
	IF (Scroll_DateDown.Out) THEN
		IF (StatisticsMain.Vis.DateBoxCmdMDown) THEN
			UpdateMonthScroller := 1;
		END_IF
		IF (StatisticsMain.Vis.DateBoxCmdDDown) THEN
			UpdateDayScroller := 1;
		END_IF
		IF (StatisticsMain.Vis.DateBoxCmdYDown) THEN
			UpdateYearScroller := 1;
		END_IF
	END_IF
	
	(*Reset date*)
	IF (StatisticsMain.Vis.DateBoxCmdToday) THEN
		UpdateMonthScroller := 3; (*Update month scroller*)
		UpdateDayScroller := 3;   (*Update day scroller*)
		UpdateYearScroller := 3;  (*Update year scroller*)
		StatisticsMain.Vis.DateBoxCmdToday := FALSE;
		Today := 1;
	END_IF
	
	(*DATEBOX - MONTH SCROLLER*)
	IF  (GotTexts) THEN
	IF (UpdateMonthScroller > 0) THEN
		CASE UpdateMonthScroller OF
			1:
				ArrMonthNo[2] := ArrMonthNo[2] + 1;
				IF (ArrMonthNo[2] = 13) THEN
					ArrMonthNo[2] := 1;
				END_IF
	
			2:
				ArrMonthNo[2] := ArrMonthNo[2] - 1;
				IF (ArrMonthNo[2] = 0) THEN
					ArrMonthNo[2] := 12;
				END_IF
	
			3:
				ArrMonthNo[2] := DTStructure_0.month; (*Get current month*)
		END_CASE
		FOR i := 0 TO 4 DO
					IF i <> 2 THEN
						ArrMonthNo[i] := ArrMonthNo[2] +3 -5+i;
						IF ArrMonthNo[i] > 12 THEN
							ArrMonthNo[i] := ArrMonthNo[i] - 12;
						ELSIF ArrMonthNo[i] < 1 THEN
							ArrMonthNo[i] := ArrMonthNo[i] + 12;
						END_IF
					END_IF
			StatisticsMain.Vis.DateBoxMonthList[i] := ArrMonthList[ArrMonthNo[i]-1];
		END_FOR
		UpdateMonthScroller := 0;
		IF UpdateDayScroller <> 3 THEN
			UpdateDayScroller := 4; (*Update day/month count*)
		END_IF
	END_IF
	
	(*DATEBOX - DAY SCROLLER*)
	IF (UpdateDayScroller > 0) THEN
		CASE ArrMonthNo[2] OF
			1,3,5,7,8,10,12:
				DayLimit := 31;
			2:
	
				IF ( ((0 = ArrYearNo[2] MOD 4) AND (0 < ArrYearNo[2] MOD 100)) OR ((0 = ArrYearNo[2] MOD 4) AND (0 = ArrYearNo[2] MOD 400)) ) THEN
					DayLimit := 29;
				ELSE
					DayLimit := 28;
				END_IF
	
			4,6,9,11:
				DayLimit := 30;
	
		END_CASE
		CASE UpdateDayScroller OF
			1:
				ArrDayNo[2] := ArrDayNo[2] + 1;
				IF (ArrDayNo[2] > DayLimit) THEN
					ArrDayNo[2] := 1;
				END_IF
	
			2:
				ArrDayNo[2] := ArrDayNo[2] - 1;
				IF (ArrDayNo[2] = 0) THEN
					ArrDayNo[2] := DayLimit;
				END_IF
	
			3:
				ArrDayNo[2] := DTStructure_0.day;
	
			4:
				IF ArrDayNo[2] > DayLimit THEN
					ArrDayNo[2] := DayLimit;
				END_IF
		END_CASE
		FOR i := 0 TO 4 DO
			IF i <> 2 THEN
				ArrDayNo[i] := ArrDayNo[2] +3 -5+i;
				IF ArrDayNo[i] > DayLimit THEN
					ArrDayNo[i] := ArrDayNo[i] - DayLimit;
				ELSIF ArrDayNo[i] < 1 THEN
					ArrDayNo[i] := ArrDayNo[i] + DayLimit;
				END_IF
			END_IF
			IF ArrDayNo[i] < 10 THEN
				DaySpacer := ' 0';
			ELSE
				DaySpacer := ' ';
			END_IF
			strcpy(ADR(StatisticsMain.Vis.DateBoxDayList[i]),ADR(DaySpacer));
			itoa(ArrDayNo[i],ADR(tmpStr));
			strcat(ADR(StatisticsMain.Vis.DateBoxDayList[i]),ADR(tmpStr));
		END_FOR
		UpdateDayScroller := 0;
	END_IF
	
	(*DATEBOX - YEAR SCROLLER*)
	IF (UpdateYearScroller > 0) THEN
		CASE UpdateYearScroller OF
			1:
				ArrYearNo[2] := ArrYearNo[2] + 1;
			2:
				ArrYearNo[2] := ArrYearNo[2] - 1;
			3:
				ArrYearNo[2] := DTStructure_0.year; (*Get current year*)
		END_CASE
		FOR i := 0 TO 4 DO
			IF i <> 2 THEN
				ArrYearNo[i] := ArrYearNo[2] +3 -5+i;
			END_IF
			StatisticsMain.Vis.DateBoxYearList[i] := ' ';
			itoa(ArrYearNo[i],ADR(tmpStr));
			strcat(ADR(StatisticsMain.Vis.DateBoxYearList[i]),ADR(tmpStr));
		END_FOR
		UpdateYearScroller := 0;
		IF UpdateDayScroller <> 3 THEN
			UpdateDayScroller := 4; (*Update day/month count*)
		END_IF
	END_IF
	END_IF
	(*Open DateBox*)
	IF (StatisticsMain.Vis.MainCmdDate) THEN
		StatisticsMain.Vis.DateBoxShow := 0;
		StatisticsMain.Vis.MainCmdDate := FALSE;
	END_IF
	
	(*Close DateBox*)
	IF (StatisticsMain.Vis.DateBoxCmdEnter) THEN
		StatisticsMain.Vis.DateBoxShow := 1;
		StatisticsMain.Vis.DateBoxCmdEnter := FALSE;
		UpdateRequestDate := TRUE;
		GenStatisticsTotal := TRUE;
	END_IF
	(**)
	(*~datebox*)
	
	(*Get Current stat date string*)
	IF (UpdateRequestDate AND GotTexts) THEN
		strcpy(ADR(SearchDateString),ADR(''));
		itoa(ArrYearNo[2],ADR(tmpStr));
		strcat(ADR(SearchDateString),ADR(tmpStr));
		strcat(ADR(SearchDateString),ADR(' '));
		strcat(ADR(SearchDateString),ADR(ArrMonthList[ArrMonthNo[2]-1]));
		strcat(ADR(SearchDateString),ADR(' '));
		itoa(ArrDayNo[2],ADR(tmpStr));
		strcat(ADR(SearchDateString),ADR(tmpStr));
		StatisticsMain.Vis.MainDateText := SearchDateString;
		(*Set filename here:*)
		IF (Today) THEN
			FilenameTest := CurrentfName;
		ELSE
			FilenameTest := '';
			itoa(ArrYearNo[2],ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR('-'));
			itoa(ArrMonthNo[2],ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR('-'));
			itoa(ArrDayNo[2],ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR(tmpStr));
			strcat(ADR(FilenameTest),ADR('_'));
			strcat(ADR(FilenameTest),ADR(fName));
		END_IF
		Today := FALSE;
		UpdateRequestDate := FALSE;
	END_IF
	
	(*Clean up memory start, should make this recursive!!!*)
	IF (CleanMemory) THEN
		CleanMemory := FALSE;
		CustomerAdr := 0;
		StatisticsMain.CustomerCount := 0; (*Reset customer counts*)
		memset(ADR(StatisticsMain.Counters), 0, SIZEOF(StatisticsMain.Counters));
		memset(ADR(StatisticsMain.Vis.Counters), 0, SIZEOF(StatisticsMain.Vis.Counters));
		StatisticsMain.Vis.MainCustomerText := '';
		StatisticsMain.Vis.UnlockArticleSelect := 1;
		StatisticsMain.Vis.UnlockCustomerSelect := 1;
		StatisticsMain.Vis.UnlockBatchSelect := 1;
		StatisticsMain.Vis.MainArticleText := '';
		StatisticsMain.Vis.MainSubArticleText := '';
	
		(*Clear shift memory*)
		IF (AdrFistShift > 0) THEN
			ShiftSearchAdr := AdrFistShift;
			RunSearch := TRUE;
			WHILE (RunSearch) DO
				pDynShift ACCESS ShiftSearchAdr;
				ShiftSearchAdr := pDynShift.pNext;
				IF (ShiftSearchAdr = 0) THEN
					(*END, check for articles*)
					RunSearch := FALSE;
				END_IF
				AdrFistShift := ADR(pDynShift);
				AsMemPartFree_0(enable:=1, ident:=LoadBuffer, mem:=AdrFistShift); (*SubArticle deleted from memory*)
			END_WHILE
			AdrFistShift := 0;
		END_IF
	
		IF (StatisticsMain.pFirstCustomer > 0) THEN
			(*Search down customers*)
			SearchAdr := StatisticsMain.pFirstCustomer;
			RunSearch := TRUE;
			WHILE (RunSearch = TRUE) DO
				pStatisticsDynCustomer ACCESS SearchAdr;
				SearchAdr := pStatisticsDynCustomer.pNext;
				IF (SearchAdr = 0) THEN
					(*END, check for articles*)
					RunSearch := FALSE;
				END_IF
				MemIdent := ADR(pStatisticsDynCustomer);
				SubMemIdent := pStatisticsDynCustomer.pFirstSub;
				AsMemPartFree_0(enable:=1, ident:=LoadBuffer, mem:=MemIdent); (*Customer deleted from memory*)
				IF (SubMemIdent > 0) THEN
					SubSearchAdr := SubMemIdent;
					RunSubSearch := TRUE;
					WHILE (RunSubSearch) DO
						pStatisticsDynArticle ACCESS SubSearchAdr;
						SubSearchAdr := pStatisticsDynArticle.pNext;
						IF (SubSearchAdr = 0) THEN
							(*END, check for articles*)
							RunSubSearch := FALSE;
						END_IF
						SubMemIdent := ADR(pStatisticsDynArticle);
						SubSubMemIdent := pStatisticsDynArticle.pFirstSub;
						AsMemPartFree_0(enable:=1, ident:=LoadBuffer, mem:=SubMemIdent); (*Article deleted from memory*)
						IF (SubSubMemIdent > 0) THEN
							SubSubSearchAdr := SubSubMemIdent;
							RunSubSubSearch := TRUE;
							WHILE (RunSubSubSearch) DO
								pStatisticsDynSubArticle ACCESS SubSubSearchAdr;
								SubSubSearchAdr := pStatisticsDynSubArticle.pNext;
								IF (SubSubSearchAdr = 0) THEN
									(*END, check for articles*)
									RunSubSubSearch := FALSE;
								END_IF
								SubSubMemIdent := ADR(pStatisticsDynSubArticle);
								AsMemPartFree_0(enable:=1, ident:=LoadBuffer, mem:=SubSubMemIdent); (*SubArticle deleted from memory*)
							END_WHILE
						END_IF
					END_WHILE
				END_IF
				(*Delete customer*)
			END_WHILE
		END_IF
		StatisticsMain.pFirstCustomer := 0;
	END_IF
	(*Clean up memory done*)
	
	(*All customers total*)
	IF (UpdateTotals) THEN
		CASE StatisticsMain.ListMode OF
			0:
				StatisticsMain.Vis.Counters := StatisticsMain.Counters;
			1:
				StatisticsMain.Vis.Counters := pStatisticsDynCustomer.Counters;
			2:
				StatisticsMain.Vis.Counters := pStatisticsDynArticle.Counters;
			3:
				StatisticsMain.Vis.Counters := pStatisticsDynSubArticle.Counters;
			5:
				StatisticsMain.Vis.Counters := pDynShift.Counters;
		END_CASE
		UpdateTotals := FALSE;
	END_IF
	
	(*Scroll logic*)
	IF (GetVisCustomerList) THEN
		IF StatisticsMain.ListMode <> 1 THEN
			StatisticsMain.ListMode := 1;
			SubUpdateScroller := TRUE;
			pCurrentTopCustomer := StatisticsMain.pFirstCustomer;
			CustomerAdr := 0 (*Reset article choice?*);
		ELSE
			StatisticsMain.Vis.ScrollBoxShow := 0;
		END_IF
		GetVisCustomerList := FALSE;
	END_IF
	
	IF (GetVisArticleList) THEN
		IF StatisticsMain.ListMode <> 2 THEN
			StatisticsMain.ListMode := 2;
			SubUpdateScroller := TRUE;
			IF CustomerAdr = 0 THEN
				CustomerAdr := pStatisticsDynCustomer.pFirstSub;
			END_IF
			pCurrentTopCustomer := CustomerAdr;
		ELSE
			StatisticsMain.Vis.ScrollBoxShow := 0;
		END_IF
		GetVisArticleList := FALSE;
	END_IF
	
	IF (GetVisSubArticleList) THEN
		IF StatisticsMain.ListMode <> 3 THEN
			StatisticsMain.ListMode := 3;
			SubUpdateScroller := TRUE;
			pCurrentTopCustomer := pStatisticsDynArticle.pFirstSub;
		ELSE
			StatisticsMain.Vis.ScrollBoxShow := 0;
		END_IF
		GetVisSubArticleList := FALSE;
	END_IF
	
	IF (GetVisShiftList) THEN
		IF StatisticsMain.ListMode <> 5 THEN
			StatisticsMain.ListMode := 5;
			SubUpdateScroller := TRUE;
			pCurrentTopCustomer := AdrFistShift;
		ELSE
			StatisticsMain.Vis.ScrollBoxShow := 0;
		END_IF
		GetVisShiftList := FALSE;
	END_IF
	
	
	
	IF (SubUpdateScroller) THEN
		UpdateSroller := TRUE;
		StatisticsMain.Vis.ScrollBoxDataPoint := 0;
		SubUpdateScroller := FALSE;
	END_IF
	
	IF ( UpdateSroller AND (StatisticsMain.CustomerCount > 0 OR StatisticsMain.ListMode = 4 OR StatisticsMain.ListMode = 5) AND pCurrentTopCustomer > 0) THEN
		Cnt := 0;
		pDynItemAddr := pCurrentTopCustomer;
		FOR	Cnt := 0 TO SIZEOF(StatisticsMain.Vis.ScrollBoxList) / SIZEOF(StatisticsMain.Vis.ScrollBoxList[0]) - 1 DO
			IF (pDynItemAddr > 0) THEN
				IF (Cnt = 0) THEN
					DynTopAdr := pDynItemAddr;
				END_IF
				pDynItem ACCESS pDynItemAddr;
				LookupList[Cnt] := pDynItemAddr; (*Cache for speed*)
				pDynItemAddr := pDynItem.pNext;
				StatisticsMain.Vis.ScrollBoxList[Cnt] := pDynItem.Name;
				strcat(ADR(StatisticsMain.Vis.ScrollBoxList[Cnt]),ADR(' '));
			ELSE
				LookupList[Cnt] := 0; (*Cache for speed*)
				StatisticsMain.Vis.ScrollBoxList[Cnt] := '';
			END_IF
		END_FOR
		StatisticsMain.Vis.ScrollBoxShow := 0;
		UpdateSroller := FALSE;
	END_IF
	
	Scroll_0( In := StatisticsMain.Vis.ScrollBoxCmdUp );
	Scroll_1( In := StatisticsMain.Vis.ScrollBoxCmdDown );
	
	(*Skal kunne genbruges - og det blev den*)
	IF (Scroll_0.Out) THEN
		IF ( (StatisticsMain.pFirstCustomer <> DynTopAdr AND StatisticsMain.Vis.ScrollBoxDataPoint = 0) OR StatisticsMain.Vis.ScrollBoxDataPoint > 0) THEN (*Don't scroll below, we will get an ugly empty list*)
			IF (StatisticsMain.Vis.ScrollBoxDataPoint = 0) THEN
				CustomerListScrollDirection := 2;
				ScrollCustomerList := TRUE;
			ELSE
				StatisticsMain.Vis.ScrollBoxDataPoint := StatisticsMain.Vis.ScrollBoxDataPoint - 1;
			END_IF
		END_IF
	END_IF
	
	IF (Scroll_1.Out) THEN
		//IF LookupList[StatisticsMain.Vis.ScrollBoxDataPoint] > 0 THEN
			pDynItem ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
			IF ( pDynItem.pNext > 0) THEN (*Don't scroll below, we will get an ugly empty list*)
				IF (StatisticsMain.Vis.ScrollBoxDataPoint = StatisticsMain.Vis.ScrollBoxMaxIndex) THEN
					CustomerListScrollDirection := 1;
					ScrollCustomerList := TRUE;
				ELSE
					StatisticsMain.Vis.ScrollBoxDataPoint := StatisticsMain.Vis.ScrollBoxDataPoint + 1;
				END_IF
			END_IF
		//END_IF
	END_IF
	
	IF (ScrollCustomerList AND NOT GetVisCustomerList) THEN
		ScrollCustomerList := FALSE;
	
		IF (pCurrentTopCustomer > 0) THEN
			pStatisticsDynCustomer ACCESS pCurrentTopCustomer;
			CASE CustomerListScrollDirection OF
	
				1: (**Scroll down*)
					IF (pStatisticsDynCustomer.pNext > 0) THEN
						pCurrentTopCustomer := pStatisticsDynCustomer.pNext;
					END_IF
	
				2: (*Scroll up*)
					IF (pStatisticsDynCustomer.pPrev > 0) THEN
						pCurrentTopCustomer := pStatisticsDynCustomer.pPrev;
					END_IF
			END_CASE
			UpdateSroller := TRUE;
		END_IF
	END_IF
	
	(*scroll logic end*)
	
	(*Input from vis*)
	(*Close select window*)
	IF (StatisticsMain.Vis.ScrollBoxCmdClose) THEN
		StatisticsMain.Vis.ScrollBoxShow := 1;
		StatisticsMain.Vis.ScrollBoxCmdClose := FALSE;
		IF StatisticsMain.ListMode = 4 THEN
			UpdateDynamicOption := 3;
		END_IF
		StatisticsMain.ListMode := IDLE;
	END_IF
	(*Activate Customer select*)
	IF (StatisticsMain.Vis.MainCmdCustomer) THEN
		GetVisCustomerList := TRUE;
		StatisticsMain.Vis.MainCmdCustomer := 0;
		StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[12]; (*Hent text fra textgroup*)
	END_IF
	(*Activate Article select*)
	IF (StatisticsMain.Vis.MainCmdArticle) THEN
		GetVisArticleList := TRUE;
		StatisticsMain.Vis.MainCmdArticle := 0;
		IF StatisticsMain.Vis.ShowArticle = 1 THEN
			StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[13]; (*Hent text fra textgroup*)
		ELSE
			StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[17]; (*Hent text fra textgroup*)
		END_IF
	END_IF
	(*Activate SubArticle select*)
	IF (StatisticsMain.Vis.MainCmdSubArticle) THEN
		GetVisSubArticleList := TRUE;
		StatisticsMain.Vis.MainCmdSubArticle := 0;
		StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[14]; (*Hent text fra textgroup*)
	END_IF
	
	IF (ShowShifts) THEN
		GetVisShiftList := TRUE;
		StatisticsMain.Vis.ScrollBoxAllText := ArrTexts[19];
		ShowShifts := FALSE;
	END_IF
	
	IF (StatisticsMain.Vis.ScrollBoxCmdEnter) THEN
		CASE StatisticsMain.ListMode OF
			1:
				pStatisticsDynCustomer ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
				StatisticsMain.Vis.MainCustomerText := pStatisticsDynCustomer.Name;
				StatisticsMain.Vis.MainSubArticleText := ArrTexts[14];
				StatisticsMain.Vis.MainArticleText := '';
				IF StatisticsMain.Vis.ShowArticle = 1 THEN
					StatisticsMain.Vis.MainArticleText := ArrTexts[13]; (*Hent text fra textgroup*)
				ELSE
					StatisticsMain.Vis.MainArticleText := ArrTexts[17];
				END_IF
				StatisticsMain.Vis.UnlockArticleSelect := 0;
				StatisticsMain.Vis.UnlockBatchSelect := 1;
			2:
				pStatisticsDynArticle ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
				StatisticsMain.Vis.MainArticleText := pStatisticsDynArticle.Name;
				StatisticsMain.Vis.MainSubArticleText := ArrTexts[14]; (*Hent text fra textgroup*)
				StatisticsMain.Vis.UnlockBatchSelect := 0;
			3:
				pStatisticsDynSubArticle ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
				StatisticsMain.Vis.MainSubArticleText := pStatisticsDynSubArticle.Name;
	
			4:
				pStatisticsDynOption ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
				UpdateDynamicOption := 1;
	
			5:
				pDynShift ACCESS LookupList[StatisticsMain.Vis.ScrollBoxDataPoint];
		END_CASE
		UpdateTotals := TRUE;
		StatisticsMain.Vis.ScrollBoxCmdEnter := FALSE;
		StatisticsMain.Vis.ScrollBoxShow := 1;
	END_IF
	
	IF (StatisticsMain.Vis.ScrollBoxCmdAll) THEN
		CASE StatisticsMain.ListMode OF
		1:
			IF (StatisticsMain.CustomerCount > 1) THEN (*Support for 1 customer fast access and no Cust Art*)
				StatisticsMain.ListMode := 0;
				StatisticsMain.Vis.MainCustomerText := ArrTexts[12];
				StatisticsMain.Vis.UnlockCustomerSelect := 0;
				StatisticsMain.Vis.UnlockArticleSelect := 1;
				StatisticsMain.Vis.UnlockBatchSelect := 1;
				StatisticsMain.Vis.MainSubArticleText := ArrTexts[14];
				StatisticsMain.Vis.MainArticleText := ArrTexts[13];
			ELSE
				StatisticsMain.Vis.MainSubArticleText := ArrTexts[14];
			END_IF
		2:
			StatisticsMain.ListMode := 1;
			StatisticsMain.Vis.MainArticleText := StatisticsMain.Vis.ScrollBoxAllText;
			StatisticsMain.Vis.UnlockBatchSelect := 1;
			StatisticsMain.Vis.MainSubArticleText := ArrTexts[14];
		3:
			StatisticsMain.ListMode := 2;
			StatisticsMain.Vis.MainSubArticleText := StatisticsMain.Vis.ScrollBoxAllText;
		4:
			UpdateDynamicOption := 2;
		5:
			pDynShift ACCESS AdrFistShift;
		END_CASE
	
		UpdateTotals := TRUE;
		StatisticsMain.Vis.ScrollBoxCmdAll := FALSE;
		StatisticsMain.Vis.ScrollBoxShow := 1;
	END_IF
	
	IF g_Core.Services.Statistics.Interface.isDeleteOldFiles THEN (*Delete old files*)
		FOR ServerNo := 1 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
			CASE ScanState OF
				(*Read Statistics dir info*)
				0:
					IF (g_Core.Services.Statistics.Interface.DeleteStatsAfterNoDays = 0) THEN
						FOR No := 0 TO 9 DO
							IncreseShifIndex[ServerNo-1].LoadID[No] := TRUE;
						END_FOR
						DeleteLoadID := GetData(ServerNo := ServerNo, Type:= LOADID, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
						
						FOR i := 0 TO UDINT_TO_USINT(NumberOfProductionUnits) - 1 DO // NEW MULTI RCP
							g_Core.Services.CAR.Interface.No[0].isCmdIncrementLoadID := TRUE;
						END_FOR // NEW MULTI RCP
						ScanState := 101;
					ELSE
						ScanState := 102;
					END_IF
	
				101:
					IF DeleteLoadID < GetData(ServerNo := ServerNo, Type:= LOADID, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server)) THEN (*Reset of permstat done*)
						ScanState := 102;
					END_IF
	
				102:
					MemoryUsage := 0;
					ScanState := 1;
	
				1:
					DirInfo_0(enable:=1, pDevice:= ADR(fDevice), pPath:=ADR(fDir[ServerNo-1]));
					CASE DirInfo_0.status OF
						65535: (*Still working*)
						;
	
						0: (*Got dir info*)
							ScanState := 2;
	
					ELSE (*Error*)
						ScanState := 100;
					END_CASE
				(*Check each file*)
				2:
				IF FileNo < DirInfo_0.filenum THEN
					CASE FileScanState OF
						0: (*Read Dir?*)
							FileScanState := 1;
						1:
							DirRead_0(enable:=1, pDevice:=ADR(fDevice), pPath:=ADR(fDir[ServerNo-1]), entry:=FileNo, option:=fiFILE, pData:=ADR(ScanFileName), data_len:=SIZEOF(ScanFileName));
							CASE DirRead_0.status OF
								65535: (*Still working*)
									;
	
								0: (*Got dir info*)
									FileScanState := 2;
	
								ELSE (*Error*)
									ScanState := 101;
							END_CASE
						2: (*Do some magic!!!*)
							(*Day*)
							dChar ACCESS ADR(ScanFileName.Filename);
		            		FOR SubStep := 0 TO 2 DO
	
								StartAdr := ADR(dChar);
								WHILE (dChar <> 45 AND dChar <> 95) DO
									dChar ACCESS ADR(dChar)+1;
								END_WHILE
								memset(ADR(TmpString),0,SIZEOF(TmpString));
								memcpy(ADR(TmpString), StartAdr, ADR(dChar) - StartAdr);
								CASE SubStep OF
									0:  (*Get Year*)
										DTStructure_2.year := DINT_TO_UINT(atoi(ADR(TmpString)));
									1:  (*Get Month*)
										DTStructure_2.month := DINT_TO_USINT(atoi(ADR(TmpString)));
									2:	(*Get Day*)
										DTStructure_2.day := DINT_TO_USINT(atoi(ADR(TmpString)));
								END_CASE
								dChar ACCESS ADR(dChar)+1;
							END_FOR
	
							FileDT := DTStructure_TO_DT(ADR(DTStructure_2));
							FileScanState := 3;
	
						3:
							FileTimeDiff := DiffDT(g_Core.Services.Time.Runtime.Date_Time,FileDT);
							IF FileTimeDiff > 0 THEN (*86400 sec pr day*)
								IF UDINT_TO_REAL(FileTimeDiff) / UDINT_TO_REAL(86400) > UDINT_TO_REAL(g_Core.Services.Statistics.Interface.DeleteStatsAfterNoDays) THEN
									FileScanState := 4;
								ELSE
									FileScanState := 5;
								END_IF
							ELSE
								FileScanState := 5;
							END_IF
	
						4: (*Delete file*)
							CASE FileDeleteState OF
								0: (*Delete file?*)
									(*Make filename string*)
									FileDeleteName := fDir[ServerNo-1];
									strcat(ADR(FileDeleteName),ADR(ScanFileName.Filename));
									FileDeleteState := 1;
								1:
									FileDelete_0(enable:=1, pDevice:=ADR(fDevice), pName:=ADR(FileDeleteName));
									CASE FileDelete_0.status OF
										65535: (*Still working*)
											;
	
										0: (*Got dir info*)
											FileDeleteState := 2;
	
										ELSE (*Error*)
											ScanState := 102;
									END_CASE
								2:
									FileDeleteState := 0;
									FileScanState := 0;
									FileNo := 0;
									ScanState := 0;
							END_CASE
	
						5:
							MemoryUsage := MemoryUsage + ScanFileName.Filelength;
							FileScanState := 6;
						6:
							FileNo := FileNo + 1;
							FileScanState := 0;
	
	
					END_CASE
				ELSE (*All files scanned*)
					FileScanState := 0;
					FileNo := 0;
					ScanState := 0;
					g_Core.Services.Statistics.Interface.isDeleteOldFiles := FALSE;
					g_Core.Services.Statistics.Interface.DeleteStatsAfterNoDays := 365;
				END_IF
			END_CASE
		END_FOR
	END_IF
	(*Stat file handling*)
	IF (FlatVarHandler_0.Status = 1) THEN
	
		(*Read the total*)
		IF (GenStatisticsTotal AND NOT ReadTestFile = 1 AND NOT GenTestFile = 1) THEN
			CASE StatisticsTotalStep OF
			0:
				ReadTestFile := 1;
				StatisticsTotalStep := 1;
				CleanMemory := 1;
				(*Shifts*)
				MaxShiftIndex := 0;
				DynShiftNext := 0;
				ShiftsLoaded := 0;
				ShiftFirstRunned := 0;
				ShiftsAvailable := 1;
			1:
				IF NOT ReadTestFile THEN
					IF FlatVar.FileDataLines > 0 AND BufferAdr > 0 THEN
						StatisticsMain.Vis.ShowAll := 1;
						FileDataLines := FlatVar.FileDataLines;
						FOR xLines := 0 TO FlatVar.FileDataLines - 1 DO
	
							Offset := Offsetter * xLines; (*Get correct offset*)
							BufferDataType ACCESS BufferAdr+Offset; (*Access correct offset*)
							(*Nyt*)
							(*Shifts*)
							IF (NOT ShiftLoadError AND g_Core.Services.Statistics.Interface.StatShowShift) THEN
								IF MaxShiftIndex <> BufferDataType.ShiftIndex THEN
									MaxShiftIndex := BufferDataType.ShiftIndex;
									ShiftsLoaded := ShiftsLoaded + 1;
									IF ShiftsLoaded > 1 THEN
										ShiftsAvailable := 0;
									END_IF
									ShiftFirstRunned := FALSE;
								END_IF
								IF NOT ShiftFirstRunned THEN
									AsMemPartAlloc_0(enable:=1, ident:=LoadBuffer, len:=SIZEOF(pDynShift));
									IF (AsMemPartAlloc_0.status = 0) THEN (*Mem allocated ok*)
										IF (DynShiftNext) THEN
											pDynShift.pNext := AsMemPartAlloc_0.mem;
										ELSE
											DynShiftNext := TRUE;
											AdrFistShift := AsMemPartAlloc_0.mem;
										END_IF
										pDynShift ACCESS AsMemPartAlloc_0.mem;
										pDynShift.No 	:= ShiftsLoaded;
										pDynShift.SubNo := MaxShiftIndex;
										DynStartTime	:= BufferDataType.TimeStart;
	
										ShiftFirstRunned:= TRUE;
									ELSE
										ShiftLoadError := TRUE;
									END_IF
								END_IF
								IF (NOT ShiftLoadError) THEN
									pDynShift.Counters.TimeInSec 	:= pDynShift.Counters.TimeInSec 	+ BufferDataType.TimeInSec;
								    pDynShift.Counters.Production[BufferDataType.PU-1] 		:= pDynShift.Counters.Production[BufferDataType.Production-1] + BufferDataType.Production; // NEW MULTI RCP
									pDynShift.Counters.Total 		:= pDynShift.Counters.Total 		+ BufferDataType.Production;
									pDynShift.Counters.SortA 		:= pDynShift.Counters.SortA 		+ BufferDataType.SortA;
									pDynShift.Counters.SortB 		:= pDynShift.Counters.SortB 		+ BufferDataType.SortB;
									pDynShift.Counters.Drop 		:= pDynShift.Counters.Drop 			+ BufferDataType.Drop;
									pDynShift.Counters.Quality 		:= pDynShift.Counters.Quality 		+ BufferDataType.Quality;
									pDynShift.Counters.OverSize 	:= pDynShift.Counters.OverSize 		+ BufferDataType.OverSize;
									pDynShift.Counters.TooClose 	:= pDynShift.Counters.TooClose 		+ BufferDataType.TooClose;
									pDynShift.Counters.PreProduction:= pDynShift.Counters.PreProduction + BufferDataType.PreProduction;
									pDynShift.Counters.Option1		:= pDynShift.Counters.Option1 		+ BufferDataType.Option1;
									pDynShift.Counters.Option2		:= pDynShift.Counters.Option2 		+ BufferDataType.Option2;
									pDynShift.Counters.Option3		:= pDynShift.Counters.Option3 		+ BufferDataType.Option3;
									pDynShift.Counters.Flow1		:= pDynShift.Counters.Flow1 		+ BufferDataType.Flow1;
									pDynShift.Counters.Flow2		:= pDynShift.Counters.Flow2 		+ BufferDataType.Flow2;
									pDynShift.Counters.Flow3		:= pDynShift.Counters.Flow3 		+ BufferDataType.Flow3;
									
									ConvIntToAscii(11, ADR(StartString), SIZEOF(StartString), ADR(DynStartTime));
									ConvIntToAscii(11, ADR(StopString), SIZEOF(StopString), ADR(BufferDataType.TimeStop));
									itoa(pDynShift.No,ADR(tmpString2));
									strcat(ADR(tmpString2),ADR(': '));
									memset(ADR(tmpString), 0, SIZEOF(tmpString));
									memcpy(ADR(tmpString),ADR(StartString)+11,5);
									strcat(ADR(tmpString), ADR(' -  '));
									memcpy(ADR(tmpString)+8, ADR(StopString)+11,5);
									pDynShift.Name := tmpString2;
									strcat(ADR(pDynShift.Name),ADR(tmpString));
								END_IF
							END_IF
	
							(*Support NON Cust/Art files*)
							IF (strlen(ADR(BufferDataType.CustomerName)) = 0) THEN
								BufferDataType.CustomerName		:= ArrTexts[16];
								BufferDataType.ArticleName 		:= BufferDataType.RecipeName;
								BufferDataType.CustomerNumber 		:= 1;
								BufferDataType.ArticleNumber 		:= BufferDataType.RecipeNumber;
								(*StatisticsMain.Vis.ShowCustomer	:= 0;*)
								StatisticsMain.Vis.ShowArticle 	:= 0;
							ELSE
								StatisticsMain.Vis.ShowArticle	:= 1;
								StatisticsMain.Vis.ShowCustomer	:= 1;
							END_IF
							StatisticsMain.Counters.TimeInSec	:= StatisticsMain.Counters.TimeInSec 		+ BufferDataType.TimeInSec;
							StatisticsMain.Counters.Production[BufferDataType.PU-1] 		:= StatisticsMain.Counters.Production[BufferDataType.PU-1] + BufferDataType.Production;  // NEW MULTI RCP
							StatisticsMain.Counters.Total		:= StatisticsMain.Counters.Total 			+ BufferDataType.Production;
							StatisticsMain.Counters.SortA		:= StatisticsMain.Counters.SortA 			+ BufferDataType.SortA;
							StatisticsMain.Counters.SortB		:= StatisticsMain.Counters.SortB 			+ BufferDataType.SortB;
							StatisticsMain.Counters.Drop		:= StatisticsMain.Counters.Drop 			+ BufferDataType.Drop;
							StatisticsMain.Counters.Quality		:= StatisticsMain.Counters.Quality 			+ BufferDataType.Quality;
							StatisticsMain.Counters.OverSize	:= StatisticsMain.Counters.OverSize 		+ BufferDataType.OverSize;
							StatisticsMain.Counters.TooClose	:= StatisticsMain.Counters.TooClose 		+ BufferDataType.TooClose;
						    StatisticsMain.Counters.PreProduction:= StatisticsMain.Counters.PreProduction 	+ BufferDataType.PreProduction;
							StatisticsMain.Counters.Option1		:= StatisticsMain.Counters.Option1 			+ BufferDataType.Option1;
							StatisticsMain.Counters.Option2		:= StatisticsMain.Counters.Option2 			+ BufferDataType.Option2;
							StatisticsMain.Counters.Option3		:= StatisticsMain.Counters.Option3 			+ BufferDataType.Option3;
							StatisticsMain.Counters.Flow1		:= StatisticsMain.Counters.Flow1 			+ BufferDataType.Flow1;
							StatisticsMain.Counters.Flow2		:= StatisticsMain.Counters.Flow2 			+ BufferDataType.Flow2;
							StatisticsMain.Counters.Flow3		:= StatisticsMain.Counters.Flow3 			+ BufferDataType.Flow3;
							(*Customer handler*)
							IF StatisticsMain.pFirstCustomer = 0 THEN (*Tjekker om der findes kunder*)
								AddCustomerToList := TRUE; (*Tilf?j kunde*)
							ELSE (*Der findes kunder, s?g om denne kunde findes i forvejen*)
								pCustomerAddr := StatisticsMain.pFirstCustomer;
								RunSearch := TRUE; (*S?g efter kunde*)
								WHILE (RunSearch = TRUE) DO
								(*search*)
									pStatisticsDynCustomer ACCESS pCustomerAddr;
									IF BufferDataType.CustomerNumber = pStatisticsDynCustomer.No THEN (*Kunde fundet*)
										RunSearch := FALSE; (*stop s?gning*)
										UpdateCustomerCounters := TRUE;
									ELSIF (pStatisticsDynCustomer.pNext = 0) THEN (*Enden er n?et og kunden er ikke fundet*)
										RunSearch := FALSE; (*Stop s?gning*)
										AddCustomerToList := TRUE; (*Tilf?j kunde*)
									ELSE
										pCustomerAddr := pStatisticsDynCustomer.pNext; (*S?tter pointer til n?ste kunde i listen*)
									END_IF
								END_WHILE
							END_IF
							IF (AddCustomerToList = TRUE) THEN (*Opretter en ny kunde i listen*)
								StatisticsMain.CustomerCount := StatisticsMain.CustomerCount + 1; (*Kundet?ller*)
								AddCustomerToList := FALSE; (*Nulstil tilf?j kunde kommando*)
								AsMemPartAlloc_0(enable:=1, ident:=LoadBuffer, len:=SIZEOF(pStatisticsDynCustomer));
								IF (AsMemPartAlloc_0.status = 0) THEN (*Mem allocated ok*)
									IF StatisticsMain.pFirstCustomer = 0 THEN (*Set first customer*)
										StatisticsMain.pFirstCustomer := AsMemPartAlloc_0.mem;
									ELSE
										PrevCustomerAddr := ADR(pStatisticsDynCustomer);
										pStatisticsDynCustomer.pNext := AsMemPartAlloc_0.mem;
									END_IF
									pStatisticsDynCustomer ACCESS AsMemPartAlloc_0.mem; (*Access correct mem*)
									pStatisticsDynCustomer.pPrev := PrevCustomerAddr; (*Easy access for the scrolllist*)
									pStatisticsDynCustomer.No := BufferDataType.CustomerNumber;
									pStatisticsDynCustomer.Name := BufferDataType.CustomerName;
									(*M?ske m?ske ikke...*)
									UpdateCustomerCounters := TRUE;
								END_IF
							END_IF
	
							IF (UpdateCustomerCounters) THEN
								UpdateCustomerCounters := FALSE;
								pStatisticsDynCustomer.Counters.TimeInSec 		:= pStatisticsDynCustomer.Counters.TimeInSec 		+ BufferDataType.TimeInSec;
								pStatisticsDynCustomer.Counters.Production[BufferDataType.PU-1] := pStatisticsDynCustomer.Counters.Production[BufferDataType.PU-1] + BufferDataType.Production;
								pStatisticsDynCustomer.Counters.Total 			:= pStatisticsDynCustomer.Counters.Total 			+ BufferDataType.Production;
								pStatisticsDynCustomer.Counters.SortA 			:= pStatisticsDynCustomer.Counters.SortA 			+ BufferDataType.SortA;
								pStatisticsDynCustomer.Counters.SortB 			:= pStatisticsDynCustomer.Counters.SortB 			+ BufferDataType.SortB;
								pStatisticsDynCustomer.Counters.Drop 			:= pStatisticsDynCustomer.Counters.Drop 			+ BufferDataType.Drop;
								pStatisticsDynCustomer.Counters.Quality 		:= pStatisticsDynCustomer.Counters.Quality 			+ BufferDataType.Quality;
								pStatisticsDynCustomer.Counters.OverSize 		:= pStatisticsDynCustomer.Counters.OverSize 		+ BufferDataType.OverSize;
								pStatisticsDynCustomer.Counters.TooClose 		:= pStatisticsDynCustomer.Counters.TooClose 		+ BufferDataType.TooClose;
								pStatisticsDynCustomer.Counters.PreProduction 	:= pStatisticsDynCustomer.Counters.PreProduction 	+ BufferDataType.PreProduction;
								pStatisticsDynCustomer.Counters.Option1 		:= pStatisticsDynCustomer.Counters.Option1 			+ BufferDataType.Option1;
								pStatisticsDynCustomer.Counters.Option2 		:= pStatisticsDynCustomer.Counters.Option2			+ BufferDataType.Option2;
								pStatisticsDynCustomer.Counters.Option3 		:= pStatisticsDynCustomer.Counters.Option3 			+ BufferDataType.Option3;
								pStatisticsDynCustomer.Counters.Flow1	 		:= pStatisticsDynCustomer.Counters.Flow1 			+ BufferDataType.Flow1;
								pStatisticsDynCustomer.Counters.Flow2 			:= pStatisticsDynCustomer.Counters.Flow2 			+ BufferDataType.Flow2;
								pStatisticsDynCustomer.Counters.Flow3 			:= pStatisticsDynCustomer.Counters.Flow3 			+ BufferDataType.Flow3;
							END_IF
							(*Hvis kunden blev fundet eller oprettet pejer pStatisticsDynCustomer korrekt p? denne kunde*)
							(*Vi s?ger nu artiklerne igennem for at gruppere dem, vi opretter sub articles under dem*)
							(*Search article*)
							(*Article handler*)
	
							IF pStatisticsDynCustomer.pFirstSub = 0 THEN (*Tjekker om der findes kunder*)
								AddArtcleToCustomer := TRUE; (*Tilf?j artikel til kunde*)
							ELSE (*Der findes artikler, s?g om denne artikkel findes i forvejen*)
								pArticleAddr := pStatisticsDynCustomer.pFirstSub;
								RunSearch := TRUE; (*S?g efter Artikel*)
								WHILE (RunSearch = TRUE) DO
								(*search*)
									pStatisticsDynArticle ACCESS pArticleAddr;
									IF BufferDataType.ArticleNumber = pStatisticsDynArticle.No THEN (*Artikel fundet*)
										RunSearch := FALSE; (*stop s?gning*)
										UpdateArticleCounters := TRUE;
									ELSIF (pStatisticsDynArticle.pNext = 0) THEN (*Enden er n?et og artiklen er ikke fundet*)
										RunSearch := FALSE; (*Stop s?gning*)
										AddArtcleToCustomer := TRUE; (*Tilf?j artikel*)
									ELSE
										pArticleAddr := pStatisticsDynArticle.pNext; (*S?tter pointer til n?ste artikel i listen*)
									END_IF
								END_WHILE
							END_IF
	
							IF (AddArtcleToCustomer) THEN
								AddArtcleToCustomer := FALSE;
								pStatisticsDynCustomer.SubCount := pStatisticsDynCustomer.SubCount + 1; (*Kunde/Artikkel t?ller*)
								AsMemPartAlloc_0(enable:=1, ident:=LoadBuffer, len:=SIZEOF(pStatisticsDynArticle));
								IF (AsMemPartAlloc_0.status = 0) THEN (*Mem allocated ok*)
									IF (pStatisticsDynCustomer.pFirstSub = 0) THEN
										pStatisticsDynCustomer.pFirstSub := AsMemPartAlloc_0.mem;
										PrevArticleAddr := 0;
									ELSE
										PrevArticleAddr := ADR(pStatisticsDynArticle);
										pStatisticsDynArticle.pNext := AsMemPartAlloc_0.mem;
									END_IF
	
									pStatisticsDynArticle ACCESS AsMemPartAlloc_0.mem;
									(*Fill in data for article*)
									pStatisticsDynArticle.pPrev		:= PrevArticleAddr;
									pStatisticsDynArticle.No		:= BufferDataType.ArticleNumber;
									pStatisticsDynArticle.Name		:= BufferDataType.ArticleName;
									pStatisticsDynArticle.SubNo		:= BufferDataType.RecipeNumber;
									pStatisticsDynArticle.SubName	:= BufferDataType.RecipeName;
									UpdateArticleCounters := TRUE;
								END_IF
							END_IF
	
							IF (UpdateArticleCounters) THEN
								UpdateArticleCounters := FALSE;
								pStatisticsDynArticle.Counters.TimeInSec	:= pStatisticsDynArticle.Counters.TimeInSec 	+ BufferDataType.TimeInSec;
								pStatisticsDynArticle.Counters.Production[BufferDataType.PU-1]		:= pStatisticsDynArticle.Counters.Production[BufferDataType.PU-1] + BufferDataType.Production;
								pStatisticsDynArticle.Counters.Total		:= pStatisticsDynArticle.Counters.Total 		+ BufferDataType.Production;
								pStatisticsDynArticle.Counters.SortA		:= pStatisticsDynArticle.Counters.SortA 		+ BufferDataType.SortA;
								pStatisticsDynArticle.Counters.SortB		:= pStatisticsDynArticle.Counters.SortB 		+ BufferDataType.SortB;
								pStatisticsDynArticle.Counters.Drop			:= pStatisticsDynArticle.Counters.Drop 			+ BufferDataType.Drop;
								pStatisticsDynArticle.Counters.Quality		:= pStatisticsDynArticle.Counters.Quality 		+ BufferDataType.Quality;
								pStatisticsDynArticle.Counters.OverSize		:= pStatisticsDynArticle.Counters.OverSize 		+ BufferDataType.OverSize;
								pStatisticsDynArticle.Counters.TooClose		:= pStatisticsDynArticle.Counters.TooClose 		+ BufferDataType.TooClose;
								pStatisticsDynArticle.Counters.PreProduction:= pStatisticsDynArticle.Counters.PreProduction + BufferDataType.PreProduction;
								pStatisticsDynArticle.Counters.Option1		:= pStatisticsDynArticle.Counters.Option1 		+ BufferDataType.Option1;
								pStatisticsDynArticle.Counters.Option2		:= pStatisticsDynArticle.Counters.Option2 		+ BufferDataType.Option2;
								pStatisticsDynArticle.Counters.Option3		:= pStatisticsDynArticle.Counters.Option3 		+ BufferDataType.Option3;
								pStatisticsDynArticle.Counters.Flow1		:= pStatisticsDynArticle.Counters.Flow1 		+ BufferDataType.Flow1;
								pStatisticsDynArticle.Counters.Flow2		:= pStatisticsDynArticle.Counters.Flow2 		+ BufferDataType.Flow2;
								pStatisticsDynArticle.Counters.Flow3		:= pStatisticsDynArticle.Counters.Flow3 		+ BufferDataType.Flow3;
								AddSubToArticle := TRUE;
							END_IF
	
							IF (AddSubToArticle) THEN
								AddSubToArticle := FALSE;
	
								IF pStatisticsDynArticle.pFirstSub = 0 THEN (*Tjekker om der findes subarticles*)
									AddSubArtcleToArticle := TRUE; (*Tilf?j subartikel til artiklen*)
								ELSE (*Der findes Sub artikler, Find den sidste*)
									pSubArticleAddr := pStatisticsDynArticle.pFirstSub;
									RunSearch := TRUE; (*S?g efter Artikel*)
									WHILE (RunSearch = TRUE) DO
										(*search*)
										pStatisticsDynSubArticle ACCESS pSubArticleAddr;
										IF pStatisticsDynSubArticle.pNext = 0 THEN (*Sidste fundet*)
											RunSearch := FALSE; (*stop s?gning*)
											AddSubArtcleToArticle := TRUE;
										ELSE
											pSubArticleAddr := pStatisticsDynSubArticle.pNext; (*S?tter pointer til n?ste artikel i listen*)
										END_IF
									END_WHILE
								END_IF
							END_IF
	
							IF (AddSubArtcleToArticle) THEN
								AddSubArtcleToArticle := FALSE;
								pStatisticsDynArticle.SubCount := pStatisticsDynArticle.SubCount + 1; (*Kunde/Artikkel t?ller*)
								AsMemPartAlloc_0(enable:=1, ident:=LoadBuffer, len:=SIZEOF(pStatisticsDynSubArticle));
								IF (AsMemPartAlloc_0.status = 0) THEN (*Mem allocated ok*)
									IF (pStatisticsDynArticle.pFirstSub = 0) THEN
										pStatisticsDynArticle.pFirstSub := AsMemPartAlloc_0.mem;
										PrevSubArticleAddr := 0;
									ELSE
										PrevSubArticleAddr := ADR(pStatisticsDynSubArticle);
										pStatisticsDynSubArticle.pNext := AsMemPartAlloc_0.mem;
									END_IF
	
									pStatisticsDynSubArticle ACCESS AsMemPartAlloc_0.mem;
									(*Fill in data for article*)
									pStatisticsDynSubArticle.pPrev	:= PrevSubArticleAddr;
									pStatisticsDynSubArticle.No		:= BufferDataType.ArticleNumber;
									
									ConvIntToAscii(11, ADR(StartString), SIZEOF(StartString), ADR(BufferDataType.TimeStart));
									ConvIntToAscii(11, ADR(StopString),	 SIZEOF(StopString),  ADR(BufferDataType.TimeStop));
									
									memset(ADR(tmpString), 		0, 					SIZEOF(tmpString)	);
									memcpy(ADR(tmpString),		ADR(StartString)+11,5					);
									strcat(ADR(tmpString), 		ADR(' -  ')								);
									memcpy(ADR(tmpString)+8, 	ADR(StopString)+11,	5					);
	
									pStatisticsDynSubArticle.Name					:= tmpString;(*BufferDataType.ArticleName;*)
									pStatisticsDynSubArticle.SubNo					:= BufferDataType.RecipeNumber;
									pStatisticsDynSubArticle.SubName				:= BufferDataType.RecipeName;
									pStatisticsDynSubArticle.Counters.TimeInSec		:= BufferDataType.TimeInSec;
									pStatisticsDynSubArticle.Counters.Production[BufferDataType.PU-1]			:= BufferDataType.Production;
								
									pStatisticsDynSubArticle.Counters.Total			:= BufferDataType.Production;
									pStatisticsDynSubArticle.Counters.SortA			:= BufferDataType.SortA;
									pStatisticsDynSubArticle.Counters.SortB			:= BufferDataType.SortB;
									pStatisticsDynSubArticle.Counters.Drop			:= BufferDataType.Drop;
									pStatisticsDynSubArticle.Counters.Quality		:= BufferDataType.Quality;
									pStatisticsDynSubArticle.Counters.OverSize		:= BufferDataType.OverSize;
									pStatisticsDynSubArticle.Counters.TooClose		:= BufferDataType.TooClose;
									pStatisticsDynSubArticle.Counters.PreProduction	:= BufferDataType.PreProduction;
									pStatisticsDynSubArticle.Counters.Option1		:= BufferDataType.Option1;
									pStatisticsDynSubArticle.Counters.Option2		:= BufferDataType.Option2;
									pStatisticsDynSubArticle.Counters.Option3		:= BufferDataType.Option3;
									pStatisticsDynSubArticle.Counters.Flow1			:= BufferDataType.Flow1;
									pStatisticsDynSubArticle.Counters.Flow2			:= BufferDataType.Flow2;
									pStatisticsDynSubArticle.Counters.Flow3			:= BufferDataType.Flow3;
								END_IF
							END_IF
							(*End for add subarticle*)
						END_FOR
						StatisticsTotalStep := 2;
					ELSE
						GenStatisticsTotal := FALSE;
						StatisticsTotalStep := 0;
						StatisticsMain.Vis.ShowAll := 0;
					END_IF
				END_IF
			2:
				GenStatisticsTotal 					:= FALSE;
				StatisticsTotalStep 				:= 0;
				Offset 								:= 0;
				StatisticsMain.Vis.ScrollBoxCmdAll 	:= TRUE;
				StatisticsMain.ListMode 			:= 1;
				
				IF (StatisticsMain.CustomerCount = 1) THEN
					(*No cust art liste or 1 customer*)
					StatisticsMain.Vis.ScrollBoxCmdEnter 	:= TRUE;
					StatisticsMain.Vis.ScrollBoxDataPoint 	:= 0;
					LookupList[0] 							:= StatisticsMain.pFirstCustomer;
				END_IF
				(*UpdateBufferDataType := TRUE; OLD STAT SCREEN*)(*Access correct offset*)
				(*GetVisCustomerList := TRUE;*)
			END_CASE
		END_IF
	
		(*Setup active lanes show level for VIS*)
		FOR No := 0 TO 9 DO
			StatisticsMain.Vis.ActiveLanes[No] := StatisticsMain.Vis.Counters.Production[No] = 0; (*Disabling lane in vis stats*)
		END_FOR
	
		FOR ServerNo := 1 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
			// Next for loop new to multi RCP
			FOR No := 0 TO 9 DO
				IF (LogCore[ServerNo-1].PU[No].Write AND NOT GenTestFile = 1 AND NOT ReadTestFile = 1) THEN
					GenTestFile := LogCore[ServerNo-1].PU[No].Write;
					MasterLog := LogCore[ServerNo-1].PU[No].Data;
					LogCore[ServerNo-1].PU[No].Write := 0;
					WriteNo := ServerNo -1;
				END_IF
			END_FOR
		END_FOR
	
		IF (ReadTestFile = 1 AND NOT GenTestFile = 1) THEN
			FlatVarHandler_0.Settings.CreateFile := FALSE; (*Do not create an empty file when file is not found!!!*)
			FlatVarHandler_0.pDirectory	:= ADR(fDir[DisplayServer]); (*set correct Dir*)
			(*Burde h?ndteres i clib*)
			FlatVarHandler_0();
			IF (FlatVar.State = 0) THEN
				CASE Step OF
					0: (*Kommandoerne er ved at v?re p? plads.*)
						FlatVar.FileDataLines := 0;
						BufferAdr := 0;
						FlatVarHandler_0.Command := CONNECT_FILE;
						Step := 1;
					1:
						FlatVarHandler_0.Command := MAP_FILE_TO_BUFFER;
						Step := 2;
					2:
						BufferAdr	:= FlatVar.FileHandler.BufferMemIdent;
						BufferDataType ACCESS BufferAdr+Offset;
	
						FlatVarHandler_0.Command := DISCONNECT_FILE;
						Step := 3;
					3:
						ReadTestFile := 0;
						Step := 0;
						IF (FlatVar.FileDataLines = 0) THEN
							FileEmpty := TRUE;
						END_IF
				END_CASE
			ELSIF (FlatVar.State = 2 AND FlatVar.FileHandler.wStatus = 10000) THEN (*File does not exist*)
				Step 						:= 3;
				FlatVar.State 				:= 0;
				FlatVar.FileHandler.wStatus := 0;
				EmptyFileCount 				:= EmptyFileCount + 1;
			END_IF
		END_IF
	
		IF (GenTestFile = 1 (*AND NOT ReadTestFile = 1*)) THEN
			FlatVarHandler_0.Settings.CreateFile 	:= TRUE; (*Create an empty file if file is not found*)
			FlatVarHandler_0.pDirectory				:= ADR(fDir[WriteNo]); (*set correct Dir*)
			FlatVarHandler_0.pFile					:= ADR(CurrentfName); (*set correct filename*)
			FlatVarHandler_0();
			IF (FlatVar.State = 0) THEN
				CASE Step OF
					0:
						FlatVarHandler_0.Command 		:= CONNECT_FILE;
						Step 		:= 1;
					1:
						IF (FlatVarHandler_0.Settings.SecureWrite) THEN
							FlatVarHandler_0.Command 	:= ENABLE_SECURE_WRITE;
						END_IF
						Step 		:= 2;
					2:
						IF (FlatVar.FileHandler.FileStatus = 1) THEN
							Step 	:= 4;
						ELSE
							FlatVarHandler_0.Command 	:= MAP_STRUCT_TO_BUFFER;
							Step 	:= 3;
						END_IF
					3:
						FlatVarHandler_0.Command 		:= WRITE_BUFFER_TO_FILE;
						Step 		:= 4;
					4:
						FlatVarHandler_0.Command 		:= MAP_DATA_TO_BUFFER;
						Step 		:= 5;
					5:
						FlatVarHandler_0.Command 		:= WRITE_BUFFER_TO_FILE;
						Step 		:= 6;
					6:
						FlatVarHandler_0.Command 		:= DISCONNECT_FILE;
						Step 		:= 7;
					7:
						GenTestFile := 0;
						Step 		:= 0;
				END_CASE
			END_IF
		END_IF
	END_IF
END_PROGRAM

