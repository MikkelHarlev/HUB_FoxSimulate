PROGRAM _CYCLIC
	(*	When switching to digital page, activate inputs	*)
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageIOStatus) AND (lastPage <> g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID) THEN
		IoStatus.IoType := IO_LIST_DI_LIST;
	END_IF;
	lastPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID;
	
	(*	exit task if page not active or Error in Init function occured	*)
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageIOStatus OR IoListInit_0.Status <> 0 THEN
		IF (IoListInit_0.Status <> 0) THEN
			g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Alarm   [44] := TRUE;
			g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Priority[44] := 255;
		END_IF
		RETURN;
	END_IF
	
	(*	generate signal for scroll continues if button pressed longer	*)
	
	TriggScrollDown.CLK := USINT_TO_BOOL(IoStatus.cmdScrollDown);
	TriggScrollUp.CLK := USINT_TO_BOOL(IoStatus.cmdScrollUp);
	
	TriggScrollDown();
	TriggScrollUp();
	
	// Set IO Description
	IF (strlen(ADR(IoStatus.IoDescription)) > 0) THEN
		IODescription := IoStatus.IoDescription;
	ELSE
		IODescription := IoStatus.IoInfoStruct.ActIoName;
	END_IF
	
	(*	check if Io Type has changed	*)
	IF (IoStatus.IoType <> oldIoType) THEN
		IoListScroll_0.IoType := IoStatus.IoType;
		IoListScroll_0.cmdInit := 1;
	END_IF;
	oldIoType := IoStatus.IoType;
	
	
	(* Set status for 'State Set' input fields *)
	CASE IoStatus.IoType OF
		0, 2:
			IoStatus.EnableStateSet:= 0;
			IoStatus.ColorStateSet:= COLOR_OUTPUT_FIELD;
		1, 3:
			IoStatus.EnableStateSet:= 1;
			IoStatus.ColorStateSet:= COLOR_INPUT_FIELD;
	END_CASE
	
	(*	Check for Scrolling Up	*)
	IF (TriggScrollUp.Q = 1) THEN	(*	Button Pressed	*)
		IoListScroll_0.cmdUp := 1;
	ELSIF (TriggScrollUp.CLK = 1) THEN
		TimeCounterUp := TimeCounterUp + TaskCycleTime;
		CycleCount := CycleCount + 1;	(*	I can't scroll down a par every cycle *)
		IF (TimeCounterUp > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
			IoListScroll_0.cmdUp := 1;
			CycleCount := 0;
		END_IF;
	ELSE
		TimeCounterUp := 0;
	END_IF;
	
	
	(*	Check for Scrolling Down	*)
	IF (TriggScrollDown.Q = 1) THEN	(*	Button Pressed	*)
		IoListScroll_0.cmdDown := 1;
	ELSIF (TriggScrollDown.CLK = 1) THEN
		TimeCounterDown := TimeCounterDown + TaskCycleTime;
		CycleCount := CycleCount + 1;	(*	I can't scroll down a par every cycle *)
		IF (TimeCounterDown > TimePermanentScroll) AND (CycleCount > CycleScroll) THEN
			IoListScroll_0.cmdDown := 1;
			CycleCount := 0;
		END_IF;
	ELSE
		TimeCounterDown := 0;
	END_IF;
	
	
	(*	check for change state	*)
	IF (IoStatus.cmdChangeOutput = 1) THEN
		IoListScroll_0.cmdSetOutput := 1;
		IoStatus.cmdChangeOutput := 0;
	END_IF;
	
	
	(*	check for Level Up	*)
	IF (IoStatus.cmdLevelUp = 1) THEN
		IoStatus.cmdLevelUp := 0;
		IoListScroll_0.cmdScrollLevelUp := 1;
	END_IF;
	
	
	(*	check for Level Down	*)
	IF (IoStatus.cmdLevelDown = 1) THEN
		IoStatus.cmdLevelDown := 0;
		IoListScroll_0.cmdScrollLevelDown := 1;
	END_IF;
	
	
	(*	Set color according to IO State *)
	FOR StateCount := 0 TO (IoListInit_0.LinesVisWindow - 1)DO
		IoStatus.ColorDigitalArray[StateCount] := IoStatus.DigitalStateArray[StateCount] *(1+IoStatus.IoType*2);
	END_FOR;
	
	ActualIoColour := IoStatus.DigitalStateSet *(1+IoStatus.IoType*2);
	
	IF EDGENEG (g_Core.Services.IO.Interface.isHaltPlc) THEN
		SetForce := 3;
	END_IF
	
	(* Force handling *)
	CASE SetForce OF
		1:(* Force Io to ON *)
			IF IoStatus.IoInfoStruct.ActIoAdr > 0 THEN
				IF IoListScroll_0.ActIoForcedOn >0 THEN (*force is active already *)
					IoStatus.DigitalForce := 1;
					IoListScroll_0.cmdForceSetValue := 1;
				ELSE
					IoListScroll_0.cmdForceEnable := 1;
					DoSetValue := 1;
					SetIoCountDown := 3;
				END_IF
			END_IF
		2:(* Force Io to OFF *)
			IF IoStatus.IoInfoStruct.ActIoAdr > 0 THEN
				IF IoListScroll_0.ActIoForcedOn > 0 THEN (*force is active already *)
					IoStatus.DigitalForce := 0;
					IoListScroll_0.cmdForceSetValue := 1;
				ELSE
					DoSetValue := 2;
					IoListScroll_0.cmdForceEnable := 1;
					SetIoCountDown := 3;
				END_IF
			END_IF
		3:(* Release Force *)
			IF IoStatus.IoInfoStruct.ActIoAdr > 0 THEN
				IF IoListScroll_0.ActIoForcedOn > 0 THEN (*force is active already *)
					IoListScroll_0.cmdForceDisable := 1;
				END_IF
			END_IF
		4:(* Release Force of All *)
			IF IoListScroll_0.AnyIoForcedOn > 0 THEN
				IoListScroll_0.cmdForceDisableAll := 1;
			END_IF
		ELSE
			;
	END_CASE
	SetForce := 0;
	IF EDGENEG (g_Core.Services.IO.Interface.isHaltPlc) THEN
		SetForce := 4;
	END_IF
		 
	IoListScroll_0();

	(* Force value in next loop *)
	IF SetIoCountDown > 0 THEN
		SetIoCountDown := SetIoCountDown -1;
		IF SetIoCountDown = 0 THEN
			IF DoSetValue = 1 THEN
				IoStatus.DigitalForce := 1;
				IoListScroll_0.cmdForceSetValue := 1;
			ELSIF DoSetValue = 2 THEN
				IoStatus.DigitalForce := 0;
				IoListScroll_0.cmdForceSetValue := 1;
			END_IF
			DoSetValue := 0;
		END_IF
	END_IF
	
	IoStatus.SelectedItem := UINT_TO_USINT(IoListScroll_0.SelectedItem);
	
	IF IoStatus.IoInfoStruct.Value[2] = '1' OR (* X67 *)
		IoStatus.IoInfoStruct.Value[2] = '3' THEN (* X20 *)
		strcpy(ADR(ModuleDescriptionText[1]),ADR('Node #'));
		strcpy(ADR(ModuleValueText[0]),ADR('PowerLink '));
		strcpy(ADR(ModuleValueText[1]),ADR(IoStatus.IoInfoStruct.Value[3]));(* Node Id 1-255 *)
		strcpy(ADR(ModuleValueText[2]),ADR(IoStatus.IoInfoStruct.Value[4]));(* Channel number 1-8 *)
	ELSIF IoStatus.IoInfoStruct.Value[0] = '6' THEN (* X2X IF6 *)
		strcpy(ADR(ModuleDescriptionText[1]),ADR('Slot #'));
		strcpy(ADR(ModuleValueText[0]),ADR('Local IO'));
		strcpy(ADR(ModuleValueText[1]),ADR(IoStatus.IoInfoStruct.Value[1]));(* Node Id 1-15 *)
		strcpy(ADR(ModuleValueText[2]),ADR(IoStatus.IoInfoStruct.Value[2]));(* Channel number 1-16 *)	
	ELSE	(* PowerLink IF2 *)
		strcpy(ADR(ModuleDescriptionText[1]),ADR('Slot #'));
		strcpy(ADR(ModuleValueText[0]),ADR('Local IO'));
		strcpy(ADR(ModuleValueText[1]),ADR(IoStatus.IoInfoStruct.Value[4]));(* Node Id 1-15 *)
		strcpy(ADR(ModuleValueText[2]),ADR(IoStatus.IoInfoStruct.Value[5]));(* Channel number 1-16 *)
	END_IF
	
	hideUnForceHMI  := g_Core.System.Configuration.isHideUnForceHMI; 
	hidePlcHalt 	:= g_Core.System.Configuration.isHidePlcHalt;
	
END_PROGRAM