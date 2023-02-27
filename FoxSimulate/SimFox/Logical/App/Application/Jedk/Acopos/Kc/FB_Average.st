FUNCTION_BLOCK FB_Average
	
	IF reset THEN
		reset := FALSE;
		FOR i := 0 TO 10 DO
			tempMs[i] := 0;
		END_FOR
		averageOut := FALSE;
		nb := 0;
	END_IF
		
	IF countIn THEN
		memmove(ADR(tempMs[1]),ADR(tempMs[0]),(SIZEOF(tempMs)-SIZEOF(tempMs[0])));
		tempMs[0] := milliSeconds;
		FOR i := 10 TO 1 BY -1 DO
			IF tempMs[i] > 0 THEN
				nb := i;
				EXIT;
			END_IF
		END_FOR
	END_IF

	IF countIn OR (milliSeconds > (tempMs[0] + 10000)) THEN
		countIn := FALSE;
		IF (nb > 0) THEN
			avgTime := UDINT_TO_REAL((milliSeconds - tempMs[nb]) / nb) - 6;
			IF avgTime < 59999 THEN
				averageOut := REAL_TO_UINT((60000 / avgTime) * 60); 
			ELSE
				FOR i := 0 TO 10 DO
					tempMs[i] := 0;
				END_FOR
				averageOut := 0;
				nb := 0;	
			END_IF
		END_IF
	END_IF	

END_FUNCTION_BLOCK