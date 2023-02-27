PROGRAM _INIT
	g_MCfg;
	g_Core.Services.Machine.Interface.ptrConfig :=  0;
	
	MaCfgInit_0.Enable := 1;		
	strcpy(ADR(NameStructure), g_Core.System.Configuration.adrMCfgVarName);
	
	MaCfgInit_0.pStructName := ADR(NameStructure);
	MaCfgInit_0.pRcpInfoStruct := ADR(MCfg.CfgExtInfo);
	MaCfgInit_0.LenRcpInfoStruct := SIZEOF(MCfg.CfgExtInfo);
	MaCfgInit_0.pFileNameArray := 0;
	MaCfgInit_0.SizeFileNameArray := SIZEOF(MCfg.FileList.FileNameArray);
	MaCfgInit_0.LinesFileNameArray := SIZEOF(MCfg.FileList.FileNameArray) / SIZEOF(MCfg.FileList.FileNameArray[0]);
	MaCfgInit_0.cfgWorkWithVar := 1;// 0 = Dynamic data, 1 = fixed size list
	MaCfgInit_0.NumbersLang := 40;
	MaCfgInit_0();
	
	IF (MaCfgInit_0.Status = 0) THEN
		g_Core.Services.Machine.Runtime.ParIdent := MaCfgInit_0.Ident;
		MCfg.Ident 								  := MaCfgInit_0.Ident;
	ELSE
		MCfg.Ident := 0;
	END_IF
	
	IF (MaCfgInit_0.Status = 0) THEN
		MachParScroInit_0.Enable := 1;
		MachParScroInit_0.Ident := MaCfgInit_0.Ident;
		IF USE_PAR_FILES THEN
			MachParScroInit_0.pFileNameParLanguage := ADR(NAME_CFGPARFILENAME);
		ELSE	
			MachParScroInit_0.pFileNameParLanguage := 0;						
		END_IF	
		MachParScroInit_0.pVarNameArray := ADR(MCfg.ParScroll.VarNameArray);
		MachParScroInit_0.SizeVarNameArray := SIZEOF(MCfg.ParScroll.VarNameArray);
		MachParScroInit_0.LinesVarNameArray := SIZEOF(MCfg.ParScroll.VarNameArray) / SIZEOF(MCfg.ParScroll.VarNameArray[0]);
		
		MachParScroInit_0.pParScrollArray := ADR(MCfg.ParScroll.ParScrollArray);
		MachParScroInit_0.pParValueArray := ADR(MCfg.ParScroll.ParValueArray);
		MachParScroInit_0.pActParValue := ADR(MCfg.ParScroll.ActParValue);
		MachParScroInit_0.pDevice := ADR(NAME_CFGPARDEVICE);
		MachParScroInit_0.SizeParScrollArray := SIZEOF(MCfg.ParScroll.ParScrollArray);
		MachParScroInit_0.SizeParValueArray := SIZEOF(MCfg.ParScroll.ParValueArray);
		MachParScroInit_0.SizeActParValue := SIZEOF(MCfg.ParScroll.ActParValue);
		MachParScroInit_0.LinesParScrollArray := SIZEOF(MCfg.ParScroll.ParScrollArray) / SIZEOF(MCfg.ParScroll.ParScrollArray[0]);
		MachParScroInit_0.AdrTimerVisibility := ADR(MCfgTimerVisibility);
		MachParScroInit_0.SizeTimerVisibility := SIZEOF(MCfgTimerVisibility) / SIZEOF(MCfgTimerVisibility[0]);
	
		RcpPointInit_1.pPointerName := ADR('mcfg:p_Config');
		RcpPointInit_1.RcpInitIdent := MaCfgInit_0.Ident;
		RcpPointInit_1();
		
		MachParScroCyclic_0.Enable := 1;
		MachParScroCyclic_0.Ident := MaCfgInit_0.Ident;
		MachParScroCyclic_0.SelectRcpNumber := 1;
	
		MaCfgLoad_0.Enable := 1;
		MaCfgLoad_0.Ident := MaCfgInit_0.Ident;
		MaCfgLoad_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		MaCfgSave_0.Enable := 1;
		MaCfgSave_0.Ident := MaCfgInit_0.Ident;
		MaCfgSave_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		strcpy(ADR(MCfg.CfgName),ADR(NAME_CFGFILE));
		sMaCfg := MACFG_PARSCROLL_INIT;
	END_IF
	
	MCfg.CfgExtInfo.MaxNumberOfFiles := 1;
	
	strcpy(ADR(MCfg.StatusString),ADR('No Config File Loaded'));
	NewStatusString := 1;									// clear MCfg.StatusString after 5 seconds 
	MCfg.InitDone := 0;
	
	// Set Actual Language 
	MachParScroCyclic_0.ActLanguage := g_Core.Services.System.Runtime.file.Language;
	MachParScroCyclic_0.cmdLangSwitch := 1;
	
	// Get task class cycle time for permanent scrolling in parameters 
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	TimePermanentScroll := 500;
	CycleScroll := 5;
	
	// enable SYSInfo - used for reset MCfg.StatusString output 
	SYSInfo_0.enable := 1;
	
	g_Core.Services.Machine.Runtime.initState := INIT;
	PageMachineConfigEdit := LookupPageID(PAGE_MACHINE_CONFIG_120,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	TimerDescription.Enable := 0; 
END_PROGRAM