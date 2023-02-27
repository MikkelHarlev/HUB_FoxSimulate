PROGRAM _CYCLIC
	// cyclic program

	// Show layer
IF EDGEPOS(pThis.Runtime.Select.ShowLayer = 0) AND ShowLayerPage = 0 THEN
	ShowLayerPage := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID;
ELSIF pThis.Runtime.Select.ShowLayer = 0 THEN
	IF ShowLayerPage <> g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID THEN
			pThis.Runtime.Select.Caller := 0;
		ShowLayerPage := 0;
	END_IF
END_IF
	
	
IF pThis.Runtime.Select.Caller > RECIPE_CALLER_NONE_0 THEN
	pThis.Runtime.Select.ShowLayer 				:= 0;
	IF pThis.Runtime.Select.ReturnStatus = SELECT_RECIPE_IDLE_0 THEN
		pThis.Runtime.CategoryList.inxSelectedFoldProgram 	:= pThis.Runtime.Select.DefaultListIndex;
	END_IF
	// Busy
	pThis.Runtime.Select.ReturnStatus 	:= SELECT_RECIPE_BUSY_2;
ELSE
	// Idle
	pThis.Runtime.Select.ReturnStatus 	:= SELECT_RECIPE_IDLE_0;
	pThis.Runtime.Select.ShowLayer 		:= 1;
END_IF

IF pThis.Runtime.Select.ShowLayer = 0 THEN
	// General recepie handling
	IF pThis.Runtime.CategoryList.cmdDown = 1 THEN
		pThis.Runtime.CategoryList.inxSelectedFoldProgram 	:= pThis.Runtime.CategoryList.inxSelectedFoldProgram + 1;
	END_IF
	
	IF pThis.Runtime.CategoryList.cmdUp = 1 AND (pThis.Runtime.CategoryList.inxSelectedFoldProgram > 0) THEN
		pThis.Runtime.CategoryList.inxSelectedFoldProgram 	:= pThis.Runtime.CategoryList.inxSelectedFoldProgram - 1;
	END_IF
		
	IF pThis.Runtime.CategoryList.inxSelectedFoldProgram  = MAXUINT THEN
		pThis.Runtime.CategoryList.inxSelectedFoldProgram  := 0;
	ELSIF pThis.Runtime.CategoryList.inxSelectedFoldProgram  >= pThis.Runtime.CategoryList.MaxFoldPrograms THEN
		pThis.Runtime.CategoryList.inxSelectedFoldProgram  := pThis.Runtime.CategoryList.MaxFoldPrograms-1;
	END_IF
		
	IF pThis.Runtime.CategoryList.cmdNewFoldProgramSelected THEN
		IF (pThis.Runtime.CategoryList.SelectedFoldProgram >= 1) AND (pThis.Runtime.CategoryList.SelectedFoldProgram <= pThis.Runtime.CategoryList.MaxFoldPrograms) THEN
			pThis.Runtime.CategoryList.inxSelectedFoldProgram := pThis.Runtime.CategoryList.SelectedFoldProgram-1;
		END_IF
	END_IF
		
	IF pThis.Runtime.CategoryList.cmdConfirmFoldProgram THEN
		IF pThis.Runtime.CategoryList.inxSelectedFoldProgram < pThis.Runtime.CategoryList.MaxFoldPrograms THEN
			pThis.Runtime.Select.SelectedRecipe := pThis.Runtime.CategoryList.inxSelectedFoldProgram+1;
		END_IF
		pThis.Runtime.CategoryList.cmdConfirmFoldProgram := FALSE;
		pThis.Runtime.Select.ShowLayer 		:= 1;
		pThis.Runtime.Select.ReturnStatus	:= SELECT_RECIPE_DONE_1;
	END_IF
		
	// Just exit out of layer
	IF pThis.Runtime.CategoryList.cmdCancelSelection THEN 
		pThis.Runtime.CategoryList.cmdCancelSelection	:= FALSE;
		pThis.Runtime.Select.Caller 					:= RECIPE_CALLER_NONE_0;
	END_IF
		
	IF pThis.Runtime.CategoryList.cmdDirectFoldProgramSelect = 1 THEN
		IF (pThis.Runtime.CategoryList.ActualFoldProgram > 0) AND (pThis.Runtime.CategoryList.ActualFoldProgram <= pThis.Runtime.CategoryList.MaxFoldPrograms) THEN
			pThis.Runtime.Select.SelectedRecipe						:= pThis.Runtime.CategoryList.ActualFoldProgram;
			pThis.Runtime.CategoryList.inxSelectedFoldProgram 		:= pThis.Runtime.CategoryList.ActualFoldProgram-1;
			pThis.Runtime.CategoryList.cmdDirectFoldProgramSelect 	:= FALSE;
		END_IF
	END_IF
END_IF

END_PROGRAM

