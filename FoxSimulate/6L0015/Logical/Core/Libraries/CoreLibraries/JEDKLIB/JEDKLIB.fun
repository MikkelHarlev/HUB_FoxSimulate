
FUNCTION_BLOCK FB_BlowPipe
	VAR_INPUT
		CntNameAdr : UDINT;
		MemNameAdr : UDINT;
		CntOutNameAdr : UDINT;
		Comp : USINT;
		Mode : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Counter : ARRAY[0..6] OF UDINT;
		OnCounter : UDINT;
		ErrorCode : UINT;
		ErrorString : STRING[100];
	END_VAR
	VAR
		CntArray : REFERENCE TO ARRAY[0..6] OF UDINT;
		MemArray : REFERENCE TO ARRAY[0..5] OF Blow_Type;
		CntOutAdr : UDINT;
		Cnt : USINT;
		OutCountIndex : ARRAY[0..6] OF USINT;
		GapCounter : ARRAY[0..6] OF UDINT;
		OnCounterInternal : ARRAY[0..6] OF UDINT;
		pCounter : REFERENCE TO UDINT;
		CntNo : UINT;
		MaxLane : USINT;
		InUse_Function : FB_InUse;
		InUse_Type : InUse_Head_Type;
		MemNo : UINT;
		ModeOld : USINT;
		CntNoIndex : USINT;
		CntType : UDINT;
		CntLen : UDINT;
		CntAdr : UDINT;
		MemType : UDINT;
		MemLen : UDINT;
		MemAdr : UDINT;
		SetCheckDone : ARRAY[0..6] OF BOOL;
		taskNameConcatAdr : UDINT;
		strMemSize : UDINT;
		grp : UINT;
		statusStrMemAlloc : UINT;
		statusStrMemFree : UINT;
		RSet : ARRAY[0..6] OF BOOL;
		oldCntNameAdr : UDINT;
		oldMemNameAdr : UDINT;
		oldCntOutAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Conveyor
	VAR_INPUT
		CntNameAdr : UDINT;
		MemNameAdr : UDINT;
		Comp : USINT;
		Gap : UINT;
		Mode : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Counter : ARRAY[0..6] OF UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		MaxLane : USINT;
		ModeOld : USINT;
		Cnt : USINT;
		CntType : UDINT;
		CntLen : UDINT;
		CntAdr : UDINT;
		CntNo : USINT;
		CntNoIndex : USINT;
		CntArray : REFERENCE TO ARRAY[0..5] OF UDINT;
		MemType : UDINT;
		MemLen : UDINT;
		MemAdr : UDINT;
		MemNo : USINT;
		MemArray : REFERENCE TO ARRAY[0..5] OF Conv_Type;
		TGapSet : ARRAY[0..5] OF UINT;
		TGapReset : ARRAY[0..5] OF UINT;
		SetCheckDone : ARRAY[0..5] OF BOOL;
		ResetCheckDone : ARRAY[0..5] OF BOOL;
		StopCheckDone : ARRAY[0..5] OF BOOL;
		InUse_Type : InUse_Head_Type;
		InUse_Function : FB_InUse;
		taskNameConcatAdr : UDINT;
		strMemSize : UDINT;
		grp : UINT;
		statusStrMemAlloc : UINT;
		statusStrMemFree : UINT;
		oldCntNameAdr : UDINT;
		oldMemNameAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CT290
	VAR_INPUT
		CT290DataAdr : UDINT;
		SerialDataAdr : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : USINT;
		StatusString : STRING[42];
	END_VAR
	VAR
		Init : BOOL;
		CT290 : REFERENCE TO ArcNetCT_Type;
		Serial : REFERENCE TO Serial_Type;
		State : USINT;
		REnable : BOOL;
		TimeOutDelay : TON_10ms;
		LastByte : UINT;
		CheckSum : UINT;
		CheckSumCnt : UINT;
		Cnt : USINT;
		No : USINT;
		Next : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_CustArtFifo
	VAR_INPUT
		Set : BOOL;
		Reset : BOOL;
		RcpNo : USINT;
		CustomerNo : UDINT;
		ArticleNo : UDINT;
		CustomerChange : BOOL;
		RcpText : STRING[32];
		CustomerText : STRING[32];
		ArticleText : STRING[32];
		BatchID : UDINT;
		SourceID : UDINT;
		SpareUDINT1 : UDINT;
		SpareUDINT2 : UDINT;
		SpareUDINT3 : UDINT;
		Delay : UDINT;
		CntAdr : UDINT;
		MemAdr : UDINT;
		Size : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		RcpNoOut : USINT;
		CustomerNoOut : UDINT;
		ArticleNoOut : UDINT;
		CustomerChangeOut : BOOL;
		RcpTextOut : STRING[32];
		CustomerTextOut : STRING[32];
		ArticleTextOut : STRING[32];
		BatchIDOut : UDINT;
		SourceIDOut : UDINT;
		SpareUDINT1Out : UDINT;
		SpareUDINT2Out : UDINT;
		SpareUDINT3Out : UDINT;
		Empty : BOOL;
		Full : BOOL;
		Counter : UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pCounter : REFERENCE TO UDINT;
		MemArray : REFERENCE TO ARRAY[0..254] OF CustArtFifo_Type;
		Elements : USINT;
		Cnt : UINT;
		oldCntAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Delay
	VAR_INPUT
		Set : BOOL;
		Delay : UDINT;
		Comp : UDINT;
		CntAdr : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		Trig : BOOL;
		Counter : UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pCounter : REFERENCE TO UDINT;
		OutCounter : UDINT;
		oldCntAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_DelayOn
	VAR_INPUT
		Set : BOOL;
		Info : UINT;
		Delay : UDINT;
		On : UDINT;
		Comp : UDINT;
		Cnt1Adr : UDINT;
		Cnt2Adr : UDINT;
		RInfo : UINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		RSet : BOOL;
		InfoOut : UINT;
		Counter1 : UDINT;
		Counter2 : UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pCounter1 : REFERENCE TO UDINT;
		pCounter2 : REFERENCE TO UDINT;
		OutCounterInternal : UDINT;
		OnCounterInternal : UDINT;
		oldCnt1Adr : UDINT;
		oldCnt2Adr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_DFiFo
	VAR_INPUT
		Set : BOOL;
		Reset : BOOL;
		Info : UINT;
		Delay : UDINT;
		On : UINT;
		CntAdr : UDINT;
		CntOnAdr : UDINT;
		MemAdr : UDINT;
		Size : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		OutOn : BOOL;
		InfoOut : UINT;
		Empty : BOOL;
		Full : BOOL;
		Counter : UDINT;
		CounterOn : UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pCounter : REFERENCE TO UDINT;
		pCounterOn : REFERENCE TO UDINT;
		MemArray : REFERENCE TO ARRAY[0..254] OF DFifo_Type;
		Elements : USINT;
		Cnt : UINT;
		CntEmpty : UDINT;
		oldCntAdr : UDINT;
		oldCntOnAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_EnCode
	VAR_INPUT
		PassWordAdr : UDINT;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		ErrorString : STRING[16];
	END_VAR
	VAR
		Copy : REFERENCE TO ARRAY[0..3] OF USINT;
		Pass : ARRAY[0..3] OF USINT;
		InitDone : BOOL;
		TLong : REFERENCE TO UDINT;
		TWord : REFERENCE TO ARRAY[0..1] OF UINT;
		TByte : REFERENCE TO ARRAY[0..3] OF USINT;
		b : SINT;
		i : SINT;
		s : SINT;
		oldPassWordAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_FiFo
	VAR_INPUT
		Set : BOOL;
		Get : BOOL;
		Reset : BOOL;
		Info : UINT;
		MemAdr : UDINT;
		Size : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		InfoOut : UINT;
		Empty : BOOL;
		Full : BOOL;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		MemArray : REFERENCE TO ARRAY[0..254] OF UINT;
		Elements : UINT;
		Cnt : UINT;
		oldMemAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Filter
	VAR_INPUT
		In : BOOL;
		FMode : SINT;
		TMode : SINT;
		Filter : UDINT;
		CntAdr : UDINT;
		InitDone : BOOL;
		Out : BOOL; (*TMode dependent output.*)
		OutPosEdge : BOOL; (*Leading edge.*)
		OutNegEdge : BOOL; (*Trailing edge.*)
	END_VAR
	VAR_OUTPUT
		OutF : BOOL; (*Filtered output.*)
		Counter : UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pCounter : REFERENCE TO UDINT;
		LCount : UDINT;
		TCount : UDINT;
		ROut : BOOL;
		RTrig : BOOL;
		oldCntAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Filter_Coupling
	VAR_INPUT
		MemAdr : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		Cnt : USINT;
		MemArray : REFERENCE TO Filter_Coupling_Type;
		oldMemArray : {REDUND_UNREPLICABLE} Filter_Coupling_Type;
		Counter : ARRAY[0..5] OF UDINT;
		LCount : ARRAY[0..5] OF UDINT;
		TCount : ARRAY[0..5] OF UDINT;
		RIn : ARRAY[0..5] OF BOOL;
		In : USINT;
		Out : USINT;
		OutAll : USINT;
		OutSerial : USINT;
		Bin : USINT;
		Ste : USINT;
		Bin1 : USINT;
		Ste1 : USINT;
		Bin2 : USINT;
		Ste2 : USINT;
		Counter_0 : REFERENCE TO UDINT;
		Counter_1 : REFERENCE TO UDINT;
		Counter_2 : REFERENCE TO UDINT;
		Counter_3 : REFERENCE TO UDINT;
		Counter_4 : REFERENCE TO UDINT;
		Counter_5 : REFERENCE TO UDINT;
		Index : USINT;
		IndexTemp : USINT;
		oldMemAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION HEX_TO_UINT : DINT
	VAR_INPUT
		pData : UDINT;
	END_VAR
	VAR
		Convert : REFERENCE TO Convert_Type;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK FB_InUse
	VAR_INPUT
		InUse_Type_Adr : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pInUse_Type : REFERENCE TO InUse_Head_Type;
		Coupling : Filter_Coupling_Type;
		Coupling_Function : FB_Filter_Coupling;
		Counter : UDINT;
		MaxLane : USINT;
		Cnt : USINT;
		La : USINT;
		OldMode : USINT;
		OldCouplingClass : USINT;
		oldInUse_Type_Adr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Jam
	VAR_INPUT
		Enable : USINT;
		Reset : BOOL;
		Start : BOOL;
		Stop : BOOL;
		JamTimeOut : UINT;
		JamTolerence : UINT;
		ResetTimeOut : UINT;
		CntAdr : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Jam : BOOL;
		Status : USINT;
		StatusString : STRING[80];
	END_VAR
	VAR
		Cnt : USINT;
		Counter : REFERENCE TO UDINT;
		JamQeue : ARRAY[0..9] OF UDINT;
		TimeOutCheck : UDINT;
		ResetJam : BOOL;
		ResetTrig : BOOL;
		StatusCnt : USINT;
		JamCnt : USINT;
		oldCntAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_LaneCombination
	VAR_INPUT
		Type_Adr : UDINT;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		LaneCombination_Type : REFERENCE TO LaneCombination_Head_Type;
		Mode : USINT;
		CouplingClass : USINT;
		CouplingClassOld : USINT;
		zzEdge00000 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_LogExport
	VAR_INPUT
		Enable : BOOL;
		pDevice : UDINT;
		pFileName : UDINT;
		cmdSaveLog : USINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		State : USINT;
		fDelete : FileDelete;
		fCreate : FileCreate;
		fWrite : FileWrite;
		fClose : FileClose;
		EntryNo : USINT;
		OffsetLogWrite : UDINT;
		LenAtoi : UINT;
		LenLogWrite : UINT;
		LogString : STRING[80];
		LogEntryType : ERR_xtyp;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MapLaneCombination
	VAR_INPUT
		Map_Type_Adr : UDINT;
		MasterLaneMode : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		pMap_Type : REFERENCE TO MapLaneFunction_Type;
		MasterLaneModeOld : USINT;
		MasterMaxLane : USINT;
		MasterInUse : InUse_Head_Type;
		MasterInUse_Function : FB_InUse;
		oldMap_Type_Adr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_MultiDelay
	VAR_INPUT
		In : BOOL;
		Reset : BOOL;
		Mode : USINT;
		Size : USINT;
		Delay : UINT;
		DelayOff : UINT;
		CntAdr : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		MemArray : ARRAY[0..19] OF MultiDelay_Type;
		Counter : REFERENCE TO UDINT;
		RIn : BOOL;
		Cnt : USINT;
		RReset : BOOL;
		oldCntAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_NFifo
	VAR_INPUT
		NewDataIn : BOOL;
		Reset : BOOL;
		Delay : UDINT;
		pCounter : UDINT;
		pDataIn : UDINT;
		pDataOut : UDINT;
		pDataArray : UDINT;
		DataArraySize : USINT;
		DataTypeSize : UINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		NewDataOut : BOOL;
		ErrorCode : UINT;
		ErrorString : STRING[80];
		Empty : BOOL;
		Full : BOOL;
	END_VAR
	VAR
		Cnt : USINT;
		Counter : REFERENCE TO UDINT;
		DataArrayCounter : ARRAY[0..255] OF UDINT;
		oldpCounter : UDINT;
		oldpDataIn : UDINT;
		oldpDataOut : UDINT;
		oldpDataArray : UDINT;
		oldDataArraySize : UDINT;
		oldDataTypeSize : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Receive_StrobedInfo
	VAR_INPUT
		Mode : USINT;
		TimeScale : USINT;
		pString : UDINT;
		Strobe : BOOL;
		BCD1 : BOOL;
		BCD2 : BOOL;
		BCD4 : BOOL;
		BCD8 : BOOL;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		NewData : BOOL;
		ErrorCode : UINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		State : USINT;
		TimeOutCounter : UINT;
		TimeOut : UINT;
		Counter : USINT;
		ReceiveBuffer : REFERENCE TO ARRAY[0..255] OF USINT;
		Lead : BOOL;
		RStrobe : BOOL;
		oldpString : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Send_StrobedInfo
	VAR_INPUT
		Send : BOOL;
		Mode : USINT;
		TimeScale : USINT;
		pString : UDINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Strobe : BOOL;
		BCD1 : BOOL;
		BCD2 : BOOL;
		BCD4 : BOOL;
		BCD8 : BOOL;
		Ready : BOOL;
		ErrorCode : UINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		SendByte : USINT;
		SendBuffer : REFERENCE TO ARRAY[0..255] OF USINT;
		State : USINT;
		Counter : USINT;
		StrobeCounter : USINT;
		StrobeStart : BOOL;
		oldpString : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Serial_Com
	VAR_INPUT
		Port : STRING[32];
		ComSettings : STRING[42];
		UseExtendedConfig : BOOL;
		config_struct : XOPENCONFIG;
		dInit : BOOL;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		DataAdr : UDINT;
		Status : USINT;
	END_VAR
	VAR
		Serial : Serial_Type;
		State : USINT;
		FRM_xopen_0 : FRM_xopen;
		FRM_close_0 : FRM_close;
		FRM_read_0 : FRM_read;
		FRM_write_0 : FRM_write;
		FRM_rbuf_0 : FRM_rbuf;
		FRM_robuf_0 : FRM_robuf;
		FRM_gbuf_0 : FRM_gbuf;
		IdentFrmOpen : UDINT;
		TimeOutDelay : TON_10ms;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SetReset
	VAR_INPUT
		CntNameAdr : UDINT;
		MemNameAdr : UDINT;
		Comp : USINT;
		Mode : USINT;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		Counter : ARRAY[0..6] OF UDINT;
		ErrorCode : USINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		CntArray : REFERENCE TO ARRAY[0..5] OF UDINT;
		MemArray : REFERENCE TO ARRAY[0..5] OF SetReset_Type;
		Cnt : USINT;
		MaxLane : USINT;
		InUse_Function : FB_InUse;
		InUse_Type : InUse_Head_Type;
		CntNo : UINT;
		MemNo : UINT;
		CntNoIndex : USINT;
		ModeOld : USINT;
		CntType : UDINT;
		CntLen : UDINT;
		CntAdr : UDINT;
		MemType : UDINT;
		MemLen : UDINT;
		MemAdr : UDINT;
		SetCheckDone : ARRAY[0..5] OF BOOL;
		ResetCheckDone : ARRAY[0..5] OF BOOL;
		taskNameConcatAdr : UDINT;
		strMemSize : UDINT;
		grp : UINT;
		statusStrMemAlloc : UINT;
		statusStrMemFree : UINT;
		oldCntNameAdr : UDINT;
		oldMemNameAdr : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_SpeedCalculation
	VAR_INPUT
		Resolution : UINT;
		CyclicTime : REAL;
		WheelCounter : UDINT;
		TimeCounter : UDINT;
		FilterValue : USINT;
		MeasureDif : UDINT;
		MeasureType : USINT;
		OutputUnit : USINT;
		TimeOut : UINT;
	END_VAR
	VAR_OUTPUT
		Speed : UDINT;
		Speed_dMeter_Min : UDINT;
		Speed_dFeet_Min : UDINT;
		Speed_HMI : REAL;
		FeetDisable : USINT;
		MeterDisable : USINT;
		Status : UINT;
	END_VAR
	VAR
		SpeedValues : ARRAY[0..31] OF UDINT;
		Index : USINT;
		TimeDif : UDINT;
		PulseDif : UDINT;
		OldWheelCounter : UDINT;
		SpdCalcDone : BOOL;
		OldTimeCounter : UDINT;
		Counter : UINT;
		OldCount : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK FB_Tag_Read_Write
	VAR_INPUT
		Command : USINT;
		pSerial : UDINT;
		pConfig : UDINT;
		pData : UDINT;
		EnableMetaData : BOOL;
		InitDone : BOOL;
	END_VAR
	VAR_OUTPUT
		ErrorNumber : UINT;
		ErrorString : STRING[80];
	END_VAR
	VAR
		Serial : REFERENCE TO Serial_Type;
		Config : REFERENCE TO Tag_Config_Type;
		Tag : REFERENCE TO TagRW_Type;
		State : USINT;
		Cnt : USINT;
		Length : UINT;
		RxChecksum : USINT;
		TxChecksum : USINT;
		TxSize : USINT;
		ExecutionTime : UDINT;
		Timeout : TON_10ms;
		SubState : USINT;
		oldpSerial : UDINT;
		oldpConfig : UDINT;
		oldpData : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION UINT_TO_HEX : DINT
	VAR_INPUT
		pData : UDINT;
	END_VAR
	VAR
		Convert : REFERENCE TO Convert_Type;
		Temp1 : USINT;
		Temp2 : USINT;
		Cnt : USINT;
	END_VAR
END_FUNCTION
