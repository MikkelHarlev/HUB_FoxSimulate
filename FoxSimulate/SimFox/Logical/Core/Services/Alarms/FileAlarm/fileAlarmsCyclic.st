PROGRAM _INIT
END_PROGRAM

PROGRAM _CYCLIC
	//
	// PUTTING TASK READING HERE, A TASK / SERVICE SHOULD NOT WRITE TO OTHER TASKS "Private data"
	//
	runningCounter 	:= 0;
	runningDone		:= 0;
	FOR i := 0 TO 6 DO
		serviceType := i;
		serviceEnabled := TRUE;
		//
		// Access with pointer to initstate does not work???
		//
		CASE serviceType OF 
			SYSTEM_SERVICE:		initState := g_Core.Services.System.Runtime.initState;
			RECIPE_SERVICE:		initState := g_Core.Services.Recipe.Runtime.initState;
			MACHINE_SERVICE:  	initState := g_Core.Services.Machine.Runtime.initState;
			HARDWARE_SERVICE:	initState := g_Core.Services.Hardware.Runtime.initState;
			CUSTOMER_SERVICE:	initState := g_Core.Services.CAR.Runtime.initState;
								serviceEnabled := g_Core.Services.CAR.Runtime.isEnabled;
			OPERATOR_SERVICE:	initState := g_Core.Services.Operator.Runtime.initState;
								serviceEnabled := g_Core.Services.Operator.Runtime.isEnabled;
			FILEDEVICES_SERVICE:initState := g_Core.Services.FileDevices.Runtime.initState;
			
		END_CASE
		runningCounter := runningCounter + serviceEnabled;
		IF serviceEnabled  THEN
			CASE initState OF
			INIT:
				g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[10+i]	:= TRUE;
				g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Alarm[20+i] 	:= FALSE;
			
			RUNTIME:
				runningDone := runningDone + 1;
				g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_INFOS].Alarm[10+i] 	:= FALSE;
				
			ERROR:
				g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Alarm[20+i] 	:= TRUE;
			END_CASE
		END_IF
	END_FOR
	//
	// Set system to Ready state if all important services are in runtime mode.
	//
	IF EDGEPOS(runningCounter = runningDone) THEN
		g_Core.System.Runtime.isInitDone := TRUE;
	END_IF
	
	//
	// File Error layer handling
	//
	RunFileErrorLayer(ADR(g_Core.Services.Alarmhandler.Interface.FileError));
END_PROGRAM
