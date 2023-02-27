PROGRAM _INIT
(* init program *)


g_ExternalPVICom.RequestTimeOutTime := 3000;// Hardcoded should be ok or?

(* Init the Finisher scanner *)
HwGetNode_0(enable:= 1, pDevice:= ADR('SL0.SS0.HW'), ordinal:= 1);
g_PLCNodeId:= HwGetNode_0.node;
ERRxwarning(1234, g_PLCNodeId, ADR('Node id'));

//InitFoldClient(2, g_PLCNodeId, ADR(g_ExternalCom.Ethernet), '', 250); // 250 just during startup. Will be replaced by configured value
BCD_Conntection := 0;
pThis ACCESS ADR(g_Core.Services.Communication.ConnectionHandler.FoldXML);
getLogicIdent_0(sysID := 1 , roleType := 2);

END_PROGRAM

