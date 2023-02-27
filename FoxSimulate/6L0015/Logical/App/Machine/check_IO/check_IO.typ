(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: check_IO
 * File: check_IO.typ
 * Author: munchp
 * Created: April 30, 2014
 ********************************************************************
 * Local data types of program check_IO
 ********************************************************************)

TYPE
	IO_Force_Type : 	STRUCT 
		pv_name : STRING[80];
		dp_name : STRING[80];
		enableForce : BOOL;
		forceValue : UDINT;
		state : USINT;
	END_STRUCT;
	CheckIO_Type : 	STRUCT 
		boolReturn : BOOL;
		IO_Name : STRING[50];
		IO_Index : UINT;
	END_STRUCT;
END_TYPE
