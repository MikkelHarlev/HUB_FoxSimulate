
TYPE
	Backup_Include_Type : 	STRUCT 
		Index : USINT;
		IndexUp : BOOL;
		IndexDw : BOOL;
		ComboboxHide : USINT;
		ComboboxMaxIndex : USINT;
	END_STRUCT;
	passwordtask_type : 	STRUCT 
		PasswordList : ARRAY[0..3] OF STRING[7];
		ChangePassword : ARRAY[0..3] OF STRING[7];
		StatusPasswordEdit : ARRAY[0..3] OF UINT;
		PasswordCodeIn : UDINT;
		PasswordCodeOut : UDINT;
		PasswordCodeStatus : UINT;
		PasswordLevel : USINT;
		PasswordEntered : USINT;
		PasswordChanged : USINT;
		WrongPWTextStatus : UINT;
		InvalidPWTextStatus : UINT;
	END_STRUCT;
	JenLog_Type : 	STRUCT 
		SaveFileState : UINT;
		DeviceName : STRING[11];
		FileName : STRING[14];
		OpenStatus : UINT;
		OpenError : UINT;
		LogPointer : UINT;
		DoSave : BOOL;
		StoreTimeOutCntr : UINT;
		OpenIdent : UDINT;
		LastFileWriteAddress : UDINT;
		RecordAdr : UDINT;
		RecordSize : UDINT;
	END_STRUCT;
	Backup_Type : 	STRUCT 
		cmdBackup : USINT;
		cmdRestore : USINT;
		cmdCancel : USINT;
		ErrorNumber : UINT;
		IndexStatusText : UINT;
		StatusWarningText : UINT;
		Include : Backup_Include_Type;
	END_STRUCT;
	BusStatusModule_Type : 	STRUCT 
		State : USINT;
		ConfiguredNumber : UINT;
		ConfiguredFamily : UINT;
		ConfiguredType : UINT;
		ModuleName : STRING[21];
		Station : SINT;
	END_STRUCT;
	CPUInfoData_Type : 	STRUCT 
		State : UINT;
		BType : UINT;
		Number : UINT;
		Name : STRING[21];
		Path : STRING[41];
		Info1 : STRING[21];
		Info2 : STRING[21];
	END_STRUCT;
	IoStatus_Type : 	STRUCT 
		DigitalStateArray : ARRAY[0..5] OF BOOL;
		DigitalStateArrayOut : ARRAY[0..5] OF BOOL;
		AnalogStateArray : ARRAY[0..5] OF INT;
		IoNameArray : ARRAY[0..5] OF STRING[32];
		ColorDigitalArray : ARRAY[0..5] OF UINT;
		DigitalStateSet : BOOL;
		DigitalForce : BOOL;
		AnalogStateSet : INT;
		AnalogForce : INT;
		EnableStateSet : UINT;
		ColorStateSet : UINT;
		IoDescription : STRING[32];
		IoType : USINT;
		NumbSelectLanguage : USINT;
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		cmdLevelUp : USINT;
		cmdLevelDown : USINT;
		cmdChangeOutput : USINT;
		SelectedItem : USINT;
		IoInfoStruct : IoInfo_Type;
	END_STRUCT;
	IoTraceValue_Type : 	STRUCT 
		Pointer : UDINT;
		Name : STRING[21];
		TType : UINT;
		CurrentValue : UINT;
		OldValue : UINT;
		LastCycle : UINT;
		Index : UINT;
		Value : ARRAY[0..50] OF UINT;
		StartCycle : ARRAY[0..50] OF UINT;
	END_STRUCT;
	IoTraceStruct_Type : 	STRUCT 
		Mode : UINT;
		CycleCounter : UINT;
		TrigStartCycle : UINT;
		TrigStopCycle : UINT;
		TrigIndex : INT;
		ExternTrig : BOOL;
		TrigStart : BOOL;
		RecordEnable : BOOL;
		IoData : ARRAY[0..10] OF IoTraceValue_Type;
		cmdAdd : SINT;
		cmdStart : SINT;
		cmdStop : SINT;
		cmdTrig : SINT;
		cmdReset : SINT;
		numberOfTraceIO : UINT;
	END_STRUCT;
	IoTraceVarList_Type : 	STRUCT 
		NumberVar : UINT;
		IoName : ARRAY[0..4] OF STRING[33];
		adrIo : ARRAY[0..4] OF UDINT;
		ColorTrend : ARRAY[0..4] OF UINT;
	END_STRUCT;
	IoTrace_Type : 	STRUCT 
		cmdRst : USINT;
		cmdAdd : USINT;
		cmdConfig : USINT;
		cmdScrollDown : USINT;
		cmdScrollUp : USINT;
		InitOk : USINT;
		SelectedItem : UINT;
		IoNameArray : ARRAY[0..9] OF STRING[40];
		RecordEnable : BOOL;
		RecordOnOff : UINT;
		TextHide : UINT;
		State : UINT;
		Status : UINT;
		idTrend : UDINT;
		TrendVarList : IoTraceVarList_Type;
	END_STRUCT;
	LocalBusData_Type : 	STRUCT 
		Index : UINT;
		BType : UINT;
		Status : UINT;
		Name : STRING[11];
	END_STRUCT;
	X67OutputStatus_Type : 	STRUCT 
		Output1 : BOOL;
		Output2 : BOOL;
		Output3 : BOOL;
		Output4 : BOOL;
		Output5 : BOOL;
		Output6 : BOOL;
		Output7 : BOOL;
		Output8 : BOOL;
	END_STRUCT;
	plclog_type : 	STRUCT 
		cmdLogRead : USINT;
		cmdDetailInfo : USINT;
		cmdNextEntry : USINT;
		cmdPrevEntry : USINT;
		NumberDetailInfo : USINT;
		InfoHide : UINT;
		LogInfoString : ARRAY[0..19] OF STRING[45];
		DetailInfo : ERR_xtyp;
	END_STRUCT;
	sysinfo_type : 	STRUCT 
		BatteryState : USINT;
		SRAM : UDINT;
		DRAM : UDINT;
		HD : UDINT;
	END_STRUCT;
END_TYPE
