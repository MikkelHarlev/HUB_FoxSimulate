PROGRAM _INIT
	(*	Delete eventually existing old iomap dataobject	*)
//	DatObjInfo_0.enable:= 1;
//	DatObjInfo_0.pName:= ADR('iomap_io');
//	DatObjInfo_0();
//	IF (DatObjInfo_0.status = 0) THEN
//		DatObjDelete_0.enable:=1;
//		DatObjDelete_0.ident:=DatObjInfo_0.ident;
//		DatObjDelete_0();
//	END_IF;
//	(*	copy xml io map file to data object *)
//	AsIOMMCopy_0.enable := 1;
//	AsIOMMCopy_0.pModuleName := ADR('iomap');
//	AsIOMMCopy_0.pNewModule := ADR('iomap_io');
//	AsIOMMCopy_0.memType := 2;
//	AsIOMMCopy_0();
	
	IoListInit_0.Enable := 1;
	IoListInit_0.pStateDi := ADR(IoStatus.DigitalStateArray);
	IoListInit_0.pStateDo := ADR(IoStatus.DigitalStateArray);
	IoListInit_0.pStateAi := 0;
	IoListInit_0.pStateAo := 0;
	IoListInit_0.pVisWindow := ADR(IoStatus.IoNameArray);
	IoListInit_0.pVisVarDigitalSet := ADR(IoStatus.DigitalStateSet);
	IoListInit_0.pVisVarAnalogSet := 0;
	IoListInit_0.SizeVisVarDigitalSet := SIZEOF(IoStatus.DigitalStateSet);
	IoListInit_0.SizeVisVarAnalogSet := 0;
	IoListInit_0.SizeVisWindow := SIZEOF(IoStatus.IoNameArray);
	IoListInit_0.LinesVisWindow := SIZEOF(IoStatus.IoNameArray) / SIZEOF(IoStatus.IoNameArray[0]);
	IoListInit_0.LenStateDi := SIZEOF(IoStatus.DigitalStateArray);
	IoListInit_0.LenStateDo := SIZEOF(IoStatus.DigitalStateArray);
	IoListInit_0.LenStateAi := 0;
	IoListInit_0.LenStateAo := 0;
	IoListInit_0.pVisStructIoInfo := ADR(IoStatus.IoInfoStruct);
	IoListInit_0.SizeVisStructIoInfo := SIZEOF (IoStatus.IoInfoStruct);
	IoListInit_0.UseArio := 1;
	IoListInit_0.pDatObjName := ADR('iomap_io');
	IoListInit_0.pVisVarDigitalForce := ADR(IoStatus.DigitalForce);
	IoListInit_0.pVisVarAnalogForce := 0;
	IoListInit_0.SizeVisVarDigitalForce := SIZEOF(IoStatus.DigitalForce);
	IoListInit_0.SizeVisVarAnalogForce := 0;
	IoListInit_0.IgnoreNonExistIo := 0;
	
	IoListInit_0();
	
	IF (IoListInit_0.Status = 0) THEN
		IoListScroll_0.Ident := IoListInit_0.Ident;
		IoListScroll_0.cmdInit := 1;
		IoListScroll_0.Enable := 1;
	
		IoDescLoad_0.Enable := 1;
		IoDescLoad_0.Ident := IoListInit_0.Ident;
		IoDescLoad_0.pDevice := ADR('cfgpar');
		IoDescLoad_0.pFileName := ADR('iodescription.csv');
		IoDescLoad_0.pDescString := ADR(IoStatus.IoDescription);
		IoDescLoad_0.SizeDescString := SIZEOF(IoStatus.IoDescription) - 1;
		IoDescLoad_0();
	END_IF;
	
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	
	TimePermanentScroll := 500;
	oldIoType := IO_LIST_DI_LIST;
	IoStatus.IoType := IO_LIST_DI_LIST;
	
	IoStatus.ColorStateSet:= COLOR_OUTPUT_FIELD;
	CycleScroll := 10;
	SetIoCountDown := 0;
	DoSetValue := 0;
	
	ModuleDescriptionText[0] := 'BusType';
	ModuleDescriptionText[2] := 'Channel #';
	PageIOStatus := LookupPageID(PAGE_SERVICE_DIGITAL,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);

END_PROGRAM