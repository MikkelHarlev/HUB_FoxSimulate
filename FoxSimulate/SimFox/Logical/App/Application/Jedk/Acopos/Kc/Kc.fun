
FUNCTION_BLOCK FB_Average
	VAR_INPUT
		countIn : BOOL; (*Count input (one scan)*)
		reset : BOOL; (*Reset input (one scan)*)
		milliSeconds : UDINT; (*Millisecond counter*)
	END_VAR
	VAR_OUTPUT
		avgTime : REAL; (*Calculated average time for last pieces (up to 10)*)
		averageOut : UINT; (*Calculated average pcs/hour last pieces (up to 10)*)
	END_VAR
	VAR
		tempMs : ARRAY[0..10] OF UDINT;
		i : USINT;
		nb : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK MC_TorqueMode
	VAR_INPUT
		Axis : UDINT;
		Execute : BOOL;
		Position : REAL;
		Velocity : REAL;
		Acceleration : REAL;
		Deceleration : REAL;
		Torque : USINT;
		LagLimit : REAL;
		LagError : REAL;
		ActualPosition : REAL;
		ActualVelocity : REAL;
		Release : REAL;
		NewValue : BOOL;
		NewSpeed : BOOL;
		Stop : BOOL;
		StopFbk : BOOL;
		Reset : BOOL;
	END_VAR
	VAR_OUTPUT
		Status : UINT;
		Done : BOOL;
		Error : BOOL;
		fbkStep : UINT;
	END_VAR
	VAR
		NomTorque : USINT;
		Clear : BOOL;
		Direction : BOOL;
		TDReCallABS : USINT;
		MoveAbsolute : MC_MoveAbsolute;
		SetTorquePos : MC_BR_WriteParID;
		SetTorqueNeg : MC_BR_WriteParID;
		zzEdge00000 : BOOL;
		zzEdge00001 : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK MC_TorquePull
	VAR_INPUT
		Axis : UDINT; (*Axis Reference*)
		Execute : BOOL; (*Start Function*)
		Position : REAL; (*Positon*)
		Velocity : REAL; (*Speed*)
		Acceleration : REAL; (*Acceleration*)
		Deceleration : REAL; (*Deceleration*)
		Torque : USINT; (*Torque*)
		LagError : REAL; (*Lag Error*)
		ActualPosition : REAL; (*Actual Position*)
		Stop : BOOL; (*Stop Function*)
		StopFbk : BOOL; (*Stop Function Block*)
		Reset : BOOL; (*Reset To Nominel Torque*)
	END_VAR
	VAR_OUTPUT
		Status : UINT; (*Info : Status*)
		Done : BOOL; (*Info : Function Done*)
		MaxPosition : BOOL; (*Info : Max imum Position Reached*)
		Error : BOOL; (*Info : Error*)
		fbkStep : UINT; (*Info : Function State*)
	END_VAR
	VAR
		NomTorque : USINT; (*Nominel Torque*)
		TDReCallABS : USINT; (*Delay Recall Abs Function*)
		MoveAbsolute : MC_MoveAbsolute; (*Ext. Function MC_MoveAbsolute*)
		SetTorquePos : MC_BR_WriteParID; (*Ext. Function MC_BR_WriteParID*)
		SetTorqueNeg : MC_BR_WriteParID; (*Ext. Function MC_BR_WriteParID*)
		zzEdge00000 : BOOL; (*Front Edge*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK MC_Follow
	VAR_INPUT
		Axis : UDINT; (*Axis Reference*)
		Execute : BOOL; (*Start Function*)
		Position1 : REAL; (*Position When Both Inputs On*)
		Position2 : REAL; (*Position When Both Inputs Off*)
		Velocity : REAL; (*Speed*)
		Acceleration : REAL; (*Acceleration*)
		Deceleration : REAL; (*Deceleration*)
		input1 : BOOL; (*Input 1*)
		input2 : BOOL; (*Input 2*)
		Stop : BOOL; (*Stop Function*)
	END_VAR
	VAR_OUTPUT
		Status : UINT; (*Info : Status*)
		Done : BOOL; (*Info : Function Done*)
		InPosition : BOOL; (*Info : In Position (only 1 Input On)*)
		MaxPosition : BOOL; (*Info : Max imum Position Reached*)
		Error : BOOL; (*Info : Error*)
		fbkStep : UINT; (*Info : Function State*)
	END_VAR
	VAR
		MoveAbsolute : MC_MoveAbsolute; (*Ext. Function MC_MoveAbsolute*)
		StopMotion : MC_Stop; (*Ext. Function MC_Stop*)
		zzEdge00000 : BOOL; (*Front Edge*)
		ReadStatus : MC_ReadStatus;
	END_VAR
END_FUNCTION_BLOCK
