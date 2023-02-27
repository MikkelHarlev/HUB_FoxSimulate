PROGRAM _CYCLIC
	USBDisk_0();
	IF EDGENEG(UINT_TO_BOOL(USBDisk_0.Status)) AND (USBDisk_0.VendorID > 0) THEN
		(* New usb device plugged in... *)
		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 300, USBIconDisplayTimer);
		pThis.Runtime.isUsbStorageAttached := TRUE;
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel >= 2) THEN
			ROldPageID := g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID;
			CallPageControllerLink(10, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler); (* Backup page *)
		END_IF;
	END_IF
	IF EDGEPOS(UINT_TO_BOOL(USBDisk_0.Status)) AND pThis.Runtime.isUsbStorageAttached THEN
		pThis.Runtime.isUsbStorageAttached := FALSE;
		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 301, USBIconDisplayTimer);
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 10) AND (ROldPageID <> 10) THEN
			CallPageControllerLink(0, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler); (* Exit *)
		END_IF
	END_IF
	
	(* Open page *)
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageBackUp) THEN
		(* Blank ID is not allowed *)
		MachineNumber := g_Core.System.Configuration.SystemDescription.MachineNumber;
		// Set from g_Core TODO!!!
		Backup.Include.Index 		:= 0; (* All *)
		Backup.Include.ComboboxHide := 1;
	END_IF;
	
	(* No USB found *)
	IF NOT pThis.Runtime.isUsbStorageAttached OR (Backup.Include.ComboboxHide = 0) THEN
		Step := 0;
	END_IF;
	
	
	
	(* Backup\Restore case *)
	CASE Step OF
		0: // Wait for commands 
			
			// Reset paths - bug if copy more than once
			CopySource := '';
			CopyDestination := '';
			
			(* USB found..? *)
			IF NOT pThis.Runtime.isUsbStorageAttached THEN
				Backup.IndexStatusText := 3; (* TEXT_NOUSB *)
				Backup.StatusWarningText := 1;
			ELSE
				Backup.IndexStatusText := 0; (* TEXT_READY *)
				IF Backup.cmdBackup = 1 THEN
					Step := 1;
					Backup.StatusWarningText:= 0;
					Backup.IndexStatusText := 1; (* TEXT_BACKUP_WARNING *)
				END_IF;
	
				IF Backup.cmdRestore = 1 THEN
					Step := 20;
					Backup.StatusWarningText:= 0;
					Backup.IndexStatusText := 4; (* TEXT_RESTORE_WARNING *)
				END_IF;
			END_IF;
	
		1: (* Warning Backup *)
			IF Backup.cmdBackup = 1 THEN
				CASE Backup.Include.Index OF
					0: CopySource := '';
					1: CopySource := 'Jensen';
					2: CopySource := 'statistics';
					3: CopySource := 'log\service';
					4: CopySource := 'log\cockpit';
					5: CopySource := 'custart';
					6: CopySource := 'operator';
				END_CASE;
				Backup.IndexStatusText := 2; (* TEXT_BACKUP_PROGRESS *)
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, 9999);
				Step := 2;
			END_IF;
	
		2: (* Search\Create Folders *)
			DirCreate_0.enable:=	1;
			DirCreate_0.pDevice:=	ADR('USBStick');
			strcpy(ADR(RSearchFolder), ADR(MachineNumber));
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				CASE Backup.Include.Index OF
					0: ;
					1: strcat(ADR(RSearchFolder), ADR('\Jensen'));
					2: strcat(ADR(RSearchFolder), ADR('\statistics'));
					3,4: strcat(ADR(RSearchFolder), ADR('\log'));
					5: strcat(ADR(RSearchFolder), ADR('\custart'));
					6: strcat(ADR(RSearchFolder), ADR('\operator'));
				END_CASE;
	
				IF Backup.Include.Index = 0 THEN
					strcat(ADR(CopyDestination), ADR(RSearchFolder));
					strcat(ADR(CopyDestination), ADR('\'));
					Step := 5;
				ELSE
					Step := 3;
				END_IF;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
		3: (* Create Subfolders *)
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				CASE Backup.Include.Index OF
					3:  strcat(ADR(RSearchFolder), ADR('\service'));
						Step := 4;
					4:  strcat(ADR(RSearchFolder), ADR('\cockpit'));
						Step := 4;
					0,1,2,5,6:
						strcat(ADR(CopyDestination), ADR(RSearchFolder));
						strcat(ADR(CopyDestination), ADR('\'));
						Step := 5;
				END_CASE;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
		4: (* Create Subfolders *)
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				strcat(ADR(CopyDestination), ADR(RSearchFolder));
				strcat(ADR(CopyDestination), ADR('\'));
				Step := 5;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
		5: 
			IF Backup.ErrorNumber = 0 OR Backup.ErrorNumber = 20708 THEN //OK OR file not found
				Step:= 10;
			ELSIF Backup.ErrorNumber <> 0 AND Backup.ErrorNumber <> 65535 THEN
				Backup.IndexStatusText:= TEXT_BACKUP_ERROR;
				Step:= 30;
			END_IF
	
			IF Backup.cmdCancel = 1 THEN
				Backup.cmdCancel:= 0;
				Backup.StatusWarningText:= 1;
				Backup.IndexStatusText:= TEXT_WAIT;
				Step:= 0;
			END_IF
	
		10: (* Backup *)
			DirCopy_0(enable := TRUE, pSrcDev := ADR('all'), pSrcDir := ADR(CopySource), pDestDev := ADR('USBStick') , pDestDir := ADR(CopyDestination), option := fiOVERWRITE);
			Backup.ErrorNumber := DirCopy_0.status;
	
			IF Backup.ErrorNumber = 0 THEN
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, 1);
				Backup.IndexStatusText := 0; (* TEXT_READY *)
				Step := 0;
			ELSIF Backup.ErrorNumber <> 0 AND Backup.ErrorNumber <> 65535 THEN
				Backup.IndexStatusText := Backup.ErrorNumber;
				Step := 30;
			END_IF;
	
		20: (* Warning Restore *)
			IF Backup.cmdRestore = 1 THEN
				strcat(ADR(CopySource), ADR(MachineNumber));			
				CASE Backup.Include.Index OF
					0: strcat(ADR(CopySource), ADR('\'));
						CopyDestination := '';
					1: strcat(ADR(CopySource), ADR('\jensen\'));
						CopyDestination := 'all\jensen\';
						RSearchFolder := '\jensen';
					2: strcat(ADR(CopySource), ADR('\statistics\'));
						CopyDestination := 'statistics\';
						RSearchFolder := '\statistics';
					3: strcat(ADR(CopySource), ADR('\log\service\'));
						CopyDestination := 'all\service\';
						RSearchFolder := '\log';
					4: strcat(ADR(CopySource), ADR('\log\cockpit\'));
						CopyDestination := 'cockpit\';
						RSearchFolder := '\log';
					5: strcat(ADR(CopySource), ADR('\custart\'));
						CopyDestination := 'custart\';
						RSearchFolder := '\custart';
					6: strcat(ADR(CopySource), ADR('\operator\'));
						CopyDestination := 'operator\';
						RSearchFolder := '\operator';
				END_CASE;
	
				Backup.IndexStatusText := 5; (* TEXT_RESTORE_PROGRESS *)
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_OPEN_120, 9999);
				IF Backup.Include.Index = 0 THEN
					Step := 23;
				ELSE
					Step := 21;
				END_IF;
	
			END_IF;
	
		21: (* Search\Create Folders *)
			DirCreate_0.enable  := 1;
			DirCreate_0.pDevice := ADR('all');
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				CASE Backup.Include.Index OF
					3:  strcat(ADR(RSearchFolder), ADR('\service'));
						Step := 22;
					4:  strcat(ADR(RSearchFolder), ADR('\cockpit'));
						Step := 22;
					1,2,5,6:
						Step := 23;
				END_CASE;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
		22: (* Search\Create Folders *)
			DirCreate_0.enable  := 1;
			DirCreate_0.pDevice := ADR('all');
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				Step := 23;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
		23: (* Restore *)			
			DirCopy_0(enable := TRUE, pSrcDev := ADR('USBStick'), pSrcDir := ADR(CopySource), pDestDev := ADR('all') , pDestDir := ADR(CopyDestination), option := fiOVERWRITE);
			Backup.ErrorNumber := DirCopy_0.status;
	
			IF Backup.ErrorNumber = 0 THEN
				Backup.StatusWarningText:= 1;
				Backup.IndexStatusText := 0; (* TEXT_READY *)
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, 1);
				Step := 0;
			ELSIF Backup.ErrorNumber <> 0 AND Backup.ErrorNumber <> 65535 THEN
				Backup.IndexStatusText := Backup.ErrorNumber;
				Step := 30;
			END_IF;
	
		30: (* Error *)
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121, 1);
			Step := 0;
	
		112: (* Search\Create Folders *)
			DirCreate_0.enable  := 1;
			DirCreate_0.pDevice := ADR(CopyDestination);
			DirCreate_0.pName := ADR(RSearchFolder);
			DirCreate_0();
	
			IF DirCreate_0.status = 65535 THEN
				;
			ELSIF (DirCreate_0.status = 20725 OR DirCreate_0.status = 0) THEN
				Step := 0;
			ELSE
				Backup.IndexStatusText := DirCreate_0.status;
				Step := 30;
			END_IF;
	
	END_CASE;
	
	(* Cancel *)
	IF (Step = 0) OR (Step = 1) OR (Step = 20) OR (Step = 30) THEN
		IF Backup.cmdCancel = 1 THEN
			Backup.StatusWarningText := 1;
			Backup.Include.Index := 0; (* All *)
			Backup.IndexStatusText := 0; (* TEXT_READY *)
			Step := 0;
		END_IF;
	END_IF;
	Backup.cmdBackup:= 0;
	Backup.cmdRestore:= 0;
	Backup.cmdCancel := 0;
	
	(* Combobox max index *)
	IF g_Core.Services.CAR.Runtime.isEnabled THEN
		Backup.Include.ComboboxMaxIndex := 6;
	ELSE
		Backup.Include.ComboboxMaxIndex := 4;
	END_IF;
	
	(* Combobox Up/Dw *)
	IF Backup.Include.IndexUp THEN
		Backup.Include.IndexUp := 0;
		Backup.Include.Index := Backup.Include.Index + 1;
	ELSIF Backup.Include.IndexDw THEN
		Backup.Include.IndexDw := 0;
		Backup.Include.Index := Backup.Include.Index - 1;
	END_IF;
	
	(* Index Check *)
	IF Backup.Include.Index > Backup.Include.ComboboxMaxIndex THEN
		Backup.Include.Index := Backup.Include.ComboboxMaxIndex;
	END_IF;
END_PROGRAM

