PROGRAM _INIT
(* init program *)
(* Common settings for the task *)


g_StackerProcess[1].Common.Description 			:= 'Stack group 1';		// Make this in the for loop aswell...	
g_StackerProcess[2].Common.Description 			:= 'Stack group 2';		
g_StackerProcess[3].Common.Description 			:= 'Stack group 3';		
g_StackerProcess[4].Common.Description 			:= 'Stack group 4';		
g_StackerProcess[5].Common.Description 			:= 'Stack group 5';		

FOR StackerGroup := 1 TO NUMBER_OF_STACKERGROUPS DO
	InitFoldTask(g_StackerProcess[StackerGroup].Common,g_MachineManager[g_StackerProcess[StackerGroup].Common.MachineManagerIndex]);
END_FOR	



END_PROGRAM

