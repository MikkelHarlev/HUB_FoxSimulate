/* Automation Studio generated header file */
/* Do not edit ! */
/* MetLogic 4.09.0 */

#ifndef _METLOGIC_
#define _METLOGIC_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _MetLogic_VERSION
#define _MetLogic_VERSION 4.09.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "AsString.h"
		#include "MetUtils.h"
#endif
#ifdef _SG4
		#include "AsString.h"
		#include "MetUtils.h"
#endif
#ifdef _SGC
		#include "AsString.h"
		#include "MetUtils.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define METMERGE_STATE_FREE_PASSAGE_30 30U
 #define METMERGE_STATE_RUN_LANE_20 20U
 #define METMERGE_STATE_IDLE_10 10U
 #define METMERGE_STATE_RUN_YIELD_15 15U
 #define METMERGE_STATE_FEEDER_ON_30 30U
 #define METMERGE_STATE_FEEDER_BLOCK_40 40U
 #define METMERGE_STATE_INIT_0 0U
 #define METLOGIC_MAX_SYNCRO_FEEDERS 10U
 #define METLOGIC_MAX_MERGELANES 3U
 #define METEASYLOAD_INIT_0 0U
 #define METEASYLOAD_REFEED_HANGER_13 13U
 #define METEASYLOAD_WAIT_NEW_HANGER_16 16U
 #define METEASYLOAD_READY_5 5U
 #define METEASYLOAD_WAIT_TIME_CLOSE_17 17U
 #define METEASYLOAD_FEED_NEW_HANGER_15 15U
 #define METEASYLOAD_WAIT_OPENING_11 11U
 #define METEASYLOAD_WAIT_START_COM_14 14U
 #define METEASYLOAD_OPENING_10 10U
 #define METEASYLOAD_CLOSE_CLAMP_20 20U
 #define METEASYLOAD_READY_WAIT_6 6U
 #define METEASYLOAD_WAIT_REMOVE_GARM_18 18U
 #define METEASYLOAD_WAIT_HANGER_PASS_12 12U
#else
 _GLOBAL_CONST unsigned short METMERGE_STATE_FREE_PASSAGE_30;
 _GLOBAL_CONST unsigned short METMERGE_STATE_RUN_LANE_20;
 _GLOBAL_CONST unsigned short METMERGE_STATE_IDLE_10;
 _GLOBAL_CONST unsigned short METMERGE_STATE_RUN_YIELD_15;
 _GLOBAL_CONST unsigned short METMERGE_STATE_FEEDER_ON_30;
 _GLOBAL_CONST unsigned short METMERGE_STATE_FEEDER_BLOCK_40;
 _GLOBAL_CONST unsigned short METMERGE_STATE_INIT_0;
 _GLOBAL_CONST unsigned short METLOGIC_MAX_SYNCRO_FEEDERS;
 _GLOBAL_CONST unsigned short METLOGIC_MAX_MERGELANES;
 _GLOBAL_CONST unsigned short METEASYLOAD_INIT_0;
 _GLOBAL_CONST unsigned short METEASYLOAD_REFEED_HANGER_13;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_NEW_HANGER_16;
 _GLOBAL_CONST unsigned short METEASYLOAD_READY_5;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_TIME_CLOSE_17;
 _GLOBAL_CONST unsigned short METEASYLOAD_FEED_NEW_HANGER_15;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_OPENING_11;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_START_COM_14;
 _GLOBAL_CONST unsigned short METEASYLOAD_OPENING_10;
 _GLOBAL_CONST unsigned short METEASYLOAD_CLOSE_CLAMP_20;
 _GLOBAL_CONST unsigned short METEASYLOAD_READY_WAIT_6;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_REMOVE_GARM_18;
 _GLOBAL_CONST unsigned short METEASYLOAD_WAIT_HANGER_PASS_12;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct MetriFeedSlide_Type
{	plcbit Blocked;
	plcbit StopperDown;
	plcbit HangerPassed;
	unsigned short DelayHangerPassedTimer;
	unsigned short DelayHangerPassedTime;
} MetriFeedSlide_Type;

typedef struct Flash_Type
{	unsigned short OnTime;
	unsigned short OffTime;
	unsigned short StartTimeOn;
	unsigned short StartTimeOff;
	unsigned short FlashState;
	plcbit Output;
} Flash_Type;

typedef struct Full_Type
{	unsigned short Id;
	plcbit Input;
	unsigned short Status;
	unsigned short StartTimer;
	unsigned short OnDelay;
	unsigned short OffDelay;
	unsigned short PulseOnTime;
	unsigned short PulseOffTime;
	struct Flash_Type InternalPulse;
	plcbit Output;
	plcbit Pulse;
	plcbit Inverted;
} Full_Type;

