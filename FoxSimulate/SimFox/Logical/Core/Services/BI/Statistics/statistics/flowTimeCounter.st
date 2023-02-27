FUNCTION_BLOCK flowTimeCounter
	IF NOT initDone THEN
		IF adrMillicounter > 0 THEN
			pMilliCounter ACCESS adrMillicounter;
			initDone :=TRUE;
		END_IF
	ELSE
		IF reset THEN
			timer := 0;
			oldtime := pMilliCounter;
			reset := FALSE;
		END_IF
		IF set <> oldset THEN
			oldset := set;
			IF set THEN
				oldtime := pMilliCounter;
			END_IF
		END_IF
		IF set THEN
			timer := timer + pMilliCounter - oldtime;
			oldtime := pMilliCounter;
		END_IF
	END_IF
END_FUNCTION_BLOCK
