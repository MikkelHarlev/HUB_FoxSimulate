FUNCTION LogEntry
(* Implementation of LogEntry *)

(*-------------------------------------------------------------------------------------

Author:   				Per-Olov Nilsson.

FileName:				Task(file)name.scr

Desription:

Reference:

Interfaces:				No interfaces.

Watch debugg:			Name OF important watch configurations.

History:

09-02-12				V0.00 PO Nilsson		First edition...

---------------------------------------------------------------------------------------*)



(*#########################################################*)
(* Make entries in the logbook, with the Level as a Filter *)
(*#########################################################*)

	ST_name(0, ADR(TaskName), 0);
	IF TraceLogEnable THEN
		T2FD ACCESS DA;
		T2F_New(DA:=ADR(T2FD), F:= ADR(TaskName), W:= ADR('Log'));
	
		T2F_AddUDINT(DA:= ADR(T2FD), N:= ADR('Priority'),V:= Priority);
		T2F_AddUDINT(DA:= ADR(T2FD), N:= ADR('LogValue'),V:= LogValue);
		T2F_AddStringADR(DA:=ADR(T2FD),T:=ADR('LogText;'));
		T2F_AddStringADR(DA:=ADR(T2FD),T:=ADR(LogText));
		T2F_AddStringADR(DA:=ADR(T2FD),T:=ADR(';'));
	
		T2F_Log(DA:=ADR(T2FD));
	END_IF
	
	IF LogBookLevel >= Priority THEN
		ERRxwarning(20001, LogValue, ADR(LogText));
		LogEntry := 1;								(* Value writen to logbook... *)
	ELSE
		LogEntry := 0;								(* Nothing was writen to the logbook... *)
	END_IF

END_FUNCTION
