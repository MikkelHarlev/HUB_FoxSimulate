(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Package: BlackBox
 * File: BlackBox.typ
 * Author: eg
 * Created: December 22, 2010
 ********************************************************************
 * Data types of package BlackBox
 ********************************************************************)

TYPE
	BlackboxMachineRuntime_Type : 	STRUCT 
		LoadID : ARRAY[0..9]OF UDINT;
		RcpNo : ARRAY[0..9]OF USINT;
		ArtNo : ARRAY[0..9]OF UDINT;
		CustNo : ARRAY[0..9]OF UDINT;
		RcpText : ARRAY[0..9]OF STRING[32];
		ArtText : ARRAY[0..9]OF STRING[32];
		CustText : ARRAY[0..9]OF STRING[32];
		Norm : ARRAY[0..9]OF UINT;
		FlowTimeOut : ARRAY[0..9]OF UINT;
		Primary : ARRAY[0..9]OF UINT;
		Reference : ARRAY[0..9]OF UINT;
		ActiveProductionUnits : ARRAY[0..9]OF USINT;
		DisableOperatorLog : BOOL;
		OperatorLogDelay : UINT;
		BatchID : ARRAY[0..9]OF UDINT;
		SourceID : ARRAY[0..9]OF UDINT;
	END_STRUCT;
	BlackboxMachineInterface_Type : 	STRUCT 
		ActiveProductionUnits : ARRAY[0..MAX_NUMBER_OF_STACKERS]OF USINT;
	END_STRUCT;
	BlackboxMachineSetup_Type : 	STRUCT 
		ProductionUnits : USINT;
		Attendants : USINT;
		LogOperators : BOOL;
		MachineType : STRING[32];
		LogTaskName : ARRAY[0..19]OF STRING[32];
		MultiRcp : BOOL;
		CounterName : STRING[32];
		ChangeDelay : UDINT;
		Enabled : BOOL;
		AddOns : ARRAY[0..19]OF LogAddOn_Type;
		subIDName : STRING[32];
	END_STRUCT;
END_TYPE
