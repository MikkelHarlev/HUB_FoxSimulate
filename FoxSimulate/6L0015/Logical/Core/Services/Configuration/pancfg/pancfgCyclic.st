PROGRAM _CYCLIC
	IF g_Core.Services.System.Runtime.isSystemFileValid THEN
		
		IF TempLanguageChange = 1 THEN
			CallPageControllerLink(15, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler); // Language/Time settings page
			TempLanguageChange := 0;
		END_IF
		// Init 
		IF EDGEPOS(g_Core.Services.System.Runtime.isSystemFileValid) THEN
			g_Core.System.Interface.setLanguage := g_Core.System.Runtime.Language := g_Core.Services.System.Runtime.file.Language;
			OldIcons 							:= g_Core.Services.System.Runtime.file.IconsEnabled;
			Init 								:= 1;
		END_IF;
		
		// Disabled since X20CP0484 doesn't have a battery but FRAM instead
//		// Battery info for main panel 
//		HwGetBatteryInfo_0(enable := 1, pDevice := ADR('SL0.SS0.HW'), ordinal := 2);
//		IF HwGetBatteryInfo_0.status = 0 THEN
//			Sysinfo.BatteryState 						:= HwGetBatteryInfo_0.state;
//			g_Core.System.Interface.alarms.isBatteryLow := (Sysinfo.BatteryState <> ASHW_BATTERY_OK);
//		END_IF
	
		// Memory info for main panel 
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageInfo) THEN
			TimerUpdate_TON(IN:=NOT TimerUpdate_TON.Q, PT:=T#1S);
			IF TimerUpdate_TON.Q THEN
				MEMInfo_0(enable := 1);
				IF MEMInfo_0.status = 0 THEN
					Sysinfo.SRAM 	:= MEMInfo_0.FreeUSR_Ram;
					Sysinfo.DRAM 	:= MEMInfo_0.FreeTMP_Ram;
					Sysinfo.HD 		:= MEMInfo_0.FreeUSR_Prom;
				END_IF
			END_IF;
			// CPU Info for main panel
			
		END_IF;
	
		// Save language and Icon status
		IF (g_Core.System.Runtime.Language <> g_Core.System.Interface.setLanguage) OR (g_Core.Services.System.Runtime.file.IconsEnabled <> OldIcons) THEN
			IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageSystem THEN
				g_Core.System.Runtime.Language 					:= g_Core.System.Interface.setLanguage;
				g_Core.Services.System.Runtime.file.Language 	:= UINT_TO_USINT(g_Core.System.Runtime.Language);
				OldIcons 										:= g_Core.Services.System.Runtime.file.IconsEnabled;
				g_Core.Services.System.Interface.isCmdSave 		:= TRUE;
			ELSE
				g_Core.System.Runtime.Language 					:= g_Core.System.Interface.setLanguage;
			END_IF;
		END_IF;
		//g_UserLanguage := Pancfg_0.Language;
		
	
		////////////////////////////////////////////////////////////
		//
		// Updating the MachineInfo.dat
		//
		////////////////////////////////////////////////////////////	
		
		//Read MachineInfo.dat
		CASE ReadMachineInfoDataObject OF
		1:
			OpenMachineInfoDataObject := 1;
			ReadMachineInfoDataObject := 2;
		2:
			IF (OpenMachineInfoDataObject = 0 AND (MachineInfoDataObjectIdent > 0)) THEN
				ReadMachineInfoDataObject := 3;
			END_IF
		3:
			InfoFileRead_0(enable:=1, ident:=MachineInfoDataObjectIdent, offset:=0, pDest:=ADR(MachineInfoByte), len:=SIZEOF(MachineInfoByte));
			ReadMachineInfoDataObject := 4;
		4:
			CASE InfoFileRead_0.status OF
				0:
					ReadMachineInfoDataObject := 0; (*All ok*)
				65535:
					InfoFileRead_0(); (*Call fub again*)
			END_CASE
		END_CASE
		
		
		// Open MachineInfo.dat, Creating the file if it does not exist.
		CASE OpenMachineInfoDataObject OF
		1:
			InfoFileOpen_0(enable:=1, pDevice:=ADR(fDevice), pFile:=ADR('MachineInfo.dat'), mode:=fiREAD_WRITE);
			OpenMachineInfoDataObject := 2;
		2:
			CASE InfoFileOpen_0.status OF
				0: (*File opened*)
					MachineInfoDataObjectIdent := InfoFileOpen_0.ident;
					OpenMachineInfoDataObject := 0;
				65535: (*Call fub again*)
					InfoFileOpen_0();
				20708:
					OpenMachineInfoDataObject := 0;
					CreateMachineInfoDataObject := 1;
					OpenMachineInfoDataObject := 3;
			END_CASE
		3:
			IF (CreateMachineInfoDataObject = 0) THEN
				OpenMachineInfoDataObject := 1;
			END_IF
		END_CASE
		
		
		// Creating MachineInfo.dat, because it does not exist.
		CASE CreateMachineInfoDataObject OF
		1:
			InfoFileCreate_0(enable:=1, pDevice := ADR(fDevice), pFile:=ADR('MachineInfo.dat'));
			CreateMachineInfoDataObject := 2;
		2:
			CASE InfoFileCreate_0.status OF
				0: (*All ok*)
					CreateMachineInfoDataObject := 0;
					MachineInfoDataObjectIdent := InfoFileCreate_0.ident;
				65535:
					InfoFileCreate_0();
			END_CASE
		END_CASE
	
	
		// Updating MachineInfo.dat
		CASE UpdateMachineInfoDataObject OF
			1:
				OpenMachineInfoDataObject := 1;
				UpdateMachineInfoDataObject := 2;
		
			2:
				IF (OpenMachineInfoDataObject = 0) AND (MachineInfoDataObjectIdent > 0) THEN
					UpdateMachineInfoDataObject := 3;
				END_IF
			3:
				InfoFileWrite_0(enable:=1, ident:=MachineInfoDataObjectIdent, offset:=0, pSrc:=ADR(MachineInfoByte), len:=SIZEOF(MachineInfoByte));
				UpdateMachineInfoDataObject := 4;
			4:
				IF InfoFileWrite_0.status = 65535 THEN
					InfoFileWrite_0();
				ELSE
					UpdateMachineInfoDataObject := 5;
				END_IF
			5:
				CloseMachineInfoDataObject := 1;
				UpdateMachineInfoDataObject := 6;
			6:
				IF CloseMachineInfoDataObject = 0 THEN
					UpdateMachineInfoDataObject := 0;
				END_IF
		END_CASE
		
		
		// Close connection to MachineInfo.dat
		CASE CloseMachineInfoDataObject OF
		1:
			IF (MachineInfoDataObjectIdent > 0) THEN
				InfoFileClose_0(enable:=1, ident:=MachineInfoDataObjectIdent);
				CloseMachineInfoDataObject := 2;
			END_IF
		2:
			CASE InfoFileClose_0.status OF
			0:
				CloseMachineInfoDataObject := 0; (*File closed*)
				MachineInfoDataObjectIdent := 0;
			65535:
				InfoFileClose_0(); (*Fub still working*)
			END_CASE
		END_CASE
	
	
		// Tjek if it is waiting for and update
		IF waitingToUpdate AND (UpdateMachineInfoDataObject = 0) THEN
			UpdateMachineInfoDataObject := 1;
			waitingToUpdate := FALSE;
		END_IF
		
		
		// Calculation for the operating hours
		// g_Core.System.Runtime.isRunning has to be set in a machine specific task. TRUE if Run hours should count, or FALSE if not count should be made
		
		IF g_Core.Services.System.Runtime.isSystemFileValid THEN
			ProductionEvents := 0; // PanConfig
			FOR i := 0 TO SIZEOF(g_Core.Services.PanConfig.Interface.productionEvent)/SIZEOF(g_Core.Services.PanConfig.Interface.productionEvent[0]) - 1 DO
				ProductionEvents := ProductionEvents + g_Core.Services.PanConfig.Interface.productionEvent[i];
				g_Core.Services.PanConfig.Interface.productionEvent[i] := FALSE;
			END_FOR
			MachineInfo_0(Enable := 1, Running := g_Core.System.Runtime.isRunning, Counts := ProductionEvents, pInfoMemory := ADR(g_MachinePermInfo), pInfoCFCard := ADR(MachineInfoByte));
			IF MachineInfo_0.FileSave THEN
				IF UpdateMachineInfoDataObject = 0 THEN
					UpdateMachineInfoDataObject := 1;
				ELSE
					waitingToUpdate := TRUE;
				END_IF
			END_IF;
			
			// Service Hook.
			IF (g_Core.Services.PanConfig.Interface.machineInfoState <> 0) THEN
				MachineInfo_0.State 									:= g_Core.Services.PanConfig.Interface.machineInfoState;
				g_Core.Services.PanConfig.Interface.machineInfoState 	:= 0;
			END_IF
			
			// Export Counters to core.
			g_Core.System.Runtime.operatingHours	:= MachineInfo_0.OperatingHours;
			g_Core.System.Runtime.powerOnHours		:= MachineInfo_0.PowerOnHours;
			g_Core.System.Runtime.totalCounter		:= MachineInfo_0.ProductionCounts;
			g_Core.System.Runtime.totalCounterSmall	:= MachineInfo_0.ProductionCountsSmall;
			
		END_IF;
		Init := FALSE;
	END_IF
END_PROGRAM

