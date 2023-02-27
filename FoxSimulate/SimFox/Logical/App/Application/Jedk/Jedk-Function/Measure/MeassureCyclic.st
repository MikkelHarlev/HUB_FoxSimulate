(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Measure
 * File: MeasureCyclic.st
 * Author: mha
 * Created: August 30, 2012
 ********************************************************************
 * Implementation of program Meassure
 ********************************************************************)

PROGRAM _CYCLIC


	// Both edges
	LinenSameBoth.In.Ph := IBVertical[1] OR IBHorizontal;
	LinenSameBoth();
	
	// Vertical Only 
	LinenVertical.In.Ph := IBVertical[1] ;
	LinenVertical();
	
	// Horizontal Only 
	LinenHorizontal.In.Ph := IBHorizontal;
	LinenHorizontal();
	
	// Fox Measure
	CalcLengthMode := (LinenMode.Linen.Length * WHEEL_INC_TO_DISTANCE_MM) / 100;
	CalcLengthVertical := (LinenVertical.Linen.Length * WHEEL_INC_TO_DISTANCE_MM) / 100;
	CalcLengthHorizontal := (LinenHorizontal.Linen.Length * WHEEL_INC_TO_DISTANCE_MM) / 100;
	
END_PROGRAM

FUNCTION_BLOCK LinenLengthSinglePh

	// Pointer safe check
	IF ADR(pWheelCounter) < 65536 THEN
		ErrorCode := 1;
		ErrorString := 'pWheelCounter pointer adress error';
		RETURN;
	END_IF
	
	// Same edge input
	IF NOT In.UseSeperateEdges THEN
		In.LeadPh := In.RearPh := In.Ph;
	END_IF

	CASE State OF 

		0: // Leading edge
			IF In.LeadPh THEN
				Linen := EmptyLinen;
				Linen.Lead := pWheelCounter;
				Out.Ready := 0;
				State := 10;
			END_IF
	
		10: // Rear edge
			IF NOT In.RearPh THEN
				Linen.Rear := pWheelCounter;
				Linen.Length := Linen.Rear - Linen.Lead;
				State := 20;
			END_IF
			
		20: // Wait ready
			IF NOT In.LeadPh THEN
				Out.Ready := 1;
				State := 0;
			END_IF				
	END_CASE

END_FUNCTION_BLOCK

