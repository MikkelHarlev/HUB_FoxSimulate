FUNCTION_BLOCK FB_Send_StrobedInfo

(*--------------------------------------------------------------------------------------------------------------------

	Author:			Jensen Denmark

	Function:    	Send_StrobedInfo

	Description:	Handles sending a strobe bit train from digits contained in a string.
					Digits forwarded are typically: Customer and article numbers, stacker count, batch id etc.

	History:		09-02-2007		V0.03		CRT
					18-08-2017		V0.04		BKY		Timescale changed to scale with cycletime where function is called (10 ms.)
	
	Inputs:			Send		BOOL	Activates strobe function.
					Mode		USINT	Sets mode (0 or 1). 
										0 = Strobe output sends a starting bit prior to activating BCD outputs.
										1 = Strobe output does not send a starting bit. BCD outputs activate immediately.
					TimeScale	USINT	How long BCD outputs are ON. Scales with used cycletime where function is called (10 ms.).
					pString		UDINT	Pointer to the string containing the full string of strobe digits.
				
	Outputs:		Strobe		BOOL	Strobe output (needs to be assigned to an actual output/relay).
					BCD1		BOOL	Binary digit 1 (needs to be assigned to an actual output/relay).
					BCD2		BOOL	Binary digit 2 (needs to be assigned to an actual output/relay).
					BCD4		BOOL	Binary digit 4 (needs to be assigned to an actual output/relay).
					BCD8		BOOL	Binary digit 8 (needs to be assigned to an actual output/relay).
					Ready		BOOL	Strobe function ready (not transmitting).
					ErrorCode	UINT	Numeric error code.
					ErrorString	STRING	String error message.

--------------------------------------------------------------------------------------------------------------------*)

	IF pString <> oldpString THEN
		InitDone := FALSE;
	END_IF
	oldpString := pString;

	(* InitDone *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF pString > 0 THEN
			SendBuffer ACCESS( pString );
			IF TimeScale = 0 THEN
				TimeScale := 10;
			END_IF
		ELSE
			ErrorCode   := 1;
			ErrorString := 'pString = 0';
			RETURN;
		END_IF
		InitDone := 1;
	END_IF

	(* Clock *)
	StrobeStart := 0;
	StrobeCounter := StrobeCounter + 1;

	IF (StrobeCounter >= TimeScale) THEN
		StrobeCounter := 0;
		StrobeStart := 1;
	END_IF
	IF (StrobeCounter >= ( TimeScale / 3 )) THEN
		Strobe := 1;
	ELSE
		Strobe := 0;
	END_IF

	(* Handle Data *)
	CASE State OF

		0:	(* Wait for Start Signal *)
			Ready  := 1;
			StrobeCounter := 0;
			IF Send THEN
				Send  := 0;
				Ready := 0;
				IF Mode = 0 THEN
					Counter := 0;
				ELSE
					SendByte := SendBuffer[0] - 48;
					BCD1 := ( SendByte AND 1 ) = 1;
					BCD2 := ( SendByte AND 2 ) = 2;
					BCD4 := ( SendByte AND 4 ) = 4;
					BCD8 := ( SendByte AND 8 ) = 8;
					Counter := 1;
				END_IF
				State := 1;
			END_IF

		1:	(* Send Info *)
			IF StrobeStart THEN
				IF SendBuffer[Counter] <> 0 THEN
					SendByte := SendBuffer[Counter] - 48;
					BCD1 := ( SendByte AND 1 ) = 1;
					BCD2 := ( SendByte AND 2 ) = 2;
					BCD4 := ( SendByte AND 4 ) = 4;
					BCD8 := ( SendByte AND 8 ) = 8;
					IF Counter < 64 THEN
						Counter := Counter + 1;
					ELSE
						State := 0;
					END_IF
				ELSE
					BCD1 := 0;
					BCD2 := 0;
					BCD4 := 0;
					BCD8 := 0;
					State := 0;
				END_IF
			END_IF

	END_CASE

END_FUNCTION_BLOCK