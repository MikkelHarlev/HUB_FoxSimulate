(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: Top_Conveyor
 * File: TopConveyor.typ
 * Author: mha
 * Created: September 24, 2013
 ********************************************************************
 * Local data types of program Top_Conveyor
 ********************************************************************)

TYPE
	TCLinen_Type : 	STRUCT 
		ProductID : UINT;
		ExtraRunTime : UDINT;
		Ph1PosCountStampWhl : UDINT;
		Ph1NegCountStampWhl : UDINT;
		Ph2PosCountStampWhl : UDINT;
		Check_Ph1NegCountStampWhl : UDINT;
		Check_Ph1PosCountStampWhl : UDINT;
		Check_Ph2PosCountStampWhl : UDINT;
		LengthWhl1Ph : UINT;
		LengthWhl : UINT;
		Length1Ph_mm : UINT;
		Length_mm : UINT;
		LengthOrgTC_mm : UINT;
	END_STRUCT;
END_TYPE
