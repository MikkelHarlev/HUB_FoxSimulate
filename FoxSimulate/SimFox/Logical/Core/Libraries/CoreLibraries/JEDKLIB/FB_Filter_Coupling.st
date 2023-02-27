FUNCTION_BLOCK FB_Filter_Coupling
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark

		Function:    	Filter_Coupling

		Description: 	Symetrical Filter With LaneCoupling of Outputs.

		Dependences:	

		Interfaces:  	

		History:		21-07-2005		V0.01		CRT
						05-04-2006		V0.02		AHO 			(OutAll		BOOL[6]	Photocell Outputs (All Coupled Lanes))
													AHO 			(OutSerial		BOOL[6]	Photocell Outputs (All Coupled Lanes, if all photocells activated)
										V0.03		MHA				3/2/1 Mode 31
										V0.04		MHA	(Jedk 30)	Single none-array counter possible as input			
						16-06-2008		V0.05		MHA (Jedk 40)	Mistake in Coupling 22,23 fixed
						07-09-2017		V0.06		AHO/BKY			Correct steeringlane in 2-lane operation for mode 51.

	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:

		A symetrical filter will be used on all "In" variables. The "FilterValue" will be used used as filter value and 
		the "Counter" as the base for this (Wheel or Time). "Mode" is the number of lanes. If "On" is ON, all possible 
		photocells will be used in parallel to give the optimal meassurement at the requested lane combination given by 
		"Info". If "On" is OFF, only the filtering is active. 
		"Out" is set/reset according to "On" and "Info" variables. 

		signal use the "CountSet" for delaying the "Out" signal. The "Comp" variable can be used for 
		Speedcompensation of the delay. The "CntAdr" contains the adress of the used countdown signal 
		(CycleCounter, Wheel etc.). The "Out" signal is ON as long as "On" is counted down by internal
		cyclic counter. 

		Inputs:		MemAdr		UDINT	Address OF Filter_Coupling_Type with the following variables:

		Inputs:		On			BOOL	Lane Coupling On/Off
					Mode		USINT	Lane Numbers
					Info		USINT	Lane Combination
					FilterValue	UINT	Filter Value
					In			BOOL[6]	Inputs from photocells

		Outputs:	Out			BOOL[6]	Photocell Outputs (Steering Lane)
					OutAll		BOOL[6]	Photocell Outputs (All Coupled Lanes)
					OutSerial	BOOL[6] Photocell Outputs (All Coupled Lanes, when all coupled photocell active)

		CntAdr		UDINT	Address OF Counter_Type with following variables:

		Inputs:		Counter		UDINT[6]	Counters to be used for the Filtering

		Outputs:	ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message

	(*--------------------------------------------------------------------------------------------------------------------*)

	IF MemAdr <> oldMemAdr THEN
		InitDone := FALSE;
	END_IF
	oldMemAdr := MemAdr;
	
	// Init 
	IF NOT InitDone THEN
		ErrorCode := 0;
		ErrorString := '';
		IF MemAdr <> 0 THEN
			MemArray ACCESS MemAdr;
		ELSE
			ErrorCode := 1;
			ErrorString := 'Filter_Coupling MemAdr = 0';
			RETURN;
		END_IF
	
		// Access single elements of counter adress array 
		Index  := 0;
		IndexTemp := 0;
		IF MemArray.CounterAdr[Index] = 0 THEN
			ErrorCode := 2;
			ErrorString := 'Filter_Coupling CounterAdr = 0';
			RETURN;
		ELSE
	
			// 0 
			Counter_0 ACCESS MemArray.CounterAdr[Index];
	
			// 1 
			IndexTemp := IndexTemp + 1;
			IF MemArray.CounterAdr[IndexTemp] > 0 THEN
				Index := IndexTemp;
			END_IF
			Counter_1 ACCESS MemArray.CounterAdr[Index];
	
			// 2 
			IndexTemp := IndexTemp + 1;
			IF MemArray.CounterAdr[IndexTemp] > 0 THEN
				Index := IndexTemp;
			END_IF
			Counter_2 ACCESS MemArray.CounterAdr[Index];
	
			// 3 
			IndexTemp := IndexTemp + 1;
			IF MemArray.CounterAdr[IndexTemp] > 0 THEN
				Index := IndexTemp;
			END_IF
			Counter_3 ACCESS MemArray.CounterAdr[Index];
	
			// 4 
			IndexTemp := IndexTemp + 1;
			IF MemArray.CounterAdr[IndexTemp] > 0 THEN
				Index := IndexTemp;
			END_IF
			Counter_4 ACCESS MemArray.CounterAdr[Index];
	
			// 5 
			IndexTemp := IndexTemp + 1;
			IF MemArray.CounterAdr[IndexTemp] > 0 THEN
				Index := IndexTemp;
			END_IF
			Counter_5 ACCESS MemArray.CounterAdr[Index];
	
		END_IF
	
		InitDone := 1;
	END_IF
	
	IF memcmp(ADR(MemArray.CounterAdr), ADR(oldMemArray.CounterAdr), SIZEOF(MemArray.CounterAdr)) <> 0 THEN
		InitDone := FALSE;
		oldMemArray.CounterAdr := MemArray.CounterAdr;
		RETURN;
	END_IF
	
	//--------------------------------------------------------------------------------------------------------------------	
	Counter[0] := Counter_0;
	Counter[1] := Counter_1;
	Counter[2] := Counter_2;
	Counter[3] := Counter_3;
	Counter[4] := Counter_4;
	Counter[5] := Counter_5;
	
	// Filter 
	FOR Cnt := 0 TO 5 DO
		IF MemArray.In[Cnt] THEN
			// Check if Input has been On for more than Filtervalue 
		  	IF (Counter[Cnt] > LCount[Cnt]) OR (MemArray.FilterValue = 0) THEN
				RIn[Cnt] := 1;
			END_IF
			// Update filter 
			TCount[Cnt] := Counter[Cnt] + MemArray.FilterValue;
		ELSE
			// Check if Input has been Off for more than Filtervalue 
		  	IF Counter[Cnt] > TCount[Cnt] OR (MemArray.FilterValue = 0) THEN
				RIn[Cnt] := 0;
			END_IF
			// Update filter 
			LCount[Cnt] := Counter[Cnt] + MemArray.FilterValue;
		END_IF
	END_FOR;
	
	//--------------------------------------------------------------------------------------------------------------------	
	// Encode Filter Inputs 
	In := 0;
	In := BOOL_TO_USINT(RIn[0]);
	In := BOOL_TO_USINT(RIn[1]) *  2 + In;
	In := BOOL_TO_USINT(RIn[2]) *  4 + In;
	In := BOOL_TO_USINT(RIn[3]) *  8 + In;
	In := BOOL_TO_USINT(RIn[4]) * 16 + In;
	In := BOOL_TO_USINT(RIn[5]) * 32 + In;
	
	IF MemArray.Mode <> 100 THEN
		Bin := 0;	Ste := 0;
		Bin1 := 0;  Ste1 := 0;
		Bin2 := 0;  Ste2 := 0;
	END_IF
	
	Out := In;
	OutAll := In;
	OutSerial := In;
	//--------------------------------------------------------------------------------------------------------------------
	// Coupling of Inputs 
	IF MemArray.On THEN
	 	CASE MemArray.Info OF
				1:	// 1*2 3 4 5 6 
					IF MemArray.Mode = 2 THEN
						Bin := 3;	Ste := 1;
					ELSE
						Bin := 3;	Ste := 2;
					END_IF
				2:	// 1 2*3 4 5 6 
					IF MemArray.Mode < 5 THEN
						Bin := 6; 	Ste := 2;
					ELSE
						Bin := 6; 	Ste := 4;
					END_IF
				3:	// 1*2*3 4 5 6 
					Bin := 7;		Ste := 2;
				4:	// 1 2 3*4 5 6 		// 1*2a 2b*3 
					IF MemArray.Mode <> 31 THEN
						Bin := 12;	Ste := 4;
					ELSE
						Bin := 0;	Ste := 1;
									Ste1 := 4;
					END_IF
				5:	// 1*2 3*4 5 6 
					Bin := 3;		Ste := 2;
					Bin1 := 12;		Ste1 := 4;
				6:	// 1 2*3*4 5 6 
					Bin := 14;		Ste := 4;
				7:	// 1*2*3*4 5 6 
					IF MemArray.Mode = 4 THEN
						Bin := 15;	Ste := 2;
					ELSE
						// 1*2a 2b*3 
						Bin := 15;	Ste := 4;
					END_IF
				8:	// 1 2 3 4*5 6 
					Bin := 24;		Ste := 8;
				9:	// 1*2 3 4*5 6 
					Bin := 3;		Ste := 2;
					Bin1 := 24;		Ste1 := 8;
				10:	// 1 2*3 4*5 6 
					Bin := 6;		Ste := 4;
					Bin1 := 24;		Ste1 := 8;
				11:	// 1*2*3 4*5 6 
					Bin := 7;		Ste := 2;
					Bin1 := 24;		Ste1 := 8;
				12: // 1 2 3*4*5 6 
					Bin := 28;		Ste := 8;
				13:	// 1*2 3*4*5 6 
					Bin := 3;		Ste := 2;
					Bin1 := 28;		Ste1 := 8;
				14: // 1 2*3*4*5 6 
					Bin := 30;		Ste := 4;
				15: // 1*2*3*4*5 6 
					Bin := 31;		Ste := 4;
				16: // 1 2 3 4 5*6 
					IF MemArray.Mode <> 51 THEN
						Bin := 48;		Ste := 16;
					ELSE
						// 1*2*3a 3b*4*5 
						Bin := 7;	Ste := 2;
						Bin1 := 56; Ste1:= 8;
					END_IF
				17:	// 1*2 3 4 5*6 
					Bin := 3;		Ste := 2;
					Bin1 := 48;		Ste1 := 16;
				18:	// 1 2*3 4 5*6 
					Bin := 6;		Ste := 4;
					Bin1 := 48;		Ste1 := 16;
				19:	// 1*2*3 4 5*6 
					Bin := 7;		Ste := 2;
					Bin1 := 48;		Ste1 := 16;
				20:	// 1 2 3*4 5*6 
					Bin := 12;		Ste := 4;
					Bin1 := 48;		Ste1 := 16;
				21:	// 1*2 3*4 5*6 
					Bin := 3;		Ste := 2;
					Bin1 := 12;		Ste1 := 4;
					Bin2 := 48;		Ste2 := 16;
				22:	// 1 2*3*4 5*6 
					Bin := 14;		Ste := 4;
					Bin1 := 48;		Ste1 := 16;
				23:	// 1*2*3*4 5*6 
					Bin := 15;		Ste := 4;
					Bin1 := 48;		Ste1 := 16;
				24: // 1 2 3 4*5*6 
					Bin := 56;		Ste := 16;
				25:	// 1*2 3 4*5*6 
					Bin := 3;		Ste := 2;
					Bin1 := 56;		Ste1 := 16;
				26:	// 1 2*3 4*5*6 
					Bin := 6;		Ste := 4;
					Bin1 := 56;		Ste1 := 16;
				27:	// 1*2*3 4*5*6 
					Bin := 7;		Ste := 2;
					Bin1 := 56;		Ste1 := 16;
				28: // 1 2 3*4*5*6 
					Bin := 60;		Ste := 8;
				29:	// 1*2 3*4*5*6 
					Bin := 3;		Ste := 2;
					Bin1 := 60;		Ste1 := 8;
				30:	// 1 2*3*4*5*6 
					Bin := 62;		Ste := 8;
				31:	// 1*2*3*4*5*6 
					Bin := 63;		Ste := 4;
	
				100:// Test mode;
		END_CASE
	
		IF Bin > 0 AND Ste > 0 THEN
			IF (In AND Bin) > 0    THEN Out := (Out AND (63-Bin)) + Ste; END_IF
			IF (In AND Bin) > 0    THEN OutAll := (OutAll AND (63-Bin)) + Bin; END_IF
			IF (In AND Bin) <> Bin THEN OutSerial := (OutSerial AND (63-Bin)); END_IF
		END_IF
		IF Bin1 > 0 AND Ste1 > 0 THEN
			IF (In AND Bin1) > 0     THEN Out := (Out AND (63-Bin1)) + Ste1; END_IF
			IF (In AND Bin1) > 0     THEN OutAll := (OutAll AND (63-Bin1)) + Bin1; END_IF
			IF (In AND Bin1) <> Bin1 THEN OutSerial := (OutSerial AND (63-Bin1)); END_IF
		END_IF
		IF Bin2 > 0 AND Ste2 > 0 THEN
			IF (In AND Bin2) > 0     THEN Out := (Out AND (63-Bin2)) + Ste2; END_IF
			IF (In AND Bin2) > 0     THEN OutAll := (OutAll AND (63-Bin2)) + Bin2; END_IF
			IF (In AND Bin2) <> Bin2 THEN OutSerial := (OutSerial AND (63-Bin2)); END_IF
		END_IF
	
		// Mode 31 2-Lane operation hack 
		IF (MemArray.Mode = 31) AND (MemArray.Info = 4) THEN
			OutAll := OutAll AND 2#00000101;
			Out := Out AND 2#00000101;
		END_IF
	
		// Mode 51 2-Lane operation hack 
		IF (MemArray.Mode = 51) AND (MemArray.Info = 16) THEN
			OutAll := OutAll AND 2#00011011;
			Out := Out AND 2#00011011;
		END_IF
	END_IF
	
	//--------------------------------------------------------------------------------------------------------------------
	// Decode Result 
	MemArray.Out[0] := USINT_TO_BOOL(Out AND 1);
	MemArray.Out[1] := USINT_TO_BOOL(Out AND 2);
	MemArray.Out[2] := USINT_TO_BOOL(Out AND 4);
	MemArray.Out[3] := USINT_TO_BOOL(Out AND 8);
	MemArray.Out[4] := USINT_TO_BOOL(Out AND 16);
	MemArray.Out[5] := USINT_TO_BOOL(Out AND 32);
	
	MemArray.OutAll[0] := USINT_TO_BOOL(OutAll AND 1);
	MemArray.OutAll[1] := USINT_TO_BOOL(OutAll AND 2);
	MemArray.OutAll[2] := USINT_TO_BOOL(OutAll AND 4);
	MemArray.OutAll[3] := USINT_TO_BOOL(OutAll AND 8);
	MemArray.OutAll[4] := USINT_TO_BOOL(OutAll AND 16);
	MemArray.OutAll[5] := USINT_TO_BOOL(OutAll AND 32);
	
	MemArray.OutSerial[0] := USINT_TO_BOOL(OutSerial AND 1);
	MemArray.OutSerial[1] := USINT_TO_BOOL(OutSerial AND 2);
	MemArray.OutSerial[2] := USINT_TO_BOOL(OutSerial AND 4);
	MemArray.OutSerial[3] := USINT_TO_BOOL(OutSerial AND 8);
	MemArray.OutSerial[4] := USINT_TO_BOOL(OutSerial AND 16);
	MemArray.OutSerial[5] := USINT_TO_BOOL(OutSerial AND 32);
END_FUNCTION_BLOCK