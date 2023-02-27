PROGRAM _INIT
	//
	// Access local point for easy use.
	//
	pInterface ACCESS ADR(g_Core.Services.HMIHandler);
	//
	// Start up the visualization
	// Use only for a final project!	
	//status := VA_Setup(1 , 'vis');
	//status := VA_StartProject(1,status);
	//
	// Allocate memory for HMI Handlers to load the menu files
	//
	HMIMemPool(enable:=1, len:=100000);
	//
	// Show the spinner
	//
	pInterface.Runtime.hideSpinner		:= FALSE;
	//
	// Generel standart setup of the HMI Handler
	//
	PanelHandler[0].Init.VisObject 		:= ADR('Master');
	PanelHandler[0].Init.DataObject 	:= ADR('vismenu');
	PanelHandler[0].Init.LoadPatch		:= TRUE;
	PanelHandler[0].Init.CalibrateTime 	:= 100;
	PanelHandler[0].Init.Enabled		:= TRUE;

	PanelHandler[1].Init.VisObject 		:= ADR('term1');
	PanelHandler[1].Init.DataObject 	:= ADR('termmenu');
	PanelHandler[1].Init.LoadPatch		:= TRUE;
	PanelHandler[1].Init.CalibrateTime 	:= 50;
	PanelHandler[1].Init.Enabled 		:= FALSE;

	//
	// Select default patch set based on the select PEC ID
	//
	IF (g_Core.System.Configuration.isRemotePanelModeEnabled) THEN
		PanelHandler[0].Init.PatchDataObject:= ADR('HMIPatchRe');
	ELSE
		PanelHandler[0].Init.PatchDataObject:= ADR('HMIPatch');
	END_IF
	PanelHandler[1].Init.PatchDataObject:= ADR('HMIPatch');


	//
	// Initial standart Timer values and pointer settings + initialization of the HMI Handler.
	//
	FOR i := 0 TO (SIZEOF(PanelHandler) / SIZEOF(PanelHandler[0]) -1) DO
		IF PanelHandler[i].Init.Enabled THEN
			PanelHandler[i].MemPool 				:= HMIMemPool.ident;
			PanelHandler[i].Init.LockTimeOut 		:= 12000;
			PanelHandler[i].Init.NotificatorTimer 	:= 15;
			PanelHandler[i].Init.AnimationSpeed 	:= 2;
			PanelHandler[i].Init.ExitTime 			:= 15;
			PanelHandler[i].Init.SystemPageID 		:= 102;
			PanelHandler[i].Init.InvalidPanelPageID := 255;
			PanelHandler[i].Init.WrongPasswordPageID:= 100;
			PanelHandler[i].Init.pPasswordArr 		:= ADR(g_Core.Services.System.Runtime.file.Password[0]);
			PanelHandler[i].Init.pTaskInterface 	:= ADR(pInterface.Runtime.Handler[i]);
			PanelHandler[i].Init.hwID				:= g_Core.System.Configuration.hwID;
			pInterface.Runtime.HandlersRunning 		:= pInterface.Runtime.HandlersRunning + 1;
			PanelHandler[i]();
		END_IF
	END_FOR
	//
	// A temporary fix for the visualization to access the master and slave HMI handlers, this should have been fixed in AS 3.0.81.
	//
	Term1PanelHandler ACCESS ADR(PanelHandler[1]); 
	MasterPanelHandler ACCESS ADR(PanelHandler[0]);
	//
	// Set default notifier fade out delay
	//
	pInterface.Runtime.defaultNotifyTime := 10;
	//
	// Setup basic button theme
	//
	ButtonTheme[0].Pressed	:= 252;
	ButtonTheme[0].Active	:= 250;
	ButtonTheme[0].InActive := 252;
	//
	// Icon Theme - white icons
	//
	ButtonTheme[1].Pressed	:= 249;			
	ButtonTheme[1].Active	:= 252;
	ButtonTheme[1].InActive := 250;
END_PROGRAM

