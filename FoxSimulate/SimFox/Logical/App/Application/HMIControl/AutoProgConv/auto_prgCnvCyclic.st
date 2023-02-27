PROGRAM _CYCLIC
(* cyclic program *)

(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson

FileName:				Auto_prg.scr

Desription:				Handling of the Auto program for the Fox...

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name of important watch configurations.



History:
15-02-23				V1.05.0		SF 				Old format of AutoProgram not used anymore. This program now only convers old 
													AutoProg.csv -> acfg1.csv.
11-10-18				V1.04.10	WM 				OverallAlighment in AutoProg is removed 
10-12-01				V1.04.9		PO Nilsson		Added a notification layer to the Copy Autoprogram function...
10-11-29				V1.04.8		PO Nilsson		Added SwingDelay to the Autoprogram, delay to stop swing before hanger conveyor...
10-10-05				V1.04.7		PO Nilsson		Bug fix for Long trouser...
10-06-17				V1.04.6		PO Nilsson		Improved Auto program search so if no matching length we match on type only..
10-04-16				V1.04.5		PO Nilsson		More function to Infeed stop, selet on Shirt or Trouser or both...
10-04-13				V1.04.4		PO Nilsson		Infeed stop on trouser or not added in Auto program...	
10-03-19				V1.04.3		PO Nilsson		Fixed InletWaitTime for Fox 600
10-03-18				V1.04.2		PO Nilsson		Enable pajamas at all time...
10-02-22				V1.04.1		PO Nilsson		Overall alignment added.
10-01-26				V1.04.0		PO Nilsson		Added the Wait timer hanger inlet...
													Fixed the copy of auto programs...
10-01-25				V1.03.9		PO Nilsson		New library from BR_SE...
10-01-20				V1.03.8		PO Nilsson		Added the trouser alignment function...
10-01-12				V1.03.7		PO Nilsson		Removed the "Data" member of the g_ACfg. structure has no real use...
													Added HMI function for the Offset balde for lateral...
09-12-10				V1.03.6		PO Nilsson		Secured code when Search does not find a Autoprogram so it set 1 and Found flag..
09-11-24				V1.03.5		PO Nilsson		Added the Stop timers for the Infeed belt...
09-11-23				V1.03.4		PO Nilsson		Pyjamas was added,bug fix..
09-11-19				V1.03.3		PO Nilsson		Made fix so the Autoprogram funcion should alway return atleast 1...	
09-11-16				V1.03.2		PO Nilsson		Create zero file when recipe zero files are created.. Also combi hanger pyjamas opening..
09-09-30				V1.03.1		PO Nilsson		Always assign first Name in first record to make file save work Check why with B&R...
09-09-08				V1.03.0		PO Nilsson		Removed [0..1] records in AutoProgram type
09-08-25				V1.02 		PO Nilsson		Now the main screen show the Auto program from hanger i stf, and list on turn around conveyor data.			
09-08-13				V1.01 		SFX				Allow 3 states in product type detection auto,force trouse and now also force shirt.
09-03-24				V0.01 		PO Nilsson		First edition...
---------------------------------------------------------------------------------------*)
(*########################################*)
(* Check if catgory data pointer is valid *)
(*########################################*)
IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PAGE_MACHINE_GENERAL_27) AND (AutoProgramFile.State = 0) THEN
	RETURN;
END_IF 	
IF (g_OptionsAndConfigInit = FALSE) OR (g_Core.Services.AutoProg.Runtime.autoprogPointer = 0) THEN		(* Check that pointer is bigger then Null *)
	RETURN;									(* Do not run task before pointer is assigned... *)
ELSIF g_Core.Services.AutoProg.Runtime.autoprogPointer = 0 THEN			(* Check that pointer is bigger then Null *)
	RETURN;		(* Can not access LocalAutoProgram before pointer is ok. *)
END_IF

CASE AutoProgramFile.State OF 
	0 : (* Init. Read parameter from file *) 
		AutoProgramFile.HideInfo 								:= 1;
		IF AutoProgramFile.Input.Cmd.Convert > 0 THEN
			AutoProgramFile.Input.Cmd.KeyDownCount			:= AutoProgramFile.Input.Cmd.KeyDownCount + 1;
			IF AutoProgramFile.Input.Cmd.KeyDownCount > 100 THEN
   				AutoProgramFile.State 							:= 10;
				AutoProgramFile.CurrentIndex 					:= 1;
				AutoProgramFile.HideInfo 						:= 0;
				AutoProgramFile.Input.Cmd.Convert				:= 0; 
			END_IF
		ELSE
			AutoProgramFile.Input.Cmd.KeyDownCount				:= 0;
		END_IF
	
	10: (* Link device *) 
    	FB_DevLink.enable 	:= 1; 
        FB_DevLink.pDevice 	:= ADR(AutoProgramFile.Input.Status.DeviceName); 
        FB_DevLink.pParam 	:= ADR(AutoProgramFile.Input.Status.DeviceParameters); 
        FB_DevLink(); 
		AutoProgramFile.Info := 'Reading file..';
        IF (FB_DevLink.status = 0 OR FB_DevLink.status = fiERR_DEVICE_ALREADY_EXIST) THEN 
        	AutoProgramFile.State := 20; 
        ELSIF (FB_DevLink.status <> FUNCTION_BUSY) THEN 
        	AutoProgramFile.State := 910; 
        END_IF 
         
	20:         
    	FB_FileToStruct.EnableChecksum 													:= AutoProgramFile.Input.Status.EnableChecksum; 
        FB_FileToStruct.pDevice 														:= ADR(AutoProgramFile.Input.Status.DeviceName); 
        FB_FileToStruct.pFileName 														:= ADR(AutoProgramFile.Input.Status.FileName); 
		FB_FileToStruct(); 
        IF (FB_FileToStruct.Status = 0) THEN 
			AutoProgramFile.CurrentIndex												:= 1;
        	AutoProgramFile.State 														:= 30; 
		ELSIF (FB_FileToStruct.Status <> FUNCTION_BUSY) THEN 
        	AutoProgramFile.State 														:= 920; 
             ErrorStatus 																:= FB_FileToStruct.Status; 
		ELSIF (FB_FileToStruct.Status = FUNCTION_BUSY) THEN 
			strcpy(ADR(AutoProgramFile.Info),ADR(FB_FileToStruct.FullName));
		END_IF 
                
	30: // Converting
	
		IF g_ACfg[AutoProgramFile.CurrentIndex].Name <> '' THEN // A valid AutoProgram Found
  			LocalAutoProgram ACCESS(g_Core.Services.AutoProg.Runtime.autoprogPointer + (SIZEOF(LocalAutoProgram) * LIMIT(0, (AutoProgramFile.CurrentIndex - 1), MAX_NUMBER_OF_AUTOPROGRAMS)));
			LocalAutoProgram 															:= g_ACfg[AutoProgramFile.CurrentIndex];
		END_IF
		itoa(AutoProgramFile.CurrentIndex,ADR(AutoProgramFile.Info));
		strcat(ADR(AutoProgramFile.Info),ADR(' Converting '));
		strcat(ADR(AutoProgramFile.Info),ADR(g_ACfg[AutoProgramFile.CurrentIndex].Name));
		AutoProgramFile.CurrentIndex 													:= AutoProgramFile.CurrentIndex + 1;
		IF AutoProgramFile.CurrentIndex > MAX_NUMBER_OF_AUTOPROGRAMS THEN
			strcpy(ADR(AutoProgramFile.Info),ADR('Done'));
			g_Core.Services.AutoProg.Interface.isCmdSave 								:= TRUE;
	       	AutoProgramFile.State 														:= 0; 
		END_IF	
		
	(* Error case, what should we do?? *)	
	910,920,940:	
	
		AutoProgramFile.Input.Cmd.Convert												:= 0; 
		AutoProgramFile.State 															:= 0; 
		
END_CASE; 

END_PROGRAM

