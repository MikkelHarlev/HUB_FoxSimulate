(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * PROGRAM: Jedkadapt
 * File: JedkadaptCyclic.st
 * Author: mha
 * Created: July 20, 2012
 ********************************************************************
 * Implementation OF PROGRAM Jedkadapt
 ********************************************************************)

PROGRAM _CYCLIC

	IF NOT g_SystemInitialized THEN
		RETURN;
	END_IF	


	//------------------------------------------------------------------------
	MachineStartTrig := EDGEPOS(g_Core.System.Runtime.isRunning);
	MachineStopTrig  := EDGENEG(g_Core.System.Runtime.isRunning);
	//------------------------------------------------------------------------

	// Release hanger at inlet.
	IF g_HMIReleaseHanger > 0 THEN
		g_HMIReleaseHanger := 0;
		IF (g_HangerInletProcess.Common.State <= MACHPROC_RUN_20 OR g_HangerInletProcess.Common.State = MACHPROC_ERROR_99) AND NOT QMVacuumInletConveyor OR NOT g_Core.System.Runtime.isRunning THEN
			ReleaseHanger_Delay.Set := 1;
		END_IF
	END_IF
	ReleaseHanger_Delay(Delay := g_HangerInletProcess.StepFeeder.OnTime, CntAdr := ADR(g_MilliSeconds));
	g_ReleaseHanger := ReleaseHanger_Delay.Out;

	IF g_ResetHangerCount AND NOT EDGEPOS(g_ResetHangerCount) THEN
		g_ResetHangerCount := 0;
	END_IF

	//------------------------------------------------------------------------
	// Brakes
	//------------------------------------------------------------------------
	QYBrakeLFold := NOT QMLFold[1] AND g_Core.System.Runtime.isRunning;
	QYBrakeXAFold := NOT (QMXAFoldForward OR QMXAFoldReverse) AND g_Core.System.Runtime.isRunning;

	//------------------------------------------------------------------------
	// Left/Right adapt
	//------------------------------------------------------------------------
	//QYBladeLeft := QYLFoldBladeLeft;
	//QYBladeRight := QYLFoldBladeRight;

	IF EDGEPOS(QYLFoldBladeRight) THEN
		BladeLeftOn := 0;
	END_IF

	IF QYLFoldBladeRight THEN
		BladeLeftOn := BladeLeftOn + g_MilliSeconds - OldMilliSeconds;
	END_IF

	IF EDGEPOS(QYLFoldBladeLeft) THEN
		BladeRightOn := 0;
	END_IF
	IF QYLFoldBladeLeft THEN
		BladeRightOn := BladeRightOn + g_MilliSeconds - OldMilliSeconds;
	END_IF

	//------------------------------------------------------------------------
	// Empty hanger detect
	//------------------------------------------------------------------------

	IF g_MCfg.Inlet.Hanger.EmptyHangerLength = 0 THEN
		g_MCfg.Inlet.Hanger.EmptyHangerLength := g_MCfg.Inlet.Hanger.EmptyHangerLength;
	END_IF

	BGarmentDetection( In := IBGarmentDetection);
	HangerTimeout( PT := T#1s500ms );

	LinenDetect.Start := g_HangerInletProcess.HangerConveyorMotor;
	CASE LinenDetect.State OF
	
		0: // Start
			IF LinenDetect.Start THEN
				LinenDetect := EmptyLinenDetect;
				g_EmptyHanger := 0;
				HangerTimeout.IN := 1;
				LinenDetect.State := 10;
			END_IF
		
		10: // Wait for hanger
			IF BGarmentDetection.Out THEN
				LinenDetect.HangerCountstamp := g_MilliSeconds;
				LinenDetect.CheckPoint := LinenDetect.HangerCountstamp + g_MCfg.Inlet.Hanger.EmptyHangerLength * 10 + 100;
				LinenDetect.State := 20;
			ELSIF HangerTimeout.Q THEN
				LinenDetect.HangerTimeout := 1;
				LinenDetect.State := 100;
			END_IF

		20: // Checkpoint for Empty hanger  
			IF g_MilliSeconds > LinenDetect.CheckPoint THEN
				g_EmptyHanger := NOT BGarmentDetection.Out;
				LinenDetect.State := 100;
			END_IF		
		
		100: // The end
			IF NOT LinenDetect.Start THEN
				LinenDetect.State := 0;
			END_IF  			
	END_CASE
	//------------------------------------------------------------------------
	//------------------------------------------------------------------------

	// Flot!
	IF g_MachineManagerJedk[g_DeliveryProcess.Common.MachineManagerIndex].ResetAlarm THEN
		g_DeliveryProcess.Common.AlarmList.Alarm[DELIVERY_FAIL_CODE_BELTLENGTH_5] := 0;
		g_MachineManagerJedk[g_DeliveryProcess.Common.MachineManagerIndex].ResetAlarm := 0;
	END_IF

	//------------------------------------------------------------------------
	// XBFold photocell improvement
	//------------------------------------------------------------------------

	// Photocell active only when XA starts
	IF EDGEPOS(QYAirXAFold) OR EDGEPOS(QYXAFoldKnife) THEN
		RXStart := 1;
	END_IF

	// Disable photocell after leading edge
	BXBFold_Filter(In := (IBXBFold AND RXStart), Filter := g_MCfg.SensorFilterTime+10);	

	IBXBFoldEdge := BXBFold_Filter.Out;

	IF EDGENEG(BXBFold_Filter.Out) THEN
		RXStart := 0;
	END_IF

	//------------------------------------------------------------------------
	// Delay garment-press
	//------------------------------------------------------------------------
	GarmentPress_TON (IN := QYHoldDownPlate, PT := GarmentPressDelay10ms);
	QDelay_GarmentPress_VLV := GarmentPress_TON.Q;

	//------------------------------------------------------------------------
	// Ensure clamp-lock is in position 
	//------------------------------------------------------------------------

	IF MachineStartTrig THEN
		RStartClampInit := 1;
	END_IF

	CASE StartupClampState OF
	
		0:
			RClampStartSequenceOn := 0;
			IF RStartClampInit THEN
				RClampStartSequenceOn := 1;
				RStartClampInit := 0;
				StartupClampState := 10;
			END_IF
		
		10: // Clamp down and release lock
			RClampDown := 1;
			RClampLock := 0;
			LockDelay.IN := 1;
			StartupClampState := 20;
		
		20: // Lock in position
			IF LockDelay.Q THEN
				LockDelay.IN := 0;
				RClampLock := 1;
				StartupClampState := 30;
			END_IF
		
		30: // Reset
			IF NOT LockDelay.Q THEN
				RClampDown := 0;
				StartupClampState := 0;
			END_IF			

	END_CASE
	LockDelay( PT := 20 );
	IF RClampStartSequenceOn THEN
		QYHangerClampDown := RClampDown;
		QYHangerClampLock := RClampLock;
	END_IF

	//------------------------------------------------------------------------
	// Show the stack change from Metricon
	//------------------------------------------------------------------------
	IF g_ExternalCom.StackChange <> OldStackChange THEN
		ShowStackChange_TOF.IN := 1;
	END_IF
	OldStackChange := g_ExternalCom.StackChange;
	
	ShowStackChange_TOF( PT := T#2s );
	ShowStackChange_TOF.IN := 0;
	IF ShowStackChange_TOF.Q THEN
		g_HideStackChange := 0;
	ELSE
		g_HideStackChange := 1;
	END_IF

	//------------------------------------------------------------------------------------------------------------
	// Extra statistic
	//------------------------------------------------------------------------------------------------------------

	TON_TestStatCount(IN := TestStatCount, PT := T#3s);

	IF TestStatCount THEN
		IF TON_TestStatCount.Q THEN
			TON_TestStatCount(IN := FALSE);
			TestThis := TRUE;
		END_IF
	END_IF	

	// Stacker 
	IF g_PieceCount[0] <> OldPieceCount OR TestThis THEN
		TestThis := FALSE;
		OldPieceCount := g_PieceCount[0];
		IF g_MilliSeconds > StackCountStamp[0] + 10000 THEN
			FOR i := 0 TO MAX_AVERAGE_COUNT - 1 DO
				StackCountStamp[i] := 0;
			END_FOR	
			PerHour := 0;
			Regs := 1;
		ELSE	
			FOR i := MAX_AVERAGE_COUNT - 2 TO 0 BY -1 DO
				StackCountStamp[i+1] := StackCountStamp[i]; 
			END_FOR	
			IF Regs < MAX_AVERAGE_COUNT THEN
				Regs := Regs + 1;
			END_IF
		END_IF
		StackCountStamp[0] := g_MilliSeconds;
	
		IF Regs > 1 THEN
			AverageTimeBetweenMs := UDINT_TO_REAL((StackCountStamp[0] - StackCountStamp[Regs-1]) / (Regs - 1));
			IF AverageTimeBetweenMs > 0 THEN
				PerHour := 3600000 / AverageTimeBetweenMs;
			END_IF
		END_IF
	END_IF

	IF g_ResetAverage > 0 THEN
		g_ResetAverage := 0;
		FOR i := 0 TO MAX_AVERAGE_COUNT - 1 DO
			StackCountStamp[i] := 0;
		END_FOR	
		PerHour := 0;
		Regs := 0;
	END_IF

	g_StackingPerHour := PerHour;
	g_NumberOfPiecesPerAverage := Regs;
	
	//------------------------------------------------------------------------------------------------------------
	// Bispebjerg counters
	//------------------------------------------------------------------------------------------------------------

	IF g_PieceCount[0] <> OldPieceCountB OR TestCount THEN
		OldPieceCountB := g_PieceCount[0];
		TestCount := FALSE;
		KPieceCounter_TOF.IN := TRUE;
	END_IF
	KPieceCounter_TOF(PT := T#500ms);
	QKPieceCounter := KPieceCounter_TOF.Q;
	KPieceCounter_TOF.IN := FALSE;

	// Control counter. 
	//							Edgepos();
	IF QKPieceCounter AND NOT TestCountStacker[10] THEN
		g_PieceCount[10] := g_PieceCount[10] + 1;
	END_IF
	TestCountStacker[10] := QKPieceCounter;
	g_PieceCount[9] := g_PieceCount[1] + g_PieceCount[2] + g_PieceCount[3] + g_PieceCount[4];
		
	FOR i := 1 TO UINT_TO_INT(NUMBER_OF_STACKERS) DO
		IF g_PieceCount[i] <> OldPieceCountStacker[i] OR TestCountStacker[i] THEN
			OldPieceCountStacker[i] := g_PieceCount[i];
			TestCountStacker[i] := FALSE;
			KStackCounter_TOF[i].IN := TRUE;
		END_IF
		KStackCounter_TOF[i](PT := T#500ms);
		QKStackCounter[i] := KStackCounter_TOF[i].Q;
		KStackCounter_TOF[i].IN := FALSE;
	END_FOR
	
	IF g_JamAlarm AND HangerPassedOutCount >= 3 THEN
		HangerPassedOutCount := 0;
		KJamCounter_TOF.IN := TRUE;
	END_IF
	KJamCounter_TOF(PT := T#500ms);
	KJamCounter_TOF.IN := FALSE;
	
	IF EDGEPOS(g_HangerOpenerProcess.HangerPassedOut) THEN
		HangerPassedOutCount := HangerPassedOutCount + 1;
	END_IF

	QKJamCounter := KJamCounter_TOF.Q;
	
	QKHangerAtInlet;
	QKMachineStopped;

	//------------------------------------------------------------------------------------------------------------
	// Light tower
	//------------------------------------------------------------------------------------------------------------
	
	QHGreen := g_Core.System.Runtime.isRunning;
	QHRed := g_JamAlarm;
	QHYellow := NOT g_Core.System.Runtime.isRunning AND NOT QHRed;

	QHBuzzer := QHBuzz; // QHRed AND NOT (g_HMISilenceBuzzer > 0);

	g_Machine.ErrorInProcess;
	
	//------------------------------------------------------------------------------------------------------------
	// Reset any forced outputs at emergency stop
	//------------------------------------------------------------------------------------------------------------
	IF NOT ISEmergencyOk OR NOT ISGuardOk THEN
		g_Core.Services.IO.Interface.isHaltPlc := FALSE;
	END_IF
	
	//------------------------------------------------------------------------------------------------------------
	// Tests
	//------------------------------------------------------------------------------------------------------------
	IF TestLogEntry THEN
		TestLogEntry := FALSE;
		LogEntry(TRUE, ADR(T2FD), 3, g_HangerInletProcess.Common.LogBookFlag, g_DummyPulses, 'Test log 1');
	END_IF
	
	
	//------------------------------------------------------------------------------------------------------------
	// ALARM BUZZER
	//------------------------------------------------------------------------------------------------------------
	setBuzz := 0;
	FOR i := 0 TO 19 DO
		IF g_Core.System.Runtime.isRunning AND g_ProcessAlarm OR g_MainAlarms.Alarm[i] AND (i <> 2) OR g_WaitingLiftAlarm THEN
			setBuzz := 1;
		END_IF
	END_FOR
	FOR i := 0 TO 25 DO
		IF g_Core.System.Runtime.isRunning AND g_OutletProcess.Common.AlarmList.Alarm[i] THEN
			setBuzz := 1;
		END_IF
	END_FOR	

	QHJam := setBuzz;
	g_JamAlarm := setBuzz;

	BuzzerLong( Set := EDGEPOS(setBuzz));
	BuzzerShort( Set := EDGENEG(BuzzerShort.Out) OR BuzzerLong.Out OR NOT setBuzz);
	QHBuzz := BuzzerLong.Out OR BuzzerShort.Out OR (g_Trim > 0);

	ElapsedMs := UDINT_TO_UINT(g_MilliSeconds - OldMilliSeconds);
	IF g_Trim > ElapsedMs THEN
		g_Trim := g_Trim - ElapsedMs;
	ELSE
		g_Trim := 0;
	END_IF
	
	OldMilliSeconds := g_MilliSeconds;

END_PROGRAM
