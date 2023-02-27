PROGRAM _INIT
	GetAdr(ADR(adrInOperation), g_Core.System.Configuration.adrInOperationVarName);
	GetAdr(ADR(adrEStop), g_Core.System.Configuration.adrEStopVarName);
	// Set nodenumber.
	CfgGetInaNode_0( enable :=1, pDevice := ADR( g_Core.System.Configuration.userEthernetIF ));
	g_Core.System.Runtime.nodeID := CfgGetInaNode_0.InaNode;
	// Check if we need to run cockpit, lets just exclude it from remotepanels.
//	IF NOT (g_Core.System.Runtime.nodeID < 101) THEN
//		g_Core.System.Configuration.SystemDescription.MachineNumber := 'Remote';
//	END_IF
	hideDialog := 1;
	g_Core.System.Configuration.isSafetyPLCMonitoringEnabled := TRUE;
END_PROGRAM

