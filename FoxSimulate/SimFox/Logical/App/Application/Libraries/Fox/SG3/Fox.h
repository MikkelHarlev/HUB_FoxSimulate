/* Automation Studio generated header file */
/* Do not edit ! */
/* Fox 1.00.1 */

#ifndef _FOX_
#define _FOX_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _Fox_VERSION
#define _Fox_VERSION 1.00.1
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "runtime.h"
		#include "AsString.h"
		#include "FoldTool.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "runtime.h"
		#include "AsString.h"
		#include "FoldTool.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "runtime.h"
		#include "AsString.h"
		#include "FoldTool.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define EXC_DISABLED_90 90U
 #define STACK_ITEM_MAX_20 20U
 #define EXC_ERROR_99 99U
 #define EXC_FINISHED_UNLOADING_5 5U
 #define EXC_READY_TO_RECIEVE_2 2U
 #define EXC_RECIVING_4 4U
 #define EXC_RECIVING_DONE_6 6U
 #define EXC_STANDBY_0 0U
 #define EXC_UNLOADING_3 3U
 #define EXC_WANT_TO_UNLOAD_1 1U
 #define HOOK_PULSE_FACTOR 190U
 #define HOOK_STATE_EMPTY_0 0U
 #define HOOK_STATE_FILL_DATA_2 2U
 #define HOOK_STATE_STACK_HEADER_1 1U
 #define MACHPROC_WAIT_BEFORE_EXIT_82 82U
 #define MACHPROC_WAIT_FOLD_DONE_28 28U
 #define MACHPROC_WAIT_FOLD_POINT_25 25U
 #define MACHPROC_WAIT_FOR_JOB_22 22U
 #define MACHPROC_WAIT_FOR_TRIG_23 23U
 #define MOTOR_DIRECTION_BACKWARDS_1 1
 #define MOTOR_DIRECTION_FORWARD_0 0
 #define MOTOR_STATE_HOLD_5 5U
 #define MOTOR_STATE_IDLE_1 1U
 #define MOTOR_STATE_REVERSE_4 4U
 #define MOTOR_STATE_RUN_2 2U
 #define MOTOR_STATE_STOP_3 3U
#else
 _GLOBAL_CONST unsigned short EXC_DISABLED_90;
 _GLOBAL_CONST unsigned short STACK_ITEM_MAX_20;
 _GLOBAL_CONST unsigned short EXC_ERROR_99;
 _GLOBAL_CONST unsigned short EXC_FINISHED_UNLOADING_5;
 _GLOBAL_CONST unsigned short EXC_READY_TO_RECIEVE_2;
 _GLOBAL_CONST unsigned short EXC_RECIVING_4;
 _GLOBAL_CONST unsigned short EXC_RECIVING_DONE_6;
 _GLOBAL_CONST unsigned short EXC_STANDBY_0;
 _GLOBAL_CONST unsigned short EXC_UNLOADING_3;
 _GLOBAL_CONST unsigned short EXC_WANT_TO_UNLOAD_1;
 _GLOBAL_CONST unsigned short HOOK_PULSE_FACTOR;
 _GLOBAL_CONST unsigned short HOOK_STATE_EMPTY_0;
 _GLOBAL_CONST unsigned short HOOK_STATE_FILL_DATA_2;
 _GLOBAL_CONST unsigned short HOOK_STATE_STACK_HEADER_1;
 _GLOBAL_CONST unsigned short MACHPROC_WAIT_BEFORE_EXIT_82;
 _GLOBAL_CONST unsigned short MACHPROC_WAIT_FOLD_DONE_28;
 _GLOBAL_CONST unsigned short MACHPROC_WAIT_FOLD_POINT_25;
 _GLOBAL_CONST unsigned short MACHPROC_WAIT_FOR_JOB_22;
 _GLOBAL_CONST unsigned short MACHPROC_WAIT_FOR_TRIG_23;
 _GLOBAL_CONST plcbit MOTOR_DIRECTION_BACKWARDS_1;
 _GLOBAL_CONST plcbit MOTOR_DIRECTION_FORWARD_0;
 _GLOBAL_CONST unsigned short MOTOR_STATE_HOLD_5;
 _GLOBAL_CONST unsigned short MOTOR_STATE_IDLE_1;
 _GLOBAL_CONST unsigned short MOTOR_STATE_REVERSE_4;
 _GLOBAL_CONST unsigned short MOTOR_STATE_RUN_2;
 _GLOBAL_CONST unsigned short MOTOR_STATE_STOP_3;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct Alarm_Type
{	plcbit Alarm[100];
	plcbit Ack[100];
	plcbit AckOld[100];
	plcbit Bypassed[100];
	plcbit DisableFlash[100];
} Alarm_Type;

typedef struct BeltHook_Type
{	unsigned short State;
	unsigned short StackIndex;
} BeltHook_Type;

typedef struct FoldMotor_Type
{	plcstring Name[12];
	unsigned short State;
	plcbit Run;
	plcbit cmdReverse;
	plcbit cmdForward;
	signed short cmdNewSpeed;
	plcbit cmdStop;
	plcbit cmdHold;
	unsigned short Speed;
	unsigned short LowSpeed;
	unsigned short HighSpeed;
	plcbit DoReverse;
	plcbit Direction;
	unsigned short RunTime;
	unsigned short RunTimer;
	unsigned short StopTime;
	unsigned short StopTimer;
	plcbit StartDelayWait;
	unsigned short StartDelayTime;
	unsigned short StartDelayTimer;
} FoldMotor_Type;

typedef struct DeliveryBelt_Type
{	struct BeltHook_Type Hook[11];
	unsigned short Length;
	unsigned short StackCounter;
	unsigned short ExitTime;
	unsigned short ExitTimer;
	plcbit cmdStart;
	unsigned short Function;
	struct FoldMotor_Type Motor;
	struct FoldIOCounter_Type EndSensor;
	unsigned short ExitRecalcTime;
} DeliveryBelt_Type;

typedef struct ProductData_Type
{	unsigned short ID;
	unsigned short AutoProgram;
	unsigned short FoldProgram;
	plcstring RecipeName[81];
	unsigned short LeadEdgeXA;
	unsigned short Length;
	unsigned short LengthWheel;
	unsigned short LengthNoDisc;
	unsigned short LengthStart;
	unsigned short TCExtraRunTime;
	unsigned short Article;
	unsigned short Customer;
	plcbit IsFlapTrousers;
	unsigned short ProductType;
	plcstring HangerId[21];
	plcstring GarmentId[21];
	unsigned short SortOut;
	unsigned short Size;
	unsigned short Stack;
	unsigned short JenWayDestination;
	unsigned long BatchId;
	unsigned short StackChangeIndex;
	unsigned short LastItemOnStack;
	plcbit PreStackChange;
	unsigned short EmpHangLength;
	unsigned short SelectedAutoProg;
	plcbit NoRead;
	unsigned short LogCount;
	signed short LogID;
	plcstring LogMsg[21];
	plcbit IsRouteChange;
	plcbit CustomerStackChange;
	unsigned char Dummy;
	plcbit HangerFlagLeft;
	unsigned short DuoStackChangeIndex;
} ProductData_Type;

typedef struct ExchangeData_Type
{	unsigned short TransferStatus;
	struct ProductData_Type Product;
} ExchangeData_Type;

typedef struct StackItemData_Type
{	unsigned long CustomerId;
	unsigned long ArticleId;
	plcstring HangerId[21];
	plcstring GarmentId[21];
	unsigned short FoldProgram;
} StackItemData_Type;

typedef struct StackData_Type
{	unsigned long BatchId;
	unsigned long CustomerId;
	unsigned short ArticleId;
	unsigned short FoldProgram;
	unsigned short Count;
	unsigned short Destination;
	struct StackItemData_Type ItemData[21];
} StackData_Type;

typedef struct ProcessAlarm_Type
{	plcbit Alarm[26];
	plcbit Ack[26];
	plcbit AckOld[26];
	plcbit Bypassed[26];
	plcbit DisableFlash[26];
} ProcessAlarm_Type;

typedef struct FoldTaskCommon_Type
{	unsigned short State;
	unsigned short Id;
	plcstring Description[32];
	unsigned short ErrorCode;
	plcstring IPAddress[26];
	signed char Batch;
	unsigned short OldState;
	unsigned short SaveState;
	struct ProductData_Type Product;
	plcbit ReadParameters;
	unsigned short CurTimer;
	struct FoldMotor_Type Motor;
	struct FoldIO_Type FoldUnit1;
	struct FoldIO_Type FoldUnit2;
	struct FoldIOCounter_Type InSensor;
	struct FoldIOCounter_Type InSensor2;
	struct FoldIOCounter_Type InSensor3;
	plcbit AllowServiceKeys;
	unsigned short MachineManagerIndex;
	unsigned char LogBookFlag;
	unsigned short TrigMode;
	unsigned short FoldPointTime;
	unsigned short FoldPointTimer;
	unsigned short HoldingPointTime;
	unsigned short HoldingPointTimer;
	unsigned short ExitTimer;
	unsigned short ExitTime;
	struct ProcessAlarm_Type AlarmList;
	unsigned short WatchDogStartupTimer;
	unsigned short WatchDogRunTime;
	unsigned short WatchDogRunTimer;
	unsigned short WatchDogStartupTime;
	struct ExchangeData_Type Previous;
	struct ExchangeData_Type Next;
} FoldTaskCommon_Type;

typedef struct OutletSubUnit_Type
{	signed char Batch;
	unsigned short State;
	unsigned short OldState;
	unsigned short ErrorCode;
	struct ProductData_Type Product;
	plcbit ReadParameters;
	unsigned char LogBookFlag;
	struct ExchangeData_Type Previous;
	struct ExchangeData_Type Next;
} OutletSubUnit_Type;

typedef struct TransportBeltType
{	struct BeltHook_Type Hook[51];
	plcbit IsLoaded;
	unsigned short CycleCounter;
	plcbit cmdStart;
	unsigned short Length;
	unsigned short StackIndex;
	unsigned short MissedStackIndex;
	plcbit OkToStart;
	unsigned short RestartDelay;
	struct FoldIOCounter_Type InSensor;
} TransportBeltType;

typedef struct TaskStatus_Type
{	unsigned short Id;
	plcstring Description[32];
	unsigned short State;
	unsigned short OldState;
	unsigned short ErrorCode;
	unsigned short MyStatus;
	unsigned short ExchangePreviousStatus;
	unsigned short ExchangeNextStatus;
} TaskStatus_Type;

typedef struct MachineProcessHandle_Type
{	struct TaskStatus_Type StatusData;
	plcstring Name[32];
	plcbit Run;
	plcbit ForcedStop;
	plcbit ResetAlarm;
	signed short ControlFlag;
	plcbit Simulate;
	plcbit Service;
} MachineProcessHandle_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned short BiggestResult(unsigned short OriginalSize, unsigned short PartOne);
_BUR_PUBLIC signed long RunDeliveryBelt(struct TransportBeltType* TransportBelt, struct FoldMotor_Type* Motor);
_BUR_PUBLIC signed long DeliveryPositionIsFree(struct TransportBeltType* TransportBelt, unsigned short StartPosition, unsigned short StopPosition);
_BUR_PUBLIC signed long DeliveryPositionIsFree2(struct TransportBeltType* TransportBelt, unsigned short StartPosition, unsigned short StopPosition);
_BUR_PUBLIC signed long FillDeliveryPosition(struct TransportBeltType* TransportBelt, unsigned short StartPosition, unsigned short StopPosition, unsigned short StackIndex);
_BUR_PUBLIC signed long FillDeliveryPosition2(struct TransportBeltType* TransportBelt, unsigned short StartPosition, unsigned short StopPosition, unsigned short StackIndex);
_BUR_PUBLIC signed long RunFoldMotor(plcbit TraceLogEnable, unsigned long DA, struct FoldMotor_Type* FoldMotor, unsigned short CurTimer, unsigned char LogBookFlag);
_BUR_PUBLIC signed long InitFoldTask(struct FoldTaskCommon_Type* FoldTask, struct MachineProcessHandle_Type* MachineManager);
_BUR_PUBLIC signed long RunFoldTask(plcbit TraceLogEnable, unsigned long DA, struct FoldTaskCommon_Type* FoldTask, struct MachineProcessHandle_Type* MachineManager);


#ifdef __cplusplus
};
#endif
#endif /* _FOX_ */

