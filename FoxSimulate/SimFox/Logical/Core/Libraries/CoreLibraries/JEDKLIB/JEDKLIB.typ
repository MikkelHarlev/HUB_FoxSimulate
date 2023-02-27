
TYPE
	AlarmFnc_Type : 	STRUCT 
		InitDefinition : UDINT;
		Definition : UDINT;
		TimeScale : UINT;
	END_STRUCT;
	ArcNet_ActualTimer_Type : 	STRUCT 
		Status : USINT;
		StatusString : STRING[32];
		First : USINT;
		No : ARRAY[0..31] OF UINT;
	END_STRUCT;
	ArcNet_Category_Type : 	STRUCT 
		Status : USINT;
		StatusString : STRING[32];
		No : USINT;
	END_STRUCT;
	ArcNet_Get_Type : 	STRUCT 
		Enable : BOOL;
		ConnectionNode : USINT;
		Status : USINT;
		StatusString : STRING[32];
		Category : ArcNet_Category_Type;
		Output : ArcNet_Output_Type;
		Register : ArcNet_Register_Type;
		ActualTimer : ArcNet_ActualTimer_Type;
	END_STRUCT;
	ArcNet_Output_Type : 	STRUCT 
		Status : USINT;
		StatusString : STRING[32];
		First : USINT;
		No : ARRAY[0..63] OF BOOL;
	END_STRUCT;
	ArcNet_Register_Type : 	STRUCT 
		Status : USINT;
		StatusString : STRING[32];
		First : USINT;
		No : ARRAY[0..31] OF BOOL;
	END_STRUCT;
	ArcNet_Set_Type : 	STRUCT 
		Enable : BOOL;
		Category : ArcNet_Category_Type;
		Output : ArcNet_Output_Type;
		Register : ArcNet_Register_Type;
		ActualTimer : ArcNet_ActualTimer_Type;
	END_STRUCT;
	ArcNetCT_Type : 	STRUCT 
		Enable : BOOL;
		CT290Node : USINT;
		Status : USINT;
		StatusString : STRING[32];
		Get : ARRAY[0..3] OF ArcNet_Get_Type;
		Set : ArcNet_Set_Type;
	END_STRUCT;
	Blow_Type : 	STRUCT 
		Set : BOOL;
		Info : USINT;
		Count : UDINT;
		On : UDINT;
		Out : BOOL;
		OutA : BOOL;
		OutB : BOOL;
		OutCount : USINT;
		Gap : UINT;
	END_STRUCT;
	Conv_Type : 	STRUCT 
		Set : BOOL;
		InfoSet : USINT;
		CountSet : UDINT;
		Reset : BOOL;
		InfoReset : USINT;
		CountReset : UDINT;
		Stop : BOOL;
		InfoStop : USINT;
		CountStop : UDINT;
		OutSet : BOOL;
		OutSetA : BOOL;
		OutSetB : BOOL;
		OutReset : BOOL;
		OutResetA : BOOL;
		OutResetB : BOOL;
	END_STRUCT;
	Convert_Type : 	STRUCT 
		Value : UINT;
		Hex : ARRAY[0..3] OF USINT;
	END_STRUCT;
	CT290_Par_Type : 	STRUCT 
		Status : USINT;
		First : USINT;
		DataAdr : UDINT;
	END_STRUCT;
	CT290_Req_Type : 	STRUCT 
		Node : USINT;
		Connected : USINT;
		Outputs : CT290_Par_Type;
		Registers : CT290_Par_Type;
		ActualTimers : CT290_Par_Type;
		Category : CT290_Par_Type;
	END_STRUCT;
	CT290_Set_Type : 	STRUCT 
		Outputs : CT290_Par_Type;
		Registers : CT290_Par_Type;
		ActualTimers : CT290_Par_Type;
		Category : CT290_Par_Type;
	END_STRUCT;
	CT290_Type : 	STRUCT 
		Req : ARRAY[0..3] OF CT290_Req_Type;
		Set : CT290_Set_Type;
	END_STRUCT;
	CustArtFifo_Type : 	STRUCT 
		Count : UDINT;
		CustomerNo : UINT;
		ArticleNo : UINT;
		RcpNo : USINT;
		CustomerChange : BOOL;
		CustomerText : STRING[32];
		ArticleText : STRING[32];
		RcpText : STRING[32];
		BatchID : UDINT;
		SourceID : UDINT;
		SpareUDINT1 : UDINT;
		SpareUDINT2 : UDINT;
		SpareUDINT3 : UDINT;
	END_STRUCT;
	DFifo_Type : 	STRUCT 
		Count : UDINT;
		CountOn : UDINT;
		Info : UINT;
	END_STRUCT;
	Filter_Coupling_Test_Type : 	STRUCT 
		On : BOOL;
		Bin : USINT;
		Bin1 : USINT;
		Bin2 : USINT;
		Ste : USINT;
		Ste1 : USINT;
		Ste2 : USINT;
	END_STRUCT;
	Filter_Coupling_Type : 	STRUCT 
		On : BOOL;
		Info : USINT;
		Mode : USINT;
		FilterValue : UINT;
		In : ARRAY[0..5] OF BOOL;
		Out : ARRAY[0..5] OF BOOL;
		OutAll : ARRAY[0..5] OF BOOL;
		OutSerial : ARRAY[0..5] OF BOOL;
		CounterAdr : ARRAY[0..5] OF UDINT;
	END_STRUCT;
	InUse_Lane_Type : 	STRUCT 
		Active : ARRAY[0..5] OF BOOL;
		SteeringLane : ARRAY[0..5] OF USINT;
		IndexSteering : ARRAY[0..5] OF USINT;
	END_STRUCT;
	InUse_SteeringLane_Type : 	STRUCT 
		Count : USINT;
		No : ARRAY[0..5] OF USINT;
		LanesCoupled : ARRAY[0..5] OF USINT;
	END_STRUCT;
	InUse_Head_Type : 	STRUCT 
		Mode : USINT;
		Set : BOOL;
		CouplingClass : USINT;
		Lane : InUse_Lane_Type;
		SteeringLane : InUse_SteeringLane_Type;
	END_STRUCT;
	LaneCombination_InOut_Type : 	STRUCT 
		Coup : ARRAY[0..4] OF BOOL;
		CouplingClass : USINT;
		CouplingClassOld : USINT;
	END_STRUCT;
	LaneCombination_Head_Type : 	STRUCT 
		Mode : USINT;
		In_Out : BOOL;
		In : LaneCombination_InOut_Type;
		Out : LaneCombination_InOut_Type;
	END_STRUCT;
	MapLane_In_Type : 	STRUCT 
		MasterCouplingClass : USINT;
		MasterLaneNo : USINT;
		CurrentMode : USINT;
	END_STRUCT;
	MapLane_Out_Type : 	STRUCT 
		La : USINT;
		Info : USINT;
	END_STRUCT;
	MapLaneFunction_Type : 	STRUCT 
		In : MapLane_In_Type;
		Out : MapLane_Out_Type;
	END_STRUCT;
	MultiDelay_Type : 	STRUCT 
		Count : UDINT;
		Info : BOOL;
	END_STRUCT;
	Serial_Type : 	STRUCT 
		Tx : USINT;
		Rx : USINT;
		Tx_Data : ARRAY[0..255] OF USINT;
		Rx_Data : ARRAY[0..255] OF USINT;
	END_STRUCT;
	SetReset_Type : 	STRUCT 
		Set : BOOL;
		InfoSet : USINT;
		CountSet : UDINT;
		Reset : BOOL;
		InfoReset : USINT;
		CountReset : UDINT;
		Out : BOOL;
		OutA : BOOL;
		OutB : BOOL;
	END_STRUCT;
	Tag_Config_Type : 	STRUCT 
		MemorySize : UINT;
		DataStart : UINT;
		DataLength : UINT;
	END_STRUCT;
	TagType_Enum : 
		(
		Unknown := 0,
		Philips_MifareClassic := 1,
		Fujitsu_MB89R118 := 2,
		Philips_SL2ICS20 := 3,
		TexasInstruments_TAG_IT_Plus := 4,
		Infineon_SRF55V02P := 5,
		EM_EM4135 := 6,
		Infineon_SRF55V10P := 7
		);
	Tag_MetaData_Type : 	STRUCT 
		TagType : TagType_Enum;
		UniqueID : ARRAY[0..7] OF USINT;
	END_STRUCT;
	TagRW_Type : 	STRUCT 
		LinenData : Tag_Data_Type;
		MetaData : Tag_MetaData_Type;
	END_STRUCT;
	Tag_Data_Type : 	STRUCT 
		SerialNumber : UDINT;
		DateAndTime : DATE_AND_TIME;
		BufferNumber : UINT;
		BatchNumber : UDINT;
		CustomerNumber : UINT;
		ArticleNumber : UINT;
		RecipeNumber : USINT;
		SortingClass : USINT;
		SourceID : UDINT;
		StationID : USINT;
		Info : UINT;
		CustomerID : STRING[32];
		CustomerName : STRING[32];
		ArticleID : STRING[32];
		ArticleName : STRING[32];
	END_STRUCT;
END_TYPE
