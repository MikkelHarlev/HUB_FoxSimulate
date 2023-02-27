PROGRAM _CYCLIC
	IF NOT FirstTime AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageLocalBusStat AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageBusStat THEN
		RefreshPage := TRUE;
		RETURN;
	END_IF
	
	IF RefreshPage THEN
		Scan := TRUE;
		hw_search_step := 0;
	    cpu_found := FALSE;
		CycleCount := 0;
		RefreshPage := FALSE;
	END_IF
	
	IF Scan THEN
	    CASE hw_search_step OF
	        0:
				DiagCreateInfo_0(enable:=1,infoKind := asdiagPLUGGED OR asdiagCONFIGURED);
	            hwSearchStatus := DiagCreateInfo_0.status;                    (* Call function block *)
	
	   	        IF DiagCreateInfo_0.status(*hwSearchStatus*) = 0 THEN
	       	    	hw_search_step := 2;                                  (* Next step *)
	           		search_hw_status := 0;
	            ELSIF DiagCreateInfo_0.status(*hwSearchStatus*) = ERR_FUB_BUSY THEN
	   	        	search_hw_status := ERR_FUB_BUSY;                    (* RETURN that function is ready NOT yet *)
		       ELSE
		            ERRxwarning(1234, 0,ADR('ERROR DiagCreateInfo'));
	   	        	strcpy(ADR(HW_msg), ADR('ERROR DiagCreateInfo'));
	            	search_hw_status := 10;                              (* RETURN error *)
		            hw_search_step := 99;									(* Exit search loop *)
	            END_IF
	
			2:  (* Read numeric values OF all modules *)
	       		cpu_found := FALSE;
				CPUData[1].BType := 84;// Unknown
				CPUData[1].State := module_cfg.State;
				CPUData[1].Number := 0;
				strcpy(ADR(CPUData[1].Name),ADR(''));
	            FOR counter := 0 TO UDINT_TO_USINT(DiagCreateInfo_0.nrEntries-1) DO
	              	IF counter >= MAX_MODULE_COUNT  THEN
	              		counter :=UDINT_TO_USINT(DiagCreateInfo_0.nrEntries);
	              	ELSE
	              		DiagGetNumInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagMODUL_STATE); (* Get State *)
	              		module_cfg.State := UDINT_TO_USINT(DiagGetNumInfo_0.value);
						DiagGetNumInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagCONFIG_MODNO);
	           			module_cfg.ConfiguredNumber := UDINT_TO_UINT(DiagGetNumInfo_0.value);
						DiagGetNumInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagCONFIG_FAMILY);
	           			module_cfg.ConfiguredFamily := UDINT_TO_UINT(DiagGetNumInfo_0.value);
						DiagGetNumInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagCONFIG_USETYPE);
	           			module_cfg.ConfiguredType := UDINT_TO_UINT(DiagGetNumInfo_0.value);
	    	        	DiagGetStrInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagCONFIG_MODULE, pBuffer:=ADR(module_cfg.ModuleName), bufferLen:=MAX_MODULE_NAME_LEN - 1);
		            	DiagGetStrInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident, index:=counter, infoCode:=asdiagPATH, pBuffer:=ADR(PathString), bufferLen:=40);
						module_cfg.Station := 0;
						stage := 0;
						FOR I:=11 TO 40 DO
							IF PathString[I] = 0 THEN (* NULL *)
								I := 41;
							ELSIF stage = 0  AND PathString[I] = 46 THEN (* . *)
								stage := 1;
							ELSIF stage = 1 AND PathString[I] = 83 THEN (* S *)
								stage := 2;
							ELSIF stage = 2 AND PathString[I] = 84 AND module_cfg.ConfiguredFamily = 10 THEN (* X2X T *)
								stage := 3;
							ELSIF stage = 2 AND PathString[I] = 76 THEN (* PowerLink L *)
								stage := 3;
							ELSIF stage = 3 AND PathString[I] > 47 AND PathString[I] < 58 THEN (* 0-9 *)
								stage := 4;
								module_cfg.Station := PathString[I] - 48;
							ELSIF stage = 4 AND PathString[I] > 47 AND PathString[I] < 58 THEN (* 0-9 *)
								module_cfg.Station := module_cfg.Station * 10 + PathString[I] - 48;
							ELSE
								stage := 0;
							END_IF
						END_FOR
						IF module_cfg.ConfiguredFamily = 1 THEN (* PowerLink 2005 *)
							strcpy(ADR(TempStr),ADR(module_cfg.ModuleName));
							TempStr[6] := 0;
							LocalBus[module_cfg.Station].Status := module_cfg.State+80;
							IF module_cfg.ConfiguredNumber = 7 THEN (* DI476 *)
								strcpy(ADR(LocalBus[module_cfg.Station].Name),ADR(TempStr[1]));
								LocalBus[module_cfg.Station].Index := counter;
								LocalBus[module_cfg.Station].BType := 3;
							ELSIF module_cfg.ConfiguredNumber = 64 THEN (* DO479 *)
								strcpy(ADR(LocalBus[module_cfg.Station].Name),ADR(TempStr[1]));
								LocalBus[module_cfg.Station].Index := counter;
								LocalBus[module_cfg.Station].BType := 4;
							ELSIF module_cfg.ConfiguredNumber = 4717 THEN (* 3EX282 *)
								strcpy(ADR(LocalBus[0].Name),ADR(TempStr[1]));
								LocalBus[0].Index := counter;
								LocalBus[module_cfg.Station].BType := 1;
							ELSIF module_cfg.ConfiguredNumber = 4646 THEN (* 3IF7729 *)
	   							CPUData[2].BType := 22;
								CPUData[2].State := module_cfg.State;
								CPUData[2].Number := module_cfg.ConfiguredNumber;
								strcpy(ADR(CPUData[2].Name),ADR( module_cfg.ModuleName));
								strcpy(ADR(CPUData[2].Path),ADR( PathString));
							ELSIF module_cfg.ConfiguredNumber = 6791 THEN (* 3IF797 / 3IF797-1*)
	   							CPUData[1].BType := 72;
								CPUData[1].State := module_cfg.State+80;
								CPUData[1].Number := module_cfg.ConfiguredNumber;
								strcpy(ADR(CPUData[1].Name),ADR( module_cfg.ModuleName));
								strcpy(ADR(CPUData[1].Path),ADR( PathString));
							ELSIF module_cfg.ConfiguredNumber = 5090 THEN (* 3IF789.9 *)
	   							CPUData[1].BType := 71;
								CPUData[1].State := module_cfg.State+80;
								CPUData[1].Number := module_cfg.ConfiguredNumber;
								strcpy(ADR(CPUData[1].Name),ADR( module_cfg.ModuleName));
								strcpy(ADR(CPUData[1].Path),ADR( PathString));
							ELSIF module_cfg.ConfiguredNumber = 7662 THEN (* 3IF789.9-1 Same settings as 3IF789.9 *)
	   							CPUData[1].BType := 71;
								CPUData[1].State := module_cfg.State+80;
								CPUData[1].Number := module_cfg.ConfiguredNumber;
								strcpy(ADR(CPUData[1].Name),ADR( module_cfg.ModuleName));
								strcpy(ADR(CPUData[1].Path),ADR( PathString));
							ELSE
								IF (module_cfg.Station > 0) AND (module_cfg.Station < MAX_MODULE_POWERLINK) THEN
									LocalBus[module_cfg.Station].BType := 2;(* Dummy module *)
								END_IF
							END_IF
						ELSIF module_cfg.ConfiguredFamily = 4 THEN (* PowerPanel *)
		            	    IF NOT cpu_found THEN (* first one is always CPU ? *)
	   							CPUData[0].BType := 20;(*Always OK and On-Line *)
								CPUData[0].State := module_cfg.State;
								CPUData[0].Number := module_cfg.ConfiguredNumber;
								strcpy(ADR(CPUData[0].Name),ADR( module_cfg.ModuleName));
								strcpy(ADR(CPUData[0].Path),ADR( PathString));
	                    		cpu_found := TRUE;
								IF module_cfg.ConfiguredNumber = 45895 THEN (* PP65 Jensen *)
	   								CPUData[1].BType := 73;
									CPUData[1].State := module_cfg.State+80;
									CPUData[1].Number := module_cfg.ConfiguredNumber;
									strcpy(ADR(CPUData[1].Name),ADR( module_cfg.ModuleName));
									strcpy(ADR(CPUData[1].Path),ADR( PathString));	
								END_IF
							END_IF
						ELSIF module_cfg.ConfiguredFamily = 10 THEN (* X2X *)
							strcpy(ADR(TempStr),ADR(module_cfg.ModuleName));
							TempStr[9] := 0;
							strcpy(ADR(X2XBus[module_cfg.Station].Name),ADR(TempStr[3]));
							X2XBus[module_cfg.Station].Index := counter;
							X2XBus[module_cfg.Station].Status := module_cfg.State+80;
							(* Start with X67 modules *)
							IF module_cfg.ConfiguredNumber = 5172 THEN (* DI1371 *)
								X2XBus[module_cfg.Station].BType := 11;
							ELSIF module_cfg.ConfiguredNumber = 4881 THEN (* DM1321 *)
								X2XBus[module_cfg.Station].BType := 14;
							ELSIF module_cfg.ConfiguredNumber = 6360 THEN (* IF1121 *)
								X2XBus[module_cfg.Station].BType := 13;
							ELSIF module_cfg.ConfiguredNumber = 6352 THEN (* DC1198 *)
								X2XBus[module_cfg.Station].BType := 63;
							ELSIF module_cfg.ConfiguredNumber = 7627 THEN (* SM2436 *)
								X2XBus[module_cfg.Station].BType := 65;
							ELSIF module_cfg.ConfiguredNumber = 7966 THEN (* BC0083 *)
								X2XBus[module_cfg.Station].BType := 67;
							ELSIF module_cfg.ConfiguredNumber = 8076 THEN (* PS9400 *)
								X2XBus[module_cfg.Station].BType := 31;
							ELSIF module_cfg.ConfiguredNumber = 5223 THEN (* DO1332 *)
								X2XBus[module_cfg.Station].BType := 12;
							ELSIF module_cfg.ConfiguredNumber = 5256 THEN (* AT1322 *)
								X2XBus[module_cfg.Station].BType := 15;
							ELSIF module_cfg.ConfiguredNumber = 7105 THEN (* BR9300 *)
								X2XBus[module_cfg.Station].BType := 33;
							ELSIF module_cfg.ConfiguredNumber = 7059 THEN (* DI6371 *)
								X2XBus[module_cfg.Station].BType := 36;
							ELSIF module_cfg.ConfiguredNumber = 7058 THEN (* DI4371 *)
								X2XBus[module_cfg.Station].BType := 35;
							ELSIF module_cfg.ConfiguredNumber = 7103 THEN (* PS2100 *)
								X2XBus[module_cfg.Station].BType := 31;
							ELSIF module_cfg.ConfiguredNumber = 7063 THEN (* DO4322 *)
								X2XBus[module_cfg.Station].BType := 39;
							ELSIF module_cfg.ConfiguredNumber = 7066 THEN (* DO9322 *)
								X2XBus[module_cfg.Station].BType := 41;
							ELSIF module_cfg.ConfiguredNumber = 7064 THEN (* DO6322 *)
								X2XBus[module_cfg.Station].BType := 40;
							ELSIF module_cfg.ConfiguredNumber = 7106 THEN (* BT9100 *)
								X2XBus[module_cfg.Station].BType := 32;
							ELSIF module_cfg.ConfiguredNumber = 7104 THEN (* BR3300 *)
								X2XBus[module_cfg.Station].BType := 34;
							ELSIF module_cfg.ConfiguredNumber = 7061 THEN (* DI9371 *)
								X2XBus[module_cfg.Station].BType := 37;
							ELSIF module_cfg.ConfiguredNumber = 7069 THEN (* DO8332 *)
								X2XBus[module_cfg.Station].BType := 42;
							ELSIF module_cfg.ConfiguredNumber = 7079 THEN (* AT4222 *)
								X2XBus[module_cfg.Station].BType := 66;
							ELSIF module_cfg.ConfiguredNumber = 7082 THEN (* AI4622 *)
								X2XBus[module_cfg.Station].BType := 62;
							ELSIF module_cfg.ConfiguredNumber = 7074 THEN (* AO2622 *)
								X2XBus[module_cfg.Station].BType := 64;
							ELSIF module_cfg.ConfiguredNumber = 43394 THEN (* MM3332 *)
								X2XBus[module_cfg.Station].BType := 68;
							ELSE
								X2XBus[module_cfg.Station].BType 	:= 48;(* Unknown *)
								X2XBus[module_cfg.Station].Status 	:= 0;
								UnKnownType 						:= module_cfg.ConfiguredNumber;
							END_IF
						END_IF
	            	END_IF
	         	END_FOR
	            hw_search_step := 4;                                         (* Next step *)
	        4:
				DiagDisposeInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident);
	            hwSearchStatus := DiagDisposeInfo_0.status;
	            IF hwSearchStatus = 0 THEN
	               hw_search_step := 5;                                      (* Next step *)
	               search_hw_status := ERR_FUB_BUSY;                        (* RETURN that function is ready NOT yet *)
	            ELSIF hwSearchStatus = ERR_FUB_BUSY THEN
	               search_hw_status := ERR_FUB_BUSY;                        (* RETURN that function is ready NOT yet *)
	            ELSE
	               hw_search_step := 5;                                      (* Next step *)
	               strcpy(ADR(HW_msg), ADR('ERROR DiagDisposeInfo'));
	               search_hw_status := ERR_FUB_BUSY;                        (* RETURN that function is ready NOT yet *)
	            END_IF
	        5:
	            HW_msg[0] := 0;                                              (* Delete hardware message *)
	            (* Analyse hardware *)
	            IF cpu_found THEN                                        (* IF cpu is present *)
	                ;(* TODO *)
	            ELSE
	                strcpy(ADR(HW_msg), ADR('ERROR: Unknown HW configuration'));
	            END_IF
	            hw_search_step := 99;
	            search_hw_status := 1;                                      (* RETURN that function is ready now *)
		END_CASE
	    IF hw_search_step = 99  THEN                     (* IF HW_Search has finished *)
	        Scan := FALSE;
			IF DiagCreateInfo_0.ident > 0 THEN
				DiagDisposeInfo_0(enable:=1, ident:=DiagCreateInfo_0.ident);
			END_IF
	        FirstTime := FALSE;
	    END_IF
	END_IF
	
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageBusStat THEN
		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			IF SelectedDecade > 0 THEN
				SelectedDecade :=  SelectedDecade - 1;
			END_IF
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			IF SelectedDecade < (MAX_MODULE_X2X/10)-1 THEN
				SelectedDecade :=  SelectedDecade + 1;
			END_IF
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			InterFaceShowCount := 25; // Pop-up interface layer for 5 sec (20ms task cycle).
		END_IF
		
		IF CPUData[0].Number = 45895 THEN // PP65 Jensen style SFX 110412 Maybe do we need to detect also othe PP65 models ?
			// Powerlink module should be seen also
			FOR I:= 1 TO 10 DO
				CurrentX2XDecade[I] := X2XBus[I-1+SelectedDecade*10];
				CurrentX2XNode[I] := I-1+SelectedDecade*10;
			END_FOR
		ELSE
			FOR I:= 1 TO 10 DO
				CurrentX2XDecade[I] := X2XBus[I+SelectedDecade*10];
				CurrentX2XNode[I] := I+SelectedDecade*10;
			END_FOR
		END_IF	
	//	IF SelectedDecade = 0 THEN 
	//		g_Core.Services.HMIHandler.Runtime.Handler[0]..Group.Service.HMIHandler.ButtonMagic[0].Locked[0] := 1;
	//	ELSE		
	//		Local.Core.Group.Service.HMIHandler.ButtonMagic[0].Locked[0] := 0;
	//	END_IF
	//	IF SelectedDecade = (MAX_MODULE_X2X/10)-1 THEN 
	//		Local.Core.Group.Service.HMIHandler.ButtonMagic[0].Locked[1] := 1;
	//	ELSE		
	//		Local.Core.Group.Service.HMIHandler.ButtonMagic[0].Locked[1] := 0;
	//	END_IF
	//	g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed := 0;(* always clear key *)
	END_IF
	
	IF InterFaceShowCount > 0 THEN
		InterFaceShowCount := InterFaceShowCount - 1;
		InterFaceHide := 0;
	ELSE
		InterFaceHide := 1;
	END_IF	
	CycleCount := CycleCount + 1;
	IF CycleCount > UpdateIntervall THEN
		RefreshPage := TRUE;
	END_IF
END_PROGRAM

