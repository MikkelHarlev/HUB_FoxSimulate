(*-------------------------------------------------------------------------------------

Author:   				PO Nilsson

FileName:				JenLogStack.st

Desription:				Text file logger for stack item data...

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name of important watch configurations.

History:
09-11-10				V1.00.0 PO Nilsson		Bug fixes for string lenghts, constants in strin declarations...
xx-xx-xx				V0.00 	Sten Flystedt	First edition...
---------------------------------------------------------------------------------------*)

PROGRAM _CYCLIC

IF NOT g_SystemInitialized THEN
	RETURN;
END_IF	


IF RInitNoRun THEN
	LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'jenlog Cyclic init start');
	RInitNoRun := 0;
END_IF

(* cyclic program *)
IF NOT g_RunJenLog THEN 
	RETURN;
ELSE 	
	IF g_LogInletHanger.DoLog THEN

		IF RInitRunning THEN
			LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'jenlog Cyclic Running');
			RInitRunning := 0;
		END_IF

		memset(ADR(logstr),32,LogRecLen);(* make space('') first *)
		(* Get date & time *)
		DTGetTime_0.enable:= 1;
		DTGetTime_0();
		DT_TO_DTStructure(DTGetTime_0.DT1,ADR(MyDTStructure));
		IF MyDTStructure.day <> LastDay THEN
			memset(ADR(datestr),48,22);(* YYMMDD = 000000 *)
			IF (MyDTStructure.year MOD 100) > 9 THEN
				datestr[0] := UINT_TO_USINT(((MyDTStructure.year MOD 100) / 10) + 48);
			END_IF
			datestr[1] := UINT_TO_USINT((MyDTStructure.year MOD 10)  + 48);
			IF MyDTStructure.month > 9 THEN
				datestr[2] := 49;
			END_IF
			datestr[3] := UINT_TO_USINT((MyDTStructure.month MOD 10)  + 48);
			IF MyDTStructure.day > 9 THEN
				datestr[4] := UINT_TO_USINT(((MyDTStructure.year MOD 100) / 10) + 48);
			END_IF
			datestr[5]  := UINT_TO_USINT((MyDTStructure.day MOD 10)  + 48);
			datestr[6]  := 59;  (* ; *)
			datestr[9]  := 58;  (* : *)
			datestr[12] := 58;  (* : *)
			datestr[15] := 59;  (* ; *)
			datestr[16] := 0;   (* Always terminate with null *)
		END_IF
		(* log current time *)
		IF MyDTStructure.hour > 9 THEN
			datestr[7] := UINT_TO_USINT((MyDTStructure.hour/10) + 48);
		END_IF
		datestr[8] := UINT_TO_USINT((MyDTStructure.hour MOD 10)  + 48);
		IF MyDTStructure.minute > 9 THEN
			datestr[10] := UINT_TO_USINT((MyDTStructure.minute/10) + 48);
		END_IF
		datestr[11] := UINT_TO_USINT((MyDTStructure.minute MOD 10)  + 48);
		IF MyDTStructure.second > 9 THEN
			datestr[13] := UINT_TO_USINT((MyDTStructure.second/10) + 48);
		END_IF
		datestr[14] := UINT_TO_USINT((MyDTStructure.second MOD 10)  + 48);
		strcpy(ADR(logstr),ADR(datestr));
		strcat(ADR(logstr),ADR(g_LogInletHanger.HangerIdStr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.Program,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.HType,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.Article,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.Customer,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.Destination,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		strcat(ADR(logstr),ADR(';'));
		itoa(g_LogInletHanger.StackChange,ADR(tmpstr));
		strcat(ADR(logstr),ADR(tmpstr));
		(* Replace null with ''(space) *)
		logstr[LogRecLen-2] := 32;			// Why do we do like this???
		(* End with CRLF *)
		logstr[LogRecLen-4] := 13;
		logstr[LogRecLen-3] := 10;
		memcpy(ADR(LogRecord[LogHandle.LogPointer]),ADR(logstr),LogRecLen);(* Store Log Record *)
		LogHandle.LogPointer := LogHandle.LogPointer  + 1;
		IF LogHandle.LogPointer > MAX_RECORDS_BEFORE_SAVE THEN
			LogHandle.DoSave := TRUE;
		END_IF
		g_LogInletHanger.DoLog 	:= FALSE;
	END_IF
END_IF

IF LogHandle.LogPointer > 0 THEN
	LogHandle.StoreTimeOutCntr := LogHandle.StoreTimeOutCntr + 1;
	IF LogHandle.StoreTimeOutCntr > MAX_STORE_TIMEOUT THEN
		LogHandle.DoSave := TRUE;
	END_IF
END_IF

IF LogHandle.DoSave THEN
	memcpy(ADR(TempLogRecord),ADR(LogRecord[0]),LogHandle.LogPointer*SIZEOF(LogRecord[0]));
	LogHandle.RecordAdr			:= ADR(TempLogRecord);
	LogHandle.RecordSize		:= LogHandle.LogPointer*SIZEOF(LogRecord[0]);
	LogHandle.SaveFileState		:= 10;
	LogHandle.StoreTimeOutCntr 	:= 0;
	LogHandle.DoSave 			:= FALSE;
	LogHandle.LogPointer 		:= 0;
END_IF

(* Save the data TO a csv file*)
CASE (LogHandle.SaveFileState) OF

	10:	(* Check if a file is already present on HDD, if present open otherwise create it. *)
    	FB_FileOpen.enable    := 1;
        FB_FileOpen.pDevice   := ADR(LogHandle.DeviceName);
        FB_FileOpen.pFile     := ADR(LogHandle.FileName);
        FB_FileOpen.mode      := FILE_RW;  (* Read and write access *)
        FB_FileOpen();

        LogHandle.OpenIdent  := FB_FileOpen.ident;
        LogHandle.OpenStatus := FB_FileOpen.status;

        IF (LogHandle.OpenStatus = 20708) THEN
           LogHandle.SaveFileState := 20;
        ELSIF (LogHandle.OpenStatus = 0) THEN
			FB_FileWrite.offset	:= LogHandle.LastFileWriteAddress;
            LogHandle.SaveFileState := 30;
        ELSIF (LogHandle.OpenStatus <> 65535) THEN
        	LogHandle.OpenError := 1;
      		LogHandle.SaveFileState := 0;
           	IF (LogHandle.OpenStatus = 20799) THEN
               LogHandle.OpenError := FileIoGetSysError();
           	END_IF
       	END_IF

   20: (**** Create file ****)
        FB_FileCreate.enable  := 1;
        FB_FileCreate.pDevice := ADR(LogHandle.DeviceName);
        FB_FileCreate.pFile   := ADR(LogHandle.FileName);
        FB_FileCreate();

        LogHandle.OpenIdent := FB_FileCreate.ident;
        LogHandle.OpenStatus := FB_FileCreate.status;

        IF (LogHandle.OpenStatus = 0) THEN
			FB_FileWrite.offset	:= 0;
            LogHandle.SaveFileState := 28;
        ELSIF (LogHandle.OpenStatus <> 65535) THEN
            LogHandle.OpenError := 2;
            LogHandle.SaveFileState := 0;
            IF (LogHandle.OpenStatus = 20799) THEN
                LogHandle.OpenError := FileIoGetSysError();
            END_IF
        END_IF

	28:	(* Write header to file *)
		FB_FileWrite.enable	:= TRUE;
		FB_FileWrite.ident	:= LogHandle.OpenIdent;

		FB_FileWrite.pSrc:= ADR(HeaderRec);
		FB_FileWrite.len:= strlen(ADR(HeaderRec));
		FB_FileWrite();

		IF (FB_FileWrite.status = 0) THEN
			FB_FileWrite.offset				:= strlen(ADR(HeaderRec));
			LogHandle.LastFileWriteAddress	:= FB_FileWrite.offset;
			LogHandle.SaveFileState 		:= 30;
        ELSIF (FB_FileWrite.status <> 65535) THEN (* Some error, try to close *)
			LogHandle.SaveFileState 		:= 40;
		END_IF

	30:	(* Write to file *)
		FB_FileWrite.enable	:= TRUE;
		FB_FileWrite.ident	:= LogHandle.OpenIdent;

		FB_FileWrite.pSrc:= LogHandle.RecordAdr;
		FB_FileWrite.len:= LogHandle.RecordSize;
		FB_FileWrite();

		IF (FB_FileWrite.status = 0) THEN
			FB_FileWrite.offset				:= FB_FileWrite.offset + LogHandle.RecordSize;
			LogHandle.LastFileWriteAddress	:= FB_FileWrite.offset;
			LogHandle.SaveFileState 		:= 40;
        ELSIF (FB_FileWrite.status <> 65535) THEN (* Some error, try to close *)
			LogHandle.SaveFileState 		:= 40;
		END_IF

	40:	(* Close the file after writing *)
		FB_FileClose.enable				:= TRUE;
		FB_FileClose.ident				:= LogHandle.OpenIdent;
		FB_FileClose();
		IF (FB_FileClose.status = 0) THEN
			LogHandle.SaveFileState 	:= 0;
        ELSIF (FB_FileClose.status <> 65535) THEN
			LogHandle.SaveFileState 	:= 0;
		END_IF
END_CASE

(* Clear log from all old records *)
IF g_ClearJenLog AND (LogHandle.SaveFileState = 0) THEN
	FB_FileDelete.enable:= TRUE;
	FB_FileDelete.pDevice:=	ADR(LogHandle.DeviceName);
	FB_FileDelete.pName:= ADR(LogHandle.FileName);
	FB_FileDelete();
	g_ClearJenLog 	:= FALSE;
END_IF


RInit := 0;
END_PROGRAM

