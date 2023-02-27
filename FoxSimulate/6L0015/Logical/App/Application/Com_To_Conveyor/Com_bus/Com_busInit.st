(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Com_bus
 * File: Com_busInit.st
 * Author: jspernil
 * Created: May 05, 2010
 ********************************************************************
 * Implementation of program Com_bus
 ********************************************************************)

PROGRAM _INIT


(* Init X2X buses *)
g_ComBus.BusType := COMBUS_TYPE_X67;
InitComBus(g_ComBus);
InitComUnit(g_ComBus, 01(* Node Id *), COMUNIT_FUNCTION_TYPE_JENCOM (* Type *), 'IF1', '/PHY=RS232 /BD=9600 /PA=N /DB=8 /SB=1',25, 0, 0, 0);

END_PROGRAM

