	PROGRAM _INIT
	g_HCfg;
	
	g_Core.Services.Hardware.Runtime.initState 	:= INIT;
	SaveBlock := g_Core.System.Configuration.isBlockSaveHCfg;	
	strcpy(ADR(NameStructure),g_Core.System.Configuration.adrHCfgVarName);
	p_Options;
	HwCfgInit_0.Enable := 1;
	HwCfgInit_0.pStructName := ADR(NameStructure);
	HwCfgInit_0.pRcpInfoStruct := ADR(HCfg.CfgExtInfo);
	HwCfgInit_0.LenRcpInfoStruct := SIZEOF(HCfg.CfgExtInfo);
	HwCfgInit_0.pFileNameArray := 0;
	HwCfgInit_0.SizeFileNameArray := SIZEOF(HCfg.FileList.FileNameArray);
	HwCfgInit_0.LinesFileNameArray := SIZEOF(HCfg.FileList.FileNameArray) / SIZEOF(HCfg.FileList.FileNameArray[0]);
	HwCfgInit_0.cfgWorkWithVar := 1;// 0 = Dynamic data, 1 = fixed size list 
	HwCfgInit_0.cfgCompressOn := 0;//Set to 0 during test. Later set to 1 
	HwCfgInit_0();
	
	IF (HwCfgInit_0.Status = 0) THEN
		HCfg.Ident 								   := HwCfgInit_0.Ident;
		g_Core.Services.Hardware.Runtime.ParIdent  := HwCfgInit_0.Ident; 
	ELSE
		HCfg.Ident := 0;
	END_IF
	
	IF (HwCfgInit_0.Status = 0) THEN
		HwParScroInit_0.Enable := 1;
		HwParScroInit_0.Ident := HwCfgInit_0.Ident;
		IF USE_PAR_FILES THEN
			HwParScroInit_0.pFileNameParLanguage := ADR('hcfgpar.csv');
		ELSE	
			HwParScroInit_0.pFileNameParLanguage := 0;									
		END_IF	
		HwParScroInit_0.pVarNameArray := ADR(HCfg.ParScroll.VarNameArray);
		HwParScroInit_0.SizeVarNameArray := SIZEOF(HCfg.ParScroll.VarNameArray);
		HwParScroInit_0.LinesVarNameArray := SIZEOF(HCfg.ParScroll.VarNameArray) / SIZEOF(HCfg.ParScroll.VarNameArray[0]);
		HwParScroInit_0.pParScrollArray := ADR(HCfg.ParScroll.ParScrollArray);
		HwParScroInit_0.pParValueArray := ADR(HCfg.ParScroll.ParValueArray);
		HwParScroInit_0.pActParValue := ADR(HCfg.ParScroll.ActParValue);
		HwParScroInit_0.pDevice := ADR(NAME_CFGPARDEVICE);
		HwParScroInit_0.SizeParScrollArray := SIZEOF(HCfg.ParScroll.ParScrollArray);
		HwParScroInit_0.SizeParValueArray := SIZEOF(HCfg.ParScroll.ParValueArray);
		HwParScroInit_0.SizeActParValue := SIZEOF(HCfg.ParScroll.ActParValue);
		HwParScroInit_0.LinesParScrollArray := SIZEOF(HCfg.ParScroll.ParScrollArray) / SIZEOF(HCfg.ParScroll.ParScrollArray[0]);
		HwParScroInit_0.AdrTimerVisibility := ADR(HCfgTimerVisibility);
		HwParScroInit_0.SizeTimerVisibility := SIZEOF(HCfgTimerVisibility) / SIZEOF(HCfgTimerVisibility[0]);
	
		HwParScroCyclic_0.Enable := 1;
		HwParScroCyclic_0.Ident := HwCfgInit_0.Ident;
		HwParScroCyclic_0.SelectRcpNumber := 1;
	
		HwCfgLoad_0.Enable := 1;
		HwCfgLoad_0.Ident := HwCfgInit_0.Ident;
		HwCfgLoad_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		HwCfgSave_0.Enable := 1;
		HwCfgSave_0.Ident := HwCfgInit_0.Ident;
		HwCfgSave_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		strcpy(ADR(HCfg.CfgName),ADR(NAME_CFGFILE));
		sHwCfg := HWCFG_PARSCROLL_INIT;
	END_IF
	
	HCfg.CfgExtInfo.MaxNumberOfFiles := 1;
	
	RcpPointInit_2.pPointerName := ADR('hcfg:p_Options');
	RcpPointInit_2.RcpInitIdent := HwCfgInit_0.Ident;
	RcpPointInit_2();
	
	strcpy(ADR(HCfg.StatusString),ADR('No Hardware File Loaded'));
	NewStatusString := 1;									// clear HCfg.StatusString after 5 seconds 
	HCfg.InitDone := 0;
	
	// Set Actual Language 
	HwParScroCyclic_0.ActLanguage := g_Core.Services.System.Runtime.file.Language;
	HwParScroCyclic_0.cmdLangSwitch := 1;
	
	//	get task class cycle time for permanent scrolling in parameters	
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	
	TimePermanentScroll := 500;
	CycleScroll := 5;
	
	// enable SYSInfo - used for reset HCfg.StatusString output 
	SYSInfo_0.enable 		:=	1;
	
	PageOptionEdit 			:= LookupPageID(PAGE_MACHINE_OPTION_140,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	TimerDescription.Enable := 0; 
END_PROGRAM