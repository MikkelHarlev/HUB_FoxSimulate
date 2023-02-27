(********************************************************************
 * COPYRIGHT -- JEDK
 ********************************************************************
 * Program: HangerSetup
 * File: HangerSetupInit.st
 * Author: mha
 * Created: September 26, 2012
 ********************************************************************
 * Implementation of program HangerSetup
 ********************************************************************)

PROGRAM _INIT

RInit := TRUE;
LogEntry(g_MCfg.Trace2File, ADR(T2FD), 1, 1, 10, 'HangerSet init');

RUseOnlyFirstSensor := 0;
RUseOnlyLastSensor := 0;
RSwitchSensorFunction := 0;


END_PROGRAM

