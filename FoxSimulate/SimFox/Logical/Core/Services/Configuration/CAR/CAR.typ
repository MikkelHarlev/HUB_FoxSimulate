
TYPE
	CARFunction_type : 	STRUCT 
		State : USINT;
		Ident : UDINT;
		ListLoaded : BOOL;
		ReScrollTimeout : UDINT;
		TextTimeout : UDINT;
		CustomerEnable : BOOL;
		LaneNoCompletion : USINT;
		RcpCompletion : BOOL;
		Status : CARFunctionStatus_type;
	END_STRUCT;
	CARFunctionStatus_type : 	STRUCT 
		BtUpStat : USINT;
		BtDwStat : USINT;
		BtLeftStat : USINT;
		BtRightStat : USINT;
		BtEnterStat : USINT;
		BtDeleteStat : USINT;
		BtLoadSaveStat : USINT;
	END_STRUCT;
END_TYPE
