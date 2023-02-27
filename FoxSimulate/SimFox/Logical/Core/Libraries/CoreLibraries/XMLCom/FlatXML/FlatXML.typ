
TYPE
	XMLFlatworkData_Type : 	STRUCT 
		RcpNo : USINT;
		SortingClassNo : USINT;
		Status : USINT;
		Info : USINT;
		Speed : UINT;
		OperatorNo : UINT;
		CustomerNo : UINT;
		ArticleNo : UINT;
		TextNo : USINT;
		Text : STRING[80];
		SpareUSINT : USINT;
		SpareUINT : UINT;
		SpareUDINT : UDINT;
		SpareREAL : REAL;
		SpareDATE : DATE_AND_TIME;
		SpareTIME : TIME;
	END_STRUCT;
	FlatStatisticCounters : 	STRUCT 
		ConnectedOkCounter : UINT;
		ClosedCounter : UINT;
		RequestCounter : UINT;
		RequestOkCounter : UINT;
		StatusTransmitCounter : UINT;
		StatusOkCounter : UINT;
		NoAnswerCounter : UINT;
		ErrorCounter : UINT;
		WrongMessageIdCounter : UINT;
		UnknownTagCounter : UINT;
	END_STRUCT;
	MachineInfo_Type : 	STRUCT 
		ServerMachineStatus : INT;
		ClientMachineStatus : INT;
		MachineId : INT;
		IpAddress : STRING[21];
		ConnectionState : INT;
		ConnectionError : UDINT;
		ServerVersion : STRING[10];
		ClientVersion : STRING[10];
		StatusRefreshTime : UINT;
		StatusRefreshTimer : UINT;
		RequestTimeOutTime : UINT;
		RequestTimeOutTimer : UINT;
		ComState : INT;
		RequestFlatworkData : BOOL;
		SendFlatworkData : BOOL;
		RequestOk : BOOL;
		RequestFail : BOOL;
		LaneNo : USINT;
		NewLaneData : ARRAY[0..8]OF UINT;
		FlatworkData : ARRAY[0..8]OF XMLFlatworkData_Type;
		Statistic : FlatStatisticCounters;
	END_STRUCT;
END_TYPE