typedef struct EasyLoader_Type
{	unsigned short Id;
	unsigned short Status;
	plcbit StartButton;
	plcbit HangerPassed;
	plcbit HangerPresent;
	plcbit GarmentSensor;
	plcbit OutputPin;
	plcbit OutputClamp;
	plcbit OutputSTFAndStops;
	plcbit DeLoadingStation;
	unsigned short CurrentTimer;
	unsigned short WaitTimer;
	unsigned short EmptyTime;
	unsigned short NewHangerTime;
	unsigned short WaitCloseTime;
	unsigned short GarmentRemoveTime;
	unsigned short GarmentRemoveTimer;
	unsigned short StepfeederOpenTimer;
	unsigned short StepfeederOpenTime;
	unsigned short DelayHangerPassedTime;
	struct Full_Type Blocked;
	unsigned short NumberOfHangers;
} EasyLoader_Type;

typedef struct MetMergeLaneType
{	plcbit Presence;
	plcbit PriorityHigh;
	plcbit PriorityLow;
	unsigned short StepFeederOnTime;
	unsigned short IntervalTime;
	unsigned short MinimumFeedingTime;
	plcbit Active;
	plcbit TopSelect;
} MetMergeLaneType;

typedef struct MetMerge_Type
{	struct MetMergeLaneType Lane[4];
	unsigned short ActiveLane;
	unsigned short BestLane;
	unsigned short YieldTime;
	unsigned short YieldTimer;
	unsigned short State;
	plcbit MainRoadBlocked;
	unsigned short CurTimer;
	unsigned short StepFeederTimer;
	unsigned short IntervalTimer;
	unsigned short FeedingTimer;
	unsigned short NumberOfLanes;
} MetMerge_Type;

typedef struct AddInfo_Type
{	signed long InitState;
	signed long RunState;
} AddInfo_Type;

typedef struct B2Bcd_Type
{	plcbit Input01;
	plcbit Input02;
	plcbit Input04;
	plcbit Input08;
	plcbit Input10;
	plcbit Input20;
	plcbit Input40;
	plcbit Input80;
	unsigned char Low;
	unsigned char High;
	unsigned char Value;
} B2Bcd_Type;

typedef struct B2Bin_Type
{	plcbit Input1;
	plcbit Input2;
	plcbit Input3;
	plcbit Input4;
	plcbit Input5;
	plcbit Input6;
	plcbit Input7;
	plcbit Input8;
	unsigned char Value;
} B2Bin_Type;

typedef struct FlankBool_Type
{	plcbit Input;
	plcbit OldState;
	plcbit r;
	plcbit f;
	plcbit c;
} FlankBool_Type;

typedef struct Clamp_Type
{	plcbit InputStartSignal;
	plcbit InputPresence;
	struct FlankBool_Type FInStartSignal;
	struct Full_Type TnPresence;
	struct Full_Type TnActLowerClamp;
	unsigned short TimeActivationLowerClamp;
	unsigned short TimeOnDelayInputPresence;
	plcbit OutputUpperClamp;
	plcbit OutputLowerClamp;
} Clamp_Type;

typedef struct DestinationObject_Type
{	plcbit Enabled;
	plcbit HalfFull;
	plcbit Full;
} DestinationObject_Type;

typedef struct Detect_Type
{	plcbit InputHangerPassed;
	plcbit InputMarkerDetection;
	plcbit SwitchDownOnMarker;
	unsigned short HangerPassedToJustBeforeSwitch;
	unsigned short HangerPassedStartTimer;
	unsigned short MarkerPassedStartTimer;
	plcbit HangerHasPassed;
	plcbit MarkerHasPassed;
	struct FlankBool_Type FEvaluate;
	struct FlankBool_Type FHangerPassed;
	struct FlankBool_Type FMarkerPassed;
	plcbit Output;
} Detect_Type;

typedef struct DistributionScanner
{	unsigned short Id;
	unsigned short NumberOfDestinations;
	struct DestinationObject_Type Destinations[5];
	unsigned short Mode;
	signed short LastSelected;
	plcbit BlockIfAllIsFull;
	struct AddInfo_Type Info;
} DistributionScanner;

