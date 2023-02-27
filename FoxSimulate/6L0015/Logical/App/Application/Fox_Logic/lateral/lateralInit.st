PROGRAM _INIT
(* init program *)
(* Common settings for the task *)



(* Individual settings for the task *)
g_LateralProcess.Common.Description 									:= 'Lateral';
InitFoldTask(g_LateralProcess.Common,g_MachineManager[g_LateralProcess.Common.MachineManagerIndex]);

MAX_TEMPLATE_SIZE := 5+10+20+40;

DelayFoldbladeBack.CntAdr := ADR(g_MilliSeconds);
DelayFoldbladeBack.Delay := 300;
DelayFoldbladeBack();
FixFoldXAAdjust	:= 100;
END_PROGRAM

