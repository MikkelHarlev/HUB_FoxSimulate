ACTION HangerInletInit: 	
	EnableRecheck;
	
	TimeoutInletTime := 4001;
	
	StackDestinationTest := 1; // Used for testing multistacker, set a fixed Stack destination from Inlet...

	(* Common settings for the task *)
	g_HangerInletProcess.EnableFeeding := TRUE; // Always start feeding at startup...
	g_HangerInletProcess.AutoSelectColor := 46; // Yellow

	(* Individual settings for the task *)
	g_HangerInletProcess.Common.Description := 'Hanger Inlet';
	InitFoldTask(g_HangerInletProcess.Common, g_MachineManager[g_HangerInletProcess.Common.MachineManagerIndex]);
	
	g_AutoProgram.SelectedAutoProgram := 1;
	g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;

	FilterMiddleOff := 50;

	FlapTrouserFilter.CntAdr := ADR(g_MilliSeconds);
	FlapTrouserFilter.FMode := 1;
	FlapTrouserFilter.TMode := 0;
	FlapTrouserFilter();
	
	BIBOverallSideFilter.CntAdr := ADR(g_MilliSeconds);
	BIBOverallSideFilter.FMode := 1;
	BIBOverallSideFilter.TMode := 0;
	BIBOverallSideFilter();
	
	BIBOverallMiddleFilter.CntAdr := ADR(g_MilliSeconds);
	BIBOverallMiddleFilter.FMode := 1;
	BIBOverallMiddleFilter.TMode := 0;
	BIBOverallMiddleFilter();
	
	BIBOverallDetectFilter.CntAdr := ADR(g_MilliSeconds);
	BIBOverallDetectFilter.FMode := 1;
	BIBOverallDetectFilter.TMode := 0;
	BIBOverallDetectFilter();

	TrouserBlowFunction(CntNameAdr := ADR('g_MilliSeconds'), CntOutNameAdr := ADR('g_MilliSeconds'), MemNameAdr := ADR('TrouserBlow'), Mode := 1);

	(* YCH Force No com handling *)
	IF g_HCfg.HangerReading = 8 THEN // Com enabled(0)
		g_HangerInletProcess.ForcedNoCom := 0;
	ELSIF g_HCfg.HangerReading = 15 THEN // Data disabled(1)
		g_HangerInletProcess.ForcedNoCom := 1;
		g_HCfg.PrinterCom := 0;
	ELSIF g_HCfg.HangerReading = 0 THEN // All disabled(2)
		g_HangerInletProcess.ForcedNoCom := 2;
		g_HCfg.PrinterCom := 0;
	END_IF  	
END_ACTION


ACTION HangerInlet: 

	// Disable "All data" com when machine is configured to HangerReading and XML communication, but Metricon XML connection is disabled.
	IF (g_HangerInletProcess.ForcedNoCom = 0) AND (g_HCfg.HangerReading = 8) AND (g_MCfg.Metricon.ComMode = 1) AND NOT g_Core.Services.System.Runtime.file.Connection[1].isEnabled THEN // Com enabled(0)
		g_HangerInletProcess.ForcedNoCom := 2;
	END_IF

	(*#####################*)
	(* Get current time... *)
	(*#####################*)
	g_HangerInletProcess.Common.CurTimer := g_Timers._1_ms; (* Get current time *)
	IF g_HangerInletProcess.Common.LogBookFlag > 0 THEN
		strcpy(ADR(TmpStr),ADR(g_HangerInletProcess.Common.Description));
	END_IF

	ACfgProgram := LIMIT(0, g_HangerInletProcess.Common.Product.FoldProgram - 1, 98); 
	//################################
	// Block signal from Metricon 
	//################################
	g_HangerInletProcess.OutletIsFree.OnDelay := 2000;
	g_HangerInletProcess.OutletIsFree.OffDelay := 2000;

	// -------------------------------------------------------------------------
	// Check outlet is free to recieve hangers
	// -------------------------------------------------------------------------
	IF g_MCfg.Deloading.InvertOutletFree THEN
		OutletFreeSensor := NOT ISHangerOutletFree;
	ELSE
		OutletFreeSensor := ISHangerOutletFree;
	END_IF
	
	IF g_HangerInletProcess.ForcedNoCom = 2 THEN
		// Communication switched off
		g_HangerInletProcess.OutletIsFree.Input := TRUE;
	ELSIF g_MCfg.Metricon.UseExternalStatus = 1 THEN 
		// Use block signals from communication link...
		g_HangerInletProcess.OutletIsFree.Input := (g_ExternalCom.OutletFull = 0) OR (g_HCfg.HangerReading = 0);
	ELSIF g_MCfg.Metricon.UseExternalStatus = 0 THEN 
		// Use block signals from I/O connections...
		g_HangerInletProcess.OutletIsFree.Input := OutletFreeSensor;
	ELSIF g_MCfg.Metricon.UseExternalStatus = 2 THEN 
		// Both Metricon and io
		g_HangerInletProcess.OutletIsFree.Input := ((g_ExternalCom.OutletFull = 0) OR (g_HCfg.HangerReading = 0)) AND OutletFreeSensor;
	END_IF

	(*#################################*)
	(* copy status of exchange objects *)
	(*#################################*)
	g_HangerInletProcess.Common.Next := g_HangerOpenerProcess.Common.Previous;

	(*########################################*)
	(* Connect inputs to the module structure *)
	(*########################################*)
	// Detect shirt or trouser at inlet, one or both photocells needed for detection
	IF g_MCfg.Inlet.OnePhotocellShirtDetect THEN
		g_HangerInletProcess.ShirtDetect.Input := IBTrouseDetection OR IBLeftTrouseDetection OR IBRightTrouseDetection OR g_sim.IBRightTrouseDetection; 
	ELSE
		g_HangerInletProcess.ShirtDetect.Input := IBTrouseDetection OR IBLeftTrouseDetection AND IBRightTrouseDetection; 
	END_IF	
	g_HangerInletProcess.PresenceStepfeeder.Input := IISeperationIn OR g_sim.IISeperationIn; // Normal presence
	g_HangerInletProcess.Presence2Stepfeeder.Input := IISeperationIn OR g_sim.IISeperationIn; // Used to refeed hanger sins no presence in upper stf 
	g_HangerInletProcess.GarmentDetect.Input := IBGarmentDetection  OR g_sim.IBGarmentDetection; // Detect and measure garment at inlet
	g_HangerInletProcess.OverallDetection.Input := IBLeftOverallDetection OR IBRightOverallDetection; // Detects overall Option...

	// Filter out short peaks of wrong detection
	BIBOverallSideFilter(In := IBFlapTrousersSide[1] OR IBFlapTrousersSide[2], 	 Filter := 50);
	BIBOverallMiddleFilter(In := IBFlapTrousersMiddle[1] AND IBFlapTrousersMiddle[2], Filter := 50);
	BIBOverallDetectFilter (In := BIBOverallSideFilter.Out AND NOT BIBOverallMiddleFilter.Out, Filter := g_MCfg.Inlet.FlapTrouserFilterMs);

	g_HangerInletProcess.FlapTrousersMiddle1.Input := IBFlapTrousersMiddle[1] AND IBFlapTrousersMiddle[2];
	g_HangerInletProcess.FlapTrousersMiddle2.Input := TRUE;
	g_HangerInletProcess.FlapTrousersMiddle3.Input := TRUE;
	g_HangerInletProcess.FlapTrousersSide.Input := IBFlapTrousersSide[1];

	g_HangerInletProcess.ResetAfterStackChange := ISResetStackChange;

	(*######################*)
	(* Connect timer values *)
	(*######################*)
	g_HangerInletProcess.Common.WatchDogStartupTime := 4000;
	g_HangerInletProcess.Common.WatchDogRunTime := 2800;

	g_HangerInletProcess.PresenceStepfeeder.OnDelay := 2000;
	g_HangerInletProcess.PresenceStepfeeder.OffDelay := parPresenceStepfeederOffDelay;
	g_HangerInletProcess.Presence2Stepfeeder.OnDelay := 1; 
	g_HangerInletProcess.Presence2Stepfeeder.OffDelay := parPresence2StepfeederOffDelay;
	g_HangerInletProcess.HangerPassedStf.OnDelay := 0;
	g_HangerInletProcess.HangerPassedStf.OffDelay := 50; 

	g_HangerInletProcess.StepFeeder.StartDelayTime := 10;
	g_HangerInletProcess.StepFeeder.OnTime := 700; 

	g_HangerInletProcess.ShirtDetect.OnDelay := g_MCfg.SensorFilterTime;
	g_HangerInletProcess.ShirtDetect.OffDelay := g_MCfg.SensorFilterTime;
	g_HangerInletProcess.GarmentDetect.OnDelay := 20; // changed from 30// Filter time to avoid false collapsed hangers.
	g_HangerInletProcess.GarmentDetect.OffDelay := 100;

	g_HangerInletProcess.OverallDetection.OnDelay := MAX(g_MCfg.Inlet.OverallDetectionOnDelay ,50);
	g_HangerInletProcess.OverallDetection.OffDelay := 50; 

	// Run Infeed belt when hanger comes into machine...
	g_HangerInletProcess.InFeedBeltRun.StartDelayTime := g_ACfg[ACfgProgram].InFeedBeltStartDelay;
	g_HangerInletProcess.InFeedBeltRun.OnTime := g_ACfg[ACfgProgram].InFeedBeltOnTime;

	g_HangerInletProcess.CheckHangerTime := 1500;
	g_HangerInletProcess.HangerConveyorOnTime := TimeoutInletTime;
	g_HangerInletProcess.ReCheckHangerTime := 6000; // Try to refeed hanger in double stepfeeder... 
	g_HangerInletProcess.HangerPassedTime := MIN(g_MCfg.Inlet.Hanger.PassedTime, 2000);
	g_HangerInletProcess.HoldPointTime := g_MCfg.Inlet.Hanger.HoldPoint;

	g_HangerInletProcess.CheckForShirt.StartDelayTime := g_MCfg.Inlet.CheckShirtDelay;
	g_HangerInletProcess.CheckForShirt.OnTime := g_MCfg.Inlet.CheckShirtOnTime;

	g_HangerInletProcess.OverallCenter.StartDelayTime := g_MCfg.Inlet.OverallCenterDelay; 
	g_HangerInletProcess.OverallCenter.OnTime := g_MCfg.Inlet.OverallCenterOnTime;

	g_HangerInletProcess.Vacuum.StartDelayTime := 0;
	g_HangerInletProcess.Vacuum.OnTime := 10; // Just to trigger a raising edge..

	g_HangerInletProcess.FanCleaningTime := g_MCfg.Inlet.Vaccum.FanCleaningTime;
	g_HangerInletProcess.HangerBeforeCleaning := g_MCfg.Inlet.Vaccum.FanCleaningPieces; 
								
	g_HangerInletProcess.DelayInletBelt.StartDelayTime := g_MCfg.Inlet.DelayInletMotor;
	g_HangerInletProcess.DelayInletBelt.OnTime := 10; // Just to trigger a raising edge..

	g_HangerInletProcess.CollapsedTime := g_MCfg.Inlet.Hanger.CheckCollapsedTime;

	WaitHangerSwingTime := g_ACfg[ACfgProgram].SwingDelay;

	g_HangerInletProcess.Common.ExitTime := 100;

	g_HangerInletProcess.InletBeltTC1Start.StartDelayTime := 1;
	g_HangerInletProcess.InletBeltTC1Start.OnTime := g_MCfg.Inlet.RunTimeTC1Start;

	HangerNoReadMax := g_MCfg.Inlet.NoReadAlarm; // Trigger alarm after number of no reads

	g_HangerInletProcess.IdleTime := 20000; // Inlet has been idle, Index stack at Holbaek
	
	//g_HangerInletProcess.CheckUnexpectedHangerFeedTime := 1500;	// Set at declaration

	//WaitStartConvTime := g_MCfg.DelayStartHangerConveyor;
	WaitStartConvTime := g_ACfg[ACfgProgram].WaitTimeInlet;
	WaitStopConvTime := g_MCfg.Inlet.Hanger.DelayStopHangerConveyor;
	WaitStopConvLongTime := g_MCfg.Inlet.Hanger.DelayStopHangerConveyorLong;
	WaitFlapTrsPlateClosedTime := MAX(g_MCfg.Inlet.WaitFlapTrsPlateClosedTime,100);
	WaitFlapTrsDetectTime := MAX(g_MCfg.Inlet.WaitFlapTrsDetectTime, 300);

	FlapTrouserDetectionOn := g_ACfg[ACfgProgram].FlapTrouserDetectionOn;

	// 2.2.17 -> param added to Auto Prog
	g_HangerInletProcess.FlapTrousersAir.OnTime := g_ACfg[ACfgProgram].FlapTrousersAirBlastOnTime;
	//g_HangerInletProcess.FlapTrousersAir.StartDelayTime := g_ACfg[ACfgProgram].FlapTrousersAirBlastStartDelay;
	FlapTrousersAirBlastStartDelay := g_ACfg[ACfgProgram].FlapTrousersAirBlastStartDelay;
	g_HangerInletProcess.FlapTrousersMiddle1.OnDelay := MAX(g_MCfg.Inlet.FlapTrousersMiddle1OnDelay, 2);
	g_HangerInletProcess.FlapTrousersMiddle2.OnDelay := MAX(g_MCfg.Inlet.FlapTrousersMiddle2OnDelay, 2);
	g_HangerInletProcess.FlapTrousersMiddle3.OnDelay := MAX(g_MCfg.Inlet.FlapTrousersMiddle3OnDelay, 2);
	g_HangerInletProcess.FlapTrousersSide.OnDelay := MAX(g_MCfg.Inlet.FlapTrousersSideOnDelay, 20);

	g_HangerInletProcess.FlapTrousersMiddle1.OffDelay := FilterMiddleOff;
	g_HangerInletProcess.FlapTrousersMiddle2.OffDelay := FilterMiddleOff;

	// Option for combi hanger...
	g_HangerInletProcess.CombiHanger := g_HCfg.CombiHanger;

	//YCH. Metricon option: 8= Hanger Data and position (XML or IO), 15= Only Hanger position, 0=No Metricon
	g_HangerInletProcess.HangerReading := g_HCfg.HangerReading; 

	(*#####################*)
	(* Stop feeding on jam *)
	(*#####################*)
	IF g_ProcessAlarm THEN
		g_HangerInletProcess.EnableFeeding := FALSE; 
	END_IF
	IF EDGENEG(g_ProcessAlarm) AND (NOT g_Machine.StopAttempt) AND NOT rStopFeeding THEN
		g_HangerInletProcess.EnableFeeding := TRUE; 
	END_IF

	(*##################*)
	(* Stop feeding HMI *)
	(*##################*)		
	IF g_HangerInletProcess.StopFeedingCmd = 1 THEN
		rStopFeeding := TRUE;
		g_HangerInletProcess.StopFeedingCmd := 0;
		IF g_HangerInletProcess.EnableFeeding THEN // Hanger inlet is blocked, red light...
			g_HangerInletProcess.EnableFeeding := FALSE; 
		ELSIF NOT g_HangerInletProcess.EnableFeeding AND NOT g_Machine.StopAttempt THEN // Hanger inlet is running, green light...	
			g_HangerInletProcess.EnableFeeding := TRUE; 
			rStopFeeding := FALSE; 
		END_IF	
	END_IF	
	
	HMIEnableFeeding := g_HangerInletProcess.EnableFeeding;	
	HMIAirBlowInlet := NOT g_HCfg.AirBlowInlet;

	(*#######################*)
	(* Force No com handling *)
	(*#######################*)	
	IF g_HangerInletProcess.ForcedNoCom = 0 THEN // No force com
		g_HangerInletProcess.HangerReading := g_HCfg.HangerReading;
	ELSIF g_HangerInletProcess.ForcedNoCom >= 1 THEN // Forced No com
		g_HangerInletProcess.HangerReading := 0; 
		g_HCfg.PrinterCom := 0;
	END_IF	

	(* Handle Input signals *)
	RunIOCounter(g_HangerInletProcess.PresenceStepfeeder, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.Presence2Stepfeeder, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.ShirtDetect, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.GarmentDetect, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.OverallDetection, g_HangerInletProcess.Common.CurTimer);
	// V1.07.5 Flap Trousres 
	RunIOCounter(g_HangerInletProcess.FlapTrousersMiddle1, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.FlapTrousersMiddle2, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.FlapTrousersMiddle3, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.FlapTrousersSide, g_HangerInletProcess.Common.CurTimer);
	RunIOCounter(g_HangerInletProcess.OutletIsFree, g_HangerInletProcess.Common.CurTimer);

	FlapTrouserFilter.Filter := g_MCfg.Inlet.FlapTrouserFilterMs;
	FlapTrouserFilter (In := g_HangerInletProcess.FlapTrousersMiddle3.Output AND NOT g_HangerInletProcess.FlapTrousersMiddle1.Output);
	
	IF g_HangerInletProcess.Common.State > MACHPROC_INIT_0 AND g_HangerInletProcess.Common.State < MACHPROC_TRIG_ERROR_98 THEN
		ElapsedTimeCount[0] := ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.Common.WatchDogRunTimer);
	END_IF

	RunFoldTask(g_MCfg.Trace2File, ADR(T2FD), g_HangerInletProcess.Common, g_MachineManager[g_HangerInletProcess.Common.MachineManagerIndex]);

	//###################################################################
	// If a hanger passed into the machine let step feeder try X times
	//###################################################################
	IF IIPrestopIn THEN 
		g_HangerInletProcess.StepfeederTries := 6;
	END_IF			

	IF EDGEPOS(IIHangerFlagLeft) THEN
		FlagLeftCount[0] := g_MilliSeconds;
	END_IF		
	IF EDGEPOS(IIHangerFlagRight) THEN
		FlagRightCount[0] := g_MilliSeconds;
	END_IF		

	IF EDGEPOS(g_HangerInletProcess.Common.State = MACHPROC_RUN_20) THEN
		g_HangerInletProcess.Common.Product.Stack := 0;
		g_HangerInletProcess.Common.Product.HangerFlagLeft := 0;
	END_IF

	REdgeposHangerFlag := EDGEPOS(IIHangerFlagLeft);

	g_EnableFeedingWaiting := FALSE;
	g_NoHangersAtInlet := FALSE;

	IF g_HangerOpenerProcess.HangerInPosition.Output AND NOT g_Core.System.Runtime.isRunning THEN
		HangerWaitAfterRestart := TRUE;
	END_IF
	CASE g_HangerInletProcess.Common.State OF


		MACHPROC_INIT_0:
			g_HangerInletProcess.isInProgress := FALSE;
		
			(*####################################*)
			(* Start Up Machine, Home Axels etc.. *)
			(*####################################*)
		MACHPROC_STARTUP_1:
			g_HangerInletProcess.Common.Previous.TransferStatus := EXC_STANDBY_0;
			g_HangerInletProcess.Common.Next.TransferStatus := EXC_STANDBY_0;
			g_HangerInletProcess.HangerConveyorMotor := TRUE;
			g_HangerSpeed := HANGER_SPEED_NORMAL_0;
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; // start watchdog timer for process 
			g_HangerInletProcess.CheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 
			g_HangerInletProcess.DelayStartTimer := 0; // Reset this timer when machine is stopped... 
			g_HangerInletProcess.StepfeederTries := 6;
			g_HangerInletProcess.GarmentLenght := 0;
			g_HangerInletProcess.isCollapsedHanger := FALSE;
			g_HangerInletProcess.Common.State := MACHPROC_STARTUP_2; 

			(* Check if hanger on Hanger conveyor *)
		MACHPROC_STARTUP_2:
			// Hanger on the conveyor at startup... 
			IF g_HangerInletProcess.GarmentDetect.Output THEN
				g_HangerInletProcess.Common.ErrorCode := 5; 
				g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98; 
			END_IF		

			// No hanger on Conveyor... 
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.CheckHangerTimer) >= g_HangerInletProcess.CheckHangerTime) THEN
				g_HangerInletProcess.HangerConveyorMotor := FALSE;
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; (* start watchdog timer for process *)
				g_HangerInletProcess.Common.State := MACHPROC_RUN_20; 
			END_IF		

			g_HangerInletProcess.ReCheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 

			(*###############################################################*)
			(* Machine Stop case, to handle shut down process of the module  *)
			(*###############################################################*)
		MACHPROC_STOP_15:
			(* Reset output and handle the shutdown procedure *)
			(* Extra stop cases may be needed.. *)
			g_HangerInletProcess.Common.State := MACHPROC_INIT_0;
			g_HangerInletProcess.Common.FoldUnit1.State := 0;
			g_HangerInletProcess.Common.FoldUnit2.State := 0;
			g_HangerInletProcess.Common.Motor.cmdStop := TRUE;
			g_HangerInletProcess.StepFeeder.State := FOLDIO_STATE_IDLE_0;
			//		g_HangerInletProcess.FlapTrousersAir.State := FOLDIO_STATE_IDLE_0;
			FlapTrousersAirBlastActive := FALSE; 
			SleeveBlastLeft.Set := FALSE;
			SleeveBlastRight.Set := FALSE;
			g_HangerInletProcess.DelayStartTimer := 0; // Reset this timer when machine is stopped... 
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
			g_HangerInletProcess.GarmentLenght := 0;

			(*#####################*)
			(* Main running state  *)
			(*#####################*)
		MACHPROC_RUN_20:
			g_HangerInletProcess.GarmentLenght := 0;
			
			g_HangerInletProcess.isInProgress := FALSE;
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
			g_HangerInletProcess.FlapTrouserAlignment := FALSE; 
			g_HangerInletProcess.isCollapsedHanger := FALSE;
			CheckForShirtHangerDetected := FALSE;

			(* Hanger in place and hanger opener is ready *)
			(* We also check the lenght of the previous garment to se if we should start or not... *)
			IF NOT g_HangerOpenerProcess.HangerInPosition.Output AND g_Core.System.Runtime.isRunning THEN
				HangerWaitAfterRestart := FALSE;
			ELSIF  g_HangerOpenerProcess.HangerInPosition.Output AND g_Machine.AllProcessesIdle AND (g_HangerOpenerProcess.Common.ErrorCode =0) THEN // trigger error when garment is under deloader on start
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'HO not ready check photocell');
				g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
				g_HangerInletProcess.isCollapsedHanger := TRUE;
				g_HangerInletProcess.Common.ErrorCode := 12;
			END_IF
			//IF g_HangerInletProcess.PresenceStepfeeder.Output AND (NOT g_HangerInletProcess.GarmentDetect.Output 
			
			IF NOT HangerWaitAfterRestart AND g_HangerInletProcess.PresenceStepfeeder.Output AND (NOT g_HangerInletProcess.GarmentDetect.Output 
				AND (g_HangerInletProcess.GarmentLenght < 20) 
				AND g_HangerInletProcess.StepFeeder.State = FOLDIO_STATE_IDLE_0
				AND NOT g_CommunicationErrorMetricon OR (g_HangerInletProcess.ForcedNoCom = 2) OR (g_HangerInletProcess.HangerReading = 0))
				AND g_HangerInletProcess.OutletIsFree.Output AND g_HangerInletProcess.EnableFeeding AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN
				
				g_HangerInletProcess.isInProgress := TRUE;
				g_HangerSpeed := HANGER_SPEED_NORMAL_0;
				FlapTrouserAutoDetect := FALSE;
				OldFlapTrousersMid1NotCovered := FlapTrousersMid1NotCovered;
				OldFlapTrousersMid3Covered := FlapTrousersMid3Covered;
				OldFlapTrouserAutoDetect := FlapTrouserAutoDetect;
				OldHangerProcess := g_HangerInletProcess;
				g_HangerInletProcess.CheckUnexpectedHangerFeed := FALSE;
			
				g_HangerInletProcess.Common.Product.NoRead := FALSE;
				IF g_HangerInletProcess.DelayStartTimer = 0 THEN
					g_HangerInletProcess.DelayStartTimer := g_HangerInletProcess.Common.CurTimer;
				END_IF			
				// No hanger reading or Disabled or Just full signals communication...
				IF (g_HangerInletProcess.HangerReading = 0) OR (g_HangerInletProcess.ForcedNoCom = 1) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_FULL_IO_3) THEN 
					g_HangerInletProcess.Common.Product.FoldProgram := g_AutoProgram.SelectedAutoProgram; 
					g_HangerInletProcess.Common.Product.BatchId := g_BatchId;
					g_HangerInletProcess.Common.Product.Article := g_ArticleNumber := g_ArticleNumber + 1;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Feed hanger');
					// Set yellow color for hanger manual selection..
					g_HangerInletProcess.AutoSelectColor := 46; // Yellow...	
					g_HangerInletProcess.Common.State := MACHPROC_DELAY_START_24;
				ELSIF g_HangerInletProcess.HangerReading = 15 THEN // To test double step feeder with out hanger reading for Inhouse test..
					g_HangerInletProcess.Common.Product.FoldProgram := g_AutoProgram.SelectedAutoProgram; 
					g_HangerInletProcess.Common.Product.BatchId := g_BatchId;
					g_HangerInletProcess.Common.Product.Article := g_ArticleNumber := g_ArticleNumber + 1 ;
					IF StackDestinationTest > g_HCfg.NumberOfStackers THEN
						StackDestinationTest := 1;
					END_IF					
					g_HangerInletProcess.Common.Product.Stack := StackDestinationTest;
					IF ManualStackChange THEN
						//ManualStackChange := FALSE;
						StackChangeIndex := StackChangeIndex + 1;
					END_IF	
					g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Feed hanger Manual data');
					// Set yellow color for hanger manual selection..
					g_HangerInletProcess.AutoSelectColor := 46; // Yellow...	
					g_HangerInletProcess.Common.State := MACHPROC_DELAY_START_24;
				ELSIF g_HangerInletProcess.HangerReading = 8 THEN // Hanger reading with data exchange 	
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Wait hanger data');
					ReadDelayTimer := g_HangerOpenerProcess.Common.CurTimer; 
					g_HangerInletProcess.ReCheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 
					g_HangerInletProcess.Common.State := MACHPROC_WAIT_READ_22;
				END_IF	
			END_IF

			IF ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.CheckUnexpectedHangerFeedTimer) >= g_HangerInletProcess.CheckUnexpectedHangerFeedTime THEN
				g_HangerInletProcess.CheckUnexpectedHangerFeed := FALSE;
			END_IF
			
			// If we have a double stepfeeder we need to refeed if no hanger is in front position... 
			IF NOT g_HangerInletProcess.Presence2Stepfeeder.Output AND NOT g_HangerInletProcess.ReCheckHanger AND g_HangerInletProcess.StepFeeder.State = FOLDIO_STATE_IDLE_0
				AND (g_HangerInletProcess.GarmentLenght < 20) AND (g_HangerInletProcess.StepfeederTries > 0) AND NOT g_Core.System.Interface.alarms.isLowAirPressure THEN // Let stepfeeder try a couple of times...
				
				g_HangerInletProcess.CheckUnexpectedHangerFeed := TRUE;
				g_HangerInletProcess.CheckUnexpectedHangerFeedTimer := g_HangerInletProcess.Common.CurTimer;
				
				g_HangerInletProcess.ReCheckHanger := TRUE;
				g_HangerInletProcess.StepFeeder.State := FOLDIO_STATE_START_1;
				IF g_HangerInletProcess.StepfeederTries > 0 THEN
					g_HangerInletProcess.StepfeederTries := g_HangerInletProcess.StepfeederTries - 1;
				END_IF	
				g_HangerInletProcess.ReCheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 
			END_IF
			// Here is a dangerous point if presence is lost we can feed extra hangers down...	
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.ReCheckHangerTimer) >= g_HangerInletProcess.ReCheckHangerTime) AND NOT g_HangerInletProcess.Presence2Stepfeeder.Output THEN
				g_HangerInletProcess.ReCheckHanger := FALSE;
				g_HangerInletProcess.ReCheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 
			END_IF
			
			// Alarm if the refeed from prestop has unexpected feed a hanger into inlet.
			IF g_HangerInletProcess.CheckUnexpectedHangerFeed AND g_HangerInletProcess.HangerPassedStf.Output THEN
				g_HangerInletProcess.CheckUnexpectedHangerFeed := FALSE;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Unexpected hanger dropped in inlet');
				g_HangerInletProcess.Common.ErrorCode := 11; 
				g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
			END_IF
			

			IF IIHangerFlagLeft THEN
				FlagLeftCount[1] := g_MilliSeconds;
			END_IF
			IF REdgeposHangerFlag THEN
				FlagLeftCount[1] := g_MilliSeconds;
			END_IF		
			IF IIHangerFlagLeft THEN
				HangerFlagTest[0] := HangerFlagTest[0] + 1;
				g_HangerInletProcess.Common.Product.Stack := 2; // To wich stacker 09-11-24
				g_HangerInletProcess.Common.Product.HangerFlagLeft := 1;
			END_IF		

			(* Reset the Counter when the Inlet Belt has started... *)
//			IF g_TopConveyorProcess.InfeedBeltMotor THEN
			IF g_TopConveyorProcess.StopInFeedBelt.State = FOLDIO_STATE_START_1 THEN				
				g_HangerInletProcess.GarmentLenght := 0;
			END_IF

			// If no hangers in Stepfeeder set flag to count time...
			g_NoHangersAtInlet := NOT g_HangerInletProcess.Presence2Stepfeeder.Output; 

			g_EnableFeedingWaiting := (g_HangerInletProcess.GarmentLenght < 20) 
			AND g_HangerInletProcess.StepFeeder.State = FOLDIO_STATE_IDLE_0
			AND (g_HangerInletProcess.OutletIsFree.Output OR (g_HangerInletProcess.ForcedNoCom = 2) OR g_HangerInletProcess.HangerReading = 0)
			AND NOT g_HangerInletProcess.EnableFeeding; // Stop feeding not activated...
			
			// Reset The FlapTrousers Detection Plate
			g_HangerInletProcess.FlapTrousersDetectionPlate := FALSE;

			IF g_HCfg.FlapTrousers AND g_ACfg[g_AutoProgram.SelectedAutoProgram -1].FlapTrousersAlignment THEN 
				g_HangerInletProcess.FlapTrousersPlate := TRUE;
				FlapTrousersAirBlastActive := TRUE;
			ELSE
				g_HangerInletProcess.FlapTrousersPlate := FALSE;
				FlapTrousersAirBlastActive := FALSE;
			END_IF

		MACHPROC_WAIT_READ_22:		
			// Trigger a request to Metricon for hanger data... 
			ReadDelayTime := 0;
			// Wait some time for hanger to go down and be read before we make the reguest... POX
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, ReadDelayTimer) >= ReadDelayTime) THEN
				IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
					BCD_Conntection := 0;
				END_IF			
				g_ExternalCom.HangerState := EXTERN_HANGER_REQUEST_1;
				g_LogInletHanger.HType := LOG_TYPE_HANGER_REGUEST_1;
				g_LogInletHanger.Article := 0;
				g_LogInletHanger.Customer := 0;
				g_LogInletHanger.Destination := 0;
				g_LogInletHanger.HangerIdStr := '';
				g_LogInletHanger.Program := 0;
				g_LogInletHanger.StackChange := 0; 
				g_LogInletHanger.DoLog := TRUE; // Write data to logrecord...
				HangerNoRead := HangerNoRead + 1; // Always increase this counter is cleared if OK read...		
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_DATA_23;
			END_IF		

		MACHPROC_WAIT_DATA_23:
			(* Hand shake with Metricon... *)
			IF (g_ExternalCom.HangerState = EXTERN_HANGER_WAIT_2) AND (g_HangerInletProcess.ForcedNoCom <> 2) THEN
				; (* External search in progress *)
			ELSIF g_ExternalCom.HangerState = EXTERN_HANGER_FOUND_6 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Data OK');
				IF g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4 THEN
					g_HangerInletProcess.Common.Product.FoldProgram := g_AutoProgram.OperatorAutoProgram;
				ELSE
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_HangerInletProcess.Common.Product.FoldProgram := 1; 
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_I, Bad fold program');
					ELSE
						g_HangerInletProcess.Common.Product.FoldProgram := g_ExternalCom.Recipe;
					END_IF	
				END_IF	
			
				// Full data exchange		
				IF (g_MCfg.Metricon.ComMode <> 4) AND g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0 THEN
					g_HangerInletProcess.Common.Product.BatchId := UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_HangerInletProcess.Common.Product.Customer := UDINT_TO_UINT(g_ExternalCom.CustomerId); 
					g_HangerInletProcess.Common.Product.Article := g_ExternalCom.ArticleId;
					IF g_ExternalCom.Destination > 0 THEN
						StackDestTestCount[0] := StackDestTestCount[0] + 1;
					END_IF
					StackDestTestCount[1] := StackDestTestCount[1] + 1;
					IF (g_MCfg.Outlet.StackChangeMode <> OUTLET_STACK_CHANGE_LENGTH_6) THEN
						g_HangerInletProcess.Common.Product.Stack := g_ExternalCom.Destination; // To wich stacker
					END_IF
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_HangerInletProcess.ExternalRecipe := 1;
					ELSE
						g_HangerInletProcess.ExternalRecipe := g_ExternalCom.Recipe;
					END_IF	
					// Auto program and No stack destination	
				ELSIF (g_MCfg.Metricon.ComMode <> 4) AND g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1 THEN
					g_HangerInletProcess.Common.Product.BatchId := UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_HangerInletProcess.Common.Product.Customer := UDINT_TO_UINT(g_ExternalCom.CustomerId);
					g_HangerInletProcess.Common.Product.Article := g_ExternalCom.ArticleId;
					IF (g_MCfg.Outlet.StackChangeMode <> OUTLET_STACK_CHANGE_LENGTH_6) THEN
						g_HangerInletProcess.Common.Product.Stack := 0; // To wich stacker
					END_IF
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_HangerInletProcess.ExternalRecipe := 1;
					ELSE
						g_HangerInletProcess.ExternalRecipe := g_ExternalCom.Recipe;
					END_IF		
				ELSIF g_MCfg.Metricon.ComMode = 4 THEN //AND (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_1 OR g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2) THEN
					IF (g_ExternalCom.Recipe < 1) OR (g_ExternalCom.Recipe > 99) THEN
						g_HangerInletProcess.ExternalRecipe := 1;
					ELSE
						g_HangerInletProcess.ExternalRecipe := g_ExternalCom.Recipe;
					END_IF
					g_HangerInletProcess.Common.Product.Stack := 0; // To wich stacker
				END_IF
						
				IF OverwriteAutoprog > 0 THEN
					g_AutoProgram.SelectedAutoProgram := OverwriteAutoprog;
					g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;
					OverwriteAutoprog := 0;
					g_HangerInletProcess.Common.Product.FoldProgram :=	g_AutoProgram.SelectedAutoProgram;
					g_HangerInletProcess.ManualChangeAutoProg := TRUE;
				END_IF
			
				IF (g_HangerInletProcess.ManualChangeAutoProg) THEN
					IF (g_HangerInletProcess.AutoProgBackUp <> g_HangerInletProcess.ExternalRecipe) THEN
						g_AutoProgram.SelectedAutoProgram := g_HangerInletProcess.ExternalRecipe;
						g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;
						g_HangerInletProcess.ManualChangeAutoProg := FALSE;
					ELSE
						g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;
						g_HangerInletProcess.Common.Product.FoldProgram :=	g_AutoProgram.SelectedAutoProgram;
					END_IF
				ELSIF (NOT g_HangerInletProcess.ManualChangeAutoProg) THEN
					g_AutoProgram.SelectedAutoProgram := g_HangerInletProcess.ExternalRecipe;
					g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;
					OverwriteAutoprog := 0;
				END_IF
									
				// Make strings of HangerId data...
//				DataMakeStr(g_ExternalCom.HangerId, ADR(g_HangerInletProcess.Common.Product.HangerId));
//				DataMakeStr(g_ExternalCom.GarmentId, ADR(g_HangerInletProcess.Common.Product.GarmentId));			
				
				//Copy Hanger/garmentID
				g_HangerInletProcess.Common.Product.HangerId := g_ExternalCom.Ethernet.GarmentData.HangerId;
				g_HangerInletProcess.Common.Product.GarmentId := g_ExternalCom.Ethernet.GarmentData.GarmentId;
		
				HangerNoRead := 0; // Clear counter every time we get a OK reading	
			
				// Set green color for hanger OK
				g_HangerInletProcess.AutoSelectColor := 10; // Green...			
			
				// Make a stack change if AutoProgram change / and stack change on Fold program... 10-01-28..
				IF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_FOLDPROG_1 THEN
					IF g_AutoProgram.SelectedAutoProgram <> OldAutoProgram THEN
						StackChangeIndex := StackChangeIndex + 1;
						g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Stack change A-P Changed');
					END_IF
				END_IF
						
				// Stack change...
				IF ((g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0) OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_ONLY_STACKCHANGE_4)
					OR (g_MCfg.Metricon.DataExchangeMode = DATA_EX_AUTO_STACKCHANGE_2)) AND (g_MCfg.Outlet.StackChangeMode <> OUTLET_STACK_CHANGE_RESET_4) THEN
					IF ((g_ExternalCom.StackChange = 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 0)) OR ((g_ExternalCom.StackChange < 0) AND (g_MCfg.Outlet.ZeroValueStackChange = 1)) OR (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_LENGTH_6) THEN
						IF g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_MET_FPROG_5 THEN
							IF g_AutoProgram.SelectedAutoProgram <> OldAutoProgram THEN
								StackChangeIndex := StackChangeIndex + 1;
								g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
								LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Stack change A-P Changed');
							END_IF
						ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_LENGTH_6) AND (g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0) THEN
												
							IF (Step = 0) AND (NOT Wait_Sorting) THEN
								g_HangerInletProcess.Common.Product.PreStackChange := FALSE;
								Wait_Sorting := TRUE;
								Step := 1;
							ELSIF Step = 6 THEN
								IF g_ExternalCom.Destination >= 100 THEN
									IF (g_ExternalCom.Destination MOD 100) <= UINT_TO_INT(g_HCfg.NumberOfStackers) THEN 
										IF g_HangerInletProcess.Common.Product.Stack = INT_TO_UINT(g_ExternalCom.Destination MOD 100) THEN
											Wait_Sorting := FALSE;
										ELSE
											Stacker := 0;
											Length := 0;
											Step := 1;
										END_IF
									ELSE
										Wait_Sorting := FALSE;
									END_IF
								ELSE
									Wait_Sorting := FALSE;
								END_IF
							END_IF									
						ELSE						
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet No Stack change');
							; // No stack change do nothing
						END_IF
						//ELSIF (g_ExternalCom.StackChange > 0) THEN
					ELSIF (g_ExternalCom.StackChange > 0) OR ((g_MCfg.Outlet.ZeroValueStackChange = 1) AND (g_ExternalCom.StackChange >= 0)) THEN
						// To give a Stack index number to the garments, if the stack change garment is lost in the folder...			
						StackChangeIndex := StackChangeIndex + 1;
						// Take care on high stack numbers...
						g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Stack change triggerd');
					END_IF

				ELSIF (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_RESET_4) AND (g_MCfg.Metricon.DataExchangeMode = DATA_EX_FULL_0) THEN
					IF ((g_ExternalCom.StackChange > 0) OR ((g_MCfg.Outlet.ZeroValueStackChange = 1) AND (g_ExternalCom.StackChange >= 0)))
						AND (g_HangerInletProcess.Common.Product.Customer = OldCustomer) THEN
						// To give a Stack index number to the garments, if the stack change garment is lost in the folder...			
						StackChangeIndex := StackChangeIndex + 1;
						// Take care on high stack numbers...
						g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Stack change triggerd');

					ELSIF (g_HangerInletProcess.Common.Product.Customer <> OldCustomer) THEN 
						g_HangerInletProcess.EnableFeeding := FALSE;
						g_HangerInletProcess.CustomerStackChange := TRUE;
						g_HangerInletProcess.StopFeedingOnCustomerChange := TRUE;
						g_HangerInletProcess.Common.State := MACHPROC_RUN_20;    						
					END_IF
				END_IF
			
				// set here because of new option above
				OldAutoProgram := g_AutoProgram.SelectedAutoProgram;
			
				IF (NOT g_HangerInletProcess.StopFeedingOnCustomerChange) AND NOT Wait_Sorting THEN 
					// Counter on Inlet service page							
					g_HangerInletProcess.NoReadCount := 0; // Reset counter...	
					g_HangerInletProcess.DiagCounters.HangerReadOK := g_HangerInletProcess.DiagCounters.HangerReadOK + 1;
			
					// Log data	
					g_LogInletHanger.HType := LOG_TYPE_HANGER_FOUND_6;
					g_LogInletHanger.Article := g_ExternalCom.ArticleId;
					g_LogInletHanger.Customer := g_ExternalCom.CustomerId;
					g_LogInletHanger.Destination := g_ExternalCom.Destination;
					DataMakeStr(g_ExternalCom.HangerId, ADR(g_LogInletHanger.HangerIdStr));
					g_LogInletHanger.Program := g_ExternalCom.Recipe;
					g_LogInletHanger.StackChange := g_ExternalCom.StackChange; 
					g_LogInletHanger.DoLog := TRUE; // Write data to logrecord...
						
					IF g_HangerInletProcess.DelayStartTimer = 0 THEN
						g_HangerInletProcess.DelayStartTimer := g_HangerInletProcess.Common.CurTimer;
					END_IF			
				
					IF g_ExternalCom.ArticleId > 0 THEN
						g_ArticleNumber := g_ExternalCom.ArticleId;
					END_IF
					IF g_ExternalCom.CustomerId > 0 THEN
						g_CustomerNumber := g_ExternalCom.CustomerId;
					END_IF			
					Step := 0;
					g_HangerInletProcess.Common.State := MACHPROC_DELAY_START_24; 
				END_IF
		
			ELSIF (g_ExternalCom.HangerState = EXTERN_HANGER_FAIL_9) OR (g_HangerInletProcess.ForcedNoCom = 2) THEN
				IF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_READ THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_I, No read');
					g_HangerInletProcess.NoReadCount := g_HangerInletProcess.NoReadCount + 1;
					g_HangerInletProcess.DiagCounters.NoRead := g_HangerInletProcess.DiagCounters.NoRead + 1;
				ELSIF g_ExternalCom.MetricHangerReadStatus = HANGER_READ_STATE_NO_DATA OR (g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4) THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_I, No Data');
					g_HangerInletProcess.DiagCounters.NoData := g_HangerInletProcess.DiagCounters.NoData + 1;
				END_IF	
				g_HangerInletProcess.Common.Product.NoRead := TRUE;
				
				// Set red color for hanger NOT OK
				g_HangerInletProcess.AutoSelectColor := 51; // Red...	
				IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
					g_HangerInletProcess.Common.Product.FoldProgram := g_AutoProgram.SelectedAutoProgram; //OldAutoProgram; 
					g_HangerInletProcess.Common.Product.Stack := 0;
					StackChangeIndex := StackChangeIndex + 1;
					g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex; // Trigger stack change on ufo hangers
					g_HangerInletProcess.Common.State := MACHPROC_DELAY_START_24; 
				ELSE	
					// We got default data from Metricon
					IF g_MCfg.Metricon.UfoIsLastProgram THEN
						g_HangerInletProcess.Common.Product.FoldProgram := LIMIT(1, g_HangerInletProcess.Common.Product.FoldProgram, 99); 
					ELSE
						g_HangerInletProcess.Common.Product.FoldProgram := g_MCfg.Metricon.AutoProgramUfo; 
					END_IF
					
					g_AutoProgram.SelectedAutoProgram := g_HangerInletProcess.Common.Product.FoldProgram;
					g_AutoProgram.OperatorAutoProgram := g_HangerInletProcess.Common.Product.FoldProgram;                                                               
					g_HangerInletProcess.Common.Product.Stack := g_HCfg.NumberOfStackers; // To wich stacker 09-11-24
					StackChangeIndex := StackChangeIndex + 1;
					g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex; // Trigger stack change on ufo hangers
					g_LogInletHanger.HType := LOG_TYPE_NODATA_FORCED_66;
					g_LogInletHanger.Article := g_ExternalCom.ArticleId;
					g_LogInletHanger.Customer := g_ExternalCom.CustomerId;
					g_LogInletHanger.Destination := g_ExternalCom.Destination;
					DataMakeStr(g_ExternalCom.HangerId, ADR(g_LogInletHanger.HangerIdStr));
					g_LogInletHanger.Program := g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.GarmentData.Program;
					g_LogInletHanger.StackChange := 1; 
					g_LogInletHanger.DoLog := TRUE; // Write data to logrecord...	
					g_HangerInletProcess.Common.State := MACHPROC_DELAY_START_24;
				END_IF
			END_IF

			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer;
	
			(* If no more presence in stf go back to Run state... *)
			IF NOT g_HangerInletProcess.PresenceStepfeeder.Output THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_I Lost presence');
			END_IF	

		MACHPROC_DELAY_START_24:		
			g_AutoProgram.OperatorAutoProgram := g_AutoProgram.SelectedAutoProgram;
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
			IF EDGEPOS(g_HangerInletProcess.VacuumMotor) THEN
				g_HangerInletProcess.VacuumStartupTimer	:= g_HangerInletProcess.Common.CurTimer;
			END_IF	
			IF g_HCfg.FlapTrousers AND g_ACfg[g_AutoProgram.SelectedAutoProgram - 1].FlapTrousersAlignment THEN 
				g_HangerInletProcess.FlapTrousersPlate := TRUE;
				FlapTrousersAirBlastActive := TRUE;
			ELSE
				g_HangerInletProcess.FlapTrousersPlate := FALSE;
				FlapTrousersAirBlastActive := FALSE;
			END_IF
		
			// Start feeding hanger after delay timer for speed controll of machine...
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.DelayStartTimer) >= g_HangerInletProcess.DelayStartTime) AND g_HangerInletProcess.StepFeeder.State = FOLDIO_STATE_IDLE_0 
				AND (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.VacuumStartupTimer) >= g_MCfg.Inlet.Vaccum.StartupTime OR NOT g_HangerInletProcess.VacuumMotor OR NOT g_Exists.Vacuum) THEN
				g_HangerInletProcess.StepFeeder.State := FOLDIO_STATE_START_1;
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Delay start is done');
				g_HangerInletProcess.LeadingPoint := 0;
				//g_HangerInletProcess.PulsCounter := 0;
				g_HangerInletProcess.FlapTrouserDetectPosCounter := g_HangerInletProcess.PulsCounter;
				g_HangerInletProcess.GarmentLenght := 0;
				g_HangerInletProcess.NoHangerPassed := FALSE;
				g_HangerInletProcess.Common.Product.ProductType := TROUSER_TYPE_0; // Default every garment is a Trouser 
				g_HangerInletProcess.HangerPassedTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.DelayStartTimer := g_HangerInletProcess.Common.CurTimer; // Start timer here to have over the whole cycle 
				g_HangerInletProcess.HangerPassedStf.OldEdgeCounter := g_HangerInletProcess.HangerPassedStf.EdgeCounter; // Start the trigger

				IF g_ExternalCom.ConnectionType = CONNECTION_TYPE_BCD_4 THEN
					g_ExternalCom.HangerState := EXTERN_HANGER_AWAY_3;
				END_IF			 
				// Stack change test
				IF g_HMIStackChange > 0 THEN
					g_HMIStackChange := 0;
					StackChangeIndex := StackChangeIndex + 1;
					g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
				END_IF
				g_HangerInletProcess.Common.State := MACHPROC_CHECK_HANGER_PASSED_25;
			END_IF	

		MACHPROC_CHECK_HANGER_PASSED_25:	
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
			
			// Check for hanger passed sensor...
			ElapsedTimeCount[2] := ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.HangerPassedTimer);
			IF ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.HangerPassedTimer) >= g_HangerInletProcess.HangerPassedTime AND NOT g_sim.Test THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, No hanger passed signal');
				g_HangerInletProcess.NoHangerPassed := TRUE;
				g_HangerInletProcess.Common.ErrorCode := 4; (* Hanger passed error...  *)	
				g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
			END_IF

			// Check hanger no read count
			IF (HangerNoReadMax > 0) AND NOT g_HangerInletProcess.HangerReadError THEN
				IF HangerNoRead >= HangerNoReadMax THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Hanger max read error');
					g_HangerInletProcess.HangerReadError := TRUE;
					g_HangerInletProcess.Common.ErrorCode := 7; // Hanger read error... 
					g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
				END_IF		
			END_IF	

			// Hanger has passed, normal case 
			IF g_HangerInletProcess.HangerPassedStf.EdgeCounter > g_HangerInletProcess.HangerPassedStf.OldEdgeCounter THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Hanger passed OK');
				ElapsedTimeCount[6] := ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.HangerPassedTimer);
				// Set hanger away to Metricon if hanger was sent into folder 
				IF g_HangerInletProcess.HangerReading >= 8 THEN
					IF g_ExternalCom.ConnectionType <> CONNECTION_TYPE_BCD_4 THEN
						g_ExternalCom.HangerState := EXTERN_HANGER_AWAY_3;
					END_IF
					g_LogInletHanger.HType := LOG_TYPE_HANGER_AWAY_3;
					g_LogInletHanger.Article := 0;
					g_LogInletHanger.Customer := 0;
					g_LogInletHanger.Destination := 0;
					g_LogInletHanger.HangerIdStr := '';
					g_LogInletHanger.Program := 0;
					g_LogInletHanger.StackChange := 0; 
					g_LogInletHanger.DoLog := TRUE; // Write data to logrecord...
				END_IF	
				WaitHangerSwingTimer := g_HangerInletProcess.Common.CurTimer;

				// Special trouser airblast
				TrouserBlow.Count := g_MilliSeconds + g_MCfg.Inlet.TrouserBlowDelay + g_ACfg[ACfgProgram].TrouserBlowAdjust;
				TrouserBlow.On := g_MCfg.Inlet.TrouserBlowTime + g_ACfg[ACfgProgram].TrouserBlowTimeAdjust;
				TrouserBlow.Gap := g_MCfg.Inlet.TrouserBlowGap + g_ACfg[ACfgProgram].TrouserBlowGapAdjust;
				TrouserBlow.OutCount := g_MCfg.Inlet.TrouserBlowCount + g_ACfg[ACfgProgram].TrouserBlowCountAdjust;
				TrouserBlow.Set := g_ACfg[ACfgProgram].TrouserBlowEnable;
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_SWING_45;
			END_IF

		MACHPROC_WAIT_SWING_45:
			// Wait tbefore starting HangerConveyor if very light garments, the swing into the machien and craches..	
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
			ElapsedTimeCount[3] := (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitHangerSwingTimer) >= WaitHangerSwingTime);
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitHangerSwingTimer) >= WaitHangerSwingTime)THEN
				LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Has waited for swing');
				g_HangerInletProcess.HangerReadError := FALSE;
				g_HangerInletProcess.CollapsedTimer := g_HangerInletProcess.PulsCounter; 
				g_HangerInletProcess.HangerConveyorOnTimer := g_HangerInletProcess.PulsCounter; 
				g_HangerInletProcess.HangerConveyorMotor := TRUE;
				g_HangerSpeed := HANGER_SPEED_INFEED_1;
				HangerConveyorShortRun.Set := g_MCfg.Inlet.Hanger.ConveyorShortRunTime > 0;
				HangerSpeedInfeedTime_Delay.Set := TRUE;
				WaitStopConvTimer := g_HangerInletProcess.PulsCounter;
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer;
				OverallDetected := FALSE; 
				FlapTrousersMid3Covered := FALSE;
				g_HangerInletProcess.Common.Product.IsFlapTrousers := FALSE;
				IsFlapTrouser := FALSE;
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_STOPCONV_26;
			END_IF

			// Stop hanger on rubber belt to stop swinging
		MACHPROC_WAIT_STOPCONV_26:
			ElapsedTimeCount[4] := (ElapsedMsTime(g_HangerInletProcess.PulsCounter, WaitStopConvTimer) >= WaitStopConvTime);
			IF (ElapsedMsTime(g_HangerInletProcess.PulsCounter, WaitStopConvTimer) >= WaitStopConvTime)THEN
				LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Combi wait stopped');
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
						
				IF (g_HCfg.FlapTrousers > 0) AND FlapTrouserDetectionOn THEN
					TestCounter := 0;
					WaitFlapTrsDetectTimer := g_HangerInletProcess.Common.CurTimer;
					FlapTrousersSideCovered := FALSE; 
					IsFlapTrouser := FALSE;
					g_HangerInletProcess.Common.Product.IsFlapTrousers := FALSE;
					FlapTrousersMid1NotCovered := FALSE; 
					FlapTrousersMid2NotCovered := FALSE;
					g_HangerInletProcess.FlapTrouserAlignment := FALSE; 
					FlapTrousersAirBlastActive := FALSE;
					RLogFlapDetect := FALSE;
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 2, g_HangerInletProcess.Common.LogBookFlag, TestCounter, 'H_Inlet, FlapTro _26');
					g_HangerInletProcess.FlapTrousersDetectionPlate := TRUE; 
					g_HangerInletProcess.HangerConveyorMotor := FALSE;
					g_HangerInletProcess.Common.State := MACHPROC_FLAPTRS_DETECT_31;
				ELSE
					WaitStartConvTimer := g_HangerInletProcess.Common.CurTimer;
					g_HangerInletProcess.Common.State := MACHPROC_WAIT_RESTARTCONV_28;
					//				g_HangerInletProcess.FlapTrousersPlate := FALSE; 
				END_IF
			END_IF

			// Flap Trousers Detection 
		MACHPROC_FLAPTRS_DETECT_31:
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitFlapTrsDetectTimer) >= WaitFlapTrsDetectTime) THEN //OR g_HangerInletProcess.FlapTrouserAlignment THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_HangerInletProcess.Common.LogBookFlag, TestCounter, 'H_Inlet, Flap Trousers Detection end');
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
				WaitFlapTrsPlateClosedTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.Common.State := MACHPROC_FLAPTR_WAIT_32;
			END_IF
		
			// Remember if Side PH was detected for filter time
			IF g_HangerInletProcess.FlapTrousersSide.Output  THEN
				FlapTrousersSideCovered := TRUE; 
			END_IF

			// Remember if Middle PH 1 was detected for filter time
			IF NOT g_HangerInletProcess.FlapTrousersMiddle1.Output AND FlapTrousersMid3Covered THEN
				FlapTrousersMid1NotCovered := TRUE; 
			END_IF

			// Remember if Middle PH 2 was detected for filter time
			IF NOT g_HangerInletProcess.FlapTrousersMiddle2.Output  AND FlapTrousersMid3Covered THEN
				FlapTrousersMid2NotCovered := TRUE; 
			END_IF

			// Remember if Middle PH 3 was detected for filter time
			IF g_HangerInletProcess.FlapTrousersMiddle3.Output  THEN
				FlapTrousersMid3Covered := TRUE; 
			END_IF
		
			IF BIBOverallDetectFilter.Out THEN
				IsFlapTrouser := TRUE;
			END_IF		
		
			IF g_HCfg.FlapTrousers > 0 THEN 
				// Detection of Flaptrousers manualy if option is set and no data exchange 
				IF g_HCfg.HangerReading <> 8  THEN
					IF NOT RLogFlapDetect THEN
						LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_HangerInletProcess.Common.LogBookFlag, TestCounter, 'H_Inlet, FlapTrous Check');
					END_IF

					// One of the middle PHs was uncoverd for filter time 
					//IF ((FlapTrousersMid1NotCovered OR FlapTrousersMid2NotCovered) AND FlapTrousersMid3Covered) AND NOT OverallDetected THEN 
					IF IsFlapTrouser AND NOT OverallDetected THEN 
						g_HangerInletProcess.Common.Product.ProductType := TROUSER_TYPE_0;
						g_HangerInletProcess.Common.Product.IsFlapTrousers := TRUE;
						g_HangerInletProcess.FlapTrouserAlignment := TRUE; 
						FlapTrouserAutoDetect := TRUE;
						IF NOT RLogFlapDetect THEN
							LogEntry(g_MCfg.Trace2File, ADR(T2FD), 6, g_HangerInletProcess.Common.LogBookFlag, TestCounter, 'H_Inlet, FlapTrous Set');
						END_IF
					END_IF	
					RLogFlapDetect := 1;
				ELSE
					// Detection by recipe compere (Metricon sends a prog that is set as Flaptrousers in AutoProg)
					IF g_ACfg[ACfgProgram].FlapTrousersAlignment	THEN 
						g_HangerInletProcess.FlapTrouserAlignment := TRUE; 
					END_IF
				END_IF
			END_IF
			IF g_HangerInletProcess.FlapTrouserAlignment THEN
				// Close detectionPlate immedietely after detection
				g_HangerInletProcess.FlapTrousersDetectionPlate := FALSE; 
				// Reset Air Blast 
				FlapTrousersAirBlastActive := FALSE; 
			END_IF
		
			// Jump if Overall detected 			
			IF g_HangerInletProcess.OverallDetection.Output AND NOT g_HangerInletProcess.FlapTrousersPlate THEN
				OverallDetected:= TRUE; 
				WaitStartConvTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_RESTARTCONV_28;
				g_HangerInletProcess.FlapTrousersDetectionPlate := FALSE; 
			END_IF
		
			// Flap Trousers Detection 
		MACHPROC_FLAPTR_WAIT_32:
			// Close detectionPlate immedietely after detection
			g_HangerInletProcess.FlapTrousersDetectionPlate := FALSE; 
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitFlapTrsPlateClosedTimer) >= WaitFlapTrsPlateClosedTime) THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Flap Trousers Wait before Plate closed');
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
				WaitStartConvTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_RESTARTCONV_28;
			END_IF
	
			// Restart again after time and Hanger opener is ready..
		MACHPROC_WAIT_RESTARTCONV_28:
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
			ElapsedTimeCount[5] := ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitStartConvTimer);
			IF ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, WaitStartConvTimer) >= WaitStartConvTime OR g_HangerInletProcess.FlapTrouserAlignment THEN

				IF (g_HangerInletProcess.Common.Next.TransferStatus = EXC_RECIVING_DONE_6) OR (g_HangerInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0) THEN // Garment has left the inlet belt..
					g_HangerInletProcess.Common.Next.TransferStatus := EXC_STANDBY_0; 
					g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
					g_HangerInletProcess.HangerConveyorMotor := TRUE;
					IF ( g_Inverter.Drive[0].GetStatusExtended <> 24594 ) OR (g_Inverter.Drive[0].GetStatus <> 1591 AND g_Inverter.Drive[0].GetStatus <> 567 ) THEN // Log:inverter status is differ from expected
						LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_Inverter.Drive[0].GetStatusExtended, 'H_Inlet, GetStatusExtended');
						LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_Inverter.Drive[0].GetStatus, 'H_Inlet, GetStatus');
					END_IF	
					g_HangerInletProcess.HangerConveyorOnTimer := g_HangerInletProcess.PulsCounter;
					g_HangerInletProcess.VacuumFlapDelayTimer := g_HangerInletProcess.Common.CurTimer;//g_HangerInletProcess.PulsCounter;
					g_HangerInletProcess.CollapsedTimer := g_HangerInletProcess.PulsCounter; 
					LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet, Combi wait start');

					// Moved the overall detection here 2010-07-20 WM...		
					// Activate overall alignment function...				
					IF g_HCfg.OverallAlignment THEN
						IF (g_HangerInletProcess.OverallDetection.Output) OR (BIT_TST(g_MCfg.Inlet.OverallFunction, 2)) THEN
							g_HangerInletProcess.OverallCenter.State := FOLDIO_STATE_START_1; 
						END_IF
					END_IF
					// Activate the Vacuum
					IF g_HCfg.OverallAlignment THEN
						IF (g_HangerInletProcess.OverallDetection.Output) OR (BIT_TST(g_MCfg.Inlet.OverallFunction, 1)) THEN
							g_HangerInletProcess.Vacuum.State := FOLDIO_STATE_START_1;
						END_IF
					END_IF	
					// Set data that it is a Overall in the product
					IF g_HCfg.OverallAlignment THEN
						IF (g_HangerInletProcess.OverallDetection.Output) THEN
							g_HangerInletProcess.Common.Product.Size := 2500;
						ELSE	
							g_HangerInletProcess.Common.Product.Size := 0;
						END_IF
					END_IF		

					// Activate the Inlet belt 
					IF g_HCfg.OverallAlignment THEN
						g_HangerInletProcess.DelayInletBelt.State := FOLDIO_STATE_START_1;
					END_IF	
					g_HangerInletProcess.InletGarmentDetectTimer := g_HangerInletProcess.Common.CurTimer; 

					g_HangerInletProcess.Common.State := MACHPROC_WAIT_SENSOR_27; 
				END_IF
			
				// start AirBlast for FlapTrousers
				IF g_HangerInletProcess.FlapTrouserAlignment THEN
					FlapTrousersAirBlastActive := TRUE; 
					g_HangerInletProcess.FlapTrousersDetectionPlate := FALSE; 
				END_IF
			END_IF

			// Wait for garment to pass photocell a cross inlet
		MACHPROC_WAIT_SENSOR_27:
			// Log inverter status
			IF g_Inverter.Drive[0].GetStatusExtended <> 24594 AND  g_Inverter.Drive[0].GetStatusExtended <> 27218 AND  g_Inverter.Drive[0].GetStatusExtended <> 25170 
				OR (g_Inverter.Drive[0].GetStatus <> 567 AND g_Inverter.Drive[0].GetStatus <> 1591 ) THEN	// Log:inverter status is differ from expected
				LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_Inverter.Drive[0].GetStatusExtended, 'H_Inlet, GetStatusExtended');
				LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_Inverter.Drive[0].GetStatus, 'H_Inlet, GetStatus');
			END_IF	
			// Garment passes the photocell
			GarmentDetectElapsedTime := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.CollapsedTimer);
			IF g_HangerInletProcess.GarmentDetect.Output THEN
				g_HangerInletProcess.FlapTrouserDetectPos := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.FlapTrouserDetectPosCounter);
				g_HangerInletProcess.FlapTrouserDetectPosCounter := g_HangerInletProcess.PulsCounter;
				g_HangerInletProcess.CollapsedTimer := g_HangerInletProcess.PulsCounter; 
				g_HangerInletProcess.InFeedBeltRun.State := FOLDIO_STATE_START_1;
				g_HangerInletProcess.HoldPointTimer := g_HangerInletProcess.PulsCounter;
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
				g_HangerInletProcess.InletGarmentDetectTimer := g_HangerInletProcess.Common.CurTimer; 
				// Open window for Shirt/Trouser detection 
				//g_HangerInletProcess.CheckForShirt.State := FOLDIO_STATE_START_1;
				//LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'CheckForShirt Delay start');
				CheckForShirtHangerDetected := TRUE;
				LogEntry(TRUE, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, GarmentDetectElapsedTime, 'H-Inl lead garment');
				HangerDetected := FALSE;
				g_HangerInletProcess.Common.State := MACHPROC_CHECK_COLLAPSED_29;
			END_IF

			// Check point for Empty Combi hangers
			// Empty Combi hangers jump over the sensor, but we need to run them through the machine anyway...
			IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.InletGarmentDetectTimer) >= g_MCfg.Inlet.GarmentDetectTimeout) THEN
				IF (g_HangerInletProcess.CombiHanger = 1) THEN
					LogEntry(TRUE, ADR(T2FD), 7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Empty hanger timeout');
					g_HangerInletProcess.GarmentLenght := 0;
					g_HangerInletProcess.HoldPointTimer := g_HangerInletProcess.PulsCounter;
					g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer;
					g_HangerInletProcess.CollapsedTimer := g_HangerInletProcess.PulsCounter; 
					HangerDetected := FALSE;
					g_HangerInletProcess.Common.State := MACHPROC_CHECK_HOLD_30;
				ELSE
					LogEntry(TRUE, ADR(T2FD), 7, g_HangerOpenerProcess.Common.LogBookFlag, ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.InletGarmentDetectTimer), 'Hanger not at inlet');
					g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
					g_HangerInletProcess.Common.ErrorCode := 10;
				END_IF	
			END_IF	
		
			// To check if a collapsed lobster hanger goes into the machine..
		MACHPROC_CHECK_COLLAPSED_29:
			// Only use Blast if Trousers detected 
			ElapsedTimeCount[7] := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.FlapTrouserDetectPosCounter);
				
			IF NOT HangerDetected THEN
				CollapsedCheckRuntime := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.CollapsedTimer);
			END_IF
				
			// If no input it's a collapsed hanger, or Combi hanger option do not check this, photocell do not detect combi hanger...
			IF IBLeftTrouseDetection OR IBRightTrouseDetection OR (g_HangerInletProcess.CombiHanger = 1) OR g_HCfg.KGHanger OR g_sim.Test THEN
				HangerDetected := TRUE; 
			END_IF
				
			// Check point 	
			IF ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.CollapsedTimer) >= g_MCfg.Inlet.Hanger.CheckCollapsedTime THEN 
				// If collapsed hanger trigger error..
				IF HangerDetected THEN
					iCol := (iCol + 1) MOD (SIZEOF(CollapsedCheckRuntimeOk) / SIZEOF(CollapsedCheckRuntimeOk[0]) - 1);
					CollapsedCheckRuntimeOk[iCol] := CollapsedCheckRuntime;
					CollapsedCheckRuntimeMax := MAX(CollapsedCheckRuntime, CollapsedCheckRuntimeMax);
					LogEntry(TRUE, ADR(T2FD), 7, g_HangerOpenerProcess.Common.LogBookFlag, CollapsedCheckRuntime, 'Hanger wings detected - not collapsed');
					g_HangerInletProcess.Common.State := MACHPROC_CHECK_HOLD_30;
				ELSE
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerOpenerProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Collapsed hanger');
					g_HangerInletProcess.Common.State := MACHPROC_TRIG_ERROR_98;
					g_HangerInletProcess.isCollapsedHanger := TRUE;
					g_HangerInletProcess.Common.ErrorCode := 6;
				END_IF	
			END_IF	
			
			// Hold point before the Hanger opener 
		MACHPROC_CHECK_HOLD_30:
			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; (* start watchdog timer for process *)

			IF g_HangerInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Wants to unload');
				g_HangerInletProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
			END_IF

			// Check if Holdpoint or not
			IF (ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.HoldPointTimer) >= g_HangerInletProcess.HoldPointTime) OR NOT g_HangerInletProcess.HangerConveyorMotor THEN
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Check hold or not');
				IF (g_HangerInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2) THEN
					g_HangerInletProcess.Common.State := MACHPROC_WAIT_STOP_38;
				ELSE
					g_HangerInletProcess.Common.State := MACHPROC_HOLD_POINT_33;
				END_IF
			END_IF

			// We are at Holdpoint, stop Motor 
		MACHPROC_HOLD_POINT_33:

			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet at hold point');
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
			g_TopConveyorProcess.InfeedBeltMotor := FALSE; // POX 10-03-30
			g_TopConveyorProcess.StopInFeedBelt.State := FOLDIO_STATE_IDLE_0;
			
			g_HangerInletProcess.InletBeltMotor := FALSE;
			g_HangerInletProcess.InFeedBeltRun.State := FOLDIO_STATE_IDLE_0;
			g_HangerInletProcess.InletBeltTC1Start.State := FOLDIO_STATE_IDLE_0;
			g_HangerInletProcess.Common.State := MACHPROC_WAIT_RESTART_35;

			// Wait for Hanger opener to get ready..
		MACHPROC_WAIT_RESTART_35:

			g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; (* start watchdog timer for process *)
			// Make handshake with Hanger opener..
			IF g_HangerInletProcess.Common.Next.TransferStatus = EXC_STANDBY_0 THEN
				g_HangerInletProcess.Common.Next.TransferStatus := EXC_WANT_TO_UNLOAD_1;
			ELSIF g_HangerInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 AND NOT (g_HangerOpenerProcess.HangerInPosition.Output) AND NOT g_CorrectBeltsTurnAround THEN
				g_HangerInletProcess.Common.Next.TransferStatus := EXC_UNLOADING_3;
				g_HangerInletProcess.HangerConveyorOnTimer := g_HangerInletProcess.PulsCounter; 
				g_HangerInletProcess.HangerConveyorMotor := TRUE;
				// Activate the Inlet belt 
//				IF g_HCfg.OverallAlignment THEN
//					g_HangerInletProcess.InletBeltMotor := TRUE; 
//				END_IF	

				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Restart Hold point');
				g_HangerInletProcess.Common.State := MACHPROC_WAIT_STOP_38;
			END_IF
			
		MACHPROC_WAIT_STOP_38:
			// Reset the Trouser alignment output when hanger is about to fall in to deloading unit.
			g_HangerInletProcess.TrouserAlignment := FALSE;
		
			// Hanger has dropped down onto the opener plate. 
			IF g_HangerInletProcess.Common.Next.TransferStatus = EXC_READY_TO_RECIEVE_2 THEN
				g_HangerInletProcess.Common.Next.TransferStatus := EXC_UNLOADING_3; 
				DropDeloaderSpeed_Delay.Set := TRUE;
				g_HangerInletProcess.InletBeltMotor := FALSE;
			ELSIF g_HangerInletProcess.Common.Next.TransferStatus = EXC_RECIVING_4 THEN

				LinenID := LinenID + 1;
				IF LinenID = 0 THEN
					LinenID := LinenID + 1;
				END_IF
				g_HangerInletProcess.Common.Product.ID := LinenID; 

				// Garment type icon
				IF g_HangerInletProcess.GarmentLenght < g_MCfg.Inlet.Hanger.EmptyHangerLength THEN 
					ShirtDetectedHMI := 66; // Empty hanger detected at Hanger inlet...
				ELSIF IsFlapTrouser THEN
					ShirtDetectedHMI := 2; // Shirt icon
				ELSIF (g_HangerInletProcess.Common.Product.ProductType = SHIRT_TYPE_1) OR (g_HangerInletProcess.Common.Product.ProductType = PYJAMAS_TYPE_2) THEN
					ShirtDetectedHMI := 1; // Shirt icon
				ELSE
					ShirtDetectedHMI := 3; // Trouser icon 
				END_IF	

				// MH --> neue Variable definiert: EmpHangLength //
				g_HangerInletProcess.Common.Product.EmpHangLength := g_HangerInletProcess.GarmentLenght;
				g_HangerInletProcess.Common.Next.Product := g_HangerInletProcess.Common.Product;
				g_HangerInletProcess.InFeedBeltRun.State := FOLDIO_STATE_IDLE_0; // Stop here if timer would be to long...
				g_HangerInletProcess.VacuumFlap := FALSE;
				g_HangerInletProcess.InletBeltMotor := FALSE; 
				g_HangerInletProcess.Common.Next.TransferStatus := EXC_FINISHED_UNLOADING_5; //Hanger opener clamps hanger and starts opening...
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet hanger dropped');
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.Common.ExitTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.Common.State := MACHPROC_GARMENT_IN_40;
			END_IF

			// Hanger opener has got the hanger, go back and start feeding next hanger..
		MACHPROC_GARMENT_IN_40:
			IF ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.Common.ExitTimer) >= g_HangerInletProcess.Common.ExitTime THEN
				g_HangerInletProcess.Common.WatchDogRunTimer := g_HangerInletProcess.Common.CurTimer; 
				g_HangerInletProcess.InletBeltMotor := FALSE; 
				LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'H_Inlet Exit');
				g_HangerInletProcess.ReCheckHangerTimer := g_HangerInletProcess.Common.CurTimer; 
				g_HangerInletProcess.Common.State := MACHPROC_RUN_20;
			END_IF

		MACHPROC_ERROR_99:	
			g_HangerInletProcess.Common.Next.TransferStatus := EXC_ERROR_99; // POX Obs..
			TshirtBlastLeft.Set := FALSE;
			TshirtBlastRight.Set := FALSE;
			SleeveBlastLeft.Set := FALSE;
			SleeveBlastRight.Set := FALSE;
			g_HangerInletProcess.isInProgress := FALSE;
			g_HangerInletProcess.StepFeeder.State := FOLDIO_STATE_IDLE_0;
			g_HangerInletProcess.InFeedBeltRun.State := FOLDIO_STATE_IDLE_0;
			g_HangerInletProcess.InletBeltTC1Start.State := FOLDIO_STATE_IDLE_0;
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
			g_HangerSpeed := HANGER_SPEED_NORMAL_0;
			g_HangerInletProcess.TrouserAlignment := FALSE;
			g_HangerInletProcess.InletBeltMotor := FALSE;
			g_HangerInletProcess.VacuumFlap := FALSE;
			g_HangerInletProcess.FlapTrousersPlate := FALSE;

			g_HangerInletProcess.StopFeedingOnCustomerChange := FALSE;
			IF NOT g_HangerInletProcess.EnableFeeding AND (g_MCfg.Outlet.StackChangeMode = OUTLET_STACK_CHANGE_RESET_4) THEN
				g_HangerInletProcess.EnableFeeding := TRUE;
			END_IF				

			// Reset the counter when alarm is triggerd..
			IF HangerNoReadMax > 0 THEN
				HangerNoRead := 0;
			END_IF		
			Step := 0;
			Wait_Sorting := FALSE;
	END_CASE

	HangerConveyorShortRun(Delay := g_MCfg.Inlet.Hanger.ConveyorShortRunTime, CntAdr := ADR(g_HangerInletProcess.PulsCounter));
	HangerConveyorShortRunPause(Set := HangerConveyorShortRun.Trig, Delay := g_MCfg.Inlet.Hanger.ConveyorShortRunPause, CntAdr := ADR(g_MilliSeconds));
	g_HangerInletProcess.HangerConveyorShortRun := HangerConveyorShortRun.Out;
	g_HangerInletProcess.HangerConveyorShortRunPause := HangerConveyorShortRunPause.Out;
	
	(*Flap Trousres Air Blast Timer*)
	IF FlapTrousersAirBlastActive THEN 
		IF NOT g_HangerInletProcess.HangerConveyorMotor AND NOT ( (g_HangerInletProcess.Common.State = MACHPROC_HOLD_POINT_33) OR (g_HangerInletProcess.Common.State = MACHPROC_WAIT_RESTART_35) ) THEN
			// The FlapTrousersAirBlastTimer not always got reset 
			FlapTrousersAirBlastTimer := g_HangerInletProcess.PulsCounter; 
		END_IF
	ELSE
		g_HangerInletProcess.FlapTrousersAir.State := FOLDIO_STATE_IDLE_0;
		FlapTrousersAirBlastTimer := g_HangerInletProcess.PulsCounter; 
	END_IF
	IF ElapsedMsTime(g_HangerInletProcess.PulsCounter, FlapTrousersAirBlastTimer) >= FlapTrousersAirBlastStartDelay THEN
		g_HangerInletProcess.FlapTrousersAir.State := FOLDIO_STATE_START_1;
		FlapTrousersAirBlastTimer := g_HangerInletProcess.PulsCounter; 
	END_IF

	(*##############*)
	(* Run FoldIO's *)
	(*##############*)
	DropDeloaderSpeed_Delay(Delay := g_MCfg.Inlet.Hanger.SpeedToDeloaderDelay, CntAdr := ADR(g_HangerInletProcess_PulsCounter));
	IF DropDeloaderSpeed_Delay.Trig THEN
		g_HangerSpeed := HANGER_SPEED_DELOADER_2;
	END_IF
	
	HangerSpeedInfeedTime_Delay(Delay := g_MCfg.Inlet.SpeedInfeedTime, CntAdr := ADR(g_MilliSeconds));
	IF HangerSpeedInfeedTime_Delay.Trig THEN
		g_HangerSpeed := HANGER_SPEED_NORMAL_0;
	END_IF	

	g_HPulsCounter := g_HangerInletProcess.PulsCounter;
	FBTshirtBlastLeft();
	FBTshirtBlastRight();
	FBSleeveBlastLeft();
	FBSleeveBlastRight();
	
	ActivateFoldIO(g_HangerInletProcess.StepFeeder, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.InFeedBeltRun, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.CheckForShirt, g_HangerInletProcess.PulsCounter);
	ActivateFoldIO(g_HangerInletProcess.OverallCenter, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.InletBeltTC1Start, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.Vacuum, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.DelayInletBelt, g_HangerInletProcess.Common.CurTimer);
	ActivateFoldIO(g_HangerInletProcess.FlapTrousersAir, g_HangerInletProcess.Common.CurTimer);

	//#############################
	// Stop Motor after timeout
	//#############################
	IF g_HangerInletProcess.Common.State >= MACHPROC_RUN_20 THEN // Else will not the start up check work
		IF ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.HangerConveyorOnTimer) >= g_HangerInletProcess.HangerConveyorOnTime THEN
			g_HangerInletProcess.HangerConveyorMotor := FALSE;
		END_IF
	END_IF

	IF EDGEPOS(g_HangerInletProcess.GarmentDetect.Output) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'GarmentDetect ON');
	END_IF
	IF EDGENEG(g_HangerInletProcess.GarmentDetect.Output) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'GarmentDetect OFF');
	END_IF

	IF EDGEPOS(g_HangerInletProcess.ShirtDetect.Output) THEN
		Count[3] := g_HPulsCounter;
		IF CheckForShirtHangerDetected THEN
			Count[4] := g_HPulsCounter;
			CheckForShirtHangerDetected := FALSE;

			g_HangerInletProcess.CheckForShirt.State := FOLDIO_STATE_START_1; 
			TshirtBlastLeft.Count := g_HangerInletProcess.PulsCounter + g_ACfg[ACfgProgram].TShirtBlowDelay[1];
			TshirtBlastLeft.On := g_ACfg[ACfgProgram].TShirtBlowOnTime[1];
			TshirtBlastRight.Count := g_HangerInletProcess.PulsCounter + g_ACfg[ACfgProgram].TShirtBlowDelay[0];
			TshirtBlastRight.On := g_ACfg[ACfgProgram].TShirtBlowOnTime[0];
			SleeveBlastLeft.Count := g_HangerInletProcess.PulsCounter + g_ACfg[ACfgProgram].ArmBlowDelay[1]; 
			SleeveBlastLeft.On := g_ACfg[ACfgProgram].ArmBlowOnTime[1];
			SleeveBlastRight.Count := g_HangerInletProcess.PulsCounter + g_ACfg[ACfgProgram].ArmBlowDelay[0];
			SleeveBlastRight.On := g_ACfg[ACfgProgram].ArmBlowOnTime[0];
	
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'CheckForShirt Delay start, ShirtDetect ON');
		ELSE
			Count[5] := g_HPulsCounter;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'ShirtDetect ON indep.');
		END_IF
	END_IF
	
	IF EDGENEG(g_HangerInletProcess.ShirtDetect.Output) THEN
		Count[6] := g_HPulsCounter;
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'ShirtDetect OFF');
	END_IF
	
	IF EDGEPOS(g_HangerInletProcess.CheckForShirt.Output) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'CheckForShirt ON');
	END_IF
	IF EDGENEG(g_HangerInletProcess.CheckForShirt.Output) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'CheckForShirt OFF');
	END_IF
	
	(*##################################*)
	(* Check if it's a Shirt or Trouser *)
	(*##################################*)
	// If ForceTrouser is set to FORCE_TO_TROUSER_1 then nothing happens but all garment are trouser by default..
	IF g_HangerInletProcess.CheckForShirt.Output AND g_HangerInletProcess.Common.Product.ProductType = TROUSER_TYPE_0 THEN
		
		// Set product type
		IF g_ACfg[ACfgProgram].ForceTrouser = 0 AND g_HangerInletProcess.ShirtDetect.Output OR g_ACfg[ACfgProgram].ForceTrouser = FORCE_TO_SHIRT_2 THEN // Use photocell to detect shirts...
			g_HangerInletProcess.Common.Product.ProductType := SHIRT_TYPE_1;
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Shirt type set');
		ELSIF g_ACfg[ACfgProgram].ForceTrouser = FORCE_TO_PYJAMAS_3 AND g_HangerInletProcess.ShirtDetect.Output THEN // Pajamas must work in a mix with trousers...
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Pyjamas type set');
			g_HangerInletProcess.Common.Product.ProductType := PYJAMAS_TYPE_2;
		END_IF
		
		// Air blast on other than trousers
		IF g_HangerInletProcess.Common.Product.ProductType <> TROUSER_TYPE_0 THEN 
			TshirtBlastLeft.Set := TRUE;
			TshirtBlastRight.Set := TRUE;
			SleeveBlastLeft.Set := TRUE;
			SleeveBlastRight.Set := TRUE;
		END_IF
	END_IF

	// It is a trouser, detection is closed and nothing was detected...
	IF EDGENEG(g_HangerInletProcess.CheckForShirt.Output) AND (g_HangerInletProcess.Common.Product.ProductType = TROUSER_TYPE_0) THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 7, g_HangerInletProcess.Common.LogBookFlag, g_HangerInletProcess.PulsCounter, 'Trouser found');
		// Trouser aligment function
		IF g_ACfg[ACfgProgram].TrouserAlignment THEN
			g_HangerInletProcess.TrouserAlignment := TRUE;
		END_IF	
		IF g_MCfg.Inlet.RunInfeedAll = 0 THEN // 0 = Stop on trousers..
			g_HangerInletProcess.InFeedBeltRun.State := FOLDIO_STATE_IDLE_0; // Stop the Infeed belt if it's a par of trousers.
		END_IF	
	END_IF	 

	(*################################*)
	(* Show no read icon on main page *)
	(*################################*)
	IF g_HangerInletProcess.OutletIsFree.Output THEN 
		g_HangerInletProcess.NoReadStatus := 0; // Hidde icon on main page.
		g_EmptyHangerBlock := FALSE;
	ELSE
		g_HangerInletProcess.NoReadStatus := 2; // Show Outlet blocked icon on main page.
		g_EmptyHangerBlock := TRUE;
	END_IF

	(*############################*)
	(* Measure lenght of garement *)
	(*############################*)

	// Leading Edge 
	IF g_HangerInletProcess.GarmentLenght = 0 THEN
		g_HangerInletProcess.GarmentDetect.EdgeFlank := FALSE;
		g_HangerInletProcess.GarmentDetect.TrailFlank := FALSE;
		IF g_HangerInletProcess.GarmentDetect.EdgeCounter > g_HangerInletProcess.GarmentDetect.OldEdgeCounter THEN
			g_HangerInletProcess.LeadingPoint := g_HangerInletProcess.PulsCounter; 
		END_IF
		g_HangerInletProcess.GarmentDetect.OldEdgeCounter := g_HangerInletProcess.GarmentDetect.EdgeCounter;

		// Trailing Edge 
		IF g_HangerInletProcess.LeadingPoint > 0 THEN
			IF (g_HangerInletProcess.GarmentDetect.TrailCounter > g_HangerInletProcess.GarmentDetect.OldTrailCounter) OR
				(((g_HangerInletProcess.Common.State = MACHPROC_WAIT_STOP_38) OR (g_HangerInletProcess.Common.State = MACHPROC_WAIT_RESTART_35)) > Old_EdgeState) THEN 
				g_HangerInletProcess.GarmentLenght := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.LeadingPoint);
			END_IF
		END_IF		 
		g_HangerInletProcess.GarmentDetect.OldTrailCounter := g_HangerInletProcess.GarmentDetect.TrailCounter;

	ELSIF g_HangerInletProcess.GarmentLenght > 0 THEN
		IF g_HangerInletProcess.GarmentDetect.EdgeCounter > g_HangerInletProcess.GarmentDetect.OldEdgeCounter THEN
			IF ((g_HangerInletProcess.Common.State >= 27) AND (g_HangerInletProcess.Common.State <= 38)) THEN 
				g_HangerInletProcess.GarmentLenght := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.LeadingPoint);
				IF g_HangerInletProcess.GarmentDetect.TrailCounter > g_HangerInletProcess.GarmentDetect.OldTrailCounter THEN
					g_HangerInletProcess.GarmentLenght := ElapsedMsTime(g_HangerInletProcess.PulsCounter, g_HangerInletProcess.LeadingPoint); 
				END_IF
			
			ELSIF (g_HangerInletProcess.Common.State > 38) THEN
				g_HangerInletProcess.GarmentDetect.OldEdgeCounter := g_HangerInletProcess.GarmentDetect.EdgeCounter;
				g_HangerInletProcess.GarmentDetect.OldTrailCounter := g_HangerInletProcess.GarmentDetect.TrailCounter;
			END_IF
		END_IF
	END_IF
	Old_EdgeState := ((g_HangerInletProcess.Common.State = MACHPROC_WAIT_STOP_38) OR (g_HangerInletProcess.Common.State = MACHPROC_WAIT_RESTART_35));

	//#########################################################
	// Hanger Inlet is idle to be used in the machine process..
	//#########################################################
	IF g_HangerInletProcess.Common.State =  MACHPROC_RUN_20 THEN
		IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.IdleTimer) >= g_HangerInletProcess.IdleTime) OR NOT g_HangerInletProcess.EnableFeeding THEN
			g_HangerInletProcess.InletIsIdle := TRUE;
		END_IF
	ELSE
		g_HangerInletProcess.InletIsIdle := FALSE;
		g_HangerInletProcess.IdleTimer := g_HangerInletProcess.Common.CurTimer; 
	END_IF

	//###################################
	// Run Vaccum motor if needed.
	//###################################
	g_HangerInletProcess.VacuumMotor_TOF(IN := g_HangerInletProcess.isInProgress AND g_ACfg[ACfgProgram].VacuumEnabled, PT := UDINT_TO_TIME(g_MCfg.Inlet.Vaccum. DelayOffSec * 1000));
	g_HangerInletProcess.VacuumMotor := g_HangerInletProcess.VacuumMotor_TOF.Q;	

	//##############################################
	// Number of garments before cleaning of Fan..
	//##############################################
	IF g_HangerInletProcess.VacuumMotor THEN
		IF EDGEPOS(g_HangerInletProcess.StepFeeder.Output) THEN
			NumberOfHangersCleaning := NumberOfHangersCleaning + 1;
			// Check when to activate the output for cleaning the fan..
			IF NumberOfHangersCleaning > g_HangerInletProcess.HangerBeforeCleaning THEN
				NumberOfHangersCleaning := 0;
				g_HangerInletProcess.FanCleaningTimer := g_HangerInletProcess.Common.CurTimer;
				g_HangerInletProcess.VacuumCleaning := TRUE;
			END_IF	
		END_IF
	END_IF	

	// Reset cleaning output after a time	
	IF g_HangerInletProcess.VacuumCleaning THEN 
		IF (ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.FanCleaningTimer) >= g_HangerInletProcess.FanCleaningTime) THEN
			g_HangerInletProcess.VacuumCleaning := FALSE;
		END_IF
	END_IF

	// Vacuum flap delay
	IF g_HangerInletProcess.isInProgress AND EDGEPOS(ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.VacuumFlapDelayTimer) > g_ACfg[ACfgProgram].VacuumFlapDelayOn) THEN
		g_HangerInletProcess.VacuumFlap := TRUE;
		VacuumStopDelay.Set := 1;
	END_IF
	VacuumStopDelay(Delay := g_ACfg[ACfgProgram].VacuumFlapDelayOff, CntAdr := ADR(g_HangerInletProcess.Common.CurTimer));
	IF VacuumStopDelay.Trig THEN
		g_HangerInletProcess.VacuumFlap := FALSE;
	END_IF

	//##########################################
	// Set Inlet belt motor after foldio timer
	//##########################################
	IF EDGEPOS(g_HangerInletProcess.DelayInletBelt.Output) THEN
		g_HangerInletProcess.InletBeltMotor := TRUE;
	END_IF	

	InletBeltMotorDelay(Set := g_HangerInletProcess.InletBeltMotor, Delay := g_ACfg[ACfgProgram].DelayStopInlet, CntAdr := ADR(g_MilliSeconds));
	IF EDGEPOS(InletBeltMotorDelay.Out) THEN
		g_HangerInletProcess.InletBeltMotor := FALSE;
	END_IF

	//##################################################
	// Stop Inlet as long as CustomerChange is not reset
	//##################################################
	IF (g_HangerInletProcess.StopFeedingOnCustomerChange) THEN
		g_Machine.StopAttempt := TRUE;
		IF (NOT g_HangerInletProcess.CustomerStackChange) AND (EDGEPOS(g_HangerInletProcess.ResetAfterStackChange)) THEN
			OldCustomer := g_HangerInletProcess.Common.Product.Customer;
			g_HangerInletProcess.CustomerChangeLMP := FALSE;
			g_HangerInletProcess.EnableFeeding := TRUE;
			g_HangerInletProcess.StopFeedingOnCustomerChange := FALSE;
			g_Machine.StopAttempt := FALSE;
			MachineManagerDoIndex := FALSE; 
			g_OutletProcess.DoubleIndex := FALSE;		
		END_IF	
	END_IF

	//###################################
	//Show Icon if StackChange requested
	//###################################
	IF (g_HangerInletProcess.Common.Product.StackChangeIndex <> g_CrossFoldBProcess.StackChangeControl.OldStackChangeIndex) AND (g_HCfg.FeedManual = 0) AND (NOT g_HangerInletProcess.ManualChangeAutoProg) THEN
		g_HangerInletProcess.IndexingIconRuntime := 0; 
	ELSE
		g_HangerInletProcess.IndexingIconRuntime := 1;
	END_IF
	
	CASE Step OF 	
		0:	//Wait for request
			Stacker := 0;
			Length := 0;
	
		1:	//Check if value is correct
			IF g_HangerInletProcess.Common.Product.Customer <> OldCustomer THEN
				OldCustomer := g_HangerInletProcess.Common.Product.Customer;
				Stackchange := 2;
			END_IF
			
			DestinationMetri := g_ExternalCom.Destination;
			DestinationTrimmed := g_ExternalCom.Destination / 100;
			IF NOT g_MCfg.Stacker.LengthSorting THEN
				g_ExternalCom.Destination := g_ExternalCom.Destination MOD 100;
			END_IF
			
			IF g_ExternalCom.Destination < 100 THEN
				IF g_ExternalCom.Destination <= USINT_TO_INT(g_HCfg.NumberOfStackers) THEN
					Length := 0;
					Stacker := g_ExternalCom.Destination;
					Step := 2;
				ELSE				
					g_HangerInletProcess.Common.Product.Stack := 0;
					Batch := 4;
					Step := 3;
				END_IF
			ELSE
				Length := g_ExternalCom.Destination / 100;
				Stacker := g_ExternalCom.Destination MOD 100;
				IF Stacker <= g_HCfg.NumberOfStackers THEN
					Step := 2;
				ELSE
					g_HangerInletProcess.Common.Product.Stack := 0;
					Batch := 4;
					Step := 3;
				END_IF
			END_IF		
		
		2:	//Check for latest length on stacker	
			IF Length_On_Stacker[Stacker] = Length THEN
				g_HangerInletProcess.Common.Product.Stack := Stacker; 
			ELSIF Length_On_Stacker[Stacker] <> Length THEN
				Length_On_Stacker[Stacker] := Length;
				g_HangerInletProcess.Common.Product.Stack := Stacker;
				IF Stackchange = 0 THEN
					Stackchange := 1;
				END_IF
			END_IF		  
			Step := 3;
	
		3:
			IF Batch <> 4 THEN
				IF g_ExternalCom.Destination = 0 THEN
					Batch := 0;
				ELSIF (g_ExternalCom.Destination > 0) AND (g_ExternalCom.Destination < 100) THEN
					Batch := 1;
				ELSIF g_ExternalCom.Destination >= 100 THEN
					Batch := 2;
				END_IF
			END_IF
			IF (Batch <> OldBatch) OR (Batch = 4) THEN
				IF Batch = 4 THEN
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag, Batch, 'H_Inlet Batch = 4');
				ELSE
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag, Batch, 'H_Inlet Batch <> OldBatch');
				END_IF
				Stackchange := 2;
				OldBatch := Batch;
				Step := 4;
			ELSE
				Step := 5;
			END_IF		
		
		4:	//Reset	
			FOR j := 1 TO UINT_TO_INT(g_HCfg.NumberOfStackers) DO
				IF j <> UINT_TO_INT(Stacker) THEN
					Length_On_Stacker[j] := 0;
				END_IF
			END_FOR
			IF Batch = 4 THEN
				Batch := 5;
			END_IF		
			Step := 5;
		
		5:
			IF Stackchange > 0 THEN
				IF Stackchange = 2 THEN 
					LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag, DestinationMetri, 'H_Inlet Pre-Stack change 5');
					g_HangerInletProcess.Common.Product.PreStackChange := TRUE;
				END_IF
				StackChangeIndex := StackChangeIndex + 1;
				g_HangerInletProcess.Common.Product.StackChangeIndex := StackChangeIndex;
				Stackchange := 0;
			END_IF
			Step := 6;
		
		6:
			;
	END_CASE	
	
	IF EDGEPOS(g_HangerBeltRunningLowSpeed) THEN
		Count[1] := g_MilliSeconds;
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag,  g_HangerInletProcess.PulsCounter, ' Infeed slowspeed start');
	END_IF
	IF EDGENEG(g_HangerBeltRunningLowSpeed) THEN
		Count[2] := g_MilliSeconds;
		Count[0] := Count[2] - Count[1];
		itoa(Count[0], ADR(tmpStr));
		strcpy(ADR(LogStr), ADR(tmpStr));
		strcat(ADR(LogStr), ADR(' : Infeed slowspeed end'));
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag,  g_HangerInletProcess.PulsCounter, LogStr);
	END_IF
	
	
	TrouserBlowFunction(); 

	OldMilliseconds := g_MilliSeconds;
	
	//#################
	// Connect Outputs 
	//#################
	QYAirInlet := TrouserBlow.Out;
	QYSeparation := g_HangerInletProcess.StepFeeder.Output OR g_ReleaseHanger;
	QYCHAirTShirtLeft := TshirtBlastLeft.Out;
	QYCHAirTShirtRight := TshirtBlastRight.Out;
	QYAirLeftSleeve := SleeveBlastLeft.Out;
	QYAirRightSleeve := SleeveBlastRight.Out;
	QYTrouserAlignment := g_HangerInletProcess.TrouserAlignment;
	QYOverallCenter := g_HangerInletProcess.OverallCenter.Output;
	QMVacuumInletConveyor := (InletBeltMotorDelay.Out OR g_HangerInletProcess.InletBeltTC1Start.Output) AND NOT g_HangerBeltRunningLowSpeed AND NOT g_HangerInletProcess.HangerConveyorShortRunPause AND g_HangerInletProcess.Common.State < MACHPROC_TRIG_ERROR_98 AND g_Core.System.Runtime.isRunning;
	QYVacuumFlap := g_HangerInletProcess.VacuumFlap;
	QMVacuum := g_HangerInletProcess.VacuumMotor;
	QYVacuumCleaning := g_HangerInletProcess.VacuumCleaning;
	QHStopOnStack := g_HangerInletProcess.CustomerChangeLMP;
	QYAirTrouses := g_HangerInletProcess.FlapTrousersAir.Output;
	QYFlapsLegsAdjustment := g_HangerInletProcess.FlapTrousersPlate;
	QYFlapsLegsDetectionPlate := g_HangerInletProcess.FlapTrousersDetectionPlate; 
	
	// Trace state if Watchdog alarm
	IF EDGEPOS(g_HangerInletProcess.Common.ErrorCode=2) THEN
		CWHState[0] := g_HangerInletProcess.Common.State;
		CWHState[1] := g_HangerInletProcess.Common.OldState;
	END_IF

	IF (g_HangerInletProcess.Common.CurTimer-g_HangerInletProcess.Common.WatchDogRunTimer)>CWHState[2] AND (g_HangerInletProcess.Common.State > 15) AND (g_HangerInletProcess.Common.State < 90) THEN
		CWHState[2] := (g_HangerInletProcess.Common.CurTimer-g_HangerInletProcess.Common.WatchDogRunTimer);
		CWHState[3] := g_HangerInletProcess.Common.State;
		CWHState[4] := g_HangerInletProcess.Common.Next.TransferStatus;
		CWHState[5] := g_HangerInletProcess.Common.Previous.TransferStatus;
	END_IF
	
	IF g_HangerInletProcess.Common.State > MACHPROC_INIT_0 AND g_HangerInletProcess.Common.State < MACHPROC_TRIG_ERROR_98 THEN
		ElapsedTimeCount[1] := ElapsedMsTime(g_HangerInletProcess.Common.CurTimer, g_HangerInletProcess.Common.WatchDogRunTimer);
	END_IF
	

END_ACTION