(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: MiniJenWay
 * File: MiniJenWayInit.st
 * Author: jspernil
 * Created: June 02, 2009
 ********************************************************************
 * Implementation of program MiniJenWay
 ********************************************************************)

PROGRAM _INIT



(* Common settings for the task *)



(* Individual settings for the task *)
g_MiniJenwayProcess.Common.Description 			:= 'Mini Jenway';
InitFoldTask(g_MiniJenwayProcess.Common, g_MachineManager[g_MiniJenwayProcess.Common.MachineManagerIndex]);


END_PROGRAM

