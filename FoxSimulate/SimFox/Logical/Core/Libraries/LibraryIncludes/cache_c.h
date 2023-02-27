/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| Cache_C.h : definitions shared with C programmers of cache clients                                             |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 NS19990714 original Motorola version                                                               |
| Version 2.0 NS20000731 Intel version                                                                           |
| Version 2.1 NS20040107 Extension to 8 mirror channels + time stamp (BUG!!)                                     |
| Version 2.2 NS20040209 New CacheList.c to handle clearly and surely mirror list operations                     |
| Version 2.2.1 NS20060602 Now checking reply times											                     |
| Version 2.2.2 NS20101005 Extra functions to run mirror in ST                                                   |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef CacheSharedHeader
#define CacheSharedHeader

/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plctypes.h>
#include <sys_lib.h>
#include <metutils.h>											/* internal structures used						*/
#include <FileIO.h>
#include "RtkUser.h"											/* ULONG Type for critical section id			*/

#define STRUCDEF 1

#if STRUCDEF
	/**/
#else
	#include "CacheLib.h"
#endif

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

#define HANGER_MAX_ADDRESS          10
#define MKCacheLimitBatchSize		128							/* max number of rec. in one go 				*/

/* extended mirroring channels */
#define CACHE_MIRROR_MAX_REGISTER   7							/* number of mirroring channels					*/
#define CACHE_REC_FLAG_MIRROR_0     0x0001                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_0  0x0002                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_1     0x0004                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_1  0x0008                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_2     0x0010                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_2  0x0020                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_3     0x0040                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_3  0x0080                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_4     0x0100                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_4  0x0200                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_5     0x0400                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_5  0x0800                      /* flag to mark records for mirror pending      */
#define CACHE_REC_FLAG_MIRROR_6     0x1000                      /* flag to mark records for mirroring           */
#define CACHE_REC_FLAG_MIRRORING_6  0x2000                      /* flag to mark records for mirror pending      */

#define CACHE_REC_FLAG_MIRRORING_SP 0x8000                      /* special flag to mark records as a simple flag*/
							/* update, they are not moved in the age list. This will allow to save ack'd mirror */
					/* operation to the cache file and restore the last state of mirroring in all other registers*/

#define CACHE_MANAGER_MIRROR_REG	0							/* mirroring register used by the manager		*/
#define CACHE_MANAGER_MIRROR_MASK	((1<<CACHE_MIRROR_MAX_REGISTER)-1-(1<<CACHE_MANAGER_MIRROR_REG))/* mirroring mask used by the manager	*/

/*···[ Errors constants ]·······················································································*/

#define MKCacheERRORnone             0                          /* there is no problem                          */
#define MKCacheERRORnullBase         2                          /* the base array couldn't be allocated         */
#define MKCacheERRORbadDM           11                          /* invalid settings in the data module          */
#define MKCacheERRORfile			12							/* file IO error								*/
#define MKCacheERRORnullHash        30                          /* the hash table couldn't be allocated         */
#define MKCacheERRORbadID           40                          /* the hash table couldn't be restored          */
#define MKCacheERRORcheckFree       50                          /* bad free records' list                       */
#define MKCacheERRORcheckAge        51                          /* bad age records' list                        */
#define MKCacheERRORcheckHash       52                          /* bad hash records' list                       */
#define MKCacheERRORcheckMirror     54                          /* mirror list corrupted                        */
#define MKCacheERRORcritSection     64                          /* related to critical sections usage           */
#define MKCacheERRORbadMirrorIdx	70							/* related to mirror channel selection			*/
#define MKCacheERRORtime			80							/* related to time stamp						*/

/*···[ Dialogue constants ]·····················································································*/

#define CACHE_STATE_OK              10                          /* client and server happy together             */
#define CACHE_STATE_NOT_READY      901                          /* cache module not ready                       */
#define CACHE_STATE_FAIL          1001                          /* cache module failed (give up...)             */

/*———[ Typedefs ]———————————————————————————————————————————————————————————————————————————————————————————————*/

