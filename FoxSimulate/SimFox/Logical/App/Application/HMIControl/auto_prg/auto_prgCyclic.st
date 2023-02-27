PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson

FileName:				Auto_prg.scr

Desription:				Handling OF the Auto PROGRAM FOR the Fox...

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.



History:
15-02-25				V1.05.0		SF 				AutoProgram comes from acfg-file AND is no longer a global array.
													Structure OF PROGRAM changed.
11-10-18				V1.04.10	WM 				OverallAlighment in AutoProg is removed 
10-12-01				V1.04.9		PO Nilsson		Added a notification layer TO the Copy Autoprogram FUNCTION...
10-11-29				V1.04.8		PO Nilsson		Added SwingDelay TO the Autoprogram, delay TO stop swing before hanger conveyor...
10-10-05				V1.04.7		PO Nilsson		Bug fix FOR Long trouser...
10-06-17				V1.04.6		PO Nilsson		Improved Auto PROGRAM search so IF no matching length we match on type only..
10-04-16				V1.04.5		PO Nilsson		More FUNCTION TO Infeed stop, selet on Shirt OR Trouser OR both...
10-04-13				V1.04.4		PO Nilsson		Infeed stop on trouser OR NOT added in Auto PROGRAM...	
10-03-19				V1.04.3		PO Nilsson		Fixed InletWaitTime FOR Fox 600
10-03-18				V1.04.2		PO Nilsson		Enable pajamas at all time...
10-02-22				V1.04.1		PO Nilsson		Overall alignment added.
10-01-26				V1.04.0		PO Nilsson		Added the Wait timer hanger inlet...
													Fixed the copy OF auto programs...
10-01-25				V1.03.9		PO Nilsson		New library from BR_SE...
10-01-20				V1.03.8		PO Nilsson		Added the trouser alignment FUNCTION...
10-01-12				V1.03.7		PO Nilsson		Removed the "Data" member OF the g_ACfg. structure has no real use...
													Added HMI FUNCTION FOR the Offset balde FOR lateral...
