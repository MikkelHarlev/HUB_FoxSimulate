(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Meassure
 * File: Meassure.typ
 * Author: mha
 * Created: August 30, 2012
 ********************************************************************
 * Local data types of program Meassure
 ********************************************************************)

TYPE
	LinenLengthFunctionOut_Type : 	STRUCT 
		Ready : BOOL;
	END_STRUCT;
	LinenLengthFunctionIn_Type : 	STRUCT 
		UseSeperateEdges : BOOL;
		Ph : BOOL;
		LeadPh : BOOL;
		RearPh : BOOL;
	END_STRUCT;
	LinenLengthFunctionLinen_Type : 	STRUCT 
		Lead : UDINT;
		Rear : UDINT;
		Length : UDINT;
	END_STRUCT;
	Count_Type : 	STRUCT 
		Lead : UDINT;
		Rear : UDINT;
		Length : UDINT;
	END_STRUCT;
	Linen_Type : 	STRUCT 
		State : USINT;
		PhModeCount : Count_Type;
	END_STRUCT;
END_TYPE