typedef UINT                        CacheState_Type;            /* cache state indicator       					*/
typedef UINT                        CacheSize_Type;             /* type of a length in the hanger array         */
typedef CacheSize_Type		    *   CacheSizePtr_Type;		    /* type to point to it                          */
typedef USINT                       CacheMirrorBatch_Type;      /* type to store the size of a mirroring batch  */
typedef CacheMirrorBatch_Type   *   CacheMirrorBatchPtr_Type;   /* type to point to it                          */
typedef HangerID_Type			*	HangerIDPtr_Type;

#if STRUCDEF
typedef struct Hanger_Type                                      /* structure of the hanger data record          */
{
    HangerID_Type                   ID;                         /* chip ID                                      */
    HangerID_Type                   Garment;                    /* garment ID                                   */
    UINT							MirrorFlags;                /* mirror flags                                 */
    UINT                            Flag;                       /* hanger flag indicate status of hanger        */
    RTCtime_typ						DTStamp;					/* date & time stamp							*/
/*·········V·Insert·fields·from·here·V··········································································*/
    UINT        	                Position;                   /* last position                                */
    UINT		                    Address[HANGER_MAX_ADDRESS];/* address string                               */
    UINT                            FinisherProgram;            /* finisher program                             */
    UINT                            FolderProgram;              /* folder program                               */
    UINT                            FolderDestination;          /* folderdestination                            */
    UINT                            Control;                    /* control destination                          */
    UINT                            Presort;                    /* presort destination                          */
    UINT                            Exit;                       /* exit destination                             */
    UINT                            SortID;                     /* sort order identity                          */
    UINT                            LotID;                      /* current lot id                               */
    UINT                            SubLotID;                   /* current sublot id                            */
    UINT                            WashCounter;                /* rewash count                                 */
    UINT                            Size;                       /* size code                                    */
    UINT                            GarmentType;                /* type code                                    */
    UINT                            FolderSortID;               /* belt to sort garment on after folder         */
    UDINT                           RID;                        /* route id                                     */
    UDINT                           CID;                        /* customer id                                  */
    UDINT                           EID;                        /* employee id                                  */
} Hanger_Type;								                    /* type to store hanger data                    */
#endif
typedef Hanger_Type             *   HangerPtr_Type;             /* type to point over a hanger record           */

#if STRUCDEF
enum HangerFlag_Enum
{
    HANGER_FLAG_UFO              	=     1,                	/* bit 0, hanger is a ufo hanger                */
    HANGER_FLAG_VALID            	=     2,                	/* bit 1, hanger is valid                       */
    HANGER_FLAG_NOT_FOUND        	=     4,                	/* bit 2, hanger is not found                   */
    HANGER_FLAG_PRESORT_ALLOCATE	=     8,                	/* bit 3, hanger should be allocated for presort*/
    HANGER_FLAG_BAD_FEED 			=    16	                	/* bit 4, hanger should not be allowed more for */
																/*        sorting etc. Flag is reset by loading */
};
#endif

typedef UINT                        CacheKey_Type;              /* type to store a chip ID Key                  */

#if STRUCDEF
typedef struct CacheMirrorList_Type                             /* structure of the mirror list                 */
{
    struct CacheList_Type       *   Older; 						/* the previous record to mirror			    */
    struct CacheList_Type       *   Younger;					/* the following record to mirror 				*/
} CacheMirrorList_Type;
#endif
typedef CacheMirrorList_Type    *   CacheMirrorListPtr_Type;    /* type to point over a mirror list entry       */

#if STRUCDEF
typedef struct CacheMirrorEssential_Type                        /* base structure of the mirror list            */
{
	struct CacheList_Type       *   Head;						/* base pointer for cache mirroring   			*/
	struct CacheList_Type       *   End;						/* base pointer for cache mirroring (youngest)	*/
	CacheSize_Type           		Lag;						/* number of updated records to be mirrored		*/
} CacheMirrorEssential_Type;
#endif
typedef CacheMirrorEssential_Type * CacheMirrorEssentialPtr_Type;

