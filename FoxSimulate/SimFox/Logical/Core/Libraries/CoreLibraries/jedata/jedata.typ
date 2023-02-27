
TYPE
	JenViewTmpRealTimeData_Type : 	STRUCT 
		RcpTime : UDINT;
		OprTime : UDINT;
		OprCnt : UDINT;
		RcpCnt : UDINT;
		Clear : BOOL;
		RewashCnt : UDINT;
		RepairCnt : UDINT;
	END_STRUCT;
	AlarmEvent_Type : 	STRUCT 
		ID : UINT;
		GroupID : UINT;
		Status : USINT;
		Description : STRING[40];
		Severity : UINT;
	END_STRUCT;
	CommonDataLogger_Type : 	STRUCT 
		Production : DataLoggerProduction_Type;
		Flow : DataLoggerFlow_Type;
		Alarm : ARRAY[0..9]OF AlarmEvent_Type;
		Operator : ARRAY[0..9]OF JDOperatorID_Type;
		Active : BOOL;
		ChangeType : BOOL;
		Change : BOOL;
		MetaData : DataLoggerMetaData_Type;
		OldMetaData : DataLoggerMetaData_Type;
		OprLoggedTime : UDINT;
		RcpLoggedTime : UDINT;
		Mode : UINT;
		SingleLaneOp : BOOL;
		TimeStart : DATE_AND_TIME;
		LoadID : UDINT;
	END_STRUCT;
	DataLoggerElement_Type : 	STRUCT 
		Data : UDINT;
		MessageA : STRING[40];
		MessageB : STRING[40];
		Info1 : DINT;
		OprTotal : UDINT;
		RcpTotal : UDINT;
		Info2 : UDINT;
	END_STRUCT;
	DataLoggerFlow_Type : 	STRUCT 
		Machine : FlowMachine_Type;
		Station : FlowStation_Type;
	END_STRUCT;
	DataLoggerMetaData_Type : 	STRUCT 
		RcpNo : USINT;
		RcpText : STRING[32];
		ArtNo : UINT;
		ArtText : STRING[32];
		CustNo : UINT;
		CustText : STRING[32];
		Primary : UDINT;
		Reference : UDINT;
		TNorm : UINT;
		FlowTimeOut : UINT;
		PUStatus : USINT;
		BatchID : UDINT;
		SourceID : UDINT;
	END_STRUCT;
	DataLoggerProduction_Type : 	STRUCT 
		Production : DataLoggerElement_Type;
		Rewash : DataLoggerElement_Type;
		Repair : DataLoggerElement_Type;
		PreProduction : DataLoggerElement_Type;
		Drop : DataLoggerElement_Type;
		Quality : DataLoggerElement_Type;
		Oversize : DataLoggerElement_Type;
		Trash : DataLoggerElement_Type;
		ThickItem : DataLoggerElement_Type;
		Sort : DataLoggerElement_Type;
		MisFeed : DataLoggerElement_Type;
		TooClose : DataLoggerElement_Type;
		Extra1 : DataLoggerElement_Type;
		Extra2 : DataLoggerElement_Type;
		Extra3 : DataLoggerElement_Type;
	END_STRUCT;
	FlowMachine_Type : 	STRUCT 
		WaitingForOverlap : USINT;
		FeedingProhibited : USINT;
		Idle : USINT;
	END_STRUCT;
	FlowStation_Type : 	STRUCT 
		FeedStart : BOOL;
		FeedEnd : BOOL;
		NoFlow : BOOL;
		LinenPresence : BOOL;
	END_STRUCT;
	JDWideLog_Type : 	STRUCT 
		Index : UDINT;
		TimeStamp : DATE_AND_TIME;
		PositionID : USINT;
		SubID : INT;
		RegType : USINT;
		SubRegType : USINT;
		SubRegTypeID : INT;
		State : INT;
		MessageA : STRING[40];
		MessageB : STRING[40];
		BatchID : DINT;
		SourceID : UDINT;
		ProcessCode : UDINT;
		ProcessName : STRING[32];
		CustNo : UDINT;
		SortCategoryID : DINT;
		ArtNo : UDINT;
		OperatorNo : UDINT;
		Value : REAL;
		Unit : INT;
	END_STRUCT;
	JDLog_Type : 	STRUCT 
		Index : UINT;
		TimeStamp : DATE_AND_TIME;
		Mode : USINT;
		ValueID : USINT;
		Value : UDINT;
		Info : DINT;
		MessageA : STRING[40];
		MessageB : STRING[40];
	END_STRUCT;
	JDOperatorID_Type : 	STRUCT 
		ID : UINT;
		Name : STRING[80];
	END_STRUCT;
	JenViewDataObject : 	STRUCT 
		DateTimeLog : ARRAY[0..4]OF DATE_AND_TIME;
		Operator : ARRAY[0..9]OF JDOperatorID_Type;
		Ident : UDINT;
	END_STRUCT;
	JenViewInterfaceInternal_Type : 	STRUCT 
		AdrArrJenViewWriteWideLogVar : UDINT;
		AdrArrJenViewWriteLogVar : UDINT;
		AdrArrIdentJenViewWideLogInit : UDINT;
		AdrArrIdentJenViewLogInit : UDINT;
		AdrArrRealTimeExchange : UDINT;
		MemPartIdent : UDINT;
		AdrLoggerSetup : UDINT;
	END_STRUCT;
	JenViewLogSetup_Type : 	STRUCT 
		Attendants : USINT;
		MachineType : USINT;
		ProductionUnits : USINT;
		Type : USINT;
		PulseLogInterval : UINT;
		Init : BOOL;
		AdrDataLogger : UDINT;
		ExternalInitVarName : STRING[80];
		CounterVarName : STRING[80];
		SingeLaneOp : ARRAY[0..9]OF BOOL;
		OperatorDelay : BOOL;
		MachineName : STRING[80];
		DisableOperatorLog : BOOL;
		AddOn : ARRAY[0..19]OF LogAddOn_Type;
		LogTaskName : ARRAY[0..19]OF STRING[32];
		RunTimeDataEntry : STRING[80];
		NoFlowTimeOut : UINT;
		ChangeDelay : UDINT;
		NoneProduction : BOOL;
		TakeoffStation : BOOL;
		RunningStatus : STRING[80];
		EmergencyStatus : STRING[80];
		CloneMasterEvents : BOOL;
		AlarmIgnoreList : ARRAY[0..19]OF UINT;
	END_STRUCT;
	JenViewTaskInterface_Type : 	STRUCT 
		Internal : JenViewInterfaceInternal_Type;
		ServersRunning : USINT;
		XMLRPCServerStarted : BOOL;
		Status : UINT;
		StatusString : STRING[80];
		MsgString : STRING[200];
		MsgStatus : UINT;
	END_STRUCT;
	LoadID_Type : 	STRUCT 
		LoadID : ARRAY[0..9]OF UDINT;
		BatchID : ARRAY[0..9]OF UDINT;
	END_STRUCT;
	LogAddOn_Type : 	STRUCT 
		AddOnName : STRING[80];
		MinValue : UDINT;
		MaxValue : UDINT;
		MultiplierValue : UDINT;
		DividerValue : UDINT;
		Type : USINT;
		Mode : USINT;
		ValueID : UDINT;
		VarName : STRING[80];
		Limiter : UDINT;
		Ident : UDINT;
		Log : BOOL;
		Reset : BOOL;
		TimeOut : UINT;
		RegType : USINT;
		SubRegType : USINT;
		SubRegTypeID : INT;
		MessageA : STRING[40];
		MessageB : STRING[40];
		Value : UINT;
		Unit : INT;
	END_STRUCT;
	M2JenData_Type : 	STRUCT 
		LoadID : ARRAY[0..9]OF UDINT;
		RcpNo : ARRAY[0..9]OF USINT;
		ArtNo : ARRAY[0..9]OF UDINT;
		CustNo : ARRAY[0..9]OF UDINT;
		RcpText : ARRAY[0..9]OF STRING[32];
		ArtText : ARRAY[0..9]OF STRING[32];
		CustText : ARRAY[0..9]OF STRING[32];
		Norm : ARRAY[0..9]OF UINT;
		FlowTimeOut : ARRAY[0..9]OF UINT;
		Primary : ARRAY[0..9]OF UINT;
		Reference : ARRAY[0..9]OF UINT;
		Active : ARRAY[0..9]OF USINT;
		DisableOperatorLog : BOOL;
		OperatorLogDelay : UINT;
		OperatingHours : UDINT;
		Status : UINT;
		StatusString : STRING[40];
		BatchID : ARRAY[0..9]OF UDINT;
		SourceID : ARRAY[0..9]OF UDINT;
	END_STRUCT;
	OperatorFifo_Type : 	STRUCT 
		Operator : UINT;
		Delay : UDINT;
		Info : USINT;
		OperatorName : STRING[80];
	END_STRUCT;
	ReadLogVar10_Type : 	STRUCT 
		Log : ARRAY[0..39]OF JDLog_Type;
	END_STRUCT;
	RealTimeElement_Type : 	STRUCT 
		Key : STRING[10];
		Data : STRING[20];
	END_STRUCT;
END_TYPE
