FUNCTION HEX_TO_UINT
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	Hex_To_UINT
	
		Description: 	Handle Conversion of 4 USINT HEX ASCII Value to an UINT
	
		Dependences:	
	
		Interfaces:  	
	
		History:		01-10-2007		V0.01		CRT
																														  *)
	(*----------------------------------------------* cyclic program *----------------------------------------------------*)
	
	Convert ACCESS pData;
	
	Convert.Value := 0;
	
	IF Convert.Hex[0] > 57 THEN
		Convert.Value := ( Convert.Hex[0] - 55 ) * 4096;
	ELSE
		Convert.Value := ( Convert.Hex[0] - 48 ) * 4096;
	END_IF;
	
	IF Convert.Hex[1] > 57 THEN
		Convert.Value := Convert.Value + ( Convert.Hex[1] - 55 ) * 256;
	ELSE
		Convert.Value := Convert.Value + ( Convert.Hex[1] - 48 ) * 256;
	END_IF;
	
	IF Convert.Hex[2] > 57 THEN
		Convert.Value := Convert.Value + ( Convert.Hex[2] - 55 ) * 16;
	ELSE
		Convert.Value := Convert.Value + ( Convert.Hex[2] - 48 ) * 16;
	END_IF;
	
	IF Convert.Hex[3] > 57 THEN
		Convert.Value := Convert.Value + ( Convert.Hex[3] - 55 );
	ELSE
		Convert.Value := Convert.Value + ( Convert.Hex[3] - 48 );
	END_IF;
	
	HEX_TO_UINT := 0;
	
END_FUNCTION