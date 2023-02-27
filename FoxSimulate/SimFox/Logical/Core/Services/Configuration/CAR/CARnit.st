PROGRAM _INIT
	//	get task class cycle time for permanent scrolling in parameters	
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	
	memset(ADR(RdyTrue),1,SIZEOF(RdyTrue));
	
	PageCARSelect := LookupPageID(PAGE_CAR_SELECT,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageCAREdit := LookupPageID(PAGE_CAR_CONFIG,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	g_Core.Services.CAR.Runtime.initState := INIT;
	
	IF (g_Core.System.Configuration.isRemotePanelModeEnabled) THEN
		isRemote := TRUE;
	END_IF

	CustInit.Enable := 1;
	CustInit.pDevice := ADR('custart');

	CustInit.pStringArray := ADR(CARHandler[0].Vis.ItemList);
	CustInit.SizeStringArray := SIZEOF(CARHandler[0].Vis.ItemList);
	CustInit.pEntryStruct := ADR(CARHandler[0].Entry);
	CustInit.SizeEntryStruct := SIZEOF(CARHandler[0].Entry);
	CustInit.pListInfoStruct := ADR(CARHandler[0].ListInfo);
	CustInit.SizeListInfoStruct := SIZEOF(CARHandler[0].ListInfo);

	CustInit.ArrayElementTotal := SIZEOF(CARHandler[0].Vis.ItemList) / SIZEOF (CARHandler[0].Vis.ItemList[0]);
	CustInit.ListType := LIST_TYPE_CUSTOMER;
	CustInit();
	
END_PROGRAM
