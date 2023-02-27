PROGRAM _CYCLIC
	(*MANGLER MULTILANE SUPPORT FRA JL!!!!*)
	IF Error = 0 AND NOT disable THEN
		(*Internal timer*)
		MilliSeconds := TIME_TO_UDINT( clock_ms());
	
		LocalCycleCounter := LocalCycleCounter + 1;
		(*DEBUG - DISABLE AFTER USE!*)
		DbgDataLogger ACCESS JenViewSetupCfg[DbgServer].AdrDataLogger + (DbgOperator * SIZEOF(DbgDataLogger));
		(*DEBUG*)
	
		FOR i:= 0 TO JenViewServerInterface.ServersRunning - 1 DO
	
			(*Replacement for ISControlPlc AND ISEmergencyOK*)
			IF ArrAdrRunningStatus[i] > 0 THEN (*Pointer to ISControlPlc found*)
				DynRunningStat ACCESS ArrAdrRunningStatus[i];
	
				IF DynRunningStatus[i] <> DynRunningStat AND DynRunningStat = TRUE THEN
					EdgePosISControlPlc[i] := 1;
				ELSE
					EdgePosISControlPlc[i] := 0;
				END_IF
	
				IF DynRunningStatus[i] <> DynRunningStat AND DynRunningStat = FALSE THEN
					EdgeNegISControlPlc[i] := 1;
				ELSE
					EdgeNegISControlPlc[i] := 0;
				END_IF
	
				DynRunningStatus[i] := DynRunningStat;
	
			END_IF
			IF ArrAdrEmergencyStatus[i] > 0 THEN (*Pointer to ISControlPlc found*)
				DynEmergencyStatus ACCESS ArrAdrEmergencyStatus[i];
			END_IF
	
			(*Acces correct loadID*)
			RunTimeData ACCESS ArrAdrRunTimeDataEntry[i];
	
			FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
				(*Making delays for lanes instead of servers*)
	
				IF EdgePosISControlPlc[i] THEN (*Added: 1.23*)
					PreCustomerArticleLoadID[i].LoadID[Operator-1] := RunTimeData.LoadID[Operator-1]; (*Do not wait at start*)
				END_IF
				(*Detect Change*)
				IF ((PreCustomerArticleLoadID[i].LoadID[Operator-1] < RunTimeData.LoadID[Operator-1]) (*AND DynRunningStatus[i] EG 0110*)) THEN
					(*Clear RealTimeTmp Counters*)
	
					PreCustomerArticleLoadID[i].LoadID[Operator-1] := RunTimeData.LoadID[Operator-1];
					(*Delay Change*)
					IF (JenViewSetupCfg[i].ChangeDelay > 0 AND pGlobalCounter > 0 AND DynRunningStatus[i]) THEN
						ChangeDelay[i].LoadID[Operator-1] := GlobalCounter + JenViewSetupCfg[i].ChangeDelay;
					ELSE
						ChangeDelayed[Operator-1] := TRUE;
					END_IF
				END_IF
				IF ChangeDelay[i].LoadID[Operator-1] > 0 THEN (*Check for nullpointer =)*)
					IF (ChangeDelay[i].LoadID[Operator-1] <= GlobalCounter) THEN
						ChangeDelayed[Operator-1] := TRUE;
						ChangeDelay[i].LoadID[Operator-1] := 0;
					END_IF
				END_IF
	
				IF ((EdgePosISControlPlc[i] OR EdgeNegISControlPlc[i]) OR (HChange[i] AND DynRunningStatus[i]) OR (ChangeDelayed[Operator-1]) AND ArrAdrRunTimeDataEntry[i] > 0) THEN
	
					IF ChangeDelayed[Operator-1] THEN
						pRealTimeTmpLog ACCESS ArrAdrRealTimeTmpLog[i] + (Operator - 1) * SIZEOF(pRealTimeTmpLog);
						pRealTimeTmpLog.Clear := 1;
					END_IF
	
					DataLogger ACCESS JenViewSetupCfg[i].AdrDataLogger + (Operator - 1) * SIZEOF(DataLogger); (*Acces correct memory*)
	
					DataLogger.Change 		:= TRUE;
					DataLogger.ChangeType 	:= HChange[i];
					DataLogger.Active 		:= (RunTimeData.Active[Operator-1] MOD 10) = 1;   // New flow logic here
					DataLogger.MetaData.PUStatus := RunTimeData.Active[Operator-1];   // New flow logic here
					DataLogger.SingleLaneOp := JenViewSetupCfg[i].SingeLaneOp[Operator-1];
	
					IF EdgePosISControlPlc[i] THEN (*Set starttime if turned on*)
						DataLogger.TimeStart	:= DTGetTime_1.DT1;
					END_IF
	
					ChangeDelayed[Operator-1] := FALSE;
				END_IF
			END_FOR
			HChange[i] := 0;
	
	
			Status[i] := 0;
			// Running
			IF (DynRunningStatus[i]) 															THEN	Status[i] := Status[i] + 1;		END_IF
			// Not Running
			IF (NOT DynRunningStatus[i] AND RunTimeData.Status = 0)								THEN	Status[i] := Status[i] + 2;		END_IF
			// Emergency
			IF (NOT DynEmergencyStatus AND NOT DynRunningStatus[i])								THEN	Status[i] := Status[i] + 4;		END_IF
			// Alarm
			IF (NOT DynRunningStatus[i] AND (RunTimeData.Status > 0))	THEN	Status[i] := Status[i] + 8;		END_IF;
	
			(*Find server offset for finding the correct operators for a specific server*)
			TimerDiff := 0;
			IF (i > 0) THEN
				tmpServerOffset := 0;
				FOR IndexCount := 1 TO i DO
					IF (JenViewSetupCfg[IndexCount-1].DisableOperatorLog) THEN
						tmpServerOffset := tmpServerOffset + JenViewSetupCfg[IndexCount-1].Attendants;
					ELSE
						tmpServerOffset := tmpServerOffset + JenViewSetupCfg[IndexCount-1].ProductionUnits + JenViewSetupCfg[IndexCount-1].Attendants;
					END_IF
					IF ((JenViewSetupCfg[IndexCount-1].DisableOperatorLog AND JenViewSetupCfg[IndexCount-1].Attendants = 0)) THEN
						TimerDiff := TimerDiff + JenViewSetupCfg[IndexCount-1].ProductionUnits;
					ELSIF ((JenViewSetupCfg[IndexCount-1].DisableOperatorLog AND JenViewSetupCfg[IndexCount-1].ProductionUnits > JenViewSetupCfg[IndexCount-1].Attendants)) THEN
						TimerDiff := TimerDiff + JenViewSetupCfg[IndexCount-1].ProductionUnits-JenViewSetupCfg[IndexCount-1].Attendants;
					END_IF
				END_FOR
				ServerOffset := tmpServerOffset;
			ELSE
				ServerOffset := 0;
			END_IF
			(*Great fix!*)
			TimerOffset := ServerOffset + TimerDiff;
	
			(*Logwrite wrapper*)
			AddToLog_0(Setup:=1, ServerNo := i);
			AddToWideLog_0(Setup:=1, ServerNo := i);
			(*AddToLog_1(Setup:=1, ServerNo := i);*)
			(*External power input, understøttelse af fremmede maskiner*)
			IF (ArrAdrExternalPowerInput[i] > 0) THEN
				pExternalPowerInput ACCESS ArrAdrExternalPowerInput[i];
				pExternalPowerInput();
				IF EDGEPOS(pExternalPowerInput.Out) THEN
					RInit[i] := TRUE;
					StatusOld[i] := 0;
				END_IF
			END_IF
	
			IF EdgePosISControlPlc[i] THEN (*Starting up*)
				THourLog[i] := 0;
			END_IF
	
			IF (DynRunningStatus[i]) THEN
				THourLog[i] := THourLog[i] + 1;
			END_IF
	
			FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
				DataLogger ACCESS ArrAdrCommonDataLogger[i] + (Operator - 1) * SIZEOF(DataLogger); (*Acces correct memory*)
	
				IF (DynRunningStatus[i]) THEN
					IF TimeCycleCount[Operator-1+TimerOffset] <> REAL_TO_UDINT(MilliSeconds / 1000) THEN
						TimeCycleCount[Operator-1+TimerOffset] := REAL_TO_UDINT(MilliSeconds / 1000);
						DataLogger.RcpLoggedTime := DataLogger.RcpLoggedTime + 1;
						DataLogger.OprLoggedTime := DataLogger.OprLoggedTime + 1;
					END_IF
				END_IF
	
				(*Look for Change*)
				IF ((DataLogger.Change = TRUE) OR (Restart[i])) THEN
					Change[i] := 1;
					THourLog[i] := 0;
				END_IF
	
			END_FOR
	
			(*Pulse logger*)
			JenViewPulseLogX ACCESS ArrAdrJenViewPulseLog[i];
	
			IF RInit[i] THEN (*Write init in logfile*)
	
				(*Log off Attendants or Operators*) (*Working!*)
				IF (JenViewSetupCfg[i].Attendants + JenViewSetupCfg[i].ProductionUnits > 0) THEN
					(*Test*)
					IF (JenViewSetupCfg[i].DisableOperatorLog) THEN
						Count := JenViewSetupCfg[i].ProductionUnits;
					ELSE
						Count := 0;
					END_IF
					(*Test*)
					FOR Operator := 1 + Count TO JenViewSetupCfg[i].ProductionUnits+JenViewSetupCfg[i].Attendants DO (*Log off Operators*)
						IF (PermData.Operator[Operator-Count-1+ServerOffset].ID > 0) THEN
							PermData.Operator[Operator-Count-1+ServerOffset].ID := 0;
							PermData.Operator[Operator-Count-1+ServerOffset].Name := 'LOGOUT';
							AddToLog_0(Mode := 02, ValueID := (30 +  Operator), Value := 0, Info := -1,MessageA := PermData.Operator[Operator-Count-1+ServerOffset].Name, TimeStamp := PermData.DateTimeLog[i], OverWriteTimeStamp := 1);
							
							AddToWideLog_0.Data.SubID 		:= Operator;
							AddToWideLog_0.Data.TimeStamp	:= PermData.DateTimeLog[i];
							AddToWideLog_0.OverWriteTimeStamp := TRUE;
							AddToWideLog_0.Data.RegType 	:= 6;
							AddToWideLog_0.Data.SubRegType 	:= 0;
							AddToWideLog_0.Data.SubRegTypeID:= -1;
							AddToWideLog_0.Data.State 		:= 0;
							AddToWideLog_0.Data.OperatorNo 	:= OperatorNo;
							AddToWideLog_0.Data.MessageA 	:= PermData.Operator[Operator-Count-1+ServerOffset].Name;
							AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
							AddToWideLog_0();
							
							OperatorID[Operator-Count-1+ServerOffset] := 0; (*Signoff - debug*)
							(*Reset Perm Data*)
						END_IF
					END_FOR
				END_IF
	
				(*Power off, power on*)
				// P O W E R  O F F
				AddToLog_0(Mode := 255, ValueID := 0, Value := 0, Info := -1, TimeStamp := PermData.DateTimeLog[i], OverWriteTimeStamp := 1);
				// Power Off in wide format
				AddToWideLog_0.Data.TimeStamp 		:= PermData.DateTimeLog[i];
				AddToWideLog_0.OverWriteTimeStamp 	:= TRUE;
				AddToWideLog_0.Data.RegType 		:= 0;
				AddToWideLog_0.Data.SubRegType 		:= 3;
				AddToWideLog_0.Data.MessageA		:= 'Power Off';
				AddToWideLog_0.Data.State 			:= 0;
				AddToWideLog_0.Data.SubID			:= -1;
				AddToWideLog_0();
				
				// P O W E R  O N
				DTGetTime_1(enable := 1); (* Get Date and Time - *)
				RealTime[i] := DTGetTime_1.DT1;
				AddToLog_0(Mode := 255, ValueID := 0, Value := 1, Info := -1);
				// Power On in wide format
				AddToWideLog_0.Data.RegType 		:= 0;
				AddToWideLog_0.Data.SubRegType 		:= 3;
				AddToWideLog_0.Data.MessageA		:= 'Power On';
				AddToWideLog_0.Data.State 			:= 1;
				AddToWideLog_0.Data.SubID			:= -1;
				AddToWideLog_0();	
			END_IF
	
			(*Log pulse*) (*Working!*)
			(* Distance logs - ONLY in narrow format for now!! *)
			JenViewPulseLogX(Run:= 1, ForceOut := Change[i]);
			IF (JenViewPulseLogX.Out AND UDINT_TO_UINT((JenViewPulseLogX.PulseCount*3)/10) > 0) THEN
				AddToLog_0(Mode := 4, ValueID := 31, Value := UDINT_TO_UINT((JenViewPulseLogX.PulseCount*3)/10), Info := -1);
			END_IF
	
			(*Log Add Ons *)
			FOR AddOnNo := 0 TO (SIZEOF(JenViewSetupCfg[i].AddOn) / SIZEOF(JenViewSetupCfg[i].AddOn[0]) - 1 ) DO
				IF (JenViewSetupCfg[i].AddOn[AddOnNo].Ident > 0) THEN
					(*Test[i] := Test[i] + 1;*)
					pAddOnFub ACCESS JenViewSetupCfg[i].AddOn[AddOnNo].Ident;
					pAddOnFub(Reset := Change[i]);
					IF pAddOnFub.Out AND JenViewSetupCfg[i].AddOn[AddOnNo].Log THEN
						IF (pAddOnFub.Value > 0 AND pAddOnFub.Type = 1) OR (pAddOnFub.Type = 0) THEN
							AddToLog_0(Mode := JenViewSetupCfg[i].AddOn[AddOnNo].Mode, ValueID := UDINT_TO_USINT(JenViewSetupCfg[i].AddOn[AddOnNo].ValueID), Value := pAddOnFub.Value, Info := -1, MessageA := JenViewSetupCfg[i].AddOn[AddOnNo].AddOnName);
							AddToWideLog_0.Data.RegType 		:= JenViewSetupCfg[i].AddOn[AddOnNo].RegType;
							AddToWideLog_0.Data.SubRegType 		:= JenViewSetupCfg[i].AddOn[AddOnNo].SubRegType;
							AddToWideLog_0.Data.SubRegTypeID	:= JenViewSetupCfg[i].AddOn[AddOnNo].SubRegTypeID;
							AddToWideLog_0.Data.MessageA		:= JenViewSetupCfg[i].AddOn[AddOnNo].AddOnName;
							AddToWideLog_0.Data.MessageB		:= JenViewSetupCfg[i].AddOn[AddOnNo].MessageB;
							AddToWideLog_0.Data.ArtNo			:= DataLogger.MetaData.ArtNo;
							AddToWideLog_0.Data.CustNo			:= DataLogger.MetaData.CustNo;
							AddToWideLog_0.Data.ProcessCode		:= DataLogger.MetaData.RcpNo + 1;
							AddToWideLog_0.Data.ProcessName 	:= DataLogger.MetaData.RcpText;
							AddToWideLog_0.Data.SubID		 	:= -1;
														
							IF (JenViewSetupCfg[i].AddOn[AddOnNo].MultiplierValue > 0) THEN
								AddToWideLog_0.Data.Value			:= (UDINT_TO_REAL(pAddOnFub.Value)/UDINT_TO_REAL(JenViewSetupCfg[i].AddOn[AddOnNo].MultiplierValue));
							ELSE
								AddToWideLog_0.Data.Value			:= UDINT_TO_REAL(pAddOnFub.Value);
							END_IF
							AddToWideLog_0.Data.Unit			:= JenViewSetupCfg[i].AddOn[AddOnNo].Unit;
							IF (JenViewSetupCfg[i].AddOn[AddOnNo].RegType = 2) THEN
	   							AddToWideLog_0.Data.State := -1;
							ELSIF (JenViewSetupCfg[i].AddOn[AddOnNo].RegType = 7) THEN 							
								AddToWideLog_0.Data.State := 0;
							END_IF
							AddToWideLog_0();
						END_IF
					END_IF
				END_IF
			END_FOR
			
			(*Log status change*) (*Working!*)
			IF (Status[i] > 0) THEN
				IF (Status[i] <> StatusOld[i]) THEN
					AddToLog_0(Mode := 02, ValueID := 01, Value := Status[i], Info := -1);
				END_IF
				
				// New Cockpit Wide Log Status
				// ERROR
				Status0[i] := Status[i].0;
				Status1[i] := Status[i].1;
				Status2[i] := Status[i].2;
				Status3[i] := Status[i].3;
				
				// THREE SCENARIOS
				
				IF (Status3[i] <> StatusOld3[i] AND StatusOld3[i] = 1) THEN
					AddToWideLog_0.Data.SubID		:= -1;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					AddToWideLog_0.Data.State		:= 0;
					AddToWideLog_0.Data.Value		:= 3;
					AddToWideLog_0.Data.MessageA	:= 'Error';
					AddToWideLog_0.Data.MessageB	:= 'Status';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Unit		:= -1;
					AddToWideLog_0();

				END_IF
								// Check Ready to Start status and not in error
				IF (Status1[i] <> StatusOld1[i]) AND Status0[i] = 1 THEN
					AddToWideLog_0.Data.SubID		:= -1;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					IF (Status3[i] = 1) THEN
						AddToWideLog_0.Data.State		:= 0;
					ELSE
						AddToWideLog_0.Data.State		:= Status[i].1;
					END_IF
					AddToWideLog_0.Data.Value		:= 1;
					AddToWideLog_0.Data.MessageA	:= 'Ready To Start';
					AddToWideLog_0.Data.MessageB	:= 'Status';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Unit		:= -1;
					AddToWideLog_0();
				END_IF
				// Check In Operation Status
				IF (Status0[i] <> StatusOld0[i]) THEN
					AddToWideLog_0.Data.SubID		:= -1;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					AddToWideLog_0.Data.State		:= Status[i].0;
					AddToWideLog_0.Data.Value		:= 2;
					AddToWideLog_0.Data.MessageA	:= 'In Operation';
					AddToWideLog_0.Data.MessageB	:= 'Status';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Unit		:= -1;
					AddToWideLog_0();		
				END_IF
				
				// Check Ready to Start status and not in error
				IF (Status1[i] <> StatusOld1[i]) AND Status0[i] = 0 THEN
					AddToWideLog_0.Data.SubID		:= -1;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					IF (Status3[i] = 1) THEN
						AddToWideLog_0.Data.State		:= 0;
					ELSE
						AddToWideLog_0.Data.State		:= Status[i].1;
					END_IF
					AddToWideLog_0.Data.Value		:= 1;
					AddToWideLog_0.Data.MessageA	:= 'Ready To Start';
					AddToWideLog_0.Data.MessageB	:= 'Status';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Unit		:= -1;
					AddToWideLog_0();
				END_IF
				
				IF (Status3[i] <> StatusOld3[i] AND StatusOld3[i] = 0) THEN
					AddToWideLog_0.Data.SubID		:= -1;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					AddToWideLog_0.Data.State		:= 1;
					AddToWideLog_0.Data.Value		:= 3;
					AddToWideLog_0.Data.MessageA	:= 'Error ';
					AddToWideLog_0.Data.MessageB	:= 'Status';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Unit		:= -1;
					AddToWideLog_0();

				END_IF
				
				StatusOld0[i] := Status0[i];
				StatusOld1[i] := Status1[i];
				StatusOld2[i] := Status2[i];
				StatusOld3[i] := Status3[i];
				
				
				StatusOld[i] := Status[i];
			END_IF;
	
			(* Log Operators (Operations (lanes)) and Attendants *)
			IF (JenViewSetupCfg[i].ProductionUnits + JenViewSetupCfg[i].Attendants > 0) THEN
	
				IF (JenViewSetupCfg[i].DisableOperatorLog) THEN
					Count := JenViewSetupCfg[i].ProductionUnits;
				ELSE
					Count := 0;
				END_IF
	
				(*Log Operators popped off the fifo *)
				IF (ArrAdrOperatorDelay[i] > 0) THEN
					pOperatorDelay ACCESS ArrAdrOperatorDelay[i];
					pOperatorDelay();
					IF pOperatorDelay.Out THEN
						AddToLog_0(Mode := 02, ValueID := 31 + pOperatorDelay.Info, Value := pOperatorDelay.Operator, Info := -1, MessageA := pOperatorDelay.OperatorName);
						
						AddToWideLog_0.Data.SubID 		:= pOperatorDelay.Info + 1;
					    AddToWideLog_0.Data.RegType 	:= 6;
						AddToWideLog_0.Data.SubRegType 	:= 0;
						AddToWideLog_0.Data.SubRegTypeID:= -1;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.OperatorNo 	:= pOperatorDelay.Operator;
						AddToWideLog_0.Data.MessageA 	:= pOperatorDelay.OperatorName;
						AddToWideLog_0.Data.Unit		:= -1;
						
						IF (PermData.Operator[Operator-Count + ServerOffset].ID = 0 ) THEN
		   					AddToWideLog_0.Data.State		:= 0;							
							AddToWideLog_0.Data.MessageB	:= 'Operator Log Off';
						ELSE
							AddToWideLog_0.Data.State		:= 1;							
							AddToWideLog_0.Data.MessageB	:= 'Operator Log On';
						END_IF
								
						AddToWideLog_0();
						
						DataLogger ACCESS ArrAdrCommonDataLogger[i] + (pOperatorDelay.Info-Count) * SIZEOF(DataLogger); (*Access correct memory*)
						DataLogger.Production.Production.OprTotal := 0;
						DataLogger.OprLoggedTime := 0;
					END_IF
				END_IF
	
				(*Catch Operator logon/logoff*)
				FOR Operator := 0 + Count TO JenViewSetupCfg[i].ProductionUnits + JenViewSetupCfg[i].Attendants - 1 DO
	
					(*Special for peter arghe!!*)
					IF RunTimeData.DisableOperatorLog THEN
						IF OperatorID[Operator+ServerOffset-Count] <> 0 THEN
							OperatorID[Operator+ServerOffset-Count] := 0;
							DataLogger ACCESS ArrAdrCommonDataLogger[i] + (Operator-Count) * SIZEOF(DataLogger); (*Access correct memory*)
							DataLogger.Production.Production.OprTotal := 0;
							DataLogger.OprLoggedTime := 0;
							AddToLog_0(Mode := 02, ValueID := 31 + Operator, Value := 0, Info := -1);
							
							AddToWideLog_0.Data.SubID 			:= Operator + 1;
					    	AddToWideLog_0.Data.RegType 		:= 6;
							AddToWideLog_0.Data.SubRegType 		:= 0;
							AddToWideLog_0.Data.SubRegTypeID 	:= -1;
							AddToWideLog_0.Data.CustNo			:= DataLogger.MetaData.CustNo;
							AddToWideLog_0.Data.ArtNo			:= DataLogger.MetaData.ArtNo;
							AddToWideLog_0.Data.ProcessCode		:= DataLogger.MetaData.RcpNo + 1;
							AddToWideLog_0.Data.ProcessName 	:= DataLogger.MetaData.RcpText;
							AddToWideLog_0.Data.OperatorNo 		:= OperatorNo;
							AddToWideLog_0.Data.MessageA 		:= PermData.Operator[Operator-Count-1+ServerOffset].Name;
							AddToWideLog_0.Data.Unit			:= -1;
							IF (PermData.Operator[Operator-Count + ServerOffset].ID > 0 ) THEN
	   							AddToWideLog_0.Data.State		:= 1;							
								AddToWideLog_0.Data.MessageB	:= 'Operator Log On';
							ELSE
								AddToWideLog_0.Data.State		:= 0;							
								AddToWideLog_0.Data.MessageB	:= 'Operator Log Off';
							END_IF
							AddToWideLog_0();
						END_IF
					ELSE
						(*FIX*)
						IF PermData.Operator[Operator+ServerOffset-Count].ID <> OperatorID[Operator+ServerOffset-Count] THEN
							LastId := Operator+ServerOffset-Count;
							OperatorID[LastId] := PermData.Operator[LastId].ID;
	
							(*Delay + buffer her!*)
							IF ((ArrAdrOperatorDelay[i] > 0) AND NOT RInit[i] AND DynRunningStatus[i]) THEN
								pOperatorDelay(Delay := RunTimeData.OperatorLogDelay, Set:=1, Operator:=PermData.Operator[LastId].ID, Info:= Operator, OperatorName := PermData.Operator[LastId].Name);
							ELSE
								AddToLog_0(Mode := 02, ValueID := 31 + Operator, Value := PermData.Operator[LastId].ID, Info := -1, MessageA := PermData.Operator[LastId].Name);
								//THE STUFF THAT LOGS THE OPERATORS ON AND OFF!!!
								AddToWideLog_0.Data.SubID 		:= Operator + 1;
					    		AddToWideLog_0.Data.RegType 	:= 6;
								AddToWideLog_0.Data.SubRegType 	:= 0;
								AddToWideLog_0.Data.SubRegTypeID:= -1;
								AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
								AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
								AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
								AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
								AddToWideLog_0.Data.OperatorNo 	:= PermData.Operator[LastId].ID;
								AddToWideLog_0.Data.MessageA 	:= PermData.Operator[LastId].Name;
								AddToWideLog_0.Data.Unit		:= -1;
								
								IF (PermData.Operator[Operator-Count + ServerOffset].ID = 0 ) THEN
		   							AddToWideLog_0.Data.State		:= 0;							
									AddToWideLog_0.Data.MessageB	:= 'Operator Log Off';
								ELSE
									AddToWideLog_0.Data.State		:= 1;							
									AddToWideLog_0.Data.MessageB	:= 'Operator Log On';
								END_IF
								AddToWideLog_0();
								
								(*Clear Operator stats at login*)
								DataLogger ACCESS ArrAdrCommonDataLogger[i] + (Operator-Count) * SIZEOF(DataLogger); (*Access correct memory*)
								DataLogger.Production.Production.OprTotal := 0;
								DataLogger.OprLoggedTime := 0;
							END_IF
						END_IF
					END_IF
				END_FOR
	
				(*Calculate Flow*)
				SFSFlow[i] 	:= 0;
				SFEFlow[i] 	:= 0;
				SNFFlow[i] 	:= 0;
				SLPFlow[i] 	:= 0;
				MWOFlow[i] 	:= 0;
				MFPFlow[i] 	:= 0;
				MIFlow[i] 	:= 0;
				
				FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
					DataLogger ACCESS ArrAdrCommonDataLogger[i] + (Operator - 1) * SIZEOF(DataLogger); (*Acces correct memory*)
					pTFlowTimeOut ACCESS ArrAdrTFlowTimeOut[i] + (Operator - 1) * SIZEOF(pTFlowTimeOut); (*Acces correct memory                        set high flow for flow control*)
					(*If We recieve a noflow command set flow low*)
					IF (NOT DataLogger.Flow.Station.NoFlow AND RunTimeData.FlowTimeOut[Operator-1] = 0) THEN
						pTFlowTimeOut(Set:=1, Delay := 0);
					END_IF
					(*Fix Flowtimer*)
					IF (RunTimeData.FlowTimeOut[Operator-1] = 0) THEN
						FlowTimer := JenViewSetupCfg[i].NoFlowTimeOut;
					ELSE
						FlowTimer := RunTimeData.FlowTimeOut[Operator-1];
					END_IF
					//IF (DataLogger.Production.Production.Data > 0 OR (DataLogger.Flow.Station.NoFlow) OR NOT DataLogger.Active OR NOT DynRunningStatus[i] OR DataLogger.Change) THEN
					IF (DataLogger.Production.Production.Data > 0 OR (DataLogger.Flow.Station.NoFlow) OR NOT DataLogger.Active OR NOT DynRunningStatus[i] OR EdgePosISControlPlc[i] OR EdgeNegISControlPlc[i]) THEN
						DbgFlow[i] := REAL_TO_UDINT(UDINT_TO_REAL(FlowTimer) * 1000 / CycleTime);
						DbgFlow[2+i] := FlowTimer;
						pTFlowTimeOut(Set:= 1, Delay:= (REAL_TO_UDINT(UDINT_TO_REAL(FlowTimer) * 1000 / CycleTime)), Comp:= 0, CntAdr:= ADR (LocalCycleCounter));
					END_IF
					pTFlowTimeOut();
					IF pTFlowTimeOut.Out THEN
						SNFFlow[i] := SNFFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
				
					(*New flow calcs*)
					IF RInit[i] THEN // Init new flows
						DataLogger.Flow.Station.FeedStart 			:= 1; 
						DataLogger.Flow.Station.FeedEnd 			:= 1;
						DataLogger.Flow.Station.LinenPresence 		:= 1;
						DataLogger.Flow.Machine.FeedingProhibited 	:= 1; 
						DataLogger.Flow.Machine.Idle 				:= 1;
						DataLogger.Flow.Machine.WaitingForOverlap 	:= 1;
					END_IF
				
					IF DataLogger.Flow.Station.FeedStart = 1 THEN
						SFSFlow[i] := SFSFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
					IF DataLogger.Flow.Station.FeedEnd = 1 THEN
						SFEFlow[i] := SFEFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
					IF DataLogger.Flow.Station.LinenPresence = 1 THEN
						SLPFlow[i] := SLPFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
				
					(*New flow machine*)
					IF DataLogger.Flow.Machine.FeedingProhibited = 1 THEN
						MFPFlow[i] := MFPFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
					IF DataLogger.Flow.Machine.Idle = 1 THEN
						MIFlow[i] := MIFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
					IF DataLogger.Flow.Machine.WaitingForOverlap = 1 THEN
						MWOFlow[i] := MWOFlow[i] + (REAL_TO_USINT( EXPT(2,Operator-1)));
					END_IF
					END_FOR
				(*take off station????*)
				IF (JenViewSetupCfg[i].TakeoffStation) AND (SNFFlow[i] > 1) THEN
					SNFFlow[i] := 1;
				END_IF
				
			END_IF
	
			(*Log events (counts, sorts etc....*)
			FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
				DataLogger ACCESS ArrAdrCommonDataLogger[i] + (Operator - 1) * SIZEOF(DataLogger); (*Acces correct memory*)
	
				(*Log Change*)
				IF (DataLogger.Change) THEN (*Working!*)
						
					AddToWideLog_0.Data.SubID 		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType	:= 5;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State 		:= 0;
					AddToWideLog_0.Data.MessageA 	:= 'CAR Change';
					AddToWideLog_0.Data.Value 		:= DataLogger.Active;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo; //UDINT_TO_UINT(RunTimeData.CustNo[Operator-1]);
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; //UDINT_TO_UINT(RunTimeData.ArtNo[Operator-1]);
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0();
					
					// Set new data for blackbox
					DataLogger.MetaData.RcpNo		:= RunTimeData.RcpNo[Operator-1];
					DataLogger.MetaData.RcpText		:= RunTimeData.RcpText[Operator-1];
					DataLogger.MetaData.CustNo 		:= UDINT_TO_UINT(RunTimeData.CustNo[Operator-1]);
					DataLogger.MetaData.CustText	:= RunTimeData.CustText[Operator-1];
					DataLogger.MetaData.ArtNo 		:= UDINT_TO_UINT(RunTimeData.ArtNo[Operator-1]);
					DataLogger.MetaData.ArtText 	:= RunTimeData.ArtText[Operator-1];
					DataLogger.MetaData.TNorm 		:= RunTimeData.Norm[Operator-1];
					DataLogger.MetaData.FlowTimeOut := RunTimeData.FlowTimeOut[Operator-1];
					DataLogger.MetaData.Primary 	:= RunTimeData.Primary[Operator-1];
					DataLogger.MetaData.Reference 	:= RunTimeData.Reference[Operator-1];

					AddToWideLog_0.Data.SubID 		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 0;
					AddToWideLog_0.Data.SubRegType	:= 5;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State 		:= 1;
					AddToWideLog_0.Data.MessageA 	:= 'CAR Change';
					AddToWideLog_0.Data.Value 		:= DataLogger.Active;
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo; //UDINT_TO_UINT(RunTimeData.CustNo[Operator-1]);
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; //UDINT_TO_UINT(RunTimeData.ArtNo[Operator-1]);
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0();
														
					//Norm
					AddToWideLog_0.Data.SubID		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 8;
					AddToWideLog_0.Data.SubRegType 	:= 0;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State		:= -1;
					AddToWideLog_0.Data.MessageB	:= 'Norm';
					AddToWideLog_0.Data.Value		:= DataLogger.MetaData.TNorm;
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; 
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					// 67 = Pieces/h
					AddToWideLog_0.Data.Unit		:= 67;
					
					AddToWideLog_0();
					
					//NoFlowTimeOut
					AddToWideLog_0.Data.SubID		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 8;
					AddToWideLog_0.Data.SubRegType 	:= 1;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State		:= -1;
					AddToWideLog_0.Data.MessageB	:= 'No Flow Timeout';
					AddToWideLog_0.Data.Value		:= DataLogger.MetaData.FlowTimeOut;
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; 
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					// 25 = Seconds
					AddToWideLog_0.Data.Unit		:= 25;
					AddToWideLog_0();

					//Primary
					AddToWideLog_0.Data.SubID		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 8;
					AddToWideLog_0.Data.SubRegType 	:= 2;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State		:= -1;
					AddToWideLog_0.Data.MessageB	:= 'Primary';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; 
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Value		:= UDINT_TO_REAL(DataLogger.MetaData.Primary);
					// Only for test
					AddToWideLog_0.Data.Unit		:= 6;
					
					AddToWideLog_0();

					//Reference
					AddToWideLog_0.Data.SubID		:= Operator;
					AddToWideLog_0.Data.RegType 	:= 8;
					AddToWideLog_0.Data.SubRegType 	:= 3;
					AddToWideLog_0.Data.SubRegTypeID:= -1;
					AddToWideLog_0.Data.State		:= -1;
					AddToWideLog_0.Data.MessageB	:= 'Reference';
					AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; 
					AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					AddToWideLog_0.Data.Value		:= UDINT_TO_REAL(DataLogger.MetaData.Reference);
					// Only for test
					AddToWideLog_0.Data.Unit		:= 6;
					
					AddToWideLog_0();
							
					IF (DataLogger.SingleLaneOp) THEN
						//CAR change
						AddToLog_0(Mode := 2, ValueID := 150 + Operator, Value := RunTimeData.BatchID[i], 			Info := -1, MessageA := '0'); (* Log Batch *)
						AddToLog_0(Mode := 2, ValueID := 210 + Operator, Value := RunTimeData.SourceID[i], 			Info := -1, MessageA := '0'); (* Log Source *)
						AddToLog_0(Mode := 2, ValueID := 060 + Operator, Value := DataLogger.MetaData.CustNo, 		Info := -1,	MessageA := DataLogger.MetaData.CustText); (* Log Customer *)
						AddToLog_0(Mode := 2, ValueID := 090 + Operator, Value := DataLogger.MetaData.ArtNo, 		Info := -1, MessageA := DataLogger.MetaData.ArtText ); 	(* Log Article *)
						AddToLog_0(Mode := 1, ValueID := 000 + Operator, Value := DataLogger.MetaData.RcpNo + 1, 	Info := -1, MessageA := DataLogger.MetaData.RcpText );	(* Log Recipe *)
						AddToLog_0(Mode := 1, ValueID := 030 + Operator, Value := DataLogger.MetaData.TNorm, 		Info := -1 );	(* Log Norm *)
						AddToLog_0(Mode := 1, ValueID := 060 + Operator, Value := DataLogger.MetaData.FlowTimeOut, 	Info := -1 );(* Log Flow TimeOut *)
						AddToLog_0(Mode := 1, ValueID := 090 + Operator, Value := DataLogger.MetaData.Primary, 		Info := -1 );(* Log Flow TimeOut *)
						AddToLog_0(Mode := 1, ValueID := 120 + Operator, Value := DataLogger.MetaData.Reference, 	Info := -1 );(* Log Flow TimeOut *)
					END_IF
	
					IF (DataLogger.ChangeType = 0) THEN
	
						(*ACCESS RealTimeTmp Loggers Data - Peter Special ;)*)
						pRealTimeTmpLog ACCESS ArrAdrRealTimeTmpLog[i] + (Operator - 1) * SIZEOF(pRealTimeTmpLog);
						IF pRealTimeTmpLog.Clear = 0 THEN
							pRealTimeTmpLog.RcpTime := pRealTimeTmpLog.RcpTime + DataLogger.RcpLoggedTime;
							pRealTimeTmpLog.OprTime := pRealTimeTmpLog.OprTime + DataLogger.OprLoggedTime;
							pRealTimeTmpLog.RcpCnt	:= pRealTimeTmpLog.RcpCnt  + DataLogger.Production.Production.RcpTotal;
							pRealTimeTmpLog.OprCnt	:= pRealTimeTmpLog.OprCnt  + DataLogger.Production.Production.OprTotal;
							pRealTimeTmpLog.RepairCnt := pRealTimeTmpLog.RepairCnt + DataLogger.Production.Repair.RcpTotal;
							pRealTimeTmpLog.RewashCnt := pRealTimeTmpLog.RewashCnt + DataLogger.Production.Rewash.RcpTotal;
						ELSE (*Clear that little bastard*)
							memset(ArrAdrRealTimeTmpLog[i] + (Operator - 1) * SIZEOF(pRealTimeTmpLog), 0, SIZEOF(pRealTimeTmpLog));
						END_IF
						(*Peter Special End*)
	
						(*Clear data loggers*)
						(*Memset DataLogger.Production???*)
					    DataLogger.Production.Production.OprTotal		:= 0;
						DataLogger.Production.Production.RcpTotal		:= 0;
						DataLogger.Production.Rewash.OprTotal 			:= 0;
						DataLogger.Production.Rewash.RcpTotal 			:= 0;
						DataLogger.Production.Repair.OprTotal 			:= 0;
						DataLogger.Production.Repair.RcpTotal 			:= 0;
						DataLogger.Production.PreProduction.OprTotal 	:= 0;
						DataLogger.Production.PreProduction.RcpTotal	:= 0;
						DataLogger.Production.Drop.OprTotal 			:= 0;
						DataLogger.Production.Drop.RcpTotal 			:= 0;
						DataLogger.Production.Quality.OprTotal 			:= 0;
						DataLogger.Production.Quality.RcpTotal 			:= 0;
						DataLogger.Production.Oversize.OprTotal 		:= 0;
						DataLogger.Production.Oversize.RcpTotal 		:= 0;
						DataLogger.Production.Trash.OprTotal 			:= 0;
						DataLogger.Production.Trash.RcpTotal 			:= 0;
						DataLogger.Production.ThickItem.OprTotal 		:= 0;
						DataLogger.Production.ThickItem.RcpTotal 		:= 0;
						DataLogger.Production.Sort.OprTotal 			:= 0;
						DataLogger.Production.Sort.RcpTotal 			:= 0;
						DataLogger.Production.MisFeed.OprTotal 			:= 0;
						DataLogger.Production.MisFeed.RcpTotal 			:= 0;
						DataLogger.Production.TooClose.OprTotal 		:= 0;
						DataLogger.Production.TooClose.RcpTotal 		:= 0;
						DataLogger.Production.Extra1.OprTotal 			:= 0;
						DataLogger.Production.Extra1.RcpTotal 			:= 0;
						DataLogger.Production.Extra2.OprTotal 			:= 0;
						DataLogger.Production.Extra2.RcpTotal 			:= 0;
						DataLogger.Production.Extra3.OprTotal 			:= 0;
						DataLogger.Production.Extra3.RcpTotal 			:= 0;
						DataLogger.RcpLoggedTime 						:= 0;
						DataLogger.OprLoggedTime 						:= 0;
						DataLogger.TimeStart 							:= DTGetTime_1.DT1;
						DataLogger.LoadID								:= RunTimeData.LoadID[Operator-1];
					END_IF
				END_IF
			//	(*Log steering lanes*)
				IF (DataLogger.Active AND DataLogger.Change) THEN
					AddToLog_0(Mode := 6, ValueID := Operator, Value := 0, Info := -1, );
					Mode[i] := Mode[i] + (REAL_TO_UINT( EXPT(2,Operator-1)));
					
					
				END_IF
	
				DataLogger.Change := FALSE;
				DataLogger.ChangeType := 0;
	
				IF (Change[i]) THEN (*Move ti single lane op when requested*)
					DataLogger.Mode :=Mode[i];
				END_IF
	
				(*Moved below Change to prevent drop of events*)
				(*Log Events*)
				FOR AlarmNo := 0 TO SIZEOF(DataLogger.Alarm) / SIZEOF(DataLogger.Alarm[0]) - 1 DO
					IF DataLogger.Alarm[AlarmNo].Status <> 0 THEN
						Info := (DataLogger.Alarm[AlarmNo].GroupID * 100) + DataLogger.Alarm[AlarmNo].ID;
						IgnoreEvent := FALSE;
						FOR IgnoreNo := 0 TO (SIZEOF(JenViewSetupCfg[i].AlarmIgnoreList)/SIZEOF(JenViewSetupCfg[i].AlarmIgnoreList[0])) -1 DO
							IF (Info = JenViewSetupCfg[i].AlarmIgnoreList[IgnoreNo]) THEN
								IgnoreEvent := TRUE;
							END_IF
						END_FOR
						IF (NOT IgnoreEvent) THEN
							IF DataLogger.Alarm[AlarmNo].Severity > 0 THEN
								LastestAlarmInfo[i] := Info;
								AddToLog_0(Mode := 3, ValueID := 1, Value := DataLogger.Alarm[AlarmNo].Status - 1, Info := Info, MessageA := DataLogger.Alarm[AlarmNo].Description);
								//Log Event and Severity - Wide Format
								AddToWideLog_0.Data.RegType 	:= 0;
								AddToWideLog_0.Data.SubRegType 	:= 1;
								AddToWideLog_0.Data.SubRegTypeID:= Info;
								// Getting correct alarm state.
								CASE DataLogger.Alarm[AlarmNo].Status OF
									1:
										AddToWideLog_0.Data.State		:= 0;
									2:
										AddToWideLog_0.Data.State		:= 1;
								END_CASE
						
								AddToWideLog_0.Data.MessageA	:= DataLogger.Alarm[AlarmNo].Description;
								AddToWideLog_0.Data.MessageB	:= DataLogger.Alarm[AlarmNo].Description;
								AddToWideLog_0.Data.Value		:= DataLogger.Alarm[AlarmNo].Severity;
								AddToWideLog_0.Data.Unit		:= DataLogger.Alarm[AlarmNo].GroupID;
								AddToWideLog_0();
								
								//Log Severity - Narrow format
								IF (DataLogger.Alarm[AlarmNo].Status - 1 = 1) THEN
									AddToLog_0(Mode := 3, ValueID := 2, Value := DataLogger.Alarm[AlarmNo].Severity, Info := Info,);
									AddToLog_0(Mode := 3, ValueID := 4, Value := DataLogger.Alarm[AlarmNo].GroupID, Info := Info,);
									
									
									//Log Alarm Group
									//Not defined in the "Bible"
									
									
								END_IF
							ELSIF (DataLogger.Alarm[AlarmNo].Status - 1 = 1) THEN (*Information*)
								AddToLog_0(Mode := 3, ValueID := 3, Value := DataLogger.Alarm[AlarmNo].Status - 1, Info := Info, MessageA := DataLogger.Alarm[AlarmNo].Description);
								//Information without a time duration - Not tested
								AddToWideLog_0.Data.RegType 	:= 0;
								AddToWideLog_0.Data.SubRegType	:= 4;
								AddToWideLog_0.Data.SubRegTypeID:= Info;
								AddToWideLog_0.Data.MessageA	:= DataLogger.Alarm[AlarmNo].Description;
								AddToWideLog_0.Data.MessageB	:= DataLogger.Alarm[AlarmNo].Description;
								AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo; 
								AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
								AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
								AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
								AddToWideLog_0.Data.Value		:= Info;
								AddToWideLog_0();
							END_IF
						END_IF
						(*Clear cached alam*)
						DataLogger.Alarm[AlarmNo].Status := 0;
					END_IF
				END_FOR
	
	
				(*Log Operators*)
				FOR OperatorNo := 0 TO SIZEOF(DataLogger.Operator) / SIZEOF(DataLogger.Operator[0]) - 1 DO
					IF strcmp(ADR(DataLogger.Operator[OperatorNo].Name),ADR('LOGOUT')) = 0 THEN (*Logout operator*)
						PermData.Operator[OperatorNo].ID := 0;
						PermData.Operator[OperatorNo].Name := 'LOGOUT';
	//					UpdatePermData := TRUE;
					ELSIF (DataLogger.Operator[OperatorNo].ID > 0) THEN (*Login Operator*)
						PermData.Operator[OperatorNo].ID := DataLogger.Operator[OperatorNo].ID;
						strcpy(ADR(PermData.Operator[OperatorNo].Name),ADR(DataLogger.Operator[OperatorNo].Name));
	//					UpdatePermData := TRUE;
					END_IF
				END_FOR
	
				IF (DynRunningStatus[i]) THEN (*Only log production then the machine is running*)
					(*Log production*)
					(*Array of Commondataloggers would have been more easy to loop through*)
					IF (DataLogger.Production.Production.Data > 0) THEN(*Procution*)
						AddToLog_0(Mode := 6, ValueID := Operator, Value := DataLogger.Production.Production.Data, Info := DataLogger.Production.Production.Info1);
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 0;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= UDINT_TO_REAL(DataLogger.Production.Production.Data);
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						MHADbg_ProcessName := AddToWideLog_0.Data.ProcessName;
						MHADbg_Info2 := DataLogger.Production.Production.Info2;
						IF g_EnableJDLogData THEN
							IF (DataLogger.Production.Production.Info1 > 0) THEN
								IF MHAEnableStd THEN
									AddToWideLog_0.Data.ProcessCode	:= DataLogger.Production.Production.Info1 + 1;
									strcpy(ADR(AddToWideLog_0.Data.ProcessName),DataLogger.Production.Production.Info2);
								ELSE
