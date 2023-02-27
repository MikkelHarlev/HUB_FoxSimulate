FUNCTION UINT_TO_HEX
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	UINT_To_Hex
	
		Description: 	Handle Conversion of an UINT to 4 USINT HEX ASCII Values
	
		Dependences:	
	
		Interfaces:  	
	
		History:		01-10-2007		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	
	Convert ACCESS pData;
	
	Temp1 := UINT_TO_USINT( Convert.Value / 256 );
	Temp2 := UINT_TO_USINT( Convert.Value - ( Temp1 * 256 ));
	
	Convert.Hex[0] := UINT_TO_USINT( Temp1 / 16 );
	Convert.Hex[1] := UINT_TO_USINT( Temp1 - ( Convert.Hex[0] * 16 ));
	Convert.Hex[2] := UINT_TO_USINT( Temp2 / 16 );
	Convert.Hex[3] := UINT_TO_USINT( Temp2 - ( Convert.Hex[2] * 16 ));
	
	FOR Cnt := 0 TO 3 DO
		IF Convert.Hex[Cnt] > 9 THEN
			Convert.Hex[Cnt] := 55 + Convert.Hex[Cnt];
		ELSE
			Convert.Hex[Cnt] := 48 + Convert.Hex[Cnt];
		END_IF;
	END_FOR;
	
	UINT_TO_HEX := 0;
	
	
	
END_FUNCTION