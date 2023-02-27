PROGRAM _CYCLIC
	
	IF g_Core.Services.Blackbox.Runtime.server.Internal.AdrArrIdentJenViewLogInit = 0 THEN
		RETURN;
	END_IF
	
	ArrLogInitIdents ACCESS g_Core.Services.Blackbox.Runtime.server.Internal.AdrArrIdentJenViewLogInit;
	
	
	IF (LogNo <> LogNoOld AND LogNo > 0 AND LogNo < 6 AND LogNo <= g_Core.Services.Blackbox.Runtime.server.ServersRunning) THEN
		LogLib ACCESS ArrLogInitIdents[LogNo-1];
		pLogList  := LogLib.pFileData + LogLib.Offset4thLine;
		LogNoOld := LogNo;
	ELSE
		LogNo := LogNoOld;
	END_IF
	
	IF pLogList = 0 THEN
		RETURN;
	END_IF;
	
	
	(* Set List Pointer = Start *)
	IF ListStart THEN
		ListStart := 0;
		LogListNo := 0;
		ListNo    := 0;
	END_IF;
	
	(* Set List Pointer = Write Position *)
	IF ListWrite THEN
		ListWrite := 0;
		IF LogLib.LastLineWrite > 6 THEN
			LogListNo := LogLib.LastLineWrite - 7;
			ListNo := 7;
		ELSE
			LogListNo := LogLib.EntrysLogFile - ( 7 - LogLib.LastLineWrite );
			ListNo := 7;
		END_IF;
	END_IF;
	
	(* Listbox Up *)
	Scroll_0( In := ListUp );
	IF Scroll_0.Out THEN
		IF ListNo > 0 THEN
			ListNo := ListNo - 1;
		ELSE
			IF LogListNo > 0 THEN
				LogListNo := LogListNo - 1;
			ELSE
				LogListNo := LogLib.EntrysLogFile - 1;
			END_IF;
		END_IF;
	END_IF;
	
	(* Listbox Down *)
	Scroll_1( In := ListDown );
	IF Scroll_1.Out THEN
		IF ListNo < 7 THEN
			ListNo := ListNo + 1;
		ELSE
			IF LogListNo < LogLib.EntrysLogFile - 1 THEN
				LogListNo := LogListNo + 1;
			ELSE
				LogListNo := 0;
			END_IF;
		END_IF;
	END_IF;
	
	(* Copy Selected List *)
	FOR No := 0 TO 7 DO
		IF LogListNo + No > LogLib.EntrysLogFile - 1 THEN
			TempNo := LogListNo + No - LogLib.EntrysLogFile;
		ELSE
			TempNo := LogListNo + No;
		END_IF;
		Test[No] := TempNo;
		List[No] := '';
		memcpy( ADR( List[No] ) + 0, pLogList + ( TempNo * LogLib.DataLineLength ), SIZEOF( List[0] ) - 2 );
		IF No = ListNo THEN
			memcpy( ADR( ListIndex    ), pLogList + ( TempNo * LogLib.DataLineLength ) + 00, 05 );
			memcpy( ADR( ListDate     ), pLogList + ( TempNo * LogLib.DataLineLength ) + 06, 10 );
			memcpy( ADR( ListTime     ), pLogList + ( TempNo * LogLib.DataLineLength ) + 17, 08 );
			memcpy( ADR( ListMode     ), pLogList + ( TempNo * LogLib.DataLineLength ) + 26, 03 );
			memcpy( ADR( ListID       ), pLogList + ( TempNo * LogLib.DataLineLength ) + 30, 03 );
			memcpy( ADR( ListValueID  ), pLogList + ( TempNo * LogLib.DataLineLength ) + 34, 05 );
			memcpy( ADR( ListInfo     ), pLogList + ( TempNo * LogLib.DataLineLength ) + 40, 10 );
			memcpy( ADR( ListMessageA ), pLogList + ( TempNo * LogLib.DataLineLength ) + 52, 24 );
			memcpy( ADR( ListMessageB ), pLogList + ( TempNo * LogLib.DataLineLength ) + 85, 24 );
		END_IF;
	END_FOR;
END_PROGRAM

