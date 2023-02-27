PROGRAM _CYCLIC
	
	// UTF8 TEST
	// CATCH RCfg.ParScroll.cmdEditPar and convert back!
	//u8_toucs(ADR(ActParValueWChar), SIZEOF(ActParValueWChar), ADR(RCfg.ParScroll.ActParValue), SIZEOF(RCfg.ParScroll.ActParValue));
	RCfg.ParScroll.ActParValue;
	ActParValueWChar;
	
	// Refresh values
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) THEN
		ParScroCyclic_0(Enable := TRUE, cmdInit := 1);
	END_IF
	
	g_Core.Services.Recipe.Runtime.HMIShow  := g_Core.System.Runtime.isCustomerEnabled;
	TimerDescription.Enable					:= g_Core.System.Configuration.isTimerDescriptionEnabled;
	// Show error layer when file error 
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipieSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) OR
		(g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageRecipieSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageRecipeEdit) THEN
		IF ((RCfg.CfgExtInfo.ErrStringInfo > '') OR (RCfg.CfgExtInfo.ErrStringDetail > '')) THEN		// If error information 
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= RCfg.CfgExtInfo.ErrStringInfo;
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := RCfg.CfgExtInfo.ErrStringDetail;
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
	
	// Search in Rcp list after first 3 letters
	IF g_Core.Services.Recipe.Interface.isCmdSearch THEN
		g_Core.Services.Recipe.Interface.isCmdSearch := FALSE;
		ParScroCyclic_0.SearchVariable := g_Core.Services.Recipe.Interface.isCmdSearchTxt;
		ParScroCyclic_0.cmdSearch := 1;
		
		// Jump to actual recipe
		IF RCfg.ParScroll.SelectRcpNumber <> g_Core.Services.CAR.Runtime.No[0].RecipeNumber THEN
			cmdUpdateRcpOrg := 1; 
		END_IF
		
	END_IF
	
	IF g_Core.Services.Recipe.Interface.isCmdSave THEN
		g_Core.Services.Recipe.Interface.isCmdSave := FALSE;
		RCfg.cmdSaveCfg := 1;
	END_IF
	
	IF g_Core.Services.Recipe.Interface.isCmdLoad THEN
		g_Core.Services.Recipe.Interface.isCmdLoad := FALSE;
		g_Core.Services.Recipe.Interface.externalCmdKey := RECIPE_KEY_LOAD_1;
	END_IF
	
	IF g_Core.Services.Recipe.Interface.isCmdLoadFactorySettings THEN
		g_Core.Services.Recipe.Interface.isCmdLoadFactorySettings := FALSE;
		g_Core.Services.Recipe.Interface.externalCmdKey := RECIPE_KEY_LOAD_FACTORY;
	END_IF
	
	IF RCfg.ParScroll.SelectRcpNumber > 0 THEN
		IF (g_Core.Services.Recipe.Interface.isCmdSaveFactorySettings = 1 ) THEN
			RCfg.cmdSaveCfg := 9;
		END_IF
		g_Core.Services.Recipe.Interface.isCmdSaveFactorySettings := 0;// always reset this value
	END_IF
	
	TriggScrollDown.CLK := USINT_TO_BOOL(RCfg.ParScroll.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(RCfg.ParScroll.cmdScrollUp);
	TriggScrollDown();
	TriggScrollUp();
	
	IF cmdCopyTimerToAllRcp OR cmdCancel OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageRecipeEdit) THEN
		cmdCancel := FALSE;
		cmdAsk := TRUE;
	END_IF 	
	
	g_Core.Services.CAR.Interface.No[0].RecipeNumber := LIMIT(1,g_Core.Services.CAR.Interface.No[0].RecipeNumber,99);
	
	CASE sRecipe OF
		RECIPE_PARSCROLL_INIT:
			ParScroInit_0();
			IF (ParScroInit_0.Status <> 65535) THEN
				IF (ParScroInit_0.Status = 0) THEN
					sRecipe := RECIPE_DIRLIST_INIT;
				ELSE
					sRecipe := RECIPE_ERROR;
				END_IF
			END_IF
	
		RECIPE_DIRLIST_INIT:
			RcpDirList_0();
			IF (RcpDirList_0.Status <> 65535) AND (g_Core.Services.System.Runtime.isSystemFileValid) THEN
				IF (RcpDirList_0.Status = 0) THEN
					RcpFileListScroll_0.Enable := 1;
					IF (strlen(ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe)) <> 0) THEN
						strcpy(ADR(RCfg.CfgName),ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe));
						sRecipe := RECIPE_LOAD;
					ELSE
						strcpy(ADR(RCfg.CfgName),ADR('0.csv'));
						sRecipe := RECIPE_LOAD;
					END_IF
				ELSE
					sRecipe := RECIPE_ERROR;
				END_IF
			END_IF
	
		RECIPE_CHECK_FOR_COMMAND:
			
			IF g_Core.Services.Recipe.Interface.isCmdUpdatePar THEN
				sRecipe := RECIPE_UPDATE_PAR;
			END_IF	
			IF g_Core.Services.Recipe.Interface.isCmdSearch THEN
				RCfgParScrollSelectedItem := 0;
				RCfgParScrollSelectedVariable := g_Core.Services.Recipe.Interface.isCmdSearchVariable;
				RCfg.ParScroll.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
				ParScroCyclic_0.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
				sRecipe := RECIPE_UPDATE_PAR_FINDPOS;
			END_IF
		
			IF (RCfg.cmdLoadCfg = 1) THEN
				RCfg.cmdLoadCfg := 0;
				g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sRecipe := RECIPE_LOAD;
			ELSIF (RCfg.cmdSaveCfg = 1) THEN
				RCfg.cmdSaveCfg := 0;
				IF strcmp(ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe),ADR('1.csv')) = 0 THEN
					strcpy(ADR(RCfg.CfgName),ADR('1.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sRecipe := RECIPE_SAVE;
				ELSIF strcmp(ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe),ADR('2.csv')) = 0 THEN
					strcpy(ADR(RCfg.CfgName),ADR('2.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sRecipe := RECIPE_SAVE;
				ELSE
				// Alway save file to 1.csv if zero was selected 	
					strcpy(ADR(RCfg.CfgName),ADR('1.csv'));
					g_Core.Services.System.Interface.isCmdSave := 1;
					sRecipe := RECIPE_SAVE;
				END_IF		
			ELSIF (RCfg.CfgCopy.cmdCopyCfg = 1) THEN
				RcpCopy_0.RcpSourceNumber := RCfg.CfgCopy.CfgSourceNumber;
				RcpCopy_0.RcpDestBegin := RCfg.CfgCopy.CfgDestBegin;
				RcpCopy_0.RcpDestEnd := RCfg.CfgCopy.CfgDestEnd;
				RCfg.CfgCopy.cmdCopyCfg := 0;
				sRecipe  := RECIPE_COPY;
			ELSIF (RCfg.FileList.cmdDirList = 1) THEN
				RCfg.FileList.cmdDirList := 0;
				sRecipe := RECIPE_DIR_LIST;
			ELSIF (RCfg.FileList.cmdUp = 1) THEN
				RCfg.FileList.cmdUp := 0;
				RcpFileListScroll_0.cmdUp := 1;
			ELSIF (RCfg.FileList.cmdDown = 1) THEN
				RCfg.FileList.cmdDown := 0;
				RcpFileListScroll_0.cmdDown := 1;
			ELSIF (RCfg.ParScroll.cmdScrollUp = 1) THEN
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
			ELSIF (RCfg.ParScroll.cmdScrollDown = 1) THEN
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
	
			ELSIF (RCfg.NameList.cmdScrollUp = 1) THEN
				IF RCycleCount > RTimeCounter THEN // Don't scroll each scan
					RcpNameList_0.cmdScrollUp := 1;
					RTimeCounter := RCycleCount + 15; 
				END_IF
			ELSIF (RCfg.NameList.cmdScrollDown = 1) THEN
				IF RCycleCount > RTimeCounter THEN // Don't scroll each scan
					RcpNameList_0.cmdScrollDown := 1;
					RTimeCounter := RCycleCount + 15; 
				END_IF

			ELSIF cmdCopyTimerToAllRcp THEN
				// Copy Singel Timer To All Recipe 
				cmdCopyTimerToAllRcp := FALSE;
				Value :=  RCfg.ParScroll.ActParValue;
				OrgRcp := RCfg.ParScroll.SelectRcpNumber;
			 	FOR i := 0 TO 98 DO
					ParScroCyclic_0.SelectRcpNumber := i + 1;
					ParScroCyclic_0.cmdRcpChange := 1;
					ParScroCyclic_0();
	
					RCfg.ParScroll.ActParValue := Value;
					ParScroCyclic_0.cmdEditPar := 1;
					ParScroCyclic_0();
				END_FOR
				ParScroCyclic_0.SelectRcpNumber := OrgRcp;
				ParScroCyclic_0.cmdRcpChange := 1;
				ParScroCyclic_0();
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				
			ELSIF cmdUpdateRcpOrg THEN
				// Update To Original Recipe 
				cmdUpdateRcpOrg := FALSE;
				RCfg.ParScroll.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
				ParScroCyclic_0.SelectRcpNumber := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
				ParScroCyclic_0.cmdRcpChange := 1;
				RTrigFunctions := 1;
		
			ELSIF cmdUpdateRcpAuto THEN
				// Update To Automatic Recipe 
				cmdUpdateRcpAuto := FALSE;
	
				IF (g_Core.Services.Recipe.Interface.AutoRecipe > 0) AND (g_Core.Services.Recipe.Interface.AutoRecipe < 100) THEN
					RCfg.ParScroll.SelectRcpNumber := g_Core.Services.Recipe.Interface.AutoRecipe;
					ParScroCyclic_0.SelectRcpNumber := g_Core.Services.Recipe.Interface.AutoRecipe;
					ParScroCyclic_0.cmdRcpChange := 1;
					RTrigFunctions := 1;
				END_IF
	
			ELSIF (RCfg.NameList.cmdCfgNameSelect = 1) THEN
				RCfg.NameList.cmdCfgNameSelect := 0;
				RCfg.NameList.SelectedRcpNumber := RcpNameList_0.RcpNumber;
				g_Core.Services.CAR.Interface.No[0].RecipeNumber := UINT_TO_USINT(LIMIT(1,RcpNameList_0.RcpNumber,99));
	
			ELSIF (RCfg.NameList.cmdInit = 1) THEN
				RCfg.NameList.cmdInit := 0;
				RcpNameList_0.cmdInit := 1;
	
			ELSIF (RCfg.NameList.cmdGetNames = 1) THEN
				sRecipe := RECIPE_GET_NAMES;
	
			ELSIF (g_Core.Services.Recipe.Interface.externalCmdKey <> RECIPE_KEY_IDLE) THEN
				CASE g_Core.Services.Recipe.Interface.externalCmdKey OF
					RECIPE_KEY_LOAD_FACTORY:
						strcpy(ADR(RCfg.CfgName),ADR('0.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_LOAD;
					RECIPE_KEY_SAVE_FACTORY:
						strcpy(ADR(RCfg.CfgName),ADR('0.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_SAVE;
					RECIPE_KEY_LOAD_1:
						strcpy(ADR(RCfg.CfgName),ADR('1.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_LOAD;
					RECIPE_KEY_LOAD_2:
						strcpy(ADR(RCfg.CfgName),ADR('2.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_LOAD;
					RECIPE_KEY_SAVE_1:
						strcpy(ADR(RCfg.CfgName),ADR('1.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_SAVE;
					RECIPE_KEY_SAVE_2:
						strcpy(ADR(RCfg.CfgName),ADR('2.csv'));
						g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
						g_Core.Services.System.Interface.isCmdSave := 1;
						sRecipe := RECIPE_SAVE;
				END_CASE
				g_Core.Services.Recipe.Interface.externalCmdKey := RECIPE_KEY_IDLE;
			ELSE
				TimeCounterUp := 0;
				TimeCounterDown := 0;
			END_IF
			//	When Recipe Number changes then change also Recipe Number on Parameter Scroll Cyclic function	
			IF (RCfg.ParScroll.SelectRcpNumber <> OldRcpNo) THEN
				OldRcpNo := RCfg.ParScroll.SelectRcpNumber;
				ParScroCyclic_0.SelectRcpNumber := RCfg.ParScroll.SelectRcpNumber;
				ParScroCyclic_0.cmdRcpChange := 1;
			END_IF
			//	copy Recipe edit command	
			IF RCfg.ParScroll.cmdEditPar > 0 THEN
				ParScroCyclic_0.cmdEditPar := RCfg.ParScroll.cmdEditPar;
				RCfg.ParScroll.cmdEditPar := 0;
				RTrigFunctions := 1;
			END_IF
			//	copy recipe number change for edit 
			IF RCfg.ParScroll.cmdEditPar = 1 THEN
				RVariableEdited := 1;
			END_IF
			ParScroCyclic_0.cmdEditPar := RCfg.ParScroll.cmdEditPar;
			RCfg.ParScroll.cmdEditPar := 0;
			(*	copy recipe number change for edit *)
			ParScroCyclic_0.cmdRcpChange := RCfg.ParScroll.cmdParListRcpChange;
			RCfg.ParScroll.cmdParListRcpChange := 0;
			ParScroCyclic_0();
			RcpFileListScroll_0();
			RcpNameList_0();
	
		RECIPE_COPY:
			RcpCopy_0();
			IF (RcpCopy_0.Status = 0) THEN
				RcpCopy_0.RcpSourceNumber := 1;
				RcpCopy_0.RcpDestBegin := 1;
				RcpCopy_0.RcpDestEnd := 1;
				sRecipe := RECIPE_CLEAR_ERROR_STRINGS;
				cmdReadRecipeNames := TRUE;
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_COPY_122, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			ELSE
				sRecipe := RECIPE_ERROR;
			END_IF
	
		RECIPE_LOAD:
			RcpLoad_0.pFileName := ADR(RCfg.CfgName);
			sRecipe := RECIPE_LOAD_WAIT;
			IF NOT RDontNotify THEN
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			END_IF
			RDontNotify := 0;
	
		RECIPE_LOAD_WAIT:
			RcpLoad_0();
			g_Core.Services.Recipe.Runtime.initState := INIT;
			RInitDone := FALSE;
			IF (RcpLoad_0.Status <> 65535) THEN
				IF (RcpLoad_0.Status = 0) THEN
					strcpy(ADR(g_Core.Services.System.Runtime.file.LastLoadedRecipe),ADR(RCfg.CfgName));
					strcpy(ADR(RCfg.StatusString),ADR('Recipe File Loaded'));
					NewStatusString := 1;									// clear RCfg.StatusString after 5 seconds 
					RCfg.InitDone := 1;
					ParScroCyclic_0.cmdInit := 1;
					RcpNameList_0.cmdInit := 1;
					RTrigFunctions := 1;
					RInitDone := TRUE;
					RCfg.NameList.cmdGetNames				 := TRUE;		// To trigger a update of the list in rcfg task....
					g_Core.Services.Recipe.Runtime.initState := RUNTIME;
					g_Core.Services.Recipe.Runtime.loadCount := g_Core.Services.Recipe.Runtime.loadCount + 1;
					sRecipe := RECIPE_CLEAR_ERROR_STRINGS;
				ELSE
					sRecipe := RECIPE_ERROR;
					ERRxwarning(sRecipe, 9999, ADR('Recipe file Error'));
					g_Core.Services.Recipe.Runtime.initState := ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		RECIPE_SAVE:
			RcpSave_0.pFileName := ADR(RCfg.CfgName);
			sRecipe := RECIPE_SAVE_WAIT;
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
		RECIPE_SAVE_WAIT:
			RcpSave_0();
			IF (RcpSave_0.Status <> 65535) THEN
				IF (RcpSave_0.Status = 0) OR (RcpSave_0.Status = 20708) THEN
					strcpy(ADR(RCfg.StatusString),ADR('Recipe File Saved'));
					g_Core.Services.Recipe.Runtime.saveCount := g_Core.Services.Recipe.Runtime.saveCount + 1;
					NewStatusString := 1;									// clear RCfg.StatusString after 5 seconds 
					RcpNameList_0.cmdInit := 1;
					g_Core.Services.System.Runtime.file.LastLoadedRecipe := RCfg.CfgName;
					sRecipe := RECIPE_CLEAR_ERROR_STRINGS;
				ELSE
					sRecipe := RECIPE_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		RECIPE_DIR_LIST:
			RcpDirList_0();
			IF (RcpDirList_0.Status <> 65535) THEN
				IF (RcpDirList_0.Status = 0) THEN
					RcpFileListScroll_0.Enable := 1;
					RcpFileListScroll_0.cmdInit := 1;
					strcpy(ADR(RCfg.StatusString),ADR('Recipe list updated'));
					NewStatusString := 1;									// clear RCfg.StatusString after 5 seconds 
					sRecipe := RECIPE_CLEAR_ERROR_STRINGS;
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
				ELSE
					sRecipe := RECIPE_ERROR;
				END_IF
			END_IF
	
		RECIPE_GET_NAMES:
			RcpGetNames_0();
			IF (RcpGetNames_0.Status = 0) THEN
				RCfg.NameList.cmdGetNames := 0;
				sRecipe := RECIPE_CLEAR_ERROR_STRINGS;
			ELSE
				RCfg.NameList.cmdGetNames := 0;
				sRecipe := RECIPE_ERROR;
			END_IF
	
		RECIPE_ERROR:
			strcpy(ADR(tmpstr),ADR(RCfg.CfgExtInfo.ErrStringInfo));
			ErrStrLen := SIZEOF(RCfg.CfgExtInfo.ErrStringInfo);
			tmpstr[ErrStrLen-1] := 0;									// Terminate string since status string is shorter 
			strcpy(ADR(RCfg.StatusString),ADR(tmpstr));
			sRecipe := RECIPE_CHECK_FOR_COMMAND;
	
		RECIPE_CLEAR_ERROR_STRINGS:
			strcpy(ADR(RCfg.CfgExtInfo.ErrStringInfo),ADR(''));
			strcpy(ADR(RCfg.CfgExtInfo.ErrStringDetail),ADR(''));
			RCfg.CfgExtInfo.Status := 0;
			sRecipe := RECIPE_CHECK_FOR_COMMAND;
			
		RECIPE_UPDATE_PAR:
			RCfgParScrollSelectedItem := RCfg.ParScroll.SelectedItem;
			RCfgParScrollSelectedVariable := RCfg.ParScroll.VarNameArray[RCfg.ParScroll.SelectedItem];

			ParScroInit_0();
			IF (ParScroInit_0.Status <> 65535) THEN
				IF (ParScroInit_0.Status = 0) THEN
					g_Core.Services.Recipe.Interface.isCmdUpdatePar := FALSE;
					sRecipe := RECIPE_UPDATE_PAR_FINDPOS;
				END_IF
			END_IF
		
		RECIPE_UPDATE_PAR_FINDPOS:
			g_Core.Services.Recipe.Interface.isCmdSearch := FALSE;
			ParScroCyclic_0.cmdSearchPlace := RCfgParScrollSelectedItem;
			ParScroCyclic_0.SearchVariable := RCfgParScrollSelectedVariable;
			ParScroCyclic_0.cmdSearch := 1;
			ParScroCyclic_0();
			IF (ParScroCyclic_0.cmdSearch = 10) THEN
				// Search found
			ELSIF (ParScroCyclic_0.cmdSearch = 20) THEN
				// Search not found, jump to first in list	
				ParScroCyclic_0.cmdJumpFirst := 1;
				ParScroCyclic_0();
			ELSE
				// Search error
				ParScroCyclic_0.cmdInit := 1;
				ParScroCyclic_0();
			END_IF
		
			FOR Cnt := 0 TO 6 DO
				IF RCfg.ParScroll.ParScrollArray[Cnt] = '' THEN
					RCfg.ParScroll.ParValueArray[Cnt] := '';
				END_IF
			END_FOR
			sRecipe := RECIPE_CHECK_FOR_COMMAND;
	END_CASE;
	RCycleCount := RCycleCount +1;
	
	RCfg.ParScroll.SelectRcpNumber := LIMIT(1,RCfg.ParScroll.SelectRcpNumber,99);
	
	// Allways updated with correct Rcp
	IF (g_Core.Services.CAR.Runtime.No[0].RecipeNumber <> RcpNameList_0.RcpNumber) THEN
		Rcp_Select := (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> 50) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> 51) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PAGE_ID_STAT_RCP) AND
	 				  (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> 50) AND (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> 51) AND (g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID <> PAGE_ID_STAT_RCP);
	END_IF
	
	// Place Cursor Right in NameList after select 
	IF (Rcp_Select = 1) OR RcpNameList_0.RcpNumber = 0 AND (RcpNameList_0.Status = 0) THEN
		RcpNameList_0.cmdScrollUp := (g_Core.Services.CAR.Runtime.No[0].RecipeNumber < RcpNameList_0.RcpNumber);
		RcpNameList_0.cmdScrollDown := (g_Core.Services.CAR.Runtime.No[0].RecipeNumber > RcpNameList_0.RcpNumber);
	END_IF
	Rcp_Select := 0;
	g_Core.Services.Recipe.Runtime.selectedRcpNo := UINT_TO_USINT(RcpNameList_0.RcpNumber);
	
	// Clear status string after 5 sec 
	IF ClearString = 0 THEN
		IF strlen(ADR(RCfg.StatusString)) > 0 THEN
			ClearString := 500;
		END_IF
	ELSE
		IF ClearString = 1 THEN
			RCfg.StatusString := '';
		END_IF
		ClearString := ClearString - 1;
	END_IF
	
	// Get pointer to Local recipe data 
	IF (g_Core.Services.Recipe.Runtime.initState = RUNTIME) THEN		// Recipe file is loaded 
		IF g_Core.Services.Recipe.Runtime.recipePointer = 0 THEN
			IF (g_Core.System.Configuration.adrRCfgVarName > 0) THEN
				GetAdr(ADR(g_Core.Services.Recipe.Runtime.recipePointer), g_Core.System.Configuration.adrRCfgVarName);		
			// ELSE CONFIG ERROR!
			END_IF
		END_IF
	END_IF
	
	IF g_Core.Services.Recipe.Interface.cmdReadRecipeNames THEN
		g_Core.Services.Recipe.Interface.cmdReadRecipeNames := FALSE;
		RCfg.NameList.cmdGetNames := TRUE;
	END_IF
	
	// Shift Actual Language 
	IF (LastLanguage <> g_Core.System.Runtime.Language) THEN
		ParScroCyclic_0.ActLanguage := UINT_TO_USINT(g_Core.System.Runtime.Language);
		ParScroCyclic_0.cmdLangSwitch := 1;
		ParScroCyclic_0.cmdInit := 1;
		RTrigFunctions := 1;
	END_IF
	LastLanguage := g_Core.System.Runtime.Language;
	
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_OPERATOR_MAIN OR 
		g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PAGE_OPERATOR_MAIN) AND (RCfg.ParScroll.SelectRcpNumber <> LIMIT(1,g_Core.Services.CAR.Runtime.No[0].RecipeNumber,99)) THEN
		RCfg.ParScroll.SelectRcpNumber := LIMIT(1,g_Core.Services.CAR.Runtime.No[0].RecipeNumber,99);
		RCfg.ParScroll.cmdParListRcpChange := 1;
	END_IF
	
	RCfg.FileList.SelectedItem := RcpFileListScroll_0.SelectedItem;
	RCfg.NameList.SelectedItem := RcpNameList_0.SelectedItem;
	RCfg.ParScroll.SelectedItem := ParScroCyclic_0.SelectedItem;
	
	SYSInfo_0();	// getting actual tick_count 
	
	CASE (NewStatusString) OF
		1:	NewStatusString_Time := SYSInfo_0.tick_count;		// store actual tick_count	
			NewStatusString := 2;								// next step				
	
		2:	IF ((NewStatusString_Time + 500) <= SYSInfo_0.tick_count) THEN	// wait 500*10ms = 5s	
				NewStatusString := 0;										// nothing to do		
				strcpy(ADR(RCfg.StatusString),ADR(''));						// clear output			
			END_IF
	END_CASE
	
	IF Completion_CfgDestBegin THEN
		Completion_CfgDestBegin := 0;
		IF RCfg.CfgCopy.CfgDestBegin > RCfg.CfgCopy.CfgDestEnd THEN
			RCfg.CfgCopy.CfgDestEnd := RCfg.CfgCopy.CfgDestBegin;
		END_IF
	END_IF
	
	IF Completion_CfgDestEnd THEN
		Completion_CfgDestEnd := 0;
		IF RCfg.CfgCopy.CfgDestBegin > RCfg.CfgCopy.CfgDestEnd THEN
			RCfg.CfgCopy.CfgDestEnd := RCfg.CfgCopy.CfgDestBegin;
		END_IF
	END_IF
	
	// Name For Recipe Screen
	// TODO GET DYNAMIC -DONE
	IF RCfg.ParScroll.SelectRcpNumber > 0 THEN
		RecipeName := RCfg.NameList.RcpNameArray[RCfg.ParScroll.SelectRcpNumber-1];
	ELSE
		RecipeName := RCfg.NameList.RcpNameArray[0];
	END_IF
	//--------------------------------------------------------------------------------------------------------------------
	// Extra Timer Explanation
	//--------------------------------------------------------------------------------------------------------------------
	
	IF TimerDescription.Enable AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) THEN
		FOR TimerDescription.Cnt := 0 TO 6 DO
			TimerDescription.No[TimerDescription.Cnt] := atoi(ADR(RCfg.ParScroll.ParScrollArray[TimerDescription.Cnt]));
		END_FOR
		TimerDescription.ActTimer := TimerDescription.No[RCfg.ParScroll.SelectedItem];
	ELSE
		TimerDescription.Hide := 1; 
	END_IF
	
	//--------------------------------------------------------------------------------------------------------------------
	// Search Timer number
	//--------------------------------------------------------------------------------------------------------------------
	
	IF g_Core.Services.Recipe.Interface.isCmdSearch THEN
		g_Core.Services.Recipe.Interface.isCmdSearch := FALSE;
	 	ParScroCyclic_0.SearchVariable := g_Core.Services.Recipe.Interface.isCmdSearchTxt;
		ParScroCyclic_0.cmdSearch := TRUE;
	END_IF 	

	// SFX 130816 JESW Also handle select recipe from a layer with list box and alwys show current recipe name on page regardless of scrolling.
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipieSelect) OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) THEN
	(* Open recipe selection layer *)
		IF ShowRecipeSelect THEN
			IF g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_IDLE_0 THEN
				g_Core.Services.Recipe.Runtime.Select.Caller 					:= RECIPE_CALLER_STAT_2;
				g_Core.Services.Recipe.Runtime.CategoryList.ActualFoldProgram	:= RCfg.ParScroll.SelectRcpNumber;
				g_Core.Services.Recipe.Runtime.Select.DefaultListIndex 			:= RCfg.ParScroll.SelectRcpNumber - 1;
			END_IF
			ShowRecipeSelect 													:= FALSE;
		END_IF
		(* Layer is done *)
		(* Show select recipe layer *)
		IF cmdSelectRecipe THEN
			cmdSelectRecipe 													:= FALSE;
			RCfg.NameList.cmdGetNames											:= TRUE;		// To trigger a update of the list in rcfg task....
			IF g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_IDLE_0 THEN
				g_Core.Services.Recipe.Runtime.Select.Caller 					:= RECIPE_CALLER_EDIT_3;
				g_Core.Services.Recipe.Runtime.CategoryList.ActualFoldProgram	:= RCfg.ParScroll.SelectRcpNumber;
				g_Core.Services.Recipe.Runtime.Select.DefaultListIndex  		:= RCfg.ParScroll.SelectRcpNumber - 1;
			END_IF
		END_IF
		IF (g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_DONE_1) AND g_Core.Services.Recipe.Runtime.Select.Caller = RECIPE_CALLER_STAT_2 THEN 		(* Done *)
			RCfg.ParScroll.SelectRcpNumber										:= g_Core.Services.Recipe.Runtime.Select.SelectedRecipe;
			RCfg.ParScroll.cmdParListRcpChange									:= TRUE;
			g_Core.Services.Recipe.Runtime.Select.Caller 						:= RECIPE_CALLER_NONE_0;
		END_IF
	
		IF (RCfg.ParScroll.SelectRcpNumber <> g_Core.Services.Recipe.Runtime.Select.SelectedRecipe) AND (g_Core.Services.Recipe.Runtime.Select.SelectedRecipe > 0) THEN
			RCfg.ParScroll.SelectRcpNumber										:= g_Core.Services.Recipe.Runtime.Select.SelectedRecipe;
			g_Core.Services.Recipe.Runtime.Select.SelectedRecipe				:= 0;
			RCfg.ParScroll.cmdParListRcpChange									:= TRUE;
		END_IF
		IF RCfg.ParScroll.SelectRcpNumber > 0 THEN
			CurrentRecipeName 													:= RCfg.NameList.RcpNameArray[RCfg.ParScroll.SelectRcpNumber-1];
		END_IF
	END_IF
	//--------------------------------------------------------------------------------------------------------------------
	// Timer Visibility
	//--------------------------------------------------------------------------------------------------------------------
//	g_Core.Services.Recipe.Runtime.EditingRecipe := UINT_TO_USINT(RCfg.ParScroll.SelectRcpNumber); 
	TON_VisiEnable(IN := (TON_VisiEnable.IN OR EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) OR EDGEPOS(RInitDone) OR RVariableEdited) AND (RCfg.ParScroll.cmdScrollUp = 0) AND (RCfg.ParScroll.cmdScrollDown = 0),PT :=T#250ms);
	IF TON_VisiEnable.Q AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageRecipeEdit) THEN
		TON_VisiEnable.IN := RVariableEdited := 0;
		g_Core.Services.Recipe.Runtime.UpdateShowLevelEnable := 1;
	END_IF
	
END_PROGRAM
