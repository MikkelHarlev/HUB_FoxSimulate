PROGRAM _INIT
END_PROGRAM


PROGRAM _CYCLIC

	IF (g_Core.Services.Alarmhandler.Runtime.Event[0].Status <> 0) THEN
	
		CASE BOOL_TO_USINT(g_Core.Services.Alarmhandler.Runtime.blinkPulse) OF
  			0:
				StartOffColor := Color1;		
			1:
				StartOffColor := Color2;
			
		END_CASE		
	ELSE
		StartOffColor := Color3;
	END_IF
	
	IF (g_Core.System.Runtime.isAppReady) THEN
		AppColor := Color1;
		
	ELSE
		AppColor := Color3;
		
	END_IF
	
END_PROGRAM
