
(* Not working in FOX sw *)
FUNCTION T2F_AddString
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA; 
	IF Data.init = FALSE THEN
		RETURN;
	END_IF
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), T);
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, T);

	T2F_AddString := TRUE;

END_FUNCTION
