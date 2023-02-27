	PROGRAM _INIT
	(*	get task class cycle time for permanent scrolling in parameters	*)
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;

	memset(ADR(RdyTrue),1,SIZEOF(RdyTrue));
 	
	PageOPSelect 	:= LookupPageID(PAGE_OP_SELECT,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageOPEdit 		:= LookupPageID(PAGE_OP_EDIT,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	pThis ACCESS ADR(g_Core.Services.Operator);

END_PROGRAM

