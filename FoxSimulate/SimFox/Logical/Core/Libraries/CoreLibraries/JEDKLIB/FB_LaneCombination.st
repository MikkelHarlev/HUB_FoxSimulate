FUNCTION_BLOCK FB_LaneCombination
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Author:			Jensen Denmark
	
		Function:    	LaneCombination
	
		Description: 	Calculate CouplingClass
	
		Dependences:	
	
		Interfaces:  	
	
		History:		16-11-2007		V1.00		AHO
																														  *)
	(*--------------------------------------------------------------------------------------------------------------------*)
	(*
		Inputs:		Type_Adr  UDINT	Address OF LaneCombination_Type with the following variables:
					Mode				      USINT	Mode OF Lane Combination
	
		Outputs:	CouplingClass USINT   Calculated CoulingClass
					ErrorCode	  USINT	  IF Errorcode > 0 THEN see "ErrorString"
					ErrorString   STRING  Error Message
	
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	ErrorCode   := 0;
	ErrorString := '';
	IF Type_Adr > 0 THEN
		LaneCombination_Type ACCESS Type_Adr;
	ELSE
		ErrorCode   := 1;
		ErrorString := 'Type_Adr = 0';
		LaneCombination_Type.In.CouplingClass    := 0;
		LaneCombination_Type.In.CouplingClassOld := 0;
		LaneCombination_Type.Out.Coup[0] := LaneCombination_Type.Out.Coup[1] := LaneCombination_Type.Out.Coup[2] := LaneCombination_Type.Out.Coup[3] := LaneCombination_Type.Out.Coup[4] := 0;
		RETURN;
	END_IF;
	
	Mode := LaneCombination_Type.Mode;
	IF Mode = 0 OR Mode > 6 THEN
		ErrorCode   := 2;
		ErrorString := 'Mode = 0 or Mode > 6';
		LaneCombination_Type.In.CouplingClass := 0;
		LaneCombination_Type.In.CouplingClassOld := 0;
		LaneCombination_Type.Out.Coup[0] := LaneCombination_Type.Out.Coup[1] := LaneCombination_Type.Out.Coup[2] := LaneCombination_Type.Out.Coup[3] := LaneCombination_Type.Out.Coup[4] := 0;
		RETURN;
	END_IF;
	
	IF LaneCombination_Type.In_Out THEN
		(* Flags -> Class *)
		CouplingClassOld := CouplingClass;
	
		CouplingClass :=                  (1  * BOOL_TO_USINT((Mode >= 2) AND LaneCombination_Type.In.Coup[0]));
		CouplingClass := CouplingClass OR (2  * BOOL_TO_USINT((Mode >= 3) AND LaneCombination_Type.In.Coup[1]));
		CouplingClass := CouplingClass OR (4  * BOOL_TO_USINT((Mode >= 4) AND LaneCombination_Type.In.Coup[2]));
		CouplingClass := CouplingClass OR (8  * BOOL_TO_USINT((Mode >= 5) AND LaneCombination_Type.In.Coup[3]));
		CouplingClass := CouplingClass OR (16 * BOOL_TO_USINT((Mode >= 6) AND LaneCombination_Type.In.Coup[4]));
		LaneCombination_Type.In.CouplingClass := CouplingClass;
	
		(* Old CouplingClass *)
		IF EDGEPOS(CouplingClass <> CouplingClassOld) THEN
			LaneCombination_Type.In.CouplingClassOld := CouplingClassOld;
		END_IF;
	
		LaneCombination_Type.Out.Coup[0] := LaneCombination_Type.Out.Coup[1] := LaneCombination_Type.Out.Coup[2] := LaneCombination_Type.Out.Coup[3] := LaneCombination_Type.Out.Coup[4] := 0;
	ELSE
		(* Class -> Flags *)
		LaneCombination_Type.Out.Coup[0] := (Mode >= 2) AND ((LaneCombination_Type.Out.CouplingClass AND 1) = 1);
		LaneCombination_Type.Out.Coup[1] := (Mode >= 3) AND ((LaneCombination_Type.Out.CouplingClass AND 2) = 2);
		LaneCombination_Type.Out.Coup[2] := (Mode >= 4) AND ((LaneCombination_Type.Out.CouplingClass AND 4) = 4);
		LaneCombination_Type.Out.Coup[3] := (Mode >= 5) AND ((LaneCombination_Type.Out.CouplingClass AND 8) = 8);
		LaneCombination_Type.Out.Coup[4] := (Mode >= 6) AND ((LaneCombination_Type.Out.CouplingClass AND 16) = 16);
	
		LaneCombination_Type.In.CouplingClass := 0;
		LaneCombination_Type.Out.CouplingClassOld := 0;
	END_IF;
END_FUNCTION_BLOCK