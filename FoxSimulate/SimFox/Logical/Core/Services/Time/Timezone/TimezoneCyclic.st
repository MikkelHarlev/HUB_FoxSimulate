(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Timezone
 * File: TimezoneCyclic.st
 * Author: duem
 * Created: January 14, 2014
 ********************************************************************
 * Implementation of program Timezone
 ********************************************************************)
PROGRAM _INIT
	GUI_HideLayer 																		:= 1;
	GUI_LoadingHide																	:= 1;
	CfgGetTimeZone_0(enable := 1);
	TimezoneNames;
END_PROGRAM


PROGRAM _CYCLIC
	IF NOT(g_Core.System.Runtime.isInitDone) THEN
		RETURN;
	END_IF
	
	IF InitDoneTimezone = FALSE THEN
		IF g_Core.Services.System.Runtime.file.TimezoneID < 1 THEN
			CfgGetTimeZone_0(enable := 1);
			IF CfgGetTimeZone_0.status = 0 THEN
				g_Core.Services.System.Runtime.file.TimezoneID														:= (CfgGetTimeZone_0.timezoneID/5);
				InitDoneTimezone																			:= TRUE;
			END_IF
		ELSE
			CfgSetTimeZone_0(enable := TRUE, timezoneID := (g_Core.Services.System.Runtime.file.TimezoneID*5));
			IF CfgSetTimeZone_0.status = 0 THEN
				InitDoneTimezone																			:= TRUE;
			END_IF
		END_IF
	END_IF
	
	IF InitDoneTimezone THEN	
		IF GUI_ButtonSetup = 1 THEN
			GUI_ListboxIndex																:= g_Core.Services.System.Runtime.file.TimezoneID-1;
			GUI_HideLayer 																:= 0;
			GUI_ButtonSetup 																:= 0;
		END_IF
	
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> 15 AND GUI_HideLayer = 0) OR (GUI_ButtonCancel = 1 AND GUI_HideLayer = 0) THEN
			GUI_ButtonCancel															:= 0;
			GUI_HideLayer 																:= 1;
		END_IF
		
		IF GUI_ButtonConfirm = 1 THEN
			GUI_LoadingHide																:= 0;
			g_Core.Services.System.Runtime.file.TimezoneID	:= GUI_ListboxIndex+1;
			CfgSetTimeZone_0(enable := TRUE, timezoneID := (g_Core.Services.System.Runtime.file.TimezoneID*5));
			IF CfgSetTimeZone_0.status = 0 THEN
				GUI_ButtonConfirm															:= 0;
				GUI_HideLayer 																:= 1;
				GUI_LoadingHide															:= 1;
			END_IF
		END_IF
		
		IF OldSelectedTimezone <> g_Core.Services.System.Runtime.file.TimezoneID THEN
			OldSelectedTimezone														:= g_Core.Services.System.Runtime.file.TimezoneID;
			GUI_SelectedTimezone													:= Timezone_Names[g_Core.Services.System.Runtime.file.TimezoneID];
		END_IF
		
	END_IF
END_PROGRAM
