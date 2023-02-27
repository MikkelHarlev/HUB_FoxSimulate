PROGRAM _CYCLIC
(*-----------------------------------------------------------------------------------
	Responsible Person: Peter Hauser

	Project Name: 	JENSEN common HMI Project

	Task Name:		op_pageh.src	CYCLIC PART

	Description: 	This task can be used to manage the page handling in the machine specific operator part
					of the HMI.
					Prepared pages:
					"Machine Main Page" (ID 1) for the connection of the machine specific part to the
					"System Login Page" (ID 98) (last operator page before the system pages).
					"System Login Page" (ID 98) for labeling the buttons and the connection back to the
					"Machine Main Page".

					Additional pages can be inserted by the user.
					For this purpose the page ID, the page specific actions and the connection to other pages
					must be inserted in the case-statement.

					If this task is not used the connection beween the "Machine Main Page" and the
					"System Login Page" and the labeling of the buttons must be done by the machine
					programmer!


	References:  	Interface of the task: OpPageh of op_pageh_type as global variable

	Libraries:		JenPanel	minimum V2.01

	History:
	09-10-28		V1.07.2			PO Nilsson			Multi stacker needed larger array on some variables...
	09-06-24		V1.07.1 		SF					Only show PW-icon if menu is pw-protected
	09-05-27		V1.07			PO Nilsson			Added parts from Tematic to Fox...	
	09-03-06		V1.05			PO Nilsson			Bug fix, it was not possible to select recipe via direct number...
	09-03-03		V1.04			SF      			Adjusted customer article name max size to fit on screen
	09-02-13		V1.03			PO Nilsson			Added the Select recipe layer instead of separate pages...
	2009-01-28		V1.02			PO Nilsson			Customer Article text from Master communication...
	2009-01-22		V1.01			PO Nilsson			Pointer for recipe, removed MAX_NOMBER_OF_CATEGORIES calculation..
	28.05.2004		V1.00			Peter Hauser		created
-----------------------------------------------------------------------------------*)

(* Assign actions to the buttons depending on the page *)
	IF NOT g_OptionsAndConfigInit THEN
		RETURN;
	END_IF 	
	
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_MAIN_1 THEN
		(* Show recipe select layer *)
		IF cmdChangeRecipe THEN
			cmdChangeRecipe := FALSE;
			IF g_Core.Services.Recipe.Runtime.Select.ReturnStatus = SELECT_RECIPE_IDLE_0 THEN
				g_Core.Services.Recipe.Runtime.Select.Caller := RECIPE_CALLER_MACHINE_1;
				g_Core.Services.Recipe.Runtime.Select.DefaultListIndex := g_Machine.Program - 1;
			END_IF
		END_IF
		
		IF cmdCustomPage THEN
			StatusSetMenu := CallPageControllerLink(PAGE_CUSTOMER_SELECT_51,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			cmdCustomPage := FALSE;
		END_IF
		IF cmdOperatorPage THEN 
			StatusSetMenu := CallPageControllerLink(PAGE_OPERATOR_SELECT_53,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			cmdOperatorPage := FALSE;
		END_IF
		IF cmdMachinePage THEN
			StatusSetMenu := CallPageControllerLink(PAGE_MACHINE_SERVICE,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
			cmdMachinePage := FALSE;
		END_IF
	END_IF

	IF g_Core.System.Interface.isOperatorEnabled THEN
		IF g_Core.Services.Operator.Runtime.No[0].Number > 0 THEN
			g_OperatorIcon := 1;
		ELSE
			g_OperatorIcon := 0;
		END_IF
		HideOperator := 0;
	ELSE
		HideOperator := 1;
	END_IF	

	IF g_Core.System.Interface.isCustomerEnabled THEN
		strcpy(ADR(tmpstr),ADR(g_Core.Services.CAR.Runtime.No[0].CustomerName));
		IF g_Core.Services.CAR.Runtime.No[0].ArticleNumber > 0 THEN
			strcat(ADR(tmpstr),ADR('/'));
			strcat(ADR(tmpstr),ADR(g_Core.Services.CAR.Runtime.No[0].ArticleName));
		END_IF
		tmpstr[NAMELENGTH] := 0; // force length of tmpstr to fit g_CustomerArticleName
		strcpy(ADR(g_CustomerArticleName),ADR(tmpstr));
		HideCurtArtField := 0;
	ELSE
		HideCurtArtField := 1;
	END_IF
		
	isLoginGotoMachinePage := g_HCfg.LoginGotoMachinePage;
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 1) AND isLoginGotoMachinePage THEN
		StatusSetMenu := CallPageControllerLink(PAGE_MACHINE_GENERAL_27, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	END_IF
	
END_PROGRAM