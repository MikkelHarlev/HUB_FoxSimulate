(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Package: Application
 * File: CF.typ
 * Author: JENSEN
 * Created: March 11, 2020
 ********************************************************************
 * Data types of package Application
 ********************************************************************)

TYPE
	ACfg_Type : 	STRUCT  (*ACfg_Type*)
		Name : STRING[40];
		WaitTimeInlet : UINT;
		VacuumEnabled : BOOL;
		VacuumFlapDelayOn : UINT;
		VacuumFlapDelayOff : UINT;
		SwingDelay : UINT;
		TShirtBlowDelay : ARRAY[0..1]OF UINT;
		TShirtBlowOnTime : ARRAY[0..1]OF UINT;
		ArmBlowDelay : ARRAY[0..1]OF UINT;
		ArmBlowOnTime : ARRAY[0..1]OF UINT;
		InFeedBeltStartDelay : UINT;
		InFeedBeltOnTime : UINT;
		InFeedBeltStopDelay : UINT;
		InFeedBeltStopTime : UINT;
		InFeedStopOnTrousers : UINT;
		HangerBeltQuickStart : BOOL;
		DeloaderDwPos : INT;
		DeloaderSpeedUpPct : USINT;
		DeloaderAccUpPct : USINT;
		SpeedHzHangerBelt : UINT;
		SpeedSlowHangerBeltDeloader : UINT;
		DelayTrouserBlast : UINT;
		DeloaderHeavyGarment : BOOL;
		OnTimeTrouserBlast : UINT;
		TrouserBlowPoint : UINT;
		PhTrousers : ACfg_Ph_Type;
		PhShirt : ACfg_Ph_Type;
		PhFlapTrousers : ACfg_Ph_Type;
		BypassLateralBlades : UINT;
		TrouserAlignment : BOOL;
		ForceTrouser : UINT;
		Categorys : ARRAY[0..6]OF UINT;
		LenghtPoints : ARRAY[0..6]OF UINT;
		Trouser : ARRAY[0..6]OF UINT;
		FlapTrouserDetectionOn : BOOL;
		FlapTrousersAlignment : BOOL;
		FlapTrousersAirBlastOnTime : UINT;
		FlapTrousersAirBlastStartDelay : UINT;
		XtremeHeavy : BOOL;
		XtremeRaiseBlades : BOOL;
		XtremeGuideplates : BOOL;
		DelayStopInlet : UINT;
		TrouserBlowEnable : BOOL;
		TrouserBlowAdjust : INT;
		TrouserBlowTimeAdjust : INT;
		TrouserBlowCountAdjust : SINT;
		TrouserBlowGapAdjust : INT;
		FullIndexingTime : ARRAY[0..MAX_NUMBER_OF_STACKERS]OF UINT;
		Extra : ARRAY[0..5]OF UINT;
	END_STRUCT;
	RCfg_Type : 	STRUCT 
		Name : STRING[41];
		NoFlowTimeout : UDINT;
		Extra1 : UINT;
		Extra2 : UINT;
		Extra3 : UINT;
		SelectedStack : UINT;
		Lateral : ParametersLateral_Type;
		CrossFold : ParametersCrossFold_Type;
		CrossFoldA : ParametersCrossFoldA_Type;
		CrossFoldB : ParametersCrossFoldB_Type;
		StackerBelt1 : ParametersSTG_Type;
		StackerBelt2 : ParametersSTG_Type;
		StackerBelt3 : ParametersSTG_Type;
		StackerBelt4 : ParametersSTG_Type;
		StackerBelt5 : ParametersSTG_Type;
		Stacker : ParametersStacker_Type;
		Outlet : ParametersOutlet_Type;
		Delivery : ParametersDelivery_Type;
		FactorySettingsUpdate : UINT;
		Accum : ParametersAccum_Type;
		XtremeHeavy : ParametersXtremeHeavy_Type;
		DuoInlet : ParametersDuo_Type;
	END_STRUCT;
	MCfg_Type : 	STRUCT 
		SensorFilterTime : UINT;
		SensorOverTime : UINT; (*NOT USED*)
		MotorSwitchTime : UINT; (*NOt USED*)
		ConveyorRunTime : UINT;
		DelayStartTime : UINT; (*NOT USED*)
		StatisticStackOrSection : UINT;
		MultiBlowPules : USINT; (*NOT USED*)
		Inlet : MCfg_Inlet_Type;
		Deloading : MCfg_Deloading_Type;
		TC : MCfg_TC_Type;
		LFold : MCfg_LFold_Type;
		XFold : MCfg_XFold_Type;
		Stacker : MCfg_Stacker_Type;
		Outlet : MCfg_Outlet_Type;
		Delivery : MCfg_Delivery_Type;
		Jenway : MCfg_Jenway_Type;
		Metricon : MCfg_Metricon_Type;
		Accum : MCfg_Accum_Type;
		MF : MCfg_MF_Type;
		Duo : MCfg_Duo_Type;
		MachineID : INT;
		GlobeUserName : STRING[21];
		GlobePassword : STRING[21];
		Timezone : MCfg_Timezone_Type;
		Trace2File : BOOL;
		EnableCustArt : BOOL;
		EnableOperator : BOOL;
		FactorySettingsUpdate : UINT;
		Extra1 : UINT;
		Extra2 : UINT;
		Extra3 : UINT;
		Extra4 : UINT;
		Extra5 : UINT;
	END_STRUCT;
	HCfg_Type : 	STRUCT 
		Showlevel : USINT;
		HangerReading : UINT;
		KGHanger : BOOL;
		CombiHanger : UINT;
		CrossFoldingKnife : BOOL;
		CrossFoldingGapAdjust : BOOL;
		NumberOfStackers : USINT;
		StackerAirPipe : BOOL;
		IndexingConveyorsWithPushOff : USINT;
		CrossConveyor : USINT;
		CrossConveyorFotoSensorEnd : BOOL;
		DeliveryConveyor : USINT;
		DeliveryConveyorFotoSensorEnd : BOOL;
		DeliveryExternalCommunication : UINT;
		PrinterCom : UINT;
		StackMaxHeightSensor : BOOL;
		TrouserAlignment : BOOL;
		OverallAlignment : BOOL;
		FeedFromOldMetricon : UINT; (*1: Old Metricon with Spiral was used for Maximat (PreStop) 2: Old Metricon with Spiral was used for Maximat (STF) *)
		FlapTrousers : BOOL;
		FeedManual : BOOL;
		NumberOfButtonsMF : UINT;
		XtremeHeavy : BOOL;
		CHAirTShirt : BOOL;
		AirBlowInlet : BOOL;
		ElisMes : BOOL;
		BibOverall : BOOL;
		Micro : BOOL;
		HeavyGarment : BOOL;
		BlockDirection : USINT;
		DuoInlet : BOOL;
		LoginGotoMachinePage : BOOL;
		BRSafety : BOOL;
		SettingsTrig : USINT;
		IOT : MCfg_IOT_Type;
	END_STRUCT;
	ACfg_Ph_Type : 	STRUCT 
		TwoVerticalRear : BOOL;
		UseHorizontalLead : BOOL;
		UseHorizontalRear : BOOL;
	END_STRUCT;
	ParametersDuo_Type : 	STRUCT 
		DelayStartInlet : UINT;
		StackerSelection : ARRAY[0..3]OF UINT;
		WidthFirst : ARRAY[0..2]OF UINT;
		WidthLast : ARRAY[0..2]OF UINT;
	END_STRUCT;
	ApplicationVariables_Type : 	STRUCT 
		RunState : UDINT;
		InitState : UDINT;
		KeyPressed : UINT;
		KeyValue : UDINT;
		NodeId : UINT;
		AppState : UINT;
		SelectedGarmentType : UINT;
		SelectedDestination : UINT;
		Extra1 : UINT;
		Extra2 : UINT;
	END_STRUCT;
	AutoProgramHmiSetup_Type : 	STRUCT 
		HmiAction : UINT;
		SelectedAutoProgram : UINT;
		DelayTrouserBlast : UINT;
		OnTimeTrouserBlast : UINT;
		TrouserBlowPoint : UINT;
		TrouserBlowRuntime : UINT;
		PhTrousers : ACfg_Ph_Type;
		PhShirt : ACfg_Ph_Type;
		PhFlapTrousers : ACfg_Ph_Type;
		BypassLateralBlades : UINT;
		ForceTrouser : UINT;
		OffsetBlade : UINT;
		OffsetBladeRuntime : UINT;
		TrouserAlignment : BOOL;
		TrouserAlignmentRuntime : UINT;
		FlapTrousersAlignment : BOOL;
		FlapTrousersAlignmentRuntime : UINT;
		Name : STRING[40];
		Category : ARRAY[0..6]OF UINT;
		Completion : ARRAY[0..6]OF UINT;
		SelectionPoint : ARRAY[0..6]OF UINT;
		Trouser : ARRAY[0..6]OF UINT;
		CategoryName : ARRAY[0..6]OF STRING[40];
		CmdGarmentSelect : ARRAY[0..6]OF UINT;
		RightTShirtTime : UINT;
		LeftTShirtTime : UINT;
		RightArmTime : UINT;
		LeftArmTime : UINT;
		RightTShirtDelay : UINT;
		LeftTShirtDelay : UINT;
		RightArmDelay : UINT;
		LeftArmDelay : UINT;
		InFeedBeltOnTime : UINT;
		InFeedBeltStartDelay : UINT;
		InFeedBeltStopDelay : UINT;
		InFeedBeltStopTime : UINT;
		InFeedStopOnTrousers : UINT;
		HangerBeltQuickStart : BOOL;
		DeloaderDwPos : INT;
		DeloaderSpeedUpPct : USINT;
		DeloaderAccUpPct : USINT;
		SpeedHzHangerBelt : UINT;
		SpeedSlowHangerBeltDeloader : UINT;
		WaitTimeInlet : UINT;
		SwingDelay : UINT;
		DeloaderHeavyGarment : BOOL;
		FlapTrousersAirBlastOnTime : UINT;
		FlapTrousersAirBlastStartDelay : UINT;
		XtremeHeavy : BOOL;
		XtremeRaiseBlades : BOOL;
		XtremeGuideplates : BOOL;
		VacuumEnabled : BOOL;
		VacuumFlapDelayOn : UINT;
		VacuumFlapDelayOff : UINT;
		VacuumRuntime : UINT;
		DelayStopInlet : UINT;
		TrouserBlowEnable : BOOL;
		TrouserBlowAdjust : INT;
		TrouserBlowTimeAdjust : INT;
		TrouserBlowCountAdjust : SINT;
		TrouserBlowGapAdjust : INT;
		FullIndexingTime : ARRAY[0..MAX_NUMBER_OF_STACKERS]OF UINT;
		HideIndexingTime : ARRAY[0..MAX_NUMBER_OF_STACKERS]OF UINT;
		OutletRuntimeChanged : BOOL;
	END_STRUCT;
	AutoProgramHmiMain_Type : 	STRUCT 
		SelectedAutoProgram : UINT;
		NameOfAutoProgram : STRING[40];
		Category : ARRAY[0..6]OF UINT;
		Lenght : ARRAY[0..6]OF UINT;
		Name : ARRAY[0..6]OF STRING[40];
		Trouser : ARRAY[0..6]OF UINT;
		ShowSelected : ARRAY[0..6]OF UINT;
		FoldCombination : ARRAY[0..6]OF UINT;
		HideLine : ARRAY[0..6]OF UINT;
		InputColor : UINT;
	END_STRUCT;
	AutoProgramApp_Type : 	STRUCT 
		SelectedAutoProgram : UINT;
		OperatorAutoProgram : UINT;
		AutoProgramToSearch : UINT;
		TrigSelection : BOOL;
		ProgramFound : BOOL;
		MeasuredLenght : UINT;
		ShirtDetected : UINT;
		SelectedProgram : UINT;
		IsFlapTrousers : BOOL;
	END_STRUCT;
	ParametersXtremeHeavy_Type : 	STRUCT 
		FXtremeGap : BOOL;
		FRaiseStackerBelt : BOOL;
		FSlackStackerBelt : BOOL;
		FRaiseTiltConv : BOOL;
	END_STRUCT;
	ParametersDelivery_Type : 	STRUCT 
		ConveyorTime : UINT;
	END_STRUCT;
	ParametersAccum_Type : 	STRUCT 
		AccumSTFRestartTimeDelay : UINT;
		AccumProxFarNearTimeout : UINT;
	END_STRUCT;
	ParametersLateral_Type : 	STRUCT 
		FoldMode : USINT;
		StartDelayLeftBlade : UINT;
		OnTimeLeftBlade : UINT;
		StartDelayRightBlade : UINT;
		OnTimeRightBlade : UINT;
		WidthFirst : UINT;
		WidthLast : UINT;
		BladeBackTime : UINT;
		FoldDistance : INT;
		DelayBladeBack : INT;
		BeltAdjust : UINT;
	END_STRUCT;
	ParametersCrossFold_Type : 	STRUCT 
		FoldCombination : UINT;
		FixDimRearEdge : UINT;
		FixDimLeadEdge : UINT;
		XAMotorExtraTime : UINT;
	END_STRUCT;
	ParametersCrossFoldA_Type : 	STRUCT 
		FoldDevice : UINT;
		Belt1DelayTime : UINT;
		Belt1OpenTime : UINT;
		BlowDelay : UINT;
		BlowTime : UINT;
		BlowBreak : UINT;
		BlowImpulses : UINT;
		KnifeDelay : UINT;
		KnifeTime : UINT;
	END_STRUCT;
	ParametersStacker_Type : 	STRUCT 
		SelectSection : UINT;
		StackerSelection : UINT;
		StopLeadingOrRearEdge : BOOL;
		StopLeading : BOOL;
		StopPosition : UINT;
		JenWayDestination : UINT;
	END_STRUCT;
	ParametersSTG_Type : 	STRUCT 
		AirBlastStartDelay : UINT;
		AirBlastOnTime : UINT;
	END_STRUCT;
	ParametersOutlet_Type : 	STRUCT 
		NumberOfProducts : UINT;
		Mode : UINT; (*Singel or Double stacks, not used on the FOX remove???*)
		FullIndexingTime : UINT;
		DelayRollOffOut : UINT;
	END_STRUCT;
	ParametersCrossFoldB_Type : 	STRUCT 
		FoldDistance : INT;
		SlopeMode : UINT;
		SlopeOnTime : UINT;
		BlowTimeFolding : UINT;
		BlowDelayFolding : UINT;
		BlowTimeLeading : UINT;
		BlowDelayLeading : UINT;
		BlowTimeReversing : UINT;
		BlowDelayReversing : UINT;
		StopMotorEnable : BOOL;
		StopMotorDelay : UINT;
		StopMotorTime : UINT;
		ReverseTimeAdjust : INT;
		StopXAEnable : BOOL;
		StopXADelay : UINT;
	END_STRUCT;
	MF_KEY_CONFIG : 	STRUCT 
		KeyStackIndex : UINT;
		KeyProgIndex : UINT;
	END_STRUCT;
	MCfg_Timezone_Type : 	STRUCT 
		Zone : STRING[6];
		DaylightSavings : BOOL;
	END_STRUCT;
	MCfg_Deloading_Type : 	STRUCT 
		dwPos : REAL;
		upPos : REAL;
		speedUp : REAL;
		speedDw : REAL;
		accUp : REAL;
		decUp : REAL;
		accDw : REAL;
		decDw : REAL;
		DeloadDelayTime : UINT;
		HangerInPlateTime : UINT;
		HangerClampDelay : UINT;
		HangerResetDelay : UINT;
		HangerResetTime : UINT;
		StartLiftTime : UINT;
		PressResetTime : UINT;
		HangerSlideOutTime : UINT;
		NextHangerTime : UINT;
		TwoStepsPjamaOpening : BOOL;
		PajamasStopPos : UINT;
		PajamasStopPos2 : UINT;
		PajamasRestartDelay : UINT;
		PajamePreBreakingTime : UINT;
		InvertOutletFree : BOOL;
		KG : MCfg_Deloading_KG_Type;
	END_STRUCT;
	MCfg_Inlet_Type : 	STRUCT 
		NoReadAlarm : UINT;
		OnePhotocellShirtDetect : BOOL;
		CheckShirtDelay : UINT;
		CheckShirtOnTime : UINT;
		GarmentDetectTimeout : UINT;
		DelayInletMotor : UINT;
		RunTimeTC1Start : UINT;
		OverallFunction : UINT;
		OverallDetectionOnDelay : UINT;
		OverallCenterDelay : UINT;
		OverallCenterOnTime : UINT;
		FlapTrouserFilterMs : UINT;
		WaitFlapTrsPlateClosedTime : UINT;
		WaitFlapTrsDetectTime : UINT;
		FlapTrousersMiddle3OnDelay : UINT;
		FlapTrousersMiddle2OnDelay : UINT;
		FlapTrousersMiddle1OnDelay : UINT;
		FlapTrousersSideOnDelay : UINT;
		TrouserBlowDelay : UINT;
		TrouserBlowTime : UINT;
		TrouserBlowGap : UINT;
		TrouserBlowCount : USINT;
		RunInfeedAll : BOOL;
		SpeedInfeedTime : UINT;
		Hanger : MCfg_Inlet_Hanger_Type;
		Vaccum : MCfg_Inlet_Vaccum_Type;
	END_STRUCT;
	MCfg_Inlet_Vaccum_Type : 	STRUCT 
		AlwaysUse : BOOL;
		StartupTime : UINT;
		DelayOffSec : UINT;
		FanCleaningTime : UINT;
		FanCleaningPieces : UINT;
	END_STRUCT;
	MCfg_Inlet_Hanger_Type : 	STRUCT 
		EmptyHangerLength : UINT;
		CheckCollapsedTime : UINT;
		HoldPoint : UINT;
		PassedTime : UINT;
		DelayStopHangerConveyor : UINT;
		DelayStopHangerConveyorLong : UINT;
		ConveyorShortRunTime : UINT;
		ConveyorShortRunPause : UINT;
		SpeedHzConveyorShortRun : UINT;
		SpeedHzBeltInfeed : UINT;
		SpeedHzBelt : UINT;
		SpeedSlowHangerBeltDeloader : UINT;
		SpeedToDeloaderDelay : UINT;
	END_STRUCT;
	MCfg_Deloading_KG_Type : 	STRUCT 
		HangerClampDelay : UINT;
		OpenHangerTimeOn : UINT;
		OpenHangerDelay : UINT;
		StopExtMotorDelay : UINT;
		StopExtMotorTimeOn : UINT;
	END_STRUCT;
	MCfg_TC_Type : 	STRUCT 
		TurnerDistancePh : UINT;
		DelayStartInfeed : UINT;
		InfeedBeltOnTime : UINT;
	END_STRUCT;
	MCfg_LFold_Type : 	STRUCT 
		LiftBladesTime : UINT;
		BladeBackTime : UINT;
		FoldPosition : INT;
		DistanceIBLA_FoldPoint : INT;
		WidthIncrementOffset : UINT;
	END_STRUCT;
	MCfg_Duo_Type : 	STRUCT 
		AutoPrgSelect : ARRAY[0..3]OF USINT;
		RcpSelect : ARRAY[0..3]OF USINT;
		RaiseDuoInletDelay : UINT;
		TowelsXADistanceFactor : REAL;
	END_STRUCT;
	MCfg_XFold_Type : 	STRUCT 
		XAMotorStoptime : INT;
		StartXAOffsetValue : UINT; (*NOT USED*)
		DistanceXB_FoldPoint : UINT;
		CrossBExtraRewerseTime : UINT;
		DistanceXBFoldPoint_XBExit : UINT;
		CrossAByPassPrestartFoldPoint : UINT; (*NOT USED*)
		CrossBByPassPrestartFoldPoint : UINT;
		FixedDimSpeedFactor : REAL;
	END_STRUCT;
	MCfg_Stacker_Type : 	STRUCT 
		BeltSpeedFactor : UINT; (*Can be set as constant*)
		StartPosition : ARRAY[0..10]OF UINT;
		StopPosition : ARRAY[0..10]OF UINT;
		FlapsDelayOpen : UINT;
		FlapsTimeOpen : UINT;
		FlapsRestartDelay : UINT;
		LiftRaiseDelay : UINT;
		JamOnDelay : UINT;
		DropTime : UINT;
		TransportOffSetTime : UINT;
		IndexingDelay : UINT;
		LengthSorting : BOOL;
		BeltExtention : UINT;
		MaxSize : UINT; (*NOT USED*)
		MaxSinkDelay : UINT; (*NOT USED*)
	END_STRUCT;
	MCfg_Outlet_Type : 	STRUCT 
		PressTime : UINT;
		IndexStopTime : UINT; (*NOT USED*)
		RollOffReturnTime : UINT;
		CrossBeltLength : UINT;
		StartPosition : ARRAY[0..10]OF UINT;
		StopPosition : ARRAY[0..10]OF UINT;
		ConveyorRuntime : UINT;
		CrossBeltNr : ARRAY[0..10]OF UINT;
		StackChangeMode : UINT;
		StackChangeOnlyPrgChange : BOOL;
		StackSelectMode : UINT;
		ButtonPressTime : UINT;
		ZeroValueStackChange : UINT;
	END_STRUCT;
	MCfg_Delivery_Type : 	STRUCT 
		Function : UINT;
		CrossBeltRunTime : UINT;
		CrossBeltOffSet : UINT;
		ExitRunTime : UINT;
	END_STRUCT;
	MCfg_Metricon_Type : 	STRUCT 
		UseExternalStatus : UINT;
		DataExchangeMode : UINT;
		ComMode : UINT;
		AutoProgramUfo : UINT;
		UfoIsLastProgram : BOOL;
		BCD_RequestTime : UINT;
		BCD_ReadDelay : UINT;
		BCD_HangerAwayDelay : UINT;
		BCD_RequestTries : UINT;
	END_STRUCT;
	MCfg_Accum_Type : 	STRUCT 
		FullSensorOnTime : UINT;
		FullSensorOffTime : UINT;
		FullSensorOnPulse : UINT;
		FullSensorOffPulse : UINT;
		HangerAtPresenceProxTimeOut : UDINT;
		STFRestartTimeDelay : UINT;
		PreStoperDelay : UINT;
		ProxFarNearTimeout : UINT;
	END_STRUCT;
	MCfg_MF_Type : 	STRUCT 
		CheckShirtDelay : UINT; (*AF timer can be used*)
		CheckShirtOnTime : UINT; (*AF timer can be used*)
		DelayVacuum : UINT;
		StartnletBeltDelayTime : UINT;
		AutoStartnletBeltDelayTime : UINT;
		AutoStartInletBelt : BOOL;
		ReachInfeedBeltEndPHTimeOut : UINT;
		KeySelected : USINT; (*Check*)
		ReachGarmentDetectPHTimeOut : UINT;
		InfeedBeltAirBlastOnTime : UINT;
		InfeedBeltAirBlastDelay : UINT;
		ButtonSenistivityTime : UINT;
		ReleaseInfeedBeltJamTime : UINT;
		KeyStackIndex : UINT;
		KeyProgIndex : UINT;
		KeyConfig : ARRAY[0..MAX_MF_KEYCOUNT]OF MF_KEY_CONFIG;
	END_STRUCT;
	MCfg_Jenway_Type : 	STRUCT 
		InvertJenwayReady : BOOL;
		BlockTimer : UDINT;
	END_STRUCT;
END_TYPE
