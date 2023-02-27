FUNCTION_BLOCK FB_SetReset
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	SetReset
	
		Description: 	Handle Set / Reset
	
		History:		15-11-2007		V1.00		AHO
						10-06-2008		V1.01		MHA/AHO
						14-04-2009		V1.02		AHO
						13-05-2009		V1.03		AHO 		Add check for wrong size of CntArray and MemArray
						02-11-2009		V1.04		AHO 		CntAdr and CntSize -> CntNameAdr, MemAdr and MemSize -> MemName
						07-12-2009		V1.05		AHO 		Init Bug Fix
						28-09-2010		V1.06		AHO 		Added: Error if CountSet/CountReset was in the past
						05-10-2010		V1.07		AHO 		Fixed: Set Comp = 0 if > CountSet/Reset, Changed: Activate code if Counter >= CountSet/Reset (instaed of >)
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		The leading edge of the "Set" or "Reset" signal, latch the state, and use the "Delay" for delaying the 
		"Out". The state of "Set"/"Reset" decide the state of "Out". The "Comp" variable can be used for 
		Speedcompensation of the delay. The "CntAdr" contains the adress of the used countdown signal 
		( CycleCounter, Wheel etc.).
		
		Inputs:			CntNameAdr	UDINT	Address to name of Counter variable 
						MemNameAdr	UDINT	Address to name of Memory variable, SetReset_Type with the following variables:
						Set			BOOL	Triggers the function ( Leading Edge )
						InfoSet		USINT	Lane Coupling used by "Set"
						CountSet	UDINT	Delay based on Counter
						Reset		BOOL	Triggers the function ( Leading Edge )
						InfoReset	USINT	Lane Coupling used by "Reset"
						CountReset	UDINT	Delay based on Counter
				
						Out 		BOOL	ON if "Set" has triggered the function, OFF if "Reset" has triggered the function
						OutA 		BOOL	Output for 3-2-1 and 5-2-1 lane operation
						OutB 		BOOL	Output for 3-2-1 and 5-2-1 lane operation
	
					Comp		USINT		Compensation (Speedcompensation)
					Mode		USINT		Mode of Lane Combination
	
		Outputs:	
					Counter		UDINT[]	The actual counters given by CntNameAdr.
					ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
	
		Note: All lane combinations from Filter_Coupling function
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	// Mode change..?
	IF Mode <> ModeOld OR CntNameAdr <> oldCntNameAdr OR MemNameAdr <> oldMemNameAdr THEN
		InitDone := FALSE;
	END_IF
	ModeOld := Mode;
	oldCntNameAdr := CntNameAdr;
	oldMemNameAdr := MemNameAdr;
	
	IF NOT InitDone THEN
		// ******************************* Init *******************************
		InitDone := 1;
		ErrorCode   := 0;
		ErrorString := '';

		(* Mode check *)
		MaxLane := ModeOld := Mode;
		IF Mode = 31 THEN MaxLane := 3; END_IF;
		IF Mode = 51 THEN MaxLane := 5; END_IF;
		IF MaxLane = 0 OR MaxLane > 6 THEN
			ErrorCode := 101;
			ErrorString := 'Mode = 0 or > 6';
			RETURN;
		END_IF

		// Address check
		IF CntNameAdr = 0 THEN
			ErrorCode := 102;
			ErrorString := 'Error: CntNameAdr = 0';
			RETURN;
		END_IF
		IF MemNameAdr = 0 THEN
			ErrorCode := 103;
			ErrorString := 'Error: MemNameAdr = 0';
			RETURN;
		END_IF

		strMemSize := MAX(brsstrlen(CntNameAdr), brsstrlen(MemNameAdr))+13;
		IF strMemSize > 1000 THEN	// Possible not null-terminated string.
			ErrorCode := 104;
			ErrorString := 'Wrong Name-String address.';
			RETURN;
		END_IF

		statusStrMemAlloc := TMP_alloc(strMemSize, ADR(taskNameConcatAdr));
		IF statusStrMemAlloc <> 0 THEN
			ErrorCode := 105;
			ErrorString := 'Memory alloc fail';
			RETURN;
		END_IF

		// Counter check 
		ST_name(0, taskNameConcatAdr, ADR(grp));
		strcat(taskNameConcatAdr, ADR(':'));
		strcat(taskNameConcatAdr, CntNameAdr);
		PV_ninfo(taskNameConcatAdr, ADR(CntType), ADR(CntLen), ADR(CntNo));
		PV_xgetadr(taskNameConcatAdr, ADR(CntAdr), ADR(CntLen));

		IF CntAdr > 0 THEN
			CntArray ACCESS CntAdr;
		ELSE
			ErrorCode   := 106;
			ErrorString := 'Wrong Counter name';
			RETURN;
		END_IF

		IF (CntNo > 1) AND (CntNo < MaxLane) THEN
			ErrorCode   := 107;
			ErrorString := 'Counter size < Mode';
			RETURN;
		END_IF

		// Memory check 
		ST_name(0, taskNameConcatAdr, ADR(grp));
		strcat(taskNameConcatAdr, ADR(':'));
		strcat(taskNameConcatAdr, MemNameAdr);
		PV_ninfo(taskNameConcatAdr, ADR(MemType), ADR(MemLen), ADR(MemNo));
		PV_xgetadr(taskNameConcatAdr, ADR(MemAdr), ADR(MemLen));
		statusStrMemFree := TMP_free(strMemSize, taskNameConcatAdr);

		IF MemAdr > 0 THEN
			MemArray ACCESS MemAdr;
		ELSE
			ErrorCode   := 108;
			ErrorString := 'Wrong Memory name';
			RETURN;
		END_IF
		IF (MemNo >= 1) AND (MemNo < MaxLane) THEN
			ErrorCode   := 109;
			ErrorString := 'Memory size < Mode';
			RETURN;
		END_IF

		// InUse check 
		InUse_Type.Mode := Mode;
		InUse_Function(InitDone := FALSE, InUse_Type_Adr := ADR(InUse_Type));
		IF InUse_Function.ErrorCode > 0 THEN
			ErrorCode   := 110;
			ErrorString := InUse_Function.ErrorString;
			RETURN;
		END_IF
	END_IF

	IF ErrorCode >= 100 THEN
		RETURN;
	END_IF

	//******************************* Function *******************************
	FOR Cnt := 0 TO (MaxLane-1) DO

		// Only 1 counter - none array 
		IF CntNo = 1 THEN
			CntNoIndex := 0;
		ELSE
			CntNoIndex := Cnt;
		END_IF

		Counter[Cnt] := CntArray[CntNoIndex];

		//******************************* Set *******************************
		IF MemArray[Cnt].Set THEN
			// Check if CountSet is in the past 
			IF NOT SetCheckDone[Cnt] THEN
				IF (MemArray[Cnt].CountSet > 0) AND (CntArray[CntNoIndex] > (MemArray[Cnt].CountSet - Comp)) THEN
					ErrorCode   := 11;
					ErrorString := 'CountSet < Counter';
				ELSE
					ErrorCode   := 0;
					ErrorString := '';
				END_IF
				SetCheckDone[Cnt] := 1;
			END_IF

			IF MemArray[Cnt].CountSet < Comp THEN
				Comp := 0;
			END_IF

			IF CntArray[CntNoIndex] >= (MemArray[Cnt].CountSet - Comp) THEN
				IF MemArray[Cnt].InfoSet <> 0 THEN
					InUse_Type.CouplingClass := MemArray[Cnt].InfoSet;
					InUse_Type.Mode := Mode;
					InUse_Function();
					IF (MaxLane >= 1) AND (InUse_Type.Lane.SteeringLane[0] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[0].Out := 1; END_IF
					IF (MaxLane >= 2) AND (InUse_Type.Lane.SteeringLane[1] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[1].Out := 1; END_IF
					IF (MaxLane >= 3) AND (InUse_Type.Lane.SteeringLane[2] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[2].Out := 1; END_IF
					IF (MaxLane >= 4) AND (InUse_Type.Lane.SteeringLane[3] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[3].Out := 1; END_IF
					IF (MaxLane >= 5) AND (InUse_Type.Lane.SteeringLane[4] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[4].Out := 1; END_IF
					IF (MaxLane >= 6) AND (InUse_Type.Lane.SteeringLane[5] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[5].Out := 1; END_IF
				ELSE
					MemArray[Cnt].Out := 1;
				END_IF

				// Speciel outputs for 321 - 521 Lane operation 
				IF Mode = 31 AND MemArray[Cnt].InfoSet = 4 THEN
					IF Cnt = 0 THEN	MemArray[1].OutA := MemArray[0].Out; END_IF
					IF Cnt = 2 THEN	MemArray[1].OutB := MemArray[2].Out; END_IF
				ELSIF Mode = 51 AND MemArray[Cnt].InfoSet = 16 THEN
					IF Cnt = 1 THEN	MemArray[2].OutA := MemArray[1].Out; END_IF
					IF Cnt = 3 THEN	MemArray[2].OutB := MemArray[3].Out; END_IF
				ELSE
					IF Cnt = 1 THEN	MemArray[1].OutA := MemArray[1].Out; END_IF
					IF Cnt = 1 THEN	MemArray[1].OutB := MemArray[1].Out; END_IF
					IF Cnt = 2 THEN	MemArray[2].OutA := MemArray[2].Out; END_IF
					IF Cnt = 2 THEN	MemArray[2].OutB := MemArray[2].Out; END_IF
				END_IF

				MemArray[Cnt].Set := 0;
				MemArray[Cnt].InfoSet := 0;
				SetCheckDone[Cnt] := 0;
			END_IF
		END_IF

		//******************************* Reset *******************************
		IF MemArray[Cnt].Reset THEN
			// Check if CountReset is in the past 
			IF NOT ResetCheckDone[Cnt] THEN
				IF (MemArray[Cnt].CountReset > 0) AND (CntArray[CntNoIndex] > (MemArray[Cnt].CountReset - Comp)) THEN
					ErrorCode   := 12;
					ErrorString := 'CountReset < Counter';
				ELSE
					ErrorCode   := 0;
					ErrorString := '';
				END_IF
				ResetCheckDone[Cnt] := 1;
			END_IF

			IF MemArray[Cnt].CountReset < Comp THEN
				Comp := 0;
			END_IF

			IF CntArray[CntNoIndex] >= (MemArray[Cnt].CountReset - Comp) THEN
				IF MemArray[Cnt].InfoReset <> 0 THEN
					InUse_Type.CouplingClass := MemArray[Cnt].InfoReset;
					InUse_Type.Mode := Mode;
					InUse_Function();
					IF (MaxLane >= 1) AND (InUse_Type.Lane.SteeringLane[0] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[0].Out := 0; END_IF
					IF (MaxLane >= 2) AND (InUse_Type.Lane.SteeringLane[1] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[1].Out := 0; END_IF
					IF (MaxLane >= 3) AND (InUse_Type.Lane.SteeringLane[2] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[2].Out := 0; END_IF
					IF (MaxLane >= 4) AND (InUse_Type.Lane.SteeringLane[3] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[3].Out := 0; END_IF
					IF (MaxLane >= 5) AND (InUse_Type.Lane.SteeringLane[4] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[4].Out := 0; END_IF
					IF (MaxLane >= 6) AND (InUse_Type.Lane.SteeringLane[5] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[5].Out := 0; END_IF
				ELSE
					MemArray[Cnt].Out := 0;
				END_IF

				// Speciel outputs for 321 - 521 Lane operation 
				IF Mode = 31 AND MemArray[Cnt].InfoReset = 4 THEN
					IF Cnt = 0 THEN	MemArray[1].OutA := MemArray[0].Out; END_IF
					IF Cnt = 2 THEN	MemArray[1].OutB := MemArray[2].Out; END_IF
				ELSIF Mode = 51 AND MemArray[Cnt].InfoReset = 16 THEN
					IF Cnt = 1 THEN	MemArray[2].OutA := MemArray[1].Out; END_IF
					IF Cnt = 3 THEN	MemArray[2].OutB := MemArray[3].Out; END_IF
				ELSE
					IF Cnt = 1 THEN	MemArray[1].OutA := MemArray[1].Out; END_IF
					IF Cnt = 1 THEN	MemArray[1].OutB := MemArray[1].Out; END_IF
					IF Cnt = 2 THEN	MemArray[2].OutA := MemArray[2].Out; END_IF
					IF Cnt = 2 THEN	MemArray[2].OutB := MemArray[2].Out; END_IF
				END_IF

				MemArray[Cnt].Reset := 0;
				MemArray[Cnt].InfoReset := 0;
				ResetCheckDone[Cnt] := 0;
			END_IF
		END_IF
	END_FOR
END_FUNCTION_BLOCK