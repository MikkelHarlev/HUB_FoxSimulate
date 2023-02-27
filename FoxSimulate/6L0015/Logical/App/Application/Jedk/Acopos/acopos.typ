(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: ServoLib
 * File: ServoLib.typ
 * Author: sobkowskib
 * Created: July 28, 2015
 ********************************************************************
 * Data types of library ServoLib
 ********************************************************************)

TYPE
	MasterAXIS_Enum : 
		(
		AXIS_MASTER_IDLE := 0,
		AXIS_MASTER_RESETTING := 1,
		AXIS_MASTER_POWER_ON := 2,
		AXIS_MASTER_HOMING := 3,
		AXIS_MASTER_HOMED := 4,
		AXIS_MASTER_RUNSTATE := 10,
		AXIS_MASTER_STOP := 100,
		AXIS_MASTER_STOP_WAIT := 101,
		AXIS_MASTER_POWER_OF := 102,
		AXIS_MASTER_POWER_OF_WAIT := 103,
		AXIS_MASTER_UPLOAD_ERROR := 300,
		AXIS_MASTER_ERROR_RESET := 301
		);
END_TYPE
