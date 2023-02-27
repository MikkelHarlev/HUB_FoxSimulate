	PROGRAM _INIT
	//-------------------------------------------------- init program ----------------------------------------------------
	
	g_Core.Services.Recipe.Runtime.initState 		:= INIT;
	g_Core.Services.Recipe.Runtime.recipePointer 	:= 0; 	// Reset the pointer 
	
	g_RCfg;
	
	strcpy(ADR(NameStructure),g_Core.System.Configuration.adrRCfgVarName);
	strcpy(ADR(NameFieldStructure),g_Core.System.Configuration.adrRCfgVarName);
	strcat(ADR(NameFieldStructure),ADR('.'));
	strcat(ADR(NameFieldStructure),g_Core.System.Configuration.adrRCfgNameVarName);
	//EG - FUCK!
	ElementsInArray := g_Core.System.Configuration.arrSizeRCfg - 1;
	RcpInit_0.Enable := 1;
	RcpInit_0.pStructName := ADR(NameStructure);
	RcpInit_0.pRcpInfoStruct := ADR(RCfg.CfgExtInfo);
	RcpInit_0.LenRcpInfoStruct := SIZEOF(RCfg.CfgExtInfo);
	RcpInit_0.pFileNameArray := ADR(RCfg.FileList.FileNameArray);
	RcpInit_0.SizeFileNameArray := SIZEOF(RCfg.FileList.FileNameArray);
	RcpInit_0.LinesFileNameArray := SIZEOF(RCfg.FileList.FileNameArray) / SIZEOF(RCfg.FileList.FileNameArray[0]);
	RcpInit_0.cfgWorkWithVar := 1;
	RcpInit_0.NumbersLang := 40;//Add this when new jercp library is working.
	RcpInit_0();
	
	IF (RcpInit_0.Status = 0) THEN
		RCfg.Ident 								 := RcpInit_0.Ident;
		g_Core.Services.Recipe.Runtime.ParIdent  := RcpInit_0.Ident;
	ELSE
		RCfg.Ident := 0;
	END_IF
	
	IF (RcpInit_0.Status = 0) THEN
		ParScroInit_0.Enable := 1;
		ParScroInit_0.Ident := RcpInit_0.Ident;
		IF USE_PAR_FILES THEN
			ParScroInit_0.pFileNameParLanguage := ADR('rcfgpar.csv');
		ELSE	
			ParScroInit_0.pFileNameParLanguage := 0;						
		END_IF
		ParScroInit_0.pVarNameArray := ADR(RCfg.ParScroll.VarNameArray);
		ParScroInit_0.SizeVarNameArray := SIZEOF(RCfg.ParScroll.VarNameArray);
		ParScroInit_0.LinesVarNameArray := SIZEOF(RCfg.ParScroll.VarNameArray) / SIZEOF(RCfg.ParScroll.VarNameArray[0]);
		
		ParScroInit_0.pParScrollArray := ADR(RCfg.ParScroll.ParScrollArray);
		ParScroInit_0.pParValueArray := ADR(RCfg.ParScroll.ParValueArray);
		ParScroInit_0.pActParValue	:= ADR(RCfg.ParScroll.ActParValue);
		ParScroInit_0.pDevice := ADR('cfgpar');
		ParScroInit_0.SizeParScrollArray := SIZEOF(RCfg.ParScroll.ParScrollArray);
		ParScroInit_0.SizeParValueArray := SIZEOF(RCfg.ParScroll.ParValueArray);
		ParScroInit_0.LinesParScrollArray := SIZEOF(RCfg.ParScroll.ParScrollArray) / SIZEOF(RCfg.ParScroll.ParScrollArray[0]);
		ParScroInit_0.SizeActParValue := SIZEOF(RCfg.ParScroll.ActParValue);
		ParScroInit_0.pParNameString := ADR(NameFieldStructure);
		ParScroInit_0.pParNameArray := ADR(RCfg.ParScroll.ParNameArray);
		ParScroInit_0.SizeParNameArray := SIZEOF(RCfg.ParScroll.ParNameArray);
		ParScroInit_0.LinesParNameArray := SIZEOF(RCfg.ParScroll.ParNameArray) / SIZEOF(RCfg.ParScroll.ParNameArray[0]);
		ParScroInit_0.AdrTimerVisibility := ADR(RCfgTimerVisibility);
		ParScroInit_0.SizeTimerVisibility := SIZEOF(RCfgTimerVisibility) / SIZEOF(RCfgTimerVisibility[0]);
	
		RcpLoad_0.Enable := 1;
		RcpLoad_0.Ident := RcpInit_0.Ident;
		RcpLoad_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		RcpSave_0.Enable := 1;
		RcpSave_0.Ident := RcpInit_0.Ident;
		RcpSave_0.pDevice := ADR(NAME_CFG_DEVICE);
	
		ParScroCyclic_0.Enable := 1;
		ParScroCyclic_0.Ident := RcpInit_0.Ident;
		ParScroCyclic_0.SelectRcpNumber := 1;
	
		RcpCopy_0.Enable := 1;
		RcpCopy_0.Ident := RcpInit_0.Ident;
		RcpCopy_0.RcpSourceNumber := 1;
		RcpCopy_0.RcpDestBegin := 1;
		RcpCopy_0.RcpDestEnd := 1;
	
		RcpAdd_0.Enable := 1;
		RcpAdd_0.Ident := RcpInit_0.Ident;
	
		RcpDirList_0.Enable := 1;
		RcpDirList_0.pDevice := ADR(NAME_CFG_DEVICE);
		RcpDirList_0.Ident := RcpInit_0.Ident;
		RcpDirList_0.pFileExtFilter := ADR('.csv');
	
		RcpFileListScroll_0.Ident := RcpInit_0.Ident;
		RcpFileListScroll_0.cmdInit := 1;
	
		//	Function Block for Scrolling in the Recipe names	
		RcpNameList_0.Ident := RcpInit_0.Ident;
		RcpNameList_0.Enable := 1;
		RcpNameList_0.cmdInit := 1;
	
		RcpGetNames_0.Enable := 1;
		RcpGetNames_0.Ident := RcpInit_0.Ident;
		RcpGetNames_0.pRcpNameArray := ADR(RCfg.NameList.RcpNameArray);
		RcpGetNames_0.SizeRcpNameArray := SIZEOF(RCfg.NameList.RcpNameArray);
		RcpGetNames_0.LinesRcpNameArray := SIZEOF(RCfg.NameList.RcpNameArray) / SIZEOF(RCfg.NameList.RcpNameArray[0]);
	
		sRecipe := RECIPE_PARSCROLL_INIT;
	END_IF
	
	strcpy(ADR(RCfg.StatusString),ADR('No Recipe Loaded'));
	NewStatusString:= 1;									// clear RCfg.StatusString after 5 seconds 
	RCfg.CfgExtInfo.MaxNumberOfFiles := 5;
	RCfg.InitDone := 0;
	
	// Set Actual Language 
	ParScroCyclic_0.ActLanguage := g_Core.Services.System.Runtime.file.Language;
	ParScroCyclic_0.cmdLangSwitch := 1;
	
	//	get task class cycle time for permanent scrolling in parameters	
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	
	TimePermanentScroll := 500;
	CycleScroll := 5;
	
	// enable SYSInfo - used for reset RCfg.StatusString output 
	SYSInfo_0.enable := 1;
	
	RCfg.CfgCopy.CfgSourceNumber	:= 1;
	RCfg.CfgCopy.CfgDestBegin := 1;
	RCfg.CfgCopy.CfgDestEnd := 1;
	
	PageRecipieSelect := LookupPageID(PAGE_MACHINE_RECIPESEL_101,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageRecipeEdit := LookupPageID(PAGE_MACHINE_RECIPE_EDIT_100,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	// Set Hmi
	// Move to cyclic???
	HmiAuto := NOT g_Core.Services.Recipe.Interface.isAutoRecipe;
	cmdAsk := TRUE;
	TimerDescription.Enable := 0; 
	cmdReadRecipeNames 		:= TRUE;

END_PROGRAM