
FUNCTION RunPositionModule : DINT
	VAR_INPUT
		PositionModule : PositionModule_Type;
	END_VAR
END_FUNCTION

FUNCTION GetMsTimer : UINT
END_FUNCTION

FUNCTION ElapsedMsTime : UINT
	VAR_INPUT
		CurTimer : UINT;
		StartTime : UINT;
	END_VAR
END_FUNCTION

FUNCTION ActivateFoldIO : DINT
	VAR_INPUT
		FoldIO : FoldIO_Type;
		CurTimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION InitPositioningMotor : DINT
	VAR_INPUT
		PositioningMotor : FoldPositioningMotor_Type;
		Name : STRING[11];
	END_VAR
END_FUNCTION

FUNCTION RunPositioningMotor : DINT
	VAR_INPUT
		PositioningMotor : FoldPositioningMotor_Type;
		CurTimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION InitSpeedMotor : DINT
	VAR_INPUT
		SpeedMotor : FoldSpeedMotor_Type;
		Name : STRING[11];
	END_VAR
END_FUNCTION

FUNCTION RunSpeedMotor : DINT
	VAR_INPUT
		SpeedMotor : FoldSpeedMotor_Type;
		CurTimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION dummy : DINT
	VAR_INPUT
		machmanager : MachineManager_Type;
	END_VAR
END_FUNCTION

FUNCTION ActivateHold : BOOL
	VAR_INPUT
		HoldObject : HoldCheck_Type;
		State : BOOL;
	END_VAR
END_FUNCTION

FUNCTION SetHold : BOOL
	VAR_INPUT
		HoldObject : HoldCheck_Type;
		NextStep : BOOL;
	END_VAR
END_FUNCTION

FUNCTION CheckHold : BOOL
	VAR_INPUT
		HoldObject : HoldCheck_Type;
	END_VAR
END_FUNCTION

FUNCTION SetTimerCount : DINT
	VAR_INPUT
		Timers : TimerCount_Type;
	END_VAR
END_FUNCTION

FUNCTION InitCounterModule : DINT
	VAR_INPUT
		Counter : Counter_Type;
	END_VAR
END_FUNCTION

FUNCTION RunCounterModule : DINT
	VAR_INPUT
		Counter : Counter_Type;
	END_VAR
END_FUNCTION

FUNCTION RunIOCounter : DINT
	VAR_INPUT
		IOCounter : FoldIOCounter_Type;
		CurTimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION GetIOCounterEdgeFlank : DINT
	VAR_INPUT
		IOCounter : FoldIOCounter_Type;
	END_VAR
END_FUNCTION

FUNCTION GetIOCounterTrailFlank : DINT
	VAR_INPUT
		IOCounter : FoldIOCounter_Type;
	END_VAR
END_FUNCTION

FUNCTION RunSpeedPosMotor : DINT
	VAR_INPUT
		SpeedPosMotor : FoldSpeedPositionMotor_Type;
		CurTimer : UINT;
	END_VAR
END_FUNCTION

FUNCTION InitSpeedPosMotor : DINT
	VAR_INPUT
		SpeedPosMotor : FoldSpeedPositionMotor_Type;
		Name : STRING[21];
	END_VAR
END_FUNCTION
