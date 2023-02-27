FUNCTION_BLOCK FB_NFifo
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	NFiFo
	
		Description: 	Function to be used as First In and First Out with Delay
	
		Dependences:	
	
		Interfaces:  	
	
		History:		08-02-2007		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		Description:
		
	
	
					
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF pCounter <> oldpCounter OR pDataIn <> oldpDataIn OR pDataOut <> oldpDataOut OR pDataArray <> oldpDataArray OR DataArraySize <> oldDataArraySize OR DataTypeSize <> oldDataTypeSize THEN
		InitDone := FALSE;
	END_IF
	oldpCounter := pCounter;
	oldpDataIn := pDataIn;
	oldpDataOut := pDataOut;
	oldpDataArray := pDataArray;
	oldDataArraySize := DataArraySize;
	oldDataTypeSize := DataTypeSize;
		
	(* Init *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF pCounter > 0 THEN
			Counter  ACCESS pCounter;
		ELSE
			ErrorCode := 1;
			ErrorString := 'pCounter = 0';
			RETURN;
		END_IF;
		IF pDataIn = 0 THEN
			ErrorCode := 2;
			ErrorString := 'pDataIn = 0';
			RETURN;
		END_IF;
		IF pDataOut = 0 THEN
			ErrorCode := 3;
			ErrorString := 'pDataOut = 0';
			RETURN;
		END_IF;
		IF pDataArray = 0 THEN
			ErrorCode := 4;
			ErrorString := 'pDataOut = 0';
			RETURN;
		END_IF;
		IF DataArraySize = 0 THEN
			ErrorCode := 5;
			ErrorString := 'pDataArray = 0';
			RETURN;
		END_IF;
		IF DataTypeSize = 0 THEN
			ErrorCode := 6;
			ErrorString := 'DataTypeSize = 0';
			RETURN;
		END_IF;
		Reset := 1;
		InitDone  := 1;
	END_IF;
	
	(* Reset FiFo *)
	IF Reset THEN
		FOR Cnt := 0 TO DataArraySize - 1 DO
			DataArrayCounter[Cnt] := 0;
		END_FOR;
		NewDataOut := 0;
		Reset      := 0;
	END_IF;
	
	(* Put Element in FiFo *)
	IF NewDataIn AND NOT Full THEN
		FOR Cnt := 0 TO DataArraySize - 1 DO
			IF DataArrayCounter[Cnt] = 0 THEN
				DataArrayCounter[Cnt] := Counter + Delay;
				memcpy( pDataArray + ( DataTypeSize * Cnt ), pDataIn, DataTypeSize );
				EXIT;
			END_IF;
		END_FOR;
	END_IF;
	NewDataIn := 0;
	
	(* Get Element in FiFo *)
	NewDataOut := 0;
	Empty      := 1;
	Full       := 1;
	FOR	Cnt := 0 TO DataArraySize - 1 DO
		(* Find passed element *)
		IF ( DataArrayCounter[Cnt] > 0 ) AND ( Counter > DataArrayCounter[Cnt] ) THEN
			memcpy( pDataOut, pDataArray + ( DataTypeSize * Cnt ), DataTypeSize );
			DataArrayCounter[Cnt] := 0;
			NewDataOut := 1;
		END_IF;
		(* FiFo Empty or Full *)
		IF DataArrayCounter[Cnt] > 0 THEN
			Empty := 0;
		ELSE
			Full  := 0;
		END_IF;
	END_FOR;
	
	
END_FUNCTION_BLOCK