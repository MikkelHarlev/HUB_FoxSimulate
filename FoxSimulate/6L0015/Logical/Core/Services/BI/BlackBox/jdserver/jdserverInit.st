PROGRAM _INIT
	Dummy;
	IF g_Core.Services.Blackbox.Runtime.initState = RUNTIME OR g_Core.Services.Blackbox.Runtime.initState = ERROR THEN
		disable := TRUE;
		RETURN;
	END_IF
	Server.isSQLEnabled 	:= g_Core.Services.Blackbox.Configuration.mode = BLACKBOX_SQL;
	Server.isXMLRPCEnabled 	:= g_Core.Services.Blackbox.Configuration.mode = BLACKBOX_XMLRPC;
	g_Core.Services.Blackbox.Runtime.initState := NA;
	IF g_Core.Services.Blackbox.Configuration.Master.Enabled THEN
		JenDataSetup[0].Type := MASTER_1;
	END_IF
	IF g_Core.Services.Blackbox.Configuration.Slave.Enabled THEN
		JenDataSetup[1].Type := SLAVE_2;
	END_IF
	
	FOR i := 0 TO 1 DO
		IF (JenDataSetup[i].Type > 0) THEN
			
			JenDataSetup[i].AlarmIgnoreList[0]	:= 201; (*Don't log In Operation*)
			JenDataSetup[i].AlarmIgnoreList[1]	:= 202;	(*Don't log Ready to Start*)
			JenDataSetup[i].AlarmIgnoreList[2]	:= 203; (*Power save???*)
			JenDataSetup[i].AlarmIgnoreList[3]	:= 200;
			
			CASE JenDataSetup[i].Type OF
				MASTER_1:
					SetupHolder := g_Core.Services.Blackbox.Configuration.Master;
					JenDataSetup[i].RunTimeDataEntry	:= 'jdserver:MachineData[0]'; (*Name of runtime variable*)
				SLAVE_2:
					SetupHolder := g_Core.Services.Blackbox.Configuration.Slave;
					JenDataSetup[i].RunTimeDataEntry	:= 'jdserver:MachineData[1]'; (*Name of runtime variable*)
			END_CASE
			
			JenDataSetup[i].Init 				:= TRUE;
			JenDataSetup[i].PulseLogInterval 	:= 300;
			JenDataSetup[i].RunningStatus 		:= 'g_Core.System.Runtime.isStatisticsRunning';
			JenDataSetup[i].EmergencyStatus 	:= 'g_Core.System.Runtime.isEStopActivated';
	
			FOR No := 0 TO 9 DO
				JenDataSetup[i].LogTaskName[No]			:= SetupHolder.LogTaskName[No];
			END_FOR
			JenDataSetup[i].NoFlowTimeOut				:= 30000; (*Default flow timeout if none is set*)
			IF strlen(ADR(SetupHolder.CounterName)) > 0 THEN
				JenDataSetup[i].CounterVarName 			:= SetupHolder.CounterName;				
			ELSE
				JenDataSetup[i].CounterVarName 			:= 'jdserver:Dummy'; (*Init pulse logger*)
			END_IF
			JenDataSetup[i].ProductionUnits				:= SetupHolder.ProductionUnits;
			JenDataSetup[i].Attendants 					:= SetupHolder.Attendants;
			IF SetupHolder.MultiRcp THEN
				FOR No := 0 TO SetupHolder.ProductionUnits DO
					JenDataSetup[i].SingeLaneOp[No]		:= TRUE;
				END_FOR
			ELSE	
				JenDataSetup[i].SingeLaneOp[0] 				:= TRUE;
			END_IF
			JenDataSetup[i].DisableOperatorLog 			:= NOT SetupHolder.LogOperators;
			JenDataSetup[i].MachineName 				:= SetupHolder.MachineType;
			JenDataSetup[i].ChangeDelay					:= SetupHolder.ChangeDelay;(*700;*)
			// All slaves are take off stations?.. It really only disables some realtime features.
			JenDataSetup[i].TakeoffStation				:= i = 1;
			(*AddOns*)
			FOR No := 0 TO 9 DO
				IF strlen(ADR(SetupHolder.AddOns[No].VarName)) > 0 THEN
					JenDataSetup[i].AddOn[No].AddOnName			:= SetupHolder.AddOns[No].AddOnName;
					JenDataSetup[i].AddOn[No].DividerValue		:= SetupHolder.AddOns[No].DividerValue;
					JenDataSetup[i].AddOn[No].Limiter			:= SetupHolder.AddOns[No].Limiter;
					JenDataSetup[i].AddOn[No].Log				:= TRUE; //ALWAYS TRUE!!!
					JenDataSetup[i].AddOn[No].MaxValue			:= SetupHolder.AddOns[No].MaxValue;
					JenDataSetup[i].AddOn[No].MinValue			:= SetupHolder.AddOns[No].MinValue;
					JenDataSetup[i].AddOn[No].Mode				:= SetupHolder.AddOns[No].Mode;
					JenDataSetup[i].AddOn[No].MultiplierValue	:= SetupHolder.AddOns[No].MultiplierValue;
					JenDataSetup[i].AddOn[No].TimeOut			:= SetupHolder.AddOns[No].TimeOut;
					JenDataSetup[i].AddOn[No].Type				:= SetupHolder.AddOns[No].Type;
					JenDataSetup[i].AddOn[No].ValueID			:= SetupHolder.AddOns[No].SubRegTypeID;
					JenDataSetup[i].AddOn[No].VarName			:= SetupHolder.AddOns[No].VarName;
					JenDataSetup[i].AddOn[No].RegType			:= SetupHolder.AddOns[No].RegType;
					JenDataSetup[i].AddOn[No].SubRegType		:= SetupHolder.AddOns[No].SubRegType;
					JenDataSetup[i].AddOn[No].SubRegTypeID		:= SetupHolder.AddOns[No].SubRegTypeID;
					JenDataSetup[i].AddOn[No].MessageA			:= SetupHolder.AddOns[No].MessageA;
					JenDataSetup[i].AddOn[No].MessageB			:= SetupHolder.AddOns[No].MessageB;
					JenDataSetup[i].AddOn[No].Unit				:= SetupHolder.AddOns[No].Unit;
					
				END_IF
			END_FOR
		END_IF
	END_FOR
	
	g_Core.Services.Blackbox.Runtime.server.Internal.AdrLoggerSetup := ADR(JenDataSetup);
	RInit := TRUE;
	Server(InterfaceIdent := ADR(g_Core.Services.Blackbox.Runtime.server));
	g_Core.Services.Blackbox.Runtime.initState := INIT;
	// Check if it works here!
//	RegisterJenFunctions(g_Core.Services.Communication.XMLRPCServer.Runtime.serverStatus, rpc2dCBGet());

END_PROGRAM

