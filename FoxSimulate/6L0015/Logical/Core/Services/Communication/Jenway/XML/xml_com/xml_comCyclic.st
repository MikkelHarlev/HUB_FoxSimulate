(*------------------------------------------------------------------------------------------------------------------------------------

	Project Name: 	JENSEN Common HMI Project

	Task Name:		xml_comCyclic.st	

 	Description:		XML Communication Task

	History:			24-01-2011		V1.00.0		JEDK 	First Edition
							13-02-2012		V1.03.0		AHO	 Added connection for Concorde no 5
							18-03-2015		V1.04.0		AHO  Added connection for Evolution
							16-03-2017		V1.05.0		AHO  Added connection for JenscanMPS
							11-12-2017		V1.06.0		AHO  Changed: XML timeouts 1200->2000, 600->1000

------------------------------------------------------------------------------------------------------------------------------------*)

PROGRAM _CYCLIC
IF NOT g_Core.System.Runtime.isInitDone THEN
	RETURN;
END_IF

////---------------------------------------------
//// Init										   
////---------------------------------------------
//IF NOT InitDone THEN
//	connections := 0;
//	FOR No := 0 TO 9 DO // 3
//		// Fix Id for M2M connection 0-3 
//		g_System.File.Connection[No].Id := FlatId[g_Core.System.Configuration.machineType].Data[No];
//		// Connection text 
//		XML_Connection.TextId[No] := FlatText[g_Core.System.Configuration.machineType].Data[No];
//		// Show connection 
//		XML_Connection.Show[No] := NOT (FlatText[g_Core.System.Configuration.machineType].Data[No] <> 0);
//		connections := connections + (FlatText[g_Core.System.Configuration.machineType].Data[No] <> 0);
//	END_FOR
//	IF connections < 6 THEN // Disable extra screen if connections are below 6.
//		UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 16, 1, 0, 0, 0);
//		UpdateButton(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 17, 1, 31, 0, 16);
//	END_IF
//	InitDone := 1;
//END_IF

//---------------------------------------------
// Flat/XML Communication 					   
//---------------------------------------------
CASE ComState OF
	0:	// Init Servers, when check is ready 
		ConfState := 1;

		IF ConfState = 1 THEN
			InitXMLServer(1, g_MachineConfig.XMLSendOutConnectId, ADR(XMLServerComInfo[0]), XML_ServerData[0], 2000);
			ComState := 1;
		END_IF

	1:	// Init Clients 
		InitXMLClient(1, g_MachineConfig.XMLSendOutConnectId, ADR(XMLClientComInfo[0]), XML_ClientData[0], g_MachineConfig.XMLSendOutIPAddress, 1000);
		ComState := 2;

	2:	// Init Ports 
		//XML_PVs_status := XMLPVsportinit(ADR(XML_PVs_ident), ADR(XML_PVs_data), g_System.File.Port);
		XML_PVs_status := XMLPVsportinit(ADR(XML_PVs_ident), ADR(XML_PVs_data), 81);
		//SetXMLPortNumber(g_System.File.Port);
		SetXMLPortNumber(81);
		IF (XML_PVs_status = 0) THEN
			g_Core.Services.XMLCom.Runtime.isServerStarted := TRUE;
			ComState := 3;
		END_IF

	3:	// Run Servers 
//		IF g_Options.DeliveryExternalCommunication = EXTCOM_JENWAY_HAS_ROLLOFF_2 THEN	// Outcomment by request from MD, 15/9-20.
			RunXMLServer(ADR(XMLServerComInfo[0]));
			g_XMLServerCom[0].ComState        := XMLServerComInfo[0].ComState;
			g_XMLServerCom[0].UpdateTrigger   := XMLServerComInfo[0].UpdateTrigger;
			XMLServerComInfo[0].UpdateTrigger := 0;
			XMLClientComInfo[0].UpdateTrigger := g_XMLClientCom[0].UpdateTrigger;
			RunXMLClient(ADR(XMLClientComInfo[0]));
			g_XMLClientCom[0].ComState        := XMLClientComInfo[0].ComState;
			g_XMLClientCom[0].UpdateTrigger   := XMLClientComInfo[0].UpdateTrigger;
//		END_IF
END_CASE

