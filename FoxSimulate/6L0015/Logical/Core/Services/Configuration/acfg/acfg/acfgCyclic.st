
(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: acfg
 * File: acfgCyclic.st
 * Author: flystes
 * Created: February 19, 2015
 ********************************************************************
 * Implementation of program acfg
 ********************************************************************)

PROGRAM _CYCLIC
	IF (g_Core.System.Configuration.adrACfgVarName = 0) THEN
		RETURN;
	END_IF
	g_AutoProgram.OperatorAutoProgram;
	g_Core.Services.AutoProg.Runtime.HMIShow  := g_Core.System.Runtime.isCustomerEnabled;
	TimerDescription.Enable					:= g_Core.System.Configuration.isTimerDescriptionEnabled;
	
	// Refresh values
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) THEN
		ParScroCyclic_0(Enable := TRUE, cmdInit := 1);
	END_IF

	// Show error layer when file error 
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) OR
		(g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageAutoProgSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageAutoProgEdit) THEN
		IF ((ACfg.CfgExtInfo.ErrStringInfo > '') OR (ACfg.CfgExtInfo.ErrStringDetail > '')) THEN		// If error information 
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= ACfg.CfgExtInfo.ErrStringInfo;
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := ACfg.CfgExtInfo.ErrStringDetail;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 0, 5, 69, 'File error created.'); 
		ELSE																						// No error information 
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= FALSE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= '';
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := '';
		END_IF
	END_IF
	
	// Wait for previous loaded Files 
	IF (RcpInit_0.Status <> 0) THEN
		RETURN;
	END_IF
	
	// ShowLevel changed..? 
	IF RShowLevelOld <> g_Core.System.Runtime.showLevel THEN
		RShowLevelOld := ParScroCyclic_0.ShowLevel := g_Core.System.Runtime.showLevel;	
		RTrigFunctions := 1;
	END_IF
	
	// Search triggered..? 
	IF (ParScroCyclic_0.cmdSearch = 1) THEN
		RTrigFunctions := (ParScroCyclic_0.SearchVariable <> '');
	END_IF
	
	IF RcpNameList_0.cmdScrollUp > 0 OR RcpNameList_0.cmdScrollDown > 0 THEN
		RTrigFunctions := 1;
	END_IF
	

	IF g_Core.Services.AutoProg.Interface.isCmdSave THEN
		g_Core.Services.AutoProg.Interface.isCmdSave := FALSE;
		ACfg.cmdSaveCfg := 1;
	END_IF
	
	IF g_Core.Services.AutoProg.Interface.isCmdLoad THEN
		g_Core.Services.AutoProg.Interface.isCmdLoad := FALSE;
		g_Core.Services.AutoProg.Interface.externalCmdKey := RECIPE_KEY_LOAD_1;
	END_IF
	
	IF g_Core.Services.AutoProg.Interface.isCmdLoadFactorySettings THEN
		g_Core.Services.AutoProg.Interface.isCmdLoadFactorySettings := FALSE;
		g_Core.Services.AutoProg.Interface.externalCmdKey := RECIPE_KEY_LOAD_FACTORY;
	END_IF
	
	IF ACfg.ParScroll.SelectRcpNumber > 0 THEN
		IF (g_Core.Services.AutoProg.Interface.isCmdSaveFactorySettings = 1 ) THEN
			ACfg.cmdSaveCfg := 9;
		END_IF
		g_Core.Services.AutoProg.Interface.isCmdSaveFactorySettings := 0;// always reset this value
	END_IF
	
	TriggScrollDown.CLK := USINT_TO_BOOL(ACfg.ParScroll.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(ACfg.ParScroll.cmdScrollUp);
	TriggScrollDown();
	TriggScrollUp();
	
	IF cmdCopyTimerToAllRcp OR cmdCancel OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageAutoProgEdit) THEN
		cmdCancel := FALSE;
		cmdAsk := TRUE;
	END_IF 	
	
	//g_Core.Services.CAR.Interface.No[0].RecipeNumber := LIMIT(1,g_Core.Services.CAR.Interface.No[0].RecipeNumber,99);
	
	CASE sAutoProg OF
		AUTOPROG_PARSCROLL_INIT:
			ParScroInit_0();
			IF (ParScroInit_0.Status <> 65535) THEN
				IF (ParScroInit_0.Status = 0) THEN
					sAutoProg := AUTOPROG_DIRLIST_INIT;
				ELSE
					sAutoProg := AUTOPROG_ERROR;
				END_IF
			END_IF
	
		AUTOPROG_DIRLIST_INIT:
			RcpDirList_0();
			IF (RcpDirList_0.Status <> 65535) AND (g_Core.Services.System.Runtime.isSystemFileValid) THEN
				IF (RcpDirList_0.Status = 0) THEN
					RcpFileListScroll_0.Enable := 1;
					IF (strlen(ADR(g_Core.Services.System.Runtime.file.LastLoadedAutoProg)) <> 0) THEN
						strcpy(ADR(ACfg.CfgName),ADR(g_Core.Services.System.Runtime.file.LastLoadedAutoProg));
						sAutoProg := AUTOPROG_LOAD;
					ELSE
						strcpy(ADR(ACfg.CfgName),ADR('acfg0.csv'));
						sAutoProg := AUTOPROG_LOAD;
					END_IF
				ELSE
					sAutoProg := AUTOPROG_ERROR;
				END_IF
			END_IF
	
		AUTOPROG_CHECK_FOR_COMMAND:
			
			IF (g_Core.Services.AutoProg.Interface.isCmdUpdatePar) THEN
				sAutoProg 										:= AUTOPROG_UPDATE_PAR;
			END_IF	
		
			IF (ACfg.cmdLoadCfg = 1) THEN
				ACfg.cmdLoadCfg := 0;
				g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sAutoProg := AUTOPROG_LOAD;
			ELSIF (ACfg.cmdSaveCfg = 1) THEN
				ACfg.cmdSaveCfg := 0;
				IF strcmp(ADR(g_Core.Services.System.Runtime.file.LastLoadedAutoProg),ADR('acfg1.csv')) = 0 THEN
					strcpy(ADR(ACfg.CfgName),ADR('acfg1.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sAutoProg := AUTOPROG_SAVE;
				ELSIF strcmp(ADR(g_Core.Services.System.Runtime.file.LastLoadedAutoProg),ADR('acfg2.csv')) = 0 THEN
					strcpy(ADR(ACfg.CfgName),ADR('acfg2.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sAutoProg := AUTOPROG_SAVE;
				ELSE
				// Alway save file to 1.csv if zero was selected 	
					strcpy(ADR(ACfg.CfgName),ADR('acfg1.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sAutoProg := AUTOPROG_SAVE;
				END_IF		
			ELSIF (ACfg.CfgCopy.cmdCopyCfg = 1) THEN
				RcpCopy_0.RcpSourceNumber := ACfg.CfgCopy.CfgSourceNumber;
				RcpCopy_0.RcpDestBegin := ACfg.CfgCopy.CfgDestBegin;
				RcpCopy_0.RcpDestEnd := ACfg.CfgCopy.CfgDestEnd;
				ACfg.CfgCopy.cmdCopyCfg := 0;
				sAutoProg  := AUTOPROG_COPY;
			ELSIF (ACfg.FileList.cmdDirList = 1) THEN
				ACfg.FileList.cmdDirList := 0;
				sAutoProg := AUTOPROG_DIR_LIST;
			ELSIF (ACfg.FileList.cmdUp = 1) THEN
				ACfg.FileList.cmdUp := 0;
				RcpFileListScroll_0.cmdUp := 1;
			ELSIF (ACfg.FileList.cmdDown = 1) THEN
				ACfg.FileList.cmdDown := 0;
				RcpFileListScroll_0.cmdDown := 1;
			ELSIF (ACfg.ParScroll.cmdScrollUp = 1) THEN
				IF (TriggScrollUp.Q = 1) THEN
					ParScroCyclic_0.cmdUp := 1;
					RTrigFunctions := 1;
				ELSIF (TriggScrollUp.CLK = 1) THEN
					TimeCounterUp := TimeCounterUp + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterUp > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						ParScroCyclic_0.cmdUp := 1;
						RTrigFunctions := 1;
						CycleCount := 0;
					END_IF
				END_IF
			ELSIF (ACfg.ParScroll.cmdScrollDown = 1) THEN
				IF (TriggScrollDown.Q = 1) THEN
					ParScroCyclic_0.cmdDown := 1;
					RTrigFunctions := 1;
				ELSIF (TriggScrollDown.CLK = 1) THEN
					TimeCounterDown := TimeCounterDown + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterDown > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						ParScroCyclic_0.cmdDown := 1;
						RTrigFunctions := 1;
						CycleCount := 0;
					END_IF
				END_IF
	
			ELSIF (ACfg.NameList.cmdScrollUp = 1) THEN
				IF RCycleCount > RTimeCounter THEN // Don't scroll each scan
					RcpNameList_0.cmdScrollUp := 1;
					RTimeCounter := RCycleCount + 15; 
				END_IF
			ELSIF (ACfg.NameList.cmdScrollDown = 1) THEN
				IF RCycleCount > RTimeCounter THEN // Don't scroll each scan
					RcpNameList_0.cmdScrollDown := 1;
					RTimeCounter := RCycleCount + 15; 
				END_IF

			ELSIF cmdCopyTimerToAllRcp THEN
				// Copy Singel Timer To All Recipe 
				cmdCopyTimerToAllRcp := FALSE;
				Value :=  ACfg.ParScroll.ActParValue;
				OrgRcp := ACfg.ParScroll.SelectRcpNumber;
				FOR i := 0 TO 98 DO
					ParScroCyclic_0.SelectRcpNumber := i + 1;
					ParScroCyclic_0.cmdRcpChange := 1;
					ParScroCyclic_0();
	
					ACfg.ParScroll.ActParValue := Value;
					ParScroCyclic_0.cmdEditPar := 1;
					ParScroCyclic_0();
				END_FOR
				ParScroCyclic_0.SelectRcpNumber := OrgRcp;
				ParScroCyclic_0.cmdRcpChange := 1;
				RTrigFunctions := 1;
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
		
			ELSIF cmdUpdateRcpOrg THEN
				// Update To Original Recipe 
				cmdUpdateRcpOrg := FALSE;
				ACfg.ParScroll.SelectRcpNumber := g_AutoProgram.OperatorAutoProgram;
//				ACfg.ParScroll.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
//				ParScroCyclic_0.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
//				ParScroCyclic_0.cmdRcpChange := 1;
//				RTrigFunctions := 1;
//		
//			ELSIF cmdUpdateRcpAuto THEN
//				// Update To Automatic Recipe 
//				cmdUpdateRcpAuto := FALSE;
//	
//				IF (g_Core.Services.AutoProg.Interface.AutoRecipe > 0) AND (g_Core.Services.AutoProg.Interface.AutoRecipe < 100) THEN
//					ACfg.ParScroll.SelectRcpNumber := g_Core.Services.AutoProg.Interface.AutoRecipe;
//					ParScroCyclic_0.SelectRcpNumber := g_Core.Services.AutoProg.Interface.AutoRecipe;
//					ParScroCyclic_0.cmdRcpChange := 1;
//					RTrigFunctions := 1;
//				END_IF
//	
			ELSIF (ACfg.NameList.cmdCfgNameSelect = 1) THEN
				ACfg.NameList.cmdCfgNameSelect := 0;
				ACfg.NameList.SelectedRcpNumber := RcpNameList_0.RcpNumber;
				g_AutoProgram.OperatorAutoProgram := UINT_TO_USINT(LIMIT(1,RcpNameList_0.RcpNumber,99));
	
			ELSIF (ACfg.NameList.cmdInit = 1) THEN
				ACfg.NameList.cmdInit := 0;
				RcpNameList_0.cmdInit := 1;
	
			ELSIF (ACfg.NameList.cmdGetNames = 1) THEN
				sAutoProg := AUTOPROG_GET_NAMES;
	
			ELSIF (g_Core.Services.AutoProg.Interface.externalCmdKey <> RECIPE_KEY_IDLE) THEN
				CASE g_Core.Services.AutoProg.Interface.externalCmdKey OF
					RECIPE_KEY_LOAD_FACTORY:
						strcpy(ADR(ACfg.CfgName),ADR('acfg0.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_LOAD;
					RECIPE_KEY_SAVE_FACTORY:
						strcpy(ADR(ACfg.CfgName),ADR('acfg0.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_SAVE;
					RECIPE_KEY_LOAD_1:
						strcpy(ADR(ACfg.CfgName),ADR('acfg1.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_LOAD;
					RECIPE_KEY_LOAD_2:
						strcpy(ADR(ACfg.CfgName),ADR('acfg2.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_LOAD;
					RECIPE_KEY_SAVE_1:
						strcpy(ADR(ACfg.CfgName),ADR('acfg1.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_SAVE;
					RECIPE_KEY_SAVE_2:
						strcpy(ADR(ACfg.CfgName),ADR('acfg2.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sAutoProg := AUTOPROG_SAVE;
				END_CASE
				g_Core.Services.AutoProg.Interface.externalCmdKey := RECIPE_KEY_IDLE;
			ELSE
				TimeCounterUp := 0;
				TimeCounterDown := 0;
			END_IF
			//	When Recipe Number changes then change also Recipe Number on Parameter Scroll Cyclic function	
			IF (ACfg.ParScroll.SelectRcpNumber <> OldRcpNo) THEN
				OldRcpNo := ACfg.ParScroll.SelectRcpNumber;
				ParScroCyclic_0.SelectRcpNumber := ACfg.ParScroll.SelectRcpNumber;
				ParScroCyclic_0.cmdRcpChange := 1;
			END_IF
			//	copy Recipe edit command	
			IF ACfg.ParScroll.cmdEditPar > 0 THEN
				ParScroCyclic_0.cmdEditPar := ACfg.ParScroll.cmdEditPar;
				ACfg.ParScroll.cmdEditPar := 0;
				RTrigFunctions := 1;
			END_IF
			//	copy recipe number change for edit 
			IF (ParScroCyclic_0.cmdRcpChange > 0) OR (ACfg.ParScroll.cmdParListRcpChange > 0) THEN
				ParScroCyclic_0.cmdRcpChange := ParScroCyclic_0.cmdRcpChange OR ACfg.ParScroll.cmdParListRcpChange;
				ACfg.ParScroll.cmdParListRcpChange := 0;
				RTrigFunctions := 1;
			END_IF
	
			// Only update functions when necessary
			IF RTrigFunctions THEN
				RTrigFunctions := 0;
				ParScroCyclic_0();
				RcpFileListScroll_0();
				RcpNameList_0();
			END_IF
	
		AUTOPROG_COPY:
			RcpCopy_0();
			IF (RcpCopy_0.Status = 0) THEN
				RcpCopy_0.RcpSourceNumber := 1;
				RcpCopy_0.RcpDestBegin := 1;
				RcpCopy_0.RcpDestEnd := 1;
				sAutoProg := AUTOPROG_CLEAR_ERROR_STRINGS;
				cmdReadRecipeNames := TRUE;
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			ELSE
				sAutoProg := AUTOPROG_ERROR;
			END_IF
	
		AUTOPROG_LOAD:
			RcpLoad_0.pFileName := ADR(ACfg.CfgName);
			sAutoProg := AUTOPROG_LOAD_WAIT;
			IF NOT RDontNotify THEN
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			END_IF
			RDontNotify := 0;
	
		AUTOPROG_LOAD_WAIT:
			RcpLoad_0();
			g_Core.Services.AutoProg.Runtime.initState := INIT;
			RInitDone := FALSE;
			IF (RcpLoad_0.Status <> 65535) THEN
				IF (RcpLoad_0.Status = 0) THEN
					strcpy(ADR(g_Core.Services.System.Runtime.file.LastLoadedAutoProg),ADR(ACfg.CfgName));
					strcpy(ADR(ACfg.StatusString),ADR('AutoProg File Loaded'));
					NewStatusString := 1;									// clear ACfg.StatusString after 5 seconds 
					ACfg.InitDone := 1;
					ParScroCyclic_0.cmdInit := 1;
					RcpNameList_0.cmdInit := 1;
					RTrigFunctions := 1;
					RInitDone := TRUE;
					g_Core.Services.AutoProg.Runtime.initState := RUNTIME;
					g_Core.Services.AutoProg.Runtime.loadCount := g_Core.Services.AutoProg.Runtime.loadCount + 1;
					sAutoProg := AUTOPROG_CLEAR_ERROR_STRINGS;
				ELSE
					sAutoProg := AUTOPROG_ERROR;
					ERRxwarning(sAutoProg, 9999, ADR('AutoProg file Error'));
					g_Core.Services.AutoProg.Runtime.initState := ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		AUTOPROG_SAVE:
			RcpSave_0.pFileName := ADR(ACfg.CfgName);
			sAutoProg := AUTOPROG_SAVE_WAIT;
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
		AUTOPROG_SAVE_WAIT:
			RcpSave_0();
			IF (RcpSave_0.Status <> 65535) THEN
				IF (RcpSave_0.Status = 0) OR (RcpSave_0.Status = 20708) THEN
					strcpy(ADR(ACfg.StatusString),ADR('AutoProg File Saved'));
					g_Core.Services.AutoProg.Runtime.saveCount := g_Core.Services.AutoProg.Runtime.saveCount + 1;
					NewStatusString := 1;									// clear ACfg.StatusString after 5 seconds 
					RcpNameList_0.cmdInit := 1;
					cmdReadRecipeNames := TRUE;
					g_Core.Services.System.Runtime.file.LastLoadedAutoProg := ACfg.CfgName;
					sAutoProg := AUTOPROG_CLEAR_ERROR_STRINGS;
				ELSE
					sAutoProg := AUTOPROG_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		AUTOPROG_DIR_LIST:
			RcpDirList_0();
			IF (RcpDirList_0.Status <> 65535) THEN
				IF (RcpDirList_0.Status = 0) THEN
					RcpFileListScroll_0.Enable := 1;
					RcpFileListScroll_0.cmdInit := 1;
					strcpy(ADR(ACfg.StatusString),ADR('AutoProg list updated'));
					NewStatusString := 1;									// clear ACfg.StatusString after 5 seconds 
					sAutoProg := AUTOPROG_CLEAR_ERROR_STRINGS;
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				ELSE
					sAutoProg := AUTOPROG_ERROR;
				END_IF
			END_IF
	
		AUTOPROG_GET_NAMES:
			RcpGetNames_0();
			IF (RcpGetNames_0.Status = 0) THEN
				ACfg.NameList.cmdGetNames := 0;
				sAutoProg := AUTOPROG_CLEAR_ERROR_STRINGS;
			ELSE
				ACfg.NameList.cmdGetNames := 0;
				sAutoProg := AUTOPROG_ERROR;
			END_IF
	
		AUTOPROG_ERROR:
			strcpy(ADR(tmpstr),ADR(ACfg.CfgExtInfo.ErrStringInfo));
			ErrStrLen := SIZEOF(ACfg.CfgExtInfo.ErrStringInfo);
			tmpstr[ErrStrLen-1] := 0;									// Terminate string since status string is shorter 
			strcpy(ADR(ACfg.StatusString),ADR(tmpstr));
			sAutoProg := AUTOPROG_CHECK_FOR_COMMAND;
	
		AUTOPROG_CLEAR_ERROR_STRINGS:
			strcpy(ADR(ACfg.CfgExtInfo.ErrStringInfo),ADR(''));
			strcpy(ADR(ACfg.CfgExtInfo.ErrStringDetail),ADR(''));
			ACfg.CfgExtInfo.Status := 0;
			sAutoProg := AUTOPROG_CHECK_FOR_COMMAND;
			
		AUTOPROG_UPDATE_PAR:
				ParScroInit_0();
				IF (ParScroInit_0.Status <> 65535) THEN
					IF (ParScroInit_0.Status = 0) THEN
						sAutoProg 										:= AUTOPROG_CHECK_FOR_COMMAND;
						g_Core.Services.AutoProg.Interface.isCmdUpdatePar := FALSE;
						ParScroCyclic_0.cmdInit 						:= 1;
						ParScroCyclic_0();
 					END_IF
				END_IF
	END_CASE;
	RCycleCount := RCycleCount +1;
	
	ACfg.ParScroll.SelectRcpNumber := LIMIT(1,ACfg.ParScroll.SelectRcpNumber,99);
	
//	// Allways updated with correct Rcp
//	IF (g_Core.Services.CAR.Runtime.No[0].RecipeNumber <> RcpNameList_0.RcpNumber) THEN
//		Rcp_Select := (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> 50) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> 51) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PAGE_ID_STAT_RCP) AND
//	 				  (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> 50) AND (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> 51) AND (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> PAGE_ID_STAT_RCP);
//	END_IF
	
	// Place Cursor Right in NameList after select 
//	IF (Rcp_Select = 1) OR RcpNameList_0.RcpNumber = 0 AND (RcpNameList_0.Status = 0) THEN
//		RcpNameList_0.cmdScrollUp := (g_Core.Services.CAR.Runtime.No[0].RecipeNumber < RcpNameList_0.RcpNumber);
//		RcpNameList_0.cmdScrollDown := (g_Core.Services.CAR.Runtime.No[0].RecipeNumber > RcpNameList_0.RcpNumber);
//	END_IF
	Rcp_Select := 0;
	g_Core.Services.AutoProg.Runtime.selectedRcpNo := UINT_TO_USINT(RcpNameList_0.RcpNumber);
	
	// Clear status string after 5 sec 
	IF ClearString = 0 THEN
		IF strlen(ADR(ACfg.StatusString)) > 0 THEN
			ClearString := 500;
		END_IF
	ELSE
		IF ClearString = 1 THEN
			ACfg.StatusString := '';
		END_IF
		ClearString := ClearString - 1;
	END_IF
	
	// Get pointer to Local recipe data 
	IF (g_Core.Services.AutoProg.Runtime.initState = RUNTIME) THEN		// Recipe file is loaded 
		IF g_Core.Services.AutoProg.Runtime.autoprogPointer = 0 THEN
			IF (g_Core.System.Configuration.adrACfgVarName > 0) THEN
				GetAdr(ADR(g_Core.Services.AutoProg.Runtime.autoprogPointer), g_Core.System.Configuration.adrACfgVarName);		
			// ELSE CONFIG ERROR!
			END_IF
		END_IF
	END_IF
	
	IF	cmdReadRecipeNames THEN
		cmdReadRecipeNames := FALSE;
		ACfg.NameList.cmdGetNames := TRUE;
	END_IF
	
	// Shift Actual Language 
	IF (LastLanguage <> g_Core.System.Runtime.Language) THEN
		ParScroCyclic_0.ActLanguage := UINT_TO_USINT(g_Core.System.Runtime.Language);
		ParScroCyclic_0.cmdLangSwitch := 1;
		ParScroCyclic_0.cmdInit := 1;
		RTrigFunctions := 1;
	END_IF
	LastLanguage := g_Core.System.Runtime.Language;
	
	// Updated to correct autoprogram
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) THEN
		ACfg.ParScroll.SelectRcpNumber := g_AutoProgram.OperatorAutoProgram;
	END_IF		

//	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_OPERATOR_MAIN OR 
//		g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PAGE_OPERATOR_MAIN) AND (ACfg.ParScroll.SelectRcpNumber <> LIMIT(1,g_Core.Services.CAR.Runtime.No[0].RecipeNumber,99)) THEN
//		ACfg.ParScroll.SelectRcpNumber := LIMIT(1,g_Core.Services.CAR.Runtime.No[0].RecipeNumber,99);
//		ACfg.ParScroll.cmdParListRcpChange := 1;
//	END_IF
	
	ACfg.FileList.SelectedItem := RcpFileListScroll_0.SelectedItem;
	ACfg.NameList.SelectedItem := RcpNameList_0.SelectedItem;
	ACfg.ParScroll.SelectedItem := ParScroCyclic_0.SelectedItem;
	
	SYSInfo_0();	// getting actual tick_count 
	
	CASE (NewStatusString) OF
		1:	NewStatusString_Time := SYSInfo_0.tick_count;		// store actual tick_count	
			NewStatusString := 2;								// next step				
	
		2:	IF ((NewStatusString_Time + 500) <= SYSInfo_0.tick_count) THEN	// wait 500*10ms = 5s	
				NewStatusString := 0;										// nothing to do		
				strcpy(ADR(ACfg.StatusString),ADR(''));						// clear output			
			END_IF
	END_CASE
	
	IF Completion_CfgDestBegin THEN
		Completion_CfgDestBegin := 0;
		IF ACfg.CfgCopy.CfgDestBegin > ACfg.CfgCopy.CfgDestEnd THEN
			ACfg.CfgCopy.CfgDestEnd := ACfg.CfgCopy.CfgDestBegin;
		END_IF
	END_IF
	
	IF Completion_CfgDestEnd THEN
		Completion_CfgDestEnd := 0;
		IF ACfg.CfgCopy.CfgDestBegin > ACfg.CfgCopy.CfgDestEnd THEN
			ACfg.CfgCopy.CfgDestEnd := ACfg.CfgCopy.CfgDestBegin;
		END_IF
	END_IF
	
	// Name For Recipe Screen
	// TODO GET DYNAMIC -DONE
	IF ACfg.ParScroll.SelectRcpNumber > 0 THEN
		RecipeName := ACfg.NameList.RcpNameArray[ACfg.ParScroll.SelectRcpNumber-1];
	ELSE
		RecipeName := ACfg.NameList.RcpNameArray[0];
	END_IF
	//--------------------------------------------------------------------------------------------------------------------
	// Extra Timer Explanation
	//--------------------------------------------------------------------------------------------------------------------
	
	IF TimerDescription.Enable AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) THEN
		FOR TimerDescription.Cnt := 0 TO 6 DO
			TimerDescription.No[TimerDescription.Cnt] := atoi(ADR(ACfg.ParScroll.ParScrollArray[TimerDescription.Cnt]));
		END_FOR
		TimerDescription.ActTimer := TimerDescription.No[ACfg.ParScroll.SelectedItem];
	ELSE
		TimerDescription.Hide := 1; 
	END_IF
	
	//--------------------------------------------------------------------------------------------------------------------
	// Search Timer number
	//--------------------------------------------------------------------------------------------------------------------
	
	IF g_Core.Services.AutoProg.Interface.isCmdSearch THEN
		g_Core.Services.AutoProg.Interface.isCmdSearch := FALSE;
	 	ParScroCyclic_0.SearchVariable := g_Core.Services.AutoProg.Interface.isCmdSearchTxt;
		ParScroCyclic_0.cmdSearch := TRUE;
	END_IF 	
	//--------------------------------------------------------------------------------------------------------------------
	// Timer Visibility
	//--------------------------------------------------------------------------------------------------------------------
	TON_VisiEnable(IN := (TON_VisiEnable.IN OR EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) OR EDGEPOS(RInitDone) OR RVariableEdited) AND (ACfg.ParScroll.cmdScrollUp = 0) AND (ACfg.ParScroll.cmdScrollDown = 0),PT :=T#250ms);
	IF TON_VisiEnable.Q AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageAutoProgEdit) THEN
		TON_VisiEnable.IN := RVariableEdited := 0;
		g_Core.Services.AutoProg.Runtime.UpdateShowLevelEnable := 1;
	END_IF
	
END_PROGRAM