09-12-10				V1.03.6		PO Nilsson		Secured code when Search does NOT FIND a Autoprogram so it set 1 AND Found flag..
09-11-24				V1.03.5		PO Nilsson		Added the Stop timers FOR the Infeed belt...
09-11-23				V1.03.4		PO Nilsson		Pyjamas was added,bug fix..
09-11-19				V1.03.3		PO Nilsson		Made fix so the Autoprogram funcion should alway RETURN atleast 1...	
09-11-16				V1.03.2		PO Nilsson		Create zero file when recipe zero files are created.. Also combi hanger pyjamas opening..
09-09-30				V1.03.1		PO Nilsson		Always assign first Name in first record TO make file save work Check why with B&R...
09-09-08				V1.03.0		PO Nilsson		Removed [0..1] records in AutoProgram type
09-08-25				V1.02 		PO Nilsson		Now the main screen show the Auto PROGRAM from hanger i stf, and list on turn around conveyor data.			
09-08-13				V1.01 		SFX				Allow 3 states in product type detection auto,force trouse AND now also force shirt.
09-03-24				V0.01 		PO Nilsson		First edition...
---------------------------------------------------------------------------------------*)
	IF (g_OptionsAndConfigInit = FALSE) OR (g_Core.Services.Recipe.Runtime.recipePointer = 0) OR (g_Core.Services.AutoProg.Runtime.autoprogPointer = 0)  THEN		(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	g_HMIHandler;

	(*########################################*)
	(* Check if catgory data pointer is valid *)
	(*########################################*)
	IF (g_AutoProgram.SelectedAutoProgram < 1) OR (g_AutoProgram.SelectedAutoProgram > MAX_AUTO_PROGRAM_99) THEN
		g_AutoProgram.SelectedAutoProgram 				:=  1;	
	END_IF

	IF g_Core.System.Interface.isCustomerEnabled THEN
		IF (g_AutoProgram.OperatorAutoProgram = 0) AND (OldSelectedAutoProgram > 0) AND (OldCustomerNumber > 0) THEN // Set AutoPtrogram at start up
			OldCustomerNumber 								:= OldCustomerNumber;	
			g_AutoProgram.SelectedAutoProgram 				:= OldSelectedAutoProgram;
			g_AutoProgram.OperatorAutoProgram 				:= OldSelectedAutoProgram;
			HmiAutoProgram.HmiAction 						:= 1;
		ELSIF g_Core.Services.CAR.Runtime.No[0].CustomerNumber <> OldCustomerNumber THEN // New customer selected
			OldCustomerNumber 								:= g_Core.Services.CAR.Runtime.No[0].CustomerNumber;	
			g_AutoProgram.SelectedAutoProgram 				:= g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
			g_AutoProgram.OperatorAutoProgram 				:= g_Core.Services.CAR.Runtime.No[0].RecipeNumber;
			OldSelectedAutoProgram							:= g_AutoProgram.OperatorAutoProgram;
		END_IF	
	END_IF
	
	// Jump to autoprogram page from recipe-outlet indexing shortcut
	IF HmiAutoProgram.HmiAction = 60 THEN
		HmiAutoProgram.HmiAction := 0;
		CallPageControllerLink(PAGE_MACHINE_AUTOPROGSETUP5, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	END_IF

	IF ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_MACHINE_AUTOPROGSETUP1) AND 
		(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_MACHINE_AUTOPROGSETUP5)) OR
		(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGFILE) THEN

		(* Operator changed Auto program *)
		IF (HmiAutoProgram.SelectedAutoProgram < 1) OR HmiAutoProgram.SelectedAutoProgram > MAX_AUTO_PROGRAM_99  THEN
			HmiAutoProgram.SelectedAutoProgram := 1;
		END_IF
		IF (g_AutoProgram.SelectedAutoProgram < 1) OR g_AutoProgram.SelectedAutoProgram > MAX_AUTO_PROGRAM_99  THEN
			g_AutoProgram.SelectedAutoProgram := 1;
		END_IF
	
		(* Select Auto Program range *)
		LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer);		(* Get the complete Array *)
		(* Check categorys range *)
		FOR Index := 1 TO MAX_AUTO_LIST_5 DO
			IF HmiAutoProgram.Completion[Index] = 1 THEN
				HmiAutoProgram.Completion[Index] := 0;
				IF HmiAutoProgram.Category[Index] > MAX_NUMBER_OF_CATEGORIES THEN
					HmiAutoProgram.Category[Index] := MAX_NUMBER_OF_CATEGORIES;
				END_IF
				IF HmiAutoProgram.Category[Index] < 1 THEN
					HmiAutoProgram.Category[Index] := 1;
				END_IF
			END_IF
		END_FOR

		IF (HmiAutoProgram.HmiAction = 1) OR OpenPage THEN
			IF OpenPage	THEN
				HmiAutoProgram.SelectedAutoProgram 	:= g_AutoProgram.SelectedAutoProgram;
				OpenPage							:= FALSE;	
			END_IF	
			HmiAutoProgram.HmiAction			:= 0;

			// Find actual AutoProgram
			LocalAutoProgram ACCESS(g_Core.Services.AutoProg.Runtime.autoprogPointer + (SIZEOF(LocalAutoProgram) * LIMIT(0, (HmiAutoProgram.SelectedAutoProgram - 1), MAX_NUMBER_OF_AUTOPROGRAMS)));
			FOR Index := 1 TO MAX_AUTO_LIST_5 DO
				HmiAutoProgram.Category[Index]			:= LocalAutoProgram.Categorys[Index];
				HmiAutoProgram.SelectionPoint[Index]	:= LocalAutoProgram.LenghtPoints[Index] / 10;
				HmiAutoProgram.Trouser[Index]			:= LocalAutoProgram.Trouser[Index];
				IF HmiAutoProgram.Category[Index] > 0 THEN
					HmiAutoProgram.CategoryName[Index]	:= LocalFoldProgram[HmiAutoProgram.Category[Index]-1].Name;
				ELSE
					HmiAutoProgram.CategoryName[Index] 	:= '';
				END_IF	
			END_FOR
			HmiAutoProgram.Name				:= LocalAutoProgram.Name;
			HmiAutoProgram.RightArmDelay 	:= LocalAutoProgram.ArmBlowDelay[0];
			HmiAutoProgram.LeftArmDelay 	:= LocalAutoProgram.ArmBlowDelay[1];
			HmiAutoProgram.RightArmTime 	:= LocalAutoProgram.ArmBlowOnTime[0];
			HmiAutoProgram.LeftArmTime 		:= LocalAutoProgram.ArmBlowOnTime[1];
			// Cycle speed borde väl vara med här också..??
		END_IF

		(* Operator changed data in the current Auto program *)
		IF HmiAutoProgram.HmiAction = 2 THEN
			HmiAutoProgram.HmiAction  := 0; 
			FOR Index := 1 TO MAX_AUTO_LIST_5 DO
				IF (HmiAutoProgram.Category[Index] > 99) OR (HmiAutoProgram.Category[Index] < 1) THEN
					LocalAutoProgram.Categorys[Index] 	:= 1;
					HmiAutoProgram.Category[Index] 		:= LocalAutoProgram.Categorys[Index];
				ELSE	
					LocalAutoProgram.Categorys[Index] 		:= HmiAutoProgram.Category[Index];
					LocalAutoProgram.LenghtPoints[Index] 	:= HmiAutoProgram.SelectionPoint[Index] * 10;
					IF LocalAutoProgram.LenghtPoints[Index] = LocalAutoProgram.LenghtPoints[Index - 1] THEN
						IF LocalAutoProgram.LenghtPoints[Index] > 0 THEN
							IF HmiAutoProgram.Trouser[Index - 1] = 0 THEN;
								HmiAutoProgram.Trouser[Index - 1] 	:= 1;
							END_IF	
							IF HmiAutoProgram.Trouser[Index] = 0 THEN
								HmiAutoProgram.Trouser[Index] 		:= 1;
							END_IF	
						END_IF
					END_IF
					// Update name
					IF HmiAutoProgram.Category[Index] > 0 THEN
						HmiAutoProgram.CategoryName[Index]		:= LocalFoldProgram[HmiAutoProgram.Category[Index]-1].Name;
					ELSE
						HmiAutoProgram.CategoryName[Index] := '';
					END_IF
				END_IF
			END_FOR
		END_IF	

		(* Sleeve inserter data changed by operator *)
		IF HmiAutoProgram.HmiAction = 3 THEN
			HmiAutoProgram.HmiAction 							:= 0;	
			LocalAutoProgram.ArmBlowDelay[0] 					:= HmiAutoProgram.RightArmDelay;
			LocalAutoProgram.ArmBlowDelay[1] 					:= HmiAutoProgram.LeftArmDelay;
			LocalAutoProgram.ArmBlowOnTime[0]					:= HmiAutoProgram.RightArmTime;
			LocalAutoProgram.ArmBlowOnTime[1]					:= HmiAutoProgram.LeftArmTime;
			LocalAutoProgram.TShirtBlowDelay[0]					:= HmiAutoProgram.RightTShirtDelay;
			LocalAutoProgram.TShirtBlowDelay[1]					:= HmiAutoProgram.LeftTShirtDelay;
			LocalAutoProgram.TShirtBlowOnTime[0]				:= HmiAutoProgram.RightTShirtTime;
			LocalAutoProgram.TShirtBlowOnTime[1]				:= HmiAutoProgram.LeftTShirtTime;
			LocalAutoProgram.FlapTrousersAirBlastStartDelay 	:= HmiAutoProgram.FlapTrousersAirBlastStartDelay;
			LocalAutoProgram.FlapTrousersAirBlastOnTime 		:= HmiAutoProgram.FlapTrousersAirBlastOnTime;
		END_IF

		HmiAutoProgram.RightArmDelay 	:= LocalAutoProgram.ArmBlowDelay[0];
		HmiAutoProgram.LeftArmDelay 	:= LocalAutoProgram.ArmBlowDelay[1];
		HmiAutoProgram.RightArmTime 	:= LocalAutoProgram.ArmBlowOnTime[0];
		HmiAutoProgram.LeftArmTime 		:= LocalAutoProgram.ArmBlowOnTime[1];
		HmiAutoProgram.RightTShirtDelay := LocalAutoProgram.TShirtBlowDelay[0];
		HmiAutoProgram.LeftTShirtDelay 	:= LocalAutoProgram.TShirtBlowDelay[1];
		HmiAutoProgram.RightTShirtTime 	:= LocalAutoProgram.TShirtBlowOnTime[0];
		HmiAutoProgram.LeftTShirtTime 	:= LocalAutoProgram.TShirtBlowOnTime[1];
		HmiAutoProgram.FlapTrousersAirBlastStartDelay 	:= LocalAutoProgram.FlapTrousersAirBlastStartDelay;
		HmiAutoProgram.FlapTrousersAirBlastOnTime 		:= LocalAutoProgram.FlapTrousersAirBlastOnTime;

		IF HmiAutoProgram.HmiAction = 4 THEN
			HmiAutoProgram.HmiAction := 0;
			CallPageControllerLink(PAGE_MACHINE_AUTOPROGSETUP4, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		END_IF
		
		(* AutoProgram name change *)
		IF HmiAutoProgram.HmiAction = 5 THEN
			HmiAutoProgram.HmiAction := 0;	
			LocalAutoProgram.Name 	:= HmiAutoProgram.Name;
		END_IF

		(* Trouser bypass lateral blades *)
		IF HmiAutoProgram.HmiAction = 6 THEN
			HmiAutoProgram.HmiAction := 0;	
			HmiAutoProgram.BypassLateralBlades := HmiAutoProgram.BypassLateralBlades + 1;
			IF HmiAutoProgram.BypassLateralBlades > 2 THEN
				HmiAutoProgram.BypassLateralBlades := 0;
			END_IF	
			LocalAutoProgram.BypassLateralBlades := HmiAutoProgram.BypassLateralBlades;
		END_IF
		HmiAutoProgram.BypassLateralBlades 	:= LocalAutoProgram.BypassLateralBlades;
 
		// Offset rigth lateral blade for trousers...
		IF HmiAutoProgram.HmiAction = 8 THEN
			HmiAutoProgram.HmiAction := 0;	
			HmiAutoProgram.OffsetBlade := HmiAutoProgram.OffsetBlade + 1; 	
			IF HmiAutoProgram.OffsetBlade > 1 THEN
				HmiAutoProgram.OffsetBlade := 0;
			END_IF	
			//			LocalAutoProgram.OffsetBlade := HmiAutoProgram.OffsetBlade;
		END_IF
		//		HmiAutoProgram.OffsetBlade 	:= LocalAutoProgram.OffsetBlade;
		// Only show if option is on
		//		IF g_HCfg.OffsetBlade THEN
		//			HmiAutoProgram.OffsetBladeRuntime := 0;
		//		ELSE
		HmiAutoProgram.OffsetBladeRuntime := 1;
		//		END_IF

		// Trouser alignment function
		IF HmiAutoProgram.HmiAction = 9 THEN
			HmiAutoProgram.HmiAction := 0;	
			HmiAutoProgram.TrouserAlignment := NOT HmiAutoProgram.TrouserAlignment;
			LocalAutoProgram.TrouserAlignment	:= HmiAutoProgram.TrouserAlignment;
		END_IF
		HmiAutoProgram.TrouserAlignment := LocalAutoProgram.TrouserAlignment;
		// Only show if option is on
		IF g_HCfg.TrouserAlignment THEN
			HmiAutoProgram.TrouserAlignmentRuntime := 0;
		ELSE
			HmiAutoProgram.TrouserAlignmentRuntime := 1;
		END_IF

		IF HmiAutoProgram.HmiAction = 31 THEN
			HmiAutoProgram.HmiAction := 0;	
			HmiAutoProgram.FlapTrousersAlignment := NOT HmiAutoProgram.FlapTrousersAlignment;	
			LocalAutoProgram.FlapTrousersAlignment	:= HmiAutoProgram.FlapTrousersAlignment;	
		END_IF
		IF NOT g_HCfg.FlapTrousers THEN
			LocalAutoProgram.FlapTrousersAlignment	:= FALSE;	
		END_IF
		HmiAutoProgram.FlapTrousersAlignment := LocalAutoProgram.FlapTrousersAlignment;

		IF g_HCfg.FlapTrousers THEN 
			HmiAutoProgram.FlapTrousersAlignmentRuntime := 0;
		ELSE
			HmiAutoProgram.FlapTrousersAlignmentRuntime := 1;
		END_IF
		
		IF HmiAutoProgram.HmiAction = 7 THEN
			HmiAutoProgram.HmiAction := 0;
			HmiAutoProgram.ForceTrouser := HmiAutoProgram.ForceTrouser + 1;
			IF HmiAutoProgram.ForceTrouser > FORCE_TO_PYJAMAS_3 THEN
				HmiAutoProgram.ForceTrouser := 0;
			END_IF	
			LocalAutoProgram.ForceTrouser := HmiAutoProgram.ForceTrouser;
		END_IF 
		HmiAutoProgram.ForceTrouser 	:= LocalAutoProgram.ForceTrouser;

		(* Start Delay air blast hanger opener... *)
		IF HmiAutoProgram.HmiAction = 21 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.DelayTrouserBlast := HmiAutoProgram.DelayTrouserBlast;
		END_IF 
		HmiAutoProgram.DelayTrouserBlast 	:= LocalAutoProgram.DelayTrouserBlast;

		(* On time air blast hanger opener... *)
		IF HmiAutoProgram.HmiAction = 22 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.OnTimeTrouserBlast := HmiAutoProgram.OnTimeTrouserBlast;
		END_IF 
		HmiAutoProgram.OnTimeTrouserBlast 	:= LocalAutoProgram.OnTimeTrouserBlast;

		(* Blow point air blast hanger opener... *)
		IF HmiAutoProgram.HmiAction = 23 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.TrouserBlowPoint := HmiAutoProgram.TrouserBlowPoint;
		END_IF 
		HmiAutoProgram.TrouserBlowPoint 	:= LocalAutoProgram.TrouserBlowPoint;
 
		// Infeed belt start delay 
		IF HmiAutoProgram.HmiAction = 24 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.InFeedBeltStartDelay := HmiAutoProgram.InFeedBeltStartDelay;
		END_IF 
		HmiAutoProgram.InFeedBeltStartDelay 	:= LocalAutoProgram.InFeedBeltStartDelay;
 
		// Infeed belt on time
		IF HmiAutoProgram.HmiAction = 25 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.InFeedBeltOnTime := HmiAutoProgram.InFeedBeltOnTime;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP2 THEN
			HmiAutoProgram.InFeedBeltOnTime 	:= LocalAutoProgram.InFeedBeltOnTime;
		END_IF
 
		// Infeed belt stop delay 
		IF HmiAutoProgram.HmiAction = 26 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.InFeedBeltStopDelay := HmiAutoProgram.InFeedBeltStopDelay;
		END_IF 
		HmiAutoProgram.InFeedBeltStopDelay 	:= LocalAutoProgram.InFeedBeltStopDelay;
	 
		// Infeed belt stop time
		IF HmiAutoProgram.HmiAction = 27 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.InFeedBeltStopTime := HmiAutoProgram.InFeedBeltStopTime;
		END_IF 
		HmiAutoProgram.InFeedBeltStopTime 	:= LocalAutoProgram.InFeedBeltStopTime;

		// Deloader down position
		IF HmiAutoProgram.HmiAction = 51 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.DeloaderDwPos := HmiAutoProgram.DeloaderDwPos;
		END_IF 
		HmiAutoProgram.DeloaderDwPos := LocalAutoProgram.DeloaderDwPos;

		// Hanger speed
		IF HmiAutoProgram.HmiAction = 55 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.SpeedHzHangerBelt := HmiAutoProgram.SpeedHzHangerBelt;
		END_IF 
		HmiAutoProgram.SpeedHzHangerBelt := LocalAutoProgram.SpeedHzHangerBelt;

		// Hanger speed at deloader
		IF HmiAutoProgram.HmiAction = 56 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.SpeedSlowHangerBeltDeloader := HmiAutoProgram.SpeedSlowHangerBeltDeloader;
		END_IF 
		HmiAutoProgram.SpeedSlowHangerBeltDeloader := LocalAutoProgram.SpeedSlowHangerBeltDeloader;

		// Infeed belt stop on Trouser or not
		IF HmiAutoProgram.HmiAction = 28 THEN
			HmiAutoProgram.HmiAction := 0;
			HmiAutoProgram.InFeedStopOnTrousers := HmiAutoProgram.InFeedStopOnTrousers + 1;
			IF HmiAutoProgram.InFeedStopOnTrousers > 2 THEN
				HmiAutoProgram.InFeedStopOnTrousers := 0;
			END_IF		
			LocalAutoProgram.InFeedStopOnTrousers 	:= HmiAutoProgram.InFeedStopOnTrousers;
		END_IF 
		HmiAutoProgram.InFeedStopOnTrousers 	:= LocalAutoProgram.InFeedStopOnTrousers;

		// Vacuum enabled
		IF HmiAutoProgram.HmiAction = 35 THEN
			HmiAutoProgram.HmiAction := 0;
			HmiAutoProgram.VacuumEnabled := NOT HmiAutoProgram.VacuumEnabled;
			LocalAutoProgram.VacuumEnabled := HmiAutoProgram.VacuumEnabled;
		END_IF
		HmiAutoProgram.VacuumEnabled := LocalAutoProgram.VacuumEnabled;

		// Vacuum flap delay on
		IF HmiAutoProgram.HmiAction = 32 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.VacuumFlapDelayOn := HmiAutoProgram.VacuumFlapDelayOn;
		END_IF 
		HmiAutoProgram.VacuumFlapDelayOn := LocalAutoProgram.VacuumFlapDelayOn;

		// Vacuum flap delay off
		IF HmiAutoProgram.HmiAction = 33 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.VacuumFlapDelayOff := HmiAutoProgram.VacuumFlapDelayOff;
		END_IF 
		HmiAutoProgram.VacuumFlapDelayOff := LocalAutoProgram.VacuumFlapDelayOff;

		// Vacuum inlet stop
		IF HmiAutoProgram.HmiAction = 34 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.DelayStopInlet := HmiAutoProgram.DelayStopInlet;
		END_IF 
		HmiAutoProgram.DelayStopInlet 	:= LocalAutoProgram.DelayStopInlet;

		// Stacker outlet index time
		FOR i := 1 TO MAX_NUMBER_OF_STACKERS DO
			HmiAutoProgram.HideIndexingTime[i] := BOOL_TO_UINT(g_HCfg.NumberOfStackers < i);
			IF HmiAutoProgram.HmiAction = 60 + i THEN
				HmiAutoProgram.HmiAction := 0;
				LocalAutoProgram.FullIndexingTime[i] := HmiAutoProgram.FullIndexingTime[i];
			END_IF 
			HmiAutoProgram.FullIndexingTime[i] := LocalAutoProgram.FullIndexingTime[i];
		END_FOR
		
		IF HmiAutoProgram.HmiAction = 80 THEN
			HmiAutoProgram.HmiAction := 0;
			HmiAutoProgram.OutletRuntimeChanged := TRUE;
		END_IF 
			
		// Scroll Auto program from Edit pages..
		IF HmiAutoProgram.HmiAction = 12 THEN
			HmiAutoProgram.HmiAction := 1;
			IF HmiAutoProgram.SelectedAutoProgram < MAX_AUTO_PROGRAM_99 THEN
				HmiAutoProgram.SelectedAutoProgram := HmiAutoProgram.SelectedAutoProgram + 1;
			END_IF	
		END_IF

		// Scroll Auto program from Edit pages..
		IF HmiAutoProgram.HmiAction = 11 THEN
			HmiAutoProgram.HmiAction := 1;
			IF HmiAutoProgram.SelectedAutoProgram > 1 THEN
				HmiAutoProgram.SelectedAutoProgram := HmiAutoProgram.SelectedAutoProgram - 1;
			END_IF	
		END_IF

		IF HmiAutoProgram.HmiAction = 14 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.WaitTimeInlet := HmiAutoProgram.WaitTimeInlet;
		END_IF 
		HmiAutoProgram.WaitTimeInlet 	:= LocalAutoProgram.WaitTimeInlet;

		// Hanger Inlet wait time before Hanger conveyor start at all changed...
		IF HmiAutoProgram.HmiAction = 15 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.SwingDelay := HmiAutoProgram.SwingDelay;
		END_IF 
		HmiAutoProgram.SwingDelay 	:= LocalAutoProgram.SwingDelay;

		(* Operator select trouser or shirt for equal lenght *)
		FOR Index := 1 TO MAX_AUTO_LIST_5 DO
			IF HmiAutoProgram.CmdGarmentSelect[Index] = 1 THEN 
				HmiAutoProgram.CmdGarmentSelect[Index] := 0;
				HmiAutoProgram.Trouser[Index] := HmiAutoProgram.Trouser[Index] + 1;			(* 1 = Shirt, 2 = Trouser 3= Flap Trousers *)
				IF HmiAutoProgram.Trouser[Index] > 3 THEN 
					HmiAutoProgram.Trouser[Index] := 1;
				END_IF	
				LocalAutoProgram.Trouser[Index] := HmiAutoProgram.Trouser[Index];
			END_IF
		END_FOR
	
		// This HMI part does not get executed if recipe pointer is null..
		IF ((g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_MACHINE_AUTOPROGSETUP1) AND 
			(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_MACHINE_AUTOPROGSETUP5)) THEN
			IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
				NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID - 1;
				IF NewPage < PAGE_MACHINE_AUTOPROGSETUP1 THEN
					NewPage := PAGE_MACHINE_AUTOPROGSETUP5;
				END_IF
				StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
				NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID + 1;
				IF NewPage > PAGE_MACHINE_AUTOPROGSETUP5 THEN
					NewPage := PAGE_MACHINE_AUTOPROGSETUP1;
				END_IF
				StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
				g_Core.Services.AutoProg.Interface.isCmdSave := TRUE;
				IF HmiAutoProgram.OutletRuntimeChanged THEN
					g_Core.Services.Machine.Interface.isCmdSave := TRUE;
				END_IF
				HmiAutoProgram.OutletRuntimeChanged := FALSE;
			END_IF
		END_IF

		// -------------------------------------------------------------------------
		// Photocell options
		// -------------------------------------------------------------------------
		// Shirt options
		IF HmiAutoProgram.HmiAction = 110 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhShirt.UseHorizontalRear := NOT HmiAutoProgram.PhShirt.UseHorizontalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhShirt.UseHorizontalRear := LocalAutoProgram.PhShirt.UseHorizontalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 111 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhShirt.TwoVerticalRear := NOT HmiAutoProgram.PhShirt.TwoVerticalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhShirt.TwoVerticalRear := LocalAutoProgram.PhShirt.TwoVerticalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 112 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhShirt.UseHorizontalLead := NOT HmiAutoProgram.PhShirt.UseHorizontalLead;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhShirt.UseHorizontalLead := LocalAutoProgram.PhShirt.UseHorizontalLead;
		END_IF

		// Trouser options
		IF HmiAutoProgram.HmiAction = 113 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhTrousers.UseHorizontalRear := NOT HmiAutoProgram.PhTrousers.UseHorizontalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhTrousers.UseHorizontalRear := LocalAutoProgram.PhTrousers.UseHorizontalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 114 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhTrousers.TwoVerticalRear := NOT HmiAutoProgram.PhTrousers.TwoVerticalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhTrousers.TwoVerticalRear := LocalAutoProgram.PhTrousers.TwoVerticalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 115 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhTrousers.UseHorizontalLead := NOT HmiAutoProgram.PhTrousers.UseHorizontalLead;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhTrousers.UseHorizontalLead := LocalAutoProgram.PhTrousers.UseHorizontalLead;
		END_IF

		// Flap trouser options
		IF HmiAutoProgram.HmiAction = 116 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhFlapTrousers.UseHorizontalRear := NOT HmiAutoProgram.PhFlapTrousers.UseHorizontalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhFlapTrousers.UseHorizontalRear := LocalAutoProgram.PhFlapTrousers.UseHorizontalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 117 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhFlapTrousers.TwoVerticalRear := NOT HmiAutoProgram.PhFlapTrousers.TwoVerticalRear;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhFlapTrousers.TwoVerticalRear := LocalAutoProgram.PhFlapTrousers.TwoVerticalRear;
		END_IF
		IF HmiAutoProgram.HmiAction = 118 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.PhFlapTrousers.UseHorizontalLead := NOT HmiAutoProgram.PhFlapTrousers.UseHorizontalLead;
		END_IF 
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_AUTOPROGSETUP4 THEN
			HmiAutoProgram.PhFlapTrousers.UseHorizontalLead := LocalAutoProgram.PhFlapTrousers.UseHorizontalLead;
		END_IF

		// Deloader Light/Heavy garment mode. Wait up for photocell free.
		IF HmiAutoProgram.HmiAction = 103 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.DeloaderHeavyGarment := NOT HmiAutoProgram.DeloaderHeavyGarment;
		END_IF 
		HmiAutoProgram.DeloaderHeavyGarment := LocalAutoProgram.DeloaderHeavyGarment;

		// Hanger belt quick start. (Enable Fréd.)
		IF HmiAutoProgram.HmiAction = 104 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.HangerBeltQuickStart := NOT HmiAutoProgram.HangerBeltQuickStart;
		END_IF 
		HmiAutoProgram.HangerBeltQuickStart := LocalAutoProgram.HangerBeltQuickStart;

		// -------------------------------------------------------------------------
		// Extreme Heavy Option
		// -------------------------------------------------------------------------
		IF HmiAutoProgram.HmiAction = 100 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.XtremeHeavy := NOT HmiAutoProgram.XtremeHeavy;
		END_IF 
		HmiAutoProgram.XtremeHeavy 	:= LocalAutoProgram.XtremeHeavy;

		IF HmiAutoProgram.HmiAction = 101 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.XtremeRaiseBlades := NOT HmiAutoProgram.XtremeRaiseBlades;
		END_IF 
		HmiAutoProgram.XtremeRaiseBlades 	:= LocalAutoProgram.XtremeRaiseBlades;
		
		IF HmiAutoProgram.HmiAction = 102 THEN
			HmiAutoProgram.HmiAction := 0;
			LocalAutoProgram.XtremeGuideplates := NOT HmiAutoProgram.XtremeGuideplates;
		END_IF
		HmiAutoProgram.XtremeGuideplates := LocalAutoProgram.XtremeGuideplates;

		// ----------------------------------------- Special inlet trouser blow -----------------------------------------

		// TrouserBlowEnable
		IF HmiAutoProgram.HmiAction = 40 THEN
			HmiAutoProgram.HmiAction := 0;	
			HmiAutoProgram.TrouserBlowEnable := NOT HmiAutoProgram.TrouserBlowEnable;
			LocalAutoProgram.TrouserBlowEnable := HmiAutoProgram.TrouserBlowEnable;
		END_IF	
		HmiAutoProgram.TrouserBlowEnable := LocalAutoProgram.TrouserBlowEnable;

		// TrouserBlowAdjust
		IF HmiAutoProgram.HmiAction = 41 THEN
			HmiAutoProgram.HmiAction := 0;	
			LocalAutoProgram.TrouserBlowAdjust := HmiAutoProgram.TrouserBlowAdjust;
		END_IF	
		HmiAutoProgram.TrouserBlowAdjust := LocalAutoProgram.TrouserBlowAdjust;

		// TrouserBlowTimeAdjust
		IF HmiAutoProgram.HmiAction = 42 THEN
			HmiAutoProgram.HmiAction := 0;	
			LocalAutoProgram.TrouserBlowTimeAdjust := HmiAutoProgram.TrouserBlowTimeAdjust;
		END_IF	
		HmiAutoProgram.TrouserBlowTimeAdjust := LocalAutoProgram.TrouserBlowTimeAdjust;

		// TrouserBlowCountAdjust
		IF HmiAutoProgram.HmiAction = 43 THEN
			HmiAutoProgram.HmiAction := 0;	
			LocalAutoProgram.TrouserBlowCountAdjust := HmiAutoProgram.TrouserBlowCountAdjust;
		END_IF	
		HmiAutoProgram.TrouserBlowCountAdjust := LocalAutoProgram.TrouserBlowCountAdjust;

		// TrouserBlowGapAdjust
		IF HmiAutoProgram.HmiAction = 44 THEN
			HmiAutoProgram.HmiAction := 0;	
			LocalAutoProgram.TrouserBlowGapAdjust := HmiAutoProgram.TrouserBlowGapAdjust;
		END_IF	
		HmiAutoProgram.TrouserBlowGapAdjust := LocalAutoProgram.TrouserBlowGapAdjust;

		// ----------------------------------------- \Special inlet trouser blow -----------------------------------------
		// -------------------------------------------------------------------------

		HmiAutoProgram.VacuumRuntime := BOOL_TO_UINT(NOT g_Exists.Vacuum);
		HmiAutoProgram.TrouserBlowRuntime := BOOL_TO_UINT(NOT g_Exists.AirTrouses);
		HmiAutoProgram.FlapTrousersAlignmentRuntime := BOOL_TO_UINT(NOT g_Exists.FlapsLegsDetectionPlate);
 
	ELSE
		OpenPage := TRUE;	
	END_IF


	// -------------------------------------------------------------------------
	(*#####################################*)
	(* Copy data to be showed on main page *)
	(*#####################################*)
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_GENERAL_27) OR (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_OPERATOR_MAIN) THEN
		// Find actual AutoProgram
		LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer);		(* Get the complete Array *)
		IF g_AutoProgram.SelectedAutoProgram <> LastMainAutoProgram THEN
			MainGetAutoProgram ACCESS(g_Core.Services.AutoProg.Runtime.autoprogPointer + (SIZEOF(LocalAutoProgram) * LIMIT(0, (g_AutoProgram.SelectedAutoProgram - 1), MAX_NUMBER_OF_AUTOPROGRAMS)));
			LastMainAutoProgram := g_AutoProgram.SelectedAutoProgram;
		END_IF
		FOR Index := 1 TO MAX_AUTO_LIST_5 DO
			MainAutoProgram.Category[Index]				:= MainGetAutoProgram.Categorys[Index];	
			MainAutoProgram.Lenght[Index]				:= MainGetAutoProgram.LenghtPoints[Index] / 10;
			//MainAutoProgram.Trouser[Index]			:= MainGetAutoProgram.Trouser[Index];
			MainAutoProgram.NameOfAutoProgram			:= MainGetAutoProgram.Name;
			(* Local is zero based... *)
			IF MainAutoProgram.Category[Index] > 0 THEN
				MainAutoProgram.Name[Index]				:= LocalFoldProgram[MainAutoProgram.Category[Index]-1].Name;			
				MainAutoProgram.FoldCombination[Index]	:= LocalFoldProgram[MainAutoProgram.Category[Index]-1].CrossFold.FoldCombination; 
				MainAutoProgram.HideLine[Index]			:= 0;	// Show data fields only if recipe is selected...	
			ELSE
				MainAutoProgram.Name[Index]				:= '';
				MainAutoProgram.FoldCombination[Index]	:= 100;
				MainAutoProgram.HideLine[Index]			:= 1;	// Hide fields...
			END_IF	
		END_FOR	
	
		// Make field grey if password level is not set...
		IF g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 1 THEN
			MainAutoProgram.InputColor := 46;
		ELSE
			MainAutoProgram.InputColor := 253;
		END_IF	

		MainAutoProgram.ShowSelected[1] :=  NOT BOOL_TO_UINT(MainAutoProgram.Category[1] = g_AutoProgram.SelectedProgram);
		MainAutoProgram.ShowSelected[2] :=  NOT BOOL_TO_UINT(MainAutoProgram.Category[2] = g_AutoProgram.SelectedProgram);
		MainAutoProgram.ShowSelected[3] :=  NOT BOOL_TO_UINT(MainAutoProgram.Category[3] = g_AutoProgram.SelectedProgram);
		MainAutoProgram.ShowSelected[4] :=  NOT BOOL_TO_UINT(MainAutoProgram.Category[4] = g_AutoProgram.SelectedProgram);
		MainAutoProgram.ShowSelected[5] :=  NOT BOOL_TO_UINT(MainAutoProgram.Category[5] = g_AutoProgram.SelectedProgram);
	
	END_IF


	//######################
	//Overwrite Autoprogram
	//######################

	IF ((g_HCfg.HangerReading = 8) AND (g_HangerInletProcess.ForcedNoCom = 0) AND (g_HCfg.FeedManual = 0) AND (g_MCfg.Metricon.ComMode < 3)) THEN			
		IF g_AutoProgram.OperatorAutoProgram <> g_AutoProgram.SelectedAutoProgram THEN
			g_HangerInletProcess.AutoProgBackUp	:= g_AutoProgram.SelectedAutoProgram;
			OverwriteAutoprog					:= g_AutoProgram.OperatorAutoProgram;
		END_IF
	ELSIF g_HCfg.HangerReading = 8 AND g_MCfg.Metricon.ComMode = 4 THEN
		IF (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2) THEN
			IF g_AutoProgram.OperatorAutoProgram <> g_AutoProgram.SelectedAutoProgram THEN
				g_HangerInletProcess.AutoProgBackUp	:= g_AutoProgram.SelectedAutoProgram;
				OverwriteAutoprog					:= g_AutoProgram.OperatorAutoProgram;
			END_IF
		ELSIF g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4 THEN
			OverwriteAutoprog 					:= 0;
			g_AutoProgram.SelectedAutoProgram	:= g_AutoProgram.OperatorAutoProgram;
		END_IF
	ELSIF ((g_HCfg.HangerReading <> 8) OR (g_HangerInletProcess.ForcedNoCom > 0)) AND (g_HCfg.FeedManual = 0) THEN
		g_AutoProgram.SelectedAutoProgram	:= g_AutoProgram.OperatorAutoProgram;
		OverwriteAutoprog 					:= 0;
	END_IF

	IF HmiAutoProgram.HmiAction = 29 THEN
		HmiAutoProgram.HmiAction := 40;	
		TestCount[0] := TestCount[0] + 1;
	END_IF	

END_PROGRAM

