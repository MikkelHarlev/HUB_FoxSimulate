
TYPE
	Inverter_Drive_Type : 	STRUCT 
		ModuleOk : BOOL;
		SerialNumber : UDINT;
		ModuleID : UDINT;
		HardwareVariant : UDINT;
		FirmwareVersion : UDINT;
		Status : UINT;
		StartCommand : BOOL;
		SetControl : UINT;
		SetSpeed : INT;
		SetTorque : INT;
		GetPowerRemoval : BOOL;
		GetLastError : INT;
		GetLastErrorUINT : UINT;
		GetSpeed : INT;
		GetTorque : INT;
		GetStatus : UINT;
		GetStatusExtended : UINT;
		GetState : UINT;
		GetCurrent : UINT;
		GetDriveTemperature : UINT;
		GetMotorTemperature : UINT;
	END_STRUCT;
	Invalchk_Task_Type : 	STRUCT 
		Index : UINT;
		MinIndex : UINT;
		MaxIndex : UINT;
		HistoryIndex : USINT;
		HistoryTextNumber : UINT;
		History : Invalchk_History_Type;
		HMI : Inverter_Drive_Type;
	END_STRUCT;
	AcoposAlarmService_Type : 	STRUCT 
		Runtime : AcoposAlarmServiceRuntime_Type;
	END_STRUCT;
	AcoposAlarmServiceRuntime_Type : 	STRUCT 
		Initializing : BOOL;
		Error : BOOL;
		ErrorReset : BOOL;
		PowerOff : BOOL;
		FirstDrive : UINT;
		LastDrive : UINT;
	END_STRUCT;
	AcpAlarm_Type : 	STRUCT 
		status : UINT;
		errorID : UINT;
		errorInfo : REAL;
		line1 : STRING[80];
		line2 : STRING[80];
		NodeNumber : USINT;
		cmdNextAcp : USINT;
		cmdPrevAcp : USINT;
		cmdNextError : USINT;
		cmdPrevError : USINT;
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		SelectedItem : USINT;
		AcpArray : ARRAY[0..6]OF STRING[22];
	END_STRUCT;
	AcpAlarmCheck_Type : 	STRUCT 
		Vc : AcpAlarmCheckVC_Type;
	END_STRUCT;
	AcpAlarmCheckVC_Type : 	STRUCT 
		Trigger : ARRAY[0..5]OF BOOL;
		Bypass : ARRAY[0..5]OF BOOL;
		Acknowledge : ARRAY[0..5]OF BOOL;
		GroupAlarm : USINT;
	END_STRUCT;
	alarm_type : 	STRUCT 
		AlarmShortcut : USINT;
		AlarmActiveFront : UINT;
		AlarmActiveTop : UINT;
		FrontColor : UINT;
		HeaderColor : UINT;
		HeaderTextColor : UINT;
	END_STRUCT;
	AlarmCache_Type : 	STRUCT 
		Event : AlarmEvent_Type;
		Description : ARRAY[0..79]OF UINT;
	END_STRUCT;
	AlarmControl_Type : 	STRUCT 
		Visible : USINT;
		FilterControl : USINT;
		GroupFilter : UINT;
	END_STRUCT;
	AlarmLog_Type : 	STRUCT 
		Ack : ARRAY[0..100]OF BOOL;
		Alarm : ARRAY[0..100]OF BOOL;
		Priority : ARRAY[0..100]OF USINT;
	END_STRUCT;
	AlarmPriority_Type : 	STRUCT 
		Set : BOOL;
		ID : UINT;
		Priority : USINT;
	END_STRUCT;
	AXIS_Enum : 
		(
		AXIS_RESETTING := 0,
		AXIS_IDLE := 1,
		AXIS_POWER_ON := 10,
		AXIS_POWER_ON_WAIT := 11,
		AXIS_POWER_OF := 20,
		AXIS_POWER_OF_WAIT := 21,
		AXIS_HOME := 30,
		AXIS_HOME_WAIT := 31,
		AXIS_ADD := 40,
		AXIS_ADD_WAIT := 41,
		AXIS_ABS := 50,
		AXIS_ABS_WAIT := 51,
		AXIS_FOLLOW := 55,
		AXIS_FOLLOW_WAIT := 56,
		AXIS_VEL := 60,
		AXIS_VEL_WAIT := 61,
		AXIS_TORQUE_MODE := 70,
		AXIS_TORQUE_MODE_WAIT := 71,
		AXIS_TORQUE_PULL := 75,
		AXIS_TORQUE_PULL_WAIT := 76,
		AXIS_STOP := 80,
		AXIS_STOP_WAIT := 81,
		AXIS_CMD_WRITE := 100,
		AXIS_CMD_WRITE_WAIT := 101,
		AXIS_CMD_READ := 110,
		AXIS_CMD_READ_WAIT := 111,
		AXIS_ERROR := 200,
		AXIS_ERROR_1 := 201,
		AXIS_ERROR_2 := 202,
		AXIS_ERROR_3 := 203,
		AXIS_ERROR_4 := 204,
		AXIS_ERROR_RESET := 210
		);
	CommAxisActualValues_Type : 	STRUCT 
		Errorstop : USINT;
		Stopping : BOOL;
		StandStill : BOOL;
		inMotion : BOOL;
		DiscreteMotion : BOOL;
		ContinuousMotion : BOOL;
		SynchronizedMotion : BOOL;
		Homing : BOOL;
		reference : BOOL;
		trigger1 : BOOL;
		trigger2 : BOOL;
		axisPos : REAL;
		velocity : REAL;
		dintPos : DINT;
		actTorque : REAL;
		actLagError : REAL;
	END_STRUCT;
	CommAxisErrorList_Type : 	STRUCT 
		status : UINT;
		errorID : UINT;
		errorInfo : REAL;
		line1 : STRING[80];
		line2 : STRING[80];
		line3 : STRING[80];
		line4 : STRING[80];
	END_STRUCT;
	CommAxisMove_Type : 	STRUCT 
		position : REAL;
		position1 : REAL;
		position2 : REAL;
		velocity : REAL;
		acceleration : REAL;
		deceleration : REAL;
		torque : USINT;
		lagLimit : REAL;
		release : REAL;
		newvalue : BOOL;
		newspeed : BOOL;
		reset : BOOL;
		stop : BOOL;
		direction : USINT;
		input1 : BOOL;
		input2 : BOOL;
		maxposition : BOOL;
	END_STRUCT;
	CommAxisParameter_Type : 	STRUCT 
		parID : UINT;
		DataAddress : UDINT;
		DataType : UINT;
	END_STRUCT;
	CommAxis_Type : 	STRUCT 
		axisRef : UDINT;
		disable : BOOL;
		state : AXIS_Enum;
		ready : BOOL;
		power : BOOL;
		move : CommAxisMove_Type;
		actValues : CommAxisActualValues_Type;
		parameter : CommAxisParameter_Type;
		ErrorId : UINT;
		ErrorText : ARRAY[0..3]OF STRING[79];
		errorList : ARRAY[0..4]OF CommAxisErrorList_Type;
		interface : CommInterface_Type;
	END_STRUCT;
	CommInterface_Type : 	STRUCT 
		isStarted : BOOL;
		isStopped : BOOL;
		isError : BOOL;
		isErrorReset : BOOL;
		cmdStart : BOOL;
		cmdStop : BOOL;
		cmdDisableAlarm : BOOL;
	END_STRUCT;
	emcyObjData_s : 	STRUCT 
		emcyErrCode : UINT;
		emcyErrReg : USINT;
		manSpecErr : ARRAY[0..4]OF USINT;
		Errorstop : USINT;
	END_STRUCT;
	errorData_s : 	STRUCT 
		errorClass : USINT;
		errorCode : USINT;
		addCode : UINT;
		drvAdr : USINT;
		res1 : USINT;
		index : UINT;
		subIdx : USINT;
		res2 : USINT;
		data : ARRAY[0..3]OF USINT;
	END_STRUCT;
	Invalchk_Com_Type : 	STRUCT 
		ModuleOk : BOOL;
		SerialNumber : UDINT;
		ModuleID : UDINT;
		HardwareVariant : UDINT;
		VendorID : UDINT;
		CtrlWord : UINT;
		SetSpeed : INT;
		ActStatus : UINT;
		ActSpeed : INT;
		ActCurrent : UINT;
		ActTemperature : UINT;
	END_STRUCT;
	Invalchk_Error_Type : 	STRUCT 
		Initializing : BOOL;
		ConnectionError : BOOL;
		Error : BOOL;
	END_STRUCT;
	Inverter_State_Type : 	STRUCT 
		Initializing : BOOL;
		Error : BOOL;
		Disable : ARRAY[0..19]OF BOOL;
	END_STRUCT;
	Inverter_Type : 	STRUCT 
		State : Inverter_State_Type;
		Drive : ARRAY[0..19]OF Inverter_Drive_Type;
	END_STRUCT;
	Invalchk_History_Type : 	STRUCT 
		Element : ARRAY[0..4]OF INT;
		Disable : ARRAY[0..4]OF UINT;
	END_STRUCT;
	Invalchk_Type : 	STRUCT 
		Index : UINT;
		MinIndex : UINT;
		MaxIndex : UINT;
		HistoryIndex : USINT;
		HistoryTextNumber : UINT;
		History : Invalchk_History_Type;
		HMI : Invalchk_Com_Type;
	END_STRUCT;
	InverterAlarmCheck_type : 	STRUCT 
		AlarmVC : InverterAlarmCheckVC_type;
		AlarmPage : InverterAlarmCheckPage_type;
		AlarmPageInfo : InverterAlarmCheckPageInfo_type;
	END_STRUCT;
	InverterAlarmCheckPage_type : 	STRUCT 
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		SelectedItem : USINT;
		InverterNodeArray : ARRAY[0..6]OF STRING[18];
		InverterStateArray : ARRAY[0..6]OF UINT;
	END_STRUCT;
	InverterAlarmCheckPageInfo_type : 	STRUCT 
		cmdInit : USINT;
		cmdAckEmcyAlarm : USINT;
		cmdScrollNextInverter : USINT;
		cmdScrollPrevInverter : USINT;
		cmdRefresh : USINT;
		ScrollInverterNumber : USINT;
		NodeNumber : USINT;
		DrvRunStatus : UINT;
		InverterStatus : UINT;
		ErrorDetail : errorData_s;
		EmcyDetail : emcyObjData_s;
	END_STRUCT;
	InverterAlarmCheckVC_type : 	STRUCT 
		Trigger : ARRAY[0..9]OF BOOL;
		Bypass : ARRAY[0..9]OF BOOL;
		Acknowledge : ARRAY[0..9]OF BOOL;
		GroupAlarm : USINT;
	END_STRUCT;
	InverterDiag_Type : 	STRUCT 
		Initializing : UINT;
		Error : BOOL;
		NumberOfDrives : UINT;
		ComStatus : ARRAY[0..20]OF Invalchk_Com_Type;
		ActStatus : ARRAY[0..20]OF UINT;
	END_STRUCT;
	IoAlarmCheck_Type : 	STRUCT 
		Io : IoAlarmCheckIo_Type;
		Vc : IoAlarmCheckVc_Type;
		Page : IoAlarmCheckPage_Type;
	END_STRUCT;
	IoAlarmCheckIo_Type : 	STRUCT 
		Module : ARRAY[0..252]OF IoAlarmCheckIoModule_Type;
	END_STRUCT;
	IoAlarmCheckIoModule_Type : 	STRUCT 
		ModuleOk : BOOL;
		PSwarnOverCurrent : BOOL;
		PSwarnFromHW : BOOL;
		SupplyBusCurrent : USINT;
		SupplyBusVoltage : USINT;
		ModuleId : UINT;
		HardwareVersion : UINT;
		SoftwareVersion : UINT;
	END_STRUCT;
	IoAlarmCheckPage_Type : 	STRUCT 
		ModuleList : ARRAY[0..9]OF STRING[32];
		cmdScrollUp : USINT;
		cmdScrollDown : USINT;
		SelectedItem : USINT;
		PSInfo : IoAlarmCheckIoModule_Type;
		cmdPrevSupply : USINT;
		cmdNextSupply : USINT;
		cmdRefreshSupply : USINT;
		ModuleNbSupply : UINT;
	END_STRUCT;
	IoAlarmCheckVc_Type : 	STRUCT 
		Trigger : ARRAY[0..3]OF BOOL;
		Bypass : ARRAY[0..3]OF BOOL;
		Acknowledge : ARRAY[0..3]OF BOOL;
		Group : USINT;
	END_STRUCT;
	ServiceLog_Type : 	STRUCT 
		Index : UINT;
		Timestamp : DATE_AND_TIME;
		Event : AlarmEvent_Type;
	END_STRUCT;
	Time_Type : 	STRUCT 
		Date_Time : DATE_AND_TIME;
		Split : DTStructure;
	END_STRUCT;
END_TYPE
