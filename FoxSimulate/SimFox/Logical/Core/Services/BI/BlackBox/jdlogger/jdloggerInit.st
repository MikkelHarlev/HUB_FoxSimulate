PROGRAM _INIT
	(*Access setup*)
	IF g_Core.Services.Blackbox.Runtime.initState = RUNTIME THEN
		disable := TRUE;
		RETURN;
	END_IF
	
	GetAdr(ADR(AdrJenViewServerInterface), ADR('g_Core.Services.Blackbox.Runtime.server'));
	IF AdrJenViewServerInterface = 0 THEN
		Error := SERVER_INTERFACE_INIT_FAILURE;
		JenViewServerInterface.Status := Error;
		RETURN;
	END_IF
	
	memset(ADR(CleanRealTimeString),0,SIZEOF(CleanRealTimeString));
	CleanRealTimeString := ' ';
	
	JenViewServerInterface ACCESS AdrJenViewServerInterface;
	
	(*Error from Server or setup exiting...gracefully*)
	IF JenViewServerInterface.Status <> 0 THEN
		Error := SERVER_INIT_FAILURE;
		JenViewServerInterface.Status := Error;
		RETURN;
	END_IF
	
	JenViewSetupCfg ACCESS JenViewServerInterface.Internal.AdrLoggerSetup;
	GetRTInfo.enable := 1;
	GetRTInfo();
	CycleTime := UDINT_TO_REAL(GetRTInfo.cycle_time) / 1000;
	(*Init Addlog FUB*)
	AddToLog_0(AdrArrIdentJenViewLogInit:=JenViewServerInterface.Internal.AdrArrIdentJenViewLogInit, AdrArrJenViewWriteLogVar:=JenViewServerInterface.Internal.AdrArrJenViewWriteLogVar);
	// Adding Wide log support.
	AddToWideLog_0(AdrArrIdentJenViewWideLogInit:=JenViewServerInterface.Internal.AdrArrIdentJenViewWideLogInit, AdrArrJenViewWriteWideLogVar:=JenViewServerInterface.Internal.AdrArrJenViewWriteWideLogVar);
	
	FOR i:= 0 TO JenViewServerInterface.ServersRunning - 1 DO
		(*Allocate memory for pulse logger*)
		JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=SIZEOF(JenViewPulseLogX));
		DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
		ArrAdrJenViewPulseLog[i] := JenViewAllocClearMemPart.mem;
		JenViewPulseLogX ACCESS ArrAdrJenViewPulseLog[i];
		(*Init pulse logger*)
		JenViewPulseLogX(AdrCounterVarName := ADR(JenViewSetupCfg[i].CounterVarName), TimeOut := JenViewSetupCfg[i].PulseLogInterval OR 300);
	
		(*Allocate memory for common data logger*)
		JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(DataLogger) * JenViewSetupCfg[i].ProductionUnits));
		DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
		ArrAdrCommonDataLogger[i] := JenViewAllocClearMemPart.mem;
	
		(*Allocate memory for Flow delay*)
		JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(pTFlowTimeOut) * JenViewSetupCfg[i].ProductionUnits));
		DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
		ArrAdrTFlowTimeOut[i] := JenViewAllocClearMemPart.mem;
	
		(*Allocate memory for Add ons*)
		FOR AddOnNo := 0 TO (SIZEOF(JenViewSetupCfg[i].AddOn) / SIZEOF(JenViewSetupCfg[i].AddOn[0]) -1) DO
			IF (strlen(ADR(JenViewSetupCfg[i].AddOn[AddOnNo].VarName)) > 0) THEN
				JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(pAddOnFub)));
				DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
				JenViewSetupCfg[i].AddOn[AddOnNo].Ident := JenViewAllocClearMemPart.mem;
	
				IF (JenViewSetupCfg[i].AddOn[AddOnNo].Ident > 0) THEN
					pAddOnFub ACCESS JenViewSetupCfg[i].AddOn[AddOnNo].Ident;
					pAddOnFub.Limiter 		:= JenViewSetupCfg[i].AddOn[AddOnNo].Limiter;
					pAddOnFub.Multiplier 	:= JenViewSetupCfg[i].AddOn[AddOnNo].MultiplierValue;
					pAddOnFub.Divider		:= JenViewSetupCfg[i].AddOn[AddOnNo].DividerValue;
					pAddOnFub.MaxValue 		:= JenViewSetupCfg[i].AddOn[AddOnNo].MaxValue;
					pAddOnFub.MinValue 		:= JenViewSetupCfg[i].AddOn[AddOnNo].MinValue;
					pAddOnFub.VarName		:= JenViewSetupCfg[i].AddOn[AddOnNo].VarName;
					pAddOnFub.Type			:= JenViewSetupCfg[i].AddOn[AddOnNo].Type;
					pAddOnFub.TimeOut		:= JenViewSetupCfg[i].AddOn[AddOnNo].TimeOut;
					pAddOnFub.RegType		:= JenViewSetupCfg[i].AddOn[AddOnNo].RegType; 
					pAddOnFub.SubRegType	:= JenViewSetupCfg[i].AddOn[AddOnNo].SubRegType;
					pAddOnFub.SubRegTypeID	:= JenViewSetupCfg[i].AddOn[AddOnNo].SubRegTypeID;
					pAddOnFub.MessageA		:= JenViewSetupCfg[i].AddOn[AddOnNo].MessageA;
					pAddOnFub.Unit			:= JenViewSetupCfg[i].AddOn[AddOnNo].Unit;
					pAddOnFub();
				END_IF
			END_IF
		END_FOR
	
		(*Allocate memory for External power input*)
		IF (strlen(ADR(JenViewSetupCfg[i].ExternalInitVarName)) > 0) THEN
			JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(pExternalPowerInput)));
			DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
			ArrAdrExternalPowerInput[i] := JenViewAllocClearMemPart.mem;
			pExternalPowerInput ACCESS ArrAdrExternalPowerInput[i];
			pExternalPowerInput(AdrInputVarName := ADR(JenViewSetupCfg[i].ExternalInitVarName), AdrCycleCounter := ADR(LocalCycleCounter));
		END_IF
	
		(*Activate Operator login/out delay ?*)
		IF ((JenViewSetupCfg[i].OperatorDelay) AND (strlen(ADR(JenViewSetupCfg[i].CounterVarName)) > 0)) THEN
			JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(pOperatorDelay)));
			DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
			ArrAdrOperatorDelay[i] := JenViewAllocClearMemPart.mem;
			pOperatorDelay ACCESS ArrAdrOperatorDelay[i];
			(*pOperatorDelay(Delay := JenViewSetupCfg[i].OperatorDelay, CounterVarName := JenViewSetupCfg[i].CounterVarName);*)
			pOperatorDelay(AdrCounterVarName := ADR(JenViewSetupCfg[i].CounterVarName));
		END_IF
	
		(*Allocate memory for Tmp realtime counters*)
		JenViewAllocClearMemPart(enable:=1, ident:=JenViewServerInterface.Internal.MemPartIdent, len:=( SIZEOF(pRealTimeTmpLog)*JenViewSetupCfg[i].ProductionUnits));
		DynamicMemoryUsage := JenViewAllocClearMemPart.len + DynamicMemoryUsage;
		ArrAdrRealTimeTmpLog[i] := JenViewAllocClearMemPart.mem;
		memset(ArrAdrRealTimeTmpLog[i],0,JenViewAllocClearMemPart.len);
	
		(*Get list of RunTimeData*)
		IF (strlen(ADR(JenViewSetupCfg[i].RunTimeDataEntry)) > 0) THEN
			GetAdr(ADR(ArrAdrRunTimeDataEntry[i]), ADR(JenViewSetupCfg[i].RunTimeDataEntry));
			IF ArrAdrRunTimeDataEntry[i] = 0 THEN
				Error := RUNTIMEDATA_INIT_FAILURE;
				JenViewServerInterface.Status := Error;
				RETURN;
			END_IF
		END_IF
		(*Get list of RunningStatus*)
		IF (strlen(ADR(JenViewSetupCfg[i].RunningStatus)) > 0) THEN
			GetAdr(ADR(ArrAdrRunningStatus[i]), ADR(JenViewSetupCfg[i].RunningStatus));
			IF ArrAdrRunningStatus[i] = 0 THEN
				Error := RUNNING_STATUS_INIT_FAILURE;
				JenViewServerInterface.Status := Error;
				RETURN;
			END_IF
		END_IF
		(*Get list of EmergencyStatus*)
		IF (strlen(ADR(JenViewSetupCfg[i].EmergencyStatus)) > 0) THEN
			GetAdr(ADR(ArrAdrEmergencyStatus[i]), ADR(JenViewSetupCfg[i].EmergencyStatus));
			IF ArrAdrEmergencyStatus[i] = 0 THEN
				Error := EMERGENCY_STATUS_INIT_FAILURE;
				JenViewServerInterface.Status := Error;
				RETURN;
			END_IF
		END_IF
	
		IF (JenViewSetupCfg[i].Init) THEN
			RInit[i] := JenViewSetupCfg[i].Init;
		END_IF
	
		JenViewSetupCfg[i].AdrDataLogger := ArrAdrCommonDataLogger[i];
	(*
		DataLogger ACCESS ArrAdrCommonDataLogger[i];
		DataLogger.SingleLaneOp := TRUE;
	*)
	END_FOR
	
	(*Laves som FUB?*)
	
	GetAdr(ADR(pGlobalCounter),ADR(JenViewSetupCfg[0].CounterVarName));
	IF (pGlobalCounter = 0) THEN
		Error := COUNTER_INIT_FAILURE;
		JenViewServerInterface.Status := Error;
		RETURN;
	ELSE
		GlobalCounter ACCESS pGlobalCounter;
	END_IF
	
	(*Realtime data*)
	ArrRealTimeExchange ACCESS JenViewServerInterface.Internal.AdrArrRealTimeExchange;
	(*Realtime data*)
	
	(*PermData Object*)
	(*
	Findes object?
		åben hvis det findes.
			Indlæs data
		Opret et hvis ikke.
	*)
	PermDataSize := SIZEOF(PermData);
	DatObjInfo_0(enable:=1, pName:=ADR('BlackBox'));
	IF (DatObjInfo_0.status = doERR_MODULNOTFOUND) THEN
		CreateDataObject := TRUE;
	ELSE (*DataObject findes*)
		IF DatObjInfo_0.len <> SIZEOF(PermData) THEN (*If size if different from the datatyper ie. update delete the old dataobject*)
			DatObjDelete_0(enable:=1, ident:=DatObjInfo_0.ident);
			CreateDataObject := TRUE;
		ELSE
			DatObjRead_0(enable:=1, ident:=DatObjInfo_0.ident, Offset:=0, pDestination:=ADR(PermData), len:=SIZEOF(PermData));
			PermData.Ident := DatObjInfo_0.ident;
		END_IF
	END_IF
	IF CreateDataObject THEN
		DatObjCreate_0(enable:=1, grp:=0, pName:=ADR('BlackBox'), len:=SIZEOF(PermData), MemType:=doSYSROM, Option:=0, pCpyData:=0);
		PermData.Ident := DatObjCreate_0.ident;
	END_IF
	g_Core.Services.Blackbox.Runtime.initState := RUNTIME;
END_PROGRAM

