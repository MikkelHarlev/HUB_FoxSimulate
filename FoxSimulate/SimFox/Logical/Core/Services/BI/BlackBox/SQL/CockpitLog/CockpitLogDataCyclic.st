(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: CockpitLogData
 * File: CockpitLogDataCyclic.st
 * Author: duem
 * Created: November 12, 2014
 ********************************************************************
 * Implementation of program CockpitLogData
 ********************************************************************)
PROGRAM _INIT
	sqlTimeOut := 6000;
	
END_PROGRAM

PROGRAM _CYCLIC
	IF NOT(g_Core.System.Runtime.isInitDone) THEN
		RETURN;
	END_IF
	(* TODO : Add your code here *)
	CASE initState OF
		INIT:
			IF g_Core.Services.Communication.ConnectionLogic.Cockpit > 0 THEN
				pCockpit ACCESS g_Core.Services.Communication.ConnectionLogic.Cockpit;
			
				IF pCockpit.Runtime.initState = RUNTIME AND pCockpit.Runtime.SQLServerAddress <> '' THEN
					// CompanyID
					arrStaticData[0].parameterName := 'CompanyID';
					arrStaticData[0].parameterValue:= pCockpit.Runtime.companyID;
					arrStaticData[0].injectPosition := 1;
			
					// MachineID
					arrStaticData[1].parameterName := 'MachineID';
					arrStaticData[1].parameterValue:= UDINT_TO_INT(pCockpit.Runtime.machineID);
					arrStaticData[1].injectPosition := 2;
					
					// SubIDName
					// Add extra for slaves; stackers etc.
					arrStaticData[2].parameterName := 'SubIDName';
					arrStaticData[2].parameterText := pCockpit.Runtime.subIDName;		
					arrStaticData[2].injectPosition := 4;
					// Init state to setup all things that needs to be setup before going into runtime
					bufferIdents ACCESS g_Core.Services.Blackbox.Runtime.server.Internal.AdrArrIdentJenViewWideLogInit;
			
					LogRead_0.enable 			:= 1;
					LogRead_0.ident 			:= bufferIdents[0];
					LogSetLineRead_0.enable 	:= 1;
					LogSetLineRead_0.ident	 	:= bufferIdents[0];
					LogRead_0.startFirstEntry 	:= TRUE;
			
					SqlInfo.debugLevel			:= 0;
					SqlInfo.IPString			:= pCockpit.Runtime.SQLServerAddress;
					SqlInfo.UserName			:= pCockpit.Runtime.SQLUsername;
					SqlInfo.Password			:= pCockpit.Runtime.SQLPassword;
					SqlInfo.DbName 				:= 'JEGR_DB';
					SqlInfo.TableName			:= 'tblJGLogData';
					SqlInfo.VariableStructName	:= 'Event';
					//SqlInfo.SP_CreateName		:= 'JenLogCreate ';
					SqlInfo.SP_InsertName		:= 'spInsertLogData ';
					SqlInfo.FullRecordName		:= 'CockpitLog:LogRecord.Event';
					analysinfo 					:= JenSqlInit(ADR(SqlInfo));
			
					TOF_10ms_Sleep.PT										:= 100;
					
					SqlExporter												:= CHECK_CONNECTION_STATUS;
					initState												:= RUNTIME;
				END_IF
			END_IF
		RUNTIME:
		
			// Run Sql Engine
			SqlStatus := JenSqlRun(ADR(SqlInfo));
			
			// Super Watchdog Bloodhound doing stuff it should do!!!
			TON_Watchdog.PT	:= sqlTimeOut;
			TON_Watchdog.IN := (SqlInfo.cmdDB <> 0) OR (SqlInfo.ErrorString = '[FreeTDS][SQL Server]Communication link failure');
			TON_Watchdog();
		
			
			// Init Done for Connection
			pCockpit.Interface.logData.isInitDone							:= TRUE;
			
			// Runtime of the case
			CASE SqlExporter OF
				RECONNECT:
					reConnectCount 						  := reConnectCount + 1;
					pCockpit.Interface.logData.errorCount := pCockpit.Interface.logData.errorCount+1;
					SqlInfo.cmdDB 						:= 2;
					SqlExporter							:= CHECK_CONNECTION_STATUS;
					pCockpit.Interface.logData.isBusy 	:= FALSE;	
					
				CHECK_CONNECTION_STATUS:
					IF (SqlInfo.ConnectState = 2) THEN
						SqlExporter := Export_FindLine;
					END_IF
				
				Export_FindLine:
					IF SqlInfo.Ident > 0 THEN
						TOF_10ms_Sleep.IN								:= FALSE;
						TOF_10ms_Sleep();
						IF NOT(TOF_10ms_Sleep.Q) THEN
							// First we need to find a new line
							LogRead_0.adrReadData 		:= ADR(LogRecord);
							LogRead_0.sizeofReadData 	:= SIZEOF(LogRecord);
							LogRead_0.startFirstEntry 	:= TRUE;
							LogRead_0();
							IF LogRead_0.status <> 65535 THEN
								IF LogRead_0.entries_read > 0 THEN
									// Has Read a line
									LogRead_0.startFirstEntry	:= FALSE;
									SqlExporter					:= Export_PrepData;
								ELSE
									// Has not read a line. No Line avalible
									// We need to sleep for 1 sec
									TOF_10ms_Sleep.IN := TRUE;
									TOF_10ms_Sleep();
								END_IF
							END_IF
						END_IF
					END_IF
				
				Export_PrepData:
					FOR j:= 1 TO UDINT_TO_INT(LogRead_0.entries_read) DO									// So far only 1 record read at the time
						strcpy(ADR(tempQueryString), ADR(SqlInfo.InsertProcedure));
						IF (LogRead_0.status = 0) THEN	// Read one record correct
							// Not perfect but a start
							SQLCount := SQLCount + 1;
							// add static data to stored procedure call
							FOR i := 0 TO SqlInfo.DataFieldStructure.DataVariableFields-1 DO
								
// INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA INJECT DATA 
								FOR x := 0 TO (SIZEOF(arrStaticData) / SIZEOF(arrStaticData[0])) -1 DO
									// parameter is active
									IF (arrStaticData[x].injectPosition = i) THEN
										IF (strlen(ADR(arrStaticData[x].parameterName)) > 0) THEN
											IF (strlen(ADR(arrStaticData[x].parameterText)) > 0) THEN
												strcpy(ADR(tmpstr),ADR('X'));
												tmpstr[0] 											:= 39; // Trick to add a ' into a ST-string
												IF (LogRecord.Event.SubID > 0 AND x = 2) THEN
													// Nasty hack!
													IF (LogRecord.Event.PositionID = 1) THEN
														arrStaticData[x].parameterText := pCockpit.Runtime.subIDName;
													ELSE
														arrStaticData[x].parameterText := pCockpit.Runtime.subIDNameSlave;
													END_IF
													strcat(ADR(tmpstr),ADR(arrStaticData[x].parameterText));
													itoa(LogRecord.Event.SubID,ADR(tmpstrI));
													strcat(ADR(tmpstr),ADR(tmpstrI));
												ELSE
													strcat(ADR(tmpstr),ADR(''));
												END_IF
												strcat(ADR(tmpstr),ADR('X'));
												tmpstr[strlen(ADR(tmpstr))-1] 						:= 39; // Trick to add a ' into a ST-string	
											ELSE
												IF (x = 1) THEN
													IF (LogRecord.Event.PositionID = 1) THEN
														arrStaticData[x].parameterValue := pCockpit.Runtime.machineID;
													ELSE
														arrStaticData[x].parameterValue := pCockpit.Runtime.machineIDSlave;
													END_IF
											
												END_IF

												itoa(arrStaticData[x].parameterValue,ADR(tmpstr));
											END_IF
											strcat(ADR(tempQueryString),ADR(tmpstr));
											strcat(ADR(tempQueryString),ADR(', ' ));	
										END_IF
									END_IF
								END_FOR
								
								// INJECT DATA
								IF SqlInfo.DataFieldStructure.DataVariableAddressListPointer+(SIZEOF(ConvertionList_typ)*i) = 0 THEN
									SqlInfo.ErrorString := 'DataVariableAddressListPointer = 0';
									RETURN;
								END_IF
								ConvertionListPtr ACCESS SqlInfo.DataFieldStructure.DataVariableAddressListPointer+(SIZEOF(ConvertionList_typ)*i);
								CASE ConvertionListPtr.DataTyp  OF
			   						IEC_DATATYPE_BOOL:
										VarTypeBool ACCESS ConvertionListPtr.Address;
										itoa(VarTypeBool,ADR(tmpstr));
									IEC_DATATYPE_INT:
										VarTypeInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeInt,ADR(tmpstr));
					   				IEC_DATATYPE_UINT:
										VarTypeUInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeUInt,ADR(tmpstr));
			   						IEC_DATATYPE_SINT:
										VarTypeSInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeSInt,ADR(tmpstr));
			   						IEC_DATATYPE_USINT:
										VarTypeUSInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeUSInt,ADR(tmpstr));
									IEC_DATATYPE_DINT:
										VarTypeDInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeDInt,ADR(tmpstr));
									IEC_DATATYPE_UDINT:
										VarTypeUDInt ACCESS ConvertionListPtr.Address;
										itoa(VarTypeUDInt,ADR(tmpstr));
									IEC_DATATYPE_REAL:
										VarTypeREAL ACCESS ConvertionListPtr.Address;
										ftoa(VarTypeREAL,ADR(tmpstr));
										//strcpy(ADR(tmpstr),ADR('28,3'));
									IEC_DATATYPE_STRING:// STRING 
										strcpy(ADR(tmpstr),ADR('X'));
										tmpstr[0] 											:= 39; // Trick to add a ' into a ST-string				
										strcat(ADR(tmpstr),ConvertionListPtr.Address);				
										strcat(ADR(tmpstr),ADR('X'));
										tmpstr[strlen(ADR(tmpstr))-1] 						:= 39; // Trick to add a ' into a ST-string				
										strcpy(ADR(nissestring),ADR(tmpstr));
										
									IEC_DATATYPE_DATE_AND_TIME:
										// This is really stupid. We have correct time in LogRecord,LogRead() converts it into DATETIMEformat and returns here. We then creates 
										// it back to DTStructure and make a string out of it. :(
										// We need to get the correct time string from LogRecord direct without all this shitty conversion.
										//strcat(ADR(tmpstr),ADR('08.07.2014 10:12:34'));
										strcpy(ADR(tmpstr),ADR('X'));
										tmpstr[0] 											:= 39; // Trick to add a ' into a ST-string				
										VarTypeDateTime ACCESS ConvertionListPtr.Address;
										DT_TO_DTStructure(VarTypeDateTime, ADR(tmpDTStruct));
										itoa(tmpDTStruct.year,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));
										strcat(ADR(tmpstr),ADR('-'));

										itoa(tmpDTStruct.month,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));
										strcat(ADR(tmpstr),ADR('-'));

										itoa(tmpDTStruct.day,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));
										strcat(ADR(tmpstr),ADR(' '));

										itoa(tmpDTStruct.hour,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));
										strcat(ADR(tmpstr),ADR(':'));

										itoa(tmpDTStruct.minute,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));
										strcat(ADR(tmpstr),ADR(':'));

										itoa(tmpDTStruct.second,ADR(tmp));
										strcat(ADR(tmpstr),ADR(tmp));

										strcat(ADR(tmpstr),ADR('X'));
										tmpstr[strlen(ADR(tmpstr))-1] 						:= 39; // Trick to add a ' into a ST-string				

								END_CASE
								strcat(ADR(tempQueryString),ADR(tmpstr));
								IF i < (SqlInfo.DataFieldStructure.DataVariableFields-1) THEN
									strcat(ADR(tempQueryString),ADR(', ' ));
								END_IF	
							END_FOR
							strcat(ADR(tempQueryString),ADR(' ; '));
							
							// Okay we have now converted the data type
							SqlExporter															:= Export_SQLAddData;
						END_IF	
					END_FOR
				
				Export_SQLAddData:
					IF SqlInfo.cmdDB = 0 AND NOT pCockpit.Interface.realtime.isBusy THEN
						pCockpit.Interface.logData.isBusy := TRUE;
						SqlInfo.cmdDB 													:= DB_SQL_ADD_5;
						SqlInfo.Action 													:= 0;
						SqlInfo.SQLString												:= tempQueryString;
						SqlInfo.AffectedRows											:= 0;
						pCockpit.Interface.logData.sentCount							:= pCockpit.Interface.logData.sentCount+1;
						SqlExporter														:= Export_SQLCheckData_Cmd;
					END_IF
				
				Export_SQLCheckData_Cmd:
					IF (TON_Watchdog.Q) THEN
						SqlExporter := RECONNECT;	
					END_IF
					IF SqlInfo.cmdDB = 0 THEN
						//SqlInfo.cmdDB 													:= DB_GET_AFFEECTEDROWS_10;
						SqlExporter														:= Export_SetPointer; //Export_SQLCheckData_Check;
					END_IF
					
				Export_SQLCheckData_Check:
					IF (TON_Watchdog.Q) THEN
						SqlExporter := RECONNECT;	
					END_IF
					IF SqlInfo.cmdDB = 0 THEN
						IF SqlInfo.AffectedRows = 0 THEN
							// Try Again
							pCockpit.Interface.logData.errorCount						:= pCockpit.Interface.logData.errorCount+1;
							SqlExporter													:= Export_SQLAddData;
						ELSE
							SqlExporter													:= Export_SetPointer;
						END_IF
					END_IF
					
				Export_SetPointer:
					LogSetLineRead_0.ident;
					LogSetLineRead_0.status;
					LogSetLineRead_0();
					SqlExporter	:= Export_CheckLineSet;
					
				Export_CheckLineSet:
					IF (LogSetLineRead_0.status = 0) THEN						
						pCockpit.Interface.logData.isBusy := FALSE;						
						SqlExporter																		:= CHECK_CONNECTION_STATUS;
					ELSE
						LogSetLineRead_0();
					END_IF
				
			END_CASE	
			// Is Connection Connected??
			IF SqlInfo.ConnectState > 0 THEN
				pCockpit.Interface.logData.isConnected											:= TRUE;
			ELSE
				pCockpit.Interface.logData.isConnected											:= FALSE;
			END_IF
	END_CASE
END_PROGRAM
