(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: BRSE_STF
 * File: BRSE_STF.typ
 * Author: mar
 * Created: March 27, 2009
 ********************************************************************
 * Data types of library BRSE_STF
 ********************************************************************)

TYPE
	StructState_typ : 	STRUCT 
		StructName : STRING[33];
		CurrentItemNbr : UINT;
		Dimension : UINT;
		ItemType : USINT; (*1=struct item, 2=array item, 0=nothing*)
	END_STRUCT;
END_TYPE
