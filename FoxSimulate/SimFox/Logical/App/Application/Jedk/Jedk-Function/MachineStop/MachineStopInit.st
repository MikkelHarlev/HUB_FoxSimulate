(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: MachineStop
 * File: MachineStopInit.st
 * Author: mha
 * Created: September 24, 2012
 *******************************************************************)

PROGRAM _INIT

RInit := TRUE;

LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 64738, 'MachineStop init');

RInit := 0;

SoftStopMaxTime.CntAdr := ADR( g_MilliSeconds );
SoftStopMaxTime.Delay := 12000;
SoftStopMaxTime();

END_PROGRAM

