(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Axis1
 * File: Axis1.typ
 * Author: corduak
 * Created: September 25, 2014
 ********************************************************************
 * Local data types of program Axis1
 ********************************************************************)

TYPE
	axis_local_type : 	STRUCT 
		allReady : BOOL;
		TempCounter : UINT;
		DelayAlarmCheck : UINT;
		Resetting : BOOL;
		Error : BOOL;
		BR_InitCyclicRead : MC_BR_InitCyclicRead;
		BR_ReadReqParID : MC_BR_ReadParID;
		BR_ReadParID : MC_BR_ReadParID;
		BR_WriteParID : MC_BR_WriteParID;
		Home : MC_Home;
		MoveAbsolute : MC_MoveAbsolute;
		Follow : MC_Follow;
		MoveAdditive : MC_MoveAdditive;
		MoveVelocity : MC_MoveVelocity;
		Power : MC_Power;
		ReadActualPosition : MC_ReadActualPosition;
		ReadActualTorque : MC_ReadActualTorque;
		ReadActualVelocity : MC_ReadActualVelocity;
		ReadAxisError : MC_ReadAxisError;
		ReadStatus : MC_ReadStatus;
		ReadLagError : MC_BR_InitCyclicRead;
		Reset : MC_Reset;
		Stop : MC_Stop;
		TorqueMode : MC_TorqueMode;
		TorquePull : MC_TorquePull;
		MasterState : MasterAXIS_Enum;
	END_STRUCT;
END_TYPE
