FUNCTION_BLOCK MC_TorquePull
	//----------------------------------------------------------------------------------------------------------------------
	// Implementation of MC_TorquePull
	//	
	//	20-01-15 Kc.
	//
	//----------------------------------------------------------------------------------------------------------------------
	
	// Set Nominal Torque 
	NomTorque := 100;
		
	// Jmp To Reset Torque 
	IF Reset THEN
		Reset := FALSE;
		fbkStep := 200;
	END_IF
		
	// Reset Functionblock Step
	IF StopFbk THEN
		StopFbk := FALSE;
		fbkStep := 0;
	END_IF

	// Delay Recall Funktion AX_ABS 
	IF TDReCallABS >= 1 THEN
		TDReCallABS := TDReCallABS - 1;
	END_IF
	
	//----------------------------------------------------------------------------------------------------------------------
	// Functionblock step 
	//----------------------------------------------------------------------------------------------------------------------
	
	CASE fbkStep OF
		0:	// Waiting For Execution Of Functionblock 
			Done := FALSE;
			MaxPosition := FALSE;
			MoveAbsolute.Execute := FALSE;
			SetTorquePos.Execute := FALSE;
			SetTorqueNeg.Execute := FALSE;
			// Start Fb 
			IF EDGEPOS (Execute) THEN
				// Set The Limited Torque For Positive And Negative Direction
				SetTorquePos.Axis := Axis;
				SetTorquePos.ParID := 344;					// CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 
				SetTorquePos.DataType := ncPAR_TYP_USINT;
				SetTorquePos.DataAddress := ADR(Torque);
				SetTorquePos.Execute := TRUE;
				SetTorqueNeg.Axis := Axis;
				SetTorqueNeg.ParID := 346;					// CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 346 
				SetTorqueNeg.DataType := ncPAR_TYP_USINT;
				SetTorqueNeg.DataAddress := ADR(Torque);
				SetTorqueNeg.Execute := TRUE;
				fbkStep := 10;
			END_IF
	
		10:	// Start Pulling Whit Limetet Torque
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute := FALSE;
				SetTorqueNeg.Execute := FALSE;
				MoveAbsolute.Axis := Axis;
				MoveAbsolute.Position := Position;
				MoveAbsolute.Velocity := Velocity;
				MoveAbsolute.Acceleration := Acceleration;
				MoveAbsolute.Deceleration := Deceleration;
				MoveAbsolute.Direction := mcSHORTEST_WAY;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 20;
			END_IF	
		
		20:	// Check For Max Lagerror Or Stop Command
			TDReCallABS := 20;
			IF Stop THEN
				Stop := FALSE;
				MoveAbsolute.Execute := FALSE;
				fbkStep := 29;
			ELSIF (LagError > 1000) OR (LagError < -1000) THEN
				MoveAbsolute.Execute := FALSE;
 				fbkStep := 21;
			END_IF
			// Set Maximum Position 
			IF MoveAbsolute.Done THEN
   				MaxPosition := TRUE;
			END_IF			
						
		21: // Move Opposite direction To Reduce Lagerror
			IF TDReCallABS = 0 THEN
				MoveAbsolute.Axis := Axis;
				MoveAbsolute.Position := ActualPosition - (LagError - 100);
				MoveAbsolute.Velocity := 50000;
				MoveAbsolute.Acceleration := 300000;
				MoveAbsolute.Deceleration := 300000;
				MoveAbsolute.Direction := mcSHORTEST_WAY;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 22;
			END_IF	
		
		22:	// Wait For Done
			IF (MoveAbsolute.Done = TRUE) THEN
				TDReCallABS := 20;
				IF Stop THEN
					Stop := FALSE;
					MoveAbsolute.Execute := FALSE;
					fbkStep := 29;
				ELSE	
					MoveAbsolute.Execute := FALSE;
	 				fbkStep := 23;
				END_IF
			END_IF
			
		23:	// Restart Pulling
			IF TDReCallABS = 0 THEN
				MoveAbsolute.Axis := Axis;
				MoveAbsolute.Position := Position;
				MoveAbsolute.Velocity := Velocity;
				MoveAbsolute.Acceleration := Acceleration;
				MoveAbsolute.Deceleration := Deceleration;
				MoveAbsolute.Direction := mcSHORTEST_WAY;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 20;
			END_IF	

		29:	// Stop -> Move To Actual Position
			IF TDReCallABS = 0 THEN
				MoveAbsolute.Position := (ActualPosition - LagError);
				MoveAbsolute.Velocity := 50000;
				MoveAbsolute.Acceleration := 300000;
				MoveAbsolute.Deceleration := 300000;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 30;
			END_IF	

		30:	// Wait For Done -> Set Torque To Nominel
			IF (MoveAbsolute.Done = TRUE) THEN		
				MoveAbsolute.Execute := FALSE;
				SetTorquePos.Axis := Axis;
				SetTorquePos.ParID := 344;					// CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 
				SetTorquePos.DataType := ncPAR_TYP_USINT;
				SetTorquePos.DataAddress := ADR(NomTorque);
				SetTorquePos.Execute := TRUE;
				SetTorqueNeg.Axis := Axis;
				SetTorqueNeg.ParID := 346;					// CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 346 
				SetTorqueNeg.DataType := ncPAR_TYP_USINT;
				SetTorqueNeg.DataAddress := ADR(NomTorque);
				SetTorqueNeg.Execute := TRUE;
				fbkStep := 40;
			END_IF	
		
		40:	// Wait For Nominel Torque
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute := FALSE;
				SetTorqueNeg.Execute := FALSE;
				Done := TRUE;
				fbkStep := 100;
			END_IF

		//------------------------------------------------------------------------------------------------------------------
		// Done 
		//------------------------------------------------------------------------------------------------------------------
	
		100: // Keeping "Done" TRUE if "Execute" is TRUE - According To PLCOpen Interface 
			IF (Execute = TRUE) THEN
				Done := TRUE;
			ELSE
				Done := FALSE;
				fbkStep := 0;
			END_IF
	
		//------------------------------------------------------------------------------------------------------------------
		// Reset 
		//------------------------------------------------------------------------------------------------------------------
	
		200: // Set The Limited Torque To 100% For Positive And Negative Direction 
			Done := FALSE;
			MoveAbsolute.Execute := FALSE;			
			SetTorquePos.Axis := Axis;
			SetTorquePos.ParID := 344;					// CTRL Torque limiter: LIM_T1_POS override [%] - PARID 344 
			SetTorquePos.DataType := ncPAR_TYP_USINT;
			SetTorquePos.DataAddress := ADR(NomTorque);
			SetTorquePos.Execute := TRUE;
			SetTorqueNeg.Axis := Axis;
			SetTorqueNeg.ParID := 346;					// CTRL Torque limiter: LIM_T1_NEG override [%] - PARID 344 
			SetTorqueNeg.DataType := ncPAR_TYP_USINT;
			SetTorqueNeg.DataAddress := ADR(NomTorque);
			SetTorqueNeg.Execute := TRUE;
			fbkStep := 201;
	
		201: // Wait For Nominel Torque Set 
			IF (SetTorquePos.Done = TRUE AND SetTorqueNeg.Done = TRUE) THEN
				SetTorquePos.Execute		:= FALSE;
				SetTorqueNeg.Execute		:= FALSE;
				Done := TRUE;
				fbkStep := 100;
			END_IF
	END_CASE
	
	//----------------------------------------------------------------------------------------------------------------------
	// Error Handling
	//----------------------------------------------------------------------------------------------------------------------
	
	IF (Execute = TRUE) THEN
		IF (SetTorquePos.ErrorID <> 0) THEN
			Status := SetTorquePos.ErrorID;
			Error  := SetTorquePos.Error;
			SetTorquePos.Execute := FALSE;
		ELSIF (SetTorqueNeg.ErrorID <> 0) THEN
			Status := SetTorqueNeg.ErrorID;
			Error  := SetTorqueNeg.Error;
			SetTorqueNeg.Execute := FALSE;
		ELSIF (MoveAbsolute.ErrorID <> 0) THEN
			Status := MoveAbsolute.ErrorID;
			Error  := MoveAbsolute.Error;
			MoveAbsolute.Execute := FALSE;
		END_IF
	ELSE
		Status := 0;
		Error  := 0;
	END_IF
	
	IF (Error = TRUE) THEN
		fbkStep := 0;
	END_IF
	
	//----------------------------------------------------------------------------------------------------------------------
	// Functionblock Calls 
	//----------------------------------------------------------------------------------------------------------------------
	
	MoveAbsolute();
	SetTorquePos();
	SetTorqueNeg();
	
	//----------------------------------------------------------------------------------------------------------------------
	// End 
	//----------------------------------------------------------------------------------------------------------------------

END_FUNCTION_BLOCK