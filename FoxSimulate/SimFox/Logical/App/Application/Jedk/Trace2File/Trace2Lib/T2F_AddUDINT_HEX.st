
(* TODO: Add your comment here *)
FUNCTION T2F_AddUDINT_HEX
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA; 
	IF Data.init = FALSE THEN
		RETURN;
	END_IF
	itox(UDINT_TO_USINT(V),ADR(Text));

	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), N);
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(';'));
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(Text));
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), ADR(';'));

	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, N);
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, ';');
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, Text);
	//Data.FiFo[Data.FiFo_In].Text := CONCAT(Data.FiFo[Data.FiFo_In].Text, ';');

	T2F_AddUDINT_HEX := TRUE;

END_FUNCTION
