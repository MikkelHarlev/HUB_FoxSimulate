FUNCTION_BLOCK FB_Receive_StrobedInfo

(*--------------------------------------------------------------------------------------------------------------------

	Author:			Jensen Denmark

	Function:    	Receive_StrobedInfo

	Description:	Handles receiving five strobe inputs and adds them to a string.
					Digits received are typically: Customer and article numbers, batch id etc.

	History:		09-02-2007		V0.03		CRT
					18-08-2017		V0.04		BKY		Timescale changed to scale with cycletime where function is called (10 ms.)

	Inputs:			Mode		USINT	Sets mode (0 or 1).
										0 = The strobe input sends a starting bit prior to activating BCD inputs.
										1 = The strobe input does not send a starting bit. BCD inputs activates immediately.
					TimeScale	USINT	How long BCD inputs are ON. Scales with used cycletime where function is called (10 ms.). 
					pString		UDINT	Pointer to the string containing the full string of strobe digits.
					Strobe		BOOL	Strobe input (an actual input variable should be assigned to this input).
					BCD1		BOOL	Binary digit 1 (an actual input variable should be assigned to this input).
					BCD2		BOOL	Binary digit 2 (an actual input variable should be assigned to this input). 
					BCD4		BOOL	Binary digit 4 (an actual input variable should be assigned to this input).
					BCD8		BOOL	Binary digit 8 (an actual input variable should be assigned to this input).
				
	Outputs:		NewData		BOOL	When strobe train is finished the output 'NewData' is activated for one cycle.
										Used to initiate decoding of the string and get assigned values.
					ErrorCode	UINT	Numeric error code.
					ErrorString	STRING	String error message.

--------------------------------------------------------------------------------------------------------------------*)

	IF pString <> oldpString THEN
		InitDone := FALSE;
	END_IF
	oldpString := pString;

	// Init 
	IF NOT InitDone THEN
		ErrorCode := 0;
		ErrorString := '';
		IF pString > 0 THEN
			ReceiveBuffer ACCESS(pString);
			IF TimeScale = 0 THEN
				TimeScale := 10;
			END_IF
		ELSE
			ErrorCode := 1;
			ErrorString := 'pString = 0';
			RETURN;
		END_IF
		InitDone := 1;
	END_IF

	// Clock 
	TimeOutCounter := TimeOutCounter + 1;
	IF Strobe THEN
		TimeOutCounter := 0;
		TimeOut := TimeScale;
	END_IF

	IF TimeOutCounter > TimeOut THEN
		NewData := 1;
	END_IF

	// Handle Data 
	Lead := Strobe AND NOT RStrobe;
	RStrobe := Strobe;

	CASE State OF

		0:	// Wait for Start Signal 
			NewData := 0;
			IF Lead THEN
				IF Mode = 0 THEN
					Counter := 0;
				ELSE
					ReceiveBuffer[0] := 0;
					IF BCD1 THEN
						ReceiveBuffer[0] := 1;
					END_IF
					IF BCD2 THEN
						ReceiveBuffer[0] := ReceiveBuffer[0] + 2;
					END_IF
					IF BCD4 THEN
						ReceiveBuffer[0] := ReceiveBuffer[0] + 4;
					END_IF
					IF BCD8 THEN
						ReceiveBuffer[0] := ReceiveBuffer[0] + 8;
					END_IF
					ReceiveBuffer[0] := ReceiveBuffer[0] + 48;
					Counter := 1;
				END_IF
				State := 1;
			END_IF

		1:	// Receive Info 
			IF Lead THEN
				ReceiveBuffer[Counter] := 0;
				IF BCD1 THEN
					ReceiveBuffer[Counter] := 1;
				END_IF
				IF BCD2 THEN
					ReceiveBuffer[Counter] := ReceiveBuffer[Counter] + 2;
				END_IF
				IF BCD4 THEN
					ReceiveBuffer[Counter] := ReceiveBuffer[Counter] + 4;
				END_IF
				IF BCD8 THEN
					ReceiveBuffer[Counter] := ReceiveBuffer[Counter] + 8;
				END_IF
				ReceiveBuffer[Counter] := ReceiveBuffer[Counter] + 48;
				IF Counter < 64 THEN
					Counter := Counter + 1;
					ReceiveBuffer[Counter] := 0;
				ELSE
					State := 0;
				END_IF
			END_IF
			IF NewData THEN
				ReceiveBuffer[Counter+1] := 0;
				State := 0;
			END_IF
	END_CASE
END_FUNCTION_BLOCK