(********************************************************************
 * COPYRIGHT -- JEDK
 ********************************************************************
 * PROGRAM: HangerSetup
 * File: HangerSetupCyclic.st
 * Author: mha
 * Created: September 26, 2012
 ********************************************************************
 * Implementation OF PROGRAM HangerSetup
 ********************************************************************)

PROGRAM _CYCLIC

	IF NOT g_SystemInitialized THEN
		RETURN;
	END_IF	

	//------------------------------------------------------------------------
	// Hanger lift set-up
	//------------------------------------------------------------------------

	g_HangerSetupOkStart := BOOL_TO_UINT(g_MachineManager[g_HangerOpenerProcess.Common.MachineManagerIndex].Service AND NOT g_Core.System.Runtime.isRunning) AND NOT g_Core.System.Interface.alarms.isAcoposError;
	IF g_HangerSetupOkStart = 0 THEN
		g_HMIHangerSetup := 0;
	END_IF
	
	// HMI control
	IF EDGEPOS(g_HMIHangerSetup > 0) AND NOT g_Core.System.Runtime.isRunning THEN
		Lift.Enable := 1;
	END_IF
	IF EDGENEG(g_HMIHangerSetup > 0) THEN
		Lift.Enable := 0;
	END_IF


	// --------------------------------------------------------------------------------
	// Servo deloading unit test
	// --------------------------------------------------------------------------------
	CASE Lift.State OF
	
		0: // Enable
			g_HangerTestInProgress := FALSE;
			IF g_MasterStep = 100 AND Lift.Enable THEN
				g_HangerTestInProgress := TRUE;
				Lift.IsEnabled := TRUE;
				IF g_Axis[0].state = AXIS_IDLE THEN
					g_Axis[0].move.deceleration := g_MCfg.Deloading.decUp;
					g_Axis[0].move.acceleration := g_MCfg.Deloading.accUp;
					g_Axis[0].move.velocity := g_MCfg.Deloading.speedUp;
					g_Axis[0].move.position := g_MCfg.Deloading.upPos;
					g_Axis[0].state := AXIS_ABS; 
					Lift.State := 10;
				END_IF
			END_IF

		10: // Move up
			IF g_Axis[0].state = AXIS_IDLE THEN
				Lift.State := 20;
			END_IF

		20: // Delay down
			TON_DelayDown(IN := TRUE, PT := T#1s);
			IF TON_DelayDown.Q THEN
				TON_DelayDown(IN := FALSE);		
				Lift.State := 30;
			END_IF
		  
		30: // Delay down
			IF g_Axis[0].state = AXIS_IDLE THEN
				g_Axis[0].move.deceleration := g_MCfg.Deloading.decDw;
				g_Axis[0].move.acceleration := g_MCfg.Deloading.accDw;
				g_Axis[0].move.velocity := g_MCfg.Deloading.speedDw;
				g_Axis[0].move.position := g_MCfg.Deloading.dwPos;
				g_Axis[0].state := AXIS_ABS;
				Lift.State := 40;
			END_IF

		40: // Wait down
			IF g_Axis[0].state = AXIS_IDLE THEN
				g_HangerTestInProgress := FALSE;
				Lift.State := 50;
			END_IF

		50: // Wait down
			TON_DelayDown(IN := TRUE, PT := T#1s);
			IF TON_DelayDown.Q THEN
				TON_DelayDown(IN := FALSE);		
				Lift.State := 0;
			END_IF
		
	END_CASE

	// Free outputs
	IF Lift.IsEnabled THEN
		g_TestFunctionActive := 1;
	END_IF

	IF g_Core.System.Runtime.isRunning THEN
		
		Lift.IsEnabled := 0;
	END_IF

	// Function off
	IF NOT Lift.Enable THEN
		Lift.IsEnabled := 0;
	END_IF

	g_LiftSetupEnabled10ms := Lift.IsEnabled;

	IF RInit THEN
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'HangerSet Cyclic init');
	END_IF

	RInit := 0;
END_PROGRAM
