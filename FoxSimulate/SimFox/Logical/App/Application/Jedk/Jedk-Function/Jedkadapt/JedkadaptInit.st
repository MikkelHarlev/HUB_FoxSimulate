(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Jedkadapt
 * File: JedkadaptInit.st
 * Author: mha
 * Created: July 20, 2012
 ********************************************************************
 * Implementation of program Jedkadapt
 ********************************************************************)
PROGRAM _INIT
	RConnectVacuumInlet := 1;
	g_HideStackChange := 1;
	GarmentPressDelay10ms := 10;
	BGarmentDetection(Filter := 30, FMode := 3, TMode := 0, CntAdr := ADR(g_MilliSeconds));
	HangerWide := 1500;

	// Delay Infeed start
	InfeedDelay(PT := T#200ms);

	BXBFold_Filter(Filter := 50, FMode := 2, TMode := 0, CntAdr := ADR(g_MilliSeconds));
	OutletDelay_Filter(Filter := 50, FMode := 2, TMode := 0, CntAdr := ADR(g_MilliSeconds));

	BuzzerShort(Cnt1Adr := ADR(g_MilliSeconds), Cnt2Adr := ADR(g_MilliSeconds), Delay := 1500, On := 40);
	BuzzerLong(CntAdr := ADR(g_MilliSeconds), Delay := 750);

	StopValveTime := 100;

	ISEmergencyOk := 1;
	ISHangerOutletFree := 1;
END_PROGRAM