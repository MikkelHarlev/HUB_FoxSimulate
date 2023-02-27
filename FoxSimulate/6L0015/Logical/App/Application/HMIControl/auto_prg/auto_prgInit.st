PROGRAM _INIT
(* init program *)
	g_ACfg[0];
	LogBookFlag 						:= 0;
	Count;

	g_AutoProgram.SelectedAutoProgram 	:= 1;

	LocalAutoProgram ACCESS(ADR(g_ACfg[0]));
	MainGetAutoProgram ACCESS(ADR(g_ACfg[0]));
	LocalFoldProgram ACCESS(ADR(g_RCfg[0]));
	
	g_HMIStackCountStr[1] := '0';
	
END_PROGRAM

