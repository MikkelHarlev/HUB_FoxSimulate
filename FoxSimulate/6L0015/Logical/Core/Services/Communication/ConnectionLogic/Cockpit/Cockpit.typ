(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: LogSimulator
 * File: LogSimulator.typ
 * Author: flystes
 * Created: June 26, 2014
 ********************************************************************
 * Local data types of program LogSimulator
 ********************************************************************)

TYPE
	CockpitLogic_Type : 	STRUCT 
		Interface : CockpitLogicInterface_Type;
		Runtime : CockpitLogicRuntime_Type;
	END_STRUCT;
	CockpitLogicInterface_Type : 	STRUCT 
		logData : CockpitLogicInterfaceSub_Type;
		realtime : CockpitLogicInterfaceSub_Type;
	END_STRUCT;
	CockpitLogicInterfaceSub_Type : 	STRUCT 
		isConnected : BOOL;
		infomationString : STRING[80];
		sentCount : UDINT;
		errorCount : UDINT;
		isInitDone : BOOL;
		isBusy : BOOL;
	END_STRUCT;
	CockpitLogicRuntime_Type : 	STRUCT 
		initState : initState_enum;
		totalCount : UDINT;
		totalRunHours : UDINT;
		totalPowerOnHours : UDINT;
		machineID : UDINT;
		machineIDSlave : UDINT;
		companyID : USINT;
		subIDName : STRING[32];
		subIDNameSlave : STRING[32];
		SQLServerAddress : STRING[24];
		SQLUsername : STRING[21];
		SQLPassword : STRING[21];
		SQLDBName : STRING[32];
		isReady : BOOL;
		updateInterval : UDINT;
	END_STRUCT;
	staticData_type : 	STRUCT 
		parameterName : STRING[32];
		parameterValue : DINT;
		parameterText : STRING[32];
		injectPosition : USINT;
	END_STRUCT;
	VarFieldName_Type : 	STRUCT 
		adr : UDINT;
		len : UDINT;
	END_STRUCT;
	GetVariableData_Type : 	STRUCT 
		enable : BOOL;
		pVarName : UDINT;
		pVarStruct : UDINT;
		CountVariables : UDINT;
		status : UINT;
	END_STRUCT;
	LogRecord_Type : 	STRUCT 
		Event : JDWideLog_Type;
	END_STRUCT;
	LogOriginalRecord_Type : 	STRUCT 
		Index : UINT;
		Timestamp : DATE_AND_TIME;
		Event : JDWideLog_Type;
	END_STRUCT;
	RecordData_Type : 	STRUCT 
		DataVariableAddressListPointer : UDINT;
		DataFieldNameListPointer : UDINT;
		DataVariableFields : UDINT;
		DataFieldNameStartPos : USINT;
	END_STRUCT;
END_TYPE
