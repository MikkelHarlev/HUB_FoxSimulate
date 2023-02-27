
PROGRAM _INIT
	(* Insert code here *)
	runOnce := TRUE;
	updateTime  := 6000;
	// Setup the IOT logger	
	IOTLogger_0.adrIOTLogIdent 		:= gAdrIOTLogIdent;
	IOTLogger_0.IOTStructName 		:= 'IOTTwinV2:meta';
	IOTLogger_0.event.publish.type 	:= 1;
	IOTLogger_0.eventType 			:= 'assetData';
	IOTLogger_0.version 			:= 'A';

	IOTLoggerSimple_0.adrIOTLogIdent := gAdrIOTLogIdent;
	
END_PROGRAM

PROGRAM _CYCLIC
	
	// Get info.
	CASE getInfo OF
		0:
			isGetInfo := 1;
			CfgGetIPAddr_0.enable := 1;
			CfgGetIPAddr_0.Len := SIZEOF(meta.ipAddress);
			CfgGetIPAddr_0.pDevice := ADR(g_Core.System.Configuration.userEthernetIF);
			CfgGetIPAddr_0.pIPAddr := ADR(meta.ipAddress); 
			CfgGetIPAddr_0();
			IF CfgGetIPAddr_0.status = 0 THEN
				getInfo := 1;
			END_IF
		1:
			CfgGetDefaultGateway_0.enable := 1;
			CfgGetDefaultGateway_0.Len := SIZEOF(meta.gatewayAddress);
			CfgGetDefaultGateway_0.pDevice := ADR(g_Core.System.Configuration.userEthernetIF);
			CfgGetDefaultGateway_0.pGateway := ADR(meta.gatewayAddress); 
			CfgGetDefaultGateway_0();
			IF CfgGetDefaultGateway_0.status = 0 THEN
				getInfo := 2;
			END_IF
		2:
			CfgGetSubnetMask_0.enable := 1;
			CfgGetSubnetMask_0.Len := SIZEOF(meta.subnetMask);
			CfgGetSubnetMask_0.pDevice := ADR(g_Core.System.Configuration.userEthernetIF);
			CfgGetSubnetMask_0.pSubnetMask := ADR(meta.subnetMask); 
			CfgGetSubnetMask_0();
			IF CfgGetSubnetMask_0.status = 0 THEN
				getInfo := 3;
			END_IF
		3:
			
			CfgGetMacAddr_0.enable := 1;
			CfgGetMacAddr_0.Len := SIZEOF(macAddress);
			CfgGetMacAddr_0.pDevice := ADR(g_Core.System.Configuration.userEthernetIF);
			CfgGetMacAddr_0.pMacAddr := ADR(macAddress); 
			CfgGetMacAddr_0();
			IF CfgGetMacAddr_0.status = 0 THEN
				tagIDtoString(ADR(meta.macAddress),ADR(macAddress),6);
				getInfo := 4;
			END_IF
		4:
			CfgGetDnsAddress_0.enable := 1;
			CfgGetDnsAddress_0.Len1 := SIZEOF(meta.dnsAddress1);
			CfgGetDnsAddress_0.pDnsAddr1 := ADR(meta.dnsAddress1);
			CfgGetDnsAddress_0.Len2 := SIZEOF(meta.dnsAddress2);
			CfgGetDnsAddress_0.pDnsAddr2 := ADR(meta.dnsAddress2);
			CfgGetDnsAddress_0.Len3 := SIZEOF(meta.dnsAddress3);
			CfgGetDnsAddress_0.pDnsAddr3 := ADR(meta.dnsAddress3);
			CfgGetDnsAddress_0();
			IF CfgGetDnsAddress_0.status = 0 THEN
				getInfo := 5;
				isGetInfo := 0;
			END_IF
	END_CASE
	
	TON_0.PT := updateTime * 100;
	TON_0.IN := NOT TON_0.Q;
	TON_0();
	
	meta.machineType		:= g_Core.System.Configuration.SystemDescription.MachineType;
	meta.softwareVersion	:= g_Core.System.Configuration.SystemDescription.ProgramVersion;
	meta.productionHours 	:= g_Core.System.Runtime.operatingHours;
	meta.uptimeHours 		:= REAL_TO_DINT(brmfloor(TIME_TO_UDINT( clock_ms()) / 1000 /60 / 60));
	meta.totalUptimeHours 	:= g_Core.System.Runtime.powerOnHours;
	meta.totalCount 		:= ((g_Core.System.Runtime.totalCounter*1000) + g_Core.System.Runtime.totalCounterSmall);

	IF (runOnce AND isGetInfo = 0) OR TON_0.Q THEN
		runOnce := FALSE;
		IOTLogger_0.timeStamp := g_Core.Services.Time.Runtime.ISO;
		IOTLogger_0();
		lastTwinUpdate := g_Core.Services.Time.Runtime.Date_Time;
	END_IF
	
	CASE sendMetaData OF
		0:
			IF (g_Core.System.Runtime.isInitDone) THEN
				oldSaveCount := g_Core.Services.Recipe.Runtime.saveCount;
				json := '"processCodes":[';
				FOR i := 0 TO 98 DO
					IF strlen(ADR(g_RCfg[i].Name)) > 0 THEN
						strcat(ADR(json), ADR('{ "id":'));
						itoa(i+1, ADR(tmpString));
						strcat(ADR(json), ADR(tmpString));
						strcat(ADR(json), ADR(', "name":"'));
						strcat(ADR(json), ADR(g_RCfg[i].Name));
						strcat(ADR(json), ADR('"},'));
					END_IF
				strLen := strlen(ADR(json));
				END_FOR
				
				memset((ADR(json) + (strlen(ADR(json)) - 1)),0,1);
				strcat(ADR(json), ADR(']'));
				sendMetaData := 1;
			END_IF
			
		1:
			IOTLoggerSimple_0.event.publish.type	:= 1;
			IOTLoggerSimple_0.timeStamp 			:= g_Core.Services.Time.Runtime.ISO;
			IOTLoggerSimple_0.json 					:= json;
			IOTLoggerSimple_0.eventType 			:= 'metaData';
			IOTLoggerSimple_0.version 				:= 'A';	
			IOTLoggerSimple_0();
			sendMetaData := 2;
		
		2:
			IF (g_Core.Services.Recipe.Runtime.saveCount > oldSaveCount) THEN
				oldSaveCount := g_Core.Services.Recipe.Runtime.saveCount;
				sendMetaData := 0;
			END_IF
	END_CASE
	
	
END_PROGRAM

PROGRAM _EXIT
		(* Insert code here *)
	 
END_PROGRAM

