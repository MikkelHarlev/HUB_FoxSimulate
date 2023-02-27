
FUNCTION BiggestResult : UINT
	VAR_INPUT
		OriginalSize : UINT;
		PartOne : UINT;
	END_VAR
END_FUNCTION

FUNCTION RunDeliveryBelt : DINT
	VAR_INPUT
		TransportBelt : TransportBeltType;
		Motor : FoldMotor_Type;
	END_VAR
	VAR
		i : UINT;
		Milliseconds : UDINT;
	END_VAR
END_FUNCTION

FUNCTION DeliveryPositionIsFree : DINT
	VAR_INPUT
		TransportBelt : TransportBeltType;
		StartPosition : UINT;
		StopPosition : UINT;
	END_VAR
	VAR
		i : UINT;
	END_VAR
END_FUNCTION

FUNCTION DeliveryPositionIsFree2 : DINT
	VAR_INPUT
		TransportBelt : TransportBeltType;
		StartPosition : UINT;
		StopPosition : UINT;
	END_VAR
	VAR
		i : UINT;
	END_VAR
END_FUNCTION

FUNCTION FillDeliveryPosition : DINT
	VAR_INPUT
		TransportBelt : TransportBeltType;
		StartPosition : UINT;
		StopPosition : UINT;
		StackIndex : UINT;
	END_VAR
	VAR
		i : UINT;
	END_VAR
END_FUNCTION

FUNCTION FillDeliveryPosition2 : DINT
	VAR_INPUT
		TransportBelt : TransportBeltType;
		StartPosition : UINT;
		StopPosition : UINT;
		StackIndex : UINT;
	END_VAR
	VAR
		i : UINT;
	END_VAR
END_FUNCTION

FUNCTION RunFoldMotor : DINT
	VAR_INPUT
		TraceLogEnable : BOOL; (*104*)
		DA : UDINT; (*80*)
		FoldMotor : FoldMotor_Type;
		CurTimer : UINT;
		LogBookFlag : USINT;
	END_VAR
	VAR
		TmpStr : STRING[15];
	END_VAR
END_FUNCTION

FUNCTION InitFoldTask : DINT
	VAR_INPUT
		FoldTask : FoldTaskCommon_Type;
		MachineManager : MachineProcessHandle_Type;
	END_VAR
	VAR
		i : UINT;
		TmpStr : STRING[81];
	END_VAR
END_FUNCTION

FUNCTION RunFoldTask : DINT
	VAR_INPUT
		TraceLogEnable : BOOL; (*104*)
		DA : UDINT; (*103*)
		FoldTask : FoldTaskCommon_Type;
		MachineManager : MachineProcessHandle_Type;
	END_VAR
	VAR
		i : UINT;
		TmpStr : STRING[81];
		TmpStr1 : STRING[81];
	END_VAR
END_FUNCTION
