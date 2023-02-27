(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson	.

Desription:				HMI AND util FOR Printer com...

History:
09-10-08				V1.01.4 PO Nilsson			Added printer LOG button, some bug fixing..
09-09-02				V1.01.3 PO Nilsson			First edition...

---------------------------------------------------------------------------------------*)


PROGRAM _CYCLIC


	g_PrinterComHMI.FolderStatus 			:= g_PrinterCom.FolderStatus;



	//IF g_HMIHandler.CurrentPage = PAGE_PRINTER_COM_542 THEN
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PagePrintCom THEN
		// Key pressed
		IF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 1) THEN
			g_PrinterComHMI.BypassStatus := g_PrinterComHMI.BypassStatus + 1;
			IF g_PrinterComHMI.BypassStatus > 1 THEN
				g_PrinterComHMI.BypassStatus := 0;
			END_IF	
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 2) THEN
			g_RunJenLogStacker := NOT g_RunJenLogStacker;	
			g_PrinterComHMI.LogStatus := g_RunJenLogStacker;	
		END_IF
		//g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed := 0;(* always clear key *)
	END_IF	

	// Main page status icon
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageMain THEN
		IF g_HCfg.PrinterCom = 0 THEN
			g_PrinterComHMI.MainIconState := 0;			(* Do not show icon when no com configured *)
		ELSE
			IF g_PrinterComHMI.CommunicationStatus = 1  THEN
				g_PrinterComHMI.MainIconState := 1;			// Com not OK
			ELSE
				g_PrinterComHMI.MainIconState := 2;			// Com OK
			END_IF		
		END_IF	
	END_IF	


END_PROGRAM




END_PROGRAM
