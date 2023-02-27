(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: CockpitLogData
 * File: CockpitLogData.typ
 * Author: duem
 * Created: November 12, 2014
 ********************************************************************
 * Local data types of program CockpitLogData
 ********************************************************************)

TYPE
	SqlExporter_State : 
		(
		Export_FindLine,
		Export_PrepData,
		Export_SQLAddData,
		Export_SQLCheckData_Cmd,
		Export_SQLCheckData_Check,
		Export_SetPointer,
		CHECK_CONNECTION_STATUS,
		Export_CheckLineSet,
		RECONNECT
		);
	ConvertionList_typ : 	STRUCT  (*BRHC: THIS ONE WAS NEEDED TO BE ADDED*)
		Address : USINT; (*BRHC: THIS ONE WAS NEEDED TO BE ADDED*)
		DataTyp : USINT; (*BRHC: THIS ONE WAS NEEDED TO BE ADDED*)
	END_STRUCT;
END_TYPE
