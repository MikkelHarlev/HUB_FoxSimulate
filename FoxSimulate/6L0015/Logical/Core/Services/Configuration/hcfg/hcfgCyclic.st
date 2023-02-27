PROGRAM _CYCLIC

	TimerDescription.Enable					:= g_Core.System.Configuration.isTimerDescriptionEnabled;
	// Refresh values
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageOptionEdit) THEN
		HwParScroCyclic_0(Enable := TRUE, cmdInit := 1);
	END_IF

	// Show error layer when file error 
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageOptionEdit) OR
		(g_Core.Services.HMIHandler.Runtime.Handler[1].PageControllerID = PageOptionEdit) THEN										
		IF ((HCfg.CfgExtInfo.ErrStringInfo > '') OR (HCfg.CfgExtInfo.ErrStringDetail > '')) THEN		
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= TRUE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= HCfg.CfgExtInfo.ErrStringInfo;
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := HCfg.CfgExtInfo.ErrStringDetail;
		ELSE																						
			g_Core.Services.Alarmhandler.Interface.FileError.Show 		:= FALSE;
			g_Core.Services.Alarmhandler.Interface.FileError.InfoText 	:= '';
			g_Core.Services.Alarmhandler.Interface.FileError.DetailText := '';
		END_IF
	END_IF
	
	// Save hardware from HMI?
	BlockSaveHardware :=  g_Core.System.Configuration.isBlockSaveHCfg;				 
	
	// Wait for previous loaded Files 
	IF (HwCfgInit_0.Status <> 0) THEN
		RETURN;
	END_IF;
	
	IF g_Core.Services.Hardware.Interface.isCmdSaveFactorySettings = 1 THEN
		g_Core.Services.Hardware.Interface.isCmdSaveFactorySettings	:= 0;
		HCfg.cmdSaveCfg 	:= 9;
	END_IF
	
	IF g_Core.Services.Hardware.Interface.isCmdSave THEN
		g_Core.Services.Hardware.Interface.isCmdSave := 0;
		HCfg.cmdSaveCfg 			:= 1;
	END_IF
	
	IF g_Core.Services.Hardware.Interface.isCmdLoad THEN
		g_Core.Services.Hardware.Interface.isCmdLoad := FALSE;
		HCfg.cmdLoadCfg 			:= 1;
	END_IF
	
	// ShowLevel changed..? 
	IF HwParScroCyclic_0.ShowLevel <> g_Core.System.Runtime.showLevel THEN
		HwParScroCyclic_0.ShowLevel := g_Core.System.Runtime.showLevel;
		HwParScroCyclic_0();
	END_IF
	
	TriggScrollDown.CLK := USINT_TO_BOOL(HCfg.ParScroll.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(HCfg.ParScroll.cmdScrollUp);
	TriggScrollDown();
	TriggScrollUp();
	CASE sHwCfg OF
		HWCFG_CHECK_FOR_COMMAND:
		
			IF g_Core.Services.Hardware.Interface.isCmdUpdatePar THEN
				sHwCfg := HWCFG_UPDATE_PAR;
			END_IF	
			IF g_Core.Services.Hardware.Interface.isCmdSearch THEN
				HCfgParScrollSelectedItem := 0;
				HCfgParScrollSelectedVariable := g_Core.Services.Hardware.Interface.isCmdSearchVariable;
				sHwCfg := HWCFG_UPDATE_PAR_FINDPOS;
			END_IF
		
		
			IF (HCfg.cmdLoadCfg = 1) OR g_Core.Services.Hardware.Interface.isCmdLoad THEN
				HCfg.cmdLoadCfg := 0;
				g_Core.Services.Hardware.Interface.isCmdLoad := FALSE;
				strcpy(ADR(HCfg.CfgName),ADR('hcfg.csv'));
				sHwCfg := HWCFG_PARSCROLL_INIT;
			ELSIF (HCfg.cmdSaveCfg = 1) OR g_Core.Services.Hardware.Interface.isCmdSave THEN
				HCfg.cmdSaveCfg := 0;
				g_Core.Services.Hardware.Interface.isCmdSave := FALSE;
				strcpy(ADR(HCfg.CfgName),ADR('hcfg.csv'));
				sHwCfg := HWCFG_SAVE;
	
			ELSIF (HCfg.ParScroll.cmdScrollUp = 1) THEN
				IF (TriggScrollUp.Q = 1) THEN
					HwParScroCyclic_0.cmdUp := 1;
					HwParScroCyclic_0();
				ELSIF (TriggScrollUp.CLK = 1) THEN
					TimeCounterUp := TimeCounterUp + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterUp > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						HwParScroCyclic_0.cmdUp := 1;
						HwParScroCyclic_0();
						CycleCount := 0;
					END_IF
				END_IF
	
			ELSIF (HCfg.ParScroll.cmdScrollDown = 1) THEN
				IF (TriggScrollDown.Q = 1) THEN
					HwParScroCyclic_0.cmdDown := 1;
					HwParScroCyclic_0();
				ELSIF (TriggScrollDown.CLK = 1) THEN
					TimeCounterDown := TimeCounterDown + TaskCycleTime;
					CycleCount := CycleCount + 1;	//	I can't scroll down a par every cycle 
					IF (TimeCounterDown > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
						HwParScroCyclic_0.cmdDown := 1;
						HwParScroCyclic_0();
						CycleCount := 0;
					END_IF
				END_IF
	
			ELSE
				TimeCounterUp := 0;
				TimeCounterDown := 0;
			END_IF
	
		
			// copy parameter edit command		
			IF HCfg.ParScroll.cmdEditPar = 1 THEN
				RVariableEdited := 1;
			END_IF

			(*	copy parameter edit command	*)
			HwParScroCyclic_0.cmdEditPar := HCfg.ParScroll.cmdEditPar;
			IF HCfg.ParScroll.cmdEditPar = 1 THEN		
				HCfg.ParScroll.cmdEditPar := 0;
				HwParScroCyclic_0();
			END_IF
	
		HWCFG_LOAD:
			HwCfgLoad_0.pFileName := ADR(HCfg.CfgName);
			strcpy(ADR(HCfg.StatusString),ADR('No Hardware File Loaded'));
			NewStatusString := 1;									// clear HCfg.StatusString after 5 seconds 
			sHwCfg := HWCFG_LOAD_WAIT;
	
		HWCFG_LOAD_WAIT:
			HwCfgLoad_0();
			g_Core.Services.Hardware.Runtime.initState := INIT;
			RInitDone := FALSE;
			IF (HwCfgLoad_0.Status <> 65535) THEN
				IF (HwCfgLoad_0.Status = 0) THEN
					HCfg.InitDone    := 1;
					strcpy(ADR(HCfg.StatusString),ADR('Hardware File Loaded'));
					NewStatusString := 1;									// clear HCfg.StatusString after 5 seconds 
					HwParScroCyclic_0.cmdInit := 1;
					HwParScroCyclic_0();
					RcpPointRefState := RcpPointRef(CfgInit_0.Ident, RcpPointInit_2.PointerIdent, 1);
					// To find the pointer since we use a ponter to the config record 
					g_Core.Services.Hardware.Interface.ptrConfig := g_Core.System.Configuration.adrHCfgVarName;
					RInitDone := TRUE;
					sHwCfg := HWCFG_CLEAR_ERROR_STRINGS;
					g_Core.Services.Hardware.Runtime.initState := RUNTIME;
				ELSE
					sHwCfg := HWCFG_ERROR;
					g_Core.Services.Hardware.Runtime.initState := ERROR;
				END_IF
			END_IF
	
		HWCFG_SAVE:
			HwCfgSave_0.pFileName := ADR(HCfg.CfgName);
			sHwCfg := HWCFG_SAVE_WAIT;
	
		HWCFG_SAVE_WAIT:
			HwCfgSave_0();
			IF (HwCfgSave_0.Status <> 65535) THEN
				IF (HwCfgSave_0.Status = 0) THEN
					g_Core.Services.Hardware.Runtime.saveCounter := g_Core.Services.Hardware.Runtime.saveCounter + 1;
					strcpy(ADR(HCfg.StatusString),ADR('Hardware File Saved'));
					NewStatusString := 1;									// clear HCfg.StatusString after 5 seconds 
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
					Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
					sHwCfg := HWCFG_CLEAR_ERROR_STRINGS;
				ELSE
					sHwCfg := HWCFG_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		HWCFG_PARSCROLL_INIT:
			HwParScroInit_0();
			IF (HwParScroInit_0.Status <> 65535) THEN
				IF (HwParScroInit_0.Status = 0) THEN
					sHwCfg := HWCFG_LOAD;
					IF NOT RDontNotify THEN
						Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
						Notify(g_Core.Services.HMIHandler.Runtime.Handler[1].pPanelHandler, NOTIFY_OPEN_120, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
					END_IF
					RDontNotify := 0;
				ELSE
					sHwCfg := HWCFG_ERROR;
				END_IF
			END_IF
			g_Core.Services.Alarmhandler.Interface.FileError.ReCheckError := TRUE;
	
		HWCFG_ERROR:
			sHwCfg := HWCFG_CHECK_FOR_COMMAND;
	
		HWCFG_CLEAR_ERROR_STRINGS:
			strcpy(ADR(HCfg.CfgExtInfo.ErrStringInfo),ADR(''));
			strcpy(ADR(HCfg.CfgExtInfo.ErrStringDetail),ADR(''));
			HCfg.CfgExtInfo.Status := 0;
			sHwCfg := HWCFG_CHECK_FOR_COMMAND;
			
		
		HWCFG_UPDATE_PAR:
			HCfgParScrollSelectedItem := HCfg.ParScroll.SelectedItem;
			HCfgParScrollSelectedVariable := HCfg.ParScroll.VarNameArray[HCfg.ParScroll.SelectedItem];

			HwParScroInit_0();
			IF (HwParScroInit_0.Status <> 65535) THEN
				IF (HwParScroInit_0.Status = 0) THEN
					sHwCfg := HWCFG_CHECK_FOR_COMMAND;
					g_Core.Services.Hardware.Interface.isCmdUpdatePar := FALSE;
					HwParScroCyclic_0.SelectRcpNumber := 1; // PMU EDIT
					sHwCfg := HWCFG_UPDATE_PAR_FINDPOS;
				END_IF
			END_IF

		HWCFG_UPDATE_PAR_FINDPOS:
			g_Core.Services.Hardware.Interface.isCmdSearch := FALSE;
			HwParScroCyclic_0.cmdSearchPlace := HCfgParScrollSelectedItem;
			HwParScroCyclic_0.SearchVariable := HCfgParScrollSelectedVariable;
		
			HwParScroCyclic_0.cmdSearch := 1;
			HwParScroCyclic_0();
			IF (HwParScroCyclic_0.cmdSearch = 10) THEN
				// Search found
			ELSIF (HwParScroCyclic_0.cmdSearch = 20) THEN
				// Search not found, jump to first in list	
				HwParScroCyclic_0.cmdJumpFirst := 1;
				HwParScroCyclic_0();
			ELSE
				// Search error
				HwParScroCyclic_0.cmdInit := 1;
				HwParScroCyclic_0();
			END_IF
		
			FOR Cnt := 0 TO 6 DO
				IF HCfg.ParScroll.ParScrollArray[Cnt] = '' THEN
					HCfg.ParScroll.ParValueArray[Cnt] := '';
				END_IF
			END_FOR
			sHwCfg := HWCFG_CHECK_FOR_COMMAND;	
	END_CASE;
	
	// Shift Actual Language 
	IF (LastLanguage <> g_Core.System.Runtime.Language) THEN
		HwParScroCyclic_0.ActLanguage := UINT_TO_USINT(g_Core.System.Runtime.Language);
		HwParScroCyclic_0.cmdLangSwitch := 1;
		HwParScroCyclic_0.cmdInit := 1;
		HwParScroCyclic_0();
	END_IF
	LastLanguage := g_Core.System.Runtime.Language;
	
	HCfg.ParScroll.SelectedItem := HwParScroCyclic_0.SelectedItem;
	
	SYSInfo_0();	
	
	CASE (NewStatusString) OF
		1:	NewStatusString_Time := SYSInfo_0.tick_count;		// store actual tick_count	
			NewStatusString := 2;								// next step				
	
		2:	IF ((NewStatusString_Time + 500) <= SYSInfo_0.tick_count) THEN	// wait 500*10ms = 5s	
				NewStatusString := 0;										// nothing to do		
				strcpy(ADR(HCfg.StatusString),ADR(''));						// clear output			
			END_IF
	END_CASE
	// --------------------------------------------------------------------------------------------------------------------
	// Extra Timer Explanation
	// --------------------------------------------------------------------------------------------------------------------
	IF TimerDescription.Enable AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageOptionEdit) THEN
		FOR TimerDescription.Cnt := 0 TO 6 DO
			TimerDescription.No[TimerDescription.Cnt] := atoi(ADR(HCfg.ParScroll.ParScrollArray[TimerDescription.Cnt]));
		END_FOR
		TimerDescription.ActTimer := TimerDescription.No[HCfg.ParScroll.SelectedItem];
	ELSE
		TimerDescription.Hide := 1; 
	END_IF
	
	IF g_Core.Services.Hardware.Interface.isCmdSearch THEN
		g_Core.Services.Hardware.Interface.isCmdSearch := FALSE;
	 	HwParScroCyclic_0.SearchVariable := g_Core.Services.Hardware.Interface.isCmdSearchTxt;
		HwParScroCyclic_0.cmdSearch := TRUE;
	END_IF 	
	//--------------------------------------------------------------------------------------------------------------------
	// Timer Visibility
	//--------------------------------------------------------------------------------------------------------------------
	TON_VisiEnable(IN := (TON_VisiEnable.IN OR EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageOptionEdit) OR EDGEPOS(RInitDone) OR RVariableEdited) AND (HCfg.ParScroll.cmdScrollUp = 0) AND (HCfg.ParScroll.cmdScrollDown = 0),PT :=T#250ms);
	IF TON_VisiEnable.Q AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageOptionEdit) THEN
		TON_VisiEnable.IN := RVariableEdited := 0;
		g_Core.Services.Hardware.Runtime.UpdateShowLevelEnable := 1;
	END_IF
END_PROGRAM