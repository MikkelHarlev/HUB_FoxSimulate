(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: JHangerTurner
 * File: JHangerTurnerCyclic.st
 * Author: mha
 * Created: January 08, 2014
 ********************************************************************
 * Implementation of program JHangerTurner
 ********************************************************************)

PROGRAM _CYCLIC

//------------------------------------------------------------------------
// Hanger turner at factory
//------------------------------------------------------------------------
PreStopIn( In := IIPrestopIn );
HangerTurnerPresent( In := IIHangerTurnerIn );
g_HMIHideValuesHangerTurner := (g_HMIJedkHangerTurner = 0);
	
// Top prestop delay on pulses
TopPreStop.Set := IIHangerTurnerIn AND NOT TopPreStop.Out OR EDGENEG(TopPreStop.Out);
TopPreStop( Delay := g_PreStopDelayHMI, On := g_PreStopOnTimeHMI);

// Hanger turner prestop pulses and jam check
HangerTurnerPrestop.Set := (PrestopIn.Out OR JamCheck.StatusCnt >= JamCheck.Enable OR JamCheck.Jam OR NOT HangerTurnerPresent.Out) AND NOT HangerTurnerPrestop.Out OR EDGENEG(HangerTurnerPrestop.Out);
HangerTurnerPrestop( Delay := g_PreStopDelayHMI, On := g_PreStopOnTimeHMI);

// Check for hangers stuck in turner
JamCheck( Start := EDGEPOS(HangerTurnerPrestop.Out) AND IIHangerTurnerIn, Stop := EDGEPOS(IIPrestopIn), Reset := EDGEPOS(PrestopIn.Out) OR g_Machine.ResetAllAlarm OR g_HMIJedkHangerTurner = 0, Enable := UINT_TO_USINT(g_JamNoAcceptedHMI), JamTimeOut := g_JamTimeOutHMI, JamTolerence := g_JamTimeOutHMI/2 );
g_HangerInletProcess.Common.AlarmList.Alarm[11] := JamCheck.Jam;

//------------------------------------------------------------------------
// Outputs
//------------------------------------------------------------------------
QYPreStop := TopPreStop.Out AND g_HMIJedkHangerTurner > 0;
QYPreStopHangerTurner := HangerTurnerPrestop.Out AND g_HMIJedkHangerTurner > 0;


END_PROGRAM
