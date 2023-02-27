/* Automation Studio generated header file */
/* Do not edit ! */
/* jenxml 4.00.0 */

#ifndef _JENXML_
#define _JENXML_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _jenxml_VERSION
#define _jenxml_VERSION 4.00.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "ListHand.h"
#endif
#ifdef _SG4
		#include "ListHand.h"
#endif
#ifdef _SGC
		#include "ListHand.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define ARRAY_SIZE_OF_CARHANDLER_LIST 100U
#else
 _GLOBAL_CONST unsigned short ARRAY_SIZE_OF_CARHANDLER_LIST;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct JenLogging_Type
{	unsigned char cmdAdd;
	unsigned char cmdReadFirst;
	unsigned char cmdReadNext;
	unsigned char cmdSetLogPointer;
	unsigned long entriesRead;
	unsigned short Status;
	plcstring ErrInfoString[33];
	plcstring ErrInfoDetail[33];
} JenLogging_Type;

typedef struct CustomerOpt_type
{	unsigned char DoSortAfterAdd;
} CustomerOpt_type;

typedef struct CustomerCmd_type
{	unsigned char cmdUnlockList;
	unsigned char cmdLoadList;
	unsigned char cmdSaveList;
	unsigned char cmdScroll;
	unsigned char cmdAddItem;
	unsigned char cmdDeleteItem;
	unsigned char cmdDeleteList;
	unsigned char cmdSearchCustArt;
	unsigned char cmdSearchCustNo;
	unsigned char cmdSearchArtNo;
	unsigned char cmdSearchCustArtNo;
	unsigned char cmdLockList;
	unsigned char cmdEditItem;
	unsigned char cmdSelect;
} CustomerCmd_type;

typedef struct CustomerRdy_type
{	unsigned char rdyLoadList;
	unsigned char rdySaveList;
	unsigned char rdyScroll;
	unsigned char rdyAddItem;
	unsigned char rdyDeleteItem;
	unsigned char rdyDeleteList;
	unsigned char rdySearchCustArt;
	unsigned char rdySearchCustNo;
	unsigned char rdySearchArtNo;
	unsigned char rdySearchCustArtNo;
	unsigned char rdyLockList;
	unsigned char rdyUnlockList;
	unsigned char rdyEditItem;
} CustomerRdy_type;

typedef struct CustomerError_type
{	unsigned short Status;
	unsigned char ErrStringInfo[32];
	unsigned char ErrStringDetail[32];
	unsigned char EntryLegal;
} CustomerError_type;

typedef struct CustomerVis_type
{	plcstring ItemList[8][33];
} CustomerVis_type;

typedef struct CustomerEntry_type
{	plcstring Name[33];
	unsigned long CustNo;
	unsigned long ArtNo;
	unsigned char RcpNo;
	unsigned short Norm;
	unsigned short FlowTimeOut;
	unsigned short Primary;
	unsigned short Reference;
} CustomerEntry_type;

typedef struct Customer_type
{	struct CustomerOpt_type Option;
	struct CustomerCmd_type Cmd;
	struct CustomerRdy_type Rdy;
	struct CustomerError_type Error;
	struct CustomerVis_type Vis;
	struct CustomerEntry_type Entry;
	struct ListInfo_Type ListInfo;
} Customer_type;

typedef struct OperatorOpt_type
{	unsigned char DoSortAfterAdd;
} OperatorOpt_type;

typedef struct OperatorCmd_type
{	unsigned char cmdLoadList;
	unsigned char cmdSaveList;
	unsigned char cmdScroll;
	unsigned char cmdAddItem;
	unsigned char cmdDeleteItem;
	unsigned char cmdDeleteList;
	unsigned char cmdSearchName;
	unsigned char cmdSearchNumber;
	unsigned char cmdLockList;
	unsigned char cmdUnlockList;
	unsigned char cmdEditItem;
	unsigned char cmdSelect;
	unsigned char cmdLogout;
} OperatorCmd_type;

typedef struct OperatorRdy_type
{	unsigned char rdyLoadList;
	unsigned char rdySaveList;
	unsigned char rdyScroll;
	unsigned char rdyAddItem;
	unsigned char rdyDeleteItem;
	unsigned char rdyDeleteList;
	unsigned char rdySearchName;
	unsigned char rdySearchNumber;
	unsigned char rdyLockList;
	unsigned char rdyUnlockList;
	unsigned char rdyEditItem;
} OperatorRdy_type;

typedef struct OperatorError_type
{	unsigned short Status;
	unsigned char ErrStringInfo[32];
	unsigned char ErrStringDetail[32];
	unsigned char EntryLegal;
} OperatorError_type;

typedef struct OperatorVis_type
{	plcstring ItemList[8][33];
} OperatorVis_type;

typedef struct OperatorEntry_type
{	plcstring Name[33];
	unsigned short OperatorNo;
} OperatorEntry_type;

typedef struct Operator_type
{	struct OperatorOpt_type Option;
	struct OperatorCmd_type Cmd;
	struct OperatorRdy_type Rdy;
	struct OperatorError_type Error;
	struct OperatorVis_type Vis;
	struct OperatorEntry_type Entry;
	struct ListInfo_Type ListInfo;
} Operator_type;

typedef struct CfgAdd_Type
{	unsigned char cmdAdd;
	unsigned short NewCfgNumber;
} CfgAdd_Type;

typedef struct CfgCopy_Type
{	unsigned short CfgSourceNumber;
	unsigned short CfgDestBegin;
	unsigned short CfgDestEnd;
	unsigned char cmdCopyCfg;
} CfgCopy_Type;

typedef struct CfgNameList_Type
{	unsigned char cmdInit;
	unsigned char cmdScrollUp;
	unsigned char cmdScrollDown;
	unsigned char cmdCfgNameSelect;
	unsigned char cmdGetNames;
	unsigned char SelectedItem;
	unsigned short SelectedRcpNumber;
	plcstring RcpNameArray[99][33];
	unsigned char cmdGotoIndex;
} CfgNameList_Type;

typedef struct CfgFileList_Type
{	plcstring FileNameArray[5][33];
	unsigned char cmdUp;
	unsigned char cmdDown;
	unsigned char cmdDirList;
	unsigned char cmdNewFile;
	unsigned char SelectedItem;
} CfgFileList_Type;

typedef struct CfgParScro_Type
{	plcstring ParScrollArray[501][61];
	plcstring ParValueArray[501][51];
	plcstring ParNameArray[501][26];
	plcstring VarNameArray[501][61];
	plcstring ActParValue[51];
	unsigned char cmdScrollUp;
	unsigned char cmdScrollDown;
	unsigned char cmdEditPar;
	unsigned char cmdParListRcpChange;
	unsigned short SelectRcpNumber;
	unsigned short SelectedItem;
	unsigned short cmdGotoIndex;
	unsigned short cmdScrollIndex;
} CfgParScro_Type;

typedef struct Cfg_Type
{	unsigned char InitDone;
	unsigned char cmdLoadCfg;
	unsigned char cmdSaveCfg;
	plcstring CfgName[33];
	unsigned long Ident;
	plcstring StatusString[33];
	struct CfgAdd_Type CfgAdd;
	struct CfgCopy_Type CfgCopy;
	struct CfgNameList_Type NameList;
	struct CfgFileList_Type FileList;
	struct CfgParScro_Type ParScroll;
	struct RcpExtInfo_Type CfgExtInfo;
} Cfg_Type;






#ifdef __cplusplus
};
#endif
#endif /* _JENXML_ */

