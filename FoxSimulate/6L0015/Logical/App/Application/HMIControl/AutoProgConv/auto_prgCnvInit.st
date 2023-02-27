PROGRAM _INIT
(* init program *)

AutoProgramFile.Input.Status.DeviceName 		:= 'AutoProg';
AutoProgramFile.Input.Status.DeviceParameters 	:= '/DEVICE=F:\\Jensen\AutoProgram'; 
AutoProgramFile.Input.Status.FileName			:= 'AutoProg1.csv';	
FB_StructToFile.FullName 						:= 'g_ACfg.';
AutoProgramFile.State 							:= 0; 
AutoProgramFile.HideInfo 						:= 1;
END_PROGRAM

