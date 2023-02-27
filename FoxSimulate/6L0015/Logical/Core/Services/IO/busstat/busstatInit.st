PROGRAM _INIT
	UpdateIntervall := 100;(* 10 sec if task class = 100 ms *)
	cpu_found := FALSE;
	FirstTime := TRUE;
	SelectedDecade := 0;
	OnlyX20 := TRUE;
	
	(* Reset data array *)
	FOR counter := 0 TO MAX_MODULE_POWERLINK-1 DO
		LocalBus[counter].Index := 0;
		LocalBus[counter].BType := 2;(* Dummy *)
		LocalBus[counter].Status := 0;
		LocalBus[counter].Name := '';
	END_FOR
	FOR counter := 0 TO MAX_MODULE_X2X-1 DO
		X2XBus[counter].Index := 0;
		IF OnlyX20 THEN
			X2XBus[counter].BType := 49;(* Blank X20 *)
		ELSE
			X2XBus[counter].BType := 10;(* Blank X67 *)
		END_IF
		X2XBus[counter].Status := 0;
		X2XBus[counter].Name := '';
	END_FOR
	PageBusStat 		:= LookupPageID(PAGE_X20BUS_STATUS_207,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	PageLocalBusStat 	:= LookupPageID(PAGE_LOCALBUS_STATUS_205,g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
END_PROGRAM

