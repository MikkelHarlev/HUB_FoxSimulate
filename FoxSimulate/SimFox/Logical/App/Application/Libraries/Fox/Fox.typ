
TYPE
	Alarm_Type : 	STRUCT 
		Alarm : ARRAY[0..99]OF BOOL;
		Ack : ARRAY[0..99]OF BOOL;
		AckOld : ARRAY[0..99]OF BOOL;
		Bypassed : ARRAY[0..99]OF BOOL;
		DisableFlash : ARRAY[0..99]OF BOOL;
	END_STRUCT;
	BeltHook_Type : 	STRUCT 
		State : UINT;
		StackIndex : UINT;
	END_STRUCT;
	FoldMotor_Type : 	STRUCT 
		Name : STRING[11];
		State : UINT;
		Run : BOOL;
		cmdReverse : BOOL;
		cmdForward : BOOL;
		cmdNewSpeed : INT;
		cmdStop : BOOL;
		cmdHold : BOOL;
		Speed : UINT;
		LowSpeed : UINT;
		HighSpeed : UINT;
		DoReverse : BOOL;
		Direction : BOOL;
		RunTime : UINT;
		RunTimer : UINT;
		StopTime : UINT;
		StopTimer : UINT;
		StartDelayWait : BOOL;
		StartDelayTime : UINT;
		StartDelayTimer : UINT;
	END_STRUCT;
	DeliveryBelt_Type : 	STRUCT 
		Hook : ARRAY[0..10]OF BeltHook_Type;
		Length : UINT;
		StackCounter : UINT;
		ExitTime : UINT;
		ExitTimer : UINT;
		cmdStart : BOOL;
		Function : UINT;
		Motor : FoldMotor_Type;
		EndSensor : FoldIOCounter_Type;
		ExitRecalcTime : UINT;
	END_STRUCT;
	ProductData_Type : 	STRUCT 
		ID : UINT;
		AutoProgram : UINT;
		FoldProgram : UINT;
		RecipeName : STRING[80];
		LeadEdgeXA : UINT;
		Length : UINT;
		LengthWheel : UINT;
		LengthNoDisc : UINT;
		LengthStart : UINT;
		TCExtraRunTime : UINT;
		Article : UINT;
		Customer : UINT;
		IsFlapTrousers : BOOL;
		ProductType : UINT;
		HangerId : STRING[20];
		GarmentId : STRING[20];
		SortOut : UINT;
		Size : UINT;
		Stack : UINT;
		JenWayDestination : UINT;
		BatchId : UDINT;
		StackChangeIndex : UINT;
		LastItemOnStack : UINT;
		PreStackChange : BOOL;
		EmpHangLength : UINT;
		SelectedAutoProg : UINT;
		NoRead : BOOL;
		LogCount : UINT;
		LogID : INT;
		LogMsg : STRING[20];
		IsRouteChange : BOOL;
		CustomerStackChange : BOOL;
		Dummy : USINT;
		HangerFlagLeft : BOOL;
		DuoStackChangeIndex : UINT;
	END_STRUCT;
	ExchangeData_Type : 	STRUCT 
		TransferStatus : UINT;
		Product : ProductData_Type;
	END_STRUCT;
	StackItemData_Type : 	STRUCT  (*Id : UINT;*)
		CustomerId : UDINT;
		ArticleId : UDINT;
		HangerId : STRING[20];
		GarmentId : STRING[20];
		FoldProgram : UINT;
	END_STRUCT;
	StackData_Type : 	STRUCT 
		BatchId : UDINT;
		CustomerId : UDINT; (*Keep it to compile XB and on, it migth be needed..*)
		ArticleId : UINT; (*Keep it to compile XB and on, it migth be needed..*)
		FoldProgram : UINT; (*Keep it to compile XB and on, it migth be needed..*)
		Count : UINT;
		Destination : UINT;
		ItemData : ARRAY[0..STACK_ITEM_MAX_20]OF StackItemData_Type;
	END_STRUCT;
	ProcessAlarm_Type : 	STRUCT 
		Alarm : ARRAY[0..25]OF BOOL; (*CBV Old was 19*)
		Ack : ARRAY[0..25]OF BOOL;
		AckOld : ARRAY[0..25]OF BOOL;
		Bypassed : ARRAY[0..25]OF BOOL;
		DisableFlash : ARRAY[0..25]OF BOOL;
	END_STRUCT;
	FoldTaskCommon_Type : 	STRUCT 
		State : UINT;
		Id : UINT;
		Description : STRING[31];
		ErrorCode : UINT;
		IPAddress : STRING[25];
		Batch : SINT;
		OldState : UINT;
		SaveState : UINT;
		Product : ProductData_Type;
		ReadParameters : BOOL;
		CurTimer : UINT;
		Motor : FoldMotor_Type;
		FoldUnit1 : FoldIO_Type;
		FoldUnit2 : FoldIO_Type;
		InSensor : FoldIOCounter_Type;
		InSensor2 : FoldIOCounter_Type;
		InSensor3 : FoldIOCounter_Type;
		AllowServiceKeys : BOOL;
		MachineManagerIndex : UINT;
		LogBookFlag : USINT;
		TrigMode : UINT;
		FoldPointTime : UINT;
		FoldPointTimer : UINT;
		HoldingPointTime : UINT;
		HoldingPointTimer : UINT;
		ExitTimer : UINT;
		ExitTime : UINT;
		AlarmList : ProcessAlarm_Type;
		WatchDogStartupTimer : UINT;
		WatchDogRunTime : UINT;
		WatchDogRunTimer : UINT;
		WatchDogStartupTime : UINT;
		Previous : ExchangeData_Type;
		Next : ExchangeData_Type;
	END_STRUCT;
	OutletSubUnit_Type : 	STRUCT 
		Batch : SINT;
		State : UINT;
		OldState : UINT;
		ErrorCode : UINT;
		Product : ProductData_Type;
		ReadParameters : BOOL;
		LogBookFlag : USINT;
		Previous : ExchangeData_Type;
		Next : ExchangeData_Type;
	END_STRUCT;
	TransportBeltType : 	STRUCT 
		Hook : ARRAY[0..50]OF BeltHook_Type;
		IsLoaded : BOOL;
		CycleCounter : UINT;
		cmdStart : BOOL;
		Length : UINT;
		StackIndex : UINT;
		MissedStackIndex : UINT;
		OkToStart : BOOL;
		RestartDelay : UINT;
		InSensor : FoldIOCounter_Type;
	END_STRUCT;
	TaskStatus_Type : 	STRUCT 
		Id : UINT;
		Description : STRING[31];
		State : UINT;
		OldState : UINT;
		ErrorCode : UINT;
		MyStatus : UINT;
		ExchangePreviousStatus : UINT;
		ExchangeNextStatus : UINT;
	END_STRUCT;
	MachineProcessHandle_Type : 	STRUCT 
		StatusData : TaskStatus_Type;
		Name : STRING[31];
		Run : BOOL;
		ForcedStop : BOOL;
		ResetAlarm : BOOL;
		ControlFlag : INT;
		Simulate : BOOL;
		Service : BOOL;
	END_STRUCT;
END_TYPE
