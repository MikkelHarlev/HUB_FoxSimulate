FUNCTION_BLOCK FB_DFiFo
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	DFiFo
	
		Description: 	Function to be used as First In and First Out with Delay on, and delay off.
		
		History:		07-07-2005		V0.01		CRT		
						20-11-2009		V1.01		AHO		Added new output "OutOn", Delay off based on counter from CntOnAdr 																													  *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Description:
		
		The FiFo can hold elements "Size", according to the Declared Array (UDINT/UINT). The Value of an element can't be 0 (zero).
		
		The "Delay" is used to delay the "Out" and "InfoOut". The "Delay" use the Counter at the "CntAdr" for the
		timing.
	
		The "On" is used to delay off the "Out". The "On" use the Counter at the "CntOnAdr" for the
		timing.
			
		If "Reset" is TRUE, the FiFo will be initialized. All Elements will have a value of
		zero (0) including InfoOut.
		
		If "Set" is TRUE the "Info" will be placed as the last element in the FiFo. If "Full" is TRUE,
		the value will not be added.
		
	
		Inputs:		Set		    BOOL	Put Value in Fifo
					Reset		BOOL	Reset Fifo and "InfoOut"
					Info		UINT	Value to be entered to the Fifo by "Set"
					Delay		UDINT	Delay from "Set" to "Out"
					On			UINT	Time Output signal ON
					CntAdr		UDINT	Address of Counter
					CntOnAdr	UDINT	Address of On Counter 
					MemAdr		UDINT	Address of Array used by the Fifo
					Size		USINT	Number of Elements in Array
					
		Outputs:	Out			BOOL	New "InfoOut"
					OutOn		BOOL	New "InfoOut", High in "On" time.
					InfoOut 	UINT	Value from Fifo.
					Empty		BOOL	FiFo Empty
					Full		BOOL	FiFo Full
					ErrorCode	USINT	If Errorcode > 0 then see "ErrorString"
					ErrorString STRING	Error Message		
					
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	
	IF CntAdr <> oldCntAdr OR CntOnAdr <> oldCntOnAdr THEN
		InitDone := FALSE;
	END_IF
	oldCntAdr := CntAdr;
	oldCntOnAdr := CntOnAdr;
	
	(* Init *)
	IF NOT InitDone THEN
		ErrorCode   := 0;
		ErrorString := '';
		IF CntAdr > 0 THEN
			pCounter  ACCESS CntAdr;
		ELSE
			ErrorCode := 3;
			ErrorString := 'CntAdr = 0';
			RETURN;
		END_IF;
		IF CntOnAdr > 0 THEN
			pCounterOn ACCESS CntOnAdr;
		ELSE
			pCounterOn ACCESS ADR(CntEmpty);
		END_IF;
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
	CntEmpty := 0;
	
	(* Reset FiFo *)
	IF Reset THEN
		FOR Cnt := 0 TO (Elements -1) DO
			MemArray[Cnt].Count   := 0;
			MemArray[Cnt].CountOn := 0;
			MemArray[Cnt].Info    := 0;
		END_FOR;
		InfoOut := 0;
		Reset   := 0;
	END_IF;
	
	Counter := pCounter;
	CounterOn := pCounterOn;
	
	(* Put Element in FiFo *)
	IF Set AND NOT Full THEN
		FOR Cnt := 0 TO (Elements -1) DO
			IF (MemArray[Cnt].Count = 0) THEN
				MemArray[Cnt].Count := pCounter + Delay;
				MemArray[Cnt].Info  := Info;
				EXIT;
			END_IF;
		END_FOR;
	END_IF;
	Set := 0;
	
	(* Get Element in FiFo *)
	Out := OutOn := 0;
	FOR	Cnt := 0 TO (Elements -1) DO
		(* Output: Out *)
		(* Find passed element *)
		IF (MemArray[Cnt].Count > 0) AND (pCounter > MemArray[Cnt].Count) THEN
			Out := 1;
			InfoOut := MemArray[Cnt].Info;
			MemArray[Cnt].Count := 0;
			MemArray[Cnt].CountOn := pCounterOn + On;
		END_IF;
	
		(* Output: OutOn *)
		IF (pCounterOn = 0) OR (On = 0) THEN
			OutOn := Out;	(* Follow "Out" *)
			MemArray[Cnt].CountOn := 0;
		ELSE
			IF (pCounterOn > MemArray[Cnt].CountOn) THEN
				MemArray[Cnt].CountOn := 0;
			END_IF;
			OutOn := OutOn OR ((MemArray[Cnt].CountOn > 0) AND (pCounterOn <= MemArray[Cnt].CountOn));
		END_IF;
	END_FOR;
	
	(* Output: OutOn *)
	FOR	Cnt := 0 TO (Elements -1) DO
		IF NOT((pCounterOn = 0) OR (On = 0)) THEN
			IF (MemArray[Cnt].CountOn > 0) AND ((pCounterOn +1) > MemArray[Cnt].CountOn) AND (pCounterOn <= MemArray[Cnt].CountOn) THEN
				IF OutOn THEN
					ErrorString := 'New "OutOn"';
				ELSE
					ErrorString := '';
				END_IF;
				OutOn := 0;
			END_IF;
		END_IF;
	END_FOR;
	
	(* Full/empty..? *)
	Empty := Full := 1;
	FOR	Cnt := 0 TO (Elements -1) DO
		(* FiFo Empty or Full *)
		IF (MemArray[Cnt].Count > 0) OR (MemArray[Cnt].CountOn > 0) THEN
			Empty := 0;
		ELSE
			Full  := 0;
		END_IF;
	END_FOR;
	IF Empty THEN
		ErrorString := '';
	END_IF;
	
END_FUNCTION_BLOCK