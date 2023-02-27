(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: JenSQL
 * File: JenSQL.fun
 * Author: flystes
 * Created: August 25, 2014
 ********************************************************************
 * Functions and function blocks of library JenSQL
 ********************************************************************)

FUNCTION JenSQLAnalysDataStruct : UINT (*TODO: Add your comment here*)
	VAR_INPUT
		VarName : STRING[81];
		VarFillStruct : JenSQLDataFill_Type;
	END_VAR
END_FUNCTION

FUNCTION JenSqlInit : UINT (*TODO: Add your comment here*)
	VAR_INPUT
		pSqlInfo : UDINT;
	END_VAR
END_FUNCTION

FUNCTION JenSqlRun : UINT (*TODO: Add your comment here*)
	VAR_INPUT
		pSqlInfo : UDINT;
	END_VAR
END_FUNCTION
