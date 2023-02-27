(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: JenLogStack
 * File: JenLogStackInit.st
 * Author: jspernil
 * Created: October 08, 2009
 ********************************************************************
 * Implementation of program JenLogStack
 ********************************************************************)

PROGRAM _INIT

RInit := 1;
RInitNoRun := 1;
RInitLogStackRunning := 1;

(* init program *)

LogHandle.DeviceName 				:= 'Log';
LogHandle.FileName 					:= 'StackerLog.csv';
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
strcpy(ADR(HeaderRec),ADR('Date;Time;Type;Item 1;Item 2;Item 3;Item 4;Item 5;Item 6'));
endchar[0] := 13;
endchar[1] := 10;
endchar[2] := 0;
strcat(ADR(HeaderRec),ADR(endchar));



END_PROGRAM

