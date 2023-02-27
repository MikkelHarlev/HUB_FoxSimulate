
(* TODO: Add your comment here *)
FUNCTION T2F_New
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA; 
	IF Data.init = FALSE THEN
		RETURN;
	END_IF

	Data.DTStructureGetTime_0(enable := TRUE, pDTStructure := ADR(Data.DTStructureCurrent));
	Data.FiFo[Data.FiFo_In].TimeStamp := Data.DTStructureCurrent;
	notused := strcpy(ADR(Data.FiFo[Data.FiFo_In].Text), W);
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(';'));
	notused := strcpy(ADR(Data.FiFo[Data.FiFo_In].Function), F);

	T2F_New := TRUE;

END_FUNCTION
