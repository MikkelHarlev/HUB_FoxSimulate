(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: Jedkadapt
 * File: Jedkadapt.typ
 * Author: mha
 * Created: July 20, 2012
 ********************************************************************
 * Local data types of program Jedkadapt
 ********************************************************************)

TYPE
	LinenDetect_Type : 	STRUCT 
		State : USINT;
		Start : BOOL;
		HangerTimeout : BOOL;
		HangerCountstamp : UDINT;
		CheckPoint : UDINT;
	END_STRUCT;
END_TYPE
