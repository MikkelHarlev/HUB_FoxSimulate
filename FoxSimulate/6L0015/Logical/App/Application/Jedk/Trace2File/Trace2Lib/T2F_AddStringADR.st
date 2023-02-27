
(* TODO: Add your comment here *)
FUNCTION T2F_AddStringADR
	IF DA = 0 THEN
		RETURN;
	END_IF
	Data ACCESS DA;
	IF Data.init = FALSE THEN
		RETURN;
	END_IF
	notused := strcat(ADR(Data.FiFo[Data.FiFo_In].Text), T);

	T2F_AddStringADR := TRUE;

END_FUNCTION
