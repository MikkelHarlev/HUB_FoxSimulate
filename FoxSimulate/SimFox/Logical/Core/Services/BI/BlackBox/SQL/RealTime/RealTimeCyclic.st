(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: RealTime
 * File: RealTimeCyclic.st
 * Author: fuglsah
 * Created: November 10, 2014
 ********************************************************************
 * Implementation of program RealTime
 ********************************************************************)
PROGRAM _INIT
	RealTimeState													:= 1;
END_PROGRAM


PROGRAM _CYCLIC
	// We need the first Cust/Art right when the machine has init done.
	IF EDGEPOS(g_Core.System.Runtime.isInitDone AND g_Core.Services.Blackbox.Configuration.Master.ProductionUnits > 0) THEN
		FOR No := 0 TO g_Core.Services.Blackbox.Runtime.server.ServersRunning DO
			//FYFY Henrik ;)
			OldCustNo[No] 		:= GetData(ServerNo := 1, Type:= CUSTOMER_NUMBER, 	Lane:= No+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));;
			OldArticleNo[No]	:= GetData(ServerNo := 1, Type:= ARTICLE_NUMBER, 	Lane:= No+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
		END_FOR
	END_IF
	
	// Is Init Done for machine?
	IF NOT(g_Core.System.Runtime.isInitDone) THEN
		RETURN;
	END_IF
	
	// Is there a address for Communication Connection Logic for Cockpit?
	IF g_Core.Services.Communication.ConnectionLogic.Cockpit > 0 THEN
		// Access it
		pCockpit ACCESS g_Core.Services.Communication.ConnectionLogic.Cockpit;
	ELSE 
		// Return!
		RETURN;
	END_IF	

	// Only Run if a Cockpit Connection is enabled
	IF (pCockpit.Runtime.initState <> RUNTIME) OR (pCockpit.Runtime.isReady = FALSE) THEN
		// No Connection, so return!
		RETURN;
	END_IF

	CASE InitState OF
		INIT:
			IF (pCockpit.Runtime.isReady) THEN
				// Setup the SQL Info
				// Prepare for DB connection 
				SqlInfo.debugLevel			:= 0;
				SqlInfo.IPString			:= pCockpit.Runtime.SQLServerAddress;
				SqlInfo.UserName			:= pCockpit.Runtime.SQLUsername;
				SqlInfo.Password			:= pCockpit.Runtime.SQLPassword;
				SqlInfo.DbName 				:= pCockpit.Runtime.SQLDBName;
				SqlInfo.TableName			:= 'tblMachineStatus';
				SqlInfo.VariableStructName	:= 'Setup';
				//SqlInfo.SP_CreateName									:= 'JenLogCreate ';
				SqlInfo.SP_InsertName		:= 'spRTUpdateMachineStatus ';
				SqlInfo.FullRecordName		:= 'RealTime:RealTimeData.Setup';
			
				TmpSpace := ', ';
				TmpEnd	 := ';';
				TmpApostrof := 39;
			
				analysinfo := JenSqlInit(ADR(SqlInfo));
			
				RumtimeState	:= 255;
				InitState		:= RUNTIME;
			END_IF
			
		RUNTIME:
			pCockpit.Interface.realtime.isInitDone					:= TRUE;
			
			
			// Watchdog 10 seconds!!!
			TON_Watchdog.PT := 1000;
			TON_Watchdog.IN := (SqlInfo.cmdDB <> 0);
			TON_Watchdog();

			// Run SQL Engine
			SqlStatus := JenSqlRun(ADR(SqlInfo));
			
			// Check if a connection as been made
			IF SqlInfo.Ident = 0 THEN
				RETURN;
			END_IF
			
			// Update Interval Timer set timer
			IF (pCockpit.Runtime.updateInterval = 0) THEN
				TOF_10ms_Sleep.PT									:= 1000;
			ELSE
				TOF_10ms_Sleep.PT									:= pCockpit.Runtime.updateInterval/10;
			END_IF
			
			// Update Interval Timer Run
			TOF_10ms_Sleep();
			TOF_10ms_Sleep.IN										:= FALSE;

			// State Machine Case
			// RUMTIME, ALLREADY?
			CASE RumtimeState OF
				// Reconnect
				200:
					RumtimeState 	:= 255;
					SqlInfo.cmdDB 	:= 2;
					RumtimeState	:= 255;
					
				255:
					pCockpit.Interface.realtime.isBusy := FALSE;
					// Check if SQL Connection is running.
					IF (SqlInfo.ConnectState = 2) THEN
						RumtimeState := 0;
					END_IF
				
				// State: Waiting timer to signal a update, and then pred data for SQL Engine
				0:	
					// Set Status						
					IF g_Core.System.Runtime.isRunning THEN
						IF g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0 THEN
							// Running and error
							Status := 3; 
						ELSE
							// Running
			    			Status := 2;
						END_IF
					ELSE
						IF g_Core.Services.Alarmhandler.Runtime.Event[0].Status > 0 THEN
			   	 		//Stopped and error, unable to run?
							Status := 3;
						ELSE
							// Ready to Start.
							Status := 1; 
						END_IF
					END_IF
				
					IF NOT(TOF_10ms_Sleep.Q) OR oldStatus <> Status THEN
						// Reset Update Interval Timer
						TOF_10ms_Sleep.IN	:= TRUE;
						oldStatus 			:= Status;
						
						
						// Set Machine Infos
						RealTimeData.Setup.MachineID				:= pCockpit.Runtime.machineID;
						RealTimeData.Setup.Status					:= Status;
						RealTimeData.Setup.Piececount 				:= pCockpit.Runtime.totalCount;
						RealTimeData.Setup.OnTime 					:= pCockpit.Runtime.totalPowerOnHours;
						RealTimeData.Setup.RunTime					:= pCockpit.Runtime.totalRunHours;
						RealTimeData.Setup.ErrorID					:= (g_Core.Services.Alarmhandler.Runtime.Event[0].GroupID * 1000) + g_Core.Services.Alarmhandler.Runtime.Event[0].AlarmID;
						RealTimeData.Setup.ErrorString_Local		:= g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
						RealTimeData.Setup.ErrorString_GB			:= g_Core.Services.Alarmhandler.Runtime.Event[0].DescAscii;
						
						// Make Final SQL Qury String
						memset(ADR(SqlInfo.SQLString),0,SIZEOF(SqlInfo.SQLString));
						// First the Stored Procedure name
						strcpy(ADR(SqlInfo.SQLString), ADR('spRTUpdateMachineStatus '));
						
						// Move Data to Temp Strings
						itoa(RealTimeData.Setup.MachineID, ADR(TmpMachineID));
						itoa(RealTimeData.Setup.Status, ADR(TmpStatus));
						itoa(RealTimeData.Setup.Piececount, ADR(TmpPieceCount));
						itoa(RealTimeData.Setup.OnTime, ADR(TmpOnTime));								
						itoa(RealTimeData.Setup.RunTime, ADR(TmpRunTime));
						itoa(RealTimeData.Setup.ErrorID, ADR(TmpErrorID));
						
						// Now lets make magic happen!
						strcat(ADR(SqlInfo.SQLString), ADR(TmpMachineID));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
				
						strcat(ADR(SqlInfo.SQLString), ADR(TmpStatus));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
				
						strcat(ADR(SqlInfo.SQLString), ADR(TmpPieceCount));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));

						strcat(ADR(SqlInfo.SQLString), ADR(TmpOnTime));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));

						strcat(ADR(SqlInfo.SQLString), ADR(TmpRunTime));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
						
						strcat(ADR(SqlInfo.SQLString), ADR(TmpErrorID));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
						
						strcat(ADR(SqlInfo.SQLString), ADR(TmpApostrof));
						strcat(ADR(SqlInfo.SQLString), ADR(RealTimeData.Setup.ErrorString_Local));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpApostrof));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
						
						strcat(ADR(SqlInfo.SQLString), ADR(TmpApostrof));
						strcat(ADR(SqlInfo.SQLString), ADR(RealTimeData.Setup.ErrorString_GB));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpApostrof));
						strcat(ADR(SqlInfo.SQLString), ADR(TmpEnd));
						
						
				
						RumtimeState								:= 1;
					END_IF
					
				// State: Waiting for DB to be ready to Insert the data
				1:
					IF (SqlInfo.cmdDB = 0 AND NOT pCockpit.Interface.logData.isBusy) THEN
						pCockpit.Interface.realtime.isBusy := TRUE;
						// Ready
						SqlInfo.cmdDB								:= DB_SQL_ADD_5;
						pCockpit.Interface.realtime.sentCount		:= pCockpit.Interface.realtime.sentCount+1;
						RumtimeState								:= 2;
					END_IF
					
				// State: Waiting for DB to be ready to check insert
				2:
					IF (TON_Watchdog.Q) THEN
						// Reset state machine
						RumtimeState	:= 200;	
					END_IF
					
					IF (SqlInfo.cmdDB = 0) THEN
						//						SqlInfo.cmdDB								:= DB_GET_AFFEECTEDROWS_10;
						//						SqlInfo.AffectedRows						:= 0;
						RumtimeState								:= 4;
					END_IF
				
				// State: Waiting for DB to be ready so we can check how many rows it affeected
				3:
					IF (TON_Watchdog.Q) THEN
						// Reset state machine
						RumtimeState	:= 200;	
					END_IF
					IF (SqlInfo.cmdDB = 0) THEN
						IF (SqlInfo.AffectedRows = 0) THEN
							// It did not affected any rows! Something happened, try again!
							pCockpit.Interface.realtime.errorCount	:= pCockpit.Interface.realtime.errorCount+1;
							RumtimeState							:= 1;
						ELSE
							// Success!
							RumtimeState							:= 4;
						END_IF
					END_IF
				
				// State: Check if we have changed CAR
				4:
					FOR No := 0 TO g_Core.Services.Blackbox.Configuration.Master.ProductionUnits-1 DO
						RealCustNo[No] 		:= GetData(ServerNo := 1, Type:= CUSTOMER_NUMBER, 	Lane:= No+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));;
						RealArticleNo[No]	:= GetData(ServerNo := 1, Type:= ARTICLE_NUMBER, 	Lane:= No+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
						RealOperator[No]    := GetData(ServerNo := 1, Type:= OPERATOR_NUMBER, 	Lane:= No+1, Ident:= ADR(g_Core.Services.Blackbox.Runtime.server));
						IF (RealCustNo[No] <> OldCustNo[No]) OR (RealArticleNo[No] <> OldArticleNo[No]) OR (OldOperator[No] <> RealOperator[No]) THEN
							OldCustNo[No]			:= RealCustNo[No];
							OldArticleNo[No]		:= RealArticleNo[No];
							OldOperator[No]			:= RealOperator[No];
							ChangeCustArtForSubId	:= No+1;
							RumtimeState			:= 5;
							RETURN;
						END_IF
					END_FOR
					// No new Cust/Art, so we return :)
					RumtimeState										:= 255;
				
				// State: Prep data for Cust/Art
				5:
					// Set Machine Infos
					RealTimeData.SubIDPrep.MachineID				:= pCockpit.Runtime.machineID;
					RealTimeData.SubIDPrep.SubID					:= ChangeCustArtForSubId;
					RealTimeData.SubIDPrep.Operator					:= RealOperator[ChangeCustArtForSubId-1];
					RealTimeData.SubIDPrep.Customer					:= RealCustNo[ChangeCustArtForSubId-1];
					RealTimeData.SubIDPrep.Article					:= RealArticleNo[ChangeCustArtForSubId-1];

					// Make Final SQL String.
					memset(ADR(SqlInfo.SQLString),0,SIZEOF(SqlInfo.SQLString));
					// First the Stored Procedure name
					strcpy(ADR(SqlInfo.SQLString), ADR('spRTUpdateMachineSubID '));
					
					// Move data to Temp Strings
					itoa(RealTimeData.SubIDPrep.MachineID, ADR(TmpMachineID));
					itoa(RealTimeData.SubIDPrep.SubID, ADR(TmpSubID));
					itoa(RealTimeData.SubIDPrep.Operator, ADR(TmpOperator));
					itoa(RealTimeData.SubIDPrep.Customer, ADR(TmpCustomer));								
					itoa(RealTimeData.SubIDPrep.Article, ADR(TmpArticle));
					
					// Now lets make magic happen!
					strcat(ADR(SqlInfo.SQLString), ADR(TmpMachineID));
					strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
				
					strcat(ADR(SqlInfo.SQLString), ADR(TmpSubID));
					strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));
				
					strcat(ADR(SqlInfo.SQLString), ADR(TmpOperator));
					strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));

					strcat(ADR(SqlInfo.SQLString), ADR(TmpCustomer));
					strcat(ADR(SqlInfo.SQLString), ADR(TmpSpace));

					strcat(ADR(SqlInfo.SQLString), ADR(TmpArticle));
					strcat(ADR(SqlInfo.SQLString), ADR(TmpEnd));
					
					RumtimeState									:= 1;
			END_CASE
	END_CASE

	// Update Connection State
	IF SqlInfo.ConnectState > 0 THEN
		pCockpit.Interface.realtime.isConnected							:= TRUE;
	ELSE
		pCockpit.Interface.realtime.isConnected							:= FALSE;
	END_IF

END_PROGRAM