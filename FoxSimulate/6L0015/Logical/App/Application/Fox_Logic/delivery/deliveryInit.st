PROGRAM _INIT

RInit := 1;

(* init program *)
(* Common settings for the task *)

g_DeliveryProcess.MaxNumberOfLoadPoints			:= (SIZEOF(g_DeliveryProcess.CrossLoadPoint)/SIZEOF(g_DeliveryProcess.CrossLoadPoint[0]))-1;
g_DeliveryProcess.MaxStackIndex					:= (SIZEOF(g_DeliveryProcess.StackData)/SIZEOF(g_DeliveryProcess.StackData[0]))-1;
g_DeliveryProcess.DeliveryBelt.Length			:= (SIZEOF(g_DeliveryProcess.DeliveryBelt.Hook)/SIZEOF(g_DeliveryProcess.DeliveryBelt.Hook[0]))-1;
g_DeliveryProcess.StackData[g_DeliveryProcess.MaxStackIndex]	:= GarbageStackData;

(* Individual settings for the task *)
g_DeliveryProcess.Common.Description 			:= 'Delivery';

InitFoldTask(g_DeliveryProcess.Common,g_MachineManager[g_DeliveryProcess.Common.MachineManagerIndex]);(* init program *)
//g_DeliveryProcess.Common.Motor.RunTime			:= 4500;		// Tematic
g_DeliveryProcess.Common.Motor.RunTime			:= 9000;		// Fox 6 stacker...
g_DeliveryProcess.DeliveryBelt.Motor.RunTime	:= 4500;
FOR i:= 1 TO 20 DO
	g_DeliveryProcess.StackData[i].FoldProgram	:= i;
END_FOR
	HMIHideDelivBelt	:= 1; // hide manual delivRun button
END_PROGRAM

