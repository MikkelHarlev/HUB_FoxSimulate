(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Meassure
 * File: TaskFunk.st
 * Author: mha
 * Created: August 30, 2012
 ********************************************************************
 * Implementation of program Meassure
 ********************************************************************) 

(* TODO: Add your comment here *)




// Test the B&R Reference input Null-Pointer mess
FUNCTION_BLOCK TaskFunk
	
	// Mode
	// 0: Copy only by watch - Set InputCode = 5
	// 1: After scans
	// 2: Init passed
	// 3: Immediately
	
	CycleCounter := CycleCounter + 1;

	LocalVar := pInParam;
	CASE AccessMode OF
		
		0: 
			IF InputCode = 5 THEN
				LocalVar := pInParam;
			END_IF
			
		1:
			IF CycleCounter > 1000 THEN
				LocalVar := pInParam;
			END_IF
			
		2:
			IF NOT RInit THEN
				LocalVar := pInParam;
			END_IF
				
		3:
			LocalVar := pInParam;
			
	END_CASE
	
END_FUNCTION_BLOCK

