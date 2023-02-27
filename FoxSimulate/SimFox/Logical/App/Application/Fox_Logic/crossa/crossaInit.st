PROGRAM _INIT
(* init program *)
(* Common settings for the task *)

// To manual force a stop in the take over from lateral fold...
ManualStop := 0;

(* Individual settings for the task *)
g_CrossFoldAProcess.Common.Description 									:= 'CrossA';
InitFoldTask(g_CrossFoldAProcess.Common,g_MachineManager[g_CrossFoldAProcess.Common.MachineManagerIndex]);
END_PROGRAM