////---------------------------------------------
//// M2M/XML Configuration 					   
////---------------------------------------------
//CASE ConfState OF
//	0: // Decode IP-adresses 
//		FOR Cnt := 0 TO 13 DO
//			EthGenUDINT := inet_addr(ADR(g_System.File.Connection[Cnt].IpAdr));
//
//			IpInvalid := FALSE;
//			// Split Ip-Adresses 
//			FOR CountByte := 0 TO 3 DO
//				pEthernetCfg ACCESS (ADR(EthGenUDINT) + CountByte);
//				XML_Connection.IpAddress[Cnt].Split[CountByte] := pEthernetCfg;
//
//				// If any part of the IP-Address is invalid then set it to default and restart 
//				RIPMin := SEL((Cnt < 10),IP_Min2XML,IP_Min[CountByte]);
//				RIPMax := SEL((Cnt < 10),IP_Max2XML,IP_Max[CountByte]);
//				IF (XML_Connection.IpAddress[Cnt].Split[CountByte] < RIPMin) OR (XML_Connection.IpAddress[Cnt].Split[CountByte] > RIPMax) THEN
//					XML_Connection.IpAddress[Cnt].Split[CountByte] := RIPMin;
//					IpInvalid := TRUE;
//				END_IF
//			END_FOR;
//
//			XML_Connection.Id[Cnt] := g_System.File.Connection[Cnt].Id;
//			XML_Connection.Enable[Cnt] := g_System.File.Connection[Cnt].Enable;
//		END_FOR;
//		XML_Connection.Port := g_System.File.Port;
//		XML_Connection.Base64 := g_System.File.Base64;
//
//		IF IpInvalid THEN
//			IpInvalid := FALSE;
//			ConfState := 10;
//		ELSE
//			ConfState := 1;
//		END_IF
//
//	1: // Check for Save and reboot 
//		IF Save_And_Restart THEN
//			ConfState := 10;
//		END_IF
//
//	10: // If a false IP-Address detected or IP-Addresses are changed by user, write the new IP-Addresses to the string and restart communications 
//		FOR Cnt := 0 TO 13 DO
//			// Merge Ip-Adresses split 
//			itoa(XML_Connection.IpAddress[Cnt].Split[0], ADR(EthAddressBuffer));
//			strcpy(ADR(g_System.File.Connection[Cnt].IpAdr),ADR(EthAddressBuffer));
//			FOR count := 1 TO 3 DO
//				strcat(ADR(g_System.File.Connection[Cnt].IpAdr),ADR('.'));
//				itoa(XML_Connection.IpAddress[Cnt].Split[count], ADR(EthAddressBuffer));
//				strcat(ADR(g_System.File.Connection[Cnt].IpAdr),ADR(EthAddressBuffer));
//			END_FOR;
//
//			g_System.File.Connection[Cnt].Id := XML_Connection.Id[Cnt];
//			g_System.File.Connection[Cnt].Enable := XML_Connection.Enable[Cnt];
//		END_FOR;
//
//		// If using old Port and Base64 parameters a reboot is required
//		Reboot_Required := (XML_Connection.Port <> g_System.File.Port) OR (XML_Connection.Base64 <> g_System.File.Base64) OR (XML_Connection.Port = 80) OR NOT XML_Connection.Base64;
//
//		g_System.File.Port := XML_Connection.Port;
//		g_System.File.Base64 := XML_Connection.Base64;
//
//		IF Save_And_Restart THEN
//			// Save Values 
//			g_Core.Services.System.Interface.isCmdSave := TRUE;
//			FileSave_status := g_Core.Services.System.Runtime.saveCounter;
//
//			// Return to main page when save button is pressed
//			IF NOT Reboot_Required THEN
//				CallPageControllerLink(1, g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler);
//			END_IF
//
//			ConfState := 100;
//		ELSE
//			ConfState := 1;
//		END_IF
//
//	100:
//		IF g_Core.Services.System.Runtime.saveCounter > FileSave_status THEN
//			Save_And_Restart := 0;
//
//			// Reboot required if using old Port and Base64 settings. Otherwise restart XML communication.
//			IF Reboot_Required THEN
//				SYSreset(1,1);
//			ELSE
//				g_RestartXMLCom := 1;
//			END_IF
//		END_IF
//END_CASE

////---------------------------------------------
//// M2M Communication check					   
////---------------------------------------------
//TON_AlarmCheck(IN:=NOT TON_AlarmCheck.Q,PT:=T#1s);
//IF TON_AlarmCheck.Q THEN
//	g_Core.Services.XMLCom.Runtime.isConnectionError := FALSE;
//	FOR No := 0 TO 9 DO
//		IF (FlatServer[g_Core.System.Configuration.machineType].Data[No] > 0) THEN
//			pClientMachineStatus ACCESS (FlatServer[g_Core.System.Configuration.machineType].Data[No]+2);
//			TON_CommCheck[No](IN:=(g_System.File.Connection[No].Enable AND (pClientMachineStatus <> 2)), PT:=T#5s);
//			g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Alarm[FlatText[g_Core.System.Configuration.machineType].Data[No]+49] := (g_ArcNetError[FlatText[g_Core.System.Configuration.machineType].Data[No]] OR TON_CommCheck[No].Q) AND NOT AlarmBypass[FlatText[g_Core.System.Configuration.machineType].Data[No]+49];
//			g_Core.Services.Alarmhandler.Interface.AlarmGroup[CORE_ALARMS].Priority[FlatText[g_Core.System.Configuration.machineType].Data[No]+49]:= 250;
//
//			IF TON_CommCheck[No].Q  AND NOT AlarmBypass[FlatText[g_Core.System.Configuration.machineType].Data[No]+49] THEN
//				g_Core.Services.XMLCom.Runtime.isConnectionError := TRUE;
//			END_IF
//		END_IF
//	END_FOR
//END_IF
		
END_PROGRAM