PROGRAM _INIT
(* init program *)
RInit := TRUE;
RInitNoRun := TRUE;
RInitRunning := TRUE;

LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'jenlog init');

LogHandle.DeviceName 				:= 'Log';
LogHandle.FileName 					:= 'InletLog.csv';
MAX_RECORDS_BEFORE_SAVE				:= 10;
MAX_STORE_TIMEOUT					:= 300;
LogRecLen							:= SIZEOF(LogRecord[0]);
LastDay  							:= 0;
memset(ADR(datestr),48,6);			(* YYMMDD = 000000 *)
datestr[6] := 0; 					(* Always terminate with null *)
LogHandle.DoSave 					:= FALSE;
LogHandle.LogPointer 				:= 0;
LogHandle.SaveFileState				:= 0;
// Create header
strcpy(ADR(HeaderRec),ADR('Date;Time;HangerId;Recipe;Type;Article;Customer;Destination;StackChange'));
endchar[0] := 13;
endchar[1] := 10;
endchar[2] := 0;
strcat(ADR(HeaderRec),ADR(endchar));
END_PROGRAM

