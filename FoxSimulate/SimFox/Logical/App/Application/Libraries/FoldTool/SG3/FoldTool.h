/* Automation Studio generated header file */
/* Do not edit ! */
/* FoldTool 3.00.0 */

#ifndef _FOLDTOOL_
#define _FOLDTOOL_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _FoldTool_VERSION
#define _FoldTool_VERSION 3.00.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "brsystem.h"
#endif
#ifdef _SG4
		#include "brsystem.h"
#endif
#ifdef _SGC
		#include "brsystem.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define EXOBJ_DISABLED 90U
 #define EXOBJ_DISABLED_90 90U
 #define EXOBJ_FINISHED_UNLOADING 32U
 #define EXOBJ_FINISHED_UNLOADING_32 32U
 #define EXOBJ_OFF 0U
 #define EXOBJ_OFF_0 0U
 #define EXOBJ_READY_TO_RECIEVE 15U
 #define EXOBJ_READY_TO_RECIEVE_15 15U
 #define EXOBJ_RECIEVE_DONE_18 18U
 #define EXOBJ_RECIEVING_16 16U
 #define EXOBJ_RUNNING 20U
 #define EXOBJ_RUNNING_20 20U
 #define EXOBJ_STANDBY 10U
 #define EXOBJ_STANDBY_10 10U
 #define EXOBJ_UNLOADING 31U
 #define EXOBJ_UNLOADING_31 31U
 #define EXOBJ_WANT_TO_UNLOAD 30U
 #define EXOBJ_WANT_TO_UNLOAD_30 30U
 #define FOLDIO_STATE_ACTIVATED_3 3U
 #define FOLDIO_STATE_DELAYING_2 2U
 #define FOLDIO_STATE_IDLE_0 0U
 #define FOLDIO_STATE_KICKSTART_4 4U
 #define FOLDIO_STATE_START_1 1U
 #define FOLD_PROC_STATE_AT_HOME_36 36U
 #define FOLD_PROC_STATE_AT_OUT_37 37U
 #define FOLD_PROC_STATE_AT_POS_38 38U
 #define FOLD_PROC_STATE_BYPASS_18 18U
 #define FOLD_PROC_STATE_ERROR_99 99U
 #define FOLD_PROC_STATE_FOLD_POINT_15 15U
 #define FOLD_PROC_STATE_GOING_HOME_33 33U
 #define FOLD_PROC_STATE_GOING_OUT_34 34U
 #define FOLD_PROC_STATE_GOING_POS_35 35U
 #define FOLD_PROC_STATE_GO_HOME_30 30U
 #define FOLD_PROC_STATE_GO_OUT_31 31U
 #define FOLD_PROC_STATE_GO_TO_POS_32 32U
 #define FOLD_PROC_STATE_INIT_0 0U
 #define FOLD_PROC_STATE_PRESS_OUT_40 40U
 #define FOLD_PROC_STATE_READY_10 10U
 #define FOLD_PROC_STATE_RUN_11 11U
 #define FOLD_PROC_STATE_SERVICE_8 8U
 #define FOLD_PROC_STATE_STARTUP_1 1U
 #define FOLD_PROC_STATE_TRIG_ERROR_98 98U
 #define FOLD_PROC_STATE_UNKNOWN_39 39U
 #define FOLD_PROC_STATE_WAIT_EXIT_20 20U
 #define FOLD_PROC_STATE_WAIT_FOLD_13 13U
 #define FOLD_PROC_STATE_WAIT_TRIG_12 12U
 #define MACHMGR_DOOR_IS_OPEN 5U
 #define MACHMGR_ERROR_IN_MACHINE 99U
 #define MACHMGR_ERROR_IN_PROCESS 91U
 #define MACHMGR_HOLD_DO_NEXT_STEP 10U
 #define MACHMGR_IDLE 0U
 #define MACHPROC_DELIVER_PACKAGE_80 80U
 #define MACHPROC_ERROR_99 99U
 #define MACHPROC_FORCED_STOP 16U
 #define MACHPROC_HOLD_97 97U
 #define MACHPROC_INIT_0 0U
 #define MACHPROC_MANUAL_8 8U
 #define MACHPROC_PACKAGE_DELIVERED_81 81U
 #define MACHPROC_RUN_20 20U
 #define MACHPROC_STARTUP_1 1U
 #define MACHPROC_STOP_15 15U
 #define MACHPROC_TRIG_ERROR_98 98U
#else
 _GLOBAL_CONST unsigned short EXOBJ_DISABLED;
 _GLOBAL_CONST unsigned short EXOBJ_DISABLED_90;
 _GLOBAL_CONST unsigned short EXOBJ_FINISHED_UNLOADING;
 _GLOBAL_CONST unsigned short EXOBJ_FINISHED_UNLOADING_32;
 _GLOBAL_CONST unsigned short EXOBJ_OFF;
 _GLOBAL_CONST unsigned short EXOBJ_OFF_0;
 _GLOBAL_CONST unsigned short EXOBJ_READY_TO_RECIEVE;
 _GLOBAL_CONST unsigned short EXOBJ_READY_TO_RECIEVE_15;
 _GLOBAL_CONST unsigned short EXOBJ_RECIEVE_DONE_18;
 _GLOBAL_CONST unsigned short EXOBJ_RECIEVING_16;
 _GLOBAL_CONST unsigned short EXOBJ_RUNNING;
 _GLOBAL_CONST unsigned short EXOBJ_RUNNING_20;
 _GLOBAL_CONST unsigned short EXOBJ_STANDBY;
 _GLOBAL_CONST unsigned short EXOBJ_STANDBY_10;
 _GLOBAL_CONST unsigned short EXOBJ_UNLOADING;
 _GLOBAL_CONST unsigned short EXOBJ_UNLOADING_31;
 _GLOBAL_CONST unsigned short EXOBJ_WANT_TO_UNLOAD;
 _GLOBAL_CONST unsigned short EXOBJ_WANT_TO_UNLOAD_30;
 _GLOBAL_CONST unsigned short FOLDIO_STATE_ACTIVATED_3;
 _GLOBAL_CONST unsigned short FOLDIO_STATE_DELAYING_2;
 _GLOBAL_CONST unsigned short FOLDIO_STATE_IDLE_0;
 _GLOBAL_CONST unsigned short FOLDIO_STATE_KICKSTART_4;
 _GLOBAL_CONST unsigned short FOLDIO_STATE_START_1;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_AT_HOME_36;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_AT_OUT_37;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_AT_POS_38;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_BYPASS_18;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_ERROR_99;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_FOLD_POINT_15;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GOING_HOME_33;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GOING_OUT_34;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GOING_POS_35;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GO_HOME_30;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GO_OUT_31;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_GO_TO_POS_32;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_INIT_0;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_PRESS_OUT_40;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_READY_10;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_RUN_11;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_SERVICE_8;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_STARTUP_1;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_TRIG_ERROR_98;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_UNKNOWN_39;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_WAIT_EXIT_20;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_WAIT_FOLD_13;
 _GLOBAL_CONST unsigned short FOLD_PROC_STATE_WAIT_TRIG_12;
 _GLOBAL_CONST unsigned short MACHMGR_DOOR_IS_OPEN;
 _GLOBAL_CONST unsigned short MACHMGR_ERROR_IN_MACHINE;
 _GLOBAL_CONST unsigned short MACHMGR_ERROR_IN_PROCESS;
 _GLOBAL_CONST unsigned short MACHMGR_HOLD_DO_NEXT_STEP;
 _GLOBAL_CONST unsigned short MACHMGR_IDLE;
 _GLOBAL_CONST unsigned short MACHPROC_DELIVER_PACKAGE_80;
 _GLOBAL_CONST unsigned short MACHPROC_ERROR_99;
 _GLOBAL_CONST unsigned short MACHPROC_FORCED_STOP;
 _GLOBAL_CONST unsigned short MACHPROC_HOLD_97;
 _GLOBAL_CONST unsigned short MACHPROC_INIT_0;
 _GLOBAL_CONST unsigned short MACHPROC_MANUAL_8;
 _GLOBAL_CONST unsigned short MACHPROC_PACKAGE_DELIVERED_81;
 _GLOBAL_CONST unsigned short MACHPROC_RUN_20;
 _GLOBAL_CONST unsigned short MACHPROC_STARTUP_1;
 _GLOBAL_CONST unsigned short MACHPROC_STOP_15;
 _GLOBAL_CONST unsigned short MACHPROC_TRIG_ERROR_98;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct Counter_Type
{	plcbit Input;
	unsigned short Status;
	unsigned short StartTimer;
	unsigned short OnDelay;
	unsigned short OffDelay;
	unsigned short Counter;
	unsigned short TrailCounter;
	unsigned short OldCounter;
	unsigned short OldTrailCounter;
	unsigned short MuteTime;
	plcbit Output;
} Counter_Type;

typedef struct FoldIOCounter_Type
{	plcbit Input;
	unsigned short Status;
	unsigned short StartTimer;
	unsigned short OnDelay;
	unsigned short OffDelay;
	unsigned short Counter;
	unsigned short EdgeCounter;
	unsigned short TrailCounter;
	plcbit EdgeFlank;
	plcbit TrailFlank;
	unsigned short OldCounter;
	unsigned short OldEdgeCounter;
	unsigned short OldTrailCounter;
	plcbit Output;
} FoldIOCounter_Type;

typedef struct FoldIO_Type
{	plcstring Name[22];
	unsigned short State;
	unsigned short StartDelayTime;
	unsigned short Timer;
	unsigned short DoRunTimes;
	unsigned short HasRunTimes;
	unsigned short OnTime;
	plcbit Output;
} FoldIO_Type;

typedef struct FoldItem_Type
{	unsigned short Category;
	unsigned short FoldProgram;
	unsigned short Article;
	unsigned short ClientNumber;
} FoldItem_Type;

typedef struct FoldLogVariable_Type
{	unsigned short Index;
	unsigned short ProcessStage;
	unsigned short CurTimer;
	plcstring StageName[22];
	plcstring Text[22];
	unsigned short Value;
	unsigned short StatusCode;
	plcdt TimeStamp;
} FoldLogVariable_Type;

typedef struct FoldProcessControl_Type
{	unsigned short Id;
	plcstring Name[22];
	unsigned short State;
	unsigned short ErrorCode;
	plcbit Run;
	plcbit Ready;
	plcbit ResetAlarm;
	unsigned short NextItemFlag;
	plcbit StageComplete;
	plcbit ByPass;
	plcbit Simulate;
	plcbit Service;
	plcbit DebugLogFlag;
} FoldProcessControl_Type;

typedef struct FoldManager_Type
{	struct FoldProcessControl_Type FoldProcessesControl[21];
} FoldManager_Type;

typedef struct FoldPositioningMotor_Type
{	unsigned short State;
	plcbit Enable;
	unsigned short Flag;
	plcbit Simulate;
	unsigned short HomeMaxMiscount;
	plcbit HomePosition;
	plcbit OutPosition;
	signed long CurrentPosition;
	signed long TargetPosition;
	signed short TargetRange;
	plcbit Reset;
	plcbit MotorRun;
	plcbit MotorDirection;
	unsigned short MotorLowSpeed;
	unsigned short MotorHighSpeed;
	unsigned short MotorSpeed;
	unsigned short BrakeDistance;
	unsigned short MaxRunTime;
	unsigned short MaxRunTimer;
	unsigned short ErrorCode;
	plcstring Name[12];
} FoldPositioningMotor_Type;

typedef struct FoldSpeedMotor_Type
{	unsigned short State;
	plcbit Enable;
	unsigned short Flag;
	plcbit Simulate;
	unsigned short TargetPosition;
	plcbit HomePosition;
	plcbit OutPosition;
	plcbit HomeBreakPosition;
	plcbit OutBreakPosition;
	plcbit InFastZone;
	plcbit Reset;
	plcbit MotorRun;
	plcbit MotorDirection;
	unsigned short MotorLowSpeed;
	unsigned short MotorHighSpeed;
	unsigned short MotorPressSpeed;
	unsigned short MotorSpeed;
	unsigned short MotorPressOutTime;
	unsigned short MotorPressOutTimer;
	unsigned short MaxRunTime;
	unsigned short MaxRunTimer;
	unsigned short ErrorCode;
	plcstring Name[12];
} FoldSpeedMotor_Type;

typedef struct FoldSpeedPositionMotor_Type
{	unsigned short State;
	plcbit Enable;
	unsigned short Flag;
	plcbit Simulate;
	unsigned short HomeMaxMiscount;
	plcbit HomePosition;
	plcbit OutPosition;
	plcbit HomeBreakPosition;
	plcbit OutBreakPosition;
	plcbit InFastZone;
	signed long CurrentPosition;
	signed long TargetPosition;
	signed short TargetRange;
	plcbit Reset;
	plcbit MotorRun;
	plcbit MotorDirection;
	unsigned short MotorLowSpeed;
	unsigned short MotorHighSpeed;
	unsigned short MotorSpeed;
	unsigned short MotorPressSpeed;
	unsigned short MotorPressOutTime;
	unsigned short MotorPressOutTimer;
	unsigned short BrakeDistance;
	unsigned short MaxRunTime;
	unsigned short MaxRunTimer;
	unsigned short ErrorCode;
	plcstring Name[12];
} FoldSpeedPositionMotor_Type;

