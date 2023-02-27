
FUNCTION_BLOCK AddToWideLog
	VAR_INPUT
		AdrArrIdentJenViewWideLogInit : UDINT; (*Controll*)
		AdrArrJenViewWriteWideLogVar : UDINT; (*Controll*)
		ServerNo : USINT; (*Controll*)
		Setup : BOOL; (*Controll*)
		OverWriteTimeStamp : BOOL; (*Controll*)
		Data : JDWideLog_Type; (*Input Data*)
	END_VAR
	VAR_OUTPUT
		Status : UINT; (*Controll*)
	END_VAR
	VAR
		InternalTimer : DTGetTime; (*Controll*)
		JenViewWideLogWrite : LogWrite; (*Controll*)
		InitDone : BOOL; (*Controll*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION SecToText : USINT
	VAR_INPUT
		Seconds : UDINT;
		AdrText : UDINT;
		isCompressed : BOOL;
	END_VAR
END_FUNCTION

FUNCTION GetAdr : UDINT
	VAR_INPUT
		DestAdr : UDINT;
		AdrVarName : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK AddToLog
	VAR_INPUT
		AdrArrIdentJenViewLogInit : UDINT;
		AdrArrJenViewWriteLogVar : UDINT;
		ServerNo : USINT;
		Setup : BOOL;
		Mode : USINT;
		ValueID : USINT;
		Value : UDINT;
		TimeStamp : DATE_AND_TIME;
		Info : UDINT;
		OverWriteTimeStamp : BOOL;
		MessageA : STRING[40];
		MessageB : STRING[40];
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		InternalTimer : DTGetTime;
		JenViewLogWrite : LogWrite;
		InitDone : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK PulseLog
	VAR_INPUT
		Run : BOOL;
		Reset : BOOL;
		ForceOut : BOOL;
		TimeOut : UINT;
		AdrCounterVarName : UDINT;
	END_VAR
	VAR_OUTPUT
		PulseCount : UDINT;
		Out : BOOL;
	END_VAR
	VAR
		InitDone : BOOL;
		Timer : UDINT;
		InternalCount : UDINT;
		Status : UINT;
		MemAdrWheelCounter : UDINT;
		WheelCounterLen : UDINT;
		CycleTime : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK LogData
	VAR_INPUT
		Type : USINT;
		Lane : USINT;
		Info1 : UDINT;
		Info2 : UDINT;
		Info3 : UDINT;
		Info4 : UDINT;
		MessageA : UDINT;
		MessageB : UDINT;
	END_VAR
	VAR_OUTPUT
		StatusString : STRING[32];
		Status : UINT;
		AdrJenViewServerInterface : UDINT;
	END_VAR
	VAR
		InitDone : BOOL;
		LoggerAdr : UDINT;
		Operators : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION AddCountToLog : DINT
	VAR_INPUT
		AdrDataElement : UDINT;
	END_VAR
END_FUNCTION

FUNCTION Random : INT
	VAR_INPUT
		Seed : UINT;
	END_VAR
END_FUNCTION

FUNCTION GetData : UDINT
	VAR_INPUT
		ServerNo : USINT;
		Type : USINT;
		Lane : USINT;
		Ident : UDINT;
	END_VAR
END_FUNCTION

FUNCTION ScrollText : DINT
	VAR_INPUT
		AdrText : UDINT;
	END_VAR
END_FUNCTION

FUNCTION StrCatNum : BOOL
	VAR_INPUT
		pOutputString : UDINT;
		Count : USINT;
		pInputString : UDINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK JenDataServer
	VAR_INPUT
		InterfaceIdent : UDINT;
		JenViewWriteWideLogVar : ARRAY[0..4] OF JDWideLog_Type;
		JenViewWriteLogVar : ARRAY[0..4] OF JDLog_Type;
		adrWideBufferIdents : ARRAY[0..4] OF UDINT;
		JenViewCommandStruct : ARRAY[0..4] OF JenLogging_Type;
		RealTime0 : ARRAY[0..39] OF RealTimeElement_Type;
		RealTime1 : ARRAY[0..39] OF RealTimeElement_Type;
		RealTime2 : ARRAY[0..39] OF RealTimeElement_Type;
		RealTime3 : ARRAY[0..39] OF RealTimeElement_Type;
		RealTime4 : ARRAY[0..39] OF RealTimeElement_Type;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
	END_VAR
	VAR
		Ident : UDINT;
		JenViewReadLog : ARRAY[0..4] OF ReadLogVar10_Type;
	END_VAR
	VAR_INPUT
		isSQLEnabled : BOOL;
		isXMLRPCEnabled : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK AddToRealTime
	VAR_INPUT
		pText : UDINT;
		Displacement : USINT;
		RealTimeIdent : UDINT;
		DataText : UDINT;
		DataNo : UDINT;
		Init : BOOL;
	END_VAR
	VAR_OUTPUT
		StatusString : STRING[32];
		Status : USINT;
	END_VAR
	VAR
		Iter : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK JDDelay
	VAR_INPUT
		Set : BOOL;
		Delay : UDINT;
		CntAdr : UDINT;
		Comp : UDINT;
	END_VAR
	VAR_OUTPUT
		ErrorCode : USINT;
		Out : BOOL;
		Trig : BOOL;
		ErrorString : STRING[16];
	END_VAR
	VAR
		OutCounter : UDINT;
		InitDone : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION SplitString : DINT
	VAR_INPUT
		Dest2 : UDINT;
		Dest1 : UDINT;
		Source : UDINT;
		SplitChar : USINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK ExternalInput
	VAR_INPUT
		AdrInput : UDINT;
		AdrInputVarName : UDINT;
		FilterTime : UINT;
		AdrCycleCounter : UDINT;
	END_VAR
	VAR_OUTPUT
		DOut : BOOL;
		Out : BOOL;
		Status : SINT;
	END_VAR
	VAR
		TCount : UDINT;
		InitDone : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK AddOn
	VAR_INPUT
		Reset : BOOL;
		TimeOut : UINT;
		Type : USINT;
		Limiter : UDINT;
		MinValue : UDINT;
		MaxValue : UDINT;
		Divider : UDINT;
		Multiplier : UDINT;
		VarName : STRING[80];
		RegType : USINT;
		SubRegType : USINT;
		SubRegTypeID : INT;
		MessageA : STRING[40];
		MessageB : STRING[40];
		Unit : INT;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
		Value : UDINT;
	END_VAR
	VAR
		AdrValue : UDINT;
		OldValue : UDINT;
		Init : BOOL;
		CycleTime : UDINT;
		Timer : UDINT;
		InitRun : BOOL;
		DataType : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK OperatorDelayFifo
	VAR_INPUT
		Set : BOOL;
		Delay : UDINT;
		OperatorName : STRING[80];
		Info : USINT;
		Operator : UINT;
		AdrCounterVarName : UDINT;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		Out : BOOL;
	END_VAR
	VAR
		OperatorFifo : ARRAY[0..49] OF OperatorFifo_Type;
		FreeBuffers : UINT;
		Elements : UINT;
		AdrCounter : UDINT;
		InitDone : USINT;
	END_VAR
END_FUNCTION_BLOCK
