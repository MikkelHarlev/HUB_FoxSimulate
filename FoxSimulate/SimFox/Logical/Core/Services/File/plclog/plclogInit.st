PROGRAM _INIT
	MaxRead:= SIZEOF(LogbookInfo) / SIZEOF(Plclog.DetailInfo);
	
	Plclog.cmdLogRead:= 1;
	// CR+LF
	CSV_DELIMITER[0] := 13; 
	CSV_DELIMITER[1] := 10; 
	CSV_DELIMITER[2] := 0; 
	LogHandle.DeviceName 				:= 'log';
	LogHandle.FileName 					:= 'ProcStat.csv';
	//LogRecLen							:= SIZEOF(LogRecord[0]);
	LogHandle.DoSave 					:= FALSE;
	LogHandle.LogPointer 				:= 0;
	LogHandle.SaveFileState				:= 0;
	PageLogBook := LookupPageID(PAGE_LOGBOOK_220,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
END_PROGRAM

