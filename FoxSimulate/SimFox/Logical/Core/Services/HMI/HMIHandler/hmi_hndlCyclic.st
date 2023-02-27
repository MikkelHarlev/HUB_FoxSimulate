PROGRAM _CYCLIC
	// Reaccess..
	pInterface ACCESS ADR(g_Core.Services.HMIHandler);
	// Retrigger reset
	FOR i := 0 TO (SIZEOF(PanelHandler) / SIZEOF(PanelHandler[0]) -1) DO
		rTrig[i].CLK := (PanelHandler[i].Page.Active = 9998);
		rTrig[i]();
	END_FOR

	CASE pInterface.Runtime.initState OF
			
		INIT:
			//
			// Waiting for the system to initialize
			//
			// Show Spinner
			//
			pInterface.Runtime.hideSpinner := TRUE;
			//
			// Running the Spinner
			//
			IF (UpdateSpinCount >= SpinCountSpeed) THEN
				UpdateSpinCount := 0;
				IF (pInterface.Runtime.SpinnerIndex = 7) THEN
					pInterface.Runtime.SpinnerIndex := 0;
				ELSE
					pInterface.Runtime.SpinnerIndex := pInterface.Runtime.SpinnerIndex + 1;
				END_IF
			END_IF
			
			UpdateSpinCount := UpdateSpinCount + 1;
			BootCalc 		:= BootCalc + 1;
			//
			// IF System init is done or system init has timed out go to run mode.
			//
 			IF ((g_Core.System.Runtime.isInitDone AND BootCalc >100)OR BootCalc > 2000) THEN
				pInterface.Runtime.initState := RUNTIME;
				//
				// First time we hit system init done set HMI Handlers system init done high, this makes some sub processes kick in, eg. password reading.
				//
				FOR i := 0 TO (SIZEOF(PanelHandler) / SIZEOF(PanelHandler[0]) -1) DO
					pInterface.Runtime.Handler[i].SystemInitDone := TRUE;
				END_FOR
			END_IF
	
		RUNTIME:
			//
			// Display main screen and go into Run mode when system initialization is done. 
			//
			// Run all handlers and update on screen menu buttons.
			//
			FOR i := 0 TO (SIZEOF(PanelHandler) / SIZEOF(PanelHandler[0]) -1) DO
				IF (PanelHandler[i].Init.Enabled) THEN
					PanelHandler[i]();
					//
					// Kick in 'disable screen calibration function if needed
					//
					pInterface.Runtime.Handler[i].isDisableScreenCalibration := pInterface.Interface.Handler[i].isDisableScreenCalibration;
					//
					// Enable Icons on buttons if the system settings allow this and change color theme to mach icons.
					//
					// Check if VIS is reloaded...
					IF (rTrig[i].Q) THEN
						PanelHandler[i].InitDone := FALSE;
						cnt[i] := cnt[i] + 1;
					END_IF
					
					SelectedTheme[i] := g_Core.Services.HMIHandler.Runtime.Handler[i].Icons := g_Core.Services.System.Runtime.file.IconsEnabled;
					FOR KeyNo := 0 TO SIZEOF(PanelHandler[i].Key) / SIZEOF(PanelHandler[i].Key.Key[0]) - 1 DO
					    IF (PanelHandler[i].Key.Key[KeyNo].Enabled > 0 AND PanelHandler[i].Key.Key[KeyNo].Locked > 0) THEN
					        IF (PanelHandler[i].Key.KeyPressed - 1 = KeyNo) THEN
								ButtonMagic[i].Key[KeyNo] := ButtonTheme[SelectedTheme[i]].Pressed;
							ELSE
								ButtonMagic[i].Key[KeyNo] := ButtonTheme[SelectedTheme[i]].Active;
							END_IF
						ELSE
					    	IF (PanelHandler[i].Key.Key[KeyNo].Enabled > 0) THEN
			        			ButtonMagic[i].Key[KeyNo] := ButtonTheme[SelectedTheme[i]].InActive;
							ELSE
						    	ButtonMagic[i].Key[KeyNo] := 254;
							END_IF
						END_IF
				    END_FOR
				END_IF
			END_FOR
	END_CASE
	
END_PROGRAM
