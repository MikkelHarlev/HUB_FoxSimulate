PROGRAM _INIT
	Step:= 0;
	Backup.StatusWarningText:= 1;
	
	(*Setup New USBDisk handler*)
	USBDisk_0(Run:=1,FileDeviceName:=ADR('USBStick'),USBDevice:= g_Core.System.Configuration.userUsbIF,PullInterval:=2);
	USBIconDisplayTimer := 30;
	USBReadWriteTimer	:= 10;
	PageBackUp := LookupPageID(PAGE_USB_BACKUP_230, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
	
	pThis ACCESS ADR(g_Core.Services.Backup);
	
END_PROGRAM



