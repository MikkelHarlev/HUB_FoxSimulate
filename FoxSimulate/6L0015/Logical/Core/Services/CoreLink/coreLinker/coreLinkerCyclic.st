PROGRAM _CYCLIC
	CASE runtimeStep OF
	0:
		IF (adrInOperation > 0 AND adrEStop > 0) THEN
			runtimeStep := 1;
		END_IF
		
	1:
		pInOperation ACCESS adrInOperation;
		pEStop ACCESS adrEStop;
		// We should not report 
		g_Core.System.Runtime.isAppReady				:= g_Core.System.Interface.isAppReady;
		g_Core.System.Runtime.isRunning					:= pInOperation;
		//g_Core.System.Runtime.isEStopActivated			:= pEStop OR g_Core.System.Runtime.isSimulation;
		g_Core.System.Runtime.isCustomerEnabled			:= g_Core.System.Interface.isCustomerEnabled;
		g_Core.System.Runtime.isOperatorEnabled			:= g_Core.System.Interface.isOperatorEnabled;
		g_Core.System.Runtime.timelineIntervalInSec		:= g_Core.System.Interface.timelineIntervalInSec;
		g_Core.System.Runtime.showLevel					:= g_Core.System.Interface.showLevel;
		
		// Open Reboot dialog, prototype
		IF (g_Core.System.Interface.isRequestReboot) THEN
			dialogText := 'The system needs to reboot in order to apply the changes!';
			IF (dialogStep = 0) THEN
				dialogStep := 1;
			END_IF
			CASE cmdDialog OF
					// Reboot
					1:
						SYSreset(1,1);			
					// Cancel
					2:
						g_Core.System.Interface.isRequestReboot := FALSE;
						cmdDialog := 0;
			END_CASE
		END_IF
		
		CASE dialogStep OF
			0:
			
			1:
				hideDialog := 0;
				IF (cmdDialog > 0) THEN
					dialogStep := 0;
					hideDialog := 1;
				END_IF
		END_CASE
			
		//
		// Internal Core Control...
//		g_Core.System.Runtime.isStatisticsRunning				:= g_Core.System.Runtime.isRunning AND (NOT g_Core.System.Runtime.isPowerSave);
//		g_Core.System.Interface.infos.isInOperationPowerSave 	:= g_Core.System.Runtime.isPowerSave;
//		g_Core.System.Interface.infos.isInOperation				:= g_Core.System.Runtime.isRunning AND (NOT g_Core.System.Runtime.isPowerSave);																		// set through core!
//		g_Core.System.Interface.infos.isReadyToStart 			:= g_Core.System.Runtime.isAppReady AND (NOT g_Core.System.Runtime.isRunning) AND (g_Core.Services.Alarmhandler.Runtime.Event[0].Status = 0);
		
		// Internal Estop Handling, Safety PLC is handled externally
		IF NOT (g_Core.System.Configuration.isSafetyPLCMonitoringEnabled) THEN
			IF (g_Core.Services.IO.Runtime.numberOfIOModules > 0) THEN
				// Check if we are using IOs
				g_Core.System.Interface.alarms.isEStopActive 	:= NOT g_Core.System.Runtime.isEStopActivated;
			ELSE
				g_Core.System.Interface.alarms.isEStopActive 	:= FALSE;
			END_IF
		END_IF
		
		// Notify about PowerSave Mode
		TOF_Powersave(IN := g_Core.Services.HMIHandler.Runtime.Handler[0].touch.status = 1, PT := T#15s);
		IF (g_Core.System.Runtime.isPowerSave AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = 1) AND NOT TOF_Powersave.Q THEN
			Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 30, 5);
		END_IF
	END_CASE	
END_PROGRAM