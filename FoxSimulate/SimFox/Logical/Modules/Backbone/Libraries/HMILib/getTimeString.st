
(* Gets date/time as string. TRUE on success, FALSE of error. Date/time string as pointer. *)
FUNCTION getTimeString
	
	// Make DateAndTime string:
	DTGetTime_0(enable := TRUE);
	dateAndTime := DTGetTime_0.DT1;
	DT_TO_DTStructure(dateAndTime, ADR(DTstructure_0)); 
	brsitoa(DTstructure_0.year, ADR(tmpStr)); 
	brsstrcpy(ADR(dateAndTimeStr), ADR(tmpStr));
	brsstrcat(ADR(dateAndTimeStr), ADR('/'));
	brsitoa(DTstructure_0.month, ADR(tmpStr));
	IF DTstructure_0.month < 10 THEN
		brsstrcat(ADR(dateAndTimeStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateAndTimeStr), ADR(tmpStr));
	brsstrcat(ADR(dateAndTimeStr), ADR('/'));
	brsitoa(DTstructure_0.day, ADR(tmpStr)); 
	IF DTstructure_0.day < 10 THEN
		brsstrcat(ADR(dateAndTimeStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateAndTimeStr), ADR(tmpStr));
	brsstrcat(ADR(dateAndTimeStr), ADR('  '));
	brsitoa(DTstructure_0.hour, ADR(tmpStr));
	IF DTstructure_0.hour < 10 THEN
		brsstrcat(ADR(dateAndTimeStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateAndTimeStr), ADR(tmpStr));
	brsstrcat(ADR(dateAndTimeStr), ADR(':'));
	brsitoa(DTstructure_0.minute, ADR(tmpStr)); 
	IF DTstructure_0.minute < 10 THEN
		brsstrcat(ADR(dateAndTimeStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateAndTimeStr), ADR(tmpStr));
	brsstrcat(ADR(dateAndTimeStr), ADR(':'));
	brsitoa(DTstructure_0.second, ADR(tmpStr));
	IF DTstructure_0.second < 10 THEN
		brsstrcat(ADR(dateAndTimeStr), ADR('0'));
	END_IF
	brsstrcat(ADR(dateAndTimeStr), ADR(tmpStr));
	
	getTimeString := TRUE;
	
END_FUNCTION
