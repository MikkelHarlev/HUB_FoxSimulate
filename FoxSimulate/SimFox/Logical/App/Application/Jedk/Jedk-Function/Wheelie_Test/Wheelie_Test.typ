(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Wheelie_Test
 * File: Wheelie_Test.typ
 * Author: pmu
 * Created: May 01, 2013
 ********************************************************************
 * Local data types of program Wheelie_Test
 ********************************************************************)

TYPE
	TestWheel_Type : 	STRUCT 
		CountStart : ARRAY[0..9] OF UDINT;
		CountStartTest : ARRAY[0..9] OF UDINT;
		Count : ARRAY[0..9] OF UDINT;
		CountTest : ARRAY[0..9] OF UDINT;
		Time : ARRAY[0..9] OF UDINT;
		StartDelay : UDINT;
		cmdStart : BOOL;
	END_STRUCT;
END_TYPE
