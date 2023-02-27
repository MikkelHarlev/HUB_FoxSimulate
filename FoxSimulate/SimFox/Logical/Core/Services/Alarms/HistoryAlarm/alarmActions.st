
ACTION handleAlarmHistoryObject: 
	
	CASE OpenAlarmHistoryDataObject OF
		1:
			IF (AlarmHistoryDataObjectIdent = 0) THEN
				FileOpen_0(enable:=1, pDevice:=ADR(fDevice), pFile:=ADR('alarmHist.dat'), mode:=fiREAD_WRITE);
				OpenAlarmHistoryDataObject := 2;
			ELSE
				OpenAlarmHistoryDataObject := 0;
			END_IF
		2:
			CASE FileOpen_0.status OF
				0: (*File opened*)
					AlarmHistoryDataObjectIdent := FileOpen_0.ident;
					OpenAlarmHistoryDataObject := 0;
				65535: (*Call fub again*)
					FileOpen_0();
	
				20708:
					OpenAlarmHistoryDataObject := 0;
					CreateAlarmHistoryDataObject := 1;
					OpenAlarmHistoryDataObject := 3;
			END_CASE
	
		3:
			IF (CreateAlarmHistoryDataObject = 0) THEN
				OpenAlarmHistoryDataObject := 0;
			END_IF
	END_CASE
	
	CASE CreateAlarmHistoryDataObject OF
		1:
			FileCreate_0(enable:=1, pDevice := ADR(fDevice), pFile:=ADR('alarmHist.dat'));
			CreateAlarmHistoryDataObject := 2;
		2:
			CASE FileCreate_0.status OF
				0: (*All ok*)
					CreateAlarmHistoryDataObject := 0;
					AlarmHistoryDataObjectIdent := FileCreate_0.ident;
				65535:
					FileCreate_0();
			END_CASE
	END_CASE
	
	
	CASE UpdateAlarmHistoryDataObject OF
		1:
			IF ((CloseAlarmHistoryDataObject = 0) AND (ReadAlarmHistoryDataObject = 0)) THEN
				OpenAlarmHistoryDataObject := 1;
				UpdateAlarmHistoryDataObject := 2;
			END_IF

		2:
			IF (OpenAlarmHistoryDataObject = 0) THEN
				IF (AlarmHistoryDataObjectIdent > 0) THEN
					UpdateAlarmHistoryDataObject := 3;
				ELSE
					UpdateAlarmHistoryDataObject := 0;
				END_IF
			END_IF
		3:
			FileWrite_0(enable:=1, ident:=AlarmHistoryDataObjectIdent, offset:=0, pSrc:=ADR(alarmHistory), len:=SIZEOF(alarmHistory));
			UpdateAlarmHistoryDataObject := 4;
		4:
			IF FileWrite_0.status = 65535 THEN
				FileWrite_0();
			ELSE
				UpdateAlarmHistoryDataObject := 5;
			END_IF
		5:
			CloseAlarmHistoryDataObject := 1;
			UpdateAlarmHistoryDataObject := 6;
		6:
			IF CloseAlarmHistoryDataObject = 0 THEN
				UpdateAlarmHistoryDataObject := 0;
			END_IF
	END_CASE
	
	CASE ReadAlarmHistoryDataObject OF
		1:
	
			OpenAlarmHistoryDataObject := 1;
			ReadAlarmHistoryDataObject := 2;
	
		2:
			IF (OpenAlarmHistoryDataObject = 0 AND (AlarmHistoryDataObjectIdent > 0)) THEN
				ReadAlarmHistoryDataObject := 3;
			END_IF
	
		3:
			FileRead_0(enable:=1, ident:=AlarmHistoryDataObjectIdent, offset:=0, pDest:=ADR(alarmHistory), len:=SIZEOF(alarmHistory));
			ReadAlarmHistoryDataObject := 4;
	
		4:
			CASE FileRead_0.status OF
				0:
					ReadAlarmHistoryDataObject := 0; (*All ok*)
					CloseAlarmHistoryDataObject := 1;
				65535:
				FileRead_0(); (*Call fub again*)
			END_CASE
		5:
			IF (CloseAlarmHistoryDataObject = 0) THEN
				ReadAlarmHistoryDataObject := 0; (*All ok*)
			END_IF
	END_CASE

	CASE CloseAlarmHistoryDataObject OF
		1:
			IF (AlarmHistoryDataObjectIdent > 0) THEN
				FileClose_0(enable:=1, ident:=AlarmHistoryDataObjectIdent);
				CloseAlarmHistoryDataObject := 2;
			ELSE
				CloseAlarmHistoryDataObject := 0;
			END_IF
		2:
			CASE FileClose_0.status OF
				0:
					CloseAlarmHistoryDataObject := 0; (*File closed*)
					AlarmHistoryDataObjectIdent := 0;
	
				65535:
				FileClose_0(); (*Fub still working*)
			END_CASE
	END_CASE

END_ACTION

