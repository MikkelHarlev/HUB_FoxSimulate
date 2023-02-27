FUNCTION_BLOCK MC_Follow
	//----------------------------------------------------------------------------------------------------------------------
	// 	Implementation of MC_Follow
	//	
	//	Both Inputs Off -> Goto Position 1
	//	Both Inputs On  -> Goto Position 2
	// 	Only 1 Input On -> Stand Still
	//  
	//	20-01-15 Kc.
	//----------------------------------------------------------------------------------------------------------------------
	// Functionblock step 
	//----------------------------------------------------------------------------------------------------------------------
	ReadStatus(Axis := Axis, Enable := TRUE);

	(* Reset Functionblock Step *)
	IF NOT Execute THEN
		fbkStep := 0;
	END_IF

	CASE fbkStep OF
		0:	// Waiting For Execution Of Functionblock 
			Done := FALSE;
			InPosition := FALSE;
			MaxPosition := FALSE;
			StopMotion.Execute := FALSE;
			MoveAbsolute.Execute := FALSE;
			// Start Fb
			IF EDGEPOS (Execute) THEN
				IF input1 AND input2 THEN
					fbkStep := 10;
				ELSIF NOT input1 AND NOT input2 THEN
					fbkStep := 20;
				ELSE	
					fbkStep := 30;
				END_IF	
			END_IF
	
		10:	// Both Inputs On  -> Goto Position 2 (Wait For StopMotion Done)
			IF StopMotion.Done OR NOT StopMotion.Execute THEN
				StopMotion.Execute := FALSE;
				fbkStep := 11;
			END_IF

		11:	// Both Inputs On  -> Goto Position 2
			IF ReadStatus.StandStill THEN
				MoveAbsolute.Axis := Axis;
				MoveAbsolute.Position := Position2;
				MoveAbsolute.Velocity := Velocity;
				MoveAbsolute.Acceleration := Acceleration;
				MoveAbsolute.Deceleration := Deceleration;
				MoveAbsolute.Direction := mcSHORTEST_WAY;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 12;
			END_IF			
			
		12:	// Going To Positon 2 -> Check For Input Status Change
			IF (input1 AND input2) AND NOT Stop THEN
				;
			ELSE
				StopMotion.Axis := Axis;
				StopMotion.Deceleration := Deceleration;
				StopMotion.Execute := TRUE;
				IF Stop THEN
					fbkStep := 50;
				ELSIF NOT input1 AND NOT input2 THEN
					fbkStep := 20;
				ELSE   								
					fbkStep := 30;
				END_IF
			END_IF	
			// Set Maximum Position 
			IF MoveAbsolute.Done THEN
   				MaxPosition := TRUE;
			END_IF			
				
		20:	// Both Inputs Off -> Goto Position 1 (Wait For StopMotion Done)
			IF StopMotion.Done OR NOT StopMotion.Execute THEN
				StopMotion.Execute := FALSE;
				fbkStep := 21;
			END_IF

		21:	// Both Inputs Off -> Goto Position 1
			IF ReadStatus.StandStill THEN
				MoveAbsolute.Axis := Axis;				
				MoveAbsolute.Position := Position1;
				MoveAbsolute.Velocity := Velocity;
				MoveAbsolute.Acceleration := Acceleration;
				MoveAbsolute.Deceleration := Deceleration;
				MoveAbsolute.Direction := mcSHORTEST_WAY;
				MoveAbsolute.Execute := TRUE;
				fbkStep := 22;
			END_IF			
			
		22:	// Going To Positon 1 -> Check For Input Status Change
			IF NOT input1 AND NOT input2 AND NOT Stop THEN
				;
			ELSE	
				StopMotion.Axis := Axis;
				StopMotion.Deceleration := Deceleration;
				StopMotion.Execute := TRUE;
				IF Stop THEN
					fbkStep := 50;
				ELSIF input1 AND input2 THEN
					fbkStep := 10;
				ELSE	
					fbkStep := 30;
				END_IF	
			END_IF	
			// Set Maximum Position 
			IF MoveAbsolute.Done THEN
   				MaxPosition := TRUE;
			END_IF			
	
		30:	// Only 1 Input On -> Stand Still
			IF StopMotion.Done OR NOT StopMotion.Execute THEN
				StopMotion.Execute := FALSE;
				InPosition := TRUE;
				IF Stop THEN 
					fbkStep := 50;
				ELSIF input1 AND input2 THEN
					InPosition := FALSE;
					fbkStep := 10;
				ELSIF NOT input1 AND NOT input2 THEN
					InPosition := FALSE;
					fbkStep := 20;
				END_IF
			END_IF

		50: // Stopping	
			IF StopMotion.Done OR NOT StopMotion.Execute THEN
				StopMotion.Execute := FALSE;
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

	END_CASE
	
	//----------------------------------------------------------------------------------------------------------------------
	// Error Handling 
	//----------------------------------------------------------------------------------------------------------------------
	
	IF (Execute = TRUE) THEN
		IF (MoveAbsolute.ErrorID <> 0) THEN
			Status := MoveAbsolute.ErrorID;
			Error  := MoveAbsolute.Error;
			MoveAbsolute.Execute := FALSE;
		ELSIF (StopMotion.ErrorID <> 0) THEN
			Status := StopMotion.ErrorID;
			Error  := StopMotion.Error;
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
	StopMotion();
	MoveAbsolute();	
	MoveAbsolute.Execute := FALSE;

	//----------------------------------------------------------------------------------------------------------------------
	// End 
	//----------------------------------------------------------------------------------------------------------------------
	
END_FUNCTION_BLOCK