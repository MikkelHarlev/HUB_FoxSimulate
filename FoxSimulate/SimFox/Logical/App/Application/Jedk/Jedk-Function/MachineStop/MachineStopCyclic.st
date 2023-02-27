(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * PROGRAM: MachineStop
 * File: MachineStopCyclic.st
 * Author: mha
 * Created: September 24, 2012
 ********************************************************************
 * Implementation OF PROGRAM MachineStop
 ********************************************************************)

PROGRAM _CYCLIC

	IF NOT g_SystemInitialized THEN
		RETURN;
	END_IF	

	MachineStopTrig  := EDGENEG(g_Core.System.Runtime.isRunning);

	//------------------------------------------------------------------------
	// Soft stop
	//------------------------------------------------------------------------
	QKStartOk := NOT (g_Inverter.State.Error OR g_Inverter.State.Initializing) AND ISThermoOk AND NOT g_StopMachine AND (g_HMIHangerSetup = 0);  //23-11-2018 PWC: Added ISThermoOk, so machine is stopped and can't be started, whenever there's a protective switch fault.

	// Shut down complete
	MachineStop_TP(IN := g_SoftStopDone OR g_SoftStopMaxTime, PT := T#1s );
	IF MachineStop_TP.Q THEN
		QKStartOk := 0;
	END_IF
	g_SoftStopDone := 0;

	//------------------------------------------------------------------------
	// Service enabled?
	//------------------------------------------------------------------------
	RAnyService := 0;
	FOR i := 1 TO 15 DO
		RServiceEnable[i] := g_MachineManager[i].Service;
		IF RServiceEnable[i] THEN
			RAnyService := 1;
		END_IF
	END_FOR

	//------------------------------------------------------------------------
	// Control outputs
	//------------------------------------------------------------------------
	IF NOT g_Core.System.Runtime.isRunning AND NOT g_TestFunctionActive THEN
		QMDeloadingUp := 0;
		QMDeloadingDown:= 0;
	END_IF

	IF NOT g_Core.System.Runtime.isRunning AND NOT RAnyService AND NOT g_TestFunctionActive THEN
		QHBuzz;
		QYHangerClampTop := 0;
		QYHangerClampBelow := 0;
		QYHangerOpener := 0;
		QYXBFoldDoffer := 0;
		QYHoldDownPlate := 0;
		QMXAFold2 := 0;
		QMXBFoldReverse := 0;
		QMXBFoldForward := 0;
		QMStacker[1] := 0;
		QMStacker[2] := 0;
		QMStacker[3] := 0;
		QMStacker[4] := 0;
		QMStacker[5] := 0;
		QMStacker[1] := 0;
		QMStacker[2] := 0;
		QMStacker[3] := 0;
		QMStacker[4] := 0;
		QMStacker[5] := 0;
		QMLiftOutlet[1] := 0;
		QMLiftOutlet[2] := 0;
		QMLiftOutlet[3] := 0;
		QMLiftOutlet[4] := 0;
		QMLiftOutlet[5] := 0;
		QYRollOffOut[1] := 0;
		QYRollOffOut[2] := 0;
		QYRollOffOut[3] := 0;
		QYRollOffOut[4] := 0;
		QYRollOffOut[5] := 0;
		QYStackerAir[1] := 0;
		QMTopConveyor := 0;
		QMInfeedBelt := 0;
		QMXAFoldForward := 0;
		QYLFoldBladeLeft := 0;
		QYLFoldBladeRight := 0;
		QYAirRightSleeve := 0;
		QMXAFoldReverse := 0;
		QYAirXBFoldOutlet := 0;
		QYAirXAFold := 0;
		QYAirXBFoldInlet := 0;
		QYPreStop := 0;
		QYAirLeftSleeve := 0;
		QMInlet := 0;
		QMVacuum := 0;
		QMLFold[1] := 0;
		QMLFold[2] := 0;
		QMInletDuo := 0;
		QYVacuumCleaning := 0;
		QYVacuumFlap := 0;
		QMVacuumInletConveyor := 0;
	END_IF

	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'MachineStop Cyclic init');
	END_IF

	RInit := 0;
END_PROGRAM
