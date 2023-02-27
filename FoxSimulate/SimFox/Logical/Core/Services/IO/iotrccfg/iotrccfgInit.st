	PROGRAM _INIT
	(*	Delete eventually existing old iomap dataobject	*)
	SCREEN_SIZE := 5; (*5= 5.4"screen, 10 =10" screen *)
	SCALE := 0; (*0= ms, 1=t-ticks *)
	//DatObjInfo_0.enable:= 1;
	//DatObjInfo_0.pName:= ADR('iomap_io');
	//DatObjInfo_0();
	//IF (DatObjInfo_0.status = 0) THEN
	//	DatObjDelete_0.enable:=1;
	//	DatObjDelete_0.ident:=DatObjInfo_0.ident;
	//	DatObjDelete_0();
	//END_IF;
	(*	copy xml io map file to data object *)
	AsIOMMCopy_0.enable := 1;
	AsIOMMCopy_0.pModuleName := ADR('iomap');
	AsIOMMCopy_0.pNewModule := ADR('iomap_io');
	AsIOMMCopy_0.memType := 65;
	AsIOMMCopy_0();
	
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
		IoDescLoad_0.pDevice := ADR('configdir');
		IoDescLoad_0.pFileName := ADR('iodescription.csv');
		IoDescLoad_0.pDescString := ADR(IoStatus.IoDescription);
		IoDescLoad_0.SizeDescString := SIZEOF(IoStatus.IoDescription);
	END_IF;
	
	
	(*SizeTrendVarList := SIZEOF(g_IoTrace.TrendVarList.IoName) / SIZEOF(g_IoTrace.TrendVarList.IoName[0]);*)
	
	RTInfo_0.enable := 1;
	RTInfo_0();
	TaskCycleTime := RTInfo_0.cycle_time;
	TaskCycleTime := TaskCycleTime / 1000;
	
	TimePermanentScroll := 500;
	CycleScroll := 10;
	PageSwapDelay := 0;
	
	ReDraw := TRUE;
	GraphAddTimeLine	:= 0;
	GraphSubTimeLine	:= 0;
	GraphCurTimeLine	:= 0;
	GraphTimeOffSet   := 35;
	IF SCREEN_SIZE = 5 THEN
		g_Core.Services.IOTrace.Runtime.numberOfTraceIO := 8;
		GraphXWindowSize  := 250;
		GraphTimeOffSet   := 35;
		GraphCurveHeight  := 10;
		GraphValueHeight  := 7;
		GraphCurveOffSet  := 30;
	ELSE (* Screen size = 10 *)
		g_Core.Services.IOTrace.Runtime.numberOfTraceIO := 8;
		GraphXWindowSize  := 490;
		GraphTimeOffSet   := 35;
		GraphCurveHeight  := 15;
		GraphValueHeight  := 10;
		GraphCurveOffSet  := 40;
	END_IF
	GraphColorBase[0] := 21;
	GraphColorBase[1] := 10;
	GraphColorBase[2] := 0;
	GraphColorBase[3] := 201;
	GraphColorBase[4] := 33;
	GraphColorBase[5] := 57;
	GraphColorBase[6] := 107;
	GraphColorBase[7] := 48;
	GraphColorGrid	  := 253;
	GraphColorBackground := 22;
	GraphColorBorder := 0;
	ZoomFactor 		  		:= 10;
	ZoomFactorString [1] 	:= '1:10';
	ZoomFactorString [2] 	:= '1:5';
	ZoomFactorString [5] 	:= '1:2';
	ZoomFactorString [10]	:= '1:1';
	ZoomFactorString[0] 	:= ZoomFactorString[ZoomFactor];
	PageIoTrcView := LookupPageID(PAGE_TRACEIOGRAPH,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageIoTrcEdit := LookupPageID(PAGE_TRACEIOCONFIG,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);

END_PROGRAM

