FUNCTION_BLOCK FB_CustArtFifo
	(*--------------------------------------------------------------------------------------------------------------------
		Author:			Jensen Denmark
	
		Function:    	CustArtFiFo
	
		Description: 	Function to be used as First In and First Out with Delay
	
		Dependences:	
	
		Interfaces:  	
	
		History:		07-07-2005		V0.01		CRT
						17-12-2015		V1.01		AHO	Added: BatchID + 3 spares
						21-12-2015		V1.02		AHO	Added: SourceID

	----------------------------------------------* cyclic PROGRAM *----------------------------------------------------
		Description:
		
		The FiFo can hold elements "Size", according to the Declared Array (UDINT/UINT). The Value of an element can't be 0 (zero).
		
		The "Delay" is used to delay the "Out". The "Delay" use the Counter at the "CntAdr" for the
		timing.
		
		If "Reset" is TRUE, the FiFo will be initialized. 
		
		If "Set" is TRUE the Information will be placed as the last element in the FiFo. If "Full" is TRUE,
		the value will not be added.
		
	
		Inputs:		Set		    		BOOL		Put Value in Fifo
					Reset				BOOL		Reset Fifo and "InfoOut"
	
					RcpNo				USINT		Recipe Number
					CustomerNo			UDINT		Customer Number
					ArticleNo			UDINT		Article Number
					CustomerChange		BOOL		Customer Change
					RcpText				STRING[32]	Recipe Text
					CustomerText		STRING[32]	Customer Text
					ArticleText			STRING[32]	Article Text
					BatchID				UDINT		BatchID
					SourceID			UDINT		SourceID
					SpareUDINT1			UDINT		SpareUDINT
					SpareUDINT2			UDINT		SpareUDINT
					SpareUDINT3			UDINT		SpareUDINT
					
					Delay				UDINT		Delay from "Set" to "Out"
					CntAdr				UDINT		Address of Counter
					MemAdr				UDINT		Address of Array used by the Fifo
					Size				USINT		Number of Elements in Array
					
		Outputs:	Out					BOOL		New Info
	
					RcpNoOut			USINT		Recipe Number
					CustomerNoOut		UDINT		Customer Number
					ArticleNoOut		UDINT		Article Number
					CustomerChangeOut	BOOL		Customer Change
					RcpTextOut			STRING[32]	Recipe Text
					CustomerTextOut		STRING[32]	Customer Text
					ArticleTextOut		STRING[32]	Article Text
					BatchIDOut			UDINT		BatchID
					SourceIDOut			UDINT		SourceID
					SpareUDINT1Out		UDINT		SpareUDINT
					SpareUDINT2Out		UDINT		SpareUDINT
					SpareUDINT3Out		UDINT		SpareUDINT
					
					Empty				BOOL		FiFo Empty
					Full				BOOL		FiFo Full
					ErrorCode			USINT		If Errorcode > 0 then see "ErrorString"
					ErrorString 		STRING[16]	Error Message		
					
	--------------------------------------------------------------------------------------------------------------------*)
	
	IF CntAdr <> oldCntAdr THEN
		InitDone := FALSE;
	END_IF
	oldCntAdr := CntAdr;
	
	// Init 
	IF NOT InitDone THEN
		ErrorCode := 0;
		ErrorString := '';
		IF CntAdr > 0 THEN
			pCounter  ACCESS CntAdr;
		ELSE
			ErrorCode := 3;
			ErrorString := 'CntAdr = 0';
			RETURN;
		END_IF
		IF MemAdr > 0 THEN
			MemArray ACCESS MemAdr;
		ELSE
			ErrorCode := 1;
			ErrorString := 'MemAdr = 0';
			RETURN;
		END_IF
		IF Size > 0 THEN
			Elements := Size;
		ELSE
			ErrorCode := 2;
			ErrorString := 'Size = 0';
			RETURN;
		END_IF
		Reset := 1;
		InitDone := 1;
	END_IF
	
	Counter := pCounter;
	
	// Reset FiFo 
	IF Reset THEN
		FOR Cnt := 0 TO Elements - 1 DO
			MemArray[Cnt].Count := 0;
		END_FOR
		Reset := 0;
	END_IF
	
	// Put Element in FiFo 
	IF Set AND NOT Full THEN
		FOR Cnt := 0 TO Elements - 1 DO
			IF MemArray[Cnt].Count = 0 THEN
				MemArray[Cnt].Count := pCounter + Delay;
				MemArray[Cnt].RcpNo := RcpNo;
				MemArray[Cnt].CustomerNo := UDINT_TO_UINT(CustomerNo);
				MemArray[Cnt].ArticleNo := UDINT_TO_UINT(ArticleNo);
				MemArray[Cnt].CustomerChange := CustomerChange;
				MemArray[Cnt].RcpText := RcpText;
				MemArray[Cnt].CustomerText := CustomerText;
				MemArray[Cnt].ArticleText := ArticleText;
				MemArray[Cnt].BatchID := BatchID;
				MemArray[Cnt].SourceID := SourceID;
				MemArray[Cnt].SpareUDINT1 := SpareUDINT1;
				MemArray[Cnt].SpareUDINT2 := SpareUDINT2;
				MemArray[Cnt].SpareUDINT3 := SpareUDINT3;
				EXIT;
			END_IF
		END_FOR
	END_IF
	Set := 0;
	
	// Get Element in FiFo 
	Out := 0;
	Empty := 1;
	Full := 1;
	FOR	Cnt := 0 TO Elements - 1 DO
		// Find passed element 
		IF ( MemArray[Cnt].Count > 0 ) AND ( pCounter > MemArray[Cnt].Count ) THEN
			Out := 1;
			RcpNoOut := MemArray[Cnt].RcpNo;
			CustomerNoOut := MemArray[Cnt].CustomerNo;
			ArticleNoOut := MemArray[Cnt].ArticleNo;
			CustomerChangeOut := MemArray[Cnt].CustomerChange;
			RcpTextOut := MemArray[Cnt].RcpText;
			CustomerTextOut := MemArray[Cnt].CustomerText;
			ArticleTextOut := MemArray[Cnt].ArticleText;
			BatchIDOut := MemArray[Cnt].BatchID;
			SourceIDOut := MemArray[Cnt].SourceID;
			SpareUDINT1Out := MemArray[Cnt].SpareUDINT1;
			SpareUDINT2Out := MemArray[Cnt].SpareUDINT2;
			SpareUDINT3Out := MemArray[Cnt].SpareUDINT3;			
			MemArray[Cnt].Count := 0;
		END_IF
		// FiFo Empty or Full 
		IF MemArray[Cnt].Count > 0 THEN
			Empty := 0;
		ELSE
			Full := 0;
		END_IF
	END_FOR	
	
END_FUNCTION_BLOCK