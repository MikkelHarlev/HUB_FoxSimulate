
(* Gets date as string *)
FUNCTION getDateString
	
    // Make Date string:
	DTGetTime_0(enable := TRUE);
	date := DTGetTime_0.DT1;
	DT_TO_DTStructure(date, ADR(DTstructure_0)); 
	brsitoa(DTstructure_0.year, ADR(tmpStr)); 
	brsstrcpy(ADR(dateStr), ADR(tmpStr));
	brsstrcat(ADR(dateStr), ADR('/'));
	brsitoa(DTstructure_0.month, ADR(tmpStr));
	IF DTstructure_0.month < 10 THEN
		brsstrcat(ADR(dateStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateStr), ADR(tmpStr));
	brsstrcat(ADR(dateStr), ADR('/'));
	brsitoa(DTstructure_0.day, ADR(tmpStr)); 
	IF DTstructure_0.day < 10 THEN
		brsstrcat(ADR(dateStr), ADR('0'));
	END_IF

	brsstrcat(ADR(dateStr), ADR(tmpStr));
	
	getDateString := TRUE;
	
END_FUNCTION
