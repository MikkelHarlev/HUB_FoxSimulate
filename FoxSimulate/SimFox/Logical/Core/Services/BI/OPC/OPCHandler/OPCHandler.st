PROGRAM _INIT
	(* init program *)
	Init := TRUE;
END_PROGRAM   

PROGRAM _CYCLIC
	(* cyclic program *)
	IF NOT g_Core.System.Runtime.isInitDone THEN		(* Exit until System is Initialized *)
		RETURN;
	END_IF
	(* Generel Information - Standart for all Jensen Denmark V4 Platforms *)
	
	(* Init Parameters *)
	IF Init THEN
		OPCData.MachineNumber	:= g_Core.System.Configuration.SystemDescription.MachineNumber;	(* Machine Number *)
		OPCData.MachineID 		:= g_Core.System.Configuration.machineType * 1000;				(* Setting correct format *)
		MasterPUs 				:= GetData(ServerNo := 1, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
		SlavePUs 				:= GetData(ServerNo := 2, Type:= NUMBER_OF_LANES, Lane:= 1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
	
		(* Machine Specific*)
		CASE g_Core.System.Configuration.machineType OF									(* Set SubID by Machine Type*)
			1,4: (* Standart Machine ID *)
				OPCData.MachineID := OPCData.MachineID + 1;
			2,3: (* Rail and Feeder Stations *)
				OPCData.MachineID := OPCData.MachineID + UDINT_TO_UINT(MasterPUs);
			5:	(*Get Lanenumbers for a folder*)
				OPCData.MachineID := OPCData.MachineID + g_Core.Services.Blackbox.Configuration.Master.ProductionUnits;
				IF g_Core.Services.Blackbox.Runtime.server.ServersRunning > 1 THEN
					OPCData.MachineID := OPCData.MachineID + (UDINT_TO_UINT(SlavePUs) * 100);
				END_IF
		END_CASE
		Init := FALSE;
	END_IF
	
	(* RunTime Parameters *)
	OPCData.Started			:= g_Core.System.Runtime.isRunning;			(* Started *)
	OPCData.EmergencyStop	:= NOT g_Core.System.Runtime.isEStopActivated;		(* Emergency *)
	
	OPCData.CustomerNumber	:= UDINT_TO_UINT(g_Core.Services.CAR.Runtime.No[0].CustomerNumber);	(* Customer *)
	OPCData.ArtricleNumber	:= UDINT_TO_UINT(g_Core.Services.CAR.Runtime.No[0].ArticleNumber);  (* Article *)
	OPCData.RecipeNumber    := g_Core.Services.CAR.Runtime.No[0].RecipeNumber;				(* Recipe *)
	
	(* Machine Specific*)
	
	(* Error Numbers *)
	CASE g_Core.System.Configuration.machineType OF
		1,2,3:
			IF (g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000 + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID > 0) THEN
				ErrorNumber := 255; (* Internal Error *)
			ELSE
				ErrorNumber := 0; (* No Error *)
			END_IF
		4:
			CASE g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000 + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID OF
				0:		ErrorNumber := 0;	(*No Error*)
				2043:	ErrorNumber := 1;	(* Steam Missing - TODO *)
				2044:	ErrorNumber := 2;	(* Air Missing - TODO *)
				ELSE
						ErrorNumber := 255; (* Internal Error *)
			END_CASE
		5:
			CASE g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000 + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID OF
				0:		ErrorNumber := 0;	(*No Error*)
				2043:	ErrorNumber := 1;	(* Jam Lengthfold *)
				2044:	ErrorNumber := 2;	(* Jam Crossfold *)
				2045:	ErrorNumber := 3;	(* Jam Stacker *)
				ELSE
						ErrorNumber := 255; (* Internal Error *)
			END_CASE
	END_CASE
	OPCData.ErrorNumber		:= ErrorNumber;				(* Error *)
	
	IF EDGEPOS(OPCData.ResetCounters) THEN
		memset(ADR(OPCData.Counter),0,SIZEOF(OPCData.Counter)); (* Reset Counters *)
		memset(ADR(LocalCounter),0,SIZEOF(LocalCounter));
	END_IF
	IF (NOT OPCData.ResetCounters) THEN
		OPCData.Counter := LocalCounter;
	END_IF
	
	(* Generel Production Counters *)
	FOR No := 0 TO 5 DO
		IF ((LocalLogData[0].Production[No] <> g_PermLogData[0].Production[No]) AND g_PermLogData[0].Production[No] > 0) THEN (* Counter 1 - PU 1 *)
			LocalCounter[No] := LocalCounter[No] + 1;
		END_IF
	
		(* Generel Sorting Counters 7 - 8 *)
		IF ((LocalLogData[0].SortA[No] <> g_PermLogData[0].SortA[No]) AND g_PermLogData[0].SortA[No] > 0) THEN (* Counter 7 - Rewash *)
			LocalCounter[6] := LocalCounter[6] + 1;
		END_IF
		IF ((LocalLogData[0].SortB[No] <> g_PermLogData[0].SortB[No]) AND g_PermLogData[0].SortB[No] > 0) THEN (* Counter 8 - Repair *)
			LocalCounter[7] := LocalCounter[7] + 1;
		END_IF
	
	END_FOR
	(*Generel Master Production*)
	
	LocalCounter[14] := LocalCounter[0] + LocalCounter[1] + LocalCounter[2] + LocalCounter[3] + LocalCounter[4] + LocalCounter[5]; (* Counter 15 - Total Master *)
	
	(*Machine Specific Counters *)
	CASE g_Core.System.Configuration.machineType OF
		3:
			FOR No := 0 TO 5 DO
				IF ((LocalLogData[0].Drop[No] <> g_PermLogData[0].Drop[No]) AND g_PermLogData[0].Drop[No] > 0) THEN (* Counter 9 - Feeder Drop *)
					LocalCounter[8] := LocalCounter[8] + 1;
				END_IF
			END_FOR
			// Disabled as i do not know the state of this OPC interface!!!
			//IF (g_RStCount[3]) THEN
			//	g_RStCount[3] := FALSE;
			//	LocalCounter[15] := LocalCounter[15] + 1;
			//END_IF
	
		5:
			FOR No := 0 TO 5 DO
				IF ((LocalLogData[0].Quality[No] <> g_PermLogData[0].Quality[No]) AND g_PermLogData[0].Quality[No] > 0) THEN (* Counter 9 - Folder Quality *)
					LocalCounter[8] := LocalCounter[8] + 1;
				END_IF
			END_FOR
				
			IF ((LocalLogData[1].Production[0] <> g_PermLogData[1].Production[0]) AND g_PermLogData[1].Production[0] > 0) THEN (* Counter 11 - Slave PU 1 *)
				LocalCounter[10] := LocalCounter[10] + 1;
			END_IF
			IF ((LocalLogData[1].Production[1] <> g_PermLogData[1].Production[1]) AND g_PermLogData[1].Production[1] > 0) THEN (* Counter 12 - Slave PU 2 *)
				LocalCounter[11] := LocalCounter[11] + 1;
			END_IF
			IF ((LocalLogData[1].Production[2] <> g_PermLogData[1].Production[2]) AND g_PermLogData[1].Production[2] > 0) THEN (* Counter 13 - Slave PU 3 *)
				LocalCounter[12] := LocalCounter[12] + 1;
			END_IF
			IF ((LocalLogData[1].Production[3] <> g_PermLogData[1].Production[3]) AND g_PermLogData[1].Production[3] > 0) THEN (* Counter 14 - Slave PU 4 *)
				LocalCounter[13] := LocalCounter[13] + 1;
			END_IF
			LocalCounter[15] := LocalCounter[10] + LocalCounter[11] + LocalCounter[12] + LocalCounter[13]; (* Counter 16 - Total Slave *)
	END_CASE
	
	(* Update local copy of Production Data from Perm Repository*)
	LocalLogData[0]	:= g_PermLogData[0];
	LocalLogData[1]	:= g_PermLogData[1];
END_PROGRAM

