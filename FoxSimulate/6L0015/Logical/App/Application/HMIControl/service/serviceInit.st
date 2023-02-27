PROGRAM _INIT
	g_OperatorCommand.NewFoldProgram := g_Machine.Program;

	LogHandle.DeviceName := 'Log';
	LogHandle.FileName := 'ProcStat.csv';
	LogRecLen := SIZEOF(LogRecord[0]);
	LogHandle.DoSave := FALSE;
	LogHandle.LogPointer := 0;
	LogHandle.SaveFileState := 0;

	ServiceOutletCommand.LateralFoldBladeTime := 480;

END_PROGRAM