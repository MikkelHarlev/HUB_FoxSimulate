#ifndef SAX_IMPL_TYPES_H_
#define SAX_IMPL_TYPES_H_


#define CALL_STAT		0
#define RESP_STAT		(CALL_STAT+1)
#define METHOD_STAT		(RESP_STAT+1)
#define FAULT_STAT		(METHOD_STAT+1)
#define ARGLIST_STAT 	(FAULT_STAT+1)
#define PARAM_STAT		(ARGLIST_STAT+1)
#define VAL_STAT		(PARAM_STAT+1)
#define I4_STAT			(VAL_STAT+1)
#define INT_STAT		(I4_STAT+1)
#define BOOL_STAT		(INT_STAT+1)
#define STR_STAT		(BOOL_STAT+1)
#define DOUB_STAT		(STR_STAT+1)
#define TIME_STAT		(DOUB_STAT+1)
#define BIN_STAT		(TIME_STAT+1)
#define STRUC_STAT		(BIN_STAT+1)
#define SNAME_STAT		(STRUC_STAT+1)
#define SMEMBER_STAT	(SNAME_STAT+1)
#define ARRAY_STAT		(SMEMBER_STAT+1)
#define DATA_STAT		(ARRAY_STAT+1)

#define MAX_STAT		(DATA_STAT+1)


struct saxArray ;
struct saxStruct ;
struct saxParam	;


typedef struct saxArray
{
	USINT				size;
	struct saxParam**	array;	
} saxArray_t;


typedef struct saxStruct
{
	char**		names;
	saxArray_t	values;
} saxStruct_t;

typedef struct saxBin64
{
	UDINT		len;
	void*		binVal;
}saxBin64_t;

typedef union saxType
{
	INT				intVal;
	DINT			i4Val;
	BOOL			boolVal;
	char*			strVal;
	REAL			doubleVal;
	char*			timeVal;
	saxBin64_t*		binVal;
	saxArray_t*		arrayVal;
	saxStruct_t*	structVal;
} saxType_t;


typedef struct saxParam
{
	USINT		type;
	saxType_t	value;
} saxParam_t;

typedef struct saxOrigin
{
	USINT	type;
	UDINT	data;
} saxOrigin_t;

typedef struct saxMethod
{
	UDINT			wr_ident;	/* ident for writing back */
	UDINT 			key;
	const char*		name;
	USINT			paramCount;
	USINT			msgType;
	saxParam_t**	paramList;
	saxOrigin_t		callerOrigin;
} saxMethod_t;

typedef struct saxCache
{
	saxArray_t*		pArray; 
	saxStruct_t*	pStruct;
	saxParam_t**	pParam;
}saxCache_t;


typedef struct saxState
{
	saxMethod_t*		pCall;

	USINT				parNest;

	saxParam_t*			pCurrScope;
	saxParam_t*			pParent;
	saxParam_t*			pParCurr;
	USINT*				pParCurrCnt;
	struct saxStack*	pStack;
	struct mm*			pMem;
	struct hEntry*		pHash;

	USINT				rpcFinished;
	USINT				rpcResponse;
	UDINT				rpcCallBack;
	UDINT				rpcTmpRespCB;

	saxOrigin_t			currOriginData;
	
	USINT				saxBroken;
	USINT				saxCharHnd;

#ifdef DBG
	USINT				saxReset;
#endif

}saxState_t;


#endif








