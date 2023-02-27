FUNCTION_BLOCK FB_LogExport
	(* Implementation of LogExport *)
	
	(*	Reset function if Enable is false	*)
	IF (Enable = FALSE) THEN
		State := 0;
		cmdSaveLog := 0;
	END_IF;
	
	CASE	State	OF
	
		0:
			IF (cmdSaveLog = TRUE) THEN
				fDelete.enable := 1;
				fDelete.pDevice := pDevice;
				fDelete.pName := pFileName;
				fDelete();
				Status := 65535;
				State := 1;
			END_IF;
	
		1:
			fDelete();
			IF (fDelete.status = 0) OR (fDelete.status = fiERR_FILE_NOT_FOUND) THEN
				fCreate.enable := 1;
				fCreate.pDevice := pDevice;
				fCreate.pFile := pFileName;
				fCreate();
				State := 2;
			ELSIF (fDelete.status <> 65535) THEN
				Status := fDelete.status;
				State := 6;
			END_IF;
	
		2:
			fCreate();
			IF (fCreate.status = 0) THEN
				fWrite.enable := 1;
				fWrite.ident := fCreate.ident;
				EntryNo := 0;
				OffsetLogWrite := 0;
				State := 3;
			ELSIF (fCreate.status <> 65535) THEN
				Status := fCreate.status;
				State := 6;
			END_IF;
	
		3:
			Status := ERRxread(EntryNo, ADR(LogEntryType));
	
			IF (Status = 0) THEN
				Status := 65535;
	
				LenAtoi := itoa(LogEntryType.err_day,ADR(LogString));
				strcat(ADR(LogString),ADR('.'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_month,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR('.'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_year,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(' '));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_hour,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(':'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_minute,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(':'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_second,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(' '));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_millisec,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(';'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_nr,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(';'));
				LenAtoi := LenAtoi + 1;
				LenAtoi := LenAtoi + itoa(LogEntryType.err_info,ADR(LogString)+LenAtoi);
				strcat(ADR(LogString),ADR(';'));
				LenAtoi := LenAtoi + 1;
				strcat(ADR(LogString),ADR(LogEntryType.t_name));
				strcat(ADR(LogString),ADR(';'));
				strcat(ADR(LogString),ADR(LogEntryType.err_string));
	
				strcat(ADR(LogString),ADR('$R$L'));
				LenLogWrite := strlen(ADR(LogString));
				fWrite.pSrc := ADR(LogString);
				fWrite.offset := OffsetLogWrite;
				fWrite.len := LenLogWrite;
				fWrite();
				OffsetLogWrite := OffsetLogWrite + LenLogWrite;
				EntryNo := EntryNo + 1;
				State := 4;
			ELSE
				fClose.enable := 1;
				fClose.ident := fCreate.ident;
				fClose();
				Status := 65535;
				State := 5;
			END_IF;
	
		4:
			fWrite();
			IF (fWrite.status = 0) THEN
				State := 3;
			ELSIF (fWrite.status <> 65535) THEN
				Status := fCreate.status;
				State := 6;
			END_IF;
	
		5:
			fClose();
			IF (fClose.status = 0) THEN
				cmdSaveLog := FALSE;
				Status := 0;
				State := 0;
			ELSIF (fClose.status <> 65535) THEN
				Status := fClose.status;
				State := 6;
			END_IF;
	
		6:
			cmdSaveLog := FALSE;
	
	END_CASE;
	
	
	
END_FUNCTION_BLOCK