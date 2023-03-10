
TYPE
	ExistsIO_Type : 	STRUCT 
		Vacuum : BOOL;
		FlapsLegsDetectionPlate : BOOL;
		FlapsLegsAdjustment : BOOL;
		AirTrouses : BOOL;
		StackerAir : BOOL;
	END_STRUCT;
	FileConfigManage_Type : 	STRUCT 
		saveHcfg : BOOL;
		saveMcfg : BOOL;
		updateMcfg : BOOL;
	END_STRUCT;
	LYERS_STAT : 	STRUCT 
		Layer : ARRAY[0..MAX_STATISTIC_GRP]OF VISU;
		CurLayer : USINT;
	END_STRUCT;
	ServiceOutletStatus_State : 	STRUCT 
		cmdInletMotorRun : BOOL;
		cmdInletVacum : BOOL;
		stateInletMotorRun : SINT;
		stateInletVacum : SINT;
		cmdLateralMotorRun : BOOL;
		cmdLateralFoldUnit1 : BOOL;
		cmdLateralFoldUnit2 : BOOL;
		cmdLateralTemplate05 : BOOL;
		cmdLateralTemplate10 : BOOL;
		cmdLateralTemplate20 : BOOL;
		cmdLateralTemplate40 : BOOL;
		cmdLateralTemplate60_80 : BOOL;
		cmdLateralFoldTestRun : BOOL;
		cmdLateralFoldTestRunLeft : BOOL;
		cmdLateralFoldTestRunRight : BOOL;
		cmdLateralBeltCountTestRun : BOOL;
		cmdLateralBeltCountTestSave : BOOL;
		LateralFoldTestRun : SINT;
		LateralFoldTestRunLeft : SINT;
		LateralFoldTestRunRight : SINT;
		LateralFoldBladeTime : UINT;
		stateLateralMotorRun : SINT;
		stateLateralFoldUnit1 : SINT;
		stateLateralFoldUnit2 : SINT;
		stateLateralTemplate05 : SINT;
		stateLateralTemplate10 : SINT;
		stateLateralTemplate20 : SINT;
		stateLateralTemplate40 : SINT;
		stateLateralTemplate60_80 : SINT;
		cmdCrossAMotorRun : BOOL;
		cmdCrossAMotorDirection : BOOL;
		cmdCrossAFoldUnit1 : BOOL;
		cmdCrossAFoldUnit2 : BOOL;
		TestKnife : BOOL;
		cmdCrossABeltOpen : BOOL;
		cmdCrossAJamOpen : BOOL;
		stateCrossAMotorRun : SINT;
		stateCrossAMotorDirection : SINT;
		stateCrossAFoldUnit1 : SINT;
		stateCrossAFoldUnit2 : SINT;
		stateCrossABeltOpen : SINT;
		cmdCrossBMotorRun : BOOL;
		cmdCrossBMotorDirection : BOOL;
		stateCrossBMotorRun : SINT;
		stateCrossBMotorDirection : SINT;
		stateCrossBAirPipeRaise : SINT;
		stateCrossBFoldUnit2 : SINT;
		stateCrossBFoldUnit1 : SINT;
		cmdCrossBFoldUnit1 : BOOL;
		cmdCrossBFoldUnit2 : BOOL;
		cmdCrossBSlopeLift : BOOL;
		cmdCrossBRaiseAirPipe : BOOL;
		cmdStackerMotorRun : BOOL;
		cmdStackerMotorDirection : BOOL;
		cmdStackerFoldUnit1 : BOOL;
		cmdStackerFoldUnit2 : SINT;
		cmdStackerOperator : UINT;
		stateStackerMotorRun : SINT;
		stateStackerMotorDirection : SINT;
		stateStackerFoldUnit1 : SINT;
		stateCrossBSlopeLift : SINT;
		cmdOutletOperatorSelect : UINT;
		cmdOutletMotorRun : ARRAY[0..10]OF BOOL;
		cmdOutletTableUp : ARRAY[0..10]OF BOOL;
		cmdOutletTableTest : ARRAY[0..10]OF BOOL;
		cmdOutletRollOff : ARRAY[0..10]OF BOOL;
		stateOutletVisible : ARRAY[0..10]OF UINT;
		stateOutletTableUp : ARRAY[0..10]OF SINT;
		stateOutletTableDown : ARRAY[0..10]OF SINT;
		stateOutletRollOff : ARRAY[0..10]OF SINT;
		stateOutletTableTest : ARRAY[0..10]OF SINT;
		stateOutletMotorRun : ARRAY[0..10]OF SINT;
		cmdDeliveryMotorRun : BOOL;
		cmdDeliveryCrossMotorRun : BOOL;
		stateDeliveryMotorRun : SINT;
		stateDeliveryCrossMotorRun : SINT;
		stateDeliveryInfo : SINT;
		stateCrossHookPos : ARRAY[0..20]OF UDINT;
		stateCrossHookColour : ARRAY[0..20]OF UINT;
		stateDeliveryHookPos : ARRAY[0..20]OF UDINT;
		stateDeliveryLoadPos : ARRAY[0..10]OF UDINT;
	END_STRUCT;
	OverViewHMI : 	STRUCT 
		IconIndex : SINT;
		cmdSelect : SINT;
		State : UINT;
	END_STRUCT;
	oldMetric : 	STRUCT  (*WM*)
		ProxFarLastState : BOOL;
		ProxNearLastState : BOOL;
		ProxFarToOn : BOOL;
		ProxNearToOn : BOOL;
		Prox_Near : BOOL;
		Prox_PreStopper : BOOL;
		Prox_Far : BOOL;
		JamTimeOut : UINT;
		Timer : UINT;
		startTimer : BOOL;
		Step : USINT;
		FSTimer : UINT;
		FSTimeOut : UINT;
		StateOld : BOOL;
		sim : BOOL;
		PreStoperTime : UDINT;
		PreStoperTimer : UDINT;
		PreStoperPuls : BOOL;
		PreStoperPulsTimer : UINT;
	END_STRUCT;
	XtremeHeavy_Type : 	STRUCT 
		Guideplates : BOOL;
		Templates : BOOL;
		Gap : BOOL;
		RaiseStackerBelt : BOOL;
		SlackStackerBelt : BOOL;
		RaiseTiltingConv : BOOL;
		hideHMI : USINT;
	END_STRUCT;
	ConfirmLayer_Type : 	STRUCT 
		IconToShow : UINT;
		OldIcon : UINT;
		ShowTime : UINT;
		ShowTimer : UINT;
		ShowLayer : UINT;
		OldIconToShow : UINT;
	END_STRUCT;
	MachProcessCrossFoldA_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ParametersCrossFoldA_Type;
		CrossParameters : ParametersCrossFold_Type;
		BeltOpen1 : FoldIO_Type;
		WaitKnifeTimer : UINT;
		XtremeGap : BOOL;
		Folding : BOOL;
	END_STRUCT;
	Statistic_Type : 	STRUCT 
		RunningDays : UINT;
		RunningHours : UINT;
		StoppingMinutes : UINT;
		RunningMinutes : UINT;
		OnTimeDays : UINT;
		OnTimeHours : UINT;
		OnTimeMinutes : UINT;
		PowerMaximum : UINT;
		PowerEffective : UINT;
		Utilisation : UINT;
		NumberOfPiecesTotalLast : UINT;
		NumberOfPiecesTotalCur : UINT;
		NumberOfPiecesTotal : UINT;
		Delete : UINT;
		BlockTimeMinutes : UINT;
		BlockHangerMinutes : UINT;
		NoHangersInletTime : UINT;
		JamTime : UINT;
		AutoProgName : STRING[41];
		RecipeName : STRING[41];
		NoExternalHangerFeedTimeSec : UDINT;
		NoExternalHangerFeedTimeMin : UDINT;
		ProductionRunHours : UINT;
		ProductionRunMinutes : UINT;
		ProductionRunDays : UINT;
		ProductionStopHours : UINT;
		ProductionStopMinutes : UINT;
		ProductionStopDays : UINT;
		AutoProgPieces : ARRAY[0..10]OF UINT;
		AutoProgTotal : UINT;
		AutoProgRuntime : ARRAY[0..10]OF USINT;
	END_STRUCT;
	HMIStatistic_Type : 	STRUCT 
		Total : Statistic_Type;
		FoldProgram : Statistic_Type;
		StackerCmd : UINT;
		Stacker : UINT;
		ProgramChanged : UINT;
		StackTextOffSet : UINT;
		Alarms : HMIStatistic_ALM;
	END_STRUCT;
	StackChangeControl_Type : 	STRUCT 
		ArticleId : UINT;
		CustomerId : UDINT;
		AutoProgram : UINT;
		FoldProgram : UINT;
		StackerHasItemsOnItsWay : ARRAY[0..10]OF UINT;
		BestAgeCount : UINT;
		BestAgeStack : UINT;
		EmptyStacker : UINT;
		ArticleOnStack : ARRAY[0..10]OF UINT;
		AgeCountOnStack : ARRAY[0..10]OF UINT;
		AgeCount : UINT;
		DoStackChange : UINT;
		SelectedStacker : UINT;
		OldSelectedStack : UINT;
		OldStackChangeIndex : UINT;
		DuoOldStackChangeIndex : UINT;
	END_STRUCT;
	MachProcessCrossFoldB_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ParametersCrossFoldB_Type;
		CrossParameters : ParametersCrossFold_Type;
		StackChangeControl : StackChangeControl_Type;
		GarmentDetected : BOOL;
		SlopeLift : BOOL;
		SlopeDownTime : UINT;
		SlopeDownTimer : UINT;
		FoldMode : UINT;
		LeadEdgeTime : UINT;
		LeadEdgeTimer : UINT;
		ReverseTime : UINT;
		ReverseTimer : UINT;
		LeadBlowForward : FoldIO_Type;
		LeadBlowReverse : FoldIO_Type;
		ReverseBlow : FoldIO_Type;
		RaiseTiltConv : BOOL;
	END_STRUCT;
	XMLInletSlaveDataRequest : 	STRUCT 
		CustomerId : DINT;
		ArticleId : INT;
		BatchId : INT;
		FoldProgram : INT;
		IPAddress : STRING[21];
	END_STRUCT;
	XMLInletSlaveDataUpdate : 	STRUCT 
		CustomerId : DINT;
		BatchId : INT;
		ArticleId : INT;
		FoldProgram : INT;
	END_STRUCT;
	XMLLoadingDataRequest : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		BatchID : DINT;
		CategoryID : INT;
		CustomerID : DINT;
		Count : INT;
		FinishingCode : INT;
		Weight : INT;
	END_STRUCT;
	XMLLoadingDataUpdate : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		BatchID : DINT;
		CategoryID : INT;
		CustomerID : DINT;
		Count : INT;
		FinishingCode : INT;
		Weight : INT;
	END_STRUCT;
	XMLOutletDataRequest : 	STRUCT 
		NumberOfStackers : INT;
		Stack1Status : INT;
		Stack2Status : INT;
		Stack3Status : INT;
		Stack4Status : INT;
		Stack5Status : INT;
		Stack6Status : INT;
		Stack7Status : INT;
		Stack8Status : INT;
		Stack9Status : INT;
		Stack10Status : INT;
		StartStopIndex : INT;
		StartPos : INT;
		StopPos : INT;
		StackIndex : INT;
		CustomerId : DINT;
		BatchId : INT;
		ArticleId : INT;
		FoldProgram : INT;
		Destination : INT;
		Count : INT;
		IPAddress : STRING[21];
	END_STRUCT;
	XMLOutletDataUpdate : 	STRUCT 
		OutletStatus : INT;
		Stack1Status : INT;
		Stack2Status : INT;
		Stack3Status : INT;
		Stack4Status : INT;
		Stack5Status : INT;
		Stack6Status : INT;
		Stack7Status : INT;
		Stack8Status : INT;
		Stack9Status : INT;
		Stack10Status : INT;
	END_STRUCT;
	XMLSendOutDataRequest : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		BatchID : DINT;
		CategoryID : INT;
		CustomerID : DINT;
		Weight : INT;
		Count : INT;
		FinishingCode : INT;
	END_STRUCT;
	XMLSendOutDataUpdate : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		BatchID : DINT;
		CategoryID : INT;
		CustomerID : DINT;
		Weight : INT;
		Count : INT;
		FinishingCode : INT;
	END_STRUCT;
	SlaveStackerUnit_Type : 	STRUCT 
		OldExchangeStatus : UINT;
		Exchange : ExchangeStackData_Type;
	END_STRUCT;
	SlaveOutlet_Type : 	STRUCT 
		OldState : UINT;
		Updated : BOOL;
		DoUpdate : BOOL;
		NumberOfStackers : UINT;
		StackerUnit : ARRAY[0..10]OF SlaveStackerUnit_Type;
	END_STRUCT;
	MachProcessDelivery2_Type : 	STRUCT 
		Parameters : ParametersDelivery_Type;
		AllInIdle : BOOL;
		NextMachineReady : BOOL;
		DeliveryIsInProgress : BOOL;
		StackData : ARRAY[0..20]OF StackData_Type;
		NextStackIndex : UINT;
		MaxStackIndex : UINT;
		MaxNumberOfLoadPoints : UINT;
		NumberOfLoadPoints : UINT;
		CrossLoadPoint : ARRAY[0..10]OF ExchangeLoadPoint_Type;
		CrossUnloadPoint : ExchangeLoadPoint_Type;
		CrossBelt : TransportBeltType;
		DeliveryLoadPoint : ExchangeLoadPoint_Type;
		DeliveryUnloadPoint : ExchangeLoadPoint_Type;
		DeliveryBelt : DeliveryBelt_Type;
		State : USINT;
		New_Member2 : USINT;
		Common : FoldTaskCommon_Type;
	END_STRUCT;
	ExchangeLoadPoint_Type : 	STRUCT 
		State : UINT;
		StartPosition : UINT;
		StopPosition : UINT;
		Exchange : ExchangeStackData_Type;
		StopMotor : BOOL;
	END_STRUCT;
	MachProcessDelivery_Type : 	STRUCT 
		Parameters : ParametersDelivery_Type;
		AllInIdle : BOOL;
		NextMachineReady : BOOL;
		DeliveryIsInProgress : BOOL;
		StackData : ARRAY[0..20]OF StackData_Type;
		NextStackIndex : UINT;
		MaxStackIndex : UINT;
		MaxNumberOfLoadPoints : UINT;
		NumberOfLoadPoints : UINT;
		CrossLoadPoint : ARRAY[0..10]OF ExchangeLoadPoint_Type;
		CrossUnloadPoint : ExchangeLoadPoint_Type;
		CrossBelt : TransportBeltType;
		DeliveryLoadPoint : ExchangeLoadPoint_Type;
		DeliveryUnloadPoint : ExchangeLoadPoint_Type;
		DeliveryBelt : DeliveryBelt_Type;
		State : USINT;
		New_Member2 : USINT;
		Common : FoldTaskCommon_Type;
	END_STRUCT;
	MachProcessM_Inlet_Output_Type : 	STRUCT 
		InfeedBeltAirBlast : FoldIO_Type;
		InFeedBeltMotor : FoldIO_Type;
		Vacuum : FoldIO_Type;
		CheckForShirt : FoldIO_Type;
		SleeveBlastLeft : FoldIO_Type;
		SleeveBlastRight : FoldIO_Type;
		InletBeltMotor : FoldIO_Type;
		InletConveyorMotor : FoldIO_Type;
		InletBeltTC1Start : FoldIO_Type;
		ReleaseInfeedBeltJam : FoldIO_Type;
		VacuumCleaning : BOOL;
		VacuumMotor : BOOL;
		VacuumFlap : BOOL;
	END_STRUCT;
	MachProcess_Timer_Type : 	STRUCT 
		Timer : UINT;
		TTime : UINT;
	END_STRUCT;
	MachProcessM_Inlet_Timer_Type : 	STRUCT 
		DelayStart : MachProcess_Timer_Type;
		InletConveyor : MachProcess_Timer_Type;
		HoldPoint : MachProcess_Timer_Type;
		FanCleaning : MachProcess_Timer_Type;
		RestartInletConvDelay : MachProcess_Timer_Type;
		ReachGarmentDetectionPH : MachProcess_Timer_Type;
		ReachInfeedBeltMiddlePH : MachProcess_Timer_Type;
		ReachInfeedBeltEndPH : MachProcess_Timer_Type;
		AutoStartnletBeltDelay : MachProcess_Timer_Type;
		JamWaitInletConv : MachProcess_Timer_Type;
	END_STRUCT;
	MachProcessM_Inlet_Input_Type : 	STRUCT 
		ShirtDetect : FoldIOCounter_Type;
		InletConvoyerJam : FoldIOCounter_Type;
		ReachedInfeedBeltEnd : FoldIOCounter_Type;
		GarmentDetectionUp : FoldIOCounter_Type;
		GarmentOnInlet : FoldIOCounter_Type;
		StartButtons : ARRAY[0..MAX_MF_KEYCOUNT]OF FoldIOCounter_Type;
		SecurityCover : FoldIOCounter_Type;
	END_STRUCT;
	MachProcessManualInlet_Var_Type : 	STRUCT 
		AutoSelectColor : UINT;
		HangerReading : UINT;
		ForcedNoCom : UINT;
		StopFeedingStatus : UINT;
		SelectedAutoProgram : UINT;
		ConveyorIsReady : BOOL;
		IdleTimer : UINT;
		IdleTime : UINT;
		InletIsIdle : BOOL;
		LeadingPoint : UINT;
		PulsCounter : UINT;
		GarmentLenght : UINT;
		NoReadCount : UINT;
		NoReadStatus : UINT;
		SelectedStacker : UINT;
		SelectedProg : UINT;
		StartInletButton : BOOL;
		TrouserAlignment : BOOL;
		GarmentsBeforeCleaning : UINT;
		AutoStartInletBelt : BOOL;
		JamAtInletConvoyer : BOOL;
		JamAtInletConvoyerLimit : USINT;
		JamAtInletConvoyerCounter : USINT;
	END_STRUCT;
	MachProcessManualInlet_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		DiagCounters : DiagHangerRead_Type;
		OutletIsFree : BOOL;
		Outputs : MachProcessM_Inlet_Output_Type;
		Timers : MachProcessM_Inlet_Timer_Type;
		Inputs : MachProcessM_Inlet_Input_Type;
		Values : MachProcessManualInlet_Var_Type;
		ManualInletStarted : BOOL;
		NoReadCount : UINT;
	END_STRUCT;
	MachProcessHangerInlet_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		EnableFeeding : BOOL;
		PresenceStepfeeder : FoldIOCounter_Type;
		Presence2Stepfeeder : FoldIOCounter_Type;
		HangerPassedStf : FoldIOCounter_Type;
		ShirtDetect : FoldIOCounter_Type;
		GarmentDetect : FoldIOCounter_Type;
		OverallDetection : FoldIOCounter_Type;
		CheckForShirt : FoldIO_Type;
		DiagCounters : DiagHangerRead_Type;
		InFeedBeltRun : FoldIO_Type;
		OverallCenter : FoldIO_Type;
		InletBeltTC1Start : FoldIO_Type;
		Vacuum : FoldIO_Type;
		VacuumStartupTimer : UINT;
		VacuumFlapDelayTimer : UINT;
		VacuumMotor : BOOL;
		VacuumMotor_TOF : TOF;
		VacuumCleaning : BOOL;
		DelayInletBelt : FoldIO_Type;
		HangerReadError : BOOL;
		OutletIsFree : FoldIOCounter_Type;
		NoHangerPassed : BOOL;
		AutoSelectColor : UINT;
		StepfeederTries : UINT;
		HangerReading : UINT;
		ForcedNoCom : UINT;
		CheckUnexpectedHangerFeed : BOOL;
		CheckUnexpectedHangerFeedTime : UINT := 1500;
		CheckUnexpectedHangerFeedTimer : UINT;
		CombiHanger : UINT;
		ResetAfterStackChange : BOOL;
		StopFeedingOnCustomerChange : BOOL;
		StopFeedingCmd : UINT;
		SelectedAutoProgram : UINT;
		ConveyorIsReady : BOOL;
		IdleTimer : UINT;
		IdleTime : UINT;
		InletIsIdle : BOOL;
		LeadingPoint : UINT;
		PulsCounter : UINT;
		GarmentLenght : UINT;
		NoReadCount : UINT;
		ReTrigReadTimer : UINT;
		ReTrigReadTime : UINT;
		InletGarmentDetectTime : UINT;
		InletGarmentDetectTimer : UINT;
		CheckHangerTime : UINT;
		CheckHangerTimer : UINT;
		CollapsedTime : UINT;
		CollapsedTimer : UINT;
		DelayStartTime : UINT;
		DelayStartTimer : UINT;
		HangerBeforeCleaning : UINT;
		FanCleaningTime : UINT;
		FanCleaningTimer : UINT;
		HangerConveyorOnTime : UINT;
		HangerConveyorOnTimer : UINT;
		HangerPassedTimer : UINT;
		HangerPassedTime : UINT;
		HoldPointTime : UINT;
		HoldPointTimer : UINT;
		ReCheckHangerTime : UINT;
		ReCheckHangerTimer : UINT;
		ReCheckHanger : BOOL;
		NoReadStatus : UINT;
		StepFeeder : FoldIO_Type;
		FlapTrouserAlignment : BOOL;
		FlapTrouserDetectPos : UINT;
		FlapTrouserDetectPosCounter : UINT;
		TrouserAlignment : BOOL;
		HangerConveyorMotor : BOOL;
		HangerConveyorShortRun : BOOL;
		HangerConveyorShortRunPause : BOOL;
		VacuumFlap : BOOL;
		InletBeltMotor : BOOL;
		FlapTrousersMiddle2 : FoldIOCounter_Type;
		FlapTrousersMiddle3 : FoldIOCounter_Type;
		FlapTrousersMiddle1 : FoldIOCounter_Type;
		FlapTrousersSide : FoldIOCounter_Type;
		FlapTrousersAir : FoldIO_Type;
		FlapTrousersDetectionPlate : BOOL;
		FlapTrousersPlate : BOOL;
		CustomerChangeLMP : BOOL;
		CustomerStackChange : BOOL;
		AutoProgBackUp : UINT;
		ExternalRecipe : UINT;
		ManualChangeAutoProg : BOOL;
		IndexingIconRuntime : UINT;
		EmptyHangerSave : UINT;
		TotalEdgeCounter : UINT;
		isInProgress : BOOL;
		isCollapsedHanger : BOOL;
	END_STRUCT;
	MachProcessMiniJenway_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
	END_STRUCT;
	MachProcessManualInfeed_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		GarmentInPosition : FoldIOCounter_Type;
		GarmentJam : FoldIOCounter_Type;
		GarmentOutOfMachine : FoldIOCounter_Type;
		CheckOutSensor : Full_Type;
		GarmentPassedOut : BOOL;
		HMIDetectionType : UINT;
		NextGarmentTime : UINT;
		NextGarmentTimer : UINT;
	END_STRUCT;
	MachProcessHangerOpener_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		HangerInPosition : FoldIOCounter_Type;
		HangerJam : FoldIOCounter_Type;
		HangerOutOfMachine : FoldIOCounter_Type;
		CheckHangerInDU : FoldIOCounter_Type;
		HangerPassedOut : BOOL;
		CheckHangerFunction : BOOL;
		DelayHornTimer : UINT;
		DelayHornTime : UINT;
		BlockDelayTimer : UINT;
		DelayPyjamasTimer : UINT;
		PajamasMotorRunTime : UINT;
		PajamasMotorRunTimer : UINT;
		PajamasDelayLiftTimer : UINT;
		PajamasDelayLiftTime : UINT;
		CombiHanger : UINT;
		HMIDetectionType : UINT;
		StartDelayLifterTime : UINT;
		StartDelayLifterTimer : UINT;
		StartDelayOpenerTime : UINT;
		StartDelayOpenerTimer : UINT;
		HangerResetTimer : UINT;
		HangerResetTime : UINT;
		PressResetTimer : UINT;
		PressResetTime : UINT;
		HangerSlideOutTime : UINT;
		HangerSlideOutTimer : UINT;
		HangerCloseTimer : UINT;
		HangerCloseTime : UINT;
		NextHangerTime : UINT;
		NextHangerTimer : UINT;
		HangerHammer : BOOL;
		HangerClamp : BOOL;
		HangerResetLower : BOOL;
		HangerResetUpper : BOOL;
		HangerBlockClamp : BOOL;
		Press : BOOL;
		PajamePreBreaking : FoldIO_Type;
		KG_StopExtMotor : FoldIO_Type;
		KG_HangerDetectedToOpen : FoldIOCounter_Type;
		KG_HangerOpen : FoldIO_Type;
		BlockDelayTime : UINT;
		WaitingRestart : BOOL; (*Hanger was in top position at machine stop, and will be ready to restart the process*)
	END_STRUCT;
	MachProcessInlet_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		HorizontalSensor : FoldIOCounter_Type;
		StopInFeedBelt : FoldIO_Type;
		TrouserBlast : FoldIO_Type;
		BlowPointTimer : UINT;
		BlowPointTime : UINT;
		InFeedBeltOnTime : UINT;
		InFeedBeltOnTimer : UINT;
		StartPoint : UINT;
		StopPoint : UINT;
		LengthInCM : UINT;
		RestartTimer : UINT;
		InfeedBeltMotor : BOOL;
		ExpectedPhCount : UINT := 50;
		ExpectedPhCounter : UINT;
	END_STRUCT;
	MachProcessLateral_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ParametersLateral_Type;
		CrossParameters : ParametersCrossFold_Type;
		CrossAFoldDevice : UINT;
		Template1_05 : BOOL;
		Template1_10 : BOOL;
		Template1_20 : BOOL;
		Template1_40 : BOOL;
		Template2_05 : BOOL;
		Template2_10 : BOOL;
		Template2_20 : BOOL;
		Template2_40 : BOOL;
		LeftBladeIsBack : BOOL;
		KnifeIsHome : FoldIOCounter_Type;
		LiftBladesTime : UINT;
		LiftBladesTimer : UINT;
		WaitBladeBackTime : UINT;
		WaitBladeBackTimer : UINT;
		WaitBladeOutTimer : UINT;
		WaitBladeOutTime : UINT;
		XAMotorExtraTimer : UINT;
		Length : UINT;
		StartFold : BOOL;
		EdgeCount : UINT;
		TemplateSizeFirstPart : UINT;
		TemplateSizeLastPart : UINT;
		CrossAFoldMode : UINT;
		SetGap : BOOL;
		CloseGapTimer : UINT;
		CloseGapTime : UINT;
		TemplateResetFlag : BOOL;
		SetSlope : BOOL;
		KeepLeftBladeOut : BOOL;
		LiftTemplate : BOOL;
		RaiseBlades : BOOL;
		XtremeRaiseBlades : BOOL;
		BypassLateral : BOOL;
		OffsetBlade : BOOL;
		SequenceBusy : BOOL;
	END_STRUCT;
	StackerUnit_Type : 	STRUCT 
		LiftMode : UINT;
		ReleaseBreak : BOOL;
		Up : BOOL;
		SinkTimer : UINT;
		SinkPressDelay : UINT;
		DelayLiftTimer : UINT;
		DelayLiftTime : UINT;
		PressTime : UINT;
		PressTimer : UINT;
		Counter : UINT;
		LiftState : UINT;
		BeltState : UINT;
		SaveBeltState : UINT;
		cmdIndex : UINT;
		LastItemOnStack : UINT;
		Motor : FoldMotor_Type;
		LiftMotor : FoldMotor_Type;
		RollOff : BOOL;
		StackChange : BOOL;
		DoubleWaiting : BOOL;
		ExitTimer : UINT;
		WatchDogStartup : UINT;
		StartupDelayTimer : UINT;
		StackData : ARRAY[0..2]OF StackData_Type;
		LevelSensor : FoldIOCounter_Type;
		DownSensor : FoldIOCounter_Type;
		MaxHeightSensor : FoldIOCounter_Type;
		BeltBlockSensor : FoldIOCounter_Type;
		BeltEndSensor : FoldIOCounter_Type;
		BeltEndSensorEdge : BOOL;
		Next : ExchangeStackData_Type;
		DoIndex : BOOL;
		BeltIsIndexing : BOOL;
		BlockDelivery : BOOL;
		isCheckTopSensor : BOOL;
		TON_TopSensorAlarm : TON;
		isTopSensorAlarm : BOOL;
		NoRead : BOOL;
	END_STRUCT;
	ExchangeStackData_Type : 	STRUCT 
		TransferStatus : UINT;
		Block : BOOL;
		Stack : StackData_Type;
		StackIndex : UINT;
		Count : UINT; (*ItemData : ARRAY[0..STACK_ITEM_MAX_20] OF StackItemData_Type;*)
	END_STRUCT;
	MachProcessOutlet_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ARRAY[0..10]OF ParametersOutlet_Type;
		StackerUnit : ARRAY[0..10]OF StackerUnit_Type;
		JenwayExchange : ARRAY[0..5]OF ExchangeStackData_Type;
		AllSubIdle : BOOL;
		NextMachineReady : ARRAY[0..10]OF BOOL;
		JenwayIsIndexing : BOOL;
		StackerGroupLink : ARRAY[0..5]OF OutletSubUnit_Type;
		BeltIndexing : UINT;
		StackerExtentionRun : BOOL;
		StackerExtention : FoldIO_Type;
		DoubleIndex : BOOL;
	END_STRUCT;
	DiagHangerRead_Type : 	STRUCT 
		HangerReadOK : UINT;
		NoRead : UINT;
		NoData : UINT;
	END_STRUCT;
	MachProcessStacker_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ParametersSTG_Type;
		StackerParameter : ParametersStacker_Type;
		NextStackerGroup : ExchangeData_Type;
		AirBlastFlaps : FoldIO_Type;
		JamSensor : FoldIOCounter_Type;
		CheckSensor : FoldIOCounter_Type;
		Section : UINT;
		SelectedStacker : UINT;
		FlapsClose : BOOL;
		FlapsDelayOpenTimer : UINT;
		FlapDelayReached : BOOL;
		XtremeHeavy : BOOL;
		XtremeSlackBelt : BOOL;
	END_STRUCT;
	CustomerSearch_Type : 	STRUCT 
		State : UINT;
		Complete : BOOL;
		CallerId : UINT;
		ErrorState : UINT;
		CustomerNumber : UINT;
		CustomerName : STRING[41];
		ArticleName : STRING[41];
		ArticleNumber : UINT;
		FoldProgram : UINT;
		Counter : UINT;
		MaxCycleCounter : UINT;
	END_STRUCT;
	RollOffExHmi_Type : 	STRUCT 
		Tx1 : UINT;
		Tx2 : UINT;
		Rx1 : UINT;
		Rx2 : UINT;
		FoxState : UINT;
		CustomerNumber : UINT;
		ArticleNumber : UINT;
		NumbersInStack : UINT;
		RecipeNumber : UINT;
		LineNumber : UINT;
	END_STRUCT;
	ExternalPVICom_Type : 	STRUCT  (*ServerInfo *)
		MachineType : UINT;
		MachineId : INT;
		StatusRefreshTime : UINT;
		StatusRefreshTimer : UINT;
		RequestTimeOutTime : UINT;
		RequestTimeOutTimer : UINT;
		LastResponseTime : UINT;
		CurTimer : UINT;
		ComState : INT;
		MachineStatus : INT;
		OutletFull : INT;
		OutletHalfFull : INT;
		HangersWaiting : INT;
		TableUpdate : INT; (*ClientInfo*)
		InletActive : INT;
		InletFull : INT;
		InternalAlarm : INT;
		RequestHangerData : INT;
		AwayHangerUpdate : INT;
		ConnectionState : INT;
		ConnectionError : UDINT; (*GarmentData*)
		GarmentData : XMLFoldGarmentData_Type;
		MetricHangerReadStatus : UINT; (*Statistic*)
		ConnectedOkCounter : UINT;
		ClosedCounter : UINT;
		RequestCounter : UINT;
		RequestOkCounter : UINT;
		AwayCounter : UINT;
		AwayOkCounter : UINT;
		StatusTransmitCounter : UINT;
		StatusOkCounter : UINT;
		NoAnswerCounter : UINT;
		ErrorCounter : UINT;
		WrongMessageIdCounter : UINT;
		UnknownTagCounter : UINT;
	END_STRUCT;
	PrinterComHMI_Type : 	STRUCT 
		CommunicationStatus : UINT;
		HangerId : STRING[25];
		GarmentId : STRING[25];
		PrinterStatus : UINT;
		FolderStatus : UINT;
		ErrorNumber : UINT;
		ErrorString : STRING[50];
		BypassStatus : UINT;
		MainIconState : UINT;
		MachineId : INT;
		LogStatus : UINT;
	END_STRUCT;
	StackerGroupItems_Type : 	STRUCT 
		FirstStack : UINT;
		LastStack : UINT;
	END_STRUCT;
	PrinterCom_Type : 	STRUCT 
		FolderStatus : UINT;
		MLabelStatus : UINT;
		isEnabled : BOOL;
	END_STRUCT;
	LogStack_Type : 	STRUCT 
		DoLog : BOOL;
		LogType : UINT;
		Item1 : STRING[21];
		Item2 : STRING[21];
		Item3 : STRING[21];
		Item4 : STRING[21];
		Item5 : STRING[21];
		Item6 : STRING[21];
	END_STRUCT;
	LogHanger_Type : 	STRUCT 
		DoLog : BOOL;
		Program : UINT;
		HType : UINT;
		Article : UINT;
		Customer : UDINT;
		Destination : UINT;
		StackChange : UINT;
		HangerIdStr : STRING[21];
	END_STRUCT;
	EXTERNAL_FEED : 	STRUCT 
		NoExternalFeedTimeReset : BOOL;
		NoExternalFeedTime : UDINT;
		WaitForHangerAtPresenceTimeOut : UDINT;
		TimeCountActive : BOOL;
		WaitForHangerAtPresenceTimer : UDINT;
		PreStoperTimer : UDINT;
	END_STRUCT;
	ExternalCom_Type : 	STRUCT 
		Ethernet : JenXMLCommInfo_Type;
		Serial : SINT;
		Digital : SINT;
		ConnectionType : UINT;
		HangerState : UINT;
		HangerRequestHMI : UINT;
		HangerId : HangerID_Type;
		SeqId : UINT;
		GarmentId : HangerID_Type;
		MetricHangerReadStatus : UINT;
		Recipe : UINT;
		ArticleId : UINT;
		CustomerId : UDINT;
		Destination : INT;
		StackChange : INT;
		OutletHalfFull : INT;
		OutletFull : INT;
		HangersWaiting : INT;
		InletActive : INT;
		ExternalFeed : EXTERNAL_FEED;
		InletFull : INT;
		InternalAlarm : INT;
		Common : FoldTaskCommon_Type;
	END_STRUCT;
	HMI_MF_KEY : 	STRUCT 
		Index : UINT;
	END_STRUCT;
	HMIConfigChange_Type : 	STRUCT 
		OnePhotocellShirtDetectCmd : UINT;
		OnePhotocellShirtDetect : BOOL;
		InletRunTimeTC1StartCmd : UINT;
		InletRunTimeTC1Start : UINT;
		FullSensorOnTimeCmd : UINT;
		FullSensorOnTime : UINT;
		FullSensorOffTimeCmd : UINT;
		FullSensorOffTime : UINT;
		FullSensorOnPulseCmd : UINT;
		FullSensorOnPulse : UINT;
		FullSensorOffPulseCmd : UINT;
		FullSensorOffPulse : UINT;
		NoReadAlarmCmd : UINT;
		NoReadAlarm : UINT;
		AutoProgramUfoCmd : UINT;
		AutoProgramUfo : UINT;
		DelayStopHangerTimeCmd : UINT;
		DelayStopHangerConveyor : UINT;
		DelayStopHangerTimeLongCmd : UINT;
		DelayStopHangerConveyorLong : UINT;
		DelayStopHangerLongRunTime : UINT;
		HangerPassedTimeCmd : UINT;
		HangerPassedTime : UINT;
		CheckShirtDelayCmd : UINT;
		CheckShirtDelay : UINT;
		CheckShirtOnTimeCmd : UINT;
		CheckShirtOnTime : UINT;
		HangerHoldPointCmd : UINT;
		HangerHoldPoint : UINT;
		PressResetTime : UINT;
		PressResetTimeCmd : UINT;
		OverallCenterDelayCmd : UINT;
		OverallCenterDelay : UINT;
		OverallCenterOntimeCmd : UINT;
		OverallCenterOnTime : UINT;
		DelayVacuumCmd : UINT;
		DelayVacuum : UINT;
		OverallRunTime : UINT;
		StartLiftTimeCmd : UINT;
		StartLiftTime : UINT;
		HangerInPlateTimeCmd : UINT;
		HangerInPlateTime : UINT;
		HangerResetTimeCmd : UINT;
		HangerResetTime : UINT;
		HangerSlideOutTimeCmd : UINT;
		HangerSlideOutTime : UINT;
		HangerResetDelayCmd : UINT;
		HangerResetDelay : UINT;
		PajamasMotorPosCmd : UINT;
		PajamasStopPos : UINT;
		PajamasMotorPos2Cmd : UINT;
		PajamasStopPos2 : UINT;
		PajamasRestartDelay : UINT;
		PajamasRestartDelayCmd : UINT;
		InfeedBeltOnTimeCmd : UINT;
		InfeedBeltOnTime : UINT;
		GeneralSpeedFactorCmd : SINT;
		GeneralSpeedFactor : UINT;
		GeneralSensorFilterTimeCmd : SINT;
		GeneralSensorFilterTime : UINT;
		GeneralMotorSwitchTimeCmd : SINT;
		GeneralMotorSwitchTime : UINT;
		GeneralConveyorRunTimeCmd : SINT;
		GeneralConveyorRunTime : UINT;
		GeneralWidthIncrementOffsetCmd : SINT;
		GeneralWidthIncrementOffset : UINT;
		DistanceXA_FoldPointCmd : UINT;
		DistanceIBLA_FoldPoint : INT;
		DistanceXB_FoldPointCmd : SINT;
		DistanceXB_FoldPoint : UINT;
		DistanceXBFoldPoint_XBExitCmd : SINT;
		DistanceXBFoldPoint_XBExit : UINT;
		CrossBExtraRewerseTime : UINT;
		CrossBExtraRewerseTimeCmd : UINT;
		Stacker : HMIConfigStacker_Type;
		StackerTransportOffSetTimeCmd : SINT;
		StackerTransportOffSetLength : UINT;
		StackerIndexingDelayCmd : SINT;
		StackerMaxSinkDelayCmd : SINT;
		StackerIndexingDelay : UINT;
		StackerMaxSinkDelay : UINT;
		LiftRaiseDelayCmd : UINT;
		LiftRaiseDelay : UINT;
		OutletStackChangeModeCmd : SINT;
		OutletRollOffReturnTimeCmd : SINT;
		OutletRollOffReturnTime : UINT;
		OutletCrossBeltLengthCmd : SINT;
		OutletCrossBeltLength : UINT;
		DeliveryExitRunTimeCmd : SINT;
		DeliveryExitRunTime : UINT;
		DeliveryFunctionCmd : SINT;
		DeliveryFunction : UINT;
		MetriconIpAddress : STRING[25];
		MetriconIpRefresh : UINT;
		FullSignalsCmd : UINT;
		DataExchangeModeCmd : UINT;
		ComModeCmd : UINT;
		MLabelIpAddressByte1 : USINT;
		MLabelIpAddressByte2 : USINT;
		MLabelIpAddressByte3 : USINT;
		MLabelIpAddressByte4 : USINT;
		MLabelIpAddressByte3Cmd : UINT;
		MLabelIpAddressByte4Cmd : USINT;
		MLabelRefreshTimeOutCmd : UINT;
		MLabelRefreshTimeOut : UINT;
		XMLInletSlaveConnectIdCmd : SINT;
		XMLInletSlaveConnectId : INT;
		XMLOutletConnectIdCmd : SINT;
		XMLOutletConnectId : INT;
		XMLSlaveRefreshTimeCmd : SINT;
		XMLSlaveRefreshTime : UINT;
		XMLSlaveRefreshTimeOutCmd : SINT;
		XMLSlaveRefreshTimeOut : UINT;
		AccumSTFRestartTimeDelayCmd : SINT;
		AccumProxFarNearTimeoutCmd : SINT;
		AccumSTFRestartTimeDelay : UINT;
		AccumProxFarNearTimeout : UINT;
		FlapTrousersCmd : SINT;
		FlapTrousersFootTimeOn : UINT;
		FlapTrousersFootStartDelay : UINT;
		FlapTrousersRunTime : UINT;
		KGHangerClampDelayCmd : SINT;
		KGHangerClampDelay : UINT;
		MF_GeneralCmd : SINT;
		MF_ButtonSensivityTime : UINT;
		MF_CheckShirtOnTime : UINT;
		MF_DelayVacuum : UINT;
		MF_CheckShirtDelay : UINT;
		MF_StartnletBeltDelayTime : UINT;
		MF_AutoStartnletBeltDelayTime : UINT;
		MF_AutoStartInletBelt : BOOL;
		MF_InfeedBeltAirBlastDelay : UINT;
		MF_InfeedBeltAirBlastOnTime : UINT;
		MF_ReachInfeedBeltMiddleTimeOut : UINT;
		MF_ReachInfeedBeltEndPHTimeOut : UINT;
		MF_KeyConfigCmd : BOOL;
		MF_KeyConfigIndex : USINT;
		MF_KeyAuto : MF_KEY_CONFIG;
		MF_Keys : ARRAY[0..MAX_MF_KEYCOUNT]OF MF_KEY_CONFIG;
		MF_ReachGarmentDetectPHTimeOut : UINT;
		CrossBeltNrRuntime : UINT;
	END_STRUCT;
	HMIFoldProgOutlet_Type : 	STRUCT 
		NumberOfProducts : UINT;
		NumberOfProductsCmd : UINT;
		FullIndexingTime : UINT;
		FullIndexingTimeCmd : UINT;
		DelayRollOffOut : UINT;
		DelayRollOffOutCmd : UINT;
		RollOffStackerRuntime : UINT;
		OperatorCmd : UINT;
		SelectedStacker : UINT;
		StackSelectCmd : UINT;
		SelectedStack : UINT;
		SelectStackVisible : UINT;
	END_STRUCT;
	HMIFoldProgramChange_Type : 	STRUCT 
		ProgramChanged : BOOL;
		ProgramSelectedColour : UINT;
		LateralFoldMode : UINT;
		LateralFoldModeCmd : SINT;
		LateralLeftBladeOnTime : UINT;
		LateralLeftBladeCmd : SINT;
		LateralLeftBladeStartCmd : UINT;
		LateralLeftBladeStartDelay : UINT;
		LateralRightBladeOnTime : UINT;
		LateralRightBladeCmd : SINT;
		LateralRightBladeStartCmd : UINT;
		LateralRightBladeStartDelay : UINT;
		BladeBackTimeCmd : UINT;
		LateralBladeBackTime : UINT;
		LateralWidthFirst : REAL;
		LateralWidthFirstCmd : SINT;
		LateralWidthLast : REAL;
		LateralWidthLastCmd : SINT;
		LateralFoldTime : UINT;
		LateralFoldTimeCmd : SINT;
		LateralFoldPoint : REAL;
		LateralFoldPointCmd : SINT;
		CrossFoldModeCmd : SINT;
		CrossFoldModeDecCmd : UINT;
		CrossFixDimLeadEdge : REAL;
		CrossFixDimLeadEdgeCmd : SINT;
		CrossFixDimLeadEdgeRuntime : SINT;
		CrossFixDimRearEdge : REAL;
		CrossFixDimRearEdgeCmd : SINT;
		CrossFixDimRearEdgeRuntime : SINT;
		CrossFixDimRuntime : SINT;
		CrossFoldPicture : SINT;
		XAExtraMotorTimeCmd : UINT;
		XAExtraMotorTime : UINT;
		CrossAFoldDistanceCmd : UINT;
		CrossAFoldDistance : REAL;
		CrossAFoldDeviceCmd : SINT;
		CrossASmallOrWideRuntime : SINT;
		CrossABeltOpenerCmd : SINT;
		CrossABlowTime : UINT;
		CrossABlowTimeCmd : SINT;
		CrossABlowDelay : UINT;
		CrossABlowDelayCmd : SINT;
		CrossABlowBreak : UINT;
		CrossABlowBreakCmd : SINT;
		CrossABlowImpulses : UINT;
		CrossABlowImpulsesCmd : SINT;
		CrossABlowDelayRuntime : SINT;
		CrossAKnifeRuntime : SINT;
		CrossAKnifeDelay : UINT;
		CrossAKnifeDelayCmd : SINT;
		CrossAKnifeTime : UINT;
		CrossAKnifeTimeCmd : SINT;
		CrossABelt1DelayTime : UINT;
		CrossABelt1OpenTimeCmd : SINT;
		CrossBFoldDistance : REAL;
		CrossBFoldDistanceCmd : SINT;
		CrossBBlowTimeFolding : UINT;
		CrossBBlowTimeFoldingCmd : SINT;
		SlopeOnTimeCmd : UINT;
		SlopeOnTime : UINT;
		CrossBSlopeModeCmd : SINT;
		CrossBBlowDelayFolding : UINT;
		CrossBBlowDelayFoldingCmd : SINT;
		CrossBBlowTimeLeading : UINT;
		CrossBBlowTimeLeadingCmd : SINT;
		CrossBBlowDelayLeading : UINT;
		CrossBBlowDelayLeadingCmd : SINT;
		CrossBReverseRuntime : SINT;
		CrossBBlowTimeReversing : UINT;
		CrossBBlowTimeReversingCmd : SINT;
		CrossBBlowDelayReversing : UINT;
		CrossBBlowDelayReversingCmd : SINT;
		CrossBSectionColorRuntime : SINT;
		SetToRecpCmd : UINT;
		StackerAirBlastDelayCmd : UINT;
		StackerAirBlastDelay : UINT;
		StackerAirBlastOnTimeCmd : UINT;
		StackerAirBlastOnTime : UINT;
		StackerAirBlastShow : UINT;
		StackerJenWayDestinationRuntime : SINT;
		Stacker : HMIFoldProgStacker_Type;
		Outlet : HMIFoldProgOutlet_Type;
	END_STRUCT;
	HMIFoldProgStacker_Type : 	STRUCT 
		CouplingCmd : UINT;
		CouplingIndex : UINT;
		EdgeCmd : UINT;
		EdgeIndex : UINT;
		StopPosition : UINT;
		StopPositionCmd : UINT;
		JenWayDestination : UINT;
		JenWayDestinationCmd : UINT;
		OperatorCmd : UINT;
		SelectedStacker : UINT;
	END_STRUCT;
	HMIProcessStatus_Type : 	STRUCT 
		Reset : BOOL;
		cmdNextProcess : USINT;
		cmdPrevProcess : USINT;
		CurrentProcess : UINT;
		ManualKey : BOOL;
		ManualKeyCompletion : USINT;
		ServicePage : BOOL;
	END_STRUCT;
	JenwayExchange_Type : 	STRUCT 
		Updated : BOOL;
		DoUpdate : UINT;
		Exchange : ExchangeStackData_Type;
		OldExchangeStatus : UINT;
		RollOffCompleteCounter : UINT;
		OkToGoOutCounter : UINT;
		OkToGoOutWrongCounter : UINT;
		JenWayAckCounter : UINT;
		AskToGoOutCounter : UINT;
		AskToGoOutResendCounter : UINT;
		OldRollOffOutState : BOOL;
		RollOffGoesOutCounter : UINT;
	END_STRUCT;
	MachineAlarm_Type : 	STRUCT 
		Trigger : ARRAY[0..19]OF BOOL;
		Bypass : ARRAY[0..19]OF BOOL;
		Acknowledge : ARRAY[0..19]OF BOOL;
		GroupAlarm : USINT;
	END_STRUCT;
	MachineControl_Type : 	STRUCT 
		EStopActivated : BOOL;
		SafetyOk : BOOL;
		StartButton : BOOL;
		StopButton : BOOL;
		MotorProtectionTripped : BOOL;
		AirPressureIsOK : BOOL;
		DoorsClosed : BOOL;
		StopRequest : BOOL;
		ProcessesRunning : UINT;
		StartRequest : BOOL;
		ResetAllAlarm : BOOL;
		StopTime : UINT;
		StopTimer : UINT;
		ActivityTime : UINT;
		ActivityTimer : UINT;
		ErrorInProcess : UINT;
		OldSecond : UINT;
		IsRunning : BOOL;
		IsRunningTimer : UINT;
		LateralRunBeforeStop : UINT;
		ProcessActiveTime : UINT;
		ProcessActiveTimer : UINT;
		Category : UINT;
		AllProcessesIdle : BOOL;
		StopAttempt : BOOL;
		SimulStartButton : BOOL;
		SimulStopButton : BOOL;
		TemporaryMaster : BOOL;
		Program : UINT;
	END_STRUCT;
	VISU_MCFG_LYER : 	STRUCT 
		FeedTyp : VISU;
		HangerFeed : VISU;
		ManualKeys : VISU;
		ManualFeed : VISU;
		ManualFeedRuntime : UINT;
		DeleteDataRuntime : UINT;
		ReleaseInfeedJam : VISU;
	END_STRUCT;
	HMIConfig_Type : 	STRUCT 
		OutletView : ARRAY[0..10]OF UDINT;
		cmdOutletView : UINT;
	END_STRUCT;
	JwCustArt_Type : 	STRUCT 
		CustNo : UINT;
		ArtNo : UINT;
		RcpNo : USINT;
	END_STRUCT;
	Jenview_Type : 	STRUCT 
		DateTime : DATE_AND_TIME;
		GetCustName : BOOL;
		CustFromPanel : BOOL;
		ResetCount : BOOL;
		Eth : JwCustArt_Type;
		Op : JwCustArt_Type;
		Lb : JwCustArt_Type;
		Log : JwCustArt_Type;
		Count : ARRAY[0..3]OF BOOL;
		SortA : ARRAY[0..3]OF BOOL;
		SortB : ARRAY[0..3]OF BOOL;
		OprMin : ARRAY[0..3]OF UINT;
		OprCnt : ARRAY[0..3]OF UINT;
	END_STRUCT;
	LoadingData_Type : 	STRUCT 
		Accepted : BOOL;
		CustomerId : DINT;
		ArticleId : INT;
		BatchId : UINT;
		FoldProgram : INT;
		NewBatch : UINT;
		Flash : UINT;
	END_STRUCT;
	TEST_STEPS : 	STRUCT 
		lastStep : UINT;
		curStep : UINT;
		Steps : ARRAY[0..20]OF UINT;
		index : UINT;
	END_STRUCT;
	TEST_STEPPER : 	STRUCT 
		M_TConv : TEST_STEPS;
		M_Inlet : TEST_STEPS;
	END_STRUCT;
	OpPageCommand_Type : 	STRUCT 
		cmdNextFoldProgram : USINT;
		cmdPrevFoldProgram : USINT;
		cmdNewFoldProgram : USINT;
		NewFoldProgram : UINT;
		cmdIncFirstBladeTempAdjust : USINT;
		cmdDecFirstBladeTempAdjust : USINT;
		cmdIncSecondBladeTempAdjust : USINT;
		cmdDecSecondBladeTempAdjust : USINT;
	END_STRUCT;
	OperatorID_Type : 	STRUCT 
		No : UINT;
		Name : STRING[32];
	END_STRUCT;
	VISU : 	STRUCT 
		RTCom : USINT;
		RTPrint : USINT;
		Reset : USINT;
		BTN : USINT;
		HS : USINT;
		CMP : USINT;
		RT : USINT;
		COL : USINT;
		TXT : USINT;
		BAR : USINT;
		TM : UDINT;
		RTButton : ARRAY[0..10]OF USINT;
	END_STRUCT;
	StatisticRecord_Type : 	STRUCT 
		Pieces : ARRAY[0..10]OF UINT;
		OnTime : UDINT;
		RunTime : UDINT;
		OutletWaitTime : UDINT;
		EmptyHangerWaitTime : UDINT;
		JamTime : UDINT;
		NoHangersInletTime : UDINT;
		NoExternalHangerFeed : UDINT;
		ProductionStop : UDINT;
		Stopping : UDINT;
		Production : UDINT;
		AutoProgPieces : ARRAY[0..10]OF UINT;
	END_STRUCT;
	WebStatisticRecord_Type : 	STRUCT 
		RowText : STRING[21];
		ColumnValue : ARRAY[0..15]OF UINT;
	END_STRUCT;
	StatusIcon_Type : 	STRUCT 
		Icon : SINT;
		Visible : SINT;
		Flash : SINT;
		Key : SINT;
	END_STRUCT;
	Set_Rcp : 	STRUCT 
		StackerCoupling : BOOL;
		StackerEdge : BOOL;
		StackerStopPosition : BOOL;
		StackerJenWayDest : BOOL;
		OutletNumberOfProducts : BOOL;
		OutletFullIndexingTime : BOOL;
		OutletDelayRollOffOut : BOOL;
		LateralRightBladeOnTime : BOOL;
		LateralLeftBladeStartDelay : BOOL;
		LateralLeftBladeOnTime : BOOL;
		LateralBladeBackTime : BOOL;
		LateralWidthFirst : BOOL;
		LateralWidthLast : BOOL;
		LateralRightBladeStartDelay : BOOL;
	END_STRUCT;
	HMIConfigStacker_Type : 	STRUCT 
		CrossBeltNrCmd : UINT;
		CrossBeltNr : UINT;
		FlapsDelayOpenCmd : UINT;
		FlapsDelayOpen : UINT;
		FlapsTimeOpenCmd : UINT;
		FlapsTimeOpen : UINT;
		FlapsRestartDelayCmd : UINT;
		FlapsRestartDelay : UINT;
		StartPosition : UINT;
		StartPositionCmd : UINT;
		StopPosition : UINT;
		StopPositionCmd : UINT;
		OutletStartPosition : UINT;
		OutletStartPositionCmd : UINT;
		OutletStopPosition : UINT;
		OutletStopPositionCmd : UINT;
		OperatorCmd : UINT;
		SelectedStacker : UINT;
	END_STRUCT;
	MLabelConnection_Type : 	STRUCT 
		connectionIndex : UINT;
		ident : UDINT;
		isEnabled : BOOL;
		refreshTime : UDINT;
		IPAdress : STRING[17];
	END_STRUCT;
	MachProcessDuo_Type : 	STRUCT 
		Common : FoldTaskCommon_Type;
		Parameters : ParametersDuo_Type;
		ISInlet : BOOL; (*Manual start inlet button*)
		ISSort : BOOL; (*Sorting Button*)
		IBInlet : BOOL; (*Inlet photocell*)
		IBLF : BOOL; (*Photocell at the inlet to the LF - Used for measuring*)
		IBAutoL : ARRAY[0..4]OF BOOL;
		IBAutoW : ARRAY[0..4]OF BOOL;
		QMInletDuo : BOOL;
		QMVacuumDuo : BOOL;
		QCleanVentDuo : BOOL;
		requestDelivery : BOOL; (*Duo has linen and wants to talk to the Lateral fold*)
		testRunInlet : BOOL;
		useInverter : BOOL;
		inverterSpeed : UINT;
		BlockNormalInlet : BOOL; (*HMI Button to block the normal inlet*)
		AutoLengthON : BOOL;
		SortOutDuoEnd : BOOL; (*HMI Button to select where to sort out.*)
		ManualFeed : BOOL; (*HMI Button to select manual Feed.*)
		cmdRaiseTable : BOOL;
		cmdLowerTable : BOOL;
		lowerBlades : BOOL;
	END_STRUCT;
	Jenway_Type : 	STRUCT 
		CommOn : BOOL;
		No : ARRAY[0..4]OF Jenway_No_Type; (*0 = Outlet after crossconv; 1-4 = Outlet after RollOff on each stacker conv. *)
		ConvReady : BOOL;
	END_STRUCT;
	Jenway_No_Type : 	STRUCT 
		Ready : BOOL;
		Blocked : BOOL;
		Request : BOOL;
		Go : BOOL;
		Done : BOOL;
		ShowBlocked : BOOL;
	END_STRUCT;
	SimIO_Type : 	STRUCT 
		Test : BOOL;
		IIPrestopIn : BOOL;
		IISeperationIn : BOOL;
		IISupervisionSeperation : BOOL;
		IBGarmentDetection : BOOL;
		IBHangerDeloadReady : BOOL;
		IBHangerMove : BOOL;
		IIDeloadingUp : BOOL;
		IIDeloadingDown : BOOL;
		IBRightTrouseDetection : BOOL;
		IBJamDeloading : BOOL;
		IIJamDeloadingOut : BOOL;
		IBHorizontal : BOOL;
		IBXAFold : BOOL;
		IIBladeRightHome : BOOL;
		IBXBFold : BOOL;
		IBStacker : ARRAY[0..10]OF BOOL;
		IBGarmentOnInletMP : BOOL;
		IBInfeedBeltEndMP : BOOL;
	END_STRUCT;
END_TYPE
