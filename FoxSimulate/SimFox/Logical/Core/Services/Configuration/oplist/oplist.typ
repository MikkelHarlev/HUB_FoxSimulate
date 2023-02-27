
TYPE
	OPFunction_type : 	STRUCT 
		State : USINT;
		Ident : UDINT;
		ListLoaded : BOOL;
		ReScrollTimeout : UDINT;
		TextTimeout : UDINT;
		OperatorEnable : BOOL;
		OperatorCompletion : USINT;
		Status : OPFunctionStatus_type;
		OPStatus : ARRAY[0..9] OF OPStatus_type;
	END_STRUCT;
	OPFunctionStatus_type : 	STRUCT 
		BtUpStat : USINT;
		BtDwStat : USINT;
		BtDeleteStat : USINT;
		BtLoadSaveStat : USINT;
		BtEnterStat : USINT;
	END_STRUCT;
	Oplist_TempInfo_type : 	STRUCT 
		CustomerNumber : UDINT;
		ArticleNumber : UDINT;
		RecipeNumber : USINT;
		Norm : UINT;
		Time : UDINT;
		Count : UDINT;
	END_STRUCT;
	Oplist_ActInfo_type : 	STRUCT 
		Norm : UINT;
		Time : UDINT;
		Count : UDINT;
	END_STRUCT;
	OPStatus_type : 	STRUCT 
		Performance : REAL;
		Hide : USINT;
	END_STRUCT;
END_TYPE
