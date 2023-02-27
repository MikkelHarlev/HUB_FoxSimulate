PROGRAM _INIT
	OldMilliSeconds := g_MilliSeconds;

	RHangerConveyor_MTR_DelayOff (PT := 0);
	REnableQuickStop := 0; // 1

	REnable := 1;
	SpeedSource := 100;
END_PROGRAM

PROGRAM _CYCLIC
	IF NOT g_Halted THEN
		//------------------------------------------------------------------------
		// Jedk adapt
		//------------------------------------------------------------------------	
		g_TestFunctionActive := 0; 
	
		StartInTrig_TP_10ms(IN := g_Core.System.Runtime.isRunning, PT := 100);
	
		IF StartInTrig THEN
			ISStartMachine := StartInTrig_TP_10ms.Q;
		ELSE
			ISStartMachine := g_Core.System.Runtime.isRunning;
		END_IF
	
		StopInTrig_TP_10ms(IN := NOT g_Core.System.Runtime.isRunning, PT := 100);
	
		SelectedAutoProgram := LIMIT(1, g_AutoProgram.SelectedAutoProgram, 99) - 1; 
		SpeedHzHangerBeltInfeed := g_MCfg.Inlet.Hanger.SpeedHzBeltInfeed;
		IF g_ACfg[SelectedAutoProgram].SpeedSlowHangerBeltDeloader > 0 THEN
			SpeedSlowHangerBeltDeloader := g_ACfg[SelectedAutoProgram].SpeedSlowHangerBeltDeloader;
		ELSE
			SpeedSlowHangerBeltDeloader := g_MCfg.Inlet.Hanger.SpeedSlowHangerBeltDeloader;
		END_IF			
		
		IF g_ACfg[SelectedAutoProgram].SpeedHzHangerBelt > 0 THEN
			SpeedHzHangerBelt := g_ACfg[SelectedAutoProgram].SpeedHzHangerBelt;
		ELSE
			SpeedHzHangerBelt := g_MCfg.Inlet.Hanger.SpeedHzBelt;
		END_IF
		
		g_MCfg.Inlet.Hanger.SpeedHzConveyorShortRun := MAX(50, g_MCfg.Inlet.Hanger.SpeedHzConveyorShortRun);
		SpeedDefault := UINT_TO_REAL(SpeedHzHangerBelt) * localMCfg.SpeedFactor;
		IF g_HangerInletProcess.HangerConveyorShortRun THEN
			RSpeed := UINT_TO_REAL(g_MCfg.Inlet.Hanger.SpeedHzConveyorShortRun) * localMCfg.SpeedFactor;
		ELSIF g_HangerSpeed = HANGER_SPEED_INFEED_1 THEN
			RSpeed := UINT_TO_REAL(SpeedHzHangerBeltInfeed) * localMCfg.SpeedFactor;
		ELSIF g_HangerSpeed = HANGER_SPEED_DELOADER_2 THEN
			RSpeed := UINT_TO_REAL(SpeedSlowHangerBeltDeloader) * localMCfg.SpeedFactor;
		ELSE
			RSpeed := SpeedDefault;
		END_IF
		
		g_HangerBeltRunningLowSpeed := RSpeed < SpeedDefault;
		
		RSpeedWatch := RSpeed;
	
		IF (g_HangerInletProcess.HangerConveyorMotor OR Q_HangerConveyorRun_MTR OR RTestOutFreq) AND REnable AND NOT g_HangerInletProcess.isCollapsedHanger AND NOT g_HangerInletProcess.HangerConveyorShortRunPause THEN
			Speed := REAL_TO_INT(RSpeed);
		ELSE
			Speed := 0;
		END_IF
	
		RHangerConveyor_MTR_DelayOff(IN := (Speed <> 0));
	
		// Inverters
		Cnt := 0;
	
		IF REnableQuickStop THEN
			Start[Cnt] := g_HangerInletProcess.HangerConveyorMotor OR Q_HangerConveyorRun_MTR;
		ELSE
			Start[Cnt] := g_Core.System.Runtime.isRunning OR Q_HangerConveyorRun_MTR;
		END_IF
//		IF g_HangerInletProcess.isCollapsedHanger OR g_HangerInletProcess.HangerConveyorShortRunPause THEN
//			Start[Cnt] := FALSE;
//		END_IF
		
	
		CASE g_Inverter.Drive[Cnt].GetState OF
			0,3: 	(* Drive not Ready *)
				g_Inverter.Drive[Cnt].SetControl := 14;
			2: 	(* Drive Ready *)
				IF Start[Cnt] THEN
					g_Inverter.Drive[Cnt].SetControl := 15;
				END_IF
			4:	(* Drive Running *)
				IF NOT Start[Cnt] THEN
					g_Inverter.Drive[Cnt].SetControl := 14;
				END_IF
		END_CASE
	
		(* Inverter Initialising *)
		g_InverterInit := (g_Inverter.Drive[Cnt].GetState = 0);
	
		IF REnable THEN
			g_Inverter.Drive[Cnt].SetSpeed := Speed; 
		ELSE
			g_Inverter.Drive[Cnt].SetSpeed := 0; 
		END_IF
	
		IF RTestSpeed THEN
			g_Inverter.Drive[Cnt].SetSpeed := TestSpeed;
		END_IF
		
		// Hanger conveyor counter by speed.
		IF g_Inverter.Drive[0].GetSpeed > 0 THEN
			HangerConveyor.CounterMoved := ABS(g_Inverter.Drive[0].GetSpeed) * UDINT_TO_LREAL((g_MilliSeconds - OldMilliSeconds)) * HangerConveyor.InverterFactor + HangerConveyor.CounterMovedRest;
			HangerConveyor.Counter := HangerConveyor.Counter + TRUNC(HangerConveyor.CounterMoved);
			HangerConveyor.CounterMovedRest := HangerConveyor.CounterMoved - TRUNC(HangerConveyor.CounterMoved);
		END_IF
		g_HangerInletProcess.PulsCounter := UDINT_TO_UINT(HangerConveyor.Counter MOD 60000);
		g_HangerInletProcess_PulsCounter := HangerConveyor.Counter;
		
	END_IF
	OldMilliSeconds := g_MilliSeconds;
END_PROGRAM