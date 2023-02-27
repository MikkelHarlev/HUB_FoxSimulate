PROGRAM _CYCLIC
	IF sState > 0 THEN
		CASE sState	OF
		
			STATE_INIT:
				pDevice := ADR(LOGBOOK_DEVICENAME);
				pFileName := ADR(LOGBOOK_FILE_NAME);
				fDelete.enable := 1;
				fDelete.pDevice := pDevice;
				fDelete.pName := pFileName;
				fDelete();
				sState := STATE_DELETE;
		
			STATE_DELETE:
				fDelete.enable := 1;
				fDelete.pDevice := pDevice;
				fDelete.pName := pFileName;
				fDelete();
				IF (fDelete.status = STATUS_READY) OR (fDelete.status = fiERR_FILE_NOT_FOUND) THEN
					fCreate.enable := 1;
					fCreate.pDevice := pDevice;
					fCreate.pFile := pFileName;
					fCreate.pDevice := pDevice;
					fCreate.pFile := pFileName;
					fCreate();
					sState := STATE_CREATE;
				ELSIF (fDelete.status <> STATUS_BUSY) THEN
					sState := STATE_ERROR;
				END_IF;
		
			STATE_CREATE:
				fCreate.enable := 1;
				fCreate.pDevice := pDevice;
				fCreate.pFile := pFileName;
				fCreate.pDevice := pDevice;
				fCreate.pFile := pFileName;
				fCreate();
				IF (fCreate.status = STATUS_READY) THEN
					fWrite.enable := 1;
					fWrite.ident := fCreate.ident;
					EntryNo := 0;
					OffsetLogWrite := 0;
					sState := STATE_HEADER;
				ELSIF (fCreate.status <> STATUS_BUSY) THEN
					sState := STATE_ERROR;
				END_IF;
		
			STATE_HEADER:
				
				strcpy(ADR(LogString),ADR('DD.MM.YYYY;HH:MM:SS;ms; Error;ErrInfo;type;Description'));
				strcat(ADR(LogString),ADR(CSV_DELIMITER));
				LenLogWrite := strlen(ADR(LogString));
				fWrite.pSrc := ADR(LogString);
				fWrite.offset := OffsetLogWrite;
				fWrite.len := LenLogWrite;
				fWrite();
				OffsetLogWrite := OffsetLogWrite + LenLogWrite;
				sState := STATE_WRITE_WAIT;
			
			STATE_WRITE:
				Status := ERRxread(EntryNo, ADR(LogEntryType));
		
				IF (Status = STATUS_READY) THEN
					LenAtoi := itoa(LogEntryType.err_day,ADR(LogString));
					strcat(ADR(LogString),ADR('.'));
					LenAtoi := LenAtoi + 1;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_month,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR('.'));
					LenAtoi := LenAtoi + 1;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_year,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(' ;'));
					LenAtoi := LenAtoi + 2;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_hour,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(':'));
					LenAtoi := LenAtoi + 1;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_minute,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(':'));
					LenAtoi := LenAtoi + 1;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_second,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(' ;'));
					LenAtoi := LenAtoi + 2;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_millisec,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(' ;'));
					LenAtoi := LenAtoi + 2;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_nr,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(' ;'));
					LenAtoi := LenAtoi + 2;
					LenAtoi := LenAtoi + itoa(LogEntryType.err_info,ADR(LogString)+LenAtoi);
					strcat(ADR(LogString),ADR(' ;'));
					LenAtoi := LenAtoi + 2;
					strcat(ADR(LogString),ADR(LogEntryType.t_name));
					strcat(ADR(LogString),ADR(' ;'));
					strcat(ADR(LogString),ADR(LogEntryType.err_string));
		
					strcat(ADR(LogString),ADR(CSV_DELIMITER));
					LenLogWrite := strlen(ADR(LogString));
					fWrite.pSrc := ADR(LogString);
					fWrite.offset := OffsetLogWrite;
					fWrite.len := LenLogWrite;
					fWrite();
					OffsetLogWrite := OffsetLogWrite + LenLogWrite;
					EntryNo := EntryNo + 1;
					sState := STATE_WRITE_WAIT;
				ELSE
					fClose.enable := 1;
					fClose.ident := fCreate.ident;
					fClose();
					sState := STATE_CLOSE;
				END_IF;
		
			STATE_WRITE_WAIT:
				fWrite();
				IF (fWrite.status = STATUS_READY) THEN
					sState := STATE_WRITE;
				ELSIF (fWrite.status <> STATUS_BUSY) THEN
					sState := STATE_ERROR;
				END_IF;
		
			STATE_CLOSE:
				fClose();
				IF (fClose.status = STATUS_READY) THEN
					sState := 0;
				ELSIF (fClose.status <> STATUS_BUSY) THEN
					sState := STATE_ERROR;
				END_IF;
		
			STATE_ERROR:
				sState := 0;
		
		END_CASE;
			
		IF (sState > STATE_ERROR) THEN
			sState := 0;
		END_IF	
	END_IF	
	
	IF (cmdSaveLogBook  = 1) OR (g_Core.System.Interface.cmdSaveLogBookFile = TRUE) THEN
		cmdSaveLogBook 								:= FALSE;
		g_Core.System.Interface.cmdSaveLogBookFile 	:= FALSE;
		sState 										:= 1;
		
		Notify(g_Core.Services.HMIHandler.Runtime.Handler[0].pPanelHandler, NOTIFY_SAVE_121,g_Core.Services.HMIHandler.Runtime.defaultNotifyTime);
	END_IF
	
	
	IF g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID <> PageLogBook THEN
		RETURN;
	END_IF
	
	(* Read the logbook information *)
	IF Plclog.cmdLogRead = 1 THEN
		Plclog.InfoHide:= 1;
		Plclog.NumberDetailInfo:= 0;
	
		FOR CountLog:= 0 TO (MaxRead - 1) DO
			ERRxStatus:= ERRxread(CountLog, ADR(LogbookInfo[CountLog]));
	
			IF ERRxStatus = 0 THEN
				ErrorNb:= LogbookInfo[CountLog].err_nr;
				Plclog.LogInfoString[CountLog]:= '';
				CharCount:= 4;
	
				(* Calculate, how many 0s have to be added in front of the Error number string *)
				FOR xcnt:= 0 TO 4 DO
					IF ErrorNb <> 0 THEN
						CharCount:= CharCount - 1;
					ELSE EXIT;
					END_IF
	
					ErrorNb:= ErrorNb / 10;
				END_FOR
	
				FOR xcnt:= 0 TO CharCount DO
					strcat(ADR(Plclog.LogInfoString[CountLog]), ADR('0'));
				END_FOR
	
				itoa(LogbookInfo[CountLog].err_nr, ADR(ErrorNbString));
	
				IF LogbookInfo[CountLog].err_nr <> 0 THEN
					strcat(ADR(Plclog.LogInfoString[CountLog]), ADR(ErrorNbString));
				END_IF
	
				strcat(ADR(Plclog.LogInfoString[CountLog]), ADR(','));
				strcat(ADR(Plclog.LogInfoString[CountLog]), ADR(LogbookInfo[CountLog].err_string));
			END_IF
		END_FOR
	
		Plclog.cmdLogRead:= 0;
		memcpy(ADR(Plclog.DetailInfo), ADR(LogbookInfo[Plclog.NumberDetailInfo]), SIZEOF(Plclog.DetailInfo));
		Plclog.InfoHide := 0;
	END_IF;
	
	(* Move cursor to next entry *)
	IF Plclog.cmdNextEntry = 1 THEN
		Plclog.cmdNextEntry:= 0;
		IF Plclog.NumberDetailInfo < (MaxRead - 1) THEN
			Plclog.NumberDetailInfo:= Plclog.NumberDetailInfo + 1;
			memcpy(ADR(Plclog.DetailInfo), ADR(LogbookInfo[Plclog.NumberDetailInfo]), SIZEOF(Plclog.DetailInfo));
			Plclog.InfoHide:= 0;
		END_IF
	
	(* Move cursor to previous entry *)
	ELSIF Plclog.cmdPrevEntry = 1 THEN
		Plclog.cmdPrevEntry:= 0;
		IF Plclog.NumberDetailInfo > 0 THEN
			Plclog.NumberDetailInfo:= Plclog.NumberDetailInfo - 1;
			memcpy(ADR(Plclog.DetailInfo), ADR(LogbookInfo[Plclog.NumberDetailInfo]), SIZEOF(Plclog.DetailInfo));
			Plclog.InfoHide:= 0;
		END_IF
	END_IF
END_PROGRAM

