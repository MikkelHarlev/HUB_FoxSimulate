(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Program: Setup
 * File: Setup.typ
 * Author: eg
 * Created: December 22, 2010
 ********************************************************************
 * Local data types of program Setup
 ********************************************************************)

TYPE
	moduleComRuntimeState_Enum : 
		(
		CLEARING, (*Machine state is Clearing*)
		STOPPED, (*Machine state is Stopped*)
		STARTING, (*Machine state is Starting*)
		IDLE_, (*Machine state is Idle*)
		EXECUTE, (*Machine state is Suspended*)
		STOPPING, (*Machine state is Stopping*)
		ABORTING, (*Machine state is Aborting*)
		ABORTED, (*Machine state is Aborted*)
		HOLDING, (*Machine state is Holding*)
		HELD, (*Machine state is Held*)
		UNHOLDING, (*Machine state is UnHolding*)
		SUSPENDING, (*Machine state is Suspending*)
		UNSUSPENDING, (*Machine state is UnSuspending*)
		RESETTING, (*Machine state is Resetting*)
		COMPLETING, (*Machine state is Completing*)
		COMPLETE (*Machine state is Complete*)
		);
	moduleComRuntime_Type : 	STRUCT 
		stateCurrent : moduleComRuntimeState_Enum;
		fieldSignals : BOOL;
		data : BOOL; (*Data Collection*)
		warning : BOOL; (*Warning handling*)
		status : BOOL;
	END_STRUCT;
	moduleComInterfaceCommands_Enum : 
		(
		RESET, (*Reset Command*)
		START, (*Start Command*)
		STOP, (*Stop Command*)
		HOLD, (*Hold Command*)
		UNHOLD, (*Un-Hold Command*)
		SUSPEND, (*Suspend Command*)
		UNSUSPEND, (*Un-Suspend Command*)
		ABORT, (*Abort Command*)
		CLEAR, (*Clear Command*)
		STATECOMPLETE (*State Complete Command*)
		);
	moduleComInterface_Type : 	STRUCT  (*Decoupling HMI from moduleCon, inference from in and outputs*)
		command : moduleComInterfaceCommands_Enum;
		fieldSignals : BOOL; (*Maybe subset of data?*)
		data : BOOL; (*Data input POINTER???*)
		recipeParameters : BOOL; (*Maybe subset of Data?*)
	END_STRUCT;
	moduleCom_Type : 	STRUCT 
		interface : moduleComInterface_Type; (*Input*)
		runtime : moduleComRuntime_Type; (*Output*)
	END_STRUCT;
END_TYPE
