(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: DaylightSaving
 * File: DaylightSavingCyclic.st
 * Author: duem
 * Created: November 19, 2014
 ********************************************************************
 * Implementation of program DaylightSaving
 ********************************************************************)
PROGRAM _INIT
	GUI_ButtonState									:= 0;
	OldGuiButtonState								:= 0;
	InitDone										:= FALSE;
END_PROGRAM


PROGRAM _CYCLIC
	IF NOT(g_Core.System.Runtime.isInitDone) THEN
		RETURN;
	END_IF
	
	IF InitDone = FALSE THEN
		CfgSetDst_0(enable := TRUE, dst := g_Core.Services.System.Runtime.file.DaylightSaving);
			
		IF CfgSetDst_0.status = 0 THEN
			InitDone							:= TRUE;
			GUI_ButtonState									:= g_Core.Services.System.Runtime.file.DaylightSaving;
			OldGuiButtonState								:= g_Core.Services.System.Runtime.file.DaylightSaving;
		END_IF
	ELSE
		IF GUI_ButtonState <> OldGuiButtonState THEN
			CfgSetDst_0(enable := TRUE, dst := GUI_ButtonState);
			
			IF CfgSetDst_0.status = 0 THEN
				OldGuiButtonState								:= GUI_ButtonState;
				g_Core.Services.System.Runtime.file.DaylightSaving		:= GUI_ButtonState;
			END_IF
		END_IF
	END_IF
	
END_PROGRAM
