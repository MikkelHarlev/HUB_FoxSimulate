FUNCTION_BLOCK FB_FiFo
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	FiFo
	
		Description: 	Function to be used as First In and First Out
	
		Dependences:	
	
		Interfaces:  	
	
		History:		07-07-2005		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		
		The FiFo can hold elements "Size", according to the Declared Array (UINT). The Value of an element can't be 0 (zero).
		
		If "Reset" is TRUE, the FiFo will be initialized. All Elements will have a value of
		zero (0) including InfoOut.
		
		If "Set" is TRUE the "Info" will be placed as the last element in the FiFo. If "Full" is TRUE,
		the value will not be added.
		
		If "Get" is TRUE, the function will extract the oldest element to "InfoOut". If "Empty" is TRUE,
		no value will be extracted.
		
	
		Inputs:		Set		    BOOL	Put Value in Fifo
					Get			BOOL	Get Value from Fifo
					Reset		BOOL	Reset Fifo and "InfoOut"
					Info		UINT	Value to be entered to the Fifo by "Set"
					MemAdr		UDINT	Address of Array (UINT) used by the Fifo
					Size		USINT	Number of Elements in Array
					
		Outputs:	Out			BOOL	New "InfoOut"
					InfoOut 	UINT	Value from Fifo.
					Empty		BOOL	FiFo Empty
					Full		BOOL	FiFo Full
					ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
					
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF MemAdr <> oldMemAdr THEN
		InitDone := FALSE;
	END_IF
	oldMemAdr := MemAdr;
	
	(* Init *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF MemAdr > 0 THEN
			MemArray ACCESS MemAdr;
		ELSE
			ErrorCode := 1;
			ErrorString := 'MemAdr = 0';
			RETURN;
		END_IF;
		IF Size > 0 THEN
			Elements := Size;
		ELSE
			ErrorCode := 2;
			ErrorString := 'Size = 0';
			RETURN;
		END_IF;
		Reset    := 1;
		InitDone := 1;
	END_IF;
	
	(* Reset FiFo *)
	IF Reset THEN
		FOR Cnt := 0 TO Elements - 1 DO
			MemArray[Cnt] := 0;
		END_FOR;
		InfoOut := 0;
		Reset   := 0;
	END_IF;
	
	(* FiFo Full *)
	IF MemArray[0] <> 0 THEN
		Full := 1;
	ELSE
		Full := 0;
	END_IF;
	
	(* Put Element in FiFo *)
	IF Set AND NOT Full THEN
		Cnt := Elements;
		REPEAT
			Cnt := Cnt - 1;
			UNTIL ( MemArray[Cnt] = 0 ) OR ( Cnt = 0 )
		END_REPEAT;
		MemArray[Cnt] := Info;
	END_IF;
	Set := 0;
	
	(* Get Element in FiFo *)
	Out := 0;
	IF Get AND NOT Empty THEN
		Cnt     := Elements - 1;
		InfoOut := MemArray[Cnt];
		Out := 1;
		REPEAT
			MemArray[Cnt] := MemArray[Cnt - 1];
			Cnt := Cnt - 1;
			UNTIL ( MemArray[Cnt] = 0 ) OR ( Cnt = 0 )
		END_REPEAT;
		MemArray[Cnt]:= 0;
	END_IF;
	Get := 0;
	
	(* FiFo Empty *)
	IF MemArray[Elements - 1] = 0 THEN
		Empty := 1;
	ELSE
		Empty := 0;
	END_IF;
	
	
END_FUNCTION_BLOCK