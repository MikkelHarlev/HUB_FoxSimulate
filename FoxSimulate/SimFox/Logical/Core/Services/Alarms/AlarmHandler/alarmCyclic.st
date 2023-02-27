PROGRAM _CYCLIC
	// What is the point?

	IF (pThis.Runtime.MachineAlarmPageID = 0 AND g_Core.Services.HMIHandler.Runtime.Handler[0].isInitDone) THEN
		pThis.Runtime.MachineAlarmPageID := LookupPageID(400,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		RETURN;
	END_IF

	// Set UserGroupIDs from App configuration.
	pThis.Runtime.UserGroupID := pThis.Interface.UserGroupID;
	
	FOR alarmGroupNo := 0 TO 19 DO
		numerOfAlarms 	:= 0;
		CASE alarmGroupNo OF
			CORE_ALARMS: // Map alarms from interface to VIS Alarm handler.
				pBOOLs ACCESS ADR(g_Core.System.Interface.alarms);		
				numerOfAlarms 	:= 17;

			CORE_USER:
				pBOOLs ACCESS ADR(g_Core.System.Interface.infos);		
				numerOfAlarms 	:= 10;
		END_CASE
		IF numerOfAlarms <> 0 THEN
			FOR i := 0 TO (numerOfAlarms - 1) DO
				pThis.Interface.AlarmGroup[alarmGroupNo].Alarm[i] := pBOOLs[i];
			END_FOR
		END_IF
	END_FOR
	// Show Ack Buttom In Alarm Page
	pThis.Runtime.AckShow := NOT g_Core.System.Configuration.isShowAlarmAckButton;

	ServiceLog.Timestamp := g_Core.Services.Time.Runtime.Date_Time;

	// Define Core Group common warnings.
	CASE (pThis.Runtime.Event[MACHINE].GroupID*1000+pThis.Runtime.Event[MACHINE].AlarmID) OF

	    1000:   (*Emergency*)
	        WarningIconIndex := 1;
	    1001:   (*Guard Fault*)
	        WarningIconIndex := 4;
	    1002:   (*Thermo Fault*)
	        WarningIconIndex := 2;
	    1003: (*Fuse Fault*)
	        WarningIconIndex := 3;
	    1004: (*Low Air Pressure *)
	        WarningIconIndex := 4;
	    1005:      (*Battery Low*)
	        WarningIconIndex := 0;
	    ELSE
	        WarningIconIndex := 0;
	END_CASE

	// Blinker
		TON_10ms_0(IN:= NOT TON_10ms_0.Q, PT:= 60);
		IF TON_10ms_0.Q THEN
			pThis.Runtime.blinkPulse := NOT pThis.Runtime.blinkPulse;
		END_IF

	// External Alarm / Info Handling
		FOR i := 0 TO 1 DO
			// External Info Handling
			rTrigExternInfo[i].CLK := pThis.Interface.ExternInfo[i].isActive;
			rTrigExternInfo[i]();
			g_Core.System.Interface.infos.isExternInfo[i] 	:= pThis.Interface.ExternInfo[i].isActive;
			// Wee need to also check for string changes.
			//IF (rTrigExternInfo[i].Q) THEN
				externInfoStringLenght := strlen( ADR( pThis.Interface.ExternInfo[i].descriptionAscii));	
				IF (externInfoStringLenght > 0) THEN
					// Clea Old Unicode String.
					// "frame" Buffer
					memset(ADR(tmpUnicode),0,SIZEOF(tmpUnicode));
					//memset(ADR(pThis.Interface.ExternInfo[i].descriptionUnicode),0,SIZEOF(pThis.Interface.ExternInfo[i].descriptionUnicode));
					// Convert Text to Unicode.
					//stringToWString(ADR(pThis.Interface.ExternInfo[i].descriptionUnicode), ADR(pThis.Interface.ExternInfo[i].descriptionAscii), SIZEOF(pThis.Interface.ExternInfo[i].descriptionUnicode));
					stringToWString(ADR(tmpUnicode), ADR(pThis.Interface.ExternInfo[i].descriptionAscii), SIZEOF(pThis.Interface.ExternInfo[i].descriptionUnicode));
					memcpy(ADR(pThis.Interface.ExternInfo[i].descriptionUnicode), ADR(tmpUnicode), SIZEOF(pThis.Interface.ExternInfo[i].descriptionUnicode));
				END_IF
			//END_IF

			// External Alarm Handling
			rTrigExternAlarm[i].CLK := pThis.Interface.ExternAlarm[i].isActive;
			rTrigExternAlarm[i]();
			g_Core.System.Interface.alarms.isExternAlarm[i] := pThis.Interface.ExternAlarm[i].isActive;
			externAlarmStringLenght := strlen( ADR( pThis.Interface.ExternAlarm[i].descriptionAscii));
			// Wee need to also check for string changes.
			//IF (rTrigExternAlarm[i].Q) THEN
				IF (externAlarmStringLenght > 0) THEN
					// Clea Old Unicode String.
					// "frame" Buffer.
					memset(ADR(tmpUnicode),0,SIZEOF(tmpUnicode));
					//memset(ADR(pThis.Interface.ExternAlarm[i].descriptionUnicode),0,SIZEOF(pThis.Interface.ExternAlarm[i].descriptionUnicode));
					// Convert Text to Unicode.
					//stringToWString(ADR(pThis.Interface.ExternAlarm[i].descriptionUnicode), ADR(pThis.Interface.ExternAlarm[i].descriptionAscii), SIZEOF(pThis.Interface.ExternAlarm[i].descriptionUnicode));
					stringToWString(ADR(tmpUnicode), ADR(pThis.Interface.ExternAlarm[i].descriptionAscii), SIZEOF(pThis.Interface.ExternAlarm[i].descriptionUnicode));
					memcpy(ADR(pThis.Interface.ExternAlarm[i].descriptionUnicode), ADR(tmpUnicode), SIZEOF(pThis.Interface.ExternAlarm[i].descriptionUnicode));
				END_IF
			//END_IF
		END_FOR	
 
	(*	Show Machine Alarm line if at least one alarm is active	*)
	IF (pThis.Runtime.Event[MACHINE].Status > 0) THEN
		(*Global for all screens*)
		IF EDGEPOS(pThis.Runtime.Event[MACHINE].Status > 0) THEN
			FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
				AlarmHeaderColor[i] := COLOR_RED_45;
			END_FOR
			memset(ADR(Blink),1,SIZEOF(Blink)); // Activate blink on all screens
		END_IF
		
		FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
			IF Alarm[i].AlarmShortcut = 1 THEN
				IF AlarmPressed[i] THEN
					AlarmHeaderColor[i] := COLOR_YELLOW_41;
					Blink[i]			:= FALSE;
				END_IF
				AlarmPressed[i] := TRUE;
				pThis.Interface.AlarmGroup[pThis.Runtime.Event[MACHINE].GroupID-1].Ack[pThis.Runtime.Event[MACHINE].AlarmID] := FALSE;
			ELSE
				IF AlarmPressed[i] THEN
					AlarmToTop[i] 											:= TRUE;
					g_Core.Services.Alarmhandler.Runtime.isSendAlarmToTop 	:= TRUE;
					AlarmPressed[i] 										:= FALSE;
				END_IF
				Blink[i]			:= TRUE;
				AlarmHeaderColor[i] := COLOR_RED_45;
				
				pThis.Interface.AlarmGroup[g_Core.Services.Alarmhandler.Runtime.Event[MACHINE].GroupID-1].Ack[g_Core.Services.Alarmhandler.Runtime.Event[MACHINE].AlarmID] := pThis.Interface.AlarmGroup[g_Core.Services.Alarmhandler.Runtime.Event[MACHINE].GroupID-1].Alarm[g_Core.Services.Alarmhandler.Runtime.Event[MACHINE].AlarmID];
				// External Alarm Color Handling
				IF pThis.Runtime.Event[MACHINE].GroupID = 1 THEN
					CASE pThis.Runtime.Event[MACHINE].AlarmID OF
						15:	// ExternAlarm 1
							IF (g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].color > 0) THEN
								AlarmHeaderColor[i] := g_Core.Services.Alarmhandler.Interface.ExternAlarm[0].color;
							ELSE
								AlarmHeaderColor[i] := COLOR_ORANGE_48;
							END_IF
						16:	// ExternAlarm 2
							IF (g_Core.Services.Alarmhandler.Interface.ExternAlarm[1].color > 0) THEN
								AlarmHeaderColor[i] := g_Core.Services.Alarmhandler.Interface.ExternAlarm[1].color;
							ELSE
								AlarmHeaderColor[i] := COLOR_DARKRED_80;
							END_IF
					END_CASE
				END_IF
				// Set Ack Again, If Alarm Still On  
				pThis.Interface.AlarmGroup[pThis.Runtime.Event[MACHINE].GroupID-1].Ack[pThis.Runtime.Event[MACHINE].AlarmID] := pThis.Interface.AlarmGroup[pThis.Runtime.Event[MACHINE].GroupID-1].Alarm[pThis.Runtime.Event[MACHINE].AlarmID];
			END_IF
			//Handle input from each panel
			//TDelay[i].IN := USINT_TO_BOOL(Alarm[i].AlarmShortcut);
			TDelay[i].IN := (Alarm[i].AlarmShortcut = 1);
			TDelay[i](PT := 120);

			IF TDelay[i].Q AND (Alarm[i].AlarmShortcut = 0) THEN
				pThis.Runtime.Event[MACHINE].Acknowledged := TRUE;
			END_IF;
			IF (Alarm[i].AlarmShortcut = 1 AND NOT TDelay[i].Q) (*OR Alarm[i].AlarmShortcut = 2*) THEN
				Alarm[i].AlarmShortcut := 0;
				CallPageControllerLink(pThis.Runtime.MachineAlarmPageID, g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler); (* Alarm page *)
			END_IF
			IF Alarm[i].AlarmShortcut = 2 THEN
				Alarm[i].AlarmShortcut := 0;
				// Show AlarmMachinepage...?
				IF pThis.Interface.MachineAlarmPage > 0 THEN
		            //pThis.Interface.isShowAlarmMachinePage := FALSE;
					CallPageControllerLink(LookupPageID(pThis.Interface.MachineAlarmPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler), g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler); (* Alarm machine page *)
				ELSE
		            CallPageControllerLink(pThis.Runtime.MachineAlarmPageID, g_Core.Services.HMIHandler.Runtime.Handler[i].pPanelHandler); (* Alarm page *)
				END_IF
			END_IF
			IF Alarm[i].AlarmShortcut = 3 THEN
				Alarm[i].AlarmShortcut := 0;
				AlarmToTop[i] := TRUE;
			END_IF
			
			(*Show / Hide Alarm*)
			IF g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = SYSTEM_MAIN_PAGE_1 AND NOT AlarmToTop[i] THEN
				Alarm[i].AlarmActiveFront 	:= ALARM_LINE_SHOW;
				Alarm[i].AlarmActiveTop 	:= ALARM_LINE_HIDE;
			ELSE
				Alarm[i].AlarmActiveFront 	:= ALARM_LINE_HIDE;
				Alarm[i].AlarmActiveTop 	:= ALARM_LINE_SHOW;
			END_IF
		
			//Change colors noget må kunne slettes!
			IF Blink[i] AND NOT pThis.Runtime.blinkPulse THEN
	            FrontTextColor 			:= 4041;
				IF g_Core.Services.HMIHandler.Runtime.Handler[i].PageControllerID = SYSTEM_MAIN_PAGE_1 AND NOT AlarmToTop[i] THEN
					Alarm[i].FrontColor	:= AlarmHeaderColor[i];
					Alarm[i].HeaderColor:= COLOR_HEADER_NORMAL;
				ELSE
					Alarm[i].HeaderColor:= AlarmHeaderColor[i];
				END_IF
				Alarm[i].HeaderTextColor:= COLOR_TEXT_ALARM;
	        ELSE
	            FrontTextColor 				:= 11721;
				IF AlarmPressed[i] THEN
					Alarm[i].FrontColor		:= AlarmHeaderColor[i];
					IF AlarmToTop[i] THEN
						Alarm[i].HeaderColor	:= AlarmHeaderColor[i];
					END_IF
				ELSE
					Alarm[i].FrontColor		:= COLOR_WHITE_15;
					Alarm[i].HeaderColor	:= COLOR_HEADER_NORMAL;
				END_IF
				Alarm[i].HeaderTextColor:= COLOR_TEXT_NO_ALARM;
			END_IF
		END_FOR
	END_IF

	(*V3.01 FIX*)
	IF EDGEPOS(pThis.Runtime.Event[MACHINE].Status = 0) THEN
		FOR i := 0 TO (g_Core.Services.HMIHandler.Runtime.HandlersRunning -1) DO
			AlarmToTop[i]					:= FALSE;
			pThis.Runtime.isSendAlarmToTop 	:= FALSE;
			Alarm[i].AlarmActiveFront 		:= TRUE;
			Alarm[i].AlarmActiveTop 		:= TRUE;
			Alarm[i].FrontColor				:= COLOR_WHITE_15;
			Alarm[i].HeaderColor			:= COLOR_HEADER_NORMAL;
			Alarm[i].HeaderTextColor		:= COLOR_TEXT_NO_ALARM;
		END_FOR
	END_IF

	// Disable most alarm cache handling if running as remotepanel, act stupid.
	IF (g_Core.System.Configuration.isRemotePanelModeEnabled) THEN
		RETURN;
	END_IF

	AlarmPriority := 0;
	Access_Status := VA_Saccess (1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
	IF Access_Status = 0 THEN
		CASE step OF
	    	1,2:
	    		(*Reset Alarm*)
	    		IndexSet := FALSE;
	    		AlarmUpdated := FALSE;
	    		IF step = 1 THEN
	    			ScanComplete := FALSE;
					FOR i := 0 TO SIZEOF(AlarmCache) / SIZEOF(AlarmCache[0]) - 1 DO
						IF AlarmCache[i].Status = 1 THEN
							AlarmCache[i].Status := 2; (*Reset status if Active*)
						END_IF
					END_FOR
	    		END_IF
	        	Alarmlen := 80;
	            Seperator := 215; (*Hyphen*)
	            Alarmtype := step; (*Read first alarm*)
	            TimeDateForm := 6; (*DD.MM.YY HH.MM.SS*)

	            GetActAL_Status := VA_wcGetActAlarmList(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler,ADR(Alarmstring),ADR(Alarmlen),Alarmtype,Seperator,TimeDateForm);
	            CASE GetActAL_Status OF
	            	0:
	            		dChar ACCESS ADR(Alarmstring);
	            		FOR SubStep := 0 TO 3 DO

							StartAdr := ADR(dChar) + 2; (*Skip first char, allways -*)
	            			dChar ACCESS StartAdr;
							WHILE (dChar <> 215) DO
								dChar ACCESS ADR(dChar)+2;
							END_WHILE
							memset(ADR(TmpString),0,SIZEOF(TmpString));
							memcpy(ADR(TmpString), StartAdr, ADR(dChar) - StartAdr);
							CASE SubStep OF
								0,1:  (*Get Alarm group AND ID*)
									memset(ADR(TmpString2),0,SIZEOF(TmpString2));
									eChar ACCESS ADR(TmpString);
									FOR i := 0 TO SIZEOF(TmpString2) -1 DO
										TmpString2[i] := UINT_TO_USINT(eChar);
										eChar ACCESS ADR(eChar)+2;
									END_FOR
									CASE SubStep OF
										0: AlarmGroupIndex := DINT_TO_UINT(atoi(ADR(TmpString2)));
										1: AlarmIndex := DINT_TO_UINT(atoi(ADR(TmpString2)));
									END_CASE

								2:	(*Acknowledgement status*)
									memcpy(ADR(AlarmText),ADR(TmpString),SIZEOF(AlarmText));
								
								3:	(*Acknowledgement status*)
									strcpy(ADR(AlarmStatus),ADR(TmpString));

							END_CASE
						END_FOR
						IF MaxGroup < AlarmGroupIndex THEN
							MaxGroup := AlarmGroupIndex;
						END_IF
						FOR i := 0 TO SIZEOF(AlarmCache) / SIZEOF(AlarmCache[0]) - 1 DO
							TextSameAsOldText := memcmp(ADR(AlarmCache[i].DescUniCode),ADR(AlarmText),SIZEOF(AlarmCache[i].DescUniCode));
							IF (AlarmCache[i].AlarmID = AlarmIndex) AND AlarmCache[i].GroupID = AlarmGroupIndex AND (*TextSameAsOldText = 0 AND EG*) AlarmGroupIndex > 0 THEN
								AlarmCache[i].DescUniCode := AlarmText;
	                            AlarmCache[i].Status := 1;
								AlarmCache[i].AckStatus := AlarmStatus;
//								AlarmCache[i].DateTime := g_Core.Services.Time.Runtime.Date_Time;
//								IF strcmp(ADR(AlarmCache[i].DescAscii), ADR(AlarmCache[i].DescAsciiPrev)) > 0 THEN
//									strcpy(ADR(MHATestStr[mI]), ADR(AlarmCache[i].DescAscii));
//									MHATest[mI/2] := strcmp(ADR(AlarmCache[i].DescAscii), ADR(AlarmCache[i].DescAsciiPrev));
//									mI := (mI + 1) MOD (SIZEOF(MHATestStr) / SIZEOF(MHATestStr[0]));
//									strcpy(ADR(MHATestStr[mI]), ADR(AlarmCache[i].DescAsciiPrev));
//									mI := (mI + 1) MOD (SIZEOF(MHATestStr) / SIZEOF(MHATestStr[0]));
//									strcpy(ADR(AlarmCache[i].DescAsciiPrev), ADR(AlarmCache[i].DescAscii));
//									AlarmCache[i].DateTime := g_Core.Services.Time.Runtime.Date_Time;
//								END_IF
								AlarmUpdated := TRUE;
							END_IF
							IF AlarmCache[i].Status = 0 AND NOT IndexSet THEN
								FreeIndex := i;
								IndexSet := TRUE;
							END_IF
						END_FOR
						IF NOT AlarmUpdated THEN
							AlarmCache[FreeIndex].AlarmID := AlarmIndex;
							AlarmCache[FreeIndex].GroupID := AlarmGroupIndex;
							AlarmCache[FreeIndex].DateTime := g_Core.Services.Time.Runtime.Date_Time;
							memcpy(ADR(AlarmCache[FreeIndex].DescUniCode),ADR(AlarmText),SIZEOF(AlarmCache[FreeIndex].DescUniCode));
							pChar ACCESS ADR(AlarmCache[FreeIndex].DescAscii);
							FOR y := 0 TO SIZEOF(AlarmCache[FreeIndex].DescAscii) - 2 DO
								(*Strip unicode =) wee*)
								pChar := UINT_TO_USINT(AlarmCache[FreeIndex].DescUniCode[y]);
								pChar ACCESS ADR(pChar) + 1;
							END_FOR
							AlarmCache[FreeIndex].Status := 1;
							CASE AlarmGroupIndex OF
								2,4:
									Severity := 50;
								1,3:
									Severity := 10;
								ELSE
									Severity := 50;
							END_CASE
							AlarmCache[FreeIndex].Severity := Severity;
							AlarmCache[FreeIndex].Priority := pThis.Interface.AlarmGroup[AlarmCache[FreeIndex].GroupID-1].Priority[AlarmCache[FreeIndex].AlarmID];
							IF NOT (AlarmCache[FreeIndex].AlarmID = 0 AND (AlarmCache[FreeIndex].GroupID = pThis.Runtime.UserGroupID[0]) )THEN
								// ^^ Replace by ignorelist? ^^
								ServiceLog.Event.Description 	:= AlarmCache[FreeIndex].DescAscii;
								ServiceLog.Event.GroupID 		:= AlarmCache[FreeIndex].GroupID;
								ServiceLog.Event.ID			 	:= AlarmCache[FreeIndex].AlarmID;
								ServiceLog.Event.Severity 		:= AlarmCache[FreeIndex].Priority;
								ServiceLog.Event.Status 		:= AlarmCache[FreeIndex].Status;
								LogWrite_0();
							
								LogData_0(Lane:=1, Type:=EVENT, Info1:=AlarmCache[FreeIndex].AlarmID, Info2:=AlarmCache[FreeIndex].GroupID, MessageA:=ADR(AlarmCache[FreeIndex].DescAscii), Info3 := AlarmCache[FreeIndex].Status, Info4 := AlarmCache[FreeIndex].Severity);
							END_IF
						END_IF
						step := 2;
					240: (*Restart - delay?*)
						NoOfMAlarms := 0;
						FOR i := 0 TO SIZEOF(AlarmCache) / SIZEOF(AlarmCache[0]) - 1 DO
							IF (AlarmCache[i].GroupID <> pThis.Runtime.UserGroupID[0] OR AlarmCache[i].GroupID <> pThis.Runtime.UserGroupID[1]) AND AlarmCache[i].Status = 1 THEN
								NoOfMAlarms := NoOfMAlarms + 1;
							END_IF
							IF AlarmCache[i].Status = 2 THEN
								AlarmCache[i].Status := 0; (*Reset status if Active*)
								IF NOT (AlarmCache[i].AlarmID = 0 AND AlarmCache[i].GroupID = 1) THEN
									IF NOT (AlarmCache[FreeIndex].AlarmID = 0 AND (AlarmCache[FreeIndex].GroupID = pThis.Runtime.UserGroupID[0]) )THEN
										ServiceLog.Event.Description 	:= AlarmCache[i].DescAscii;
										ServiceLog.Event.GroupID 		:= AlarmCache[i].GroupID;
										ServiceLog.Event.ID			 	:= AlarmCache[i].AlarmID;
										ServiceLog.Event.Severity 		:= AlarmCache[i].Priority;
										ServiceLog.Event.Status 		:= AlarmCache[i].Status;
										LogWrite_0();
								
										LogData_0(Lane:=1, Type:=EVENT, Info1:=AlarmCache[i].AlarmID, Info2:=AlarmCache[i].GroupID, MessageA:=ADR(AlarmCache[i].DescAscii), Info3 := AlarmCache[i].Status, Info4 := AlarmCache[i].Severity);
									END_IF
								END_IF
								(*Write OK IN LOG*)
								(*Reset alarm, eliminate it destroy it kill it nill it*)
								memset(ADR(AlarmCache[i]),0,SIZEOF(AlarmCache[i]));
							ELSIF AlarmCache[i].Status = 1 THEN
								(*Get Machine alarm texts*)
								// EG Setup rule for User / Machine type
									IF (AlarmCache[i].GroupID = pThis.Runtime.UserGroupID[0] OR AlarmCache[i].GroupID = pThis.Runtime.UserGroupID[1])THEN
										EventType := USER;
									ELSE
										EventType := MACHINE;
									END_IF
									// Check for Acknowlegde status from vis.
									IF strcmp(ADR('A'),ADR(AlarmCache[i].AckStatus)) <> 0 THEN
										IF EventPatch[EventType].Priority <= pThis.Interface.AlarmGroup[AlarmCache[i].GroupID-1].Priority[AlarmCache[i].AlarmID] THEN
											EventPatch[EventType].Priority := pThis.Interface.AlarmGroup[AlarmCache[i].GroupID-1].Priority[AlarmCache[i].AlarmID];
											EventPatch[EventType].ID := i;
											EventPatch[EventType].Set := TRUE;
											IF EventType = MACHINE THEN
												Priority	:= EventPatch[EventType].Priority;
											END_IF
										END_IF
									END_IF
							END_IF
						END_FOR
						(*Or use a Checksum*)
						IF (AlarmCache[EventPatch[0].ID].GroupID <> pThis.Runtime.Event[0].GroupID AND AlarmCache[EventPatch[0].ID].AlarmID <> pThis.Runtime.Event[0].AlarmID ) THEN
							memset(ADR(AlarmToTop),0,SIZEOF(AlarmToTop));
						END_IF
						//IF OldNoOfMAlarms <> NoOfMAlarms THEN
						//	memset(ADR(AlarmToTop),0,SIZEOF(AlarmToTop));
						//END_IF
						OldNoOfMAlarms := NoOfMAlarms;

						(*Set MachineAlarm*)
						// For loop for user and machine eventt patches.
						FOR i := 0 TO 1 DO
							IF EventPatch[i].Set THEN // TODO Set System alarm instead of making an exception!
								IF i = 0 THEN
									g_Core.System.Interface.infos.isCheckAlarm := TRUE;
									//AlarmInfo[g_Core.Services.Alarmhandler.Runtime.UserGroupID-1].Alarm[0] := TRUE;
								END_IF
								// SFX HOw to set text "Check Alarm"
								pThis.Runtime.Event[i] := AlarmCache[EventPatch[i].ID];
								EventPatch[i].Set := FALSE;
								EventPatch[i].Priority := 0;
								//memset(ADR(EventPatch[i]),0,SIZEOF(EventPatch[i]));
							ELSE
								memset(ADR(pThis.Runtime.Event[i]),0,SIZEOF(pThis.Runtime.Event[i]));
								IF i = 0 THEN
									g_Core.System.Interface.infos.isCheckAlarm := FALSE;
									//AlarmInfo[g_Core.Services.Alarmhandler.Runtime.UserGroupID-1].Alarm[0] := FALSE;
								END_IF
							END_IF
						END_FOR
						step := 1;
	            		ScanComplete := TRUE;
	            END_CASE
		END_CASE
	    VA_Srelease(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pVCHandler);
	END_IF

	(* Update Logfile *)
	IF Update > (200) THEN
		Update := 0;
		Store  := 1;
	END_IF;

	IF (Store = 1) THEN
		LogStore_0(enable := 1, ident := LogInit_0.ident);
		IF (LogStore_0.status <> 65535) THEN
			Store := 0;
		END_IF;
	END_IF;

	IF Store = 0 THEN
		Update := Update + 1;
	END_IF

	MHATest;

END_PROGRAM