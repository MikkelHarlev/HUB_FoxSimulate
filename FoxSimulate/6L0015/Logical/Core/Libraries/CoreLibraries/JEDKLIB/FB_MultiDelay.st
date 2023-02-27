FUNCTION_BLOCK FB_MultiDelay
	(*
		Author:			Jensen Denmark
	
		Function:    	MultiDelay
	
		Description: 	Multi Delay based on external Counter.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		16-12-2005		V0.01		CRT	
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Discription:
			Mode 0 	 = Front and rear edge in queue.
			Mode 1 	 = Only front edge in queue.
			DelayOff = Only if different time needet for front and rear edge.
			Size   	 = Size of queue, Max 10.
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF CntAdr <> oldCntAdr THEN
		InitDone := FALSE;
	END_IF
	oldCntAdr := CntAdr;
	
	// Init 
	IF NOT InitDone THEN
		DelayOff := 0;
		Size := 0;
		ErrorCode := 0;
		ErrorString := '';
		IF CntAdr > 0 THEN
			Counter ACCESS (CntAdr);
		ELSE
			ErrorCode := 3;
			ErrorString := 'CntAdr = 0';
			RETURN;
		END_IF
		InitDone := 1;
	END_IF
	
	// Reset 
	IF Reset AND NOT RReset THEN
		FOR Cnt := 0 TO 19 DO
			MemArray[Cnt].Count := 0;
			MemArray[Cnt].Info := 0;
		END_FOR
		Out := 0;
	END_IF
	RReset := Reset;
	
	// Put Positive Element in Qeue 
	IF In AND NOT RIn THEN
		FOR Cnt := 0 TO 19 DO
			IF MemArray[Cnt].Count = 0 THEN
				MemArray[Cnt].Count := Counter + Delay;
				MemArray[Cnt].Info := 1;
				EXIT;
			END_IF
		END_FOR
	END_IF
	
	// Put Negative Element in Qeue 
	IF NOT In AND RIn AND Mode = 0 THEN
		IF DelayOff = 0 THEN
			DelayOff := Delay;
		END_IF
		FOR Cnt := 0 TO 19 DO
			IF MemArray[Cnt].Count = 0 THEN
				IF MemArray[Cnt - 1].Count >= Counter + DelayOff THEN
					MemArray[Cnt].Count := MemArray[Cnt - 1].Count + 1;
				ELSE
					MemArray[Cnt].Count := Counter + DelayOff;
				END_IF
				MemArray[Cnt].Info := 0;
				EXIT;
			END_IF
		END_FOR
	END_IF
	
	RIn := In;
	
	// If No Size -> Set To Default Size 
	IF Size = 0 THEN
		Size := 10;
	END_IF
	
	// If Front And Rear Edge Mode -> Dobbel The Size 
	IF Mode = 0 THEN
		Size := Size * 2;
	END_IF
	
	// If Front Edge Mode Only - > Reset Out 
	IF Mode = 1 THEN
		Out := 0;
	END_IF
	
	// Get Element from Qeue 
	FOR	Cnt := 0 TO (Size - 1) DO
		// Find passed element 
		IF ( MemArray[Cnt].Count > 0 ) AND ( Counter > MemArray[Cnt].Count ) THEN
			Out := MemArray[Cnt].Info;
			MemArray[Cnt].Count := 0;
			MemArray[Cnt].Info := 0;
			EXIT;
		END_IF
	END_FOR
END_FUNCTION_BLOCK