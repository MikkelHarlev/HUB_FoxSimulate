PROGRAM _CYCLIC
(*--------------------------------------------------------------------------
    Author:        Marcial Tschanz
    Filename:      recpedit.src

    Description:   Control OF the foldprograms in the product picture

    References:

    Interfaces:    g_HMI

    Watch Debug:

    History:
	10-08-23		V2.4.8		WM					Add Action "setTo AllRecip" = add a parameter TO all recipes when pressing a button
	10-06-08		V2.04.8		PO Nilsson			Made check on NumberOfProducts in a stack so it can be higher THEN STACK_ITEM_MAX_20.
	10-03-23		V2.04.7		PO Nilsson			Removed MAX_NUMBER_OF_FOLDPROGRAMS...
													Delay RollOff out was NOT visible with the RIGHT option..
	10-03-10		V2.04.6		PO Nilsson			Always show stacker selection...	
	10-02-16		V2.04.5		PO Nilsson			Gap can now NOT be set TO zero / No FUNCTION...
	10-02-08		V2.04.4		PO Nilsson			Removed the MIN/MAX fold distance on XB...
	10-01-23		V2.04.3		PO Nilsson			Only show knife values IF option is set...	
	10-01-20		V2.04.2		PO Nilsson			Changed logic FOR FoldCombination selection, so we only use a couple OF the 16 
													defined folds...
	09-12-09		V2.04.1		PO Nilsson			New format OF CategoryData_Type where Stacker AND StackerBelt is splitted..	
	09-11-17		V2.04.0		PO Nilsson			Stack selection on Outlet, to wich stacker on Manual machines...	
	09-11-10		V2.03.9		PO Nilsson			Cleaned up some variables...
	09-10-28		V2.03.8		PO Nilsson			Multistacker parameters..
	09-10-22		V2.03.7		PO Nilsson			Removed counter wheel TO ProcInit task...
	09-10-21		V2.03.6		PO Nilsson			Changed the mm TO pulse constant from Holbaek	
	09-09-15		V2.03.5		PO Nilsson			Removed "ActualTowelLength" from HMI struct...
	09-09-21		V2.03.4		PO Nilsson			Fixed the Show values FOR Roll Off delay AND Belt distance adjust...
	09-09-15		V2.03.3		PO Nilsson			Rearranged alot FOR the Outlet AND Stacker TO handle multiple stacks...
	09-09-09		V2.03.2		PO Nilsson			Removed Slope down timer from Machine TO Recipe..	
	2009-09-02		V2.03.1		PO Nilsson			XA folddistance changed TO INT TO handle negative values.
	2009-09-01		V2.03 		PO Nilsson			Removed the second gap adjust timers AND settings.
	2009-08-25		V2.02		PO Nilsson			Removed NOT used parts..
    2009-06-24		V2.01.1		SFX/MTS				Possible TO use different paths with different password levels, sync recipe at start up
													Bug fix, keep passwordlevel TO be able TO go back TO password protected
	2009-05-20		V2.01		PO Nilsson			Fox remake started..	
    2009-03-11		V2.00		PO Nilsson			Branched AND adapted TO the Fox...
    2009-03-06		V1.02		PO Nilsson			Bug fix, it was NOT possible TO select recipe via direct number..
    2009-01-22		V1.01.0 	PO Nilsson			Pointer TO recipe AND removed MAX_NUMBER_OF_CATEGORIES calculation..
    												Local copy is replaced with pointer LocalFoldProgram...
    10.10.03       	V1.00.1 	Marcial Tschanz    	First version
----------------------------------------------------------------------------*)


(*#################################*)
(* Variabel to hide not used parts *)
(*#################################*)

	HideNotUsedHmi := 1;

	//####################################################
	// Variable to trigger name change on overview page...
	//####################################################

	TriggerNameChange;

	(*######################*)
	(* Check recipe pointer *)
	(*######################*)

	IF NOT (g_Core.Services.Recipe.Runtime.recipePointer > 0) THEN		(* Check that pointer is bigger then Null *)
		RETURN;									(* Do not run task before pointer is assigned... *)
	END_IF

	(*################################*)
	(* MAIN PAGE RECEPIE  handling    *)
	(*################################*)
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_RECEPIE_MAIN THEN
		
		IF NOT RecipePrgSet AND g_AutoProgram.SelectedProgram > 0 THEN
			FoldProgramList.ActualFoldProgram := g_AutoProgram.SelectedProgram;
			SelectedFoldProgram := g_AutoProgram.SelectedProgram;
		END_IF
		RecipePrgSet := TRUE;

		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			SaveRecepieFlag := TRUE;
		END_IF
		//g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed := 0;(* always clear key *)

		(* Go direct to the Foldprogram with Hotspots *)
		IF KeyFoldPages[1] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_LATERAL,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[1] := 0;
		ELSIF KeyFoldPages[2] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_CROSSFOLD,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[2] := 0;
		ELSIF KeyFoldPages[3] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_STACKER,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[3] := 0;
		ELSIF KeyFoldPages[4] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_OUTLET,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[4] := 0;
		ELSIF KeyFoldPages[7] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_CROSSA,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[7] := 0;
		ELSIF KeyFoldPages[8] = 1 THEN
			StatusSetMenu := CallPageControllerLink(PAGE_RECEPIE_CROSSB,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			KeyFoldPages[8] := 0;						
		END_IF

		(* Go to RCP_LIST  *)
		// := 0;(* always clear key *)

		IF cmdChangeName = 1 THEN
			cmdChangeName := 0;
			NameStringStatus := 8;
		END_IF

		IF cmdCompleteNameChange THEN
			cmdCompleteNameChange := FALSE;
			strcpy(ADR(LocalFoldProgram.Name),ADR(FoldProgramName));
			g_Core.Services.Recipe.Interface.cmdReadRecipeNames := TRUE;
		END_IF
	ELSE
		RecipePrgSet := FALSE;
	END_IF

	(*######################################################*)
	(* Change recipe on all recipe edit screens via layer.. *)
	(*######################################################*)

	(* Show select recipe layer *)
	IF cmdSelectRecipe THEN
		cmdSelectRecipe 		:= FALSE;
		g_UpdateRcpNameList		:= TRUE;		// To trigger a update of the list in rcfg task....
	
		IF g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_IDLE_0 THEN
			g_Core.Services.Recipe.Runtime.Select.Caller 			:= RECIPE_CALLER_EDIT_3;
			g_Core.Services.Recipe.Runtime.Select.DefaultListIndex := SelectedFoldProgram - 1;
		END_IF
	END_IF


	(* Select recipe via direct number *)		(* V1.02 *)
	IF FoldProgramList.cmdDirectFoldProgramSelect = 1 THEN
		IF (FoldProgramList.ActualFoldProgram > 0) AND (FoldProgramList.ActualFoldProgram <= FoldProgramList.MaxFoldPrograms) THEN
			SelectedFoldProgram 						:= FoldProgramList.ActualFoldProgram;
			(*FoldProgramList.inxSelectedFoldProgram 		:= FoldProgramList.ActualFoldProgram-1;*)
		END_IF
		FoldProgramList.cmdDirectFoldProgramSelect := 0;
	END_IF


	(* Select recipe via left arrow *)		(* V1.02 *)
	IF FoldProgramList.cmdDirectFoldProgramSelect = 2 THEN
		IF (SelectedFoldProgram > 1)  THEN
			SelectedFoldProgram := SelectedFoldProgram - 1;
		END_IF
		FoldProgramList.cmdDirectFoldProgramSelect := 0;
	END_IF

	(* Select recipe via right arrow *)		(* V1.02 *)
	IF FoldProgramList.cmdDirectFoldProgramSelect = 3 THEN
		IF (SelectedFoldProgram < 99)  THEN
			SelectedFoldProgram := SelectedFoldProgram + 1;
		END_IF
		FoldProgramList.cmdDirectFoldProgramSelect := 0;
	END_IF


	(*#########################*)
	(* RECEPIE PAGES handling  *)
	(*#########################*)																
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_RECEPIE_MAIN) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_RECEPIE_OUTLET) THEN

		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID - 1;
			IF NewPage < PAGE_RECEPIE_MAIN THEN
				NewPage := PAGE_RECEPIE_OUTLET;
			END_IF
			StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			NewPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID + 1;
			IF NewPage > PAGE_RECEPIE_OUTLET THEN
				NewPage := PAGE_RECEPIE_MAIN;
			END_IF
			StatusSetMenu := CallPageControllerLink(NewPage,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			SaveRecepieFlag := TRUE;
		END_IF

		(* remember password level to be able to go back and change page. All recepie pages can be password leveled *)
		//g_HMIHandler.PassWordTimeOutTimer := getcurtimer();


		(* Ensure a correct fold program is handled *)
		IF SelectedFoldProgram = 0 OR
			SelectedFoldProgram > ElementsInArray THEN
			SelectedFoldProgram := g_Machine.Program;
		END_IF

	END_IF

	(*####################*)
	(* Get recipe pointer *)
	(*####################*)

	IF g_Core.Services.Recipe.Runtime.recipePointer > 0 THEN			(* Check that pointer is bigger then Null *)
		LocalFoldProgram ACCESS(g_Core.Services.Recipe.Runtime.recipePointer + (SIZEOF(LocalFoldProgram) * LIMIT(0, (SelectedFoldProgram-1), MAX_NUMBER_OF_CATEGORIES)));
	END_IF

	IF SaveRecepieFlag THEN
		SaveRecepieFlag 							:= FALSE;
		g_Core.Services.Recipe.Interface.isCmdSave 	:= TRUE;
		g_Core.Services.Recipe.Runtime.recipePointer;
	END_IF 	

	IF SyncRecipe THEN
		SyncRecipe := FALSE;
		//SelectedFoldProgram := g_Machine.Program;	(* This does not work good on the fox sins Auto program... *)
		SelectedFoldProgram := g_AutoProgram.SelectedProgram;
		//SelectedFoldProgram := 1
	END_IF

	(* Select recipe layer is done *)
	IF (g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_DONE_1) AND (g_Core.Services.Recipe.Runtime.Select.Caller = RECIPE_CALLER_EDIT_3) THEN 		(* Done *)
		SelectedFoldProgram 								:= g_Core.Services.Recipe.Runtime.Select.SelectedRecipe;
		g_Core.Services.Recipe.Runtime.Select.Caller 		:= RECIPE_CALLER_NONE_0;
	END_IF
	IF (SelectedFoldProgram < 1) OR (SelectedFoldProgram >MAX_NUMBER_OF_CATEGORIES) THEN
		SelectedFoldProgram := 1;
	END_IF

	FoldProgramName 							:= LocalFoldProgram.Name;
	FoldProgramList.ActualFoldProgram 			:= SelectedFoldProgram;
	FoldProgramList.SelectedFoldProgram 		:= FoldProgramList.inxSelectedFoldProgram + 1;


	(*#########*)
	(* Lateral *)
	(*#########*)

	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID >= PAGE_RECEPIE_LATERAL) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <= PAGE_RECEPIE_OUTLET) THEN

		(* Load in all adapeted values to be shown *)
		(* --------------------------------------- *)

		(*##########################*)
		(* Width - Use direct value *)
		(*##########################*)
	
		IF HMI.LateralWidthFirstCmd > 0 THEN
			HMI.LateralWidthFirstCmd				:= 0;
			LocalFoldProgram.Lateral.WidthFirst 	:= REAL_TO_UINT(HMI.LateralWidthFirst*10) ;
		END_IF
		HMI.LateralWidthFirst := UINT_TO_REAL(LocalFoldProgram.Lateral.WidthFirst)/10;		


		IF HMI.LateralWidthLastCmd > 0 THEN
			HMI.LateralWidthLastCmd 				:= 0;
			LocalFoldProgram.Lateral.WidthLast	 	:= REAL_TO_UINT(HMI.LateralWidthLast*10) ;	(* Just to compile Fox... *)
		END_IF
		HMI.LateralWidthLast := UINT_TO_REAL(LocalFoldProgram.Lateral.WidthLast)/10;			

		(*#####################*)	
		(* Lateral blade times *)
		(*#####################*)	

		// Start delay...
		IF HMI.LateralRightBladeStartCmd > 0 THEN
			HMI.LateralRightBladeStartCmd					:= 0;
			LocalFoldProgram.Lateral.StartDelayRightBlade	:= HMI.LateralRightBladeStartDelay;
		END_IF
		HMI.LateralRightBladeStartDelay := LocalFoldProgram.Lateral.StartDelayRightBlade;		


		// On time...
		IF HMI.LateralRightBladeCmd > 0 THEN
			HMI.LateralRightBladeCmd					:= 0;
			LocalFoldProgram.Lateral.OnTimeRightBlade	:= HMI.LateralRightBladeOnTime;
		END_IF
		HMI.LateralRightBladeOnTime := LocalFoldProgram.Lateral.OnTimeRightBlade;		


		//Start delay
		IF HMI.LateralLeftBladeStartCmd > 0 THEN
			HMI.LateralLeftBladeStartCmd					:= 0;
			LocalFoldProgram.Lateral.StartDelayLeftBlade 	:= HMI.LateralLeftBladeStartDelay;
		END_IF
		HMI.LateralLeftBladeStartDelay := LocalFoldProgram.Lateral.StartDelayLeftBlade;		


		//On time
		IF HMI.LateralLeftBladeCmd > 0 THEN
			HMI.LateralLeftBladeCmd						:= 0;
			LocalFoldProgram.Lateral.OnTimeLeftBlade 	:= (HMI.LateralLeftBladeOnTime);
		END_IF
		HMI.LateralLeftBladeOnTime := (LocalFoldProgram.Lateral.OnTimeLeftBlade);		



		// Blade Back time..
		IF HMI.BladeBackTimeCmd > 0 THEN
			HMI.BladeBackTimeCmd						:= 0;
			LocalFoldProgram.Lateral.BladeBackTime 		:= HMI.LateralBladeBackTime;
		END_IF
		HMI.LateralBladeBackTime := LocalFoldProgram.Lateral.BladeBackTime;		



		(* Fold Mode - Use direct value *)
		(* ---------------------------- *)
		IF HMI.LateralFoldModeCmd > 0 THEN
			HMI.LateralFoldModeCmd 				:= 0;
			LocalFoldProgram.Lateral.FoldMode 	:= LocalFoldProgram.Lateral.FoldMode + 1;
		END_IF
		//IF LocalFoldProgram.Lateral.FoldMode > LATER_FOLD_BOOTH_REAR_BACK_8 THEN
		IF LocalFoldProgram.Lateral.FoldMode > 2 THEN
			LocalFoldProgram.Lateral.FoldMode := 1;
		END_IF
		IF LocalFoldProgram.Lateral.FoldMode < 1 THEN
			LocalFoldProgram.Lateral.FoldMode := 1;
		END_IF	
		HMI.LateralFoldMode:= LocalFoldProgram.Lateral.FoldMode;






		(* Fold distance Lateral XA - Use direct value *)
		(* ----------------------------------- *)
		IF HMI.CrossAFoldDistanceCmd > 0 THEN
			HMI.CrossAFoldDistanceCmd 					:= 0;
			LocalFoldProgram.Lateral.FoldDistance 		:= REAL_TO_INT(HMI.CrossAFoldDistance * 10) ;		
		END_IF
		IF LocalFoldProgram.Lateral.FoldDistance <> 0 THEN
			HMI.CrossAFoldDistance := INT_TO_REAL(LocalFoldProgram.Lateral.FoldDistance) / 10;
		ELSE
			HMI.CrossAFoldDistance := 0;
		END_IF







		(*#####################*)
		(* CrossFold           *)
		(*#####################*)

		(* Load in all adapeted values to be shown *)
		(* --------------------------------------- *)

		//############################################################################	
		//		CASE g_CrossFoldAProcess.CrossParameters.FoldCombination OF
		//		(**)
		//		FOLD_COMB_BYPASS_UP_0,
		//		FOLD_COMB_BYPASS_DOWN_1,
		//		FOLD_COMB_HALFFOLD_B_UP_4,
		//		FOLD_COMB_HALFFOLD_B_DOWN_5:
		//		(**)
		//		FOLD_COMB_HALFFOLD_A_UP_2,
		//		FOLD_COMB_HALFFOLD_A_DOWN_3,
		//		FOLD_COMB_FOURFOLD_INSIDE_10,
		//		FOLD_COMB_FOURFOLD_OUTSIDE_11:
		//		(**)
		//		FOLD_COMB_THIRDFOLD_F_DIRECT_6,
		//		FOLD_COMB_THIRDFOLD_S_REVERSE_9:
		//		(**)	
		//		FOLD_COMB_THIRDFOLD_F_REVERSE_7,
		//		FOLD_COMB_THIRDFOLD_S_DIRECT_8:
		//		(**)
		//		FOLD_COMB_FIX_REAREDGE_INSIDE_12,
		//		FOLD_COMB_FIX_REAREDGE_OUTSID_13:
		//		(**)
		//		FOLD_COMB_FIX_LEADEDGE_INSIDE_14,
		//		FOLD_COMB_FIX_LEADEDGE_OUTSID_15:
		//		(**)
		//		FOLD_COMB_FIX_AB_16:
		//############################################################################	
	

		//############################################################################	
		// Only valid foldes after Bens 10-01-20..
		//
		//	2:
		//	3:
		// 	6: 
		//	7:
		//	10:
		//	11:
		//	14:
		//	15:
		//############################################################################	


	
	
		(* Increase fold combination by Hotspot or Up arrow *)
		IF HMI.CrossFoldModeCmd > 0 THEN
			HMI.CrossFoldModeCmd := 0;
			CASE LocalFoldProgram.CrossFold.FoldCombination OF
				2:	LocalFoldProgram.CrossFold.FoldCombination := 3;
				3:	LocalFoldProgram.CrossFold.FoldCombination := 8;
				8: 	LocalFoldProgram.CrossFold.FoldCombination := 9;
				9:	LocalFoldProgram.CrossFold.FoldCombination := 10;
				10:	LocalFoldProgram.CrossFold.FoldCombination := 11;
				11:	LocalFoldProgram.CrossFold.FoldCombination := 13;
				13: LocalFoldProgram.CrossFold.FoldCombination := 14;	
				14:	LocalFoldProgram.CrossFold.FoldCombination := 2;
		
				ELSE	
					LocalFoldProgram.CrossFold.FoldCombination := 2;
			END_CASE	
		
			//LocalFoldProgram.CrossFold.FoldCombination := LocalFoldProgram.CrossFold.FoldCombination + 1;
			//IF LocalFoldProgram.CrossFold.FoldCombination > 14 THEN
			//	LocalFoldProgram.CrossFold.FoldCombination := 1;
			//END_IF			
		
		END_IF
		HMI.CrossFoldPicture := UINT_TO_SINT(LocalFoldProgram.CrossFold.FoldCombination);


		(* Decrease fold combination by down arrow *)
		IF HMI.CrossFoldModeDecCmd > 0 THEN
			HMI.CrossFoldModeDecCmd := 0;
			CASE LocalFoldProgram.CrossFold.FoldCombination OF
				2:	LocalFoldProgram.CrossFold.FoldCombination := 14;
				3:	LocalFoldProgram.CrossFold.FoldCombination := 2;
				8: 	LocalFoldProgram.CrossFold.FoldCombination := 3;
				9:	LocalFoldProgram.CrossFold.FoldCombination := 8;
				10:	LocalFoldProgram.CrossFold.FoldCombination := 9;
				11:	LocalFoldProgram.CrossFold.FoldCombination := 10;
				13:	LocalFoldProgram.CrossFold.FoldCombination := 11;
				14:	LocalFoldProgram.CrossFold.FoldCombination := 13;
				ELSE	
					LocalFoldProgram.CrossFold.FoldCombination := 2;
			END_CASE	
		
			//LocalFoldProgram.CrossFold.FoldCombination := LocalFoldProgram.CrossFold.FoldCombination - 1;
			//IF LocalFoldProgram.CrossFold.FoldCombination < 1 THEN
			//	LocalFoldProgram.CrossFold.FoldCombination := 14;
			//END_IF			
		
		
		END_IF
		HMI.CrossFoldPicture := UINT_TO_SINT(LocalFoldProgram.CrossFold.FoldCombination);

		#pragma warning(disable: 1281)

		(* Fix dimension rear edge - Use direct value *)
		(* ------------------------------------------ *)
		IF HMI.CrossFixDimRearEdgeCmd > 0 THEN
			HMI.CrossFixDimRearEdgeCmd 					:= 0;
			LocalFoldProgram.CrossFold.FixDimRearEdge 	:= REAL_TO_UINT(HMI.CrossFixDimRearEdge * 10 * g_MCfg.XFold.FixedDimSpeedFactor);
		END_IF
		IF LocalFoldProgram.CrossFold.FixDimRearEdge <> 0 THEN
			HMI.CrossFixDimRearEdge := LocalFoldProgram.CrossFold.FixDimRearEdge * g_MCfg.XFold.FixedDimSpeedFactor / 10;
		ELSE
			HMI.CrossFixDimRearEdge := 0;
		END_IF



		(* Fix dimension lead edge - Use direct value *)
		(* ------------------------------------------ *)
		IF HMI.CrossFixDimLeadEdgeCmd > 0 THEN
			HMI.CrossFixDimLeadEdgeCmd 					:= 0;
			LocalFoldProgram.CrossFold.FixDimLeadEdge 	:= REAL_TO_UINT(HMI.CrossFixDimLeadEdge * 10 * g_MCfg.XFold.FixedDimSpeedFactor);
		END_IF
		IF LocalFoldProgram.CrossFold.FixDimLeadEdge <> 0 THEN
			HMI.CrossFixDimLeadEdge := LocalFoldProgram.CrossFold.FixDimLeadEdge * g_MCfg.XFold.FixedDimSpeedFactor / 10;
		ELSE
			HMI.CrossFixDimLeadEdge := 0;
		END_IF



		(* Show Dim rear or lead if needed *)
		IF (LocalFoldProgram.CrossFold.FoldCombination = 12) OR (LocalFoldProgram.CrossFold.FoldCombination = 13) THEN 		
			HMI.CrossFixDimRuntime					:= 0;
			HMI.CrossFixDimRearEdgeRuntime			:= 0;
			HMI.CrossFixDimLeadEdgeRuntime			:= 1;
		ELSIF (LocalFoldProgram.CrossFold.FoldCombination = 14) OR (LocalFoldProgram.CrossFold.FoldCombination = 15) THEN
			HMI.CrossFixDimRuntime					:= 0;
			HMI.CrossFixDimRearEdgeRuntime			:= 1;
			HMI.CrossFixDimLeadEdgeRuntime			:= 0;
		ELSE
			HMI.CrossFixDimRuntime					:= 1;
			HMI.CrossFixDimRearEdgeRuntime			:= 1;
			HMI.CrossFixDimLeadEdgeRuntime			:= 1;
		END_IF



		(* XA Extra motor time *)
		IF HMI.XAExtraMotorTimeCmd = 1 THEN
			HMI.XAExtraMotorTimeCmd := 0;
			LocalFoldProgram.CrossFold.XAMotorExtraTime := HMI.XAExtraMotorTime;
		END_IF	
		HMI.XAExtraMotorTime := LocalFoldProgram.CrossFold.XAMotorExtraTime;




		(*#####################*)
		(* CrossFold A         *)
		(*#####################*)

		(* Load in all adapeted values to be shown *)
		(* --------------------------------------- *)


		(* Folding Air Knife - Use direct value *)
		(* ------------------------------------ *)
		IF HMI.CrossAFoldDeviceCmd > 0 THEN
			HMI.CrossAFoldDeviceCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.FoldDevice 	:= LocalFoldProgram.CrossFoldA.FoldDevice + 1;
		END_IF
		IF g_HCfg.CrossFoldingKnife THEN	
			IF LocalFoldProgram.CrossFoldA.FoldDevice > FOLD_DEVICE_AIR_KNIFE_2 THEN
				LocalFoldProgram.CrossFoldA.FoldDevice := FOLD_DEVICE_AIR_0;
			END_IF
		ELSE
			LocalFoldProgram.CrossFoldA.FoldDevice := FOLD_DEVICE_AIR_0;
		END_IF	
		(* Do not show 'Knife' if Knife Option is not used *)
		IF LocalFoldProgram.CrossFoldA.FoldDevice <> FOLD_DEVICE_AIR_0 AND g_HCfg.CrossFoldingKnife = 0 THEN
			LocalFoldProgram.CrossFoldA.FoldDevice := FOLD_DEVICE_AIR_0;
		END_IF


		(* Belt Opener Mode - Use direct value *)
		(* ----------------------------------- *)
		IF HMI.CrossABeltOpenerCmd > 0 THEN
			HMI.CrossABeltOpenerCmd 				:= 0;
			LocalFoldProgram.Lateral.BeltAdjust	 	:= LocalFoldProgram.Lateral.BeltAdjust	 + 1;
		END_IF
		IF LocalFoldProgram.Lateral.BeltAdjust > XA_BELT_OPEN_OPEN_4 THEN
			LocalFoldProgram.Lateral.BeltAdjust := XA_BELT_CLOSE_CLOSE_1;
		END_IF

	
		(* Do not show 'Belt Opener' AND 'Opening Time' if SmallOrWide Option is not used *)
		IF g_HCfg.CrossFoldingGapAdjust = 1 THEN
			HMI.CrossASmallOrWideRuntime 		:= 0;							(* visible *)
		ELSE
			HMI.CrossASmallOrWideRuntime 		:= 1;							(* invisible *)
		END_IF

	
		(* Blow time - Use direct value *)
		(* ---------------------------- *)
		IF HMI.CrossABlowTimeCmd > 0 THEN
			HMI.CrossABlowTimeCmd 				:= 0;
			LocalFoldProgram.CrossFoldA.BlowTime := HMI.CrossABlowTime;
		END_IF
		HMI.CrossABlowTime := LocalFoldProgram.CrossFoldA.BlowTime;


		(* Blow time - Use direct value *)
		(* ---------------------------- *)
		IF HMI.CrossABlowDelayCmd > 0 THEN
			HMI.CrossABlowDelayCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.BlowDelay 	:= HMI.CrossABlowDelay;
		END_IF
		HMI.CrossABlowDelay := LocalFoldProgram.CrossFoldA.BlowDelay;

		(* Blow break - Use direct value *)
		(* ----------------------------- *)
		IF HMI.CrossABlowBreakCmd > 0 THEN
			HMI.CrossABlowBreakCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.BlowBreak 	:= HMI.CrossABlowBreak;
		END_IF
		HMI.CrossABlowBreak := LocalFoldProgram.CrossFoldA.BlowBreak;

		(* Blow impulses - Use direct value *)
		(* -------------------------------- *)
		IF HMI.CrossABlowImpulsesCmd > 0 THEN
			HMI.CrossABlowImpulsesCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.BlowImpulses 	:= HMI.CrossABlowImpulses;
		END_IF
		HMI.CrossABlowImpulses := LocalFoldProgram.CrossFoldA.BlowImpulses;

		(* Blow delay, Knife Delay and pulses should not be used according to BW 090107 *)
		(* Fixed by make values invisible and = 0 in HMI. Logic code still handles this if we need to use it anyway *)
		(* SFX 090115 *)
		(* ------------------------------ *)
		LocalFoldProgram.CrossFoldA.BlowBreak 	:= 0;
		LocalFoldProgram.CrossFoldA.BlowDelay 	:= 0;
		LocalFoldProgram.CrossFoldA.BlowImpulses := 0;
		//LocalFoldProgram.CrossFoldA.KnifeDelay 	:= 0;  // Must be used on Fox, no matter what Ben says... POX
		HMI.CrossABlowDelayRuntime := 1;

		(* Knife delay - Use direct value *)
		(* ------------------------------ *)
		IF HMI.CrossAKnifeDelayCmd > 0 THEN
			HMI.CrossAKnifeDelayCmd 				:= 0;
			LocalFoldProgram.CrossFoldA.KnifeDelay 	:= HMI.CrossAKnifeDelay;
		END_IF
		HMI.CrossAKnifeDelay := LocalFoldProgram.CrossFoldA.KnifeDelay;

		(* Do not show 'Knife Delay' AND 'Knife Time' if Knife Option is not used *)
		IF g_HCfg.CrossFoldingKnife = 1 THEN
			HMI.CrossAKnifeRuntime 		:= 0;							(* visible *)
		ELSE
			HMI.CrossAKnifeRuntime 		:= 1;							(* invisible *)
		END_IF

		(* Knife time - Use direct value *)
		(* ----------------------------- *)
		IF HMI.CrossAKnifeTimeCmd > 0 THEN
			HMI.CrossAKnifeTimeCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.KnifeTime 	:= HMI.CrossAKnifeTime;
		END_IF
		HMI.CrossAKnifeTime := LocalFoldProgram.CrossFoldA.KnifeTime;

		(* Belt open time - Use direct value *)
		(* --------------------------------- *)
	
		(* Adjust 1 *)
		IF HMI.CrossABelt1OpenTimeCmd > 0 THEN
			HMI.CrossABelt1OpenTimeCmd 					:= 0;
			LocalFoldProgram.CrossFoldA.Belt1DelayTime	:= HMI.CrossABelt1DelayTime;		
		END_IF
		HMI.CrossABelt1DelayTime	:= LocalFoldProgram.CrossFoldA.Belt1DelayTime;	

	



		(* Visual handling *)
		(* =============== *)

	

		(*#####################*)
		(* CrossFold B *)
		(*#####################*)

		(* Load in all adapeted values to be shown *)
		(* --------------------------------------- *)

		(* Sections values *)
		(* =============== *)

		(* Fold distance XB - Use direct value *)
		(* ----------------------------------- *)
		IF HMI.CrossBFoldDistanceCmd > 0 THEN
			HMI.CrossBFoldDistanceCmd 					:= 0;
			LocalFoldProgram.CrossFoldB.FoldDistance 	:= REAL_TO_INT(HMI.CrossBFoldDistance * 10) ;			(*MTS*)
		END_IF
		IF LocalFoldProgram.CrossFoldB.FoldDistance <> 0 THEN
			HMI.CrossBFoldDistance := INT_TO_REAL(LocalFoldProgram.CrossFoldB.FoldDistance) / 10;
		ELSE
			HMI.CrossBFoldDistance := 0;
		END_IF

		(*MTS*)
		(* Set the min and max value *)
		//	IF LocalFoldProgram.CrossFoldB.FoldDistance < -UINT_TO_INT(g_MCfg.DistanceXB_FoldPoint) THEN
		//		LocalFoldProgram.CrossFoldB.FoldDistance 	:= -UINT_TO_INT(g_MCfg.DistanceXB_FoldPoint);
		//	ELSIF LocalFoldProgram.CrossFoldB.FoldDistance > UINT_TO_INT (g_MCfg.DistanceXB_FoldPoint) THEN
		//		LocalFoldProgram.CrossFoldB.FoldDistance 	:= UINT_TO_INT(g_MCfg.DistanceXB_FoldPoint);
		//	END_IF
		(*MTS*)


		(* Blow time Folding - Use direct value *)
		(* ------------------------------------ *)
		IF HMI.CrossBBlowTimeFoldingCmd > 0 THEN
			HMI.CrossBBlowTimeFoldingCmd 			:= 0;
			LocalFoldProgram.CrossFoldB.BlowTimeFolding 	:= HMI.CrossBBlowTimeFolding;
		END_IF
		HMI.CrossBBlowTimeFolding := LocalFoldProgram.CrossFoldB.BlowTimeFolding;



		(* Slope mode - Use direct value *)
		(* ----------------------------- *)
		IF HMI.CrossBSlopeModeCmd > 0 THEN
			HMI.CrossBSlopeModeCmd 					:= 0;
			LocalFoldProgram.CrossFoldB.SlopeMode 	:= LocalFoldProgram.CrossFoldB.SlopeMode + 1;
		END_IF
		IF LocalFoldProgram.CrossFoldB.SlopeMode > SLOPEMODE_ACTIVE_1 THEN
			LocalFoldProgram.CrossFoldB.SlopeMode := SLOPEMODE_INACTIVE_0;
		END_IF

	


		(* Slope on time - Use direct value *)
		(* -------------------------------- *)
		IF HMI.SlopeOnTimeCmd > 0 THEN
			HMI.SlopeOnTimeCmd 							:= 0;
			LocalFoldProgram.CrossFoldB.SlopeOnTime 	:= HMI.SlopeOnTime;
		END_IF
		HMI.SlopeOnTime := LocalFoldProgram.CrossFoldB.SlopeOnTime;




		(* Blowing -- folding delay - Use direct value *)
		(* ------------------------------------------- *)
		IF HMI.CrossBBlowDelayFoldingCmd > 0 THEN
			HMI.CrossBBlowDelayFoldingCmd 					:= 0;
			LocalFoldProgram.CrossFoldB.BlowDelayFolding 	:= HMI.CrossBBlowDelayFolding;
		END_IF
		HMI.CrossBBlowDelayFolding := LocalFoldProgram.CrossFoldB.BlowDelayFolding;



		(* Blowing -- leading edge -- folding time - Use direct value *)
		(* ---------------------------------------------------------- *)
		IF HMI.CrossBBlowTimeLeadingCmd > 0 THEN
			HMI.CrossBBlowTimeLeadingCmd 				:= 0;
			LocalFoldProgram.CrossFoldB.BlowTimeLeading := HMI.CrossBBlowTimeLeading;
		END_IF
		HMI.CrossBBlowTimeLeading := LocalFoldProgram.CrossFoldB.BlowTimeLeading;



		(* Blowing -- leading edge -- folding delay - Use direct value *)
		(* ----------------------------------------------------------- *)
		IF HMI.CrossBBlowDelayLeadingCmd > 0 THEN
			HMI.CrossBBlowDelayLeadingCmd 					:= 0;
			LocalFoldProgram.CrossFoldB.BlowDelayLeading 	:= HMI.CrossBBlowDelayLeading;
		END_IF
		HMI.CrossBBlowDelayLeading := LocalFoldProgram.CrossFoldB.BlowDelayLeading;



		(* Blowing -- reversing edge -- folding time - Use direct value *)
		(* ------------------------------------------------------------ *)
		IF HMI.CrossBBlowTimeReversingCmd > 0 THEN
			HMI.CrossBBlowTimeReversingCmd 					:= 0;
			LocalFoldProgram.CrossFoldB.BlowTimeReversing 	:= HMI.CrossBBlowTimeReversing;
		END_IF
		HMI.CrossBBlowTimeReversing := LocalFoldProgram.CrossFoldB.BlowTimeReversing;



		(* Blowing -- reversing edge -- folding delay - Use direct value *)
		(* ------------------------------------------------------------- *)
		IF HMI.CrossBBlowDelayReversingCmd > 0 THEN
			HMI.CrossBBlowDelayReversingCmd 				:= 0;
			LocalFoldProgram.CrossFoldB.BlowDelayReversing 	:= HMI.CrossBBlowDelayReversing;
		END_IF
		HMI.CrossBBlowDelayReversing := LocalFoldProgram.CrossFoldB.BlowDelayReversing;





		//#################################
		// Stacker group
		//#################################

		// Arrow buttons for stacker groups	
		IF (HMI.Stacker.OperatorCmd = 1) AND (HMI.Stacker.SelectedStacker < NUMBER_OF_STACKERGROUPS) THEN	
			HMI.Stacker.OperatorCmd := 0;
			HMI.Stacker.SelectedStacker := HMI.Stacker.SelectedStacker + 1; 
		ELSIF (HMI.Stacker.OperatorCmd = 2) AND (HMI.Stacker.SelectedStacker > 1) THEN
			HMI.Stacker.OperatorCmd := 0;
			HMI.Stacker.SelectedStacker := HMI.Stacker.SelectedStacker - 1; 
			// Make check if operator set values direct...
		ELSIF (HMI.Stacker.OperatorCmd = 3) THEN
			HMI.Stacker.OperatorCmd := 0;
			IF (HMI.Stacker.SelectedStacker > NUMBER_OF_STACKERGROUPS) OR (HMI.Stacker.SelectedStacker < 1) THEN
				HMI.Stacker.SelectedStacker := 1; 
			END_IF	
			// Set to 1 if it's 0...
		ELSIF (HMI.Stacker.OperatorCmd = 0) AND (HMI.Stacker.SelectedStacker = 0) THEN	
			HMI.Stacker.SelectedStacker := 1;
		END_IF	
	


		// Air blast startdelay
		//-------------------------
		IF HMI.StackerAirBlastDelayCmd > 0 THEN
			HMI.StackerAirBlastDelayCmd 				:= 0;
			CASE HMI.Stacker.SelectedStacker OF
				1:	LocalFoldProgram.StackerBelt1.AirBlastStartDelay 	:= HMI.StackerAirBlastDelay;
				2:	LocalFoldProgram.StackerBelt2.AirBlastStartDelay 	:= HMI.StackerAirBlastDelay;
				3:	LocalFoldProgram.StackerBelt3.AirBlastStartDelay 	:= HMI.StackerAirBlastDelay;
				4:	LocalFoldProgram.StackerBelt4.AirBlastStartDelay 	:= HMI.StackerAirBlastDelay;
				5:	LocalFoldProgram.StackerBelt5.AirBlastStartDelay 	:= HMI.StackerAirBlastDelay;
			END_CASE	
		END_IF
		CASE HMI.Stacker.SelectedStacker OF
			1: 	HMI.StackerAirBlastDelay := LocalFoldProgram.StackerBelt1.AirBlastStartDelay;
			2: 	HMI.StackerAirBlastDelay := LocalFoldProgram.StackerBelt2.AirBlastStartDelay;
			3: 	HMI.StackerAirBlastDelay := LocalFoldProgram.StackerBelt3.AirBlastStartDelay;
			4: 	HMI.StackerAirBlastDelay := LocalFoldProgram.StackerBelt4.AirBlastStartDelay;
			5: 	HMI.StackerAirBlastDelay := LocalFoldProgram.StackerBelt5.AirBlastStartDelay;
		END_CASE	


		// Air blast Ontime
		//-------------------------
		IF HMI.StackerAirBlastOnTimeCmd > 0 THEN
			HMI.StackerAirBlastOnTimeCmd 				:= 0;
			CASE HMI.Stacker.SelectedStacker OF
				1:	LocalFoldProgram.StackerBelt1.AirBlastOnTime 	:= HMI.StackerAirBlastOnTime;
				2:	LocalFoldProgram.StackerBelt2.AirBlastOnTime 	:= HMI.StackerAirBlastOnTime;
				3:	LocalFoldProgram.StackerBelt3.AirBlastOnTime 	:= HMI.StackerAirBlastOnTime;
				4:	LocalFoldProgram.StackerBelt4.AirBlastOnTime 	:= HMI.StackerAirBlastOnTime;
				5:	LocalFoldProgram.StackerBelt5.AirBlastOnTime 	:= HMI.StackerAirBlastOnTime;
			END_CASE	
		END_IF
		CASE HMI.Stacker.SelectedStacker OF
			1: 	HMI.StackerAirBlastOnTime := LocalFoldProgram.StackerBelt1.AirBlastOnTime;
			2: 	HMI.StackerAirBlastOnTime := LocalFoldProgram.StackerBelt2.AirBlastOnTime;
			3: 	HMI.StackerAirBlastOnTime := LocalFoldProgram.StackerBelt3.AirBlastOnTime;
			4: 	HMI.StackerAirBlastOnTime := LocalFoldProgram.StackerBelt4.AirBlastOnTime;
			5: 	HMI.StackerAirBlastOnTime := LocalFoldProgram.StackerBelt5.AirBlastOnTime;
		END_CASE	

		// Show / Hide Stacker Air blast
		(*IF g_Exists.StackerAir THEN*)
		IF g_HCfg.Micro THEN
			HMI.StackerAirBlastShow := 0;
		ELSE
			HMI.StackerAirBlastShow := 1;
		END_IF	

		//########################
		// Outlet / Stacker part             
		//########################

		// Since Rcp-lib cant handle two dimensioned array we need to make several instances of Stackerbelt code it like this...POX
	
		// Arrow bottons for outlet
		IF (HMI.Outlet.OperatorCmd = 1) AND (HMI.Outlet.SelectedStacker < g_HCfg.NumberOfStackers) THEN		
			HMI.Outlet.OperatorCmd := 0;
			HMI.Outlet.SelectedStacker := HMI.Outlet.SelectedStacker + 1; 
		ELSIF (HMI.Outlet.OperatorCmd = 2) AND (HMI.Outlet.SelectedStacker > 1) THEN
			HMI.Outlet.OperatorCmd := 0;
			HMI.Outlet.SelectedStacker := HMI.Outlet.SelectedStacker - 1; 
			// Make check if operator set values direct...
		ELSIF (HMI.Outlet.OperatorCmd = 3) THEN	
			HMI.Outlet.OperatorCmd := 0;
			IF (HMI.Outlet.SelectedStacker > g_HCfg.NumberOfStackers) OR (HMI.Outlet.SelectedStacker < 1) THEN
				HMI.Outlet.SelectedStacker := 1; 
			END_IF	
			// Set to one if it's 0...	
		ELSIF (HMI.Outlet.OperatorCmd = 0) AND (HMI.Outlet.SelectedStacker = 0) THEN		
			HMI.Outlet.SelectedStacker := 1;
		END_IF	
	


		// calculate to wich stacker in wich stacker group...
		//----------------------------------------------------
		//	StackerGroup 	:= REAL_TO_UINT((HMI.Outlet.SelectedStacker + 1) / 2);			
		//	Stacker			:= HMI.Outlet.SelectedStacker MOD 2;
		//	IF Stacker = 1 THEN		// Make it more compact...
		//		Stacker := 1;
		//	ELSE
		//		Stacker := 2;
		//	END_IF	
	

		// Coupling - Use direct value 
		// --------------------------- 
		//	IF HMI.Stacker.CouplingCmd > 0 THEN	
		//		HMI.Stacker.CouplingCmd 				:= 0;
		//		CASE StackerGroup OF
		//			1: 	LocalFoldProgram.StackerBelt1.Coupling 	:= LocalFoldProgram.StackerBelt1.Coupling + 1;
		//				IF LocalFoldProgram.StackerBelt1.Coupling > 1 THEN
		//					LocalFoldProgram.StackerBelt1.Coupling := 0;
		//				END_IF	
		//			2: 	LocalFoldProgram.StackerBelt2.Coupling 	:= LocalFoldProgram.StackerBelt2.Coupling + 1;
		//				IF LocalFoldProgram.StackerBelt2.Coupling > 1 THEN
		//					LocalFoldProgram.StackerBelt2.Coupling := 0;
		//				END_IF	
		//			3: 	LocalFoldProgram.StackerBelt3.Coupling 	:= LocalFoldProgram.StackerBelt3.Coupling + 1;
		//				IF LocalFoldProgram.StackerBelt3.Coupling > 1 THEN
		//					LocalFoldProgram.StackerBelt3.Coupling := 0;
		//				END_IF	
		//			4: 	LocalFoldProgram.StackerBelt4.Coupling 	:= LocalFoldProgram.StackerBelt4.Coupling + 1;
		//				IF LocalFoldProgram.StackerBelt4.Coupling > 1 THEN
		//					LocalFoldProgram.StackerBelt4.Coupling := 0;
		//				END_IF	
		//			5: 	LocalFoldProgram.StackerBelt5.Coupling 	:= LocalFoldProgram.StackerBelt5.Coupling + 1;
		//				IF LocalFoldProgram.StackerBelt5.Coupling > 1 THEN
		//					LocalFoldProgram.StackerBelt5.Coupling := 0;
		//				END_IF	
		//		END_CASE	
		//	END_IF
		//	// Connection back to HMI
		//	CASE StackerGroup OF
		//		1:	HMI.Stacker.CouplingIndex := LocalFoldProgram.StackerBelt1.Coupling;
		//		2:	HMI.Stacker.CouplingIndex := LocalFoldProgram.StackerBelt2.Coupling;
		//		3:	HMI.Stacker.CouplingIndex := LocalFoldProgram.StackerBelt3.Coupling;
		//		4:	HMI.Stacker.CouplingIndex := LocalFoldProgram.StackerBelt4.Coupling;
		//		5:	HMI.Stacker.CouplingIndex := LocalFoldProgram.StackerBelt5.Coupling;
		//	END_CASE	
		//
		//

		// Edge - Use direct value 
		// ----------------------- 
		IF HMI.Stacker.EdgeCmd > 0 THEN	
			HMI.Stacker.EdgeCmd 				:= 0;
			LocalFoldProgram.Stacker.StopLeadingOrRearEdge			:= NOT LocalFoldProgram.Stacker.StopLeadingOrRearEdge;

		END_IF
		// Connection back to HMI
		HMI.Stacker.EdgeIndex 	:= LocalFoldProgram.Stacker.StopLeadingOrRearEdge;



		// Position - Use direct value 
		// --------------------------- 
		IF HMI.Stacker.StopPositionCmd > 0 THEN	
			HMI.Stacker.StopPositionCmd 				:= 0;
			LocalFoldProgram.Stacker.StopPosition := REAL_TO_UINT(HMI.Stacker.StopPosition * 10);
		END_IF
		// To avoid zero division
		IF LocalFoldProgram.Stacker.StopPosition <> 0 THEN
			HMI.Stacker.StopPosition := LocalFoldProgram.Stacker.StopPosition / 10;
		ELSE
			HMI.Stacker.StopPosition := 0;
		END_IF

		// Jenway destination - Use direct value 
		// ------------------------------------- 
		IF HMI.Stacker.JenWayDestinationCmd > 0 THEN	
			HMI.Stacker.JenWayDestinationCmd 				:= 0;
			LocalFoldProgram.Stacker.JenWayDestination 	:= 	HMI.Stacker.JenWayDestination;
		END_IF
		HMI.Stacker.JenWayDestination := LocalFoldProgram.Stacker.JenWayDestination;
		
	
		// Do not show if Options is not used 
		IF g_HCfg.DeliveryExternalCommunication = 1 THEN
			HMI.StackerJenWayDestinationRuntime	:= 0;
		ELSE
			HMI.StackerJenWayDestinationRuntime	:= 1;
		END_IF


		// Numbers of items in a stack - Use direct value 
		// -------------------------- 
		
		IF HMI.Outlet.NumberOfProductsCmd > 0 THEN	
			HMI.Outlet.NumberOfProductsCmd	:= 0;
			LocalFoldProgram.Outlet.NumberOfProducts 	:= HMI.Outlet.NumberOfProducts;
			// Check limits for NumberOfProducts
			IF LocalFoldProgram.Outlet.NumberOfProducts > STACK_ITEM_MAX_20 THEN
				LocalFoldProgram.Outlet.NumberOfProducts :=  STACK_ITEM_MAX_20;
			END_IF	
			IF LocalFoldProgram.Outlet.NumberOfProducts < 1 THEN
				LocalFoldProgram.Outlet.NumberOfProducts :=  1;
			END_IF		
		END_IF
		HMI.Outlet.NumberOfProducts := LocalFoldProgram.Outlet.NumberOfProducts;

		// Indexing - Use direct value 
		// --------------------------- 
(*		IF HMI.Outlet.FullIndexingTimeCmd > 0 THEN	
			HMI.Outlet.FullIndexingTimeCmd								:= 0;
			LocalFoldProgram.Outlet.FullIndexingTime 	:= HMI.Outlet.FullIndexingTime;
		END_IF
		HMI.Outlet.FullIndexingTime := LocalFoldProgram.Outlet.FullIndexingTime;
*)


		// DELAY: RollOff out - Use direct value 
		// ------------------------------------- 
		IF HMI.Outlet.DelayRollOffOutCmd > 0 THEN	
			HMI.Outlet.DelayRollOffOutCmd	 							:= 0;
			LocalFoldProgram.Outlet.DelayRollOffOut 	:= HMI.Outlet.DelayRollOffOut;
		END_IF
		HMI.Outlet.DelayRollOffOut := LocalFoldProgram.Outlet.DelayRollOffOut;

		// Do not show 'DELAY:RollOff out' if RollOff Options is not used 
		//IF g_HCfg.IndexingConveyorsWithPushOff = 1 THEN
		IF g_HCfg.CrossConveyor >= 1 THEN
			HMI.Outlet.RollOffStackerRuntime	:= 0;		// Show Delay Rolloff out..
		ELSE
			HMI.Outlet.RollOffStackerRuntime	:= 1;		
		END_IF


		// Stacker Selection; to wich stacker on No com machines
		// -------------------------------------------------------- 
		IF HMI.Outlet.StackSelectCmd > 0 THEN	
			HMI.Outlet.StackSelectCmd 				:= 0;
			IF HMI.Outlet.SelectedStack > g_HCfg.NumberOfStackers THEN
				HMI.Outlet.SelectedStack := g_HCfg.NumberOfStackers;
			END_IF	
			IF HMI.Outlet.SelectedStack < 1 THEN
				HMI.Outlet.SelectedStack := 1;
			END_IF	
			LocalFoldProgram.SelectedStack 	:= HMI.Outlet.SelectedStack;
		END_IF
		HMI.Outlet.SelectedStack := LocalFoldProgram.SelectedStack;


		//	IF g_HCfg.HangerReading = 0 THEN		// No hanger reading
		HMI.Outlet.SelectStackVisible := 0;
		//	ELSE
		// 		HMI.Outlet.SelectStackVisible := 1;
		//	END_IF	


		(*#####################*)
		(* General *)
		(*#####################*)

		(* Load in all adapeted values to be shown *)
		(* --------------------------------------- *)
		;

	END_IF

	//V1.12.7
	(*######################*)
	(* set Values to all Recipes *)
	(*######################*)
	SetToAllRecipes;



END_PROGRAM

