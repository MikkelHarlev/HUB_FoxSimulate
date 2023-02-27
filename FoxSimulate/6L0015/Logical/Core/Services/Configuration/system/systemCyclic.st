PROGRAM _CYCLIC
	CASE step OF
	
		SYSTEM_WAIT:
			(* Wait for command *)
			IF g_Core.Services.System.Interface.isCmdSave AND g_Core.Services.System.Runtime.isSystemFileValid THEN
				g_Core.Services.System.Interface.isCmdSave := 0;
				SystemFileData:= g_Core.Services.System.Runtime.file;
				step:= SYSTEM_SAVE_FILE;
			ELSIF g_Core.Services.System.Interface.isHmiCmdSave AND g_Core.Services.System.Runtime.isSystemFileValid THEN
				g_Core.Services.System.Interface.isHmiCmdSave := 0;
				SystemFileData:= g_Core.Services.System.Runtime.file;
				step:= SYSTEM_SAVE_FILE;
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
			END_IF
	
		SYSTEM_LOAD_FILE_BACKUP:
			(*Load backup file, change filedevice instead??*)
			CheckForError := TRUE;
			RcpLoad_0.pFileName:= ADR('backup.csv');
			step := SYSTEM_LOAD_FILE;
			
		SYSTEM_LOAD_FILE:
			(* Read default CSV file *)
			RcpLoad_0();
			g_Core.Services.System.Runtime.initState := INIT;
			IF RcpLoad_0.Status <> 0 AND RcpLoad_0.Status <> 65535 THEN
				g_Core.Services.System.Runtime.initState := ERROR;
				step:= SYSTEM_FILE_ERROR;
			ELSIF RcpLoad_0.Status = 0 THEN
				step:= SYSTEM_WAIT;
				IF g_Core.Services.System.Runtime.isSystemFileValid = 0 THEN
					g_Core.Services.System.Runtime.file:= SystemFileData;
					g_Core.Services.System.Runtime.isSystemFileValid := 1;
					g_Core.Services.System.Runtime.initState := RUNTIME;
					IF NOT CheckForError THEN
						step := SYSTEM_SAVE_FILE_BACKUP; (*First good load, make backup*)
					END_IF
				END_IF
				RcpLoad_0.pFileName:= ADR('system.csv'); (*Set original name*)
				CheckForError := FALSE;
			END_IF
	
		SYSTEM_SAVE_FILE_BACKUP:
			(*Save backupfile, different filedevice?*)
			RcpSave_0.pFileName:= ADR('backup.csv');
			step := SYSTEM_SAVE_FILE;
	
		SYSTEM_SAVE_FILE:
			(* Save default data to CSV-file *)
		 	RcpSave_0();
			IF RcpSave_0.Status <> 0 AND RcpSave_0.Status <> 65535 THEN
				step:= SYSTEM_FILE_ERROR;
		 	ELSIF RcpSave_0.Status = 0 THEN
				g_Core.Services.System.Runtime.saveCount := g_Core.Services.System.Runtime.saveCount + 1;
		 		RcpSave_0.pFileName:= ADR('system.csv');		(* Set origial name*)
		 		step:= SYSTEM_WAIT;
		 	END_IF
	
		SYSTEM_CREATE_FILE:
			(* If the file does not exist - create it with default values *)
			(* Use remanent structure if it is valid - else, generate new default data *)
			IF g_Core.Services.System.Runtime.isSystemFileValid = 1 THEN
				SystemFileData := g_Core.Services.System.Runtime.file;
			ELSE
				SystemFileData.Language := 1;
				SystemFileData.Password[0] := 1510174014; (* 123 *)
				SystemFileData.Password[1] := 1879787326; (*	 456 *)
				SystemFileData.Password[2] := 1512664854; (* 789	 *)
				SystemFileData.LastLoadedRecipe := '1.csv';
				SystemFileData.LastMachineFile := 'mcfg1.csv';
				SystemFileData.IPAddressPLC := '172.16.21.3';
				SystemFileData.IPDefaultGatewayPLC := '172.16.200.1';
				SystemFileData.Port := 81;
				SystemFileData.IconsEnabled := 1;	
				SystemFileData.TimezoneID := 0;	
				g_Core.Services.System.Runtime.file := SystemFileData;
				g_Core.Services.System.Runtime.isSystemFileValid := 1;
				hitAnError := TRUE;
			END_IF
	
			step:= SYSTEM_SAVE_FILE;
	
		LOAD_SYSTEM_FILE_ERROR:
			(*Delete old file, fix filesystem*)
			CASE LoadErrorStep OF
				0:
					FileDelete_0(enable:=1, pDevice:=ADR('system'), pName:=ADR('system.csv'));
					LoadErrorStep := 1;
				1:
					IF FileDelete_0.status = 65535 THEN
						FileDelete_0();
					ELSE
						IF FileDelete_0.status = 20708 THEN
							LoadErrorStep := 2;
						ELSIF FileDelete_0.status = 20718 THEN
							// FileIO Error missing disk???
							step := SYSTEM_WAIT; // be nice and wait!						
						ELSE
							;//SYSreset(1,1); (*reboot system free filehandlers*)
						END_IF
					END_IF
				2:
					LoadErrorStep := 0;
					IF CheckForError THEN
						step := SYSTEM_FILE_ERROR;
					ELSE
						step := SYSTEM_LOAD_FILE_BACKUP;
					END_IF
			END_CASE
	
		SYSTEM_FILE_ERROR:
			(* If file does not exist *)
			IF RcpInfo.Status = 20708 OR g_Core.Services.System.Runtime.isSystemFileValid = 0 THEN
				step:= SYSTEM_CREATE_FILE;
			END_IF
	
	END_CASE
	LockIcons := g_Core.System.Configuration.isBlockIcons;
	
END_PROGRAM

