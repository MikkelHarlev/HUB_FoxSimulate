PROGRAM _INIT
	RInit := 1;
	ISGuardOk := TRUE;
	FOR i := 1 TO MAX_NUMBER_OF_STACKERS DO
		ISFuseOk[i] := 1;
	END_FOR

	IFuseOkSideConv := 1;

	SimulStop := FALSE;
	SimulStart := FALSE;
	cmdLogBookFlag := -0;
	g_StatusIcon.Icon := 2;
	g_Machine.ResetAllAlarm := FALSE;
END_PROGRAM