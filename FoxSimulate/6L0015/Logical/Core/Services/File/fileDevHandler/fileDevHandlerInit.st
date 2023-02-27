	PROGRAM _INIT
	IF DiagCpuIsSimulated() THEN
		brdkStrCpy(ADR(masterDeviceAddress),ADR('/DEVICE=C:\\'));
		IF (brdkStrLen(ADR(g_SimulationFolder)) > 0) AND (brdkStrLen(ADR(g_SimulationFolder)) < 8) THEN
			brdkStrCat(ADR(masterDeviceAddress),ADR(g_SimulationFolder));
		ELSE
			brdkStrCat(ADR(masterDeviceAddress),ADR('plc0484'));// Default Folder if no special folder is config
		END_IF
	ELSE
		brdkStrCpy(ADR(masterDeviceAddress),ADR('/DEVICE=F:\\'));
	END_IF

	// ALL
	arrFileDevices[0].fileDeviceName 	:= 'all';
	arrFileDevices[0].folderName	 	:= '\\';
	// rcfg
	arrFileDevices[1].fileDeviceName 	:= 'rcfg';
	arrFileDevices[1].folderName	 	:= '\\Jensen\\rcfg';
	// hcfg
	arrFileDevices[2].fileDeviceName 	:= 'hcfg';
	arrFileDevices[2].folderName	 	:= '\\Jensen\\hcfg';
	// mcfg
	arrFileDevices[3].fileDeviceName 	:= 'mcfg';
	arrFileDevices[3].folderName	 	:= '\\Jensen\\mcfg';
	// cfgpar
	arrFileDevices[4].fileDeviceName 	:= 'cfgpar';
	arrFileDevices[4].folderName	 	:= '\\Jensen\\cfgpar';
	// system
	arrFileDevices[5].fileDeviceName 	:= 'system';
	arrFileDevices[5].folderName	 	:= '\\Jensen\system';
	// custart
	arrFileDevices[6].fileDeviceName 	:= 'custart';
	arrFileDevices[6].folderName	 	:= '\\custart';
	// operator
	arrFileDevices[7].fileDeviceName 	:= 'operator';
	arrFileDevices[7].folderName	 	:= '\\operator';
	// log
	arrFileDevices[8].fileDeviceName 	:= 'log';
	arrFileDevices[8].folderName	 	:= '\\log\log';
	// service
	arrFileDevices[9].fileDeviceName 	:= 'servicelog';
	arrFileDevices[9].folderName	 	:= '\\log\\service';
	// cockpit
	arrFileDevices[10].fileDeviceName 	:= 'cockpitlog';
	arrFileDevices[10].folderName	 	:= '\\log\\cockpit';
	// statistics
	arrFileDevices[11].fileDeviceName 	:= 'statistics';
	arrFileDevices[11].folderName	 	:= '\\statistics';
	// autoprog
	arrFileDevices[12].fileDeviceName 	:= 'acfg';
	arrFileDevices[12].folderName	 	:= '\\Jensen\\acfg';	
	// SAFETY
	arrFileDevices[13].fileDeviceName 	:= 'SAFETY';
	arrFileDevices[13].folderName	 	:= '\\Safety';
	// Trace log
	arrFileDevices[14].fileDeviceName 	:= 'trace2file';
	arrFileDevices[14].folderName	 	:= '\\log\trace';
	// IoT
	arrFileDevices[15].fileDeviceName 	:= 'IOT';
	arrFileDevices[15].folderName	 	:= '\\IOT';
	
	FOR i := 0 TO (SIZEOF(arrFileDevices) / SIZEOF(arrFileDevices[0])) - 1 DO
		// generate full path
		IF (strlen(ADR(arrFileDevices[i].fileDeviceName)) > 0 AND strlen(ADR(arrFileDevices[i].folderName)) > 0) THEN
			strcpy(ADR(strPath),ADR(masterDeviceAddress));
			strcat(ADR(strPath),ADR(arrFileDevices[i].folderName));
			// Link filedevice.
			DevLink_0(enable := 1, pDevice := ADR(arrFileDevices[i].fileDeviceName), pParam := ADR(strPath));
			WHILE (DevLink_0.status <> 0) DO
				DevLink_0();
				IF DevLink_0.status <> 65535 THEN
					// HANDLE ERROR HERE!
					EXIT;
				END_IF
			END_WHILE
			IF DevLink_0.status = 0 THEN
				devicesLinked := devicesLinked + 1;
				arrFileDevices[i].initState := RUNTIME;
			ELSE
				errorCount := errorCount + 1;
				arrFileDevices[i].initState := ERROR;
				g_Core.Services.FileDevices.Runtime.initState := ERROR;
			END_IF
		END_IF
	END_FOR
	IF g_Core.Services.FileDevices.Runtime.initState <> ERROR THEN
		g_Core.Services.FileDevices.Runtime.initState := RUNTIME;
	END_IF
//	// Get task ident.
//	ST_ident(ADR('fileDevHan'),0,ADR(taskIdent));
//	// Stop task
//	ST_tmp_suspend(taskIdent);

END_PROGRAM