typedef struct EmptyClk_Type
{	plcbit InputClockPulse;
	plcbit InputRail;
	plcbit InputLine;
	unsigned short TimeOnDelayRail;
	unsigned short TimeOffDelayRail;
	unsigned short TimeOnDelayLine;
	unsigned short TimeOffDelayLine;
	unsigned short PulseOnTime;
	unsigned short PulseOffTime;
	unsigned short DelayTimePositionSwitch;
	struct Full_Type FullregRail;
	struct Full_Type FullregLine;
	unsigned short StartTimeCp;
	plcbit OldClockPulse;
	plcbit CpHelp;
	struct Flash_Type InternalPulse;
	plcbit OutputStop;
	plcbit OutputStopPulse;
	plcbit OutputSwitch;
} EmptyClk_Type;

typedef struct EmptyDistributor_Type
{	unsigned short Id;
	plcbit RailSensor;
	plcbit LineSensor;
	plcbit BlockRail;
	plcbit BlockLine;
	unsigned short TimeOnDelayRail;
	unsigned short TimeOffDelayRail;
	unsigned short TimeOnDelayLine;
	unsigned short TimeOffDelayLine;
	unsigned short PulseOnTime;
	unsigned short PulseOffTime;
	struct Flash_Type InternalPulse;
	unsigned short Blocktime;
	struct PresenceSensor_Type IntRail;
	struct PresenceSensor_Type IntLine;
	plcbit IntBlock;
	unsigned short BlockStartTimer;
	struct FlankBool_Type FRail;
	struct FlankBool_Type FLine;
	plcbit OutputStop;
	plcbit OutputStopPulse;
	plcbit OutputSwitch;
} EmptyDistributor_Type;

typedef struct FlankInt_Type
{	unsigned long Input;
	unsigned long OldState;
	plcbit r;
	plcbit f;
	plcbit c;
} FlankInt_Type;

typedef struct FlipDetect_Type
{	plcbit HangerPassed;
	plcbit RigthSensor;
	plcbit LeftSensor;
	unsigned short Address1;
	unsigned short Address2;
	unsigned short Address3;
	unsigned short Address4;
	plcbit rxhp;
	plcbit rxrp;
	plcbit rxlp;
	unsigned short StartTime;
	plcbit EvaluateFlag;
	plcbit EvaluateFlagOld;
	unsigned short TimeBeforeNextHanger;
	unsigned short Direction;
} FlipDetect_Type;

typedef struct Latch_Type
{	unsigned short State;
	unsigned short InCount;
	unsigned short OutCount;
} Latch_Type;

typedef struct Motor_Type
{	unsigned short Id;
	plcstring IdString[10];
	plcbit EStop;
	plcbit StartButton;
	plcbit QActive;
	plcbit MotorProtection;
	plcbit ClockPulse;
	plcbit Tension;
	plcbit ResetAlarm;
	plcbit InverterAlarm;
	unsigned short InverterIndex;
	plcbit TrigStart;
	plcbit PauseMotor;
	plcbit Simulate;
	plcbit SimulateAll;
	unsigned short Flag;
	struct FlankBool_Type fStartKey;
	struct FlankBool_Type fQActive;
	struct FlankBool_Type fPauseMotor;
	unsigned short StartDelay;
	unsigned short InverterBootTimeout;
	unsigned short InverterComStatus;
	unsigned short HookTime;
	unsigned short HookTimer;
	unsigned short LastHookTime;
	unsigned short RunTime;
	unsigned short IntState;
	struct Full_Type OnTension;
	unsigned short StartTimeResetInv;
	unsigned short StartTimeCP;
	unsigned short StartTimeSoftStop;
	unsigned short StartTimeStartDelay;
	unsigned short StartTimeInverterBootTimeout;
	unsigned short ResetActivationTime;
	unsigned long StartUpCounter;
	unsigned short OnTimeTension;
	unsigned long HookCounter;
	unsigned short LongClockCounter;
	unsigned short ClockMissPrecent;
	plcbit OldClockPulse;
	unsigned short LastRunTime;
	unsigned long TotalRunTime;
	plcbit TensionAlarm;
	plcbit Contactor;
	plcbit ResetInverter;
	unsigned short Status;
} Motor_Type;

typedef struct STFClk_Type
{	plcbit InputPresence;
	plcbit InputLimitAfterStf;
	plcbit InputClockPulse;
	unsigned short TimeOnDelayPresence;
	unsigned short TimeOnDelayLimitAfterStf;
	unsigned short TimeOffDelayLimitAfterStf;
	unsigned short TimeDelayStf;
	unsigned short TimeBlockStf;
	unsigned short TimeActivationStf;
	unsigned short StartTimeOutput;
	unsigned short StartTimeBlockTime;
	unsigned short StartTimeDelayCp;
	plcbit OldClockPulse;
	plcbit ClockPulseActivated;
	plcbit TimerBlock;
	struct Full_Type FullregPresence;
	struct Full_Type FullregAfterStf;
	unsigned char ActualHangersFeed;
	unsigned char HangersToFeed;
	unsigned char EmptyHooks;
	unsigned char NumberOfEmptyHooks;
	plcbit Output;
} STFClk_Type;

typedef struct StepFeed_Type
{	plcbit InputPresence;
	plcbit InputLimitAfterStf;
	unsigned short TimeOnDelayLimit;
	unsigned short TimeOffDelayLimit;
	unsigned short TimeOnDelayPresence;
	unsigned short TimeActivationStf;
	unsigned short TimeBlockStf;
	struct Full_Type FullregLimit;
	struct Full_Type FullregPresence;
	struct Full_Type FullregBlockStf;
	struct Full_Type FullregActivationStf;
	plcbit Output;
} StepFeed_Type;

typedef struct SyncroFeed_Type
{	unsigned short Id;
	unsigned short NumberOfStoppers;
	plcbit Blocked;
	unsigned long MotorPointer;
	plcbit Stopper[11];
	plcbit StopPresence[11];
	struct PresenceSensor_Type StopPresenceTimer[11];
	unsigned short StopperCounter[11];
	plcbit OldMotorState;
	unsigned short FeederBlockTimer;
	unsigned short FeederBlockTime;
	plcbit StopperDown;
	unsigned short StopperDownTimer;
	unsigned short StopperDownTime;
	plcbit FullDestination;
	struct AddInfo_Type Info;
} SyncroFeed_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long InitFullReg(struct Full_Type* FullData);
_BUR_PUBLIC plcbit FullReg(struct Full_Type* FullData);
_BUR_PUBLIC signed long RunMotor(struct Motor_Type* MotorType);
_BUR_PUBLIC signed long EmptyDistributor(struct EmptyDistributor_Type* MTEmpty);
_BUR_PUBLIC signed long FlankBOOL(struct FlankBool_Type* IN);
_BUR_PUBLIC plcbit Flash(struct Flash_Type* IN);
_BUR_PUBLIC signed long Clamp(struct Clamp_Type* IN);
_BUR_PUBLIC signed long StepFeed(struct StepFeed_Type* IN);
_BUR_PUBLIC signed long Detect(struct Detect_Type* IN);
_BUR_PUBLIC signed long FlipDetect(struct FlipDetect_Type* IN);
_BUR_PUBLIC signed long FlankINT(struct FlankInt_Type* IN);
_BUR_PUBLIC signed long BOOL2BIN(struct B2Bin_Type* IN);
_BUR_PUBLIC signed long BOOL2BCD(struct B2Bcd_Type* IN);
_BUR_PUBLIC signed long EmptyClk(struct EmptyClk_Type* IN);
_BUR_PUBLIC signed long STFClk(struct STFClk_Type* IN);
_BUR_PUBLIC signed long InitMotor(struct Motor_Type* Motor);
_BUR_PUBLIC plcbit SetLatch(struct Latch_Type* latch, plcbit state);
_BUR_PUBLIC plcbit GetLatch(struct Latch_Type* latch);
_BUR_PUBLIC signed long RunSyncroFeed(struct SyncroFeed_Type* SyncroFeeder);
_BUR_PUBLIC signed long InitSyncroFeed(struct SyncroFeed_Type* SyncroFeeder, unsigned short Id, struct Motor_Type* Motor, unsigned short NumberOfFeeders, unsigned short FeederBlockTime, unsigned short StopperDownTime);
_BUR_PUBLIC signed long InitDestinationScanner(struct DistributionScanner* DistributionScanner, unsigned short Id, unsigned short NumberOfDestinations, unsigned short Mode);
_BUR_PUBLIC signed short GetDistributionDestination(struct DistributionScanner* DistributionScanner);
_BUR_PUBLIC signed long InitDistributionScanner(struct DistributionScanner* DistributionScanner, unsigned short Id, unsigned short NumberOfDestinations, unsigned short Mode);
_BUR_PUBLIC unsigned short RunEasyLoad(struct EasyLoader_Type* EasyLoader);
_BUR_PUBLIC unsigned short RunMetMerge(struct MetMerge_Type* Merge);
_BUR_PUBLIC unsigned short RunMetriFeedSlide(struct MetriFeedSlide_Type* MetriFeedSlide);


#ifdef __cplusplus
};
#endif
#endif /* _METLOGIC_ */