typedef struct HoldCheck_Type
{	unsigned short InCounter;
	unsigned short OutCounter;
	plcbit Activated;
	signed short State;
} HoldCheck_Type;

typedef struct MachineProcessControl_Type
{	unsigned short Id;
	plcstring Name[22];
	unsigned short State;
	unsigned short OldState;
	unsigned short ErrorCode;
	plcbit Run;
	plcbit ForcedStop;
	plcbit ResetAlarm;
	struct HoldCheck_Type HoldObject;
	signed short ControlFlag;
	plcbit Simulate;
	plcbit Service;
} MachineProcessControl_Type;

typedef struct MachineManager_Type
{	struct MachineProcessControl_Type MachineProcessControl[21];
} MachineManager_Type;

typedef struct PositionModule_Type
{	unsigned short State;
	plcbit Enable;
	plcbit CountA;
	plcbit CountB;
	plcbit OldCountA;
	plcbit OldCountB;
	plcbit OldA_Xor;
	plcbit A_Xor;
	plcbit B_Xor;
	plcbit OldAXor;
	plcbit OldBXor;
	signed char TrigCount;
	signed long CurrentPosition;
	plcbit Reset;
	plcbit Direction;
	plcbit CountDirection;
} PositionModule_Type;

typedef struct TimerCount_Type
{	unsigned short _1_ms;
	unsigned short _10_ms;
	unsigned short _1_sec;
} TimerCount_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long RunPositionModule(struct PositionModule_Type* PositionModule);
_BUR_PUBLIC unsigned short GetMsTimer(void);
_BUR_PUBLIC unsigned short ElapsedMsTime(unsigned short CurTimer, unsigned short StartTime);
_BUR_PUBLIC signed long ActivateFoldIO(struct FoldIO_Type* FoldIO, unsigned short CurTimer);
_BUR_PUBLIC signed long InitPositioningMotor(struct FoldPositioningMotor_Type* PositioningMotor, plcstring* Name);
_BUR_PUBLIC signed long RunPositioningMotor(struct FoldPositioningMotor_Type* PositioningMotor, unsigned short CurTimer);
_BUR_PUBLIC signed long InitSpeedMotor(struct FoldSpeedMotor_Type* SpeedMotor, plcstring* Name);
_BUR_PUBLIC signed long RunSpeedMotor(struct FoldSpeedMotor_Type* SpeedMotor, unsigned short CurTimer);
_BUR_PUBLIC signed long dummy(struct MachineManager_Type* machmanager);
_BUR_PUBLIC plcbit ActivateHold(struct HoldCheck_Type* HoldObject, plcbit State);
_BUR_PUBLIC plcbit SetHold(struct HoldCheck_Type* HoldObject, plcbit NextStep);
_BUR_PUBLIC plcbit CheckHold(struct HoldCheck_Type* HoldObject);
_BUR_PUBLIC signed long SetTimerCount(struct TimerCount_Type* Timers);
_BUR_PUBLIC signed long InitCounterModule(struct Counter_Type* Counter);
_BUR_PUBLIC signed long RunCounterModule(struct Counter_Type* Counter);
_BUR_PUBLIC signed long RunIOCounter(struct FoldIOCounter_Type* IOCounter, unsigned short CurTimer);
_BUR_PUBLIC signed long GetIOCounterEdgeFlank(struct FoldIOCounter_Type* IOCounter);
_BUR_PUBLIC signed long GetIOCounterTrailFlank(struct FoldIOCounter_Type* IOCounter);
_BUR_PUBLIC signed long RunSpeedPosMotor(struct FoldSpeedPositionMotor_Type* SpeedPosMotor, unsigned short CurTimer);
_BUR_PUBLIC signed long InitSpeedPosMotor(struct FoldSpeedPositionMotor_Type* SpeedPosMotor, plcstring* Name);


#ifdef __cplusplus
};
#endif
#endif /* _FOLDTOOL_ */

