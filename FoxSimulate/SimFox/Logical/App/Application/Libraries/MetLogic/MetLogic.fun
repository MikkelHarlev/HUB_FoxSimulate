
FUNCTION InitFullReg : DINT
	VAR_INPUT
		FullData : Full_Type;
	END_VAR
END_FUNCTION

FUNCTION FullReg : BOOL
	VAR_INPUT
		FullData : Full_Type;
	END_VAR
END_FUNCTION

FUNCTION RunMotor : DINT
	VAR_INPUT
		MotorType : Motor_Type;
	END_VAR
END_FUNCTION

FUNCTION EmptyDistributor : DINT
	VAR_INPUT
		MTEmpty : EmptyDistributor_Type;
	END_VAR
END_FUNCTION

FUNCTION FlankBOOL : DINT
	VAR_INPUT
		IN : FlankBool_Type;
	END_VAR
END_FUNCTION

FUNCTION Flash : BOOL
	VAR_INPUT
		IN : Flash_Type;
	END_VAR
END_FUNCTION

FUNCTION Clamp : DINT
	VAR_INPUT
		IN : Clamp_Type;
	END_VAR
END_FUNCTION

FUNCTION StepFeed : DINT
	VAR_INPUT
		IN : StepFeed_Type;
	END_VAR
END_FUNCTION

FUNCTION Detect : DINT
	VAR_INPUT
		IN : Detect_Type;
	END_VAR
END_FUNCTION

FUNCTION FlipDetect : DINT
	VAR_INPUT
		IN : FlipDetect_Type;
	END_VAR
END_FUNCTION

FUNCTION FlankINT : DINT
	VAR_INPUT
		IN : FlankInt_Type;
	END_VAR
END_FUNCTION

FUNCTION BOOL2BIN : DINT
	VAR_INPUT
		IN : B2Bin_Type;
	END_VAR
END_FUNCTION

FUNCTION BOOL2BCD : DINT
	VAR_INPUT
		IN : B2Bcd_Type;
	END_VAR
END_FUNCTION

FUNCTION EmptyClk : DINT
	VAR_INPUT
		IN : EmptyClk_Type;
	END_VAR
END_FUNCTION

FUNCTION STFClk : DINT
	VAR_INPUT
		IN : STFClk_Type;
	END_VAR
END_FUNCTION

FUNCTION InitMotor : DINT
	VAR_INPUT
		Motor : Motor_Type;
	END_VAR
END_FUNCTION

FUNCTION SetLatch : BOOL
	VAR_INPUT
		latch : Latch_Type;
		state : BOOL;
	END_VAR
END_FUNCTION

FUNCTION GetLatch : BOOL
	VAR_INPUT
		latch : Latch_Type;
	END_VAR
END_FUNCTION

FUNCTION RunSyncroFeed : DINT
	VAR_INPUT
		SyncroFeeder : SyncroFeed_Type;
	END_VAR
END_FUNCTION

FUNCTION InitSyncroFeed : DINT
	VAR_INPUT
		SyncroFeeder : SyncroFeed_Type;
		Id : UINT;
		Motor : Motor_Type;
		NumberOfFeeders : UINT;
		FeederBlockTime : UINT;
		StopperDownTime : UINT;
	END_VAR
END_FUNCTION

FUNCTION InitDestinationScanner : DINT
	VAR_INPUT
		DistributionScanner : DistributionScanner;
		Id : UINT;
		NumberOfDestinations : UINT;
		Mode : UINT;
	END_VAR
END_FUNCTION

FUNCTION GetDistributionDestination : INT
	VAR_INPUT
		DistributionScanner : DistributionScanner;
	END_VAR
END_FUNCTION

FUNCTION InitDistributionScanner : DINT
	VAR_INPUT
		DistributionScanner : DistributionScanner;
		Id : UINT;
		NumberOfDestinations : UINT;
		Mode : UINT;
	END_VAR
END_FUNCTION

FUNCTION RunEasyLoad : UINT (*TODO: Add your comment here*) (*$GROUP=User*)
	VAR_INPUT
		EasyLoader : EasyLoader_Type;
	END_VAR
END_FUNCTION

FUNCTION RunMetMerge : UINT (*TODO: Add your comment here*) (*$GROUP=User*)
	VAR_INPUT
		Merge : MetMerge_Type;
	END_VAR
END_FUNCTION

FUNCTION RunMetriFeedSlide : UINT (*TODO: Add your comment here*) (*$GROUP=User*)
	VAR_INPUT
		MetriFeedSlide : MetriFeedSlide_Type;
	END_VAR
END_FUNCTION
