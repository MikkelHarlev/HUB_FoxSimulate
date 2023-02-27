PROGRAM _CYCLIC
	(*Run Server FUB*)
	IF NOT disable THEN
		Server();

		IF (g_Core.Services.Blackbox.Runtime.server.Status = 0) THEN
		(*Reset Trigger Software alarm - setup failure*)
		(*g_MachineAlarm.Alarm.Trigger[4] := FALSE;*)
		
		(*Start server runtime is XML Com is setup*)
		g_Core.Services.Blackbox.Runtime.server.XMLRPCServerStarted := g_Core.Services.Communication.XMLRPCServer.Runtime.isServerStarted;
	
		(*Get Operating hours from MachineInfo*)
		IF AdrMachineInfo = 0 THEN
			GetAdr(ADR(AdrMachineInfo), ADR('pancfg:MachineInfo'));
			IF AdrMachineInfo > 0 THEN
				pMachineInfo ACCESS AdrMachineInfo;
				OperatingHours ACCESS ADR(pMachineInfo.OperatingHours);
			END_IF
		END_IF
	
		// Get data from CAR.
		IF (g_Core.Services.Blackbox.Configuration.Master.Enabled) THEN
			FOR i := 0 TO (g_Core.Services.Blackbox.Configuration.Master.ProductionUnits - 1) DO
				// Copy single PUs info to all PUs if not multircp! 
				IF g_Core.Services.Blackbox.Configuration.Master.MultiRcp THEN
					x := i;
				ELSE
					x := 0;
				END_IF
				g_Core.Services.Blackbox.Runtime.Master.ArtNo[i]					:= g_Core.Services.CAR.Runtime.No[x].ArticleNumber;
				g_Core.Services.Blackbox.Runtime.Master.ArtText[i]					:= g_Core.Services.CAR.Runtime.No[x].ArticleName;
				g_Core.Services.Blackbox.Runtime.Master.CustNo[i]					:= g_Core.Services.CAR.Runtime.No[x].CustomerNumber;
				g_Core.Services.Blackbox.Runtime.Master.CustText[i]					:= g_Core.Services.CAR.Runtime.No[x].CustomerName;
				//if the no flow in the Custart file is set to 0 then it is turned off - ET Special !!!
				IF (g_Core.Services.CAR.Runtime.No[x].FlowTimeout = 0) THEN
					g_Core.Services.Blackbox.Runtime.Master.FlowTimeOut[i] := 30000;
				ELSE
					g_Core.Services.Blackbox.Runtime.Master.FlowTimeOut[i]				:= g_Core.Services.CAR.Runtime.No[x].FlowTimeout;
				END_IF
				g_Core.Services.Blackbox.Runtime.Master.LoadID[i]					:= g_Core.Services.CAR.Runtime.No[x].LoadID;
				g_Core.Services.Blackbox.Runtime.Master.Primary[i]					:= g_Core.Services.CAR.Runtime.No[x].Primary;
				g_Core.Services.Blackbox.Runtime.Master.RcpNo[i]					:= g_Core.Services.CAR.Runtime.No[x].RecipeNumber - 1;
				g_Core.Services.Blackbox.Runtime.Master.RcpText[i]					:= g_Core.Services.CAR.Runtime.No[x].RecipeName;
				g_Core.Services.Blackbox.Runtime.Master.Norm[i]						:= g_Core.Services.CAR.Runtime.No[x].Norm;
				g_Core.Services.Blackbox.Runtime.Master.Reference[i]				:= g_Core.Services.CAR.Runtime.No[x].Reference;
			END_FOR
		END_IF
		
		
		FOR i := 0 TO 1 DO
		(*Data loggers runtime*)
		CASE i OF
			0:
				RuntimeHolder				:= g_Core.Services.Blackbox.Runtime.Master;
				InterfaceHolder				:= g_Core.Services.Blackbox.Interface.Master;
			1:
				RuntimeHolder				:= g_Core.Services.Blackbox.Runtime.Slave;
				InterfaceHolder				:= g_Core.Services.Blackbox.Interface.Slave;
			
		END_CASE
	
		FOR No := 0 TO (SIZEOF(RuntimeHolder.LoadID)/SIZEOF(RuntimeHolder.LoadID[0])) - 1 DO
			MachineData[i].LoadID[No]		:= RuntimeHolder.LoadID[No];
			MachineData[i].RcpNo[No] 		:= RuntimeHolder.RcpNo[No];
			MachineData[i].RcpText[No] 		:= RuntimeHolder.RcpText[No];
			MachineData[i].ArtNo[No] 		:= RuntimeHolder.ArtNo[No];
			MachineData[i].ArtText[No] 		:= RuntimeHolder.ArtText[No];
			MachineData[i].CustNo[No] 		:= RuntimeHolder.CustNo[No];
			MachineData[i].CustText[No] 	:= RuntimeHolder.CustText[No];
			RuntimeHolder.ActiveProductionUnits[No] := InterfaceHolder.ActiveProductionUnits[No];
			MachineData[i].Active[No]		:= RuntimeHolder.ActiveProductionUnits[No];
			MachineData[i].Norm[No]			:= RuntimeHolder.Norm[No];
			MachineData[i].FlowTimeOut[No] 	:= RuntimeHolder.FlowTimeOut[No];
			MachineData[i].Primary[No]		:= RuntimeHolder.Primary[No];
			MachineData[i].Reference[No] 	:= RuntimeHolder.Reference[No];
		END_FOR
	
	    IF AdrMachineInfo > 0 THEN
		    MachineData[i].OperatingHours	:= OperatingHours;
		END_IF
		MachineData[i].OperatorLogDelay 	:= RuntimeHolder.OperatorLogDelay;
		MachineData[i].Status 				:= (g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000) + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID;
		MachineData[i].StatusString 		:= g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
		END_FOR
		ELSE
		;
		(*Trigger Software alarm - setup failure*)
		(*g_MachineAlarm.Alarm.Trigger[4] := TRUE;*) 
		END_IF
	END_IF
END_PROGRAM

