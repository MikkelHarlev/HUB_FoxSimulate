FUNCTION_BLOCK FB_Delay
	(*
		Author:			Jensen Denmark
	
		Function:    	Delay
	
		Description: 	Delay based on external Counter.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		07-07-2005		V0.01		CRT	
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Discription:
		
		It detects the leading edge of the "Set" signal, use the "Delay" for delaying the "Trig" signal. The "Comp" 
		variable can be used for Speedcompensation of the delay. The "CntAdr" contains the adress of the used
		countdown signal ( CycleCounter, Wheel etc.). The "Trig" signal is ON for one cycle. The "Out" signal wil be
		ON as long as "Set" and the "Delay" are active.
		
		Inputs:		Set			BOOL	Triggers the function ( Leading Edge )
					Delay		UINT	Delay based on Counter
					Comp		UDINT	Compensation ( Speedcompensation )
					CntAdr		UDINT	Address of Counter
					
		Outputs:	Out			BOOL	Output signal while running
					Trig		BOOL	Output signal ( One Cycle only ).
					ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF CntAdr <> oldCntAdr THEN
		InitDone := FALSE;
	END_IF
	oldCntAdr := CntAdr;
	
	(* Init *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF CntAdr > 0 THEN
			pCounter ACCESS (CntAdr);
		ELSE
			ErrorCode   := 3;
			ErrorString := 'CntAdr = 0';
			RETURN;
		END_IF;
		InitDone := 1;
	END_IF;
	
	Counter := pCounter;
	
	Trig := 0;
	
	(* Set the counters for the "Out" signal *)
	IF Set THEN
		OutCounter := pCounter + Delay;
		Out := 1;
	END_IF;
	Set := 0;
	
	(* Wait until "Out" should be Set *)
	IF Out THEN
		IF Comp > Delay THEN
			Comp := Delay;
		END_IF;
		IF pCounter > ( OutCounter - Comp ) THEN
			Out  := 0;
			Trig := 1;
		END_IF;
	END_IF;
	
END_FUNCTION_BLOCK