(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Tests
 * File: Tests.st
 * Author: mha
 * Created: September 24, 2012
 ********************************************************************
 * Implementation of program Tests
 ********************************************************************)

(* Init at last part of file *)

PROGRAM _CYCLIC

IF NOT g_SystemInitialized THEN
	RETURN;
END_IF	

IF EDGEPOS(QMInlet) THEN
	StartTime[ii] := g_MilliSeconds;
END_IF
IF EDGEPOS(QMTopConveyor) THEN
	StartTimeTop[ii] := g_MilliSeconds;
	ii:=ii + 1;
	IF ii > 2 THEN ii := 0; END_IF
END_IF


//------------------------------------------------------------------------
// Check hanger out
//------------------------------------------------------------------------

IF g_ResetHangerCount THEN
	RX_HangerPosCount := 0;
END_IF

IF EDGEPOS(IIJamDeloadingOut) THEN
	RX_HangerPosCount := RX_HangerPosCount + 1;
	RIIJamDeloadingOutCount := 0;
END_IF

g_HangerPosCount[RTaskNo] := RX_HangerPosCount;

IF IIJamDeloadingOut THEN
	RIIJamDeloadingOut := g_MilliSeconds;
	RIIJamDeloadingOutCount := RIIJamDeloadingOutCount + 1;
END_IF


//------------------------------------------------------------------------
// XBFold reverse test
//------------------------------------------------------------------------
IF RTestRev THEN
	QMXBFoldForward := RFw;
	QMXBFoldReverse := NOT RFw;
END_IF

IF RTestRevXA THEN
	QMXAFoldForward := RFwXA;
	QMXAFoldReverse := NOT RFwXA;
END_IF

TrimFlash ( Set := EDGENEG(TrimFlash.Out) );
			 	
IF RRollDoGoGo THEN
	g_TestFunctionActive := 1;

	QYRollOffOut[1] := TrimFlash.Out AND RRollGoGo[0];
	QYRollOffOut[2] := TrimFlash.Out AND RRollGoGo[0];

	QYRollOffOut[3] := TrimFlash.Out AND RRollGoGo[1];
	QYRollOffOut[4] := TrimFlash.Out AND RRollGoGo[1];

	QYRollOffOut[5] := TrimFlash.Out AND RRollGoGo[2];

END_IF



END_PROGRAM

PROGRAM _INIT

FOR i := 0 TO 5 DO
	TrimFlash.Delay := 100;
	TrimFlash ( Set := 1, Info:=0, Delay := 2000, On := 2000, Comp := 0, Cnt1Adr := ADR ( g_MilliSeconds ), Cnt2Adr := ADR ( g_MilliSeconds ) );
END_FOR

g_TestTaskNo := g_TestTaskNo + 1;
RTaskNo := g_TestTaskNo;
(* Init *)


END_PROGRAM

