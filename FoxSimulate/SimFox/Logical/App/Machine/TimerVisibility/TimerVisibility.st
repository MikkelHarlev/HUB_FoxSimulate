PROGRAM _CYCLIC
(*--------------------------------------------------------------------------------------------------------------------
	Author:			Jensen Denmark

	Filename:    	TimerVisibility.st

	Description: 	TimerVisibility handling

	History:	08-01-2018		V1.00	AHO		1st version
					  02-03-2021		V1.01	MKH 	Added:  ACfg timer
				
------------------------------------------------ cyclic program ----------------------------------------------------*)
	IF NOT g_Core.System.Runtime.isInitDone THEN
		RETURN;
	END_IF
	
	// --------------------------------------------------------------------------------
	// Timervisibility for RCfg, MCfg,HCfg  and ACfg timers
	//			
	// 0 = Showlevel from ParCfg
	// 1 = Always show
	// 2 = Always hide
	// --------------------------------------------------------------------------------
	// Recipe timers
	IF g_Core.Services.Recipe.Runtime.UpdateShowLevelEnable THEN
		g_Core.Services.Recipe.Runtime.UpdateShowLevelEnable := 0;
	

		UpdateShowLevel[RCFG].Ident := g_Core.Services.Recipe.Runtime.ParIdent;
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Name', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Extra1', VarLevel :=HIDE); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Extra2', VarLevel :=HIDE); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Extra3', VarLevel :=HIDE); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.SelectedStack', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.FoldMode', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.StartDelayLeftBlade', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.OnTimeLeftBlade', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.StartDelayRightBlade', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.OnTimeRightBlade', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.WidthFirst', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.WidthLast', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.BladeBackTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.FoldDistance', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.DelayBladeBack', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Lateral.BeltAdjust', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFold.FoldCombination', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFold.FixDimRearEdge', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFold.FixDimLeadEdge', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFold.XAMotorExtraTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.FoldDevice', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.Belt1DelayTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.Belt1OpenTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.BlowDelay', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.BlowTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.BlowBreak', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.BlowImpulses', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.KnifeDelay', VarLevel :=SEL((g_HCfg.CrossFoldingKnife) OR (g_HCfg.HeavyGarment), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldA.KnifeTime', VarLevel :=SEL((g_HCfg.CrossFoldingKnife) OR (g_HCfg.HeavyGarment), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.FoldDistance', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.SlopeMode', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.SlopeOnTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowTimeFolding', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowDelayFolding', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowTimeLeading', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowDelayLeading', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowTimeReversing', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.BlowDelayReversing', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.StopMotorEnable', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.StopMotorDelay', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.StopMotorTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.ReverseTimeAdjust', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.StopXAEnable', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.CrossFoldB.StopXADelay', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt1.AirBlastStartDelay', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=1), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt1.AirBlastOnTime', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=1), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt2.AirBlastStartDelay', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=3), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt2.AirBlastOnTime', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=3), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt3.AirBlastStartDelay', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=5), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt3.AirBlastOnTime', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=5), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt4.AirBlastStartDelay', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=7), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt4.AirBlastOnTime', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=7), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt5.AirBlastStartDelay', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=9), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.StackerBelt5.AirBlastOnTime', VarLevel :=SEL((g_HCfg.Micro) AND (g_HCfg.NumberOfStackers >=9), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.SelectSection', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.StackerSelection', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.StopLeadingOrRearEdge', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.StopLeading', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.StopPosition', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Stacker.JenWayDestination', VarLevel :=SEL((g_HCfg.DeliveryExternalCommunication > 0), HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Outlet.NumberOfProducts', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Outlet.Mode', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Outlet.FullIndexingTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Outlet.DelayRollOffOut', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Delivery.ConveyorTime', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.FactorySettingsUpdate', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Accum.AccumSTFRestartTimeDelay', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.Accum.AccumProxFarNearTimeout', VarLevel :=SHOW); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.XtremeHeavy.FXtremeGap', VarLevel :=SEL(g_HCfg.XtremeHeavy, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.XtremeHeavy.FRaiseStackerBelt', VarLevel :=SEL(g_HCfg.XtremeHeavy, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.XtremeHeavy.FSlackStackerBelt', VarLevel :=SEL(g_HCfg.XtremeHeavy, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.XtremeHeavy.FRaiseTiltConv', VarLevel :=SEL(g_HCfg.XtremeHeavy, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.DelayStartInlet', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.StackerSelection[0]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.StackerSelection[1]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.StackerSelection[2]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.StackerSelection[3]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthFirst[0]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthFirst[1]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthFirst[2]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthLast[0]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthLast[1]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[RCFG](VarName := 'g_RCfg.DuoInlet.WidthLast[2]', VarLevel :=SEL(g_HCfg.DuoInlet, HIDE, SHOW)); 


	
		IF UpdateShowLevel[RCFG].ChangeCount <> ChangeCountOld[RCFG] THEN
			g_Core.Services.Recipe.Interface.isCmdUpdatePar := 1;
		END_IF
		ChangeCountOld[RCFG] := UpdateShowLevel[RCFG].ChangeCount;
	END_IF

	// Machine timers
	IF g_Core.Services.Machine.Runtime.UpdateShowLevelEnable THEN
		g_Core.Services.Machine.Runtime.UpdateShowLevelEnable := 0;

		UpdateShowLevel[MCFG].Ident := g_Core.Services.Machine.Runtime.ParIdent;
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.SensorFilterTime', VarLevel := SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.SensorOverTime', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MotorSwitchTime', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.ConveyorRunTime', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.DelayStartTime', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.StatisticStackOrSection', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MultiBlowPules', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.NoReadAlarm', VarLevel := SEL((g_HCfg.HangerReading = 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.OnePhotocellShirtDetect', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.CheckShirtDelay', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.CheckShirtOnTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.GarmentDetectTimeout', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.DelayInletMotor', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.RunTimeTC1Start', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.OverallFunction', VarLevel := SEL(g_HCfg.OverallAlignment, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.OverallDetectionOnDelay', VarLevel := SEL(g_HCfg.OverallAlignment, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.OverallCenterDelay', VarLevel := SEL(g_HCfg.OverallAlignment, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.OverallCenterOnTime', VarLevel := SEL(g_HCfg.OverallAlignment, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.FlapTrouserFilterMs', VarLevel := SEL(g_HCfg.FlapTrousers, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.WaitFlapTrsPlateClosedTime', VarLevel := SEL(g_HCfg.FlapTrousers, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.WaitFlapTrsDetectTime', VarLevel := SEL(g_HCfg.FlapTrousers, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.FlapTrousersMiddle3OnDelay', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.FlapTrousersMiddle2OnDelay', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.FlapTrousersMiddle1OnDelay', VarLevel := SEL(g_HCfg.FlapTrousers, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.FlapTrousersSideOnDelay', VarLevel := SEL(g_HCfg.FlapTrousers, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.TrouserBlowDelay', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.TrouserBlowTime', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.TrouserBlowGap', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.TrouserBlowCount', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.RunInfeedAll', VarLevel := SEL(g_Core.System.Runtime.showLevel >= 10, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.SpeedInfeedTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.EmptyHangerLength', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.CheckCollapsedTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.HoldPoint', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.PassedTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.DelayStopHangerConveyor', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.DelayStopHangerConveyorLong', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.ConveyorShortRunTime', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.ConveyorShortRunPause', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.SpeedHzConveyorShortRun', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.SpeedHzBeltInfeed', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.SpeedHzBelt', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.SpeedSlowHangerBeltDeloader', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Hanger.SpeedToDeloaderDelay', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Vaccum.AlwaysUse', VarLevel := SEL((g_Exists.Vacuum OR g_HCfg.FeedManual), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Vaccum.StartupTime', VarLevel := SEL((g_Exists.Vacuum OR g_HCfg.FeedManual), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Vaccum.DelayOffSec', VarLevel := SEL((g_Exists.Vacuum OR g_HCfg.FeedManual), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Vaccum.FanCleaningTime', VarLevel := SEL((g_Exists.Vacuum OR g_HCfg.FeedManual), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Inlet.Vaccum.FanCleaningPieces', VarLevel := SEL((g_Exists.Vacuum OR g_HCfg.FeedManual), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.dwPos', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.upPos', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.speedUp', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.speedDw', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.accUp', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.decUp', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.accDw', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.decDw', VarLevel := SEL(NOT g_HCfg.FeedManual AND (g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.DeloadDelayTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.HangerInPlateTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.HangerClampDelay', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.HangerResetDelay', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.HangerResetTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.StartLiftTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.PressResetTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.HangerSlideOutTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.NextHangerTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.TwoStepsPjamaOpening', VarLevel := SEL(NOT (g_HCfg.FeedManual OR (g_HCfg.CombiHanger=1)), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.PajamasStopPos', VarLevel := SEL(NOT (g_HCfg.FeedManual OR (g_HCfg.CombiHanger=1)), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.PajamasStopPos2', VarLevel := SEL(NOT (g_HCfg.FeedManual OR (g_HCfg.CombiHanger=1)), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.PajamasRestartDelay', VarLevel := SEL(NOT (g_HCfg.FeedManual OR (g_HCfg.CombiHanger=1)), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.PajamePreBreakingTime',VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.InvertOutletFree', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.KG.HangerClampDelay', VarLevel := SEL(g_HCfg.KGHanger, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.KG.OpenHangerTimeOn', VarLevel := SEL(g_HCfg.KGHanger, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.KG.OpenHangerDelay', VarLevel := SEL(g_HCfg.KGHanger, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.KG.StopExtMotorDelay', VarLevel := SEL(g_HCfg.KGHanger, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Deloading.KG.StopExtMotorTimeOn', VarLevel := SEL(g_HCfg.KGHanger, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.TC.TurnerDistancePh', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.TC.DelayStartInfeed', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.TC.InfeedBeltOnTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.LFold.LiftBladesTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.LFold.BladeBackTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.LFold.FoldPosition', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.LFold.DistanceIBLA_FoldPoint', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.LFold.WidthIncrementOffset', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.XAMotorStoptime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.StartXAOffsetValue', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.DistanceXB_FoldPoint', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.CrossBExtraRewerseTime', VarLevel := SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.DistanceXBFoldPoint_XBExit', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.CrossAByPassPrestartFoldPoint', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.CrossBByPassPrestartFoldPoint', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.XFold.FixedDimSpeedFactor', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.BeltSpeedFactor', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[0]', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[1]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[2]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[3]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[4]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[5]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[6]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[7]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[8]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[9]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StartPosition[10]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[0]', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[1]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[2]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[3]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[4]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[5]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[6]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[7]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[8]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[9]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.StopPosition[10]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.FlapsDelayOpen', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.FlapsTimeOpen', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.FlapsRestartDelay', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.LiftRaiseDelay', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.JamOnDelay', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.DropTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.TransportOffSetTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.IndexingDelay', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.LengthSorting', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.BeltExtention', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.MaxSize', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Stacker.MaxSinkDelay', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.PressTime', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.IndexStopTime', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.RollOffReturnTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltLength', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[0]', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[1]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[2]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[3]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[4]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[5]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[6]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[7]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[8]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[9]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StartPosition[10]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[0]', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[1]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[2]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[3]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[4]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[5]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[6]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[7]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[8]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[9]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StopPosition[10]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.ConveyorRuntime', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[0]', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[1]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[2]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[3]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[4]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[5]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[6]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[7]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[8]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[9]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.CrossBeltNr[10]', VarLevel := SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StackChangeMode', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StackChangeOnlyPrgChange', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.StackSelectMode', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.ButtonPressTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Outlet.ZeroValueStackChange', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Delivery.Function', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Delivery.CrossBeltRunTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Delivery.CrossBeltOffSet', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Delivery.ExitRunTime', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Jenway.InvertJenwayReady', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Jenway.BlockTimer', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.UseExternalStatus', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.DataExchangeMode', VarLevel := SEL((g_HCfg.HangerReading = 8), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.ComMode', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.AutoProgramUfo', VarLevel := SEL((g_HCfg.HangerReading = 8) AND(g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.UfoIsLastProgram', VarLevel := SEL((g_HCfg.HangerReading = 8) AND(g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.IpAddressByte3', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.IpAddressByte4', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.ComRefreshTime', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.BCD_RequestTime', VarLevel := SEL((g_MCfg.Metricon.ComMode =4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.BCD_ReadDelay', VarLevel := SEL((g_MCfg.Metricon.ComMode =4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.BCD_HangerAwayDelay', VarLevel := SEL((g_MCfg.Metricon.ComMode =4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Metricon.BCD_RequestTries', VarLevel := SEL((g_MCfg.Metricon.ComMode =4), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.FullSensorOnTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.FullSensorOffTime', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.FullSensorOnPulse', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.FullSensorOffPulse', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.HangerAtPresenceProxTimeOut', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.STFRestartTimeDelay', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.PreStoperDelay', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Accum.ProxFarNearTimeout', VarLevel := SEL(NOT g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.CheckShirtDelay', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.CheckShirtOnTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.DelayVacuum', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.StartnletBeltDelayTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.AutoStartnletBeltDelayTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.AutoStartInletBelt', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.ReachInfeedBeltEndPHTimeOut', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeySelected', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.ReachGarmentDetectPHTimeOut', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.InfeedBeltAirBlastOnTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.InfeedBeltAirBlastDelay', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.ButtonSenistivityTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.ReleaseInfeedBeltJamTime', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[0].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[0].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[1].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[1].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[2].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[2].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[3].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[3].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[4].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[4].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[5].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[5].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[6].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[6].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[7].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[7].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[8].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[8].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[9].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[9].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[10].KeyStackIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MF.KeyConfig[10].KeyProgIndex', VarLevel := SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.AutoPrgSelect[0]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.AutoPrgSelect[1]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.AutoPrgSelect[2]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.AutoPrgSelect[3]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.RcpSelect[0]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.RcpSelect[1]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.RcpSelect[2]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.RcpSelect[3]', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.RaiseDuoInletDelay', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Duo.TowelsXADistanceFactor', VarLevel := SEL( g_HCfg.DuoInlet, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MachineID', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.GlobeUserName', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.GlobePassword', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Timezone.Zone', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Timezone.DaylightSavings', VarLevel :=SHOW); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Trace2File', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MLabelIpAddressByte3', VarLevel := SEL(g_HCfg.PrinterCom=1, HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MLabelIpAddressByte4', VarLevel := SEL(g_HCfg.PrinterCom=1, HIDE, SHOW)); 
//		UpdateShowLevel[MCFG](VarName := 'g_MCfg.MLabelComRefreshTime', VarLevel := SEL(g_HCfg.PrinterCom=1, HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.EnableCustArt', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.EnableOperator', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.FactorySettingsUpdate', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Extra1', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Extra2', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Extra3', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Extra4', VarLevel :=HIDE); 
		UpdateShowLevel[MCFG](VarName := 'g_MCfg.Extra5', VarLevel :=HIDE); 


		IF UpdateShowLevel[MCFG].ChangeCount <> ChangeCountOld[MCFG] THEN
			g_Core.Services.Machine.Interface.isCmdUpdatePar := 1;
		END_IF
		ChangeCountOld[MCFG] := UpdateShowLevel[MCFG].ChangeCount;
	END_IF

	// Hardware timers
	IF g_Core.Services.Hardware.Runtime.UpdateShowLevelEnable THEN
		g_Core.Services.Hardware.Runtime.UpdateShowLevelEnable := 0;

		UpdateShowLevel[HCFG].Ident := g_Core.Services.Hardware.Runtime.ParIdent;
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.Showlevel', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.HangerReading', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.KGHanger', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CombiHanger', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CrossFoldingKnife', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CrossFoldingGapAdjust', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.NumberOfStackers', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.StackerAirPipe', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IndexingConveyorsWithPushOff', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CrossConveyor', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CrossConveyorFotoSensorEnd', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW));
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.DeliveryConveyor', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.DeliveryConveyorFotoSensorEnd', VarLevel :=SEL((g_HCfg.DeliveryExternalCommunication = 0), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.DeliveryExternalCommunication', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.PrinterCom', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10) AND (g_HCfg.HangerReading=8), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.StackMaxHeightSensor', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.TrouserAlignment', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.OverallAlignment', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.FeedFromOldMetricon', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10) AND (g_HCfg.HangerReading=8), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.FlapTrousers', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.FeedManual', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.NumberOfButtonsMF', VarLevel :=SEL(g_HCfg.FeedManual, HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.XtremeHeavy', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.CHAirTShirt', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.AirBlowInlet', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.ElisMes', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.BibOverall', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.Micro', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.HeavyGarment', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.BlockDirection', VarLevel :=SHOW); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.DuoInlet', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.LoginGotoMachinePage', VarLevel :=SEL((g_Core.System.Runtime.showLevel >= 10), HIDE, SHOW));
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.BRSafety', VarLevel :=HIDE);
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.SettingsTrig', VarLevel :=HIDE); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.host', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.deviceID', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.key', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.isEnabled', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.isSendInfo', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.isSendAlert', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.connectTimeoutInSeconds', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.reconnectIntervalInSeconds', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.heartBeatInSeconds', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.liteInterfaceSampleInterval', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 
		UpdateShowLevel[HCFG](VarName := 'g_HCfg.IOT.isLiteInterfaceEnabled', VarLevel := SEL((g_Core.System.Runtime.showLevel >= 22), HIDE, SHOW)); 		

		IF UpdateShowLevel[HCFG].ChangeCount <> ChangeCountOld[HCFG] THEN
			g_Core.Services.Hardware.Interface.isCmdUpdatePar := 1;
		END_IF
		ChangeCountOld[HCFG] := UpdateShowLevel[HCFG].ChangeCount;
	END_IF
	
	// Autoprogram timers
	IF g_Core.Services.AutoProg.Runtime.UpdateShowLevelEnable THEN
		g_Core.Services.AutoProg.Runtime.UpdateShowLevelEnable := 0;

	UpdateShowLevel[ACFG].Ident := g_Core.Services.AutoProg.Runtime.ParIdent;	
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Name', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.WaitTimeInlet', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.VacuumEnabled', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.VacuumFlapDelayOn', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.VacuumFlapDelayOff', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.SwingDelay', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TShirtBlowDelay[0]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TShirtBlowDelay[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TShirtBlowOnTime[0]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TShirtBlowOnTime[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.ArmBlowDelay[0]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.ArmBlowDelay[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.ArmBlowOnTime[0]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.ArmBlowOnTime[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.InFeedBeltStartDelay', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.InFeedBeltOnTime', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.InFeedBeltStopDelay', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.InFeedBeltStopTime', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.InFeedStopOnTrousers', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.HangerBeltQuickStart', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DeloaderDwPos', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DeloaderSpeedUpPct', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DeloaderAccUpPct', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.SpeedHzHangerBelt', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.SpeedSlowHangerBeltDeloader', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DelayTrouserBlast', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DeloaderHeavyGarment', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.OnTimeTrouserBlast', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowPoint', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhTrousers.TwoVerticalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhTrousers.UseHorizontalLead', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhTrousers.UseHorizontalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhShirt.TwoVerticalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhShirt.UseHorizontalLead', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhShirt.UseHorizontalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhFlapTrousers.TwoVerticalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhFlapTrousers.UseHorizontalLead', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.PhFlapTrousers.UseHorizontalRear', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.BypassLateralBlades', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserAlignment', VarLevel :=SEL(g_HCfg.TrouserAlignment, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.ForceTrouser', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[0]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[2]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[3]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[4]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[5]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Categorys[6]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[0]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[2]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[3]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[4]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[5]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.LenghtPoints[6]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[0]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[1]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[2]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[3]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[4]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[5]', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Trouser[6]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FlapTrouserDetectionOn', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FlapTrousersAlignment', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FlapTrousersAirBlastOnTime', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FlapTrousersAirBlastStartDelay', VarLevel :=SHOW); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.XtremeHeavy', VarLevel :=SEL((g_HCfg.XtremeHeavy), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.XtremeRaiseBlades', VarLevel :=SEL((g_HCfg.XtremeHeavy), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.XtremeGuideplates', VarLevel :=SEL((g_HCfg.XtremeHeavy), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.DelayStopInlet', VarLevel :=SEL((NOT g_HCfg.FeedManual), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowEnable', VarLevel :=SEL(g_Exists.AirTrouses, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowAdjust', VarLevel :=SEL(g_Exists.AirTrouses, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowTimeAdjust', VarLevel :=SEL(g_Exists.AirTrouses, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowCountAdjust', VarLevel :=SEL(g_Exists.AirTrouses, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.TrouserBlowGapAdjust', VarLevel :=SEL(g_Exists.AirTrouses, HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[0]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[1]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 1), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[2]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 2), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[3]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 3), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[4]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 4), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[5]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 5), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[6]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 6), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[7]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 7), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[8]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 8), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[9]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 9), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.FullIndexingTime[10]', VarLevel :=SEL((g_HCfg.NumberOfStackers >= 10), HIDE, SHOW)); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[0]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[1]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[2]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[3]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[4]', VarLevel :=HIDE); 
	UpdateShowLevel[ACFG](VarName := 'g_ACfg.Extra[5]', VarLevel :=HIDE); 
	
		IF UpdateShowLevel[ACFG].ChangeCount <> ChangeCountOld[ACFG] THEN
			g_Core.Services.AutoProg.Interface.isCmdUpdatePar := 1;
		END_IF
		ChangeCountOld[ACFG] := UpdateShowLevel[ACFG].ChangeCount;
	END_IF
	
END_PROGRAM