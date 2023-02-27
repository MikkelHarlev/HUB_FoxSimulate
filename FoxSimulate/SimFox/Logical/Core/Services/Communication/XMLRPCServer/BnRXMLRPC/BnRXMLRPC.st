PROGRAM _INIT

	pThis ACCESS ADR(g_Core.Services.Communication.XMLRPCServer);
	
END_PROGRAM


PROGRAM _CYCLIC
	
	CASE pThis.Runtime.initState OF
		
		INIT:
			IF (g_Core.Services.System.Runtime.initState = RUNTIME) THEN
				// Get port from system file.
				pThis.Runtime.port := g_Core.Services.System.Runtime.file.Port;
				
				// Copy XML Configuration to B&R XML RPC Server.k
				strcpy(ADR(XML_PVs_data.ParamModule),ADR('xmsvrcfg'));
				// Setup XML RPC Server PORT.
				pThis.Runtime.serverStatus := XMLPVsportinit(ADR(XML_PVs_ident), ADR(XML_PVs_data), pThis.Runtime.port);
				
				IF (pThis.Runtime.serverStatus = 0) THEN
					// Tell the rest of the system that the XML RCP Server is started
					pThis.Runtime.isServerStarted := TRUE;
					
					// Go into runtime mode.
					pThis.Runtime.initState := RUNTIME;
				END_IF
			END_IF
			
		RUNTIME:

	END_CASE

END_PROGRAM
