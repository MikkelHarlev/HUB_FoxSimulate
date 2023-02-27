/* Automation Studio generated header file */
/* Do not edit ! */
/* CacheLib 4.01.0 */

#ifndef _CACHELIB_
#define _CACHELIB_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _CacheLib_VERSION
#define _CacheLib_VERSION 4.01.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "CRC_internal.h"
		#include "AsUDP.h"
		#include "AsETH.h"
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "CRC_internal.h"
		#include "AsUDP.h"
		#include "AsETH.h"
#endif
#ifdef _SGC
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "CRC_internal.h"
		#include "AsUDP.h"
		#include "AsETH.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define MKUDPMirrorMAX 1500U
 #define MKCacheERRORnone 0U
 #define MKCacheERRORfile 12U
 #define MKCacheERRORbadDM 11U
 #define HANGER_FLAG_UFO 1U
 #define HANGER_FLAG_VALID 2U
 #define HANGER_MAX_ADDRESS 10U
 #define MKCacheERRORcheckAge 51U
 #define MKCacheERRORcheckFree 50U
 #define MKCacheERRORcheckHash 52U
 #define MKCacheERRORcheckMirror 54U
 #define MKCacheERRORbadID 40U
 #define MKCacheERRORbadMirrorIdx 70U
 #define MKCacheERRORcritSection 64U
 #define CACHE_STATE_OK 10U
 #define MKCacheERRORPosUsed 80U
 #define CACHE_STATE_NOT_READY 901U
 #define HANGER_FLAG_PRESORT_ALLOCATE 8U
 #define CACHE_STATE_FAIL 1001U
 #define HANGER_FLAG_DB_DATA 32U
 #define HANGER_FLAG_NOT_FOUND 4U
 #define HANGER_FLAG_BAD_FEED 16U
 #define MKCacheERRORnullHash 30U
 #define MKCacheERRORnullBase 2U
 #define StackStringLength 100U
 #define PresortStringLength 100U
 #define RouteLength 30U
 #define ArticleSizeLength 24U
 #define CustomerIDLength 24U
 #define ArticleIDLength 24U
 #define ArticleNameLength 30U
 #define CustomerNameLength 30U
 #define IDLength 24U
 #define InfoTextLength 40U
 #define EmployeeIDLength 24U
 #define EmployeeNameLength 30U
#else
 _GLOBAL_CONST unsigned long MKUDPMirrorMAX;
 _GLOBAL_CONST unsigned short MKCacheERRORnone;
 _GLOBAL_CONST unsigned short MKCacheERRORfile;
 _GLOBAL_CONST unsigned short MKCacheERRORbadDM;
 _GLOBAL_CONST unsigned short HANGER_FLAG_UFO;
 _GLOBAL_CONST unsigned short HANGER_FLAG_VALID;
 _GLOBAL_CONST unsigned short HANGER_MAX_ADDRESS;
 _GLOBAL_CONST unsigned short MKCacheERRORcheckAge;
 _GLOBAL_CONST unsigned short MKCacheERRORcheckFree;
 _GLOBAL_CONST unsigned short MKCacheERRORcheckHash;
 _GLOBAL_CONST unsigned short MKCacheERRORcheckMirror;
 _GLOBAL_CONST unsigned short MKCacheERRORbadID;
 _GLOBAL_CONST unsigned short MKCacheERRORbadMirrorIdx;
 _GLOBAL_CONST unsigned short MKCacheERRORcritSection;
 _GLOBAL_CONST unsigned short CACHE_STATE_OK;
 _GLOBAL_CONST unsigned short MKCacheERRORPosUsed;
 _GLOBAL_CONST unsigned short CACHE_STATE_NOT_READY;
 _GLOBAL_CONST unsigned short HANGER_FLAG_PRESORT_ALLOCATE;
 _GLOBAL_CONST unsigned short CACHE_STATE_FAIL;
 _GLOBAL_CONST unsigned short HANGER_FLAG_DB_DATA;
 _GLOBAL_CONST unsigned short HANGER_FLAG_NOT_FOUND;
 _GLOBAL_CONST unsigned short HANGER_FLAG_BAD_FEED;
 _GLOBAL_CONST unsigned short MKCacheERRORnullHash;
 _GLOBAL_CONST unsigned short MKCacheERRORnullBase;
 _GLOBAL_CONST unsigned char StackStringLength;
 _GLOBAL_CONST unsigned char PresortStringLength;
 _GLOBAL_CONST unsigned char RouteLength;
 _GLOBAL_CONST unsigned char ArticleSizeLength;
 _GLOBAL_CONST unsigned char CustomerIDLength;
 _GLOBAL_CONST unsigned char ArticleIDLength;
 _GLOBAL_CONST unsigned char ArticleNameLength;
 _GLOBAL_CONST unsigned char CustomerNameLength;
 _GLOBAL_CONST unsigned char IDLength;
 _GLOBAL_CONST unsigned char InfoTextLength;
 _GLOBAL_CONST unsigned char EmployeeIDLength;
 _GLOBAL_CONST unsigned char EmployeeNameLength;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct CacheInternalEssential_Type
{	unsigned long Head;
	unsigned long End;
	unsigned short Lag;
} CacheInternalEssential_Type;

typedef struct CacheManagerEssential_Type
{	unsigned short State;
	unsigned long CycleCount;
	unsigned short IdleMax;
	unsigned long LimitFileSize;
	unsigned char DataTransactionBatch;
	unsigned long DataBuffer;
} CacheManagerEssential_Type;

typedef struct CacheTrackEssential_Type
{	unsigned short State;
	unsigned long CriticalSectionIdent;
	unsigned long BaseHead;
	unsigned long FreeHead;
	unsigned long OlderHead;
	unsigned long YoungerHead;
	unsigned long DataHead;
	unsigned short DataSize;
	unsigned short TotalCount;
	unsigned short FreeCount;
	unsigned long GetKeyDataPtr;
	unsigned long SetNullDataPtr;
	unsigned long IsNullDataPtr;
	unsigned long IsEqualDataPtr;
	struct CacheInternalEssential_Type Mirror[7];
	unsigned long HashTableHead;
	unsigned short HashCount;
	unsigned short HashToOne;
	unsigned short HashToTwo;
	unsigned short HashToMore;
	struct CacheManagerEssential_Type Manager;
	plcstring Device[32];
	plcstring File[32];
	struct FileOpen FOpen;
	struct FileClose FClose;
	struct FileCreate FCreate;
	struct FileRead FRead;
	struct FileWrite FWrite;
	struct FileDelete FDelete;
	struct DirInfo DInfo;
	plcstring Name[32];
} CacheTrackEssential_Type;

typedef struct HangerASCII24_Type
{	plcstring Hanger[25];
	plcstring Garment[25];
	unsigned short Flag;
	plcdt TimeStamp;
	unsigned short MilliSec;
	unsigned short Position;
	unsigned short Address[10];
	unsigned short FinisherProgram;
	unsigned short FinisherDestination;
	unsigned short FolderProgram;
	unsigned short FolderDestination;
	unsigned short FolderSortID;
	unsigned short Control;
	unsigned short Presort;
	unsigned short Exit;
	unsigned short SortID;
	unsigned short LotID;
	unsigned short Size;
	unsigned short GarmentType;
	plcstring Route[31];
	plcstring CustomerID[25];
	plcstring CustomerName[31];
	plcstring EmployeeID[25];
	plcstring EmployeeName[31];
	plcstring ArticleID[25];
	plcstring ArticleName[31];
	plcstring ArticleSize[25];
	plcstring InfoText[41];
	plcstring PresortString[101];
	plcstring StackString[101];
	unsigned char dummy;
} HangerASCII24_Type;

typedef struct MT_MirrorThread
{	unsigned long threadId;
	plcbit cmdStopThread;
	plcbit threadActive;
	struct UdpOpen UdpOpenStruct;
	struct UdpClose UdpCloseStruct;
	struct UdpSend UdpSendStruct;
	struct UdpRecv UdpRecvStruct;
	struct UdpIoctl UdpIoctlStruct;
	plcstring client[17];
	signed char buffer[1501];
	struct CacheTrackEssential_Type* tk;
	unsigned long badCntRcx;
	unsigned long RcxCount;
} MT_MirrorThread;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC unsigned short mirrorStartThread(struct MT_MirrorThread* t, struct CacheTrackEssential_Type* tk);
_BUR_PUBLIC unsigned short mirrorStopThread(struct MT_MirrorThread* t);
_BUR_PUBLIC unsigned short ChCliFind(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data);
_BUR_PUBLIC unsigned short ChCliFresh(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data);
_BUR_PUBLIC unsigned short ChCliForce(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data);
_BUR_PUBLIC unsigned short ChCliDelete(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data);
_BUR_PUBLIC unsigned short ChMgrClear(struct CacheTrackEssential_Type* ce);
_BUR_PUBLIC unsigned short ChCliLastState(struct CacheTrackEssential_Type* ce);
_BUR_PUBLIC unsigned short ChMirGet(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data, unsigned char* pBatch, unsigned char idx);
_BUR_PUBLIC unsigned short ChMirGetAck(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data, unsigned char* pBatch, unsigned char idx);
_BUR_PUBLIC unsigned short ChMirAck(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data, unsigned char ackBatch, unsigned char idx);
_BUR_PUBLIC unsigned short ChMirMarkAll(struct CacheTrackEssential_Type* ce, unsigned char idx);
_BUR_PUBLIC unsigned short ChMgrInit(struct CacheTrackEssential_Type* ce, unsigned short idleMax, unsigned long sizeMax);
_BUR_PUBLIC unsigned short ChMgrCyclic(struct CacheTrackEssential_Type* ce, unsigned short* ctrl);
_BUR_PUBLIC unsigned short ChMgrExit(struct CacheTrackEssential_Type* ce);
_BUR_PUBLIC plcbit ChIsNullData(struct HangerASCII24_Type* data);
_BUR_PUBLIC unsigned short ChFlgSetUFO(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetUFO(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChFlgSetValid(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetValid(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChFlgSetNotFound(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetNotFound(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChFlgSetDBData(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetDBData(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChFlgSetAllocate(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetAllocate(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChFlgSetBadFeed(struct HangerASCII24_Type* hanger, plcbit state);
_BUR_PUBLIC plcbit ChFlgGetBadFeed(struct HangerASCII24_Type* hanger);
_BUR_PUBLIC unsigned short ChMirUpdate(struct CacheTrackEssential_Type* ce, struct HangerASCII24_Type* data, unsigned char ackBatch, unsigned char idx);


#ifdef __cplusplus
};
#endif
#endif /* _CACHELIB_ */