#if STRUCDEF
typedef struct CacheList_Type                                   /* structure of the hangers list                */
{
    struct CacheList_Type       *   Next;                       /* next free/linked record                      */
    struct CacheList_Type       *   Older;                      /* the previous record allocated                */
    struct CacheList_Type       *   Younger;                    /* the following record allocated               */
    CacheMirrorList_Type            Mirror[CACHE_MIRROR_MAX_REGISTER]; /* the mirror list link	   				*/
    Hanger_Type                     Data;                       /* the base data                                */
} CacheList_Type;
#endif
typedef CacheList_Type          *   CacheListPtr_Type;          /* type to point over a hanger list entry       */
typedef CacheListPtr_Type		*   CacheListHdl_Type;

#if STRUCDEF
typedef struct CacheEssential_Type
{
	CacheState_Type                 State;                   	/* state of the cache 			                */
	ULONG							CriticalSectionIdent;		/* identity of the crit. section used to protect cache access*/
	CacheListPtr_Type              	FreeHead;                	/* pointer to the first free hanger in the array*/
	CacheListPtr_Type               OlderHead;               	/* pointer to the oldest hanger in the array    */
	CacheListPtr_Type               YoungerHead;             	/* pointer to the youngest hanger in the array  */
	CacheSize_Type                  FreeCount;               	/* number of free records in the list           */
	CacheMirrorEssential_Type       Mirror[CACHE_MIRROR_MAX_REGISTER]; /* base pointers for cache mirroring		*/
	CacheListHdl_Type               HashTableHead;           	/* base pointer to the hash table               */
	CacheSize_Type                  HashCount;               	/* number of buckets in the hash table          */
    CacheSize_Type                  HashToOne;					/* number of hangers assigned to one bucket		*/
    CacheSize_Type                  HashToTwo;					/* number of hangers assigned to two buckets	*/
    CacheSize_Type                  HashToThree;				/* number of hangers assigned to three buckets	*/
    CacheSize_Type                  HashToFour;					/* number of hangers assigned to four buckets	*/
    CacheSize_Type                  HashToFiveOrMore;			/* number of hangers assigned to five or more	*/
	CacheListPtr_Type              	BaseHead;                	/* base pointer for the hanger array            */
	CacheSize_Type                 	TotalCount;              	/* total number of records in the hanger array  */
	UINT							ReplyFreq[10];				/* frequency table of reply times				*/
	struct FileOpen					FOpen;
	struct FileClose				FClose;
	struct FileCreate				FCreate;
	struct FileRead					FRead;
	struct FileWrite				FWrite;
	struct FileDelete				FDelete;
	struct DirInfo					DInfo;
} CacheEssential_Type;
#endif
typedef CacheEssential_Type		*   CacheEssentialPtr_Type;

/*———[ Macros ]—————————————————————————————————————————————————————————————————————————————————————————————————*/

#define HangerEqualIDPtr(a,b)   (((a)->Low)==((b)->Low) && ((a)->High)==((b)->High))    /* compare hanger IDs   */
#define HangerEqualID(a,b)      (((a).Low)==((b).Low) && ((a).High)==((b).High))        /* compare hanger IDs   */
#define HangerIsNullIDPtr(a)    (((a)->Low)==ULONG_MAX && ((a)->High)==ULONG_MAX)       /* is it a NULL ID ?    */
#define HangerIsNullID(a)       (((a).Low)==ULONG_MAX && ((a).High)==ULONG_MAX)         /* is it a NULL ID ?    */
#define HangerIsntNullIDPtr(a)  (((a)->Low)!=ULONG_MAX || ((a)->High)!=ULONG_MAX)       /* is it a valid ID ?   */
#define HangerIsntNullID(a)     (((a).Low)!=ULONG_MAX || ((a).High)!=ULONG_MAX)         /* is it a valid ID ?   */
#define HangerSetNullIDPtr(a)   {(a)->Low=ULONG_MAX; (a)->High=ULONG_MAX;}              /* set a to NULL ID     */
#define HangerSetNullID(a)      {(a).Low=ULONG_MAX; (a).High=ULONG_MAX;}                /* set a to NULL ID     */

#define HangerFlagSetValidGarment(a)			{(a).Flag |= HANGER_FLAG_VALID;}        /* mark garment as valid*/
#define HangerFlagSetNOValidGarment(a)          {(a).Flag &= ~HANGER_FLAG_VALID;}       /* mark garment as invalid*/
#define HangerFlagSetUfo(a)                     {(a).Flag |= HANGER_FLAG_UFO;}          /* mark hanger as ufo   */
#define HangerFlagCheckFlagValidGarment(a)    ((((a).Flag) & HANGER_FLAG_VALID)!=0)     /* check if valid garment*/
#define HangerFlagCheckFlagNOValidGarment(a)  ((((a).Flag) & HANGER_FLAG_VALID)==0)     /* check if invalid garment*/
#define HangerFlagCheckFlagFoundGarment(a)    ((((a).Flag) & HANGER_FLAG_NOT_FOUND)==0) /* check if garment was found*/
#define HangerFlagCheckFlagNotFoundGarment(a) ((((a).Flag) & HANGER_FLAG_NOT_FOUND)!=0) /* check if garment was not found*/
#define HangerFlagCheckUfo(a)                 ((((a).Flag) & HANGER_FLAG_UFO)!=0)       /* check if hanger is sent to ufo*/

#define HangerFlagSetNotFoundGarment(a)         {(a).Flag |= HANGER_FLAG_NOT_FOUND;}    /* mark garment not found*/
#define HangerFlagSetFoundGarment(a)            {(a).Flag &= ~HANGER_FLAG_NOT_FOUND;}   /* mark garment as found*/
#define HangerFlagCheckFlagNotFoundGarment(a) ((((a).Flag) & HANGER_FLAG_NOT_FOUND)!=0) /* check if garment not found*/
#define HangerFlagCheckFlagFoundGarment(a)    ((((a).Flag) & HANGER_FLAG_NOT_FOUND)==0) /* check if found garment*/

#define HangerFlagCheckFlagsPendingGarment(a) (HangerFlagCheckFlagNOValidGarment(a)&&HangerFlagCheckFlagNotFoundGarment(a))

#define HangerFlagSetManualGarment(a)           {(a).Flag |= MKHangerFlagManualGarment;}/* mark garment as manual*/
#define HangerFlagSetNOManualGarment(a)         {(a).Flag &= ~MKHangerFlagManualGarment;}/* mark garment as mirrored*/
#define HangerFlagCheckFlagManualGarment(a)   ((((a).Flag) & MKHangerFlagManualGarment)!=0)/* check if manual garment*/
#define HangerFlagCheckFlagNOManualGarment(a) ((((a).Flag) & MKHangerFlagManualGarment)==0)/* check if mirrored garment*/

#define HangerFlagSetRewashGarment(a)           {(a).Flag |= MKHangerFlagRewashGarment;}/* mark garment to rewash*/
#define HangerFlagSetNORewashGarment(a)         {(a).Flag &= ~MKHangerFlagRewashGarment;}/* mark garment to proceed*/
#define HangerFlagCheckFlagRewashGarment(a)   ((((a).Flag) & MKHangerFlagRewashGarment)!=0)/* check if rewash garment*/
#define HangerFlagCheckFlagNORewashGarment(a) ((((a).Flag) & MKHangerFlagRewashGarment)==0)/* check if proceed garment*/

#define HangerFlagSetSortGarment(a)             {(a).Flag |= MKHangerFlagSortGarment;}   /* mark garment to sort*/
#define HangerFlagSetNOSortGarment(a)           {(a).Flag &= ~MKHangerFlagSortGarment;}  /* mark garment to bypass*/
#define HangerFlagCheckFlagSortGarment(a)     ((((a).Flag) & MKHangerFlagSortGarment)!=0)/* check if sort garment*/
#define HangerFlagCheckFlagNOSortGarment(a)   ((((a).Flag) & MKHangerFlagSortGarment)==0)/* check if bypass garment*/

#define HRecSetFlagMirror(a,i)     {(a)->Data.MirrorFlags |= (1<<(i<<1));}     		/* set the flag to enable mirroring */
#define HRecSetFlagNOMirror(a,i)   {(a)->Data.MirrorFlags &= ~(1<<(i<<1));}    		/* set the flag to skip mirroring   */
#define HRecCheckFlagMirror(a,i)   ((((a)->Data.MirrorFlags) & (1<<(i<<1)))!=0)		/* check the flag for mirroring     */
#define HRecCheckFlagNOMirror(a,i) ((((a)->Data.MirrorFlags) & (1<<(i<<1)))==0)		/* check the flag against mirroring */

#define HRecSetFlagMirroring(a,i)     {(a)->Data.MirrorFlags |= (1<<((i<<1)+1));}     /* set the flag for mirror pending*/
#define HRecSetFlagNOMirroring(a,i)   {(a)->Data.MirrorFlags &= ~(1<<((i<<1)+1));}    /* set the flag for mirrored  	*/
#define HRecCheckFlagMirroring(a,i)   ((((a)->Data.MirrorFlags) & (1<<((i<<1)+1)))!=0)/* check the flag for pending 	*/
#define HRecCheckFlagNOMirroring(a,i) ((((a)->Data.MirrorFlags) & (1<<((i<<1)+1)))==0)/* check the flag against mirrored*/

#define HRecSetFlagAckMirror(a,i)   {((a)->Data.MirrorFlags) &= ~((1<<(i<<1))|(1<<((i<<1)+1)));}
#define HRecCheckFlagAckMirror(a,i) ((((a)->Data.MirrorFlags) & ((1<<(i<<1))|(1<<((i<<1)+1)))) == ((1<<(i<<1))|(1<<((i<<1)+1))))

#define HRecSetFlagSPMirror(a)           {(a)->Data.MirrorFlags |= CACHE_REC_FLAG_MIRRORING_SP;}/* mark for special mirror*/
#define HRecSetFlagNOSPMirror(a)         {(a)->Data.MirrorFlags &= ~CACHE_REC_FLAG_MIRRORING_SP;}/* remove special mirror*/
#define HRecCheckFlagSPMirror(a)   ((((a)->Data.MirrorFlags) & CACHE_REC_FLAG_MIRRORING_SP)!=0)/* check for special mirror*/
#define HRecCheckFlagNOSPMirror(a) ((((a)->Data.MirrorFlags) & CACHE_REC_FLAG_MIRRORING_SP)==0)/* check for no special mirror*/

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

/*… Client side methods …………………………………………………………………………………………………………………………………………………………………………………………………………………………………………*/
CacheState_Type ChCliFind( CacheEssentialPtr_Type ce, HangerPtr_Type data );/* search for a hanger ID			*/
CacheState_Type ChCliFresh( CacheEssentialPtr_Type ce, HangerPtr_Type data );/* add/update a hanger data		*/
CacheState_Type ChCliForce( CacheEssentialPtr_Type ce, HangerPtr_Type data );/* add/update a hanger data from the mirror*/
CacheState_Type ChCliDelete( CacheEssentialPtr_Type ce, HangerIDPtr_Type id );/* remove a hanger (do not use)	*/
CacheState_Type ChCliLastState(CacheEssentialPtr_Type ce);				/* get the state from the last operation*/

/*… Manager side methods ………………………………………………………………………………………………………………………………………………………………………………………………………………………………………*/
BOOL CacheInitBaseS(CacheEssentialPtr_Type);                    /* set up the base array                        */
BOOL CacheInitCheckS(CacheEssentialPtr_Type);                /* set up and check links, CRC, mirroring and flags*/
BOOL CacheInitHashS(CacheEssentialPtr_Type);                    /* set up the hash table                        */
BOOL CacheZeroS( CacheEssentialPtr_Type, CacheSize_Type, CacheSize_Type ); /* first entry in the Cache          */
BOOL CacheCheckFreeS( CacheEssentialPtr_Type );                 /* check the integrity of the free records' list*/
BOOL CacheCheckAgeS( CacheEssentialPtr_Type );                  /* check the integrity of the age list          */
BOOL CacheCheckHashS( CacheEssentialPtr_Type );                 /* check the integrity of the hash table        */
BOOL CacheCheckMirrorS( CacheEssentialPtr_Type );               /* check the integrity of the mirroring function*/
CacheState_Type ChMgrInit( CacheEssentialPtr_Type ce, CacheSize_Type, CacheSize_Type, UINT, UDINT );
CacheState_Type ChMgrCyclic( CacheEssentialPtr_Type ce, UINT * ctrl );
CacheState_Type ChMgrExit(CacheEssentialPtr_Type ce);
CacheState_Type ChMgrClear(CacheEssentialPtr_Type ce);          /* clear the memory & init server       		*/
CacheState_Type ChMirGetST( CacheEssentialPtr_Type ce, void *d, UDINT s, CacheMirrorBatchPtr_Type pCBatch, USINT idx );
CacheState_Type ChMirGet( CacheEssentialPtr_Type ce, HangerPtr_Type data, CacheMirrorBatchPtr_Type pCBatch, USINT idx );
CacheState_Type ChMirGetAck( CacheEssentialPtr_Type ce, HangerPtr_Type data, CacheMirrorBatchPtr_Type pCBatch, USINT idx );
CacheState_Type ChMirAckST( CacheEssentialPtr_Type ce, void *pid, void *did, UDINT s, CacheMirrorBatch_Type ackBatch, USINT idx );
CacheState_Type ChMirAck( CacheEssentialPtr_Type ce, HangerIDPtr_Type id, HangerPtr_Type data, CacheMirrorBatch_Type ackBatch, USINT idx );
CacheState_Type ChMirUpdateST( CacheEssentialPtr_Type ce, void *d, UDINT s, CacheMirrorBatch_Type ackBatch, USINT idx );
CacheState_Type ChMirUpdate( CacheEssentialPtr_Type ce, HangerPtr_Type data, CacheMirrorBatch_Type ackBatch, USINT idx );
CacheState_Type ChMirMarkAll(CacheEssentialPtr_Type ce, USINT idx);

/*… Server side methods …………………………………………………………………………………………………………………………………………………………………………………………………………………………………………*/
HangerPtr_Type CacheAppendOrUpdateS( CacheEssentialPtr_Type, HangerPtr_Type, USINT ); /* add/update a hanger	*/
BOOL CacheDeleteS( CacheEssentialPtr_Type, HangerID_Type * );   /* remove a hanger from the cache module        */
CacheListPtr_Type CacheLocateS( CacheEssentialPtr_Type, HangerID_Type * ); /* locate a hanger in the table      */
void CacheMirrorMarkAllS( CacheEssentialPtr_Type, USINT idx );	/* assign everything to be mirrored				*/
CacheMirrorBatch_Type CacheMirrorGetS( CacheEssentialPtr_Type, HangerPtr_Type, CacheMirrorBatch_Type, USINT idx );/* get a batch of hanger to mirror*/
CacheMirrorBatch_Type CacheMirrorGetAckS( CacheEssentialPtr_Type, HangerPtr_Type, CacheMirrorBatch_Type, USINT idx );/* pull a batch of hanger from mirror*/
void CacheMirrorAckS( CacheEssentialPtr_Type, HangerIDPtr_Type, HangerPtr_Type, CacheMirrorBatch_Type, USINT idx );/* acknowledge mirrored hangers, with an ID list OR a hanger list*/
void CacheMirrorAckHelpS( CacheEssentialPtr_Type ce, CacheListPtr_Type href, USINT idx );/*remove a hanger from a mirror list*/
void CacheMirrorAckRestoreHelpS( CacheEssentialPtr_Type ce, CacheListPtr_Type href, USINT idx );
void CacheMirrorUpdateS( CacheEssentialPtr_Type, HangerPtr_Type, CacheMirrorBatch_Type, USINT mirrorFlags );/* update a batch of hanger from PC */
void CacheClearS( CacheEssentialPtr_Type );                     /* reset to an empty cache                      */

#endif


