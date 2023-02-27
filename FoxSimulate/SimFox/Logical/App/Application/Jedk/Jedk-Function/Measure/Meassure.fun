(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Meassure
 * File: Meassure.fun
 * Author: mha
 * Created: August 30, 2012
 ********************************************************************
 * Functions and function blocks of program Meassure
 ********************************************************************)

FUNCTION_BLOCK LinenLengthSinglePh
	VAR_INPUT
		pWheelCounter : REFERENCE TO UDINT;
		In : LinenLengthFunctionIn_Type;
	END_VAR
	VAR_OUTPUT
		Out : LinenLengthFunctionOut_Type;
		ErrorString : STRING[100];
		ErrorCode : UINT;
	END_VAR
	VAR
		State : USINT;
	END_VAR
	VAR_OUTPUT
		Linen : LinenLengthFunctionLinen_Type;
	END_VAR
	VAR
		EmptyLinen : LinenLengthFunctionLinen_Type;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK TaskFunk (*TODO: Add your comment here*)
	VAR_INPUT
		AccessMode : USINT;
		pInParam : REFERENCE TO UDINT;
		InputCode : USINT;
	END_VAR
	VAR_OUTPUT
		OutPar : UDINT;
	END_VAR
	VAR
		LocalVar : UDINT;
		RInit : BOOL := TRUE;
		CycleCounter : UDINT;
	END_VAR
END_FUNCTION_BLOCK
