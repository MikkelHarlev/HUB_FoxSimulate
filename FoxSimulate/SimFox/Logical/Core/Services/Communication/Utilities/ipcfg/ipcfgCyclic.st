(*------------------------------------------------------------------------------------------------------------------------------------

	Project Name: 		JENSEN Common HMI Project

	Task Name:			ipcfgCyclic.st	

 	Description:		IP Configuration Task

	History:			24-01-2011		V1.00		JEDK 	First Edition
							06-07-2016		V1.01		AHO		Changed the way of setting the IP address. Set by value from system.csv or HMI change

------------------------------------------------------------------------------------------------------------------------------------*)
PROGRAM _CYCLIC
IF EDGEPOS(g_Core.Services.System.Runtime.initState = RUNTIME) THEN
	Ipcfg.Change.IPAddressString := g_Core.Services.System.Runtime.file.IPAddressPLC;
	Ipcfg.Change.IPDefaultGatewayString := g_Core.Services.System.Runtime.file.IPDefaultGatewayPLC;
	Ipcfg.ChangeStatus := CHANGEINIT;
	Ipcfg.State := 40;
END_IF 	
IF g_Core.Services.System.Runtime.initState <> RUNTIME THEN
	RETURN;
END_IF	

CASE Ipcfg.State OF
	//------------------------------------------------------------------------------------------
	// Change
	//------------------------------------------------------------------------------------------
	0:	// Check, Compare and change IP Setting in Panel 
		TempUDINT := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Change.IPAddressString)));
		IF (TempUDINT < Ipcfg.Range.IPAddressMinVal) OR (TempUDINT > Ipcfg.Range.IPAddressMaxVal) THEN
			Ipcfg.ErrorIPChange := Ipcfg.ErrorIPChange +1;
			Ipcfg.ChangeStatus := CHANGEILLEGAL;
			Ipcfg.State := 2;
		ELSE
			IF strcmp(ADR(Ipcfg.Plc.IPAddressString), ADR(Ipcfg.Change.IPAddressString)) <> 0 THEN
				CfgSetIPAddr_0(enable := 1, pDevice := ADR(g_Core.System.Configuration.userEthernetIF), pIPAddr := ADR(Ipcfg.Change.IPAddressString), Option := 1);
				IF CfgSetIPAddr_0.status <> 65535 THEN				
					IF CfgSetIPAddr_0.status <> 0 THEN				
						Ipcfg.ChangeStatus := CHANGEWRONG;
						Ipcfg.State := 2;
					ELSE
						Ipcfg.ChangeStatus := CHANGEGOOD;
						Ipcfg.State := 1;
					END_IF
				ELSE
					Ipcfg.ChangeStatus := CHANGEBUSY;
				END_IF
			ELSE
				Ipcfg.State := 1;
			END_IF		
		END_IF		

	1:	// Check, Compare and change Default Gateway 
		TempUDINT := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Change.IPDefaultGatewayString)));
		IF (TempUDINT < Ipcfg.Range.IPDefaultGatewayMinVal) OR (TempUDINT > Ipcfg.Range.IPDefaultGatewayMaxVal) THEN
			Ipcfg.ErrorDefaultGatewayChange := Ipcfg.ErrorDefaultGatewayChange +1;
			Ipcfg.ChangeStatus := CHANGEILLEGAL;
			Ipcfg.State := 2;
		ELSE
			IF strcmp(ADR(Ipcfg.Plc.IPDefaultGatewayString), ADR(Ipcfg.Change.IPDefaultGatewayString)) <> 0 THEN
				CfgSetDefaultGateway_0(enable := 1, pDevice := ADR(g_Core.System.Configuration.userEthernetIF), pGateway := ADR(Ipcfg.Change.IPDefaultGatewayString), Option := 1);
				IF CfgSetDefaultGateway_0.status <> 65535 THEN				
					IF CfgSetDefaultGateway_0.status <> 0 THEN				
						Ipcfg.ChangeStatus := CHANGEWRONG;
						Ipcfg.State := 2;
					ELSE
						Ipcfg.ChangeStatus := CHANGEGOOD;
						Ipcfg.State := 2;
					END_IF
				ELSE
					Ipcfg.ChangeStatus := CHANGEBUSY;
				END_IF
			ELSE
				Ipcfg.State := 2;
			END_IF
		END_IF
		
	2:	 // Change finish
		 Ipcfg.State := 40;

	//------------------------------------------------------------------------------------------
	// Get panel infos
	//------------------------------------------------------------------------------------------
	40:	// Get Current IP Address From Panel
			CfgGetIPAddr_0(enable := 1, pDevice := ADR(g_Core.System.Configuration.userEthernetIF), pIPAddr := ADR(Ipcfg.Plc.IPAddressString), Len := SIZEOF(Ipcfg.Plc.IPAddressString));
			IF CfgGetIPAddr_0.status <> 65535 THEN
				Ipcfg.Plc.IPAddressVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Plc.IPAddressString)));
				Ipcfg.State := 41;
			END_IF
			
	41:	// Get Current Subnet Mask From Panel
			CfgGetSubnetMask_0(enable := 1, pDevice := ADR(g_Core.System.Configuration.userEthernetIF), pSubnetMask := ADR(Ipcfg.Plc.IPSubnetMaskString), Len:= SIZEOF(Ipcfg.Plc.IPSubnetMaskString));
			IF CfgGetSubnetMask_0.status <> 65535 THEN
				Ipcfg.Plc.IPSubnetMaskVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Plc.IPSubnetMaskString)));
				Ipcfg.State := 42;
			END_IF
		
	42:	// Get Current Default Gateway From Panel
			CfgGetDefaultGateway_0(enable := 1, pDevice := ADR(g_Core.System.Configuration.userEthernetIF), pGateway := ADR(Ipcfg.Plc.IPDefaultGatewayString), Len := SIZEOF(Ipcfg.Plc.IPDefaultGatewayString));
			IF CfgGetDefaultGateway_0.status <> 65535 THEN
				Ipcfg.Plc.IPDefaultGatewayVal := N_TO_HUDINT(inet_addr(ADR(Ipcfg.Plc.IPDefaultGatewayString)));
				Ipcfg.State := 43;
			END_IF

	43:	// Get Current Ina Node From Panel
			Ipcfg.HMI.Node := g_Core.System.Runtime.nodeID;
			Ipcfg.State := 50;
			
	50:	// Convert Settings to HMI
			FOR Cnt := 0 TO 3 DO
				pTemp := inet_addr(ADR(Ipcfg.Plc.IPAddressString));
				dTempUSINT ACCESS(ADR(pTemp) + Cnt);
				Ipcfg.HMI.IPAddress[Cnt] := dTempUSINT;
				pTemp := inet_addr(ADR(Ipcfg.Plc.IPSubnetMaskString));
				dTempUSINT ACCESS(ADR(pTemp) + Cnt);
				Ipcfg.HMI.IPSubnetMask[Cnt] := dTempUSINT;
				pTemp := inet_addr(ADR(Ipcfg.Plc.IPDefaultGatewayString));
				dTempUSINT ACCESS(ADR(pTemp) + Cnt);
				Ipcfg.HMI.IPDefaultGateway[Cnt] := dTempUSINT;
				Ipcfg.HMI.IPAddressPing[Cnt] := Ipcfg.HMI.IPAddress[Cnt];
			END_FOR
			Ipcfg.State := 99;

	//------------------------------------------------------------------------------------------
	// Ping
	//------------------------------------------------------------------------------------------
	70:	// Check if IP within Range
			dTempUDINT ACCESS ADR(Ipcfg.HMI.IPAddressPing[0]);
			IF(H_TO_NUDINT(dTempUDINT) < Ipcfg.Range.IPDefaultGatewayMinVal) OR (H_TO_NUDINT(dTempUDINT) > Ipcfg.Range.IPDefaultGatewayMaxVal) THEN
				Ipcfg.State := 50;
			ELSE
				Ipcfg.State := 71;
			END_IF
			
	71:	// Ping IP Address
			// Convert ping IP into a string
			memset(ADR(PingIpString),0,SIZEOF(PingIpString));
			FOR SegmentNo := 0 TO 3 DO
				itoa(Ipcfg.HMI.IPAddressPing[SegmentNo],ADR(tempSegment));
				strcat(ADR(PingIpString),ADR(tempSegment));
				IF SegmentNo <> 3 THEN
					strcat(ADR(PingIpString),ADR('.'));
				END_IF
			END_FOR
		
			ICMPping_0(enable := 1, pHost := ADR(PingIpString), timeout := 1000);
			TON_PINGTimeOut(IN := 1, PT := ICMPping_0.timeout);
			Ipcfg.HMI.PingBar := UDINT_TO_USINT(TON_PINGTimeOut.ET / 10);
			IF ICMPping_0.status = 65535 THEN
				Ipcfg.HMI.PingColour := 15;
			ELSE
				IF ICMPping_0.status = 0 THEN
					Ipcfg.HMI.PingColour := 10;
				ELSE
					Ipcfg.HMI.PingColour := 45;
				END_IF				
				Ipcfg.State := 72;
			END_IF				
			TON_PINGResetColor(IN := 0);
							
	72:	// Reset ping bar
			Ipcfg.HMI.PingBar := 0;
			TON_PINGResetColor(IN := 1, PT := 300);
			IF TON_PINGResetColor.Q THEN
				Ipcfg.HMI.PingColour := 15;
				Ipcfg.State := 100;			
			END_IF			
			TON_PINGTimeOut(IN := 0);
			
	//------------------------------------------------------------------------------------------
	// Status
	//------------------------------------------------------------------------------------------
	99:	// Status
			IF (Ipcfg.ChangeStatus = CHANGEGOOD) OR (Ipcfg.ChangeStatus = CHANGEILLEGAL) THEN				
				g_Core.Services.System.Runtime.file.IPAddressPLC := Ipcfg.Plc.IPAddressString;
				g_Core.Services.System.Runtime.file.IPDefaultGatewayPLC := Ipcfg.Plc.IPDefaultGatewayString;
				g_Core.Services.System.Interface.isCmdSave := 1;
			END_IF
			IF (Ipcfg.ChangeStatus = CHANGEGOOD) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = IPCONFPAGE) THEN				
				Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 20, 25); // Good
			END_IF
			IF ((Ipcfg.ChangeStatus = CHANGEWRONG) OR (Ipcfg.ChangeStatus = CHANGEILLEGAL)) AND (g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = IPCONFPAGE) THEN				
		  		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, 21, 25); // Wrong
			END_IF
			Ipcfg.State := 100;		
										
	//------------------------------------------------------------------------------------------
	// Finish, wait for new command
	//------------------------------------------------------------------------------------------
  100:	// Wait for Command
	  		IF (Ipcfg.ButtonSetIP = 1) THEN
				dTempUDINT ACCESS ADR(Ipcfg.HMI.IPAddress[0]);
				inet_ntoa_b(dTempUDINT,  ADR(Ipcfg.Change.IPAddressString));
				dTempUDINT ACCESS ADR(Ipcfg.HMI.IPDefaultGateway[0]);
				inet_ntoa_b(dTempUDINT,  ADR(Ipcfg.Change.IPDefaultGatewayString));
				Ipcfg.State := 0;
	  		ELSIF (Ipcfg.ChangeStatus = CHANGEINIT) THEN
				Ipcfg.ChangeStatus := CHANGENOTHING;
				Ipcfg.State := 0;
			END_IF
	  		IF Ipcfg.ButtonTestIP = 1 THEN
				Ipcfg.State := 70;
			END_IF		
END_CASE

// No commands outside wait state
IF Ipcfg.State <> 100 THEN
	Ipcfg.ButtonSetIP := 0;
	Ipcfg.ButtonTestIP := 0;
END_IF			

END_PROGRAM