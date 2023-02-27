(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Measure
 * File: MeassreInit.st
 * Author: mha
 * Created: August 30, 2012
 ********************************************************************
 * Implementation of program Meassure
 ********************************************************************)

PROGRAM _INIT

	LinenMode.pWheelCounter := ADR(g_WheelCounter);
	LinenMode.In.UseSeperateEdges := 1;
	LinenMode();
	
	LinenMode( pWheelCounter := ADR(g_WheelCounter) );
	LinenSameBoth( pWheelCounter := ADR(g_WheelCounter) );
	LinenVertical( pWheelCounter := ADR(g_WheelCounter) );
	LinenHorizontal( pWheelCounter := ADR(g_WheelCounter) );

	g_FoxLengthNoDiscount := 0;
	g_FoxLengthFinal := 0;
	
END_PROGRAM

