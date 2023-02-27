PROGRAM _INIT

	pThis ACCESS ADR(g_Core.Services.Alarmhandler);
	
	ready 		:= 0;
	StartOffset := 0;
	GetHistory 	:= TRUE;
	
	// Color definition.
	COLOR_RED_45 	:= 45;
	COLOR_BLACK_0 	:= 0;
	COLOR_WHITE_15 	:= 15;
	COLOR_YELLOW_41 := 41;
	
	MaxAlarmGroup := SIZEOF(pThis.Interface.AlarmGroup)/SIZEOF(pThis.Interface.AlarmGroup[0])-1;
	(* Init Logging - we should move this outside the alarm handler task*)
	(*--------------------------------------------------------------------------------------------------------------------*)
	
	LogInit_0(enable:=1, EntrysLogfile:=10000, sizeLogbuffer:=SIZEOF(LogBuffer), pNameDevice:=ADR('servicelog'),
			pNameFile:=ADR('service_log.csv'), AdrLogbuffer:=ADR(LogBuffer), pNameWriteData:=ADR('AlarmHandl:ServiceLog'),
			pIndexName:=ADR('AlarmHandl:ServiceLog.Index'));
	
	(* Ident to Logbuffer *)
	LogWrite_0.enable := 1;
	LogWrite_0.ident := LogInit_0.ident;
	LogWrite_0.AdrWriteData := ADR( ServiceLog );
	
	FilterControl := 4; 	
	GroupFilter := 2; 		
	
	WarningIconIndex := 0;
	WarningIconBackIndex := 0;
	
	// Initialize alarm headers ;)
	// This went missing?
	
	FOR i := 0 TO ((SIZEOF(Alarm) / SIZEOF(Alarm[0])) -1) DO
		AlarmHeaderColor[i]:= COLOR_RED_45;
		
		Alarm[i].AlarmActiveTop := 1;
		Alarm[i].AlarmActiveFront := 1;
		//Init Alarm colors
		Alarm[i].FrontColor:= COLOR_WHITE_15;
		Alarm[i].HeaderColor:= COLOR_WHITE_15;
		Alarm[i].HeaderTextColor:= COLOR_BLACK_0;
	END_FOR
	
	// Init Main Case
	step := 1;
	
	// Set Priority
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[0]		:= 250;	// Check Alarm 
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[4]		:= 100;	// Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[5]		:= 50;	// Acopos Initializing  
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[7]		:= 50;	// Inverter Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[10]		:= 25;	// System Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[11]		:= 25;	// Recipe Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[12]		:= 25;	// Machine Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[13]		:= 25;	// Hardware Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[14]		:= 25;	// Customer Initializing
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[15]		:= 25;	// Operator Initializing
	
	pThis.Interface.AlarmGroup[CORE_INFOS].Priority[19]		:= 100;	// Operator Initializing
	
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[15]	:= 255;	// Safety Plc Error
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[16]	:= 255;	// Safety Plc Error
	
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[2]		:= 150;	// ThermoFault
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[4]		:= 151;	// Low Airpressure
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[9]		:= 150;	// Inverter Error
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[10]	:= 150;	// Acopos Error
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[11]	:= 150;	// Acopos Error Cleared
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[12]	:= 152;	// Acopos Error (Power Off To Reset)
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[13]	:= 250;	// External Emergency Stop
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[14]	:= 253;	// Safety Plc Error
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[0]		:= 251;	// Emergency Stop
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[1]		:= 252;	// Guard Fault
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[6]		:= 254;	// PLC Halted
	pThis.Interface.AlarmGroup[CORE_ALARMS].Priority[3]		:= 255;	// Fuse Fault
	// avoid warning
	MHATestStr;
	mI;
END_PROGRAM

