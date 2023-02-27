FUNCTION_BLOCK FB_EnCode
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Encode Password
	
		Description: 	Encoding PassWord String to Number.
	
		Dependences:	PassWord_Type
	
		Interfaces:  	
	
		History:		02-01-2005		V0.00.1		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	(*
		The Function Block will encode a STRING[4] to UDINT.
						 				
		
		Inputs:		PassWordAdr	UDINT	Address of PassWord_Type ( PassWord_Type member "String" used for the encoding )
	
		Outputs:	None ( PassWord_Type member "Code" updated )
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	IF PassWordAdr <> oldPassWordAdr THEN
		InitDone := FALSE;
	END_IF
	oldPassWordAdr := PassWordAdr;
	
	(* Init *)
	IF NOT InitDone THEN
		InitDone := 1;
		IF PassWordAdr = 0 THEN
			ErrorCode   := 1;
			ErrorString := 'PassWordAdr = 0';
			RETURN;
		END_IF
		Copy  ACCESS( PassWordAdr + 4 );
		TLong ACCESS( PassWordAdr );
		TWord ACCESS( ADR( TLong ));
		TByte ACCESS( ADR( TLong ));
	END_IF;
	
	(* Decode *)
	Pass := Copy;
	FOR b := 3 TO 0 BY -1 DO
		FOR i := 0 TO 1 DO
			FOR s := 3 TO 0 BY -1 DO
				TByte[s] := TByte[s] * 2 + (( Pass[b] AND 1 ) = 1 );
				Pass[b] := Pass[b] / 2;
			END_FOR;
		END_FOR;
	END_FOR;
	TWord[0] := TWord[0] XOR 27966;
	TWord[1] := TWord[1] XOR 27966;
	
	
	
END_FUNCTION_BLOCK