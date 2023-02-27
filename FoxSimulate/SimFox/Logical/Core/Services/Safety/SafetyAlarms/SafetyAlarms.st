PROGRAM _INIT		
	delayCyclic := TRUE; 
	g_Core.System.Interface.alarms.isSafetyInitializing := TRUE;
END_PROGRAM

PROGRAM _CYCLIC
	
IF NOT g_HCfg.BRSafety	THEN
	g_Core.System.Interface.alarms.isSafetyInitializing := FALSE;		
	RETURN;		
END_IF
	
	TON_delayCyclic(IN:= delayCyclic, PT := T#50s);

	IF NOT g_Core.System.Runtime.isInitDone OR NOT TON_delayCyclic.Q THEN
		RETURN;
	END_IF
IF safetyIO.isRunning OR TON_delayCyclic.Q THEN
		TON_delayInitDone(IN := TRUE, PT := T#20s);
		IF TON_delayInitDone.Q THEN
			g_Core.System.Interface.alarms.isSafetyInitializing := FALSE;
		END_IF 
	
	// Link To Core
	g_Core.System.Interface.alarms.isExtEStopActive := NOT safetyIO.extEmergencyStatus AND NOT g_Core.System.Runtime.isSimulation;
	g_Core.System.Interface.alarms.isEStopActive := NOT safetyIO.emergencyStatus AND NOT g_Core.System.Runtime.isSimulation;
	g_Core.System.Runtime.isEStopActivated := safetyIO.emergencyStatus AND NOT g_Core.System.Runtime.isSimulation;
	FOR Tmp := 1 TO 21 DO
		g_Core.System.Interface.alarms.isSafetyActive[Tmp] := NOT safetyIO.interlockStatus[Tmp];
	END_FOR
 	g_Core.System.Interface.alarms.isSafetyPressReset := safetyIO.resetButton AND NOT g_Core.System.Runtime.isSimulation;
	g_Core.System.Interface.alarms.isSafetyPlcError	:= NOT safetyIO.isRunning AND NOT g_Core.System.Runtime.isSimulation;
END_IF	
	
	
END_PROGRAM