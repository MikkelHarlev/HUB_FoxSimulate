(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson.

Desription:				HMI FOR the XML commuinication with Metricon:

09-06-23				V1.00 PO Nilsson				First edition.

---------------------------------------------------------------------------------------*)

PROGRAM _CYCLIC


//IF g_HMIHandler.CurrentPage = PAGE_XML_METRICON_540 THEN
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PageXMLDiag THEN
	
		// Used for HMI
		strcpy(ADR(g_ExternalCom.Common.IPAddress),ADR(g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ServerInfo.IPAddress));
		// Allow to request garment data for diagnostics
		IF g_ExternalCom.HangerRequestHMI > 0 THEN
			g_ExternalCom.HangerRequestHMI  		:= 0;
			g_ExternalCom.HangerState 				:= EXTERN_HANGER_REQUEST_1;
		END_IF	

		// Garment data
		XMLMetriconDiag.GarmentData.Article			:= g_ExternalCom.ArticleId;
		XMLMetriconDiag.GarmentData.Customer		:= g_ExternalCom.CustomerId;
		XMLMetriconDiag.GarmentData.Destination		:= g_ExternalCom.Destination;
		//XMLMetriconDiag.GarmentData.GarmentId		:= DataMakeStr(g_ExternalCom.GarmentId);
		DataMakeStr(g_ExternalCom.GarmentId, ADR(XMLMetriconDiag.GarmentData.GarmentId));
	
	
		XMLMetriconDiag.GarmentData.HangerStatus	:= g_ExternalCom.HangerState;
		XMLMetriconDiag.GarmentData.Program			:= g_ExternalCom.Recipe;
		XMLMetriconDiag.GarmentData.Stack			:= g_ExternalCom.StackChange;
	
		// Counters
		XMLMetriconDiag.Counters.AwayCounter		:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.Statistic.AwayCounter;
		XMLMetriconDiag.Counters.RequestCounter		:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.Statistic.RequestCounter;
		XMLMetriconDiag.Counters.StatusSend			:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.Statistic.StatusTransmitCounter;
		//	XMLMetriconDiag.Counters.TimeOut			:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.Statistic.???;
	
					
	
		// Status signals
		XMLMetriconDiag.StatusSignals.HangerWaiting	:= g_ExternalCom.HangersWaiting; 
		XMLMetriconDiag.StatusSignals.InletActive	:= g_ExternalCom.InletActive;	
		XMLMetriconDiag.StatusSignals.InletFull		:= g_ExternalCom.InletFull;
		XMLMetriconDiag.StatusSignals.OutletFull	:= g_ExternalCom.OutletFull;
	
	
		// Connection state
		XMLMetriconDiag.ConnectionState.ClientMachineStatus	:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.MachineStatus;			// Vart skall detta sättas
		XMLMetriconDiag.ConnectionState.ClientVersion		:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.Version;
		XMLMetriconDiag.ConnectionState.ComState			:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.ConnectionState;
		XMLMetriconDiag.ConnectionState.ServerVersion		:= g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ServerInfo.Version;	
	
		// Show Log state
		IF g_RunJenLog THEN
			ShowLogText := 0;
		ELSE
			ShowLogText := 1;
		END_IF	

	
	
		// Key pressed
		IF XMLMetriconDiag.cmdComState = 1 THEN
			XMLMetriconDiag.cmdComState := 0; 
			g_HangerInletProcess.ForcedNoCom := g_HangerInletProcess.ForcedNoCom + 1;
			IF g_HangerInletProcess.ForcedNoCom > 2 THEN
				g_HangerInletProcess.ForcedNoCom := 0;
			END_IF	
		ELSIF EDGEPOS( g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 3) THEN
			g_RunJenLog := NOT g_RunJenLog;
		END_IF		

		//g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed := 0;(* always clear key *)
	END_IF	


	// Main page status icon
	StartUpDelayTOF(IN := FALSE, PT := T#30s);
	CommunicationErrorMetriconTOF.IN := FALSE;
	IF (g_HangerInletProcess.HangerReading = 0) OR NOT g_Core.Services.System.Runtime.file.Connection[2].isEnabled OR (g_MCfg.Metricon.ComMode <> 1) THEN
		XMLMetriconDiag.MainIconState := 0;			(* Do not show icon when no com configured *)
	ELSE
		IF (g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.ConnectionState = 1) OR 
			(g_Core.Services.Communication.ConnectionHandler.FoldXML.Runtime.connection[0].data.ClientInfo.ConnectionState = 0) THEN
			XMLMetriconDiag.MainIconState := 2;			(* Com is not OK *)
			CommunicationErrorMetriconTOF.IN := NOT StartUpDelayTOF.Q;
		ELSE
			XMLMetriconDiag.MainIconState := 1;			(* Com is OK *)
			HasConnected := TRUE;
		END_IF		
	END_IF
	CommunicationErrorMetriconTOF( PT := T#1s );
	g_CommunicationErrorMetricon := CommunicationErrorMetriconTOF.Q;
	g_MainAlarms.Alarm[19] := g_CommunicationErrorMetricon;


END_PROGRAM
