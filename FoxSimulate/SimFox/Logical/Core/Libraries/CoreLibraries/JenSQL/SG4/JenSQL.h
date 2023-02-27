/* Automation Studio generated header file */
/* Do not edit ! */
/* JenSQL 1.18.1 */

#ifndef _JENSQL_
#define _JENSQL_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _JenSQL_VERSION
#define _JenSQL_VERSION 1.18.1
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Constants */
#ifdef _REPLACE_CONST
 #define MAX_SQL_STRING_SIZE 512U
 #define DB_CONNECT_1 1U
 #define DB_DISCONNECT_2 2U
 #define DB_SQL_EXECUTE_3 3U
 #define DB_SQL_ADD_5 5U
 #define DB_GET_DATA_4 4U
 #define DB_GET_ERROR_9 9U
 #define DB_GET_AFFEECTEDROWS_10 10U
 #define DB_ACTION_CREATE_1 1U
 #define DB_ACTION_FREE_9 9U
 #define DB_ACTION_IDLE_0 0U
 #define DB_ACTION_CHECK_TABLE_4 4U
 #define DB_ACTION_CHECK_CREATE_5 5U
#else
 _GLOBAL_CONST unsigned short MAX_SQL_STRING_SIZE;
 _GLOBAL_CONST unsigned short DB_CONNECT_1;
 _GLOBAL_CONST unsigned short DB_DISCONNECT_2;
 _GLOBAL_CONST unsigned short DB_SQL_EXECUTE_3;
 _GLOBAL_CONST unsigned short DB_SQL_ADD_5;
 _GLOBAL_CONST unsigned short DB_GET_DATA_4;
 _GLOBAL_CONST unsigned short DB_GET_ERROR_9;
 _GLOBAL_CONST unsigned short DB_GET_AFFEECTEDROWS_10;
 _GLOBAL_CONST unsigned short DB_ACTION_CREATE_1;
 _GLOBAL_CONST unsigned short DB_ACTION_FREE_9;
 _GLOBAL_CONST unsigned short DB_ACTION_IDLE_0;
 _GLOBAL_CONST unsigned short DB_ACTION_CHECK_TABLE_4;
 _GLOBAL_CONST unsigned short DB_ACTION_CHECK_CREATE_5;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenSQLDataFill_Type
{	unsigned long DataVariableAddressListPointer;
	unsigned long DataFieldNameListPointer;
	unsigned short DataVariableFields;
	unsigned short DataFieldNameStartPos;
} JenSQLDataFill_Type;

typedef struct JenSqlInfo_Type
{	unsigned long Ident;
	unsigned short cmdDB;
	unsigned short Action;
	unsigned short ReConnectTimer;
	unsigned short ReConnectTime;
	unsigned short ReTableTimer;
	unsigned short ReTableTime;
	unsigned short CurTimer;
	unsigned short ConnectState;
	unsigned short analysinfo;
	plcstring SQLString[513];
	plcstring SP_InsertName[513];
	plcstring SP_CreateName[513];
	plcstring FullRecordName[513];
	struct JenSQLDataFill_Type DataFieldStructure;
	plcstring IPString[22];
	plcstring UserName[22];
	plcstring Password[22];
	plcstring DbName[22];
	unsigned short ColInx;
	unsigned short DataType;
	plcstring DataString[122];
	plcstring ErrorString[513];
	unsigned short ErrorCode;
	unsigned short DataSize;
	unsigned char CreateProcedure[513];
	unsigned char InsertProcedure[513];
	plcstring TableName[42];
	plcstring VariableStructName[42];
	unsigned short VariableStructNameSize;
	signed short* VarTypeInt;
	unsigned short* VarTypeUInt;
	signed char* VarTypeSInt;
	unsigned char* VarTypeUSInt;
	signed long* VarTypeDInt;
	unsigned long* VarTypeUDInt;
	plcstring (*VarTypeString)[257];
	unsigned long AffectedRows;
	unsigned char debugLevel;
} JenSqlInfo_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned short JenSQLAnalysDataStruct(plcstring* VarName, struct JenSQLDataFill_Type* VarFillStruct);
_BUR_PUBLIC unsigned short JenSqlInit(unsigned long pSqlInfo);
_BUR_PUBLIC unsigned short JenSqlRun(unsigned long pSqlInfo);


#ifdef __cplusplus
};
#endif
#endif /* _JENSQL_ */

