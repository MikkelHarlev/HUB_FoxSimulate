FUNCTION_BLOCK FB_DelayOn
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	DelayOn
	
		Description: 	Delay and On signal based on external Counters.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		07-07-2005		V0.01		CRT
						23-11-2009		V1.01		AHO		Change Info and InfoOut from BOOL to UINT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		
		It detects the leading edge of the "Set" signal, use the "Delay" for delaying the "Out" signal. The "Comp" 
		variable can be used for Speedcompensation of the delay. The "Info" will be copied to "InfoOut", and the state 
		will be valid until next delayed "set"The "Cnt1Adr" contains the adress of the used	countdown signal 
		(CycleCounter, Wheel etc.). The "Out" signal is ON as long as "On" is counted down by the 
		"Cnt2Adr". The "Cnt2Adr" contains the adress of the used countdown signal (CycleCounter, Wheel etc.).
		
		Inputs:		Set			BOOL	Triggers the function (Leading Edge)
					Info		UINT	Can be used for Lanecoupling
					Delay		UINT	Delay based on Counter1
					On			UDINT	Out signal ON, based on Counter2
					Comp		UDINT	Compensation (Speedcompensation)
					Cnt1Adr		UDINT	Address of Counter1
					Cnt2Adr		UDINT	Address of Counter2
					
		Outputs:	Out			BOOL	Output signal (One Cycle only).
					InfoOut		UINT	Can be used for Lanecoupling
					ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF Cnt1Adr <> oldCnt1Adr OR Cnt2Adr <> oldCnt2Adr THEN
		InitDone := FALSE;
	END_IF
	oldCnt1Adr := Cnt1Adr;
	oldCnt2Adr := Cnt2Adr;
	
	(* Init *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF Cnt1Adr > 0 THEN
			pCounter1 ACCESS (Cnt1Adr);
		ELSE
			ErrorCode   := 3;
			ErrorString := 'Cnt1Adr = 0';
			RETURN;
		END_IF;
		IF Cnt2Adr > 0 THEN
			pCounter2 ACCESS (Cnt2Adr);
		ELSE
			ErrorCode   := 4;
			ErrorString := 'Cnt2Adr = 0';
			RETURN;
		END_IF;
		InitDone := 1;
	END_IF;
	
	Counter1 := pCounter1;
	Counter2 := pCounter2;
	
	(* Set the counters for the "Out" signal *)
	IF Set THEN
		OutCounterInternal := pCounter1 + Delay;
		RInfo := Info;
		RSet := Set;
		Out := 0;
		InfoOut := 0;
	END_IF;
	Set := 0;
	
	IF RSet THEN
		(* Wait until Outputs should be Set *)
		IF Comp > Delay THEN
			Comp := Delay;
		END_IF;
		IF pCounter1 > (OutCounterInternal - Comp) THEN
			(* Set Output Counter *)
			IF NOT Out THEN
				OnCounterInternal := pCounter2 + On;
			END_IF;
			Out := 1;
			InfoOut := RInfo;
			(* Wait until Outputs should be Reset *)
			IF pCounter2 > OnCounterInternal THEN
				Out := 0;
				InfoOut := 0;
				RInfo := 0;
				RSet := 0;
			END_IF;
		END_IF;
	END_IF;
END_FUNCTION_BLOCK