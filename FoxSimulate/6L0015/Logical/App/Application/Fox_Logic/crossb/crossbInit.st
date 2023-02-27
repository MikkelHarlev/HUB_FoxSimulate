PROGRAM _INIT
(* init program *)
(* Common settings for the task *)


(* Individual settings for the task *)
	g_CrossFoldBProcess.Common.Description 									:= 'CrossB';
	InitFoldTask(g_CrossFoldBProcess.Common,g_MachineManager[g_CrossFoldBProcess.Common.MachineManagerIndex]);

	JamTimeGenerel := 5000;
	IBXBFold;

	StopMotor( Cnt1Adr := ADR(g_MilliSeconds), Cnt2Adr := ADR(g_MilliSeconds) );

	CROSSB_EXTRA_REVERSE_TIME := g_MCfg.XFold.CrossBExtraRewerseTime;
	
END_PROGRAM

