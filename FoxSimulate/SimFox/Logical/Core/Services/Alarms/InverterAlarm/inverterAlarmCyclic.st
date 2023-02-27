PROGRAM _CYCLIC
	
	CASE taskState OF
		INIT:
			IF g_Core.Services.IO.Runtime.numberOfInverters > 0 THEN
				// Check if names are set.
				IF (g_Core.System.Configuration.adrInverterVarName > 0) THEN
					GetAdr(ADR(adrInverter), g_Core.System.Configuration.adrInverterVarName);
					// We most likely got the pointers :)
					IF (adrInverter > 0) THEN
						pInverter ACCESS adrInverter;
						// Set task state to runtime!
						taskState := RUNTIME; 
					END_IF
				END_IF	
				
			END_IF
		
		RUNTIME:
			IF g_Core.Services.IO.Runtime.numberOfInverters > 0 THEN
				// Add button to HMI
				FOR x := 0 TO 1 DO
					IF g_Core.Services.HMIHandler.Runtime.Handler[x].isInitDone AND NOT InitDone[x] THEN
						IF g_Core.Services.System.Runtime.file.IconsEnabled THEN 
							ButtonId := 126;
						ELSE
							ButtonId:= 34;
						END_IF	
						UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[x].pPanelHandler, 20, 2, ButtonId, 2, 23);
						InitDone[x] := TRUE;
					END_IF
				END_FOR
	
				IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].isInitDone ) THEN
					IF g_Core.Services.System.Runtime.file.IconsEnabled THEN 
						ButtonId := 126;
					ELSE
						ButtonId:= 34;
					END_IF	
					UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 20, 2, ButtonId, 2, 23);
					IF g_Core.Services.IO.Runtime.numberOfInverters > 0 THEN
						InverterAlarm.MinIndex := 0;
						InverterAlarm.MaxIndex := g_Core.Services.IO.Runtime.numberOfInverters-1;
					ELSE
						InverterAlarm.MinIndex := 0;
						InverterAlarm.MaxIndex := 0;
					END_IF
				END_IF
	
				IF g_Core.Services.IO.Runtime.numberOfInverters > 0 THEN
					// Check for Inverter Errors 
					pInverter.State.Initializing  := 0;
					pInverter.State.Error := 0;
					FirstAlarm := 0;
					isError	:= 0;
					IF (g_Core.System.Configuration.isArrayZeroBased) THEN
						FirstInverter := 0;
						LastInverter := g_Core.Services.IO.Runtime.numberOfInverters-1;
					ELSE
						FirstInverter := 1;
						LastInverter := g_Core.Services.IO.Runtime.numberOfInverters;
					END_IF
					
					FOR Cnt := FirstInverter TO LastInverter DO
						IF pInverter.State.Disable[Cnt] THEN
							pInverter.Drive[Cnt].Status := 1;		// No Connection
						ELSE
							// Check Inverter Status
							IF  ( pInverter.Drive[Cnt].GetStatus AND 1 ) = 0 THEN
								pInverter.Drive[Cnt].Status := 0;		// Not READY
								IF NOT pInverter.Drive[Cnt].ModuleOk THEN
									pInverter.Drive[Cnt].Status := 1;		// No Connection
									pInverter.State.Initializing := NOT Initialized;
								ELSIF ( pInverter.Drive[Cnt].GetStatus AND 64 )  > 0 THEN 
									IF pInverter.Drive[Cnt].SetControl = 0 THEN
										pInverter.Drive[Cnt].Status := 2;		// No Start/Stop Cmd
									ELSE
										pInverter.Drive[Cnt].Status := 3;		// Safe Torque OFF
									END_IF;
								ELSIF ( pInverter.Drive[Cnt].GetStatus AND 8 )  > 0 THEN 
									IF  ( pInverter.Drive[Cnt].GetStatusExtended AND 4 ) = 0 THEN
										pInverter.Drive[Cnt].Status := 4;	// Thermofault Motor
										isError	:= 1;
									ELSE			
										pInverter.Drive[Cnt].Status := 5;	// Thermofault Motor Ended
									END_IF;
								END_IF;
								pInverter.State.Error :=  Initialized OR isError;
							ELSE
								pInverter.Drive[Cnt].Status := 10;	// Ready
								Initialized := 1;
								IF ( pInverter.Drive[Cnt].GetStatus AND 16 ) = 0 THEN 
									pInverter.Drive[Cnt].Status := 11;		// No Line Power
									pInverter.State.Error := 1;
								END_IF;
							END_IF;
							IF  ( pInverter.Drive[Cnt].GetStatus AND 2 ) > 0 THEN
								pInverter.Drive[Cnt].Status := 20; // Running
							END_IF;
							// Update Actual Errors 
							IF (pInverter.Drive[Cnt].GetLastError <> RGetLastError) OR (pInverter.Drive[Cnt].GetLastErrorUINT <> RGetLastErrorUINT) THEN
								FOR Elements := 4 TO 1 BY -1 DO
									InverterHistory[Cnt].Element[Elements] := InverterHistory[Cnt].Element[Elements-1];
								END_FOR;
								IF (pInverter.Drive[Cnt].GetLastError <> RGetLastError) THEN
									InverterHistory[Cnt].Element[0] := RGetLastError := pInverter.Drive[Cnt].GetLastError;
								END_IF
								IF (pInverter.Drive[Cnt].GetLastErrorUINT <> RGetLastErrorUINT) THEN
									InverterHistory[Cnt].Element[0] := RGetLastErrorUINT := pInverter.Drive[Cnt].GetLastErrorUINT;
								END_IF
							END_IF;
							//Update HMI if Page not shown
							IF pInverter.State.Error THEN
								IF NOT FirstAlarm AND ( g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PAGE_ALARM_INVERTER_ERROR ) AND ( g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PAGE_ALARM_INVERTER_HISTORY ) THEN
									InverterAlarm.Index := InverterAlarm.MinIndex + Cnt;
									FirstAlarm := 1;
								END_IF;
							END_IF;
						END_IF
					END_FOR;
	
					// Copy HMI Info 
					IF ( g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_ALARM_INVERTER_ERROR ) OR ( g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_ALARM_INVERTER_HISTORY ) OR 
						( g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PAGE_ALARM_INVERTER_ERROR ) OR ( g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PAGE_ALARM_INVERTER_HISTORY ) THEN
						IF InverterAlarm.Index < InverterAlarm.MinIndex THEN
							InverterAlarm.Index := InverterAlarm.MinIndex;
						END_IF;
						IF InverterAlarm.Index > InverterAlarm.MaxIndex THEN
							InverterAlarm.Index := InverterAlarm.MaxIndex;
						END_IF;
	
						CopyFrom := InverterAlarm.Index + (NOT g_Core.System.Configuration.isArrayZeroBased);
								
						memcpy( ADR( InverterAlarm.HMI ), ADR( pInverter.Drive[CopyFrom] ), SIZEOF( InverterAlarm.HMI ));
						// Alarm History 
						FOR Cnt := 0 TO 4 DO
							InverterHistory[CopyFrom].Disable[Cnt] := 1;
						END_FOR;
						InverterHistory[CopyFrom].Disable[InverterAlarm.HistoryIndex] := 0;
						InverterAlarm.HistoryTextNumber := InverterHistory[CopyFrom].Element[InverterAlarm.HistoryIndex];
						memcpy( ADR( InverterAlarm.History ), ADR( InverterHistory[CopyFrom] ), SIZEOF( InverterAlarm.History ));
					END_IF;
				END_IF
			END_IF
	END_CASE
END_PROGRAM