//									AddToWideLog_0.Data.ProcessCode	:= DataLogger.Production.Production.Info1 + 1;
//									strcpy(ADR(AddToWideLog_0.Data.ProcessName),ADR('Article 2 - 81'));
									AddToWideLog_0.Data.ProcessCode	:= DataLogger.Production.Production.Info1;
									strcpy(ADR(AddToWideLog_0.Data.ProcessName),DataLogger.Production.Production.Info2);
								END_IF									
							ELSE
								AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
								AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
							END_IF
						END_IF
						AddToWideLog_0.Data.MessageA	:= 'Production';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;// TODO .ID g_Core.Services.Operator.Runtime.No[Operator - 1].Number;
						AddToWideLog_0();
						AddCountToLog(ADR(DataLogger.Production.Production));
					END_IF
					
					IF (DataLogger.Production.Rewash.Data > 0) THEN(*Rewash*)
						AddToLog_0(Mode := 6, ValueID := 30 + Operator, Value := DataLogger.Production.Rewash.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Rewash));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 3;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Rewash';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Repair.Data > 0) THEN(*Repair*)
						AddToLog_0(Mode := 6, ValueID := 60 + Operator, Value := DataLogger.Production.Repair.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Repair));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 4;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Repair';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.PreProduction.Data > 0) THEN(*Preproduction*)
						AddToLog_0(Mode := 6, ValueID := 90 + Operator, Value := DataLogger.Production.PreProduction.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.PreProduction));
					//	AddToWideLog_0.Data.RegType		:= 1;
					//	AddToWideLog_0.Data.SubRegType	:= 8;
					//	AddToWideLog_0.Data.SubID		:= Operator;
					//	AddToWideLog_0.Data.Value		:= 1;
					//	AddToWideLog_0.Data.Unit		:= 33;
					//	AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
					//	AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
					//	AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
					//	AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
					//	AddToWideLog_0.Data.MessageA	:= 'Pre Production';
					//	AddToWideLog_0.Data.OperatorNo	:= g_Core.Services.Operator.Runtime.No[Operator - 1].Number;
					//	AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Drop.Data > 0) THEN(*Drop*)
						AddToLog_0(Mode := 6, ValueID := 120 + Operator, Value := DataLogger.Production.Drop.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Drop));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 9;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Drop';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Quality.Data > 0) THEN(*Quality*)
						AddToLog_0(Mode := 6, ValueID := 150 + Operator, Value := DataLogger.Production.Quality.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Quality));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 2;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Quality';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Oversize.Data > 0) THEN(*Oversize*)
						AddToLog_0(Mode := 6, ValueID := 180 + Operator, Value := DataLogger.Production.Oversize.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Oversize));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 10;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Oversize';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Trash.Data > 0) THEN(*Trash*)
						AddToLog_0(Mode := 6, ValueID := 210 + Operator, Value := DataLogger.Production.Trash.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.Trash));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 6;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Trash';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.ThickItem.Data > 0) THEN(*ThickItem*)
						AddToLog_0(Mode := 7, ValueID := 30 + Operator, Value := DataLogger.Production.ThickItem.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.ThickItem));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 5;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Thick Item';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.Sort.Data > 0) THEN(*Sort*)
						AddToLog_0(Mode := 7, ValueID := 60 + Operator, Value := DataLogger.Production.Sort.Data, Info := -1, MessageA := DataLogger.Production.Trash.MessageA, MessageB := DataLogger.Production.Trash.MessageB);
						AddCountToLog(ADR(DataLogger.Production.Sort));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 1;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'Sort';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.MisFeed.Data > 0) THEN(*MisFeed*)
						AddToLog_0(Mode := 7, ValueID := 90 + Operator, Value := DataLogger.Production.MisFeed.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.MisFeed));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 11;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'MisFeed';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
					IF (DataLogger.Production.TooClose.Data > 0) THEN(*TooClose*)
						AddToLog_0(Mode := 7, ValueID := 120 + Operator, Value := DataLogger.Production.TooClose.Data, Info := -1);
						AddCountToLog(ADR(DataLogger.Production.TooClose));
						AddToWideLog_0.Data.RegType		:= 1;
						AddToWideLog_0.Data.SubRegType	:= 12;
						AddToWideLog_0.Data.SubID		:= Operator;
						AddToWideLog_0.Data.Value		:= 1;
						AddToWideLog_0.Data.Unit		:= 33;
						AddToWideLog_0.Data.CustNo		:= DataLogger.MetaData.CustNo;
						AddToWideLog_0.Data.ArtNo		:= DataLogger.MetaData.ArtNo;
						AddToWideLog_0.Data.ProcessCode	:= DataLogger.MetaData.RcpNo + 1;
						AddToWideLog_0.Data.ProcessName := DataLogger.MetaData.RcpText;
						AddToWideLog_0.Data.MessageA	:= 'TooClose';
						AddToWideLog_0.Data.OperatorNo	:= PermData.Operator[Operator - 1].ID;
						AddToWideLog_0();
					END_IF
				END_IF
				IF (DataLogger.Production.Extra1.Data > 0) THEN(*Extra1*)
					AddCountToLog(ADR(DataLogger.Production.Extra1));
					(*AddToLog_0(Mode := 7, ValueID := 150 + Operator, Value := DataLogger.Production.Extra1.Data, Info := -1);*)
				END_IF
				IF (DataLogger.Production.Extra2.Data > 0) THEN(*Extra2*)
					AddCountToLog(ADR(DataLogger.Production.Extra2));
					(*AddToLog_0(Mode := 7, ValueID := 180 + Operator, Value := DataLogger.Production.Extra2.Data, Info := -1);*)
				END_IF
				IF (DataLogger.Production.Extra3.Data > 0) THEN(*Extra3*)
					AddCountToLog(ADR(DataLogger.Production.Extra3));
					(*AddToLog_0(Mode := 7, ValueID := 210 + Operator, Value := DataLogger.Production.Extra3.Data, Info := -1);*)
				END_IF
			END_FOR
	
			IF (Change[i] = TRUE) THEN
				Mode[i] := 0;
				Change[i] := FALSE;
				Restart[i] := FALSE;
			END_IF	
		
			IF NOT JenViewSetupCfg[i].NoneProduction THEN (*Log ikke flow for nonproduction maskiner*)
				(*Station FeedStart - 15 *)
			
				IF (SFSFlow[i] <> SFSFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (SFSFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (SFSFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 6;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (SFSFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Feed Start High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Feed Start Low';
							END_IF
							AddToWideLog_0();	
						END_IF
					END_FOR
					AddToLog_0(Mode := 2, ValueID := 15, Value := SFSFlow[i], Info := -1, );
					SFSFlowOld[i] := SFSFlow[i];
				END_IF
				
				(*Station FeedEnd - 16 *)
				IF (SFEFlow[i] <> SFEFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (SFEFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (SFEFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 7;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (SFEFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Feed End High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Feed End Low';
							END_IF
							AddToWideLog_0();
				
						END_IF
					END_FOR
					SFEFlowOld[i] := SFEFlow[i];
					AddToLog_0(Mode := 2, ValueID := 16, Value := SFEFlow[i], Info := -1, );
					
				END_IF
				(*Station NoFlow - 17 *)
				IF (SNFFlow[i] <> SNFFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (SNFFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (SNFFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 2;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (SNFFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'No Flow High';
								
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'No Flow Low';
							END_IF
							AddToWideLog_0();
						END_IF
					END_FOR
					SNFFlowOld[i] := SNFFlow[i];
					AddToLog_0(Mode := 2, ValueID := 17, Value := SNFFlow[i], Info := -1, );
				END_IF
				(*Station Linen Present - 16 *)
				IF (SLPFlow[i] <> SLPFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (SLPFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (SLPFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 8;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (SLPFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Linen Present - High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Linen Present - Low';
							END_IF
							AddToWideLog_0();
						END_IF
					END_FOR
					SLPFlowOld[i] := SLPFlow[i];
					AddToLog_0(Mode := 2, ValueID := 19, Value := SLPFlow[i], Info := -1, );
				END_IF
				(*Machine Waiting for Overlap - 21 *)
				IF (MWOFlow[i] <> MWOFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (MWOFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (MWOFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN						
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 9;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (MWOFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Waiting for Overlap - High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Waiting for Overlap - Low';
							END_IF
							AddToWideLog_0();
						END_IF
					END_FOR		
					MWOFlowOld[i] := MWOFlow[i];
					AddToLog_0(Mode := 2, ValueID := 21, Value := MWOFlow[i], Info := -1, );
				END_IF
				(*Machine Feeding prohibited - 23 *)
				IF (MFPFlow[i] <> MFPFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (MFPFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (MFPFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN	
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 10;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (MFPFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN		
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Feeding Prohibited - High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Feeding Prohibited - Low';
							END_IF
							AddToWideLog_0();
						END_IF
					END_FOR	
					MFPFlowOld[i] := MFPFlow[i];
					AddToLog_0(Mode := 2, ValueID := 23, Value := MFPFlow[i], Info := -1, );
				END_IF
				(*Machine Idle- 25 *)
				IF (MIFlow[i] <> MIFlowOld[i]) THEN
					FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
						
						IF (MIFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) <> (MIFlowOld[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) THEN						
							AddToWideLog_0.Data.RegType		:= 0;
							AddToWideLog_0.Data.SubRegType	:= 11;
							AddToWideLog_0.Data.SubID		:= Operator;
							IF (MIFlow[i] AND (REAL_TO_USINT( EXPT(2,Operator-1)))) > 0 THEN		
								AddToWideLog_0.Data.State		:= 1;
								AddToWideLog_0.Data.MessageB	:= 'Machine Idle - High';
							ELSE
								AddToWideLog_0.Data.State		:= 0;
								AddToWideLog_0.Data.MessageB	:= 'Machine Idle - Low';
							END_IF
							AddToWideLog_0();
						END_IF
					END_FOR
					MIFlowOld[i] := MIFlow[i];
					AddToLog_0(Mode := 2, ValueID := 25, Value := MIFlow[i], Info := -1, );
				END_IF
			END_IF
	
			RInit[i] := FALSE;
	
			(*Log power off*)
			DTGetTime_1(enable := 1); (* Get Date and Time - *)
	
			IF (ArrAdrExternalPowerInput[i] > 0) THEN
				IF (EDGENEG(pExternalPowerInput.Out)) THEN
					PermData.DateTimeLog[i] := DTGetTime_1.DT1;
				END_IF
			ELSE
				PermData.DateTimeLog[i] := DTGetTime_1.DT1;
			END_IF
	
			(*Look for Change*)
			IF ((THourLog[i] > REAL_TO_UDINT(3600000 / CycleTime))) THEN
				HChange[i] := 1;
				THourLog[i] := 0;
			END_IF
	
			(*RealTimeData*)
	
			(*Initialize variables and FUBs*)
			OperatorOffset := 0;
			IntegrateCounter := 0;
			(* Realtime init moved to top so we can add the alarm *)
	
			AddToRealTime_0(RealTimeIdent:=ArrRealTimeExchange[i],Init:=1);
	
			(*Log all operators*)
			IF (JenViewSetupCfg[i].ProductionUnits + JenViewSetupCfg[i].Attendants > 0) THEN
				IF (JenViewSetupCfg[i].DisableOperatorLog) THEN
					OperatorOffset := JenViewSetupCfg[i].ProductionUnits;
				END_IF
				FOR Operator := 1 + OperatorOffset  TO (JenViewSetupCfg[i].ProductionUnits + JenViewSetupCfg[i].Attendants) DO
					IF RunTimeData.DisableOperatorLog THEN
						AddToRealTime_0(Displacement := Operator, pText := ADR('Opr'), DataNo := 0);
					ELSE
						AddToRealTime_0(Displacement := Operator, pText := ADR('Opr'), DataNo := PermData.Operator[Operator-1-OperatorOffset].ID);
					END_IF
				END_FOR
			END_IF
	
			(*For each production line do*)
			FOR Operator := 1 TO JenViewSetupCfg[i].ProductionUnits DO
	
				(*ACCESS RealTimeTmp Loggers Data*)
				pRealTimeTmpLog ACCESS ArrAdrRealTimeTmpLog[i] + (Operator - 1) * SIZEOF(pRealTimeTmpLog);
	
				(*Access production line data*)
				DataLogger ACCESS JenViewSetupCfg[i].AdrDataLogger + (Operator - 1) * SIZEOF(DataLogger); (*Acces correct memory*)
	
				(*Operator count*)
				IF NOT JenViewSetupCfg[i].NoneProduction THEN
					IF JenViewSetupCfg[i].TakeoffStation THEN (*Takeoff station*)
						IntegrateCounter := DataLogger.Production.Production.RcpTotal + pRealTimeTmpLog.RcpCnt + IntegrateCounter;
						IF Operator = JenViewSetupCfg[i].ProductionUnits THEN
							AddToRealTime_0(Displacement := 1, pText := ADR('OprCnt'), DataNo := IntegrateCounter);
							AddToRealTime_0(Displacement := 1, pText := ADR('OprMin'), DataNo := REAL_TO_UINT((DataLogger.OprLoggedTime + pRealTimeTmpLog.OprTime) / 60));
							AddToRealTime_0(Displacement := 1, pText := ADR('RcpCnt'), DataNo := IntegrateCounter);
						END_IF
					ELSE
						(*Operator time and count, log only if Operator login is not disabled*)
						IF NOT (JenViewSetupCfg[i].DisableOperatorLog) THEN
							AddToRealTime_0(Displacement := Operator, pText := ADR('OprCnt'), DataNo := DataLogger.Production.Production.OprTotal + pRealTimeTmpLog.OprCnt);
							AddToRealTime_0(Displacement := Operator, pText := ADR('OprMin'), DataNo := REAL_TO_UINT((DataLogger.OprLoggedTime + pRealTimeTmpLog.OprTime) / 60));
						END_IF
						(*Recepie count*)
						AddToRealTime_0(Displacement := Operator, pText := ADR('RcpCnt'), DataNo := DataLogger.Production.Production.RcpTotal + pRealTimeTmpLog.RcpCnt);
						AddToRealTime_0(Displacement := Operator, pText := ADR('Rewash'), DataNo := DataLogger.Production.Rewash.RcpTotal + pRealTimeTmpLog.RewashCnt);
						AddToRealTime_0(Displacement := Operator, pText := ADR('Repair'), DataNo := DataLogger.Production.Repair.RcpTotal + pRealTimeTmpLog.RepairCnt);
					END_IF
	
					IF (Operator = JenViewSetupCfg[i].ProductionUnits) THEN
						AddToRealTime_0(pText := ADR('Mode'), DataNo := DataLogger.Mode);
					END_IF
				END_IF
	
				(*Log the rest*)
				IF (DataLogger.SingleLaneOp) THEN
					IF NOT JenViewSetupCfg[i].NoneProduction THEN
						AddToRealTime_0(pText := ADR('Flow'), DataNo := SNFFlow[i]);
						AddToRealTime_0(Displacement := Operator, pText := ADR('RcpMin'), DataNo := REAL_TO_UINT(DataLogger.RcpLoggedTime + pRealTimeTmpLog.RcpTime) / 60);
						AddToRealTime_0(Displacement := Operator, pText := ADR('Norm'), DataNo := DataLogger.MetaData.TNorm);
					END_IF
					AddToRealTime_0(Displacement := Operator, pText := ADR('Cst'), DataNo := DataLogger.MetaData.CustNo);
					AddToRealTime_0(Displacement := Operator, pText := ADR('Art'), DataNo := DataLogger.MetaData.ArtNo);
					AddToRealTime_0(Displacement := Operator, pText := ADR('Rcp'), DataNo := DataLogger.MetaData.RcpNo+1);
				END_IF
			END_FOR
	
	
			AddToRealTime_0(pText := ADR('RunHours'), DataNo := UDINT_TO_UINT(RunTimeData.OperatingHours));
	
			AddToRealTime_0(pText := ADR('Status'), DataNo := Status[i]);
	
			(*Add info to RealtimeData here =) WEE *)
			IF RunTimeData.Status > 0  THEN
				AddToRealTime_0(pText := ADR('ErrorNo'), DataNo := RunTimeData.Status);
				AddToRealTime_0(pText := ADR('ErrorUK'), DataText := ADR(RunTimeData.StatusString));
				AddToRealTime_0(pText := ADR('ErrorLocal'), DataText := ADR(RunTimeData.StatusString));
			ELSE
				AddToRealTime_0(pText := ADR('ErrorNo'), DataNo := 0);
				AddToRealTime_0(pText := ADR('ErrorUK'), DataText := ADR(CleanRealTimeString));
				AddToRealTime_0(pText := ADR('ErrorLocal'), DataText := ADR(CleanRealTimeString));
			END_IF
			(*Log Add Ons*)
			FOR AddOnNo := 0 TO (SIZEOF(JenViewSetupCfg[i].AddOn) / SIZEOF(JenViewSetupCfg[i].AddOn[0]) ) -1 DO
				IF (JenViewSetupCfg[i].AddOn[AddOnNo].Ident > 0) THEN
					pAddOnFub ACCESS JenViewSetupCfg[i].AddOn[AddOnNo].Ident;
					AddToRealTime_0(pText := ADR(JenViewSetupCfg[i].AddOn[AddOnNo].AddOnName), DataNo := UDINT_TO_UINT(pAddOnFub.Value));
				END_IF
			END_FOR
			(*Realtime data end*)
			IF NOT UpdatePermData THEN
				PermDataUpdateTimer := PermDataUpdateTimer + 1;
			END_IF
	
			IF PermDataUpdateTimer >= REAL_TO_UDINT(1000 / CycleTime) * 5 THEN
				PermDataUpdateTimer := 0;
				UpdatePermData := TRUE;
			END_IF
			(*Write PermData*)
			IF (UpdatePermData) THEN
				DatObjWrite_0(enable:=1, ident:=PermData.Ident, Offset:=0, pSource:=ADR(PermData), len:=SIZEOF(PermData));
				IF (DatObjWrite_0.status = 0) THEN
					UpdatePermData := FALSE;
				END_IF
			END_IF
		END_FOR
	END_IF
END_PROGRAM

