(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * PROGRAM: XML_HMI_Diag
 * File: XML_HMI_DiagInit.st
 * Author: jspernil
 * Created: June 23, 2009
 ********************************************************************
 * Implementation OF PROGRAM XML_HMI_Diag
 ********************************************************************)

PROGRAM _INIT


	PageXMLDiag 							:= LookupPageID(547,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageMain	 							:= 1; //LookupPageID(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);

	StartUpDelayTOF(IN := TRUE, PT := T#5s);
	
END_PROGRAM

