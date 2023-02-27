FUNCTION_BLOCK FB_BlowPipe
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	BlowPipe
	
		Description: 	Handle array of BlowPipes.
	
		History:		07-07-2005		V0.00.1		CRT
						10-06-2008		V1.01		MHA/AHO
						14-04-2009		V1.02		AHO
						13-05-2009		V1.03		AHO 		Add check for wrong size of CntArray and MemArray
						02-11-2009		V1.04		AHO 		CntAdr and CntSize -> CntName, MemAdr and MemSize -> MemName
						07-12-2009		V1.05		AHO 		Init Bug Fix
						28-09-2010		V1.06		AHO 		Added: Error if Count was in the past
						05-10-2010		V1.07		AHO 		Fixed: Set Comp = 0 if > CountSet, Changed: Activate code if Counter >= CountSet (instaed of >)
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		The "Set" signal use the "CountSet" for delaying the "Out" signal. The "Comp" variable can be used for 
		Speedcompensation of the delay. The "CntAdr" contains the adress of the used countdown signal 
		( CycleCounter, Wheel etc.). The "Out" signal is ON as long as "On" is counted down by internal
		cyclic counter. 
		
		Inputs:		CntName		STRING[30]	Name of Counter variable 
					MemName		STRING[30]	Name of Memory variable, Blow_Type with the following variables:
						Set			BOOL	Triggers the function ( Leading EDGE )
						InfoSet		USINT	Lane Coupling used BY "Set"
						CountSet	UDINT	Delay based on Counter
						On			UINT	Time Output signal ON ( Cyclic dependant )
						OutCount	USINT	Number of Out (Multiblow)
						Gap			UINT	Gap between multiblow
						
						Out			BOOL	Output
						OutA 		BOOL	Output for 3-2-1 and 5-2-1 lane operation
						OutB 		BOOL	Output for 3-2-1 and 5-2-1 lane operation
							
					CntOutAdr	UDINT 	Address of special output counter
					Comp		USINT	Compensation ( Speedcompensation )
					Mode		USINT	Mode of Lane Combination
					
		Outputs:	ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
	
		Note: All lane combinations from Filter_Coupling function
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	(******************************** Init ********************************)

	(* Mode change..? *)
	IF Mode <> ModeOld OR CntNameAdr <> oldCntNameAdr OR CntOutAdr <> oldCntOutAdr OR MemNameAdr <> oldMemNameAdr THEN
		InitDone := FALSE;
	END_IF
	ModeOld := Mode;
	oldCntNameAdr := CntNameAdr;
	oldCntOutAdr := CntOutAdr;
	oldMemNameAdr := MemNameAdr;
	
	IF NOT InitDone THEN
		InitDone := 1;
		ErrorCode := 0;
		ErrorString := '';
	
		(* Mode check *)
		MaxLane := ModeOld := Mode;
		IF Mode = 31 THEN MaxLane := 3; END_IF;
		IF Mode = 51 THEN MaxLane := 5; END_IF;
		IF MaxLane = 0 OR MaxLane > 6 THEN
			ErrorCode := 101;
			ErrorString := 'Mode = 0 or > 6';
			RETURN;
		END_IF;

		IF CntNameAdr = 0 THEN
			ErrorCode := 102;
			ErrorString := 'Error: CntNameAdr = 0';
			RETURN;
		END_IF
		IF CntOutNameAdr = 0 THEN
			ErrorCode := 103;
			ErrorString := 'Error: CntOutNameAdr = 0';
			RETURN;
		END_IF
		IF MemNameAdr = 0 THEN
			ErrorCode := 104;
			ErrorString := 'Error: MemNameAdr = 0';
			RETURN;
		END_IF
		
		strMemSize := MAX(brsstrlen(CntNameAdr), brsstrlen(MemNameAdr))+13;
		IF strMemSize > 1000 THEN	// Possible not null-terminated string.
			ErrorCode := 105;
			ErrorString := 'CntNameAdr: Wrong Name-String address';
			RETURN;
		END_IF

		statusStrMemAlloc := TMP_alloc(strMemSize, ADR(taskNameConcatAdr));
		IF statusStrMemAlloc <> 0 THEN
			ErrorCode := 106;
			ErrorString := 'Memory alloc fail';
			RETURN;
		END_IF

		ST_name(0, taskNameConcatAdr, ADR(grp));
		strcat(taskNameConcatAdr, ADR(':'));
		strcat(taskNameConcatAdr, CntNameAdr);
		PV_ninfo(taskNameConcatAdr, ADR(CntType), ADR(CntLen), ADR(CntNo));
		PV_xgetadr(taskNameConcatAdr, ADR(CntAdr), ADR(CntLen));

		(* Counter check *)
		IF CntAdr > 0 THEN
			CntArray ACCESS CntAdr;
		ELSIF ErrorCode = 0 THEN
			ErrorCode := 108;
			ErrorString := 'CntNameAdr: Wrong Counter name';
			statusStrMemFree := TMP_free(strMemSize, taskNameConcatAdr);
			RETURN;
		END_IF;
		IF (CntNo > 1) AND (CntNo < MaxLane) THEN
			ErrorCode   := 109;
			ErrorString := 'Counter size < Mode';
			statusStrMemFree := TMP_free(strMemSize, taskNameConcatAdr);
			RETURN;
		END_IF;
		
		// Out counter
		ST_name(0, taskNameConcatAdr, ADR(grp));
		strcat(taskNameConcatAdr, ADR(':'));
		strcat(taskNameConcatAdr, CntOutNameAdr);
		PV_ninfo(taskNameConcatAdr, ADR(CntType), ADR(CntLen), ADR(CntNo));
		PV_xgetadr(taskNameConcatAdr, ADR(CntOutAdr), ADR(CntLen));

		IF CntOutAdr > 0 THEN
			pCounter ACCESS CntOutAdr;
		ELSE
			ErrorCode   := 110;
			ErrorString := 'CntOutNameAdr: Wrong Out-Counter name';
			statusStrMemFree := TMP_free(strMemSize, taskNameConcatAdr);
			RETURN;
		END_IF
	
		(* Memory check *)
		ST_name(0, taskNameConcatAdr, ADR(grp));
		strcat(taskNameConcatAdr, ADR(':'));
		strcat(taskNameConcatAdr, MemNameAdr);
		PV_ninfo(taskNameConcatAdr, ADR(MemType), ADR(MemLen), ADR(MemNo));
		PV_xgetadr(taskNameConcatAdr, ADR(MemAdr), ADR(MemLen));
		statusStrMemFree := TMP_free(strMemSize, taskNameConcatAdr);
		
		IF MemAdr > 0 THEN
			MemArray ACCESS MemAdr;
		ELSE
			ErrorCode := 111;
			ErrorString := 'MemNameAdr: Wrong variable name. Notice, no task name as prefix';
			RETURN;
		END_IF;
		IF (MemNo >= 1) AND (MemNo < MaxLane) THEN
			ErrorCode := 112;
			ErrorString := 'Memory size < Mode';
			RETURN;
		END_IF;
	
		(* InUse check *)
		InUse_Type.Mode := Mode;
		InUse_Function(InitDone := FALSE, InUse_Type_Adr := ADR(InUse_Type));
		IF InUse_Function.ErrorCode > 0 THEN
			ErrorCode := 1000 + InUse_Function.ErrorCode;
			brsstrcpy(brsstrcpy(ADR(ErrorString), ADR('InUse Function error: ')), ADR(InUse_Function.ErrorString));
			RETURN;
		END_IF;
	
	END_IF
	
	IF ErrorCode >= 100 THEN
		RETURN;
	END_IF
	
	OnCounter := pCounter;
	
	(******************************** Function ********************************)
	FOR Cnt := 0 TO (MaxLane-1) DO
		(* Only 1 counter - none array *)
		IF CntNo = 1 THEN
			CntNoIndex := 0;
		ELSE
			CntNoIndex := Cnt;
		END_IF;

		Counter[Cnt] := CntArray[CntNoIndex];

		(******************************** Set ********************************)
		IF MemArray[Cnt].Set OR RSet[Cnt] THEN
			(* Check if Count is in the past *)
			IF NOT SetCheckDone[Cnt] THEN
				IF (MemArray[Cnt].Count > 0) AND (CntArray[CntNoIndex] > (MemArray[Cnt].Count - Comp)) THEN
					ErrorCode   := 11;
					ErrorString := 'Count < Counter';
				ELSE
					ErrorCode   := 0;
					ErrorString := '';
				END_IF;
				SetCheckDone[Cnt] := 1;
			END_IF;
	
			IF MemArray[Cnt].Count < Comp THEN
				Comp := UDINT_TO_USINT(MemArray[Cnt].Count);
			END_IF;
			IF MemArray[Cnt].OutCount < 1 THEN
				MemArray[Cnt].OutCount := 1;
			END_IF
	
			(* Blow / MultiBlow *)
			IF CntArray[CntNoIndex] >= (MemArray[Cnt].Count - Comp) THEN
				IF NOT MemArray[Cnt].Out THEN
					OnCounterInternal[Cnt] := pCounter + MemArray[Cnt].On;
				END_IF;
				MemArray[Cnt].Out := (GapCounter[Cnt] <= pCounter);
			END_IF;
			IF (pCounter >= OnCounterInternal[Cnt]) AND MemArray[Cnt].Out OR NOT MemArray[Cnt].Set THEN
				MemArray[Cnt].Out := 0;
				OutCountIndex[Cnt] := OutCountIndex[Cnt] + 1;
				IF OutCountIndex[Cnt] >= MemArray[Cnt].OutCount OR NOT MemArray[Cnt].Set THEN
					MemArray[Cnt].OutCount := 1;
					MemArray[Cnt].Set 	   := 0;
					RSet[Cnt] 			   := 0;
					OutCountIndex[Cnt]	   := 0;
				ELSE
					GapCounter[Cnt] := pCounter + MemArray[Cnt].Gap;
				END_IF
			END_IF;
	
			(* Set output *)
			IF MemArray[Cnt].Info <> 0 THEN
				InUse_Type.CouplingClass := MemArray[Cnt].Info;
				InUse_Type.Mode := Mode;
				InUse_Function();
				IF (MaxLane >= 1) AND (InUse_Type.Lane.SteeringLane[0] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[0].Out := MemArray[Cnt].Out; END_IF;
				IF (MaxLane >= 2) AND (InUse_Type.Lane.SteeringLane[1] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[1].Out := MemArray[Cnt].Out; END_IF;
				IF (MaxLane >= 3) AND (InUse_Type.Lane.SteeringLane[2] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[2].Out := MemArray[Cnt].Out; END_IF;
				IF (MaxLane >= 4) AND (InUse_Type.Lane.SteeringLane[3] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[3].Out := MemArray[Cnt].Out; END_IF;
				IF (MaxLane >= 5) AND (InUse_Type.Lane.SteeringLane[4] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[4].Out := MemArray[Cnt].Out; END_IF;
				IF (MaxLane >= 6) AND (InUse_Type.Lane.SteeringLane[5] = InUse_Type.Lane.SteeringLane[Cnt]) THEN MemArray[5].Out := MemArray[Cnt].Out; END_IF;
			END_IF;
	
			(* Speciel outputs for 321 - 521 Lane operation *)
			IF Mode = 31 AND MemArray[Cnt].Info = 4 THEN
				IF Cnt = 0 THEN	MemArray[1].OutA := MemArray[0].Out; END_IF;
				IF Cnt = 2 THEN	MemArray[1].OutB := MemArray[2].Out; END_IF;
			ELSIF Mode = 51 AND MemArray[Cnt].Info = 16 THEN
				IF Cnt = 1 THEN	MemArray[2].OutA := MemArray[1].Out; END_IF;
				IF Cnt = 3 THEN	MemArray[2].OutB := MemArray[3].Out; END_IF;
			ELSE
				IF Cnt = 1 THEN	MemArray[1].OutA := MemArray[1].Out; END_IF;
				IF Cnt = 1 THEN	MemArray[1].OutB := MemArray[1].Out; END_IF;
				IF Cnt = 2 THEN	MemArray[2].OutA := MemArray[2].Out; END_IF;
				IF Cnt = 2 THEN	MemArray[2].OutB := MemArray[2].Out; END_IF;
			END_IF;
	
			IF NOT MemArray[Cnt].Set THEN
				MemArray[Cnt].Info := 0;
				SetCheckDone[Cnt] := 0;
			END_IF
		END_IF
		RSet[Cnt] := MemArray[Cnt].Set;
	END_FOR
END_FUNCTION_BLOCK