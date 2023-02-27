(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Library: JEGR_Coop
 * File: JEGR_Coop.typ
 * Author: eg
 * Created: June 09, 2010
 ********************************************************************
 * Data types of library JEGR_Coop
 ********************************************************************)

TYPE
	PassWord_Type : 	STRUCT 
		Code : UDINT;
		String : STRING[4];
	END_STRUCT;
	MachinePermInfo_Type : 	STRUCT 
		Byte : ARRAY[0..16] OF USINT;
	END_STRUCT;
END_TYPE
