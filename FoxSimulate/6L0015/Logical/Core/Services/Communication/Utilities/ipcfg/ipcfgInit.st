PROGRAM _INIT
// Set range from core config.
Ipcfg.Range := g_Core.System.Configuration.ipRange;

Ipcfg.Range.IPAddressMinVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Range.IPAddressMinString)));
Ipcfg.Range.IPAddressMaxVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Range.IPAddressMaxString)));
Ipcfg.Range.IPDefaultGatewayMinVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Range.IPAddressMinString))) AND N_TO_HUDINT(inet_addr(ADR(Ipcfg.Range.IPSubnetMaskString)));
Ipcfg.Range.IPDefaultGatewayMaxVal := Ipcfg.Range.IPDefaultGatewayMinVal OR NOT(N_TO_HUDINT(inet_addr(ADR(Ipcfg.Range.IPSubnetMaskString))));

Ipcfg.HMI.PingBar := 0;
Ipcfg.HMI.PingColour := 15;
END_PROGRAM