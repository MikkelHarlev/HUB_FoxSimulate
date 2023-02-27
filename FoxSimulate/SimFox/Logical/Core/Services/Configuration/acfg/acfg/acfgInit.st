(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: acfg
 * File: acfgInit.st
 * Author: flystes
 * Created: February 19, 2015
 ********************************************************************
 * Implementation of program acfg
 ********************************************************************)
PROGRAM _INIT
	//-------------------------------------------------- init program ----------------------------------------------------
	IF (g_Core.System.Configuration.adrACfgVarName = 0) THEN
		RETURN;
	END_IF

	g_ACfg;
	
	UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 3, 4, 45, 0, 42); //Show button on Machine Specifik page

	g_Core.Services.AutoProg.Runtime.initState 		:= INIT;
	g_Core.Services.AutoProg.Runtime.autoprogPointer 	:= 0; 	// Reset the pointer 
	// Change 'VariableNameUsed' constant in rcfg.var according to used recepie variable name.
	//strcpy(ADR(NameStructure),ADR('acfg:'));		// Start with Task name to handle also local variables
	//strcpy(ADR(NameFieldStructure),ADR('acfg:')); 	// Start with Task name to handle also local variables
	
	strcpy(ADR(NameStructure),g_Core.System.Configuration.adrACfgVarName);
	strcpy(ADR(NameFieldStructure),g_Core.System.Configuration.adrACfgVarName);
	strcat(ADR(NameFieldStructure),ADR('.'));
	strcat(ADR(NameFieldStructure),g_Core.System.Configuration.adrACfgNameVarName);
	
	ElementsInArray := g_Core.System.Configuration.arrSizeACfg - 1;
	RcpInit_0.Enable := 1;
	RcpInit_0.pStructName := ADR(NameStructure);
	RcpInit_0.pRcpInfoStruct := ADR(ACfg.CfgExtInfo);
	RcpInit_0.LenRcpInfoStruct := SIZEOF(ACfg.CfgExtInfo);
	RcpInit_0.pFileNameArray := ADR(ACfg.FileList.FileNameArray);
	RcpInit_0.SizeFileNameArray := SIZEOF(ACfg.FileList.FileNameArray);
	RcpInit_0.LinesFileNameArray := SIZEOF(ACfg.FileList.FileNameArray) / SIZEOF(ACfg.FileList.FileNameArray[0]);
	RcpInit_0.cfgWorkWithVar := 1;
	RcpInit_0.NumbersLang := 40;//Add this when new jercp library is working.
	RcpInit_0();
	
	IF (RcpInit_0.Status = 0) THEN
		ACfg.Ident 								 := RcpInit_0.Ident;
		g_Core.Services.AutoProg.Runtime.ParIdent  := RcpInit_0.Ident;
	ELSE
		ACfg.Ident := 0;
	END_IF
	
	IF (RcpInit_0.Status = 0) THEN
		ParScroInit_0.Enable := 1;
		ParScroInit_0.Ident := RcpInit_0.Ident;
		IF USE_PAR_FILES THEN
			ParScroInit_0.pFileNameParLanguage := ADR('acfgpar.csv');
		ELSE	
			ParScroInit_0.pFileNameParLanguage := 0;						
		END_IF
		ParScroInit_0.pVarNameArray := ADR(ACfg.ParScroll.VarNameArray);
		ParScroInit_0.SizeVarNameArray := SIZEOF(ACfg.ParScroll.VarNameArray);
		ParScroInit_0.LinesVarNameArray := SIZEOF(ACfg.ParScroll.VarNameArray) / SIZEOF(ACfg.ParScroll.VarNameArray[0]);
		
		ParScroInit_0.pParScrollArray := ADR(ACfg.ParScroll.ParScrollArray);
		ParScroInit_0.pParValueArray := ADR(ACfg.ParScroll.ParValueArray);
		ParScroInit_0.pActParValue	:= ADR(ACfg.ParScroll.ActParValue);
		ParScroInit_0.pDevice := ADR('cfgpar');
		ParScroInit_0.SizeParScrollArray := SIZEOF(ACfg.ParScroll.ParScrollArray);
		ParScroInit_0.SizeParValueArray := SIZEOF(ACfg.ParScroll.ParValueArray);
		ParScroInit_0.LinesParScrollArray := SIZEOF(ACfg.ParScroll.ParScrollArray) / SIZEOF(ACfg.ParScroll.ParScrollArray[0]);
		ParScroInit_0.SizeActParValue := SIZEOF(ACfg.ParScroll.ActParValue);
		ParScroInit_0.pParNameString := ADR(NameFieldStructure);
		ParScroInit_0.pParNameArray := ADR(ACfg.ParScroll.ParNameArray);
		ParScroInit_0.SizeParNameArray := SIZEOF(ACfg.ParScroll.ParNameArray);
		ParScroInit_0.LinesParNameArray := SIZEOF(ACfg.ParScroll.ParNameArray) / SIZEOF(ACfg.ParScroll.ParNameArray[0]);
		ParScroInit_0.AdrTimerVisibility := ADR(ACfgTimerVisibility);
		ParScroInit_0.SizeTimerVisibility := SIZEOF(ACfgTimerVisibility) / SIZEOF(ACfgTimerVisibility[0]);
	
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
		RcpGetNames_0.pRcpNameArray := ADR(ACfg.NameList.RcpNameArray);
		RcpGetNames_0.SizeRcpNameArray := SIZEOF(ACfg.NameList.RcpNameArray);
		RcpGetNames_0.LinesRcpNameArray := SIZEOF(ACfg.NameList.RcpNameArray) / SIZEOF(ACfg.NameList.RcpNameArray[0]);
	
		sAutoProg := AUTOPROG_PARSCROLL_INIT;
	END_IF
	
	strcpy(ADR(ACfg.StatusString),ADR('No Recipe Loaded'));
	NewStatusString:= 1;									// clear ACfg.StatusString after 5 seconds 
	ACfg.CfgExtInfo.MaxNumberOfFiles := 5;
	ACfg.InitDone := 0;
	
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
	
	// enable SYSInfo - used for reset ACfg.StatusString output 
	SYSInfo_0.enable := 1;
	
	ACfg.CfgCopy.CfgSourceNumber	:= 1;
	ACfg.CfgCopy.CfgDestBegin := 1;
	ACfg.CfgCopy.CfgDestEnd := 1;
	
	PageAutoProgSelect := LookupPageID(PAGE_MACHINE_AUTOPROGSEL_106,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageAutoProgEdit := LookupPageID(PAGE_MACHINE_AUTOPROG_EDIT_105,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	// Set Hmi
	// Move to cyclic???
	HmiAuto := NOT g_Core.Services.AutoProg.Interface.isAutoRecipe;
	cmdAsk := TRUE;
	TimerDescription.Enable := 0; 
	cmdReadRecipeNames 		:= TRUE;
END_PROGRAM