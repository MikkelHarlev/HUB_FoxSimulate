
TYPE
	JenLogging_Type : 	STRUCT 
		cmdAdd : USINT;
		cmdReadFirst : USINT;
		cmdReadNext : USINT;
		cmdSetLogPointer : USINT;
		entriesRead : UDINT;
		Status : UINT;
		ErrInfoString : STRING[32];
		ErrInfoDetail : STRING[32];
	END_STRUCT;
	CustomerOpt_type : 	STRUCT 
		DoSortAfterAdd : USINT;
	END_STRUCT;
	CustomerCmd_type : 	STRUCT 
		cmdUnlockList : USINT;
		cmdLoadList : USINT;
		cmdSaveList : USINT;
		cmdScroll : USINT;
		cmdAddItem : USINT;
		cmdDeleteItem : USINT;
		cmdDeleteList : USINT;
		cmdSearchCustArt : USINT;
		cmdSearchCustNo : USINT;
		cmdSearchArtNo : USINT;
		cmdSearchCustArtNo : USINT;
		cmdLockList : USINT;
		cmdEditItem : USINT;
		cmdSelect : USINT;
	END_STRUCT;
	CustomerRdy_type : 	STRUCT 
		rdyLoadList : USINT;
		rdySaveList : USINT;
		rdyScroll : USINT;
		rdyAddItem : USINT;
		rdyDeleteItem : USINT;
		rdyDeleteList : USINT;
		rdySearchCustArt : USINT;
		rdySearchCustNo : USINT;
		rdySearchArtNo : USINT;
		rdySearchCustArtNo : USINT;
		rdyLockList : USINT;
		rdyUnlockList : USINT;
		rdyEditItem : USINT;
	END_STRUCT;
	CustomerError_type : 	STRUCT 
		Status : UINT;
		ErrStringInfo : ARRAY[0..31]OF USINT;
		ErrStringDetail : ARRAY[0..31]OF USINT;
		EntryLegal : USINT;
	END_STRUCT;
	CustomerVis_type : 	STRUCT 
		ItemList : ARRAY[0..7]OF STRING[32];
	END_STRUCT;
	CustomerEntry_type : 	STRUCT 
		Name : STRING[32];
		CustNo : UDINT;
		ArtNo : UDINT;
		RcpNo : USINT;
		Norm : UINT;
		FlowTimeOut : UINT;
		Primary : UINT;
		Reference : UINT;
	END_STRUCT;
	Customer_type : 	STRUCT 
		Option : CustomerOpt_type;
		Cmd : CustomerCmd_type;
		Rdy : CustomerRdy_type;
		Error : CustomerError_type;
		Vis : CustomerVis_type;
		Entry : CustomerEntry_type;
		ListInfo : ListInfo_Type;
	END_STRUCT;
	OperatorOpt_type : 	STRUCT 
		DoSortAfterAdd : USINT;
	END_STRUCT;
	OperatorCmd_type : 	STRUCT 
		cmdLoadList : USINT;
		cmdSaveList : USINT;
		cmdScroll : USINT;
		cmdAddItem : USINT;
		cmdDeleteItem : USINT;
		cmdDeleteList : USINT;
		cmdSearchName : USINT;
		cmdSearchNumber : USINT;
		cmdLockList : USINT;
		cmdUnlockList : USINT;
		cmdEditItem : USINT;
		cmdSelect : USINT;
		cmdLogout : USINT;
	END_STRUCT;
	OperatorRdy_type : 	STRUCT 
		rdyLoadList : USINT;
		rdySaveList : USINT;
		rdyScroll : USINT;
		rdyAddItem : USINT;
		rdyDeleteItem : USINT;
		rdyDeleteList : USINT;
		rdySearchName : USINT;
		rdySearchNumber : USINT;
		rdyLockList : USINT;
		rdyUnlockList : USINT;
		rdyEditItem : USINT;
	END_STRUCT;
	OperatorError_type : 	STRUCT 
		Status : UINT;
		ErrStringInfo : ARRAY[0..31]OF USINT;
		ErrStringDetail : ARRAY[0..31]OF USINT;
		EntryLegal : USINT;
	END_STRUCT;
	OperatorVis_type : 	STRUCT 
		ItemList : ARRAY[0..7]OF STRING[32];
	END_STRUCT;
	OperatorEntry_type : 	STRUCT 
		Name : STRING[32];
		OperatorNo : UINT;
	END_STRUCT;
	Operator_type : 	STRUCT 
		Option : OperatorOpt_type;
		Cmd : OperatorCmd_type;
		Rdy : OperatorRdy_type;
		Error : OperatorError_type;
		Vis : OperatorVis_type;
		Entry : OperatorEntry_type;
		ListInfo : ListInfo_Type;
	END_STRUCT;
	CfgAdd_Type : 	STRUCT 
		cmdAdd : USINT;
		NewCfgNumber : UINT;
	END_STRUCT;
	CfgCopy_Type : 	STRUCT 
		CfgSourceNumber : UINT;
		CfgDestBegin : UINT;
		CfgDestEnd : UINT;
		cmdCopyCfg : USINT;
	END_STRUCT;
	CfgNameList_Type : 	STRUCT 
		cmdInit : USINT;
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		cmdCfgNameSelect : USINT;
		cmdGetNames : USINT;
		SelectedItem : USINT;
		SelectedRcpNumber : UINT;
		RcpNameArray : ARRAY[0..98]OF STRING[32];
		cmdGotoIndex : USINT; (*for mappview facelift*)
	END_STRUCT;
	CfgFileList_Type : 	STRUCT 
		FileNameArray : ARRAY[0..4]OF STRING[32];
		cmdUp : USINT;
		cmdDown : USINT;
		cmdDirList : USINT;
		cmdNewFile : USINT;
		SelectedItem : USINT;
	END_STRUCT;
	CfgParScro_Type : 	STRUCT 
		ParScrollArray : ARRAY[0..500]OF STRING[60];
		ParValueArray : ARRAY[0..500]OF STRING[50];
		ParNameArray : ARRAY[0..500]OF STRING[25];
		VarNameArray : ARRAY[0..500]OF STRING[60];
		ActParValue : STRING[50];
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		cmdEditPar : USINT;
		cmdParListRcpChange : USINT;
		SelectRcpNumber : UINT;
		SelectedItem : UINT;
		cmdGotoIndex : UINT;
		cmdScrollIndex : UINT; (*This will cause the mappview HMI to scroll to index with this number*)
	END_STRUCT;
	Cfg_Type : 	STRUCT 
		InitDone : USINT;
		cmdLoadCfg : USINT;
		cmdSaveCfg : USINT;
		CfgName : STRING[32];
		Ident : UDINT;
		StatusString : STRING[32];
		CfgAdd : CfgAdd_Type;
		CfgCopy : CfgCopy_Type;
		NameList : CfgNameList_Type;
		FileList : CfgFileList_Type;
		ParScroll : CfgParScro_Type;
		CfgExtInfo : RcpExtInfo_Type;
	END_STRUCT;
END_TYPE
