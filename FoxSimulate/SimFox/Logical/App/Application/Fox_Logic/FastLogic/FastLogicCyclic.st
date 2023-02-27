(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * PROGRAM: FastLogic
 * File: FastLogicCyclic.st
 * Author: flystes
 * Created: February 17, 2015
 ********************************************************************
 * Implementation OF PROGRAM FastLogic
 ********************************************************************)
PROGRAM _CYCLIC
	
	IF EDGEPOS(IIJamDeloadingOut) THEN
		IF JamDeloadOutCheck[i] > 0 AND JamDeloadOutCheck[i] < JamDeloadOutCheckMin THEN
			JamDeloadOutCheckMin := JamDeloadOutCheck[i];
		END_IF
		i := (i + 1) MOD (SIZEOF(JamDeloadOutCheck) / SIZEOF(JamDeloadOutCheck[0]) - 2);
		JamDeloadOutCheck[i] := 0;	
	END_IF
	IF IIJamDeloadingOut THEN
		JamDeloadOutCheck[i] := JamDeloadOutCheck[i] + 1;
	END_IF
	
	JamDeloadingOut_Filter(In := IIJamDeloadingOut, Filter := 10, FMode := 2, TMode := 0, CntAdr := ADR(g_MilliSeconds)); // filter value changed from 20
	g_JamDeloadingOut := JamDeloadingOut_Filter.Out;

	RTime(enable := TRUE);
	//g_Time.Date_Time := RTime.DT1;
	//DT_TO_DTStructure(RTime.DT1, ADR(g_Time.Split));
	g_MilliSeconds := TIME_TO_UDINT( clock_ms());

	IF RMilliSeconds = 0 THEN
		RMilliSeconds := g_MilliSeconds;
	ELSE
		RMilliSeconds := RMilliSeconds + 1;
	END_IF

	IF RMilliSeconds <> g_MilliSeconds THEN
		WrongMilli := WrongMilli + 1;
	END_IF
	
	// Test wheel count brakes
	IF IWhC XOR RCounterWheel THEN
		PulsTime[i] := g_MilliSeconds - PulsTimeStamp;
		i := (i + 1) MOD 20;
		IF IWhC THEN
			PulsTimeOff[iOff] := g_MilliSeconds - PulsTimeStamp;
			iOff := (iOff + 1) MOD 10;
		ELSE
			PulsTimeOn[iOn] := g_MilliSeconds - PulsTimeStamp;
			iOn := (iOn + 1) MOD 10;
		END_IF
		PulsTimeStamp := g_MilliSeconds;
		g_WheelCounter := g_WheelCounter + 1;
	END_IF
	RCounterWheel := IWhC;

	//	//Jedk adapt!
	//	//------------------------------------------------------------------------
	//	// What about multi blow for the sleeves...
	//	//------------------------------------------------------------------------
	//
	//	// Pules
	//	g_MCfg.MultiBlowPules := LIMIT(1, g_MCfg.MultiBlowPules, 10);
	//	
	//	// Start
	//	// Find actual AutoProgram
	//	IF g_Core.Services.AutoProg.Runtime.autoprogPointer > 0 THEN
	//		LocalAutoProgram ACCESS(ADR(DummyAutoProgram));
	//	ELSIF (g_HangerInletProcess.Common.Product.FoldProgram > 0) AND (g_HangerInletProcess.Common.Product.FoldProgram <> LastUsedAutoProgram) THEN
	//		LocalAutoProgram ACCESS(g_Core.Services.AutoProg.Runtime.autoprogPointer + (SIZEOF(LocalAutoProgram) * LIMIT(0, (g_HangerInletProcess.Common.Product.FoldProgram - 1), MAX_NUMBER_OF_AUTOPROGRAMS)));
	//		LastUsedAutoProgram := g_HangerInletProcess.Common.Product.FoldProgram;
	//	ELSIF g_HangerInletProcess.Common.Product.FoldProgram = 0 THEN
	//		LocalAutoProgram ACCESS(ADR(DummyAutoProgram));
	//	END_IF
	//
	//	IF EDGEPOS(QYCHAirShortArmLeft) THEN
	//		LeftArmBp.On := LocalAutoProgram.ArmBlowOnTime[1] / g_MCfg.MultiBlowPules;
	//		LeftArmBp.OutCount := g_MCfg.MultiBlowPules;
	//		LeftArmBp.Set := 1;
	//	END_IF
	//	IF EDGEPOS(QYCHAirShortArmRight) THEN
	//		RightArmBp.On := LocalAutoProgram.ArmBlowOnTime[0] / g_MCfg.MultiBlowPules;
	//		RightArmBp.OutCount := g_MCfg.MultiBlowPules;
	//		RightArmBp.Set := 1;
	//	END_IF
	//
	//	// Function
	//	IF RActiveFunc THEN
	//		LeftArmBpFunction();
	//		RightArmBpFunction();
	//	END_IF
	//
	//	// Activate
	//	IF RUseMultiBlow THEN
	//		QYAirLeftSleeve := LeftArmBp.Out;
	//		QYAirRightSleeve := RightArmBp.Out;
	//	ELSE
	//		QYAirLeftSleeve := QYCHAirShortArmLeft;
	//		QYAirRightSleeve := QYCHAirShortArmRight;
	//	END_IF
END_PROGRAM