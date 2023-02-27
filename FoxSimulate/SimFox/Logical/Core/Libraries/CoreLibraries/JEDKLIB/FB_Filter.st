FUNCTION_BLOCK FB_Filter
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Filter
	
		Description: 	Filter with/without triggering, based on external Counter.
	
		Dependences:	
	
		Interfaces:  	
	
		History:		07-07-2005		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		
		The "IN" signal will be filtered according to the "FMode", and the "Out" will be triggered according to the "TMode"
		The "CntAdr" contains the adress of the used counter signal ( CycleCounter, Wheel etc.). 
	
					 				
				FilterModes:	0: No Filter			TriggerModes:	0: No Trigger
				-----------		1: Leading 				------------	1: Leading edges
								2: Trailing								2: Trailing edges
								3: Both									3: Both edges
	
	
		Inputs:		In			BOOL	Input signal
					FMode		USINT	Filter Mode
					TMode		USINT	Trigger Mode
					Filter		UDINT	Filter Value
					CntAdr		UDINT	Adress OF Counter
	
		Outputs:	Out			BOOL	Output signal
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
	
	(* Filter Mode *)
	CASE FMode OF
		0:	(* No Filter *)
			ROut := In;
	
		1:	(* Leading edge filter *)
			IF In THEN
				(* Check if Input has been On for more than Filtervalue *)
			  	IF pCounter > LCount THEN
					ROut := 1;
				END_IF;
			ELSE
				(* Update filter *)
				LCount := pCounter + Filter;
				ROut := 0;
			END_IF;
	
		2:	(* Trailing edge filter *)
			IF In THEN
				(* Update filter *)
				TCount := pCounter + Filter;
				ROut := 1;
			ELSE
				(* Check if Input has been On for more than Filtervalue *)
			  	IF pCounter > TCount THEN
					ROut := 0;
				END_IF;
			END_IF;
	
		3:	(* Filter *)
			IF In THEN
				(* Check if Input has been On for more than Filtervalue *)
			  	IF pCounter > LCount THEN
					ROut := 1;
				END_IF;
				(* Update filter *)
				TCount := pCounter + Filter;
			ELSE
				(* Check if Input has been Off for more than Filtervalue *)
			  	IF pCounter > TCount THEN
					ROut := 0;
				END_IF;
				(* Update filter *)
				LCount := pCounter + Filter;
			END_IF;
	END_CASE;
	
	(* Trigger Mode *)
	CASE TMode OF
		0:  (* No Triggering *)
			Out := ROut;
	
		1:	(* Trigger Leading Edge *)
			Out := ROut AND NOT RTrig;
	
		2:	(* Trigger Trailing Edge *)
			Out := NOT ROut AND RTrig;
	
		3:	(* Trigger Edges *)
			Out := ROut XOR RTrig;
	END_CASE;
	OutF := ROut;
	OutPosEdge := ROut AND NOT RTrig;
	OutNegEdge := NOT ROut AND RTrig;
	
	RTrig := ROut;
END_FUNCTION_BLOCK