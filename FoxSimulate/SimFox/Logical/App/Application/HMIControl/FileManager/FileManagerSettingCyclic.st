(*-------------------------------------------------------------------------------------

Author:   				Sten Flystedt

Description:			Factory setting FOR files.

History:

2012-02-17				V1.00.1	Sten Flystedt		g_MCfg changed TO g_g_MCfg.Bufferg_MCfg deleted as variable
2011-06-01				V1.00.0 Sten Flystedt		First edition...

---------------------------------------------------------------------------------------*)


PROGRAM _CYCLIC

// mcfg.csv.
// If correct password was entered, save current config as factory settings.

	IF NOT (g_Core.Services.Machine.Interface.ptrConfig > 0) THEN		
		;
	ELSE
		//MachineConfig ACCESS(g_Core.Services.Machine.Interface.ptrConfig );
		IF (g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel > 2) AND (g_MCfg.FactorySettingsUpdate = 17216 ) THEN
			g_MCfg.FactorySettingsUpdate := 0;
			g_Core.Services.Machine.Interface.isCmdSaveFactorySettings := TRUE;
		END_IF
		IF g_ExternalFileManage.saveMcfg THEN 												// External task want to save machine config that was changed
			g_ExternalFileManage.saveMcfg 					:= FALSE;		
			g_Core.Services.Machine.Interface.isCmdSave 	:= TRUE;						// Command mcfg to do the actual saving
		END_IF
	END_IF

	IF (g_Core.Services.Machine.Interface.ptrConfig > 0) AND (g_Core.Services.Hardware.Interface.ptrConfig > 0) THEN		
		g_OptionsAndConfigInit := TRUE;
	END_IF

END_PROGRAM
