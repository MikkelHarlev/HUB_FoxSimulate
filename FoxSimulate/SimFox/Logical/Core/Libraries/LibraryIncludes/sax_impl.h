#ifndef SAX_IMPL_H
#define SAX_IMPL_H

#ifdef WIN32 /*define BR_AR types */
#define XML_RPC_API __declspec(dllexport)


#undef V_I4
#undef V_INT
#undef V_BOOL


#ifndef UDINT
#define UDINT	unsigned int
#endif
#ifndef DINT
#define DINT	int
#endif
#ifndef UINT
#define UINT	unsigned short
#endif
#ifndef INT
#define INT		short
#endif
#ifndef USINT
#define USINT	unsigned char
#endif
#ifndef SINT
#define SINT	char
#endif
#ifndef BOOL
#define BOOL	char
#endif
#ifndef REAL
#define REAL	double
#endif

#include "xmlhash.h"
#define xmlHash hash
#define xmlnHash hash_nodelim

#ifndef XML_Char_defined
	typedef char XML_Char;

	#define XML_Char_defined 1
#endif


#define TMP_alloc( s, ptr ) ( (*(ptr)) = malloc( s ), (*(ptr))?0:-1 )
#define TMP_free( s, ptr ) ( free( (ptr) ), 0 )

#else /* WIN32 end BR_AR and others start */
#include <bur/plc.h>
#include <bur/plctypes.h>

#define XML_RPC_API

#ifndef XML_Char_defined
	typedef char XML_Char;

	#define XML_Char_defined 1
#endif
typedef XML_Char* KEY;

#define xmlnHash( key, len) hash_nodelim( (KEY) key, len )

#endif /* BR_AR and others */

#define DBG 1

#include "sax_hash.h"

#define MCALL	"methodCall"
#define MRESP	"methodResponse"
#define MFAULT	"fault"
#define MNAM	"methodName"
#define PARLIST "params"
#define PARAM	"param"
#define VAL		"value"

#define V_I4	"i4"
#define V_INT	"int"
#define V_BOOL	"boolean"
#define V_STR	"string"
#define V_DOUB	"double"
#define V_T		"dateTime.iso8601"
#define V_BIN	"base64"

#define STRUCT	"struct"
#define S_NAME	"name"
#define S_MEMB	"member"

#define ARRAY	"array"
#define A_DATA	"data"


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


/*extern UDINT	gParser;*/

typedef struct XML_Request
{
	int		len;
	char*	ptr;
} XML_Request_t;

XML_Request_t	gXMLRet;



typedef enum { eStart =0, eEnd, eProc, eVal, eType } saxDir_t;


struct saxState;
int 	processor	( struct saxState* pState, hEntry_t* e, int key, const char* data, saxDir_t dir );


/*
	HANDLER and Types (SAX)
*/
/*
	warning !!! HARDCODED limits for the sake of proof of concept only
	please change
	50
*/


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

#ifdef DBG
	USINT				saxReset;
#endif

}saxState_t;

#define GET_STATE( ptr )	saxState_t* pState = ( ( saxState_t* ) ptr )

/*extern saxMethod_t*	gCall;*/

typedef USINT saxRPC_t	( saxMethod_t* );

void SAX_CALL( saxState_t*, saxMethod_t* );
void SAX_RESPONSE( saxState_t*, saxMethod_t* );

/*
	add a function to be called
*/
XML_RPC_API void		addRPCHandler		( saxRPC_t*, const char* );
XML_RPC_API saxRPC_t*	getRPCHandler		( const char*, HASH );

XML_RPC_API void		addRPCDefaultHandler( saxRPC_t* );
XML_RPC_API saxRPC_t*	getRPCDefaultHandler( void );


XML_RPC_API void		addRPCResultHandler( saxRPC_t* );
XML_RPC_API saxRPC_t*	getRPCResultHandler( void );


#include "sax_def.h"
#include "sax_stack.h"


#endif /*SAX_IMPL_H*/


