(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: JenSQL
 * File: JenSQL.typ
 * Author: flystes
 * Created: August 25, 2014
 ********************************************************************
 * Data types of library JenSQL
 ********************************************************************)

TYPE
	JenSQLDataFill_Type : 	STRUCT 
		DataVariableAddressListPointer : UDINT;
		DataFieldNameListPointer : UDINT;
		DataVariableFields : UINT;
		DataFieldNameStartPos : UINT;
	END_STRUCT;
	JenSqlInfo_Type : 	STRUCT 
		Ident : UDINT;
		cmdDB : UINT;
		Action : UINT;
		ReConnectTimer : UINT;
		ReConnectTime : UINT;
		ReTableTimer : UINT;
		ReTableTime : UINT;
		CurTimer : UINT;
		ConnectState : UINT;
		analysinfo : UINT;
		SQLString : STRING[MAX_SQL_STRING_SIZE];
		SP_InsertName : STRING[MAX_SQL_STRING_SIZE];
		SP_CreateName : STRING[MAX_SQL_STRING_SIZE];
		FullRecordName : STRING[MAX_SQL_STRING_SIZE];
		DataFieldStructure : JenSQLDataFill_Type;
		IPString : STRING[21];
		UserName : STRING[21];
		Password : STRING[21];
		DbName : STRING[21];
		ColInx : UINT;
		DataType : UINT;
		DataString : STRING[121];
		ErrorString : STRING[MAX_SQL_STRING_SIZE];
		ErrorCode : UINT;
		DataSize : UINT;
		CreateProcedure : ARRAY[0..MAX_SQL_STRING_SIZE] OF USINT;
		InsertProcedure : ARRAY[0..MAX_SQL_STRING_SIZE] OF USINT;
		TableName : STRING[41];
		VariableStructName : STRING[41];
		VariableStructNameSize : UINT;
		VarTypeInt : REFERENCE TO INT;
		VarTypeUInt : REFERENCE TO UINT;
		VarTypeSInt : REFERENCE TO SINT;
		VarTypeUSInt : REFERENCE TO USINT;
		VarTypeDInt : REFERENCE TO DINT;
		VarTypeUDInt : REFERENCE TO UDINT;
		VarTypeString : REFERENCE TO STRING[256];
		AffectedRows : UDINT;
		debugLevel : USINT;
	END_STRUCT;
END_TYPE
