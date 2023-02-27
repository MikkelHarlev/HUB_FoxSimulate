
TYPE
	RcpExtInfo_Type : 	STRUCT 
		Ident : UDINT;
		adrActRcpData : UDINT;
		NumberOfRecipes : UINT;
		NumberOfFiles : USINT;
		MaxNumberOfFiles : USINT;
		RcpStructName : STRING[32];
		ErrStringInfo : STRING[40];
		ErrStringDetail : STRING[40];
		Status : UINT;
	END_STRUCT;
END_TYPE
