/* Automation Studio generated header file */
/* Do not edit ! */
/* ListHand  */

#ifndef _LISTHAND_
#define _LISTHAND_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "AsString.h"
		#include "AsMem.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define LIST_TYPE_OPERATOR 0U
 #define LIST_TYPE_CUSTOMER 1U
 #define LIST_SEARCH_WHOLE_LIST 2U
 #define LIST_SEARCH_NUMBER_2 3U
 #define LIST_SEARCH_NUMBER_1 2U
 #define LIST_SEARCH_NUMBER_0 1U
 #define LIST_SEARCH_NAME 0U
 #define LIST_SEARCH_LOCKED 4U
 #define LIST_SEARCH_ACTUAL_LIST 0U
 #define LIST_SEARCH_ACT_AND_CHILD 1U
 #define LIST_SCROLL_UP 1U
 #define LIST_SCROLL_PREV_LAYER 4U
 #define LIST_SCROLL_NEXT_LAYER 3U
 #define LIST_SCROLL_LOCKED 4U
 #define LIST_SCROLL_DOWN 2U
 #define LIST_SAVE_LOCKED 2U
 #define LIST_MEMSIZE_OPERATOR_DEFAULT 100000U
 #define LIST_MEMSIZE_CUSTOMER_DEFAULT 2000000U
 #define LIST_LOAD_LOCKED 1U
 #define LIST_HAND_SIZE_STRING_PATH 50313U
 #define LIST_HAND_SIZE_STRING_0 50304U
 #define LIST_HAND_SIZE_INFO_STRUCT 50308U
 #define LIST_HAND_SIZE_ENTRY_STRUCT_0 50318U
 #define LIST_HAND_SIZE_ENTRY_STRUCT 50317U
 #define LIST_HAND_SIZE_ARRAY_0 50303U
 #define LIST_HAND_SEARCH_STRING_0 50311U
 #define LIST_HAND_SEARCH_OPTION_INVALID 50310U
 #define LIST_HAND_SEARCH_NOT_FOUND 50312U
 #define LIST_HAND_INPUT_STRING_POINTER_0 50302U
 #define LIST_HAND_IDENT_WRONG 50307U
 #define LIST_HAND_IDENT_0 50306U
 #define LIST_HAND_FILE_OLD_FORMAT 50319U
 #define LIST_HAND_ENTRY_STRUCT_POINTER_0 50316U
 #define LIST_HAND_ENABLE_0 50300U
 #define LIST_HAND_DELETE_ENTRY_NOT_EXIST 50314U
 #define LIST_HAND_DELETE_CHILD_EXIST 50315U
 #define LIST_HAND_BUSY 65535U
 #define LIST_HAND_ARRAY_POINTER_0 50301U
 #define LIST_HAND_ARRAY_ELEMENT_0 50305U
 #define LIST_EMPTY 50309U
 #define LIST_EDIT_LOCKED 64U
 #define LIST_DELETE_LOCKED 32U
 #define LIST_ADD_LOCKED 16U
 #define LIST_ADD_ITEM_ACT_LAYER 1U
#else
 _GLOBAL_CONST unsigned char LIST_TYPE_OPERATOR;
 _GLOBAL_CONST unsigned char LIST_TYPE_CUSTOMER;
 _GLOBAL_CONST unsigned char LIST_SEARCH_WHOLE_LIST;
 _GLOBAL_CONST unsigned char LIST_SEARCH_NUMBER_2;
 _GLOBAL_CONST unsigned char LIST_SEARCH_NUMBER_1;
 _GLOBAL_CONST unsigned char LIST_SEARCH_NUMBER_0;
 _GLOBAL_CONST unsigned char LIST_SEARCH_NAME;
 _GLOBAL_CONST unsigned short LIST_SEARCH_LOCKED;
 _GLOBAL_CONST unsigned char LIST_SEARCH_ACTUAL_LIST;
 _GLOBAL_CONST unsigned char LIST_SEARCH_ACT_AND_CHILD;
 _GLOBAL_CONST unsigned char LIST_SCROLL_UP;
 _GLOBAL_CONST unsigned char LIST_SCROLL_PREV_LAYER;
 _GLOBAL_CONST unsigned char LIST_SCROLL_NEXT_LAYER;
 _GLOBAL_CONST unsigned short LIST_SCROLL_LOCKED;
 _GLOBAL_CONST unsigned char LIST_SCROLL_DOWN;
 _GLOBAL_CONST unsigned short LIST_SAVE_LOCKED;
 _GLOBAL_CONST unsigned long LIST_MEMSIZE_OPERATOR_DEFAULT;
 _GLOBAL_CONST unsigned long LIST_MEMSIZE_CUSTOMER_DEFAULT;
 _GLOBAL_CONST unsigned short LIST_LOAD_LOCKED;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_STRING_PATH;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_STRING_0;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_INFO_STRUCT;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_ENTRY_STRUCT_0;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_ENTRY_STRUCT;
 _GLOBAL_CONST unsigned short LIST_HAND_SIZE_ARRAY_0;
 _GLOBAL_CONST unsigned short LIST_HAND_SEARCH_STRING_0;
 _GLOBAL_CONST unsigned short LIST_HAND_SEARCH_OPTION_INVALID;
 _GLOBAL_CONST unsigned short LIST_HAND_SEARCH_NOT_FOUND;
 _GLOBAL_CONST unsigned short LIST_HAND_INPUT_STRING_POINTER_0;
 _GLOBAL_CONST unsigned short LIST_HAND_IDENT_WRONG;
 _GLOBAL_CONST unsigned short LIST_HAND_IDENT_0;
 _GLOBAL_CONST unsigned short LIST_HAND_FILE_OLD_FORMAT;
 _GLOBAL_CONST unsigned short LIST_HAND_ENTRY_STRUCT_POINTER_0;
 _GLOBAL_CONST unsigned short LIST_HAND_ENABLE_0;
 _GLOBAL_CONST unsigned short LIST_HAND_DELETE_ENTRY_NOT_EXIST;
 _GLOBAL_CONST unsigned short LIST_HAND_DELETE_CHILD_EXIST;
 _GLOBAL_CONST unsigned short LIST_HAND_BUSY;
 _GLOBAL_CONST unsigned short LIST_HAND_ARRAY_POINTER_0;
 _GLOBAL_CONST unsigned short LIST_HAND_ARRAY_ELEMENT_0;
 _GLOBAL_CONST unsigned short LIST_EMPTY;
 _GLOBAL_CONST unsigned char LIST_EDIT_LOCKED;
 _GLOBAL_CONST unsigned short LIST_DELETE_LOCKED;
 _GLOBAL_CONST unsigned short LIST_ADD_LOCKED;
 _GLOBAL_CONST unsigned char LIST_ADD_ITEM_ACT_LAYER;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct ListOperator_type
{	plcstring Name[33];
	unsigned short OperatorNo;
} ListOperator_type;

typedef struct ListCustomer_type
{	plcstring Name[33];
	unsigned long CustNo;
	unsigned long ArtNo;
	unsigned char RcpNo;
	unsigned short Norm;
	unsigned short FlowTimeOut;
	unsigned short Primary;
	unsigned short Reference;
} ListCustomer_type;

typedef struct ListInfo_Type
{	unsigned short NumberEntryInList;
	unsigned short NumberEntryInLayer;
	unsigned short ActEntryInLayer;
	unsigned char NextLayerLastLayer;
	unsigned char ActLayerLastLayer;
	unsigned char ActLayer;
	unsigned char SelectedItem;
	plcstring StringNextLayer[33];
	plcstring StringActLayer[33];
	plcstring StringPrevLayer[33];
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	unsigned short Status;
} ListInfo_Type;

typedef struct ListEdit
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListEdit_typ;

typedef struct ListLock
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned short LockNumber;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListLock_typ;

typedef struct ListSearch
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char OptionSearch;
	unsigned long pListInfoStruct;
	unsigned long pStringArray;
	unsigned long pEntryStruct;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListSearch_typ;

typedef struct ListDelete
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char optDeleteAll;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListDelete_typ;

typedef struct ListAdd
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdAdd;
	unsigned char optDoSort;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListAdd_typ;

typedef struct ListScroll
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned char cmdScroll;
	unsigned long pListInfoStruct;
	unsigned long pStringArray;
	unsigned long pEntryStruct;
	unsigned char ArrayElementTotal;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListScroll_typ;

typedef struct ListSort
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListSort_typ;

typedef struct ListSave
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pDestName;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListSave_typ;

typedef struct ListLoad
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	unsigned long pSourceName;
	unsigned long pListInfoStruct;
	unsigned long pStringArray;
	unsigned long pEntryStruct;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
	/* VAR_OUTPUT (digital) */
	plcbit ErrCorrupt;
} ListLoad_typ;

typedef struct ListInit
{
	/* VAR_INPUT (analog) */
	unsigned long pStringArray;
	unsigned long pEntryStruct;
	unsigned long pStringPath;
	unsigned long pDevice;
	unsigned long pListInfoStruct;
	unsigned long SizeMemAlloc;
	unsigned short SizeListInfoStruct;
	unsigned short SizeStringArray;
	unsigned short SizeEntryStruct;
	unsigned short SizeStringPath;
	unsigned char ArrayElementTotal;
	unsigned char ListType;
	/* VAR_OUTPUT (analog) */
	unsigned short Status;
	unsigned long Ident;
	plcstring ErrStringInfo[33];
	plcstring ErrStringDetail[33];
	/* VAR_INPUT (digital) */
	plcbit Enable;
} ListInit_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void ListEdit(struct ListEdit* inst);
_BUR_PUBLIC void ListLock(struct ListLock* inst);
_BUR_PUBLIC void ListSearch(struct ListSearch* inst);
_BUR_PUBLIC void ListDelete(struct ListDelete* inst);
_BUR_PUBLIC void ListAdd(struct ListAdd* inst);
_BUR_PUBLIC void ListScroll(struct ListScroll* inst);
_BUR_PUBLIC void ListSort(struct ListSort* inst);
_BUR_PUBLIC void ListSave(struct ListSave* inst);
_BUR_PUBLIC void ListLoad(struct ListLoad* inst);
_BUR_PUBLIC void ListInit(struct ListInit* inst);


#ifdef __cplusplus
};
#endif
#endif /* _LISTHAND_ */

