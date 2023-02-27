PROGRAM _CYCLIC
(*-----------------------------------------------------------------------------------
	Responsible Person: Peter Hauser

	Project Name: 	JENSEN common HMI Project

	Task Name:		op_pageh.src	INIT PART

	Description: 	This task can be used TO manage the page handling in the machine specific operator part
					OF the HMI.
					Prepared pages:
					"Machine Main Page" (ID 1) FOR the connection OF the machine specific part TO the
					"System Login Page" (ID 98) (last operator page before the system pages).
					"System Login Page" (ID 98) FOR labeling the buttons AND the connection back TO the
					"Machine Main Page".

					Additional pages can be inserted BY the user.
					FOR this purpose the page ID, the page specific actions AND the connection TO other pages
					must be inserted in the CASE-statement.

					IF this task is NOT used the connection beween the "Machine Main Page" AND the
					"System Login Page" AND the labeling OF the buttons must be done BY the machine
					programmer!


	References:  	Interface OF the task: OpPageh OF op_pageh_type as global variable

	Libraries:		JenPanel	minimum V2.01

	History:
	10-05-25		V1.04.3			PO Nilsson			Changed FUNCTION on hanger opener service so it can be runned up AND down BY HMI keys...
	10-05-10		V1.04.2			PO Nilsson			Bug fix FOR Logbook save...
	10-05-03		V1.04.1			PO Nilsson			Also save Logbook when process states are saved...
	10-04-28		V1.04.0			PO Nilsson			Removed RollOff parts...
														Increased LogHandle from 20 elements TO 30..
	10-04-16		V1.03.9			PO Nilsson			EXIT from page 570 RollOff Jenway did NOT work fixed..	 
	10-04-06		V1.03.8			PO / Sten			LOG FUNCTION TO LOG all States AND Transfer states.
	10-03-24		V1.03.7			PO Nilsson			g_OutletProcess.Parameters[0] was made into a array...
	10-02-04		V1.03.6			PO Nilsson			Added cogwheel status TO show on service page FOR Top conveyor.
	10-02-03		V1.03.5			PO Nilsson			Removed short cut keys from currentkey.	
	09-12-08		V1.03.4			PO Nilsson			Show Lift AND Belt state on service page..	
	09-10-29		V1.03.3			PO Nilsson			More work on multi stacker, is now working but is NOT finished...
	09-09-15		V1.03.2			PO Nilsson			Start work on MultiStacker...	
	09-09-09		V1.03.1			PO Nilsson			Logbook level logic...
	2009-08-27		V1.03			PO Nilsson			Hanger Opener run test, 
														Bug fix	that when a service page was active it reset the output in some cases..
	2009-03-26		V1.02.1			SF      			Service mode orange instead OF blue
	2009-03-16		V1.02			SF      			Outlet is showing dynamic number OF stackers.
	2009-02-24		V1.01			SF      			Updated all processes TO work
	2009-01-22		V1.00			PO Nilsson			Pointer TO recipe AND removed MAX_NUMBER_OF_CATEGORIES calculation...
	28.05.2004		V0.00.0			Peter Hauser		created
-----------------------------------------------------------------------------------*(*######################*)

(* Check recipe pointer *)
(*######################*)
	IF (g_OptionsAndConfigInit = FALSE) OR (g_Core.Services.Recipe.Runtime.recipePointer = 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	(*	GENERAL handling of function keys and page change *)
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE OR g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_ALARM_OVERVIEW THEN

		(* Show status of process *)
		FOR Index := 1 TO NUMBER_OF_MACHINE_PROCESSES DO
			IF Index < ((SIZEOF(OverView)/SIZEOF(OverView[0]))-1) THEN				
				OverView[Index].State := 0;(* currently always show a colour shape. Maybe later only show if alarm *)
				IF g_MachineManager[Index].StatusData.State = MACHPROC_ERROR_99 THEN
					OverView[Index].IconIndex := 44;
				ELSIF g_MachineManager[Index].StatusData.State = MACHPROC_MANUAL_8 THEN
					OverView[Index].IconIndex := 47;
				ELSIF g_MachineManager[Index].StatusData.State >= MACHPROC_RUN_20 AND g_MachineManager[Index].StatusData.State < MACHPROC_TRIG_ERROR_98 THEN
					OverView[Index].IconIndex := 10;
				ELSE
					OverView[Index].IconIndex := 15;
				END_IF
				
				IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE THEN
					(* Select process to see *)
					IF OverView[Index].cmdSelect = 1 THEN
						g_PreSelectedProcess := Index;
						StatusSetMenu := CallPageControllerLink(PAGE_SERVICE_HANGER_INLET+(Index-1),g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
					END_IF
					OverView[Index].cmdSelect := 0;
				END_IF
			END_IF
		END_FOR
	END_IF

	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE THEN
		IF g_HCfg.CrossConveyor = 0 THEN
			OverView[g_DeliveryProcess.Common.MachineManagerIndex].IconIndex := 52;(*Transparent*)
			OverView[g_DeliveryProcess.Common.MachineManagerIndex].IconIndex := 52;(*Transparent*)
		END_IF
	END_IF

	// Set next / previous page
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE) OR ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_SERVICE_HANGER_INLET) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_SERVICE_DELIVERY)) THEN
		IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_HANGER_INLET) THEN 
				;//StatusSetMenu := CallPageControllerLink(PAGE_MACHINE_SERVICE,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE THEN 
				StatusSetMenu := CallPageControllerLink(PAGE_SERVICE_DELIVERY,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_TOPCONV AND g_HCfg.FeedManual )THEN
				StatusSetMenu := CallPageControllerLink(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID-2,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSE
				StatusSetMenu := CallPageControllerLink(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID-1,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			END_IF
		END_IF
		IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_DELIVERY THEN
				;//StatusSetMenu := CallPageControllerLink(PAGE_MACHINE_SERVICE,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_SERVICE THEN 
				StatusSetMenu := CallPageControllerLink(PAGE_SERVICE_HANGER_INLET,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_HANGER_INLET) AND g_HCfg.FeedManual THEN 
				StatusSetMenu := CallPageControllerLink(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID+2,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSE
				StatusSetMenu := CallPageControllerLink(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID+1,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			END_IF
		END_IF

		(* Set new logbook level *)
		IF cmdLogBookLevel > 0 THEN
			LogBookLevel := LogBookLevel + 1;
		END_IF	
		IF LogBookLevel > 9 THEN
			LogBookLevel := 0;
		END_IF	

		(* Set and manage common data for all screens *)
		CurrentProcessState.State := g_MachineManager[CurrentProcessIndex].StatusData.State;
		CurrentProcessState.OldState := g_MachineManager[CurrentProcessIndex].StatusData.OldState;
		CurrentProcessState.Description := g_MachineManager[CurrentProcessIndex].StatusData.Description;
		CurrentProcessState.ErrorCode := g_MachineManager[CurrentProcessIndex].StatusData.ErrorCode;
		CurrentProcessState.ExchangePreviousStatus := g_MachineManager[CurrentProcessIndex].StatusData.ExchangePreviousStatus;
		CurrentProcessState.ExchangeNextStatus := g_MachineManager[CurrentProcessIndex].StatusData.ExchangeNextStatus;
	END_IF

	IF NOT g_HCfg.FeedManual THEN
		//############################
		// Hanger inlet service page
		//############################
		(* Assign actions to the buttons depending on the page *)
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =  PAGE_SERVICE_HANGER_INLET THEN
			CurrentProcessIndex := g_HangerInletProcess.Common.MachineManagerIndex;
			// Logbook handling
			IF cmdLogBookLevel > 0 THEN
				g_HangerInletProcess.Common.LogBookFlag := LogBookLevel;
			ELSE
				LogBookLevel := g_HangerInletProcess.Common.LogBookFlag;
			END_IF	
			(* Check if Service is available *)
			IF (g_HangerInletProcess.Common.State = MACHPROC_MANUAL_8) THEN
				IF g_HangerInletProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
					g_HangerInletProcess.Common.Product.FoldProgram := 1;
				END_IF
				IF (HangerConveyorJogCmd = 1) THEN
					HangerConveyorJogCmd := 0;
					g_HangerInletProcess.HangerConveyorMotor := TRUE;
					JogTimer := g_HangerInletProcess.Common.CurTimer;
				END_IF	 
				IF (HangerConveyorJogCmd = 0) AND g_HangerInletProcess.HangerConveyorMotor THEN
					IF ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, JogTimer) > 1000 THEN 
						g_HangerInletProcess.HangerConveyorMotor := FALSE;
					END_IF	
				END_IF

			ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
				IF g_HangerInletProcess.HangerConveyorMotor THEN
					g_HangerInletProcess.HangerConveyorMotor := FALSE;
				END_IF				
			END_IF
			OldProcessState := g_HangerInletProcess.Common.State;
		END_IF
	ELSE

		//############################
		// Manual inlet service page
		//############################
		(* Assign actions to the buttons depending on the page *)
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =  PAGE_SERVICE_HANGER_INLET THEN
			CurrentProcessIndex := g_ManualInletProcess.Common.MachineManagerIndex;
			// Logbook handling
			IF cmdLogBookLevel > 0 THEN
				g_ManualInletProcess.Common.LogBookFlag := LogBookLevel;
			ELSE
				LogBookLevel := g_ManualInletProcess.Common.LogBookFlag;
			END_IF	
			(* Check if Service is available *)
			IF (g_ManualInletProcess.Common.State = MACHPROC_MANUAL_8) THEN
				IF g_ManualInletProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
					g_ManualInletProcess.Common.Product.FoldProgram := 1;
				END_IF
				IF (HangerConveyorJogCmd = 1) THEN
					HangerConveyorJogCmd := 0;
					g_ManualInletProcess.Outputs.InletConveyorMotor.State := FOLDIO_STATE_START_1;
					JogTimer := g_ManualInletProcess.Common.CurTimer;
				END_IF	 
				IF (HangerConveyorJogCmd = 0) AND g_ManualInletProcess.Outputs.InletConveyorMotor.Output THEN
					IF ElapsedMsTime(g_ManualInletProcess.Common.CurTimer, JogTimer) > 1000 THEN 
						g_ManualInletProcess.Outputs.InletConveyorMotor.State := FALSE;
					END_IF	
				END_IF

			ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
				IF g_ManualInletProcess.Outputs.InletConveyorMotor.Output THEN
					g_ManualInletProcess.Outputs.InletConveyorMotor.State := FOLDIO_STATE_IDLE_0;
				END_IF				
			END_IF
			OldProcessState := g_ManualInletProcess.Common.State;
		END_IF
	END_IF

	//#############################
	// Hanger opener service page
	//#############################
	(* Assign actions to the buttons depending on the page *)
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =  PAGE_SERVICE_HANGEROPENER THEN
		CurrentProcessIndex := g_HangerOpenerProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_HangerOpenerProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_HangerOpenerProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF (g_HangerOpenerProcess.Common.State = MACHPROC_MANUAL_8) THEN
			IF g_HangerOpenerProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_HangerOpenerProcess.Common.Product.FoldProgram := 1;
			END_IF
			HangerOpenerService := TRUE;	// We are in service mode, used to reset outputs when we leave this page...
		END_IF
		OldProcessState := g_HangerOpenerProcess.Common.State;

	ELSIF HangerOpenerService THEN	
		HangerOpenerService := FALSE;
	END_IF

	//###########################
	// Top conveyor service page
	//###########################
	(* Assign actions to the buttons depending on the page *)
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID =  PAGE_SERVICE_TOPCONV THEN
		CurrentProcessIndex := g_TopConveyorProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_TopConveyorProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_TopConveyorProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_TopConveyorProcess.Common.State = MACHPROC_MANUAL_8 THEN
			IF g_TopConveyorProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_TopConveyorProcess.Common.Product.FoldProgram := 1;
			END_IF
			(*Motor*)
			IF (ServiceOutletCommand.cmdInletMotorRun = TRUE) AND (g_TopConveyorProcess.Common.Motor.Run = FALSE) THEN
				g_TopConveyorProcess.Common.Motor.cmdForward := TRUE;
			ELSIF (ServiceOutletCommand.cmdInletMotorRun = TRUE) AND (g_TopConveyorProcess.Common.Motor.Run = TRUE) THEN
				g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
			END_IF

		ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
			IF g_TopConveyorProcess.Common.Motor.Run = TRUE THEN
				g_TopConveyorProcess.Common.Motor.cmdStop := TRUE;
			END_IF
		END_IF
		OldProcessState := g_TopConveyorProcess.Common.State;
		ServiceOutletCommand.stateInletMotorRun := BOOL_TO_SINT(g_TopConveyorProcess.Common.Motor.Run)*3;
		ServiceOutletCommand.cmdInletMotorRun := 0;

		// Cog wheel on service page
		//CogWheelStatus := IWhC;	
		CogWheelStatus;
	END_IF

	//#######################
	// Lateral service page
	//#######################
	g_LateralService := 0;
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_LATERAL THEN
		CurrentProcessIndex := g_LateralProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_LateralProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_LateralProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_LateralProcess.Common.State = MACHPROC_MANUAL_8 THEN
			g_LateralService := 1;
			IF g_LateralProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_LateralProcess.Common.Product.FoldProgram := 1;
				(* Get recipe pointer *)
				IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
					LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_LateralProcess.Common.Product.FoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
				END_IF
				g_LateralProcess.Parameters := LocalFoldProgram.Lateral;	(* Use medium size parameters *)
			END_IF
			(*Motor*)
			IF (ServiceOutletCommand.cmdLateralMotorRun = TRUE) AND (g_LateralProcess.Common.Motor.Run = FALSE) THEN
				g_LateralProcess.Common.Motor.cmdForward := TRUE;
			ELSIF (ServiceOutletCommand.cmdLateralMotorRun = TRUE) AND (g_LateralProcess.Common.Motor.Run = TRUE) THEN
				g_LateralProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			(*Blade left*)
			IF  ServiceOutletCommand.cmdLateralFoldUnit1 THEN
				g_LateralProcess.Common.FoldUnit1.State := 1;
				g_LateralProcess.Common.FoldUnit1.StartDelayTime := 0;
				g_LateralProcess.Common.FoldUnit1.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
			END_IF
			(*Blade right*)
			IF  ServiceOutletCommand.cmdLateralFoldUnit2 THEN
				g_LateralProcess.Common.FoldUnit2.State := 1;
				g_LateralProcess.Common.FoldUnit2.StartDelayTime := 0;
				g_LateralProcess.Common.FoldUnit2.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
			END_IF
			(* Blade Test *)
			IF ServiceOutletCommand.cmdLateralFoldTestRun AND NOT ServiceOutletCommand.cmdLateralFoldTestRunLeft AND NOT ServiceOutletCommand.cmdLateralFoldTestRunRight THEN
				IF ServiceOutletCommand.LateralFoldTestRun = 0 THEN
					g_LateralProcess.Common.FoldUnit1.StartDelayTime := 0;
					g_LateralProcess.Common.FoldUnit1.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
					g_LateralProcess.Common.FoldUnit2.StartDelayTime := 0;
					g_LateralProcess.Common.FoldUnit2.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
					ServiceOutletCommand.LateralFoldTestRun := 1;
					g_LateralProcess.Common.FoldUnit1.State := 1;
				ELSIF ServiceOutletCommand.LateralFoldTestRun = 1 AND
					g_LateralProcess.Common.FoldUnit1.State	= 0 THEN
					ServiceOutletCommand.LateralFoldTestRun := 2;
					g_LateralProcess.Common.FoldUnit2.State := 1;
				ELSIF ServiceOutletCommand.LateralFoldTestRun = 2 AND
					g_LateralProcess.Common.FoldUnit2.State	= 0 THEN
					ServiceOutletCommand.LateralFoldTestRun := 0;
				END_IF
			ELSE
				ServiceOutletCommand.LateralFoldTestRun := 0;
			END_IF

			(* Blade Test left*)
			IF ServiceOutletCommand.cmdLateralFoldTestRunLeft AND NOT ServiceOutletCommand.cmdLateralFoldTestRunRight AND NOT ServiceOutletCommand.cmdLateralFoldTestRun THEN
				IF ServiceOutletCommand.LateralFoldTestRunLeft = 0 THEN
					g_LateralProcess.Common.FoldUnit1.StartDelayTime := 1000;			(*MTS - Set on 1 sec - Later can be adjustable with HMI*)
					g_LateralProcess.Common.FoldUnit1.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
					ServiceOutletCommand.LateralFoldTestRunLeft := 1;
					g_LateralProcess.Common.FoldUnit1.State := 1;
				ELSIF ServiceOutletCommand.LateralFoldTestRunLeft = 1 AND
					g_LateralProcess.Common.FoldUnit1.State	= 0 THEN
					ServiceOutletCommand.LateralFoldTestRunLeft := 0;
				END_IF
			ELSE
				ServiceOutletCommand.LateralFoldTestRunLeft := 0;
			END_IF

			(* Blade Test right*)
			IF ServiceOutletCommand.cmdLateralFoldTestRunRight AND NOT ServiceOutletCommand.cmdLateralFoldTestRunLeft AND NOT ServiceOutletCommand.cmdLateralFoldTestRun THEN
				IF ServiceOutletCommand.LateralFoldTestRunRight = 0 THEN
					g_LateralProcess.Common.FoldUnit2.StartDelayTime := 1000;			(*MTS - Set on 1 sec - Later can be adjustable with HMI*)
					g_LateralProcess.Common.FoldUnit2.OnTime := ServiceOutletCommand.LateralFoldBladeTime;
					ServiceOutletCommand.LateralFoldTestRunRight := 1;
					g_LateralProcess.Common.FoldUnit2.State := 1;
				ELSIF ServiceOutletCommand.LateralFoldTestRunRight = 1 AND
					g_LateralProcess.Common.FoldUnit2.State	= 0 THEN
					ServiceOutletCommand.LateralFoldTestRunRight := 0;
				END_IF
			ELSE
				ServiceOutletCommand.LateralFoldTestRunRight := 0;
			END_IF
			g_LateralProcess.Template1_05 := ServiceOutletCommand.cmdLateralTemplate05;
			g_LateralProcess.Template1_10 := ServiceOutletCommand.cmdLateralTemplate10;
			g_LateralProcess.Template1_20 := ServiceOutletCommand.cmdLateralTemplate20;
			g_LateralProcess.Template1_40 := ServiceOutletCommand.cmdLateralTemplate40;
			(*g_LateralProcess.Template60_80 := ServiceOutletCommand.cmdLateralTemplate60_80;*)
		ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
			IF g_LateralProcess.Common.Motor.Run = TRUE THEN
				g_LateralProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			ServiceOutletCommand.cmdLateralFoldTestRun := FALSE;
			ServiceOutletCommand.cmdLateralFoldTestRunLeft := FALSE;
			ServiceOutletCommand.cmdLateralFoldTestRunRight := FALSE;
			g_LateralProcess.Common.FoldUnit1.State := 0;
			g_LateralProcess.Common.FoldUnit2.State := 0;
			ServiceOutletCommand.LateralFoldTestRun := 0;
			ServiceOutletCommand.LateralFoldTestRun := 0;
			ServiceOutletCommand.cmdLateralTemplate05 := 0;
			ServiceOutletCommand.cmdLateralTemplate10 := 0;
			ServiceOutletCommand.cmdLateralTemplate20 := 0;
			ServiceOutletCommand.cmdLateralTemplate40 := 0;

		END_IF
		OldProcessState := g_LateralProcess.Common.State;
		ServiceOutletCommand.stateLateralTemplate05 := BOOL_TO_SINT(g_LateralProcess.Template1_05)*3;
		ServiceOutletCommand.stateLateralTemplate10 := BOOL_TO_SINT(g_LateralProcess.Template1_10)*3;
		ServiceOutletCommand.stateLateralTemplate20 := BOOL_TO_SINT(g_LateralProcess.Template1_20)*3;
		ServiceOutletCommand.stateLateralTemplate40 := BOOL_TO_SINT(g_LateralProcess.Template1_40)*3;
		ServiceOutletCommand.stateLateralFoldUnit1 := BOOL_TO_SINT(g_LateralProcess.Common.FoldUnit1.Output)*3;
		ServiceOutletCommand.stateLateralFoldUnit2 := BOOL_TO_SINT(g_LateralProcess.Common.FoldUnit2.Output)*3;
		ServiceOutletCommand.stateLateralMotorRun := BOOL_TO_SINT(g_LateralProcess.Common.Motor.Run)*3;
		ServiceOutletCommand.cmdLateralFoldUnit1 := 0;
		ServiceOutletCommand.cmdLateralFoldUnit2 := 0;
		ServiceOutletCommand.cmdLateralMotorRun := 0;
		ServiceOutletCommand.cmdLateralBeltCountTestRun := 0;
		ServiceOutletCommand.cmdLateralBeltCountTestSave := 0;
	END_IF

	//#######################
	// Cross A service page
	//#######################
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_CROSSA THEN
		CurrentProcessIndex := g_CrossFoldAProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_CrossFoldAProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_CrossFoldAProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_CrossFoldAProcess.Common.State = MACHPROC_MANUAL_8 THEN
			IF g_CrossFoldAProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_CrossFoldAProcess.Common.Product.FoldProgram := 1;
				g_CrossFoldAProcess.Common.ReadParameters := TRUE;
				(* Get recipe pointer *)
				IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
					LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_CrossFoldAProcess.Common.Product.FoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
				END_IF
				g_CrossFoldAProcess.Parameters := LocalFoldProgram.CrossFoldA;
			END_IF
			(* Motor Forward/Reverse*)
			IF (ServiceOutletCommand.cmdCrossAMotorRun = TRUE) AND (g_CrossFoldAProcess.Common.Motor.Run = FALSE) THEN
				g_CrossFoldAProcess.Common.Motor.cmdReverse := TRUE;
			ELSIF (ServiceOutletCommand.cmdCrossAMotorDirection = TRUE) AND (g_CrossFoldAProcess.Common.Motor.Run = FALSE) THEN
				g_CrossFoldAProcess.Common.Motor.cmdForward := TRUE;
			ELSIF g_CrossFoldAProcess.Common.Motor.Run = TRUE AND (ServiceOutletCommand.cmdCrossAMotorRun = TRUE OR ServiceOutletCommand.cmdCrossAMotorDirection = TRUE) THEN
				g_CrossFoldAProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			(* Air-Pipe*)
			IF ServiceOutletCommand.cmdCrossAFoldUnit1 THEN
				g_CrossFoldAProcess.Common.FoldUnit1.State := FOLDIO_STATE_START_1;
				g_CrossFoldAProcess.Common.FoldUnit1.StartDelayTime := 0;
				IF g_CrossFoldAProcess.Common.FoldUnit1.OnTime = 0 THEN
					g_CrossFoldAProcess.Common.FoldUnit1.OnTime := 1000;
				END_IF
			END_IF
			(* Knife*)
			IF ServiceOutletCommand.cmdCrossAFoldUnit2 THEN
				IF NOT ServiceOutletCommand.TestKnife THEN
					ServiceOutletCommand.TestKnife	:= 1;
					g_CrossFoldAProcess.Common.FoldUnit2.State := FOLDIO_STATE_START_1;
					g_CrossFoldAProcess.Common.FoldUnit2.StartDelayTime := 1000;
					IF g_CrossFoldAProcess.Common.FoldUnit2.OnTime = 0 THEN
						g_CrossFoldAProcess.Common.FoldUnit2.OnTime := 500;
					END_IF
				ELSIF ServiceOutletCommand.TestKnife AND g_CrossFoldAProcess.Common.FoldUnit2.State = FOLDIO_STATE_IDLE_0 THEN
					ServiceOutletCommand.TestKnife :=0;
				END_IF	
			END_IF
			(* Belt Opener*)
			IF ServiceOutletCommand.cmdCrossABeltOpen = 1 THEN
				g_CrossFoldAProcess.BeltOpen1.State := FOLDIO_STATE_START_1;
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime := 0;
				g_CrossFoldAProcess.BeltOpen1.OnTime := 1000;		(*MTS - Set on 1 sec - Later can be adjustable with HMI *)
			END_IF
			(* Jam Opener*)
			IF ServiceOutletCommand.cmdCrossAJamOpen = 1 THEN
				g_CrossFoldAProcess.BeltOpen1.State := FOLDIO_STATE_START_1;
				g_CrossFoldAProcess.BeltOpen1.StartDelayTime := 0;
				g_CrossFoldAProcess.BeltOpen1.OnTime := 1000;		(*MTS - Set on 1 sec - Later can be adjustable with HMI *)
			END_IF
		ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
			IF g_CrossFoldAProcess.Common.Motor.Run = TRUE THEN
				g_CrossFoldAProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			ServiceOutletCommand.cmdCrossABeltOpen := 0;
			ServiceOutletCommand.cmdCrossAFoldUnit2 := 0;
		END_IF
		OldProcessState := g_CrossFoldAProcess.Common.State;
		ServiceOutletCommand.cmdCrossABeltOpen := 0;
		ServiceOutletCommand.stateCrossAFoldUnit1 := BOOL_TO_USINT(g_CrossFoldAProcess.Common.FoldUnit1.Output)*3;
		ServiceOutletCommand.stateCrossAFoldUnit2 := BOOL_TO_USINT(g_CrossFoldAProcess.Common.FoldUnit2.Output)*3;
		ServiceOutletCommand.stateCrossABeltOpen := BOOL_TO_USINT(g_CrossFoldAProcess.BeltOpen1.Output)*3;
		ServiceOutletCommand.stateCrossAMotorRun := BOOL_TO_USINT(g_CrossFoldAProcess.Common.Motor.Run AND NOT g_CrossFoldAProcess.Common.Motor.Direction)*3;
		ServiceOutletCommand.stateCrossAMotorDirection := BOOL_TO_USINT(g_CrossFoldAProcess.Common.Motor.Run AND g_CrossFoldAProcess.Common.Motor.Direction)*3;
		ServiceOutletCommand.cmdCrossAFoldUnit1 := 0;
//		ServiceOutletCommand.cmdCrossAFoldUnit2 := 0;
		ServiceOutletCommand.cmdCrossAMotorRun := 0;
		ServiceOutletCommand.cmdCrossAMotorDirection := 0;
	END_IF

	//#######################
	// Cross B service page
	//#######################
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_CROSSB THEN
		CurrentProcessIndex := g_CrossFoldBProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_CrossFoldBProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_CrossFoldBProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_CrossFoldBProcess.Common.State = MACHPROC_MANUAL_8 THEN
			IF g_CrossFoldBProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_CrossFoldBProcess.Common.Product.FoldProgram := 1;
				g_CrossFoldBProcess.Common.ReadParameters := TRUE;
				(* Get recipe pointer *)
				IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
					LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_CrossFoldBProcess.Common.Product.FoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
				END_IF
				g_CrossFoldBProcess.Parameters := LocalFoldProgram.CrossFoldB;	(* Use medium size parameters *)
			END_IF
			(*Motor Forward/Reverse*)
			IF (ServiceOutletCommand.cmdCrossBMotorRun = TRUE) AND (g_CrossFoldBProcess.Common.Motor.Run = FALSE) THEN
				g_CrossFoldBProcess.Common.Motor.cmdReverse := TRUE;
			ELSIF (ServiceOutletCommand.cmdCrossBMotorDirection = TRUE) AND (g_CrossFoldBProcess.Common.Motor.Run = FALSE) THEN
				g_CrossFoldBProcess.Common.Motor.cmdForward := TRUE;
			ELSIF g_CrossFoldBProcess.Common.Motor.Run = TRUE AND (ServiceOutletCommand.cmdCrossBMotorRun = TRUE OR ServiceOutletCommand.cmdCrossBMotorDirection = TRUE) THEN
				g_CrossFoldBProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			(*Folding Air-Pipe for Uniform*)
			IF  ServiceOutletCommand.cmdCrossBFoldUnit1 THEN
				g_CrossFoldBProcess.Common.FoldUnit1.State := FOLDIO_STATE_START_1;
				g_CrossFoldBProcess.Common.FoldUnit1.StartDelayTime := 0;
				g_CrossFoldBProcess.Common.FoldUnit1.OnTime := 1000;		(*MTS - Set on 1 sec - Later can be adjustable with HMI *)
			END_IF
			(*Folding Air-Pipe*)
			IF  ServiceOutletCommand.cmdCrossBFoldUnit2 THEN
				g_CrossFoldBProcess.Common.FoldUnit2.State := FOLDIO_STATE_START_1;
				g_CrossFoldBProcess.Common.FoldUnit2.StartDelayTime := 0;
				g_CrossFoldBProcess.Common.FoldUnit2.OnTime := 1000;		(*MTS - Set on 1 sec - Later can be adjustable with HMI *)
			END_IF
			IF ServiceOutletCommand.cmdCrossBSlopeLift = 1 THEN
				g_CrossFoldBProcess.SlopeLift := 1;
			ELSE
				g_CrossFoldBProcess.SlopeLift := 0;
			END_IF
			IF ServiceOutletCommand.cmdCrossBRaiseAirPipe = 1 THEN
				;
			END_IF
		ELSIF OldProcessState = MACHPROC_MANUAL_8 THEN
			IF g_CrossFoldBProcess.Common.Motor.Run = TRUE THEN
				g_CrossFoldBProcess.Common.Motor.cmdStop := TRUE;
			END_IF
			IF ServiceOutletCommand.cmdCrossBSlopeLift = 1 THEN
				g_CrossFoldBProcess.SlopeLift := 0;
			END_IF
			ServiceOutletCommand.cmdCrossBSlopeLift := 0;
		END_IF
		OldProcessState := g_CrossFoldBProcess.Common.State;
		ServiceOutletCommand.stateCrossBFoldUnit1 := BOOL_TO_USINT(g_CrossFoldBProcess.Common.FoldUnit1.Output)*3;
		ServiceOutletCommand.stateCrossBFoldUnit2 := BOOL_TO_USINT(g_CrossFoldBProcess.Common.FoldUnit2.Output)*3;
		ServiceOutletCommand.stateCrossBMotorRun := BOOL_TO_USINT(g_CrossFoldBProcess.Common.Motor.Run AND NOT g_CrossFoldBProcess.Common.Motor.Direction)*3;
		ServiceOutletCommand.stateCrossBMotorDirection := BOOL_TO_USINT(g_CrossFoldBProcess.Common.Motor.Run AND g_CrossFoldBProcess.Common.Motor.Direction)*3;
		ServiceOutletCommand.stateCrossBSlopeLift := BOOL_TO_USINT(g_CrossFoldBProcess.SlopeLift)*3;
		ServiceOutletCommand.cmdCrossBFoldUnit1 := 0;
		ServiceOutletCommand.cmdCrossBFoldUnit2 := 0;
		ServiceOutletCommand.cmdCrossBRaiseAirPipe := 0;
		ServiceOutletCommand.cmdCrossBMotorRun := 0;
		ServiceOutletCommand.cmdCrossBMotorDirection := 0;
	END_IF

	//#######################
	// Stacker service page
	//#######################
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_STACKER THEN

		// Select stacker group arrow	
		IF (ServiceOutletCommand.cmdStackerOperator = 1) AND (StackerGroupIndex < NUMBER_OF_STACKERGROUPS) THEN
			StackerGroupIndex := StackerGroupIndex + 1;	
			ServiceOutletCommand.cmdStackerOperator := 0;
		ELSIF (ServiceOutletCommand.cmdStackerOperator = 2) AND (StackerGroupIndex > 1) THEN	
			StackerGroupIndex := StackerGroupIndex - 1;	
			ServiceOutletCommand.cmdStackerOperator := 0;
			// Make also direct input code here
		ELSIF (ServiceOutletCommand.cmdStackerOperator = 3) THEN	
			IF (StackerGroupIndex < 1) OR (StackerGroupIndex > NUMBER_OF_STACKERGROUPS) THEN
				StackerGroupIndex := 1;
			END_IF	
		ELSIF (ServiceOutletCommand.cmdStackerOperator = 0) AND (StackerGroupIndex = 0) THEN		
			StackerGroupIndex := 1;
		END_IF

		CurrentProcessIndex := g_StackerProcess[StackerGroupIndex].Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_StackerProcess[0].Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_StackerProcess[0].Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_StackerProcess[StackerGroupIndex].Common.State = MACHPROC_MANUAL_8 THEN
			IF g_StackerProcess[StackerGroupIndex].Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_StackerProcess[StackerGroupIndex].Common.Product.FoldProgram := 1;
				g_StackerProcess[StackerGroupIndex].Common.ReadParameters := TRUE;
				(* Get recipe pointer *)
				IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
					LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_StackerProcess[StackerGroupIndex].Common.Product.FoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
				END_IF
				g_StackerProcess[StackerGroupIndex].Parameters := LocalFoldProgram.StackerBelt1;	(* Use medium size parameters *)
			END_IF
			(*Motor*)
			IF (ServiceOutletCommand.cmdStackerMotorRun = TRUE) AND (g_StackerProcess[StackerGroupIndex].Common.Motor.Run = FALSE) THEN
				g_StackerProcess[StackerGroupIndex].Common.Motor.cmdForward := TRUE;
			ELSIF (ServiceOutletCommand.cmdStackerMotorRun = TRUE) AND (g_StackerProcess[StackerGroupIndex].Common.Motor.Run = TRUE) THEN
				g_StackerProcess[StackerGroupIndex].Common.Motor.cmdStop := TRUE;
			END_IF
			(*Flaps*)
			IF  ServiceOutletCommand.cmdStackerFoldUnit1 THEN
				g_StackerProcess[StackerGroupIndex].FlapsClose := NOT g_StackerProcess[StackerGroupIndex].FlapsClose;
			END_IF
		ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN
			IF g_StackerProcess[StackerGroupIndex].Common.Motor.Run = TRUE THEN
				g_StackerProcess[StackerGroupIndex].Common.Motor.cmdStop := TRUE;
			END_IF

		END_IF
		OldProcessState := g_StackerProcess[StackerGroupIndex].Common.State;
		ServiceOutletCommand.stateStackerFoldUnit1 := BOOL_TO_USINT(g_StackerProcess[StackerGroupIndex].FlapsClose)*3;
		ServiceOutletCommand.stateStackerMotorRun := BOOL_TO_USINT(g_StackerProcess[StackerGroupIndex].Common.Motor.Run)*3;
		ServiceOutletCommand.cmdStackerFoldUnit1 := 0;
		ServiceOutletCommand.cmdStackerMotorRun := 0;
	END_IF


	//#######################
	// Outlet service page
	//#######################
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_OUTLET THEN

		// Select stacker arrow	
		IF (ServiceOutletCommand.cmdOutletOperatorSelect = 1) AND (StackerIndex < g_HCfg.NumberOfStackers) THEN
			StackerIndex := StackerIndex + 1;	
			ServiceOutletCommand.cmdOutletOperatorSelect := 0;
		ELSIF (ServiceOutletCommand.cmdOutletOperatorSelect = 2) AND (StackerIndex > 1) THEN	
			StackerIndex := StackerIndex - 1;	
			ServiceOutletCommand.cmdOutletOperatorSelect := 0;
			// Make also direct input code here
		ELSIF (ServiceOutletCommand.cmdOutletOperatorSelect = 3) THEN	
			IF (StackerIndex < 1) OR (StackerIndex > g_HCfg.NumberOfStackers) THEN
				StackerIndex := 1;
			END_IF	
			ServiceOutletCommand.cmdOutletOperatorSelect := 0;
		ELSIF (ServiceOutletCommand.cmdOutletOperatorSelect = 0) AND (StackerIndex = 0) THEN		
			StackerIndex := 1;
		END_IF

		// To show Lift and Belt state on the Service page for Outlet
		HMILiftState := g_OutletProcess.StackerUnit[StackerIndex].LiftState;
		HMIBeltState := g_OutletProcess.StackerUnit[StackerIndex].BeltState;
		STGIndex := REAL_TO_UINT((StackerIndex + 1) / 2);			
		HMIStackerGroupStat := g_OutletProcess.StackerGroupLink[STGIndex].State; 


		CurrentProcessIndex := g_OutletProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_OutletProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_OutletProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_OutletProcess.Common.State = MACHPROC_MANUAL_8 THEN
			IF g_OutletProcess.Common.Product.FoldProgram = 0 THEN (* If no FoldProgram is selected *)
				g_OutletProcess.Common.Product.FoldProgram := 1;
				(* Get recipe pointer *)
				IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
					LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (g_OutletProcess.Common.Product.FoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
				END_IF
				FOR i := 1 TO g_HCfg.NumberOfStackers DO
					g_OutletProcess.Parameters[i] := LocalFoldProgram.Outlet;	(* Use medium size parameters *)
				END_FOR	
				g_OutletProcess.Common.ReadParameters := TRUE;
			END_IF
			TestRunSettings := ServiceOutletCommand.cmdOutletTableTest[1] +(BOOL_TO_UINT(ServiceOutletCommand.cmdOutletTableTest[2])*2)+(BOOL_TO_UINT(ServiceOutletCommand.cmdOutletTableTest[3])*4);
			IF TestRunSettings = OldTestRunSettings THEN
				;
			ELSIF ServiceOutletCommand.cmdOutletTableTest[1] THEN
				Master := 1;
				ServiceOutletCommand.stateOutletTableTest[1] := 1;
				IF ServiceOutletCommand.cmdOutletTableTest[2] THEN
					ServiceOutletCommand.stateOutletTableTest[2] := 9;
				ELSE
					ServiceOutletCommand.stateOutletTableTest[2] := 0;
				END_IF
				IF ServiceOutletCommand.cmdOutletTableTest[3] THEN
					ServiceOutletCommand.stateOutletTableTest[3] := 9;
				ELSE
					ServiceOutletCommand.stateOutletTableTest[3] := 0;
				END_IF
			ELSIF ServiceOutletCommand.cmdOutletTableTest[2] THEN
				Master := 2;
				ServiceOutletCommand.stateOutletTableTest[1] := 0;
				ServiceOutletCommand.stateOutletTableTest[2] := 1;
				IF ServiceOutletCommand.cmdOutletTableTest[3] THEN
					ServiceOutletCommand.stateOutletTableTest[3] := 9;
				ELSE
					ServiceOutletCommand.stateOutletTableTest[3] := 0;
				END_IF
			ELSIF ServiceOutletCommand.cmdOutletTableTest[3] THEN
				Master := 3;
				ServiceOutletCommand.stateOutletTableTest[1] := 0;
				ServiceOutletCommand.stateOutletTableTest[2] := 0;
				ServiceOutletCommand.stateOutletTableTest[3] := 1;
			ELSE
				Master := 0;
				ServiceOutletCommand.stateOutletTableTest[1] := 0;
				ServiceOutletCommand.stateOutletTableTest[2] := 0;
				ServiceOutletCommand.stateOutletTableTest[3] := 0;
			END_IF
			FOR i := 1 TO g_HCfg.NumberOfStackers DO
				g_OutletProcess.StackerUnit[i].Motor.cmdForward := ServiceOutletCommand.cmdOutletMotorRun[i];
				ServiceOutletCommand.cmdOutletMotorRun[i] := 0;
				g_OutletProcess.StackerUnit[i].RollOff := ServiceOutletCommand.cmdOutletRollOff[i];

				IF ServiceOutletCommand.cmdOutletTableTest[i] THEN
					CASE ServiceOutletCommand.stateOutletTableTest[i] OF

						1: (* Test to be started, go up and wait for all  *)
							g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
							g_OutletProcess.StackerUnit[i].SinkTimer := g_OutletProcess.Common.CurTimer;
							ServiceOutletCommand.stateOutletTableTest[i] := 3;
						2: (* Wait for Sensor *)
							IF g_OutletProcess.StackerUnit[i].LevelSensor.Input THEN (* Use input to compensate a little for running in slow task class. *)
								g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
								g_OutletProcess.StackerUnit[i].SinkTimer := g_OutletProcess.Common.CurTimer;
								ServiceOutletCommand.stateOutletTableTest[i] := 3;
							END_IF
						3: (* Wait to be all way down *)
							IF ElapsedMsTime(g_OutletProcess.Common.CurTimer, g_OutletProcess.StackerUnit[i].SinkTimer) >= g_MCfg.Stacker.IndexingDelay THEN
								g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_UP_1;
								ServiceOutletCommand.stateOutletTableTest[i] := 2;(* Start over again *)
							END_IF
						9: (* Just follow master *)
							g_OutletProcess.StackerUnit[i].LiftMode := g_OutletProcess.StackerUnit[Master].LiftMode;
					END_CASE
				ELSIF ServiceOutletCommand.cmdOutletTableUp[i] THEN
					IF g_OutletProcess.StackerUnit[i].LevelSensor.Input THEN (* Use input to compensate a little for running in slow task class. *)
						g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_STOP_3;
					ELSE
						g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_UP_1;
					END_IF
				ELSE
					g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
				END_IF
				OldTestRunSettings :=  TestRunSettings;
			END_FOR
		ELSIF (OldProcessState = MACHPROC_MANUAL_8) THEN (* Not in service mode *)
			FOR i := 1 TO g_HCfg.NumberOfStackers DO
				ServiceOutletCommand.cmdOutletMotorRun[i] := 0;
				IF ServiceOutletCommand.cmdOutletRollOff[i] THEN
					ServiceOutletCommand.cmdOutletRollOff[i] := FALSE;
					g_OutletProcess.StackerUnit[i].RollOff := FALSE;
				END_IF
				IF ServiceOutletCommand.cmdOutletTableTest[i] THEN
					g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
					ServiceOutletCommand.cmdOutletTableTest[i] := 0;
					ServiceOutletCommand.stateOutletTableTest[i] := 0;
				END_IF
				IF ServiceOutletCommand.cmdOutletTableUp[i] THEN
					g_OutletProcess.StackerUnit[i].LiftMode := LIFT_MODE_DOWN_2;
					ServiceOutletCommand.cmdOutletTableUp[i] := FALSE;
				END_IF
			END_FOR
		END_IF

		OldProcessState := g_OutletProcess.Common.State;

		FOR i := 1 TO 4 DO
			IF i <= g_HCfg.NumberOfStackers THEN
				ServiceOutletCommand.stateOutletVisible[i] := 0;
				ServiceOutletCommand.stateOutletTableUp[i] := BOOL_TO_USINT(g_OutletProcess.StackerUnit[i].Up)*3;
				ServiceOutletCommand.stateOutletTableDown[i] := BOOL_TO_USINT(g_OutletProcess.StackerUnit[i].ReleaseBreak)*3;
				ServiceOutletCommand.stateOutletMotorRun[i] := BOOL_TO_USINT(g_OutletProcess.StackerUnit[i].Motor.Run)*3;
				ServiceOutletCommand.stateOutletRollOff[i] := BOOL_TO_USINT(g_OutletProcess.StackerUnit[i].RollOff)*3;
			ELSE
				ServiceOutletCommand.stateOutletVisible[i] := 1;
			END_IF
		END_FOR
	END_IF


	//#######################
	// Delivery service page
	//#######################
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_SERVICE_DELIVERY THEN
		CurrentProcessIndex := g_DeliveryProcess.Common.MachineManagerIndex;
		// Logbook handling
		IF cmdLogBookLevel > 0 THEN
			g_DeliveryProcess.Common.LogBookFlag := LogBookLevel;
		ELSE
			LogBookLevel := g_DeliveryProcess.Common.LogBookFlag;
		END_IF	
		(* Check if Service is available *)
		IF g_DeliveryProcess.Common.State = MACHPROC_MANUAL_8 THEN
			g_DeliveryProcess.Common.Motor.cmdForward := ServiceOutletCommand.cmdDeliveryCrossMotorRun; 	(*Cross Motor*)
			g_DeliveryProcess.DeliveryBelt.Motor.cmdForward := ServiceOutletCommand.cmdDeliveryMotorRun;	(*Delivery Motor*)
		ELSIF OldProcessState = MACHPROC_MANUAL_8 THEN
			ServiceOutletCommand.cmdDeliveryCrossMotorRun := FALSE;
			ServiceOutletCommand.cmdDeliveryMotorRun := FALSE;
		END_IF
		OldProcessState := g_OutletProcess.Common.State;
		FOR i := 1 TO 20(* g_DeliveryProcess.CrossBelt *)		 DO
			ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.CrossBelt.Hook[i].State;
			IF g_DeliveryProcess.CrossBelt.Hook[i].State = HOOK_STATE_STACK_HEADER_1 THEN
				ServiceOutletCommand.stateCrossHookColour[i] := 14;
				IF ServiceOutletCommand.stateDeliveryInfo = 0 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].FoldProgram MOD 100;
				ELSIF ServiceOutletCommand.stateDeliveryInfo = 1 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].Destination MOD 100;
				ELSIF ServiceOutletCommand.stateDeliveryInfo = 2 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].Count MOD 100;
				ELSIF ServiceOutletCommand.stateDeliveryInfo = 3 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].ArticleId MOD 100;
				ELSIF ServiceOutletCommand.stateDeliveryInfo = 4 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].CustomerId MOD 100;
				ELSIF ServiceOutletCommand.stateDeliveryInfo = 5 THEN
					ServiceOutletCommand.stateCrossHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.CrossBelt.Hook[i].StackIndex].BatchId MOD 100;
				ELSE
					ServiceOutletCommand.stateDeliveryInfo := 0; (* Reset info value *)
				END_IF
			ELSIF g_DeliveryProcess.CrossBelt.Hook[i].State = HOOK_STATE_FILL_DATA_2 THEN
				ServiceOutletCommand.stateCrossHookColour[i] := 246;
				ServiceOutletCommand.stateCrossHookPos[i] := 99;
			ELSE
				ServiceOutletCommand.stateCrossHookColour[i] := 253;
				ServiceOutletCommand.stateCrossHookPos[i] := 0;
			END_IF
		END_FOR
		IF ServiceOutletCommand.stateDeliveryInfo > 6 THEN
			ServiceOutletCommand.stateDeliveryInfo := 0; (* Reset info value *)
		END_IF
		FOR i := 1 TO 3(* g_DeliveryProcess.Delivery *)	DO
			ServiceOutletCommand.stateDeliveryHookPos[i] := g_DeliveryProcess.DeliveryBelt.Hook[i].State;
			IF g_DeliveryProcess.DeliveryBelt.Hook[i].State = HOOK_STATE_STACK_HEADER_1 THEN
				ServiceOutletCommand.stateDeliveryHookPos[i] := g_DeliveryProcess.StackData[g_DeliveryProcess.DeliveryBelt.Hook[i].StackIndex].FoldProgram;
			ELSIF g_DeliveryProcess.DeliveryBelt.Hook[i].State = HOOK_STATE_FILL_DATA_2 THEN
				ServiceOutletCommand.stateDeliveryHookPos[i] := 999;
			ELSE
				ServiceOutletCommand.stateDeliveryHookPos[i] := 0;
			END_IF
		END_FOR
		FOR i := 1 TO g_DeliveryProcess.NumberOfLoadPoints	 DO
			ServiceOutletCommand.stateDeliveryLoadPos[i] := g_DeliveryProcess.CrossLoadPoint[i].Exchange.TransferStatus;
		END_FOR
		ServiceOutletCommand.stateDeliveryCrossMotorRun := BOOL_TO_USINT(g_DeliveryProcess.Common.Motor.Run)*3;
		ServiceOutletCommand.cmdDeliveryCrossMotorRun := 0;
		ServiceOutletCommand.stateDeliveryMotorRun := BOOL_TO_USINT(g_DeliveryProcess.DeliveryBelt.Motor.Run)*3;
		ServiceOutletCommand.cmdDeliveryMotorRun := 0;
	END_IF

	(* Reset an error *)
	IF g_HMIProcessStatus.Reset THEN
		g_MachineManager[CurrentProcessIndex].ResetAlarm := TRUE;
		g_HMIProcessStatus.Reset := FALSE;
	END_IF

	(* Go into Service mode *)
	IF (g_HMIProcessStatus.ManualKeyCompletion = 1) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 1) THEN
		g_MachineManager[CurrentProcessIndex].Service := g_HMIProcessStatus.ManualKey;
	END_IF
	g_HMIProcessStatus.ManualKeyCompletion := 0;
	g_HMIProcessStatus.ManualKey := g_MachineManager[CurrentProcessIndex].Service;

	cmdLogBookLevel := FALSE;
	OldProcess := CurrentProcessIndex;

	//**************************************
	//**************************************
	// Write Process State to a log  file
	//**************************************
	//**************************************

	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 2 THEN
		ButtonShow := 0; 
	ELSE
		ButtonShow := 1;
	END_IF
	IF cmdSaveStateMachine > 0 THEN
		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
		memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
		strcpy(ADR(logstr),ADR('Process states for '));
		strcat(ADR(logstr),ADR(g_Core.System.Configuration.SystemDescription.MachineNumber));
		length := strlen(ADR(logstr));
		logstr[length] := 32; // remove null char.
		logstr[LogRecLen-2] := 13;// Add CR at end of LogRecord frame
		logstr[LogRecLen-1] := 10;// Add LF at end of LogRecord frame
		memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
		LogHandle.LogPointer := 1;
		HeadString := 'Process ;State ;OldState ;E-Code ;Next Transfer ;Prev Transfer';
		memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
		strcpy(ADR(logstr),ADR(HeadString));
		length := strlen(ADR(logstr));
		logstr[length] := 32; // remove null char.
		logstr[LogRecLen-2] := 13;// Add CR at end of LogRecord frame
		logstr[LogRecLen-1] := 10;// Add LF at end of LogRecord frame
		memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
		LogHandle.LogPointer := LogHandle.LogPointer  + 1;
		FOR i:= 1 TO NUMBER_OF_MACHINE_PROCESSES DO
			memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
			itoa(g_MachineManager[i].StatusData.Id, ADR(tmpstr));
			strcpy(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' '));
			strcat(ADR(logstr),ADR(g_MachineManager[i].StatusData.Description));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_MachineManager[i].StatusData.State, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_MachineManager[i].StatusData.OldState, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_MachineManager[i].StatusData.ErrorCode, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_MachineManager[i].StatusData.ExchangeNextStatus, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_MachineManager[i].StatusData.ExchangePreviousStatus, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			length := strlen(ADR(logstr));
			logstr[length] := 32; // remove null char.
			logstr[LogRecLen-2] := 13;// Add CR at end of LogRecord frame
			logstr[LogRecLen-1] := 10;// Add LF at end of LogRecord frame
			memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
			LogHandle.LogPointer := LogHandle.LogPointer  + 1;
		END_FOR
		// Data for Stacker group link...	
		FOR i:= 1 TO NUMBER_OF_STACKERGROUPS DO
			memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
			strcpy(ADR(logstr),ADR('STG link '));
			itoa(i, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_OutletProcess.StackerGroupLink[i].State, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_OutletProcess.StackerGroupLink[i].OldState, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_OutletProcess.StackerGroupLink[i].ErrorCode, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_OutletProcess.StackerGroupLink[i].Next.TransferStatus, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;'));
			itoa(g_OutletProcess.StackerGroupLink[i].Previous.TransferStatus, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			length := strlen(ADR(logstr));
			logstr[length] := 32; // remove null char.
			logstr[LogRecLen-2] := 13;// Add CR at end of LogRecord frame
			logstr[LogRecLen-1] := 10;// Add LF at end of LogRecord frame
			memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
			LogHandle.LogPointer := LogHandle.LogPointer  + 1;
		END_FOR
		// Stackers Lift and Belt state
		FOR i:= 1 TO g_HCfg.NumberOfStackers DO
			memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
			strcpy(ADR(logstr),ADR('Stacker'));
			strcat(ADR(logstr),ADR(' '));
			itoa(i, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;Liftstate '));
			itoa(g_OutletProcess.StackerUnit[i].LiftState, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;BeltState '));
			itoa(g_OutletProcess.StackerUnit[i].BeltState, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			strcat(ADR(logstr),ADR(' ;Transferstate '));
			itoa(g_OutletProcess.StackerUnit[i].Next.TransferStatus, ADR(tmpstr));
			strcat(ADR(logstr),ADR(tmpstr));
			length := strlen(ADR(logstr));
			logstr[length] := 32; // remove null char.
			logstr[LogRecLen-2] := 13;// Add CR at end of LogRecord frame
			logstr[LogRecLen-1] := 10;// Add LF at end of LogRecord frame
			memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
			LogHandle.LogPointer := LogHandle.LogPointer  + 1;
		END_FOR

		cmdSaveStateMachine := FALSE;
		IF LogHandle.LogPointer > 0 THEN
			LogHandle.DoSave := TRUE;
		END_IF
	END_IF

	IF LogHandle.DoSave THEN
		memcpy(ADR(TempLogRecord),ADR(LogRecord[0]),LogHandle.LogPointer*SIZEOF(LogRecord[0]));
		LogHandle.RecordAdr := ADR(TempLogRecord);
		LogHandle.RecordSize := LogHandle.LogPointer*SIZEOF(LogRecord[0]);
		LogHandle.SaveFileState := 10;
		LogHandle.StoreTimeOutCntr := 0;
		LogHandle.DoSave := FALSE;
		LogHandle.LogPointer := 0;
	END_IF

	(* Save the data TO a csv file*)
	CASE (LogHandle.SaveFileState) OF

		10:	(* Check if a file is already present on HDD, if present open otherwise create it. *)
			FB_FileOpen.enable := 1;
			FB_FileOpen.pDevice := ADR(LogHandle.DeviceName);
			FB_FileOpen.pFile := ADR(LogHandle.FileName);
			FB_FileOpen.mode := FILE_RW;  (* Read and write access *)
			FB_FileOpen();

			LogHandle.OpenIdent := FB_FileOpen.ident;
			LogHandle.OpenStatus := FB_FileOpen.status;

			IF (LogHandle.OpenStatus = 20708) THEN
				LogHandle.SaveFileState := 20;
			ELSIF (LogHandle.OpenStatus = 0) THEN
				FB_FileWrite.offset := LogHandle.LastFileWriteAddress;
				LogHandle.SaveFileState := 15;
			ELSIF (LogHandle.OpenStatus <> 65535) THEN
				LogHandle.OpenError := 1;
				LogHandle.SaveFileState := 0;
				IF (LogHandle.OpenStatus = 20799) THEN
					LogHandle.OpenError := FileIoGetSysError();
				END_IF
			END_IF
		15:
			FB_FileDelete.pDevice := ADR(LogHandle.DeviceName);
			FB_FileDelete.pName := ADR(LogHandle.FileName);
			FB_FileDelete.enable := 1;
			FB_FileDelete();
			LogHandle.OpenStatus := FB_FileDelete.status;
			IF (LogHandle.OpenStatus = 0) THEN		(* File was deleted *)
				LogHandle.SaveFileState := 20;
			ELSIF (LogHandle.OpenStatus <> 65535) THEN
				LogHandle.OpenError := 1;
				LogHandle.SaveFileState := 0;
				IF (LogHandle.OpenStatus = 20799) THEN
					LogHandle.OpenError := FileIoGetSysError();
				END_IF
			END_IF

		20: (**** Create file ****)
			FB_FileCreate.enable := 1;
			FB_FileCreate.pDevice := ADR(LogHandle.DeviceName);
			FB_FileCreate.pFile := ADR(LogHandle.FileName);
			FB_FileCreate();

			LogHandle.OpenIdent := FB_FileCreate.ident;
			LogHandle.OpenStatus := FB_FileCreate.status;

			IF (LogHandle.OpenStatus = 0) THEN
				FB_FileWrite.offset := 0;
				LogHandle.SaveFileState := 30;
			ELSIF (LogHandle.OpenStatus <> 65535) THEN
				LogHandle.OpenError := 2;
				LogHandle.SaveFileState := 0;
				IF (LogHandle.OpenStatus = 20799) THEN
					LogHandle.OpenError := FileIoGetSysError();
				END_IF
			END_IF

		30:	(* Write to file *)
			FB_FileWrite.enable := TRUE;
			FB_FileWrite.ident := LogHandle.OpenIdent;
			FB_FileWrite.pSrc := LogHandle.RecordAdr;
			FB_FileWrite.len := LogHandle.RecordSize;
			FB_FileWrite();

			IF (FB_FileWrite.status = 0) THEN
				FB_FileWrite.offset := FB_FileWrite.offset + LogHandle.RecordSize;
				LogHandle.LastFileWriteAddress := FB_FileWrite.offset;
				LogHandle.SaveFileState := 40;
			ELSIF (FB_FileWrite.status <> 65535) THEN (* Some error, try to close *)
				LogHandle.SaveFileState := 40;
			END_IF

		40:	(* Close the file after writing *)
			FB_FileClose.enable := TRUE;
			FB_FileClose.ident := LogHandle.OpenIdent;
			FB_FileClose();
			IF (FB_FileClose.status = 0) THEN
				LogHandle.SaveFileState := 50;
			ELSIF (FB_FileClose.status <> 65535) THEN
				LogHandle.SaveFileState := 0;
			END_IF
      
		50: // Also save log file with this command
			//g_SaveLogBookFile := TRUE;
			LogHandle.SaveFileState := 0;
		
	END_CASE
END_PROGRAM