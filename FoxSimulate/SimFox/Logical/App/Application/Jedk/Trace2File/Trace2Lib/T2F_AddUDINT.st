
(* TODO: Add your comment here *)
FUNCTION T2F_AddUDINT
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA; 
	IF Data.init = FALSE THEN
		RETURN;
	END_IF
	itoa(UDINT_TO_DINT(V),ADR(Text));
	
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), N);
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(';'));
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(Text));
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(';'));
	
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, N);
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, ';');
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, Text);
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, ';');

	T2F_AddUDINT := TRUE;

END_FUNCTION
