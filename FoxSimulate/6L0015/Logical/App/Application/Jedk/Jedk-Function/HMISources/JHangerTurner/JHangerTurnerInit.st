(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: JHangerTurner
 * File: JHangerTurnerInit.st
 * Author: mha
 * Created: January 08, 2014
 ********************************************************************
 * Implementation of program JHangerTurner
 ********************************************************************)

PROGRAM _INIT


// Hanger turner prestop pulses and jam check
g_PreStopDelayHMI  := 2000;
g_PreStopOnTimeHMI := 500;
g_JamTimeOutHMI    := 3000;
g_JamNoAcceptedHMI := 2;

PreStopIn( Filter := 1000, FMode := 1, TMode := 0, CntAdr := ADR(g_MilliSeconds) );
HangerTurnerPresent( Filter := 10000, FMode := 2, TMode := 0, CntAdr := ADR(g_MilliSeconds) );

JamCheck( Enable := UINT_TO_USINT(g_JamNoAcceptedHMI), Reset := 1, ResetTimeOut := 20000, CntAdr := ADR(g_MilliSeconds) );
TopPreStop( Set := 1, On := g_PreStopOnTimeHMI, Delay := g_PreStopDelayHMI, Cnt2Adr := ADR(g_MilliSeconds), Cnt1Adr := ADR(g_MilliSeconds) );
HangerTurnerPrestop( Set := 1, On := g_PreStopOnTimeHMI, Delay := g_PreStopDelayHMI, Cnt2Adr := ADR(g_MilliSeconds), Cnt1Adr := ADR(g_MilliSeconds) );


END_PROGRAM

