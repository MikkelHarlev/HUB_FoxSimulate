PROGRAM _CYCLIC

	TimerDescription.Enable					:= g_Core.System.Configuration.isTimerDescriptionEnabled;
	// Refresh values
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMachineConfigEdit) THEN
		MachParScroCyclic_0(Enable := TRUE, cmdInit := 1);
	END_IF

	// Show error layer when file error 
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMachineConfigEdit) OR 
		(g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageMachineConfigEdit) THEN	
		IF ((MCfg.CfgExtInfo.ErrStringInfo > '') OR (MCfg.CfgExtInfo.ErrStringDetail > '')) THEN		// If error information 
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= MCfg.CfgExtInfo.ErrStringInfo;
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := MCfg.CfgExtInfo.ErrStringDetail;
		ELSE																						// No error information 
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= FALSE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= '';
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := '';
		END_IF
	END_IF
	
	// Wait for previous loaded Files 
	IF (MaCfgInit_0.Status <> 0) THEN
		RETURN;
	END_IF
	
	// ShowLevel changed..? 
	IF MachParScroCyclic_0.ShowLevel <> g_Core.System.Runtime.showLevel THEN
		MachParScroCyclic_0.ShowLevel := g_Core.System.Runtime.showLevel;
		MachParScroCyclic_0();
	END_IF
	
	IF g_Core.Services.Machine.Interface.isCmdSave THEN
		g_Core.Services.Machine.Interface.isCmdSave := FALSE;
		MCfg.cmdSaveCfg := 1;
	END_IF
	IF g_Core.Services.Machine.Interface.isCmdLoad THEN
		g_Core.Services.Machine.Interface.isCmdLoad := FALSE;
		MCfg.cmdLoadCfg := 1;
	END_IF
	
	// If correct password was entered, save current config as factory settings.
	IF ((g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 2) OR (g_Core.Services.HMIHandler.Runtime.Handler[1].PasswordLevel > 2)) AND 
		(g_Core.Services.Machine.Interface.isCmdSaveFactorySettings = 1) THEN
		g_Core.Services.Machine.Interface.isCmdSaveFactorySettings	:= 0;
		MCfg.cmdSaveCfg := 9;
	END_IF
	
	// If correct password was entered, save current config as factory settings.
	IF (g_Core.Services.Machine.Interface.isCmdLoadFactorySettings = 1) THEN
		g_Core.Services.Machine.Interface.isCmdLoadFactorySettings	:= 0;
		MCfg.cmdLoadCfg := 9;
	END_IF
	
	TriggScrollDown.CLK := USINT_TO_BOOL(MCfg.ParScroll.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(MCfg.ParScroll.cmdScrollUp);
	TriggScrollDown();
	TriggScrollUp();
	
	CASE sMaCfg OF
		MACFG_CHECK_FOR_COMMAND:
			IF (g_Core.Services.Machine.Interface.isCmdUpdatePar) THEN
				sMaCfg := MACFG_UPDATE_PAR;
			END_IF	
			IF g_Core.Services.Machine.Interface.isCmdSearch THEN
				MCfgParScrollSelectedItem := 0;
				MCfgParScrollSelectedVariable := g_Core.Services.Machine.Interface.isCmdSearchVariable;
				sMaCfg := MACFG_UPDATE_PAR_FINDPOS;
			END_IF
			IF (MCfg.cmdLoadCfg = 9) THEN
				MCfg.cmdLoadCfg := 0;
				strcpy(ADR(MCfg.CfgName), ADR('mcfg0.csv'));
				g_Core.Services.System.Runtime.file.LastMachineFile := MCfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sMaCfg := MACFG_PARSCROLL_INIT;
			ELSIF (MCfg.cmdLoadCfg = 1) THEN
				MCfg.cmdLoadCfg := 0;
				strcpy(ADR(MCfg.CfgName), ADR('mcfg1.csv'));
				g_Core.Services.System.Runtime.file.LastMachineFile := MCfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sMaCfg := MACFG_PARSCROLL_INIT;
			ELSIF (MCfg.cmdSaveCfg = 1) THEN
				MCfg.cmdSaveCfg := 0;
				strcpy(ADR(MCfg.CfgName), ADR('mcfg1.csv'));
				g_Core.Services.System.Runtime.file.LastMachineFile := MCfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sMaCfg := MACFG_SAVE;
			ELSIF (MCfg.cmdSaveCfg = 9) THEN
				MCfg.cmdSaveCfg := 0;
				strcpy(ADR(MCfg.CfgName), ADR('mcfg0.csv'));
				g_Core.Services.System.Runtime.file.LastMachineFile := MCfg.CfgName;
				g_Core.Services.System.Interface.isCmdSave := 1;
				sMaCfg := MACFG_SAVE;
			ELSIF (MCfg.ParScroll.cmdScrollUp = 1) THEN
				IF (TriggScrollUp.Q = 1) THEN
					MachParScroCyclic_0.cmdUp := 1;
					MachParScroCyclic_0();
				ELSIF (TriggScrollUp.CLK = 1) THEN
					TimeCounterUp := TimeCounterUp + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterUp > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						MachParScroCyclic_0.cmdUp := 1;
						MachParScroCyclic_0();
						CycleCount := 0;
					END_IF
				END_IF
	
			ELSIF (MCfg.ParScroll.cmdScrollDown = 1) THEN
				IF (TriggScrollDown.Q = 1) THEN
					MachParScroCyclic_0.cmdDown := 1;
					MachParScroCyclic_0();
				ELSIF (TriggScrollDown.CLK = 1) THEN
					TimeCounterDown := TimeCounterDown + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterDown > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						MachParScroCyclic_0.cmdDown := 1;
						MachParScroCyclic_0();
						CycleCount := 0;
					END_IF
				END_IF
	
			ELSE
				TimeCounterUp := 0;
				TimeCounterDown := 0;
			END_IF
	
			(*	copy edit command	*)
			IF MCfg.ParScroll.cmdEditPar = 1 THEN
				RVariableEdited := 1;
			END_IF

			(*	copy edit command	*)
			MachParScroCyclic_0.cmdEditPar := MCfg.ParScroll.cmdEditPar;
			MCfg.ParScroll.cmdEditPar := 0;

			MachParScroCyclic_0();
	
		MACFG_LOAD:
			MaCfgLoad_0.pFileName := ADR(MCfg.CfgName);
			strcpy(ADR(MCfg.StatusString),ADR('No Config File Loaded'));
			NewStatusString := 1;									// clear MCfg.StatusString after 5 seconds 
			sMaCfg := MACFG_LOAD_WAIT;
	
		MACFG_LOAD_WAIT:
			MaCfgLoad_0();
			g_Core.Services.Machine.Runtime.initState := INIT;
			RInitDone := FALSE;
			IF (MaCfgLoad_0.Status <> 65535) THEN
				IF (MaCfgLoad_0.Status = 0) THEN
					MCfg.InitDone  := 1;
					strcpy(ADR(MCfg.StatusString),ADR('Config File Loaded'));
					NewStatusString := 1;									// clear MCfg.StatusString after 5 seconds 
					MachParScroCyclic_0.cmdInit := 1;
					MachParScroCyclic_0();
					RInitDone := TRUE;
					// To find the pointer since we use a ponter to the config record 
					RcpPointRefState := RcpPointRef(MaCfgInit_0.Ident, RcpPointInit_1.PointerIdent, 1);
					g_Core.Services.Machine.Interface.ptrConfig := g_Core.System.Configuration.adrMCfgVarName;

					sMaCfg := MACFG_CLEAR_ERROR_STRINGS;
					g_Core.Services.Machine.Runtime.initState := RUNTIME;
					g_LoadCFG 		:= TRUE;							(* Inserted by PWC *)
				ELSE
					sMaCfg := MACFG_ERROR;
					g_Core.Services.Machine.Runtime.initState := ERROR;
				END_IF
			END_IF
	
		MACFG_SAVE:
			MaCfgSave_0.pFileName := ADR(MCfg.CfgName);
			sMaCfg := MACFG_SAVE_WAIT;
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	
		MACFG_SAVE_WAIT:
			MaCfgSave_0();
			IF (MaCfgSave_0.Status <> 65535) THEN
				IF (MaCfgSave_0.Status = 0) THEN
					g_Core.Services.Machine.Runtime.saveCount := g_Core.Services.Machine.Runtime.saveCount + 1;
					strcpy(ADR(MCfg.StatusString),ADR('Config File Saved'));
					NewStatusString := 1;									// clear MCfg.StatusString after 5 seconds 
					sMaCfg := MACFG_CLEAR_ERROR_STRINGS;
				ELSE
					sMaCfg := MACFG_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		MACFG_PARSCROLL_INIT:
			MachParScroInit_0();
			IF (MachParScroInit_0.Status <> 65535) THEN
				IF (MachParScroInit_0.Status = 0) THEN
					IF (g_Core.Services.System.Runtime.isSystemFileValid) THEN
						IF (strlen(ADR(g_Core.Services.System.Runtime.file.LastMachineFile)) <> 0) THEN
							strcpy(ADR(MCfg.CfgName),ADR(g_Core.Services.System.Runtime.file.LastMachineFile));
						ELSE
							strcpy(ADR(MCfg.CfgName),ADR('mcfg0.csv'));
						END_IF
						sMaCfg := MACFG_LOAD;
						IF NOT RDontNotify THEN
							Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
							Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
						END_IF
						RDontNotify := 0;
					END_IF
				ELSE
					sMaCfg := MACFG_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		MACFG_ERROR:
			sMaCfg := MACFG_CHECK_FOR_COMMAND;
	
		MACFG_CLEAR_ERROR_STRINGS:
			strcpy(ADR(MCfg.CfgExtInfo.ErrStringInfo), ADR(''));
			strcpy(ADR(MCfg.CfgExtInfo.ErrStringDetail), ADR(''));
			MCfg.CfgExtInfo.Status := 0;
			sMaCfg := MACFG_CHECK_FOR_COMMAND;

		MACFG_UPDATE_PAR:
			MCfgParScrollSelectedItem := MCfg.ParScroll.SelectedItem;
			MCfgParScrollSelectedVariable := MCfg.ParScroll.VarNameArray[MCfg.ParScroll.SelectedItem];

			MachParScroInit_0();
			IF (MachParScroInit_0.Status <> 65535) THEN
				IF (MachParScroInit_0.Status = 0) THEN
					g_Core.Services.Machine.Interface.isCmdUpdatePar := FALSE;
					sMaCfg := MACFG_UPDATE_PAR_FINDPOS;
				END_IF
			END_IF

		MACFG_UPDATE_PAR_FINDPOS:
			g_Core.Services.Machine.Interface.isCmdSearch := FALSE;
			MachParScroCyclic_0.cmdSearchPlace := MCfgParScrollSelectedItem;
			MachParScroCyclic_0.SearchVariable := MCfgParScrollSelectedVariable;
			MachParScroCyclic_0.cmdSearch := 1;
			MachParScroCyclic_0();
			IF (MachParScroCyclic_0.cmdSearch = 10) THEN
				// Search found
			ELSIF (MachParScroCyclic_0.cmdSearch = 20) THEN
				// Search not found, jump to first in list	
				MachParScroCyclic_0.cmdJumpFirst := 1;
				MachParScroCyclic_0();
			ELSE
				// Search error
				MachParScroCyclic_0.cmdInit := 1;
				MachParScroCyclic_0();
			END_IF
		
			FOR Cnt := 0 TO 6 DO
				IF MCfg.ParScroll.ParScrollArray[Cnt] = '' THEN
					MCfg.ParScroll.ParValueArray[Cnt] := '';
				END_IF
			END_FOR
			sMaCfg := MACFG_CHECK_FOR_COMMAND;
	END_CASE;
	
	// Shift Actual Language 
	IF (LastLanguage <> g_Core.System.Runtime.Language) THEN
		MachParScroCyclic_0.ActLanguage := UINT_TO_USINT(g_Core.System.Runtime.Language);
		MachParScroCyclic_0.cmdLangSwitch := 1;
		MachParScroCyclic_0.cmdInit := 1;
		MachParScroCyclic_0();
	END_IF
	LastLanguage := g_Core.System.Runtime.Language;
	
	MCfg.ParScroll.SelectedItem := MachParScroCyclic_0.SelectedItem;
	
	SYSInfo_0();	// getting actual tick_count 
	
	CASE (NewStatusString) OF
		1:	NewStatusString_Time := SYSInfo_0.tick_count;		// store actual tick_count	
			NewStatusString := 2;								// next step				
	
		2:	IF ((NewStatusString_Time + 500) <= SYSInfo_0.tick_count) THEN	// wait 500*10ms = 5s	
				NewStatusString := 0;										// nothing to do		
				strcpy(ADR(MCfg.StatusString),ADR(''));						// clear output			
			END_IF
	END_CASE
	// --------------------------------------------------------------------------------------------------------------------
	// Extra Timer Explanation
	// --------------------------------------------------------------------------------------------------------------------	
	IF TimerDescription.Enable AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMachineConfigEdit) THEN
		FOR TimerDescription.Cnt := 0 TO 6 DO
			TimerDescription.No[TimerDescription.Cnt] := atoi(ADR(MCfg.ParScroll.ParScrollArray[TimerDescription.Cnt]));
		END_FOR
		TimerDescription.ActTimer := TimerDescription.No[MCfg.ParScroll.SelectedItem];
	ELSE
		TimerDescription.Hide := 1; 
	END_IF
	
	IF g_Core.Services.Machine.Interface.isCmdSearch THEN
		g_Core.Services.Machine.Interface.isCmdSearch := FALSE;
	 	MachParScroCyclic_0.SearchVariable := g_Core.Services.Machine.Interface.isCmdSearchTxt;
		MachParScroCyclic_0.cmdSearch := TRUE;
	END_IF 	
	g_MCfgInitDone := USINT_TO_BOOL(MCfg.InitDone);
	
	//--------------------------------------------------------------------------------------------------------------------
	// Timer Visibility
	//--------------------------------------------------------------------------------------------------------------------
	TON_VisiEnable(IN := (TON_VisiEnable.IN OR EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMachineConfigEdit) OR EDGEPOS(RInitDone) OR RVariableEdited) AND (MCfg.ParScroll.cmdScrollUp = 0) AND (MCfg.ParScroll.cmdScrollDown = 0),PT :=T#250ms);
	IF TON_VisiEnable.Q AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMachineConfigEdit) THEN
		TON_VisiEnable.IN := RVariableEdited := 0;
		g_Core.Services.Machine.Runtime.UpdateShowLevelEnable := 1;
	END_IF
END_PROGRAM