(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * PROGRAM: Wheelie_Test
 * File: Wheelie_TestCyclic.st
 * Author: pmu
 * Created: May 01, 2013
 ********************************************************************
 * Implementation OF PROGRAM Wheelie_Test
 ********************************************************************)

PROGRAM _CYCLIC

//-------------------------------------------------------
// Wheel Input
//-------------------------------------------------------

	IF IWhC XOR RX_CounterWheel THEN
		WheelCounterTest := WheelCounterTest + 1;
	END_IF
	RX_CounterWheel := IWhC;

	IF IWhDuo XOR rxDuoCounter THEN
		WheelCounterTestDuo := WheelCounterTestDuo + 1;
	END_IF;
	rxDuoCounter := IWhDuo;
	CycleCounter := CycleCounter + 1;

	//-------------------------------------------------------
	// Meassure wheel sensor test
	//-------------------------------------------------------
	IF CycleCounter > TestWheel.StartDelay AND TestWheel.cmdStart THEN
		RMTopConveyor := TRUE;//PWC 23-08-2016
		IF (Tmp >= 0) AND (Tmp <= 9) THEN
			IF TestWheel.Time[Tmp] = 0 THEN
				// Init
				TestWheel.Time[Tmp] := CycleCounter;
				TestWheel.CountStart[Tmp] := g_WheelCounter;
				TestWheel.CountStartTest[Tmp] := WheelCounterTest;
				TestWheel.Count[Tmp] := 0;
			ELSE	
				// Calculation
				TestWheel.Count[Tmp] := g_WheelCounter - TestWheel.CountStart[Tmp];
				TestWheel.CountTest[Tmp] := WheelCounterTest - TestWheel.CountStartTest[Tmp];
				// Next..?
				IF CycleCounter > (TestWheel.Time[Tmp] + 3333) THEN
					TestWheel.Time[Tmp] := 0;
					Tmp := Tmp +1;
				END_IF				
			END_IF
		ELSE
			Tmp := 0;
		END_IF
	ELSE
		RMTopConveyor := FALSE;	//PWC 23-08-2016 
	END_IF

	// Emptying everything
	IF EDGEPOS(TestWheel.cmdStart) THEN
		TestWheel_Empty.cmdStart := 1;
		TestWheel := TestWheel_Empty;
		TestWheel.StartDelay := CycleCounter + 250; // Short delay for motor startup
		Tmp := 0;	
	END_IF

	//PWC 23-08-2016: Activate QMTopConveyor when starting TestWheel counter. This feature requsted by Jan Ingvorsen
	IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 583) AND g_MachineManager[3].Service AND NOT g_Core.System.Runtime.isRunning THEN
		QMTopConveyor := RMTopConveyor;
	END_IF

	//-------------------------------------------------------
	// Duo wheel sensor test
	//-------------------------------------------------------
	IF CycleCounter > DuoWheel.StartDelay AND DuoWheel.cmdStart THEN
		g_DuoInletProcess.testRunInlet := TRUE;
		IF (duoTmp >= 0) AND (duoTmp <= 9) THEN
			IF DuoWheel.Time[duoTmp] = 0 THEN
				// Init
				DuoWheel.Time[duoTmp] := CycleCounter;
				DuoWheel.CountStart[duoTmp] := g_DuoWheelCounter;
				DuoWheel.CountStartTest[duoTmp] := WheelCounterTestDuo;
				DuoWheel.Count[duoTmp] := 0;
			ELSE	
				// Calculation
				DuoWheel.Count[duoTmp] := g_DuoWheelCounter - DuoWheel.CountStart[duoTmp];
				DuoWheel.CountTest[duoTmp] := WheelCounterTestDuo - DuoWheel.CountStartTest[duoTmp];
				// Next..?
				IF CycleCounter > (DuoWheel.Time[duoTmp] + 3333) THEN
					DuoWheel.Time[duoTmp] := 0;
					duoTmp := duoTmp +1;
				END_IF				
			END_IF
		ELSE
			duoTmp := 0;
		END_IF
	ELSE
		g_DuoInletProcess.testRunInlet := FALSE;
	END_IF;

	// Emptying everything
	IF EDGEPOS(DuoWheel.cmdStart) THEN
		TestWheel_Empty.cmdStart := 1;
		DuoWheel := TestWheel_Empty;
		DuoWheel.StartDelay := CycleCounter + 250; // Short delay for motor startup
		duoTmp := 0;	
	END_IF
END_PROGRAM
