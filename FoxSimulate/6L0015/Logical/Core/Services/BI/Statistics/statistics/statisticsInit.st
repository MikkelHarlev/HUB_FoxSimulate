PROGRAM _INIT

	hideDetailedView := 1;

	// Watchdog comparitor:
	memset(ADR(watchdogProductionComp),0,SIZEOF(watchdogProductionComp));
	ReadStatisticsDataObject := 1;
	Offset := 0;
	AsMemPartCreate_0(enable:=1, len:=1024000);
	LoadBuffer := AsMemPartCreate_0.ident;
	g_Core.Services.Statistics.Interface.DeleteStatsAfterNoDays := 365;
	fDevice	:= 'statistics';
	fDeviceCreator := '/DEVICE=F:\\statistics'; (*Used if filedevice is not configured*)
	fName	:= 'log.csv';
	fDir[0]	:='\Master\';
	fDir[1]	:='\Slave1\';
	fDir[2]	:='\Slave2\';
	fDir[3]	:='\Slave3\';
	fDir[4]	:='\Slave4\';
	(*Current filename*)
	Rename := TRUE;

	FlatVarHandler_0.VarName 	:= 'statistics:MasterLog';
	FlatVarHandler_0.pDevice 	:= ADR(fDevice);
	FlatVarHandler_0.pDeviceCreator := ADR(fDeviceCreator);
	FlatVarHandler_0.pDirectory 	:= ADR(fDir[0]);
	FlatVarHandler_0.pFile		:= ADR(fName);
	FlatVarHandler_0.Settings.SplitChar			:= ADR('\'); 	(*seperator tegn i dir&fil-navn*)
	FlatVarHandler_0.Settings.ColumnNameLevel 	:= 1;			(*0: Ingen label, 1:Label, 2:Label med varnavn prefix*)
															(*Header st?rrelse er automatisk beregnet ud fra headeren*)
	FlatVarHandler_0.Settings.HeaderIdent 		:= ADR('Jensen File Export V2.0b timeline edition;$R$L-----------------------------------;$R$L;$R$L;$R$L;$R$L;$R$L;$R$L;$R$L;$R$L');

	FlatVarHandler_0();
	FilenameTest := CurrentfName;

	Step := 0;

	FlatVar ACCESS FlatVarHandler_0.Ident;
	FOpen ACCESS FlatVar.FileHandler.FOpen;
	Buffer ACCESS FlatVar.FileHandler.ReadMemIdent;
	Offsetter := SIZEOF(BufferDataType);

	Scroll_0( DelayScroll := 450, DelayRepeat := 80, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
	Scroll_1( DelayScroll := 450, DelayRepeat := 80, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
	Scroll_DateUp( DelayScroll := 450, DelayRepeat := 80, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
	Scroll_DateDown( DelayScroll := 450, DelayRepeat := 80, pTimeReference := ADR( g_Core.Services.Time.Runtime.MilliSeconds ));
	(*Setup Vis parameters*)
	StatisticsMain.Vis.ScrollBoxDataPoint := 0;
	StatisticsMain.Vis.ScrollBoxMinIndex := 0;
	StatisticsMain.Vis.ScrollBoxMaxIndex := 7;
	StatisticsMain.Vis.ScrollBoxShow := 1;

	StatisticsMain.Vis.MainArticleText := '';
	StatisticsMain.Vis.MainSubArticleText := '';
	StatisticsMain.Vis.MainCustomerText := '';
	StatisticsMain.Vis.UnlockCustomerSelect := 1;
	StatisticsMain.Vis.UnlockArticleSelect := 1;
	StatisticsMain.Vis.UnlockBatchSelect := 1;

	StatisticsMain.Vis.DateBoxSelected := 2; (*Constant*)
	StatisticsMain.Vis.DateBoxShow := 1; (*Hide datebox*)

	StatisticsMain.Vis.DateBoxCmdToday := TRUE;
	FirstRun := TRUE;
	ready := 0; (*Ready for multitouch (swipe)? No not yet!*)
	UpdateRequestDate := TRUE;

	RInit := TRUE;
	SelectedRcpNo := 1;

	ResetInputDataPoint;
	ResetInput;
	DisplayServer := 0;
	MachineType := g_Core.System.Configuration.machineType;
	IF (MachineType = 0) THEN
		MachineType := 5; // Test 
	END_IF
	MachineType := MachineType * 100;
	StatisticsMain.Vis.ShowSetup := 1;

	ShiftLoadError := 0;
	ShiftsAvailable := 1;

END_PROGRAM
