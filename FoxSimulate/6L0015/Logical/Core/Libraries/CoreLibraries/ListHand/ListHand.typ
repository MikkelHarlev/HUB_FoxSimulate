
TYPE
	ListOperator_type : 	STRUCT 
		Name : STRING[32];
		OperatorNo : UINT;
	END_STRUCT;
	ListCustomer_type : 	STRUCT 
		Name : STRING[32];
		CustNo : UDINT;
		ArtNo : UDINT;
		RcpNo : USINT;
		Norm : UINT;
		FlowTimeOut : UINT;
		Primary : UINT;
		Reference : UINT;
	END_STRUCT;
	ListInfo_Type : 	STRUCT 
		NumberEntryInList : UINT;
		NumberEntryInLayer : UINT;
		ActEntryInLayer : UINT;
		NextLayerLastLayer : USINT;
		ActLayerLastLayer : USINT;
		ActLayer : USINT;
		SelectedItem : USINT;
		StringNextLayer : STRING[32];
		StringActLayer : STRING[32];
		StringPrevLayer : STRING[32];
		ErrStringInfo : STRING[32];
		ErrStringDetail : STRING[32];
		Status : UINT;
	END_STRUCT;
END_TYPE
