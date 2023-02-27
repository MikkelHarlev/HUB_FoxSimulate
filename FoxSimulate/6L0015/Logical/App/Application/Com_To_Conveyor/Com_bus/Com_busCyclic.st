PROGRAM _CYCLIC
(*-------------------------------------------------------------------------------------

Author:   				Per-Olov Nilsson.

FileName:				Task(file)name.scr

Desription:				This task runs the communication busses with readers, folders, finishers.
						
Reference:				ScanLib, MetUtils. 

Interfaces:				No interfaces.

Watch debugg:			Name of important watch configurations.

History:
10-05-05				V2.03.1 PO Nilsson			Added to the fox, removed/commented some unused parts..
08-01-10				V2.03   Sten Flystedt 		To handle PP400 internal COM1 to test scanners.
04-09-16				V2.02   Per-Olov Nilsson	Updated to new VC and small bugfixes after Wozabal...
													Changed some buttons on HMI aswell..
04-05-26				V2.01   Per-Olov Nilsson	Filtered the Siox node alarms and the Siox communications alarms...
03-08-15				V2.00   Per-Olov Nilsson	Converted to SG4...

---------------------------------------------------------------------------------------*)
IF NOT g_SystemInitialized THEN
	RETURN;
END_IF	

(*########################*)
(* Run X2X communncation *)
(*########################*)
IF g_ComBus.InitState = 0 THEN
	RunComBus(g_ComBus);
	IF ((g_ComBus.RunState >= 15250) AND (g_ComBus.RunState <= 15290)) THEN    (* Check witch node is causing the error *)
		ComBusError.TotalCounter := ComBusError.TotalCounter + 1;
		IF ComBusError.TempCounter < 5 THEN
			ComBusError.TempCounter := ComBusError.TempCounter + 1;
		END_IF
	END_IF
END_IF
END_PROGRAM