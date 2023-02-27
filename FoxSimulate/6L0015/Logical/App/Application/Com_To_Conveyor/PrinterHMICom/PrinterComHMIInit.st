(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: PrinterComHMI
 * File: PrinterComHMIInit.st
 * Author: jspernil
 * Created: September 02, 2009
 ********************************************************************
 * Implementation of program PrinterComHMI
 ********************************************************************)

PROGRAM _INIT

PagePrintCom 							:= LookupPageID(538,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
PageMain 								:= LookupPageID(1,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);



END_PROGRAM

