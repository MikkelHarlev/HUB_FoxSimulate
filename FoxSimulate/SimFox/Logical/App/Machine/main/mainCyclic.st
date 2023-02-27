PROGRAM _INIT

END_PROGRAM

PROGRAM _CYCLIC
	
	// Halt, For Output Test 
	IF g_Halted THEN
		RETURN;
	END_IF


	// Ready To Start 
	g_Core.System.Interface.infos.isReadyToStart := g_Core.System.Runtime.isAppReady AND (NOT g_Core.System.Runtime.isRunning) AND (g_Core.Services.Alarmhandler.Runtime.Event[0].Status = 0) AND NOT (g_Core.System.Interface.alarms.isSafetyInitializing AND g_HCfg.BRSafety);
	
	// In Operation 
	g_Core.System.Interface.infos.isInOperation	:= g_Core.System.Runtime.isRunning AND (NOT g_Core.System.Runtime.isPowerSave);	

	// In Operation (Powersave Mode) 
	g_Core.System.Interface.infos.isInOperationPowerSave := g_Core.System.Runtime.isPowerSave;
	
	g_Core.System.Runtime.isStatisticsRunning := g_Core.System.Runtime.isRunning AND (NOT g_Core.System.Runtime.isPowerSave);
	
	// Inverter Initialising 
	g_Core.System.Interface.infos.isInverterInitializing := g_Inverter.State.Initializing AND NOT g_Core.System.Runtime.isSimulation;
		

	// Acopos initializing
	g_Core.System.Interface.infos.isAcoposInitializing	:= g_Core.Services.AcoposAlarm.Runtime.Initializing AND NOT g_Core.System.Runtime.isSimulation;	
	
	IF g_Core.System.Interface.alarms.isAcoposErrorPowerOff OR g_Core.Services.AcoposAlarm.Runtime.Error THEN
		QKStartOk  := g_Core.System.Runtime.isSimulation;
	END_IF
IF NOT g_Core.System.Interface.alarms.isSafetyInitializing OR NOT g_HCfg.BRSafety THEN
	// Acopos Error (Power Off To Reset)
	g_Core.System.Interface.alarms.isAcoposErrorPowerOff := g_Core.Services.AcoposAlarm.Runtime.PowerOff;
	// Low Air Pressure Warning. 
	g_Core.System.Interface.alarms.isLowAirPressure := NOT g_Core.System.Interface.alarms.isGuardFault AND NOT ISAirOk AND NOT g_Core.System.Interface.alarms.isSafetyPlcError AND NOT g_Core.System.Runtime.isSimulation OR RTest[0];
	// Inverter Error 
	g_Core.System.Interface.alarms.isInterverError := NOT g_Core.System.Runtime.isEStopActivated AND NOT g_Core.System.Interface.alarms.isGuardFault AND NOT g_Inverter.State.Error AND NOT g_Core.System.Runtime.isSimulation;	
		// 
	IF g_EmptyHangerBlock THEN
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[18]	:= TRUE;
	ELSE
		g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[18]	:= FALSE;
	END_IF	
END_IF
	
END_PROGRAM