/****************************************************************************
*																			*
*																			*
*		Copyright:		Bernecker & Rainer Industrieelektronik Ges.m.b.H	*
*																			*
*		Title :			RtkUser.h											*
*		Date  :			August 27th 2002									*
*		Description:	RTK interface: definitions, types and prototypes	*
*																			*
****************************************************************************/

#ifndef _RTKUSER_
#define _RTKUSER_

/* Default handling for RTK functions : "normal C-functions" */
#ifndef EXIMPORT
 #define EXIMPORT
#endif

/****************************************************************************/
/* General datatypes for RT kernel											*/
/****************************************************************************/

#ifndef	_BYTE_DEFINED_
	#define	_BYTE_DEFINED_
	typedef	unsigned char		BYTE;
#endif
#ifndef	_LPBYTE_DEFINED_
	#define	_LPBYTE_DEFINED_
	typedef	unsigned char *		LPBYTE;
#endif
#ifndef	_WORD_DEFINED_
	#define	_WORD_DEFINED_
	typedef	unsigned short		WORD;
#endif
#ifndef	_LPWORD_DEFINED_
	#define	_LPWORD_DEFINED_
	typedef	unsigned short *	LPWORD;
#endif
#ifndef	_ULONG_DEFINED_
	#define	_ULONG_DEFINED_
	typedef	unsigned long		ULONG;
#endif
#ifndef	_LPULONG_DEFINED_
	#define	_LPULONG_DEFINED_
	typedef	unsigned long *		LPULONG;
#endif
#ifndef	_LPSTRING_DEFINED_
	#define	_LPSTRING_DEFINED_
	typedef	char *				LPSTRING;
#endif
#ifndef	_LPVOID_DEFINED_
	#define	_LPVOID_DEFINED_
	typedef	void *				LPVOID;
#endif

typedef enum
{
	RTKFALSE = 0,
	RTKTRUE  = 1
} RTKBOOLEAN;

/****************************************************************************/
/* General definitions for RT kernel										*/
/****************************************************************************/

#define	MAX_RTK_NAME_LENGTH				32
#define	MAX_RTK_NAME_TERMINATED_LENGTH	(MAX_RTK_NAME_LENGTH + 1)

/****************************************************************************/
/* Objecttypes																*/
/****************************************************************************/

typedef enum
{
    RTK_OBJ_INVALID = 0,
    RTK_OBJ_TASK,
    RTK_OBJ_SEMAPHORE,
    RTK_OBJ_CRITICAL_SECTION,
    RTK_OBJ_TIMER,
    RTK_OBJ_INTERRUPT,
    RTK_OBJ_EXCEPTION,
    RTK_OBJ_PLAINFIFO,
    RTK_OBJ_FIFO,
    RTK_OBJ_MEMORY,
    RTK_OBJ_SHARED_MEMORY,
    RTK_OBJ_DEBUGGER,
	RTK_OBJ_LOG,
    RTK_OBJ_RTC,
    RTK_OBJ_MISC,
    RTK_OBJ_TASKTIMER   /* internal */
} RTK_OBJ_TYPE;

typedef RTK_OBJ_TYPE *	LPRTK_OBJ_TYPE;

/****************************************************************************/
/* Timeout for task events, semaphore, fifo, debugmessage, ...				*/
/****************************************************************************/

#define RTK_TIMEOUT_NOWAIT			    0
#define	RTK_TIMEOUT_WAITFOREVER			0xFFFFFFFF

/****************************************************************************/
/* Errorcodes																*/
/****************************************************************************/

typedef enum
{
/* already declared in runtime.h    ERR_OK				= 0,	*/	/* No error										*/

    ERR_RTK_OBJID		= 25000,	/* Invalid object ident							*/
    ERR_RTK_OBJNOTFOUND,            /* Object with specified name not found			*/
    ERR_RTK_OBJTYPE,                /* Invalid object type							*/
    ERR_RTK_OBJ_OVERFLOW,           /* Object table full							*/
    ERR_RTK_OBJ_EXIST,              /* Object already exists						*/
    ERR_RTK_OBJNAME,                /* Wrong object name							*/

    ERR_RTK_PRIORITY	= 25010,	/* Invalid priority								*/
    ERR_RTK_NO_STACK,               /* Not enough free stack						*/
    ERR_RTK_NOT_SUSPENDED,          /* Task is not suspended						*/
    ERR_RTK_SUSPENDED,              /* Task is already suspended					*/
    ERR_RTK_TASKVALUE,              /* Invalid valueindex							*/
    ERR_RTK_NOTASKTIMERS,           /* No more task timers available				*/
    ERR_RTK_TASKCREATE,             /* OS task not created							*/
    ERR_RTK_TASKDELETE,             /* OS Task not deleted							*/

    ERR_RTK_FIFO_CREATE	= 25030,	/* FIFO not created (memory alloc, ...)			*/
    ERR_RTK_FIFO_DELETE,			/* FIFO not deleted (memory free, ...)			*/
    ERR_RTK_FIFO_WRITE,				/* FIFO not written (fifo full, ...)			*/
	ERR_RTK_FIFO_READ,				/* FIFO not read (fifo empty, ...)				*/
	ERR_RTK_FIFO_RELEASE,			/* FIFO not released							*/
	ERR_RTK_FIFO_ATTACHED_TIMEOUT,	/* FIFO read/write with timeout invalid (attached) */
	ERR_RTK_FIFO_NOT_ATTACHED,		/* FIFO not attached when read/write			*/
	ERR_RTK_FIFO_ATTACHED,			/* FIFO already attached (other task)			*/
	ERR_RTK_FIFO_ATTACH,			/* FIFO not created for attach					*/

    ERR_RTK_SEMACREATE  = 25040,	/* OS semaphore not created						*/
    ERR_RTK_SEMA_DELETE,			/* OS semaphore not deleted						*/
    ERR_RTK_SEMA_RELEASE,			/* OS semaphore not released					*/

    ERR_WRONG_MEMTYPE	= 25060,	/* Invalid memory type							*/
    ERR_RTK_NOMEM_HEAP,             /* Not enough memory free in heap				*/
    ERR_RTK_FREE_HEAP,              /* Memory not in heap							*/

	ERR_RTK_CREATE_SHAREDMEM,       /* SharedMemory not created						*/
	ERR_RTK_DELETE_SHAREDMEM,       /* SharedMemory not deleted						*/
	ERR_RTK_MAP_SHAREDMEM,          /* SharedMemory not mapped						*/
	ERR_RTK_UNMAP_SHAREDMEM,        /* SharedMemory not unmapped					*/

    ERR_RTK_IRQNUMBER	= 25080,	/* Invalid interruptnumber						*/
    ERR_RTK_CONNECT_IRQ,            /* Interrupt not connected						*/
	ERR_RTK_DISCONNECT_IRQ,			/* Interrupt not disconnected					*/

    ERR_RTK_TIMERCYCLE	= 25090,	/* Invalid cycletime							*/
    ERR_RTK_WRONGTIME,              /* Invalid time/date							*/
    ERR_RTK_SET_RTC,				/* RealTimeClock not set						*/
	ERR_RTK_TIMER_CREATE,			/* Timer not created							*/
	ERR_RTK_TIMER_DELETE,			/* Timer not deleted							*/
    ERR_RTK_TIMER_START,            /* Timer not started							*/
    ERR_RTK_TIMER_STOP,             /* Timer not stopped							*/

    ERR_RTK_CRITSECCREATE = 25250,	/* CriticalSection not created					*/
    ERR_RTK_CRITSECDELETE,          /* CriticalSection not deleted					*/
    ERR_RTK_CRITSECENTER,           /* CriticalSection not enterd					*/
    ERR_RTK_CRITSECLEAVE,           /* CriticalSection not left						*/

} RTK_ERROR;

/****************************************************************************/
/* Task                                                                     */
/****************************************************************************/

#define RTK_TASKIDENT_ITSELF            0x00000000

#define RTK_MAX_TASK_PRIORITY           255
#define RTK_MAX_TASK_VALUES	            16 

typedef void (*LPRTK_CREATE_TASK_FKT)(ULONG param);

/*--------------------------------------------------------------------------*/
/* Task flags (create/start)		                                        */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_TASKFLAG;
#define RTK_TASK_RESUMED                0x00000000
#define RTK_TASK_SUSPENDED              0x00000001
#define RTK_TASK_SYSTEM                 0x00000000
#define RTK_TASK_DRIVER                 0x00000002
#define RTK_TASK_APPLICATION            0x00000004

/*--------------------------------------------------------------------------*/
/* Task event flags												            */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_EVENTFLAG;
#define RTK_EVENT_ANY                   0x00000000
#define RTK_EVENT_ALL                   0x00000001

/*--------------------------------------------------------------------------*/
/* Task state flags (taskInfo)                                              */
/*--------------------------------------------------------------------------*/
#define RTK_TASKSTATE_READY             0x00000000  /* Task is not waiting for any resource other than the CPU. */
#define RTK_TASKSTATE_SUSPENDED         0x00000001  /* Task is unavailable for execution. */
#define RTK_TASKSTATE_PENDED            0x00000002  /* Task is blocked due to the unavailability of some resource. */
#define RTK_TASKSTATE_DELAYED           0x00000004  /* Task is asleep for some duration. */

EXIMPORT RTK_ERROR RtkCreateTask (
                    LPSTRING            lpszTaskName,
                    WORD                wTaskPriority,
                    ULONG               ulTaskSupervisorStackSize,
                    ULONG               ulTaskUserStackSize,
                    RTK_TASKFLAG        TaskFlags,
                    LPRTK_CREATE_TASK_FKT   lpTaskFunction,
                    ULONG               ulTaskFunctionParameter,
                    LPULONG             lpulTaskIdent           /* Output */
                    );
EXIMPORT RTK_ERROR RtkDeleteTask (
                    ULONG               ulTaskIdent
                    );
EXIMPORT RTK_ERROR RtkSuspendTask (
                    ULONG               ulTaskIdent
                    );
EXIMPORT RTK_ERROR RtkResumeTask (
                    ULONG               ulTaskIdent
                    );
EXIMPORT void RtkSleepTaskUsec (
                    ULONG               ulSleepUsec
                    );
EXIMPORT RTK_ERROR RtkSendTaskEvent (
                    ULONG               ulTaskIdent,
                    WORD                wTaskEvents
                    );
EXIMPORT RTK_ERROR RtkReceiveTaskEvent (
                    ULONG               ulTaskIdent,
                    WORD                wWantedEvents,
                    ULONG               ulEventFlags,
                    ULONG               ulTimeoutUsec,
                    LPWORD              lpwReceivedEvents
                    );
EXIMPORT RTK_ERROR RtkSendTaskEventCyclic (
                    ULONG               ulTaskIdent,
                    WORD                wTaskEvents,
                    ULONG               ulDelayUsec,
                    LPULONG             lpulTaskTimerIdent      /* Output */
                    );
EXIMPORT RTK_ERROR RtkSendTaskEventAfter (
                    ULONG               ulTaskIdent,
                    WORD                wTaskEvents,
                    ULONG               ulDelayUsec,
                    LPULONG             lpulTaskTimerIdent      /* Output */
                    );
EXIMPORT RTK_ERROR RtkCancelTaskTimer (
                    ULONG               ulTaskTimerIdent
                    );
EXIMPORT RTK_ERROR RtkSetTaskValue (
                    ULONG               ulTaskIdent,
                    BYTE                byValueIndex,
                    ULONG               ulValue
                    );
EXIMPORT RTK_ERROR RtkGetTaskValue (
                    ULONG               ulTaskIdent,
                    BYTE                byValueIndex,
                    LPULONG             lpulValue               /* Output */
                    );
EXIMPORT RTK_ERROR RtkGetTaskPriority (
                    ULONG               ulTaskIdent,
                    LPWORD              lpwTaskPriority         /* Output */
                    );
EXIMPORT RTK_ERROR RtkSetTaskPriority (
                    ULONG               ulTaskIdent,
                    WORD                wTaskPriority
                    );
EXIMPORT RTK_ERROR RtkGetTaskInfo (
                    ULONG               ulTaskIdent,
                    LPULONG             lpulTaskStatus,			/* Output */
                    LPWORD              lpwTaskPriority,		/* Output */
                    LPULONG             lpulUnused,			    /* Output */
                    LPULONG             lpulFreeSupervisorStack,/* Output */
                    LPULONG             lpulFreeUserStack,		/* Output */
					LPULONG				lpulInternalTaskIdent   /* Output */
                    );
EXIMPORT ULONG RtkGetCurrentTaskIdent (
                    void
                    );

/****************************************************************************/
/* Memory                                                                   */
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Memory access flags									                    */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_MEMORY_ACCESS;
#define RTK_MEM_INITZERO                0x00008000      /* initialization with NULL		*/

EXIMPORT RTK_ERROR RtkAllocateMemory (
                    ULONG               ulByteLength,
                    ULONG               ulAccessFlags,
                    LPVOID *            lpMemoryAddress         /* Output */
                    );
EXIMPORT RTK_ERROR RtkFreeMemory (
                    LPVOID              lpMemoryAddress,
                    ULONG               ulByteLength
                    );
EXIMPORT RTK_ERROR RtkGetMemoryInfo (
                    LPULONG             lpulMemSize,			/* Output */
                    LPULONG             lpulFreeMemSize,	    /* Output */
                    LPULONG             lpulBiggestFreeBlockSize/* Output */
                    );

/****************************************************************************/
/* Plain FIFO																*/			
/****************************************************************************/


EXIMPORT RTK_ERROR RtkCreatePlainFifo ( 
                    LPSTRING            lpFifoName, 
                    ULONG               ulFifoEntrySize, 
                    ULONG               ulFifoMaxEntries,
                    LPULONG             lpFifoIdent      
                   );

EXIMPORT RTK_ERROR RtkDeletePlainFifo ( 
					ULONG               ulFifoIdent 
                   ); 

EXIMPORT RTK_ERROR RtkWritePlainFifo ( 
                    ULONG               ulFifoIdent, 
                    LPVOID              lpDataSource
                   );

EXIMPORT RTK_ERROR RtkReadPlainFifo (
	                ULONG               ulFifoIdent, 
                    LPVOID              lpDataDestination 
                   );

EXIMPORT RTK_ERROR RtkClearPlainFifo (
                    ULONG				ulFifoIdent
				   );			

EXIMPORT RTK_ERROR RtkGetPlainFifoInfo (
					ULONG               ulFifoIdent,
                    LPULONG             lpulFifoFree,                                                
                    LPULONG             lpulFifoUsed,
                    LPULONG             lpulFifoEntrySize
                   );
  

/****************************************************************************/
/* FIFO																		*/			
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Fifo flags (create)													    */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_FIFOFLAG;
#define	RTK_FIFO_WRITE_UNTIL_FULL       0x00000000	    /* no overwrite	*/
#define	RTK_FIFO_WRITE_ALWAYS		    0x00000001		/* overwrite */
#define	RTK_FIFO_ATTACH				    0x00000002		/* only attach/release */

EXIMPORT RTK_ERROR RtkCreateFifo (
                    LPSTRING	        lpszFifoName,
					ULONG			    ulFifoByteSize,
					ULONG				ulFifoFlags,
					LPULONG				lpulFifoIdent		    /* Output */
					);					
EXIMPORT RTK_ERROR RtkDeleteFifo (
                    ULONG				ulFifoIdent
					);					
EXIMPORT RTK_ERROR RtkWriteFifo (
                    ULONG			    ulFifoIdent,
					LPVOID				lpDataSource,
					ULONG				ulDataByteSize,
					ULONG				ulTimeoutUsec
					);					
EXIMPORT RTK_ERROR RtkReadFifo (
                    ULONG				ulFifoIdent,
					LPVOID				lpDataDest,				/* InOut */
					ULONG				lpDataByteSize,
					ULONG				ulTimeoutUsec
					);					
EXIMPORT RTK_ERROR RtkClearFifo (
                    ULONG			    ulFifoIdent
					);
EXIMPORT RTK_ERROR RtkAttachFifo (
                    ULONG				ulFifoIdent
					);					
EXIMPORT RTK_ERROR RtkReleaseFifo (
                    ULONG				ulFifoIdent
					);					
EXIMPORT RTK_ERROR RtkGetFifoInfo (
                    ULONG				ulFifoIdent,
					LPULONG				lpulFifoFree, 			/* Output */
					LPULONG				lpulFifoUsed			/* Output */
					);

/****************************************************************************/
/* Semaphore                                                                */
/****************************************************************************/

EXIMPORT RTK_ERROR RtkCreateSemaphoreEx (
                    LPSTRING            lpszSemaphoreName,
					ULONG				ulInitCount,
                    ULONG               ulMaxCount,
                    LPULONG             lpulSemaphoreIdent      /* Output */
                    );
EXIMPORT RTK_ERROR RtkDeleteSemaphore (
                    ULONG               ulSemaphoreIdent
                    );
EXIMPORT RTK_ERROR RtkAcquireSemaphore (
                    ULONG               ulSemaphoreIdent,
                    ULONG               ulTimeoutUsec
                    );
EXIMPORT RTK_ERROR RtkReleaseSemaphore (
                    ULONG               ulSemaphoreIdent
                    );
EXIMPORT RTK_ERROR RtkGetSemaphoreInfo (
                    ULONG               ulSemaphoreIdent,
                    LPULONG             lpulMaxCount,           /* Output */
                    LPULONG             lpulActCount,           /* Output */
                    LPULONG             lpulTaskWaitingCount    /* Output */
                    );

/****************************************************************************/
/* Shared Memory                                                            */
/****************************************************************************/

EXIMPORT RTK_ERROR RtkCreateSharedMemory (
                    LPSTRING            lpszSharedMemoryName,
                    ULONG               ulByteLength,
                    LPULONG             lpulSharedMemoryIdent   /* Output */
                    );
EXIMPORT RTK_ERROR RtkDeleteSharedMemory (
                    ULONG               ulSharedMemoryIdent
                    );
EXIMPORT RTK_ERROR RtkMapSharedMemory (
                    ULONG               ulSharedMemoryIdent,
                    LPVOID *            lpulMemoryAddress       /* Output */
                    );
EXIMPORT RTK_ERROR RtkUnmapSharedMemory (
                    ULONG               ulSharedMemoryIdent
                    );

/****************************************************************************/
/* Timer                                                                    */
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Flags for timer														    */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_TIMERFLAG;
#define RTK_TIMER_CYCLIC                0x00000000
#define RTK_TIMER_ONESHOT               0x00000001

EXIMPORT RTK_ERROR RtkCreateTimer (
                    LPSTRING            lpszTimerName,
                    WORD                wTimerPriority,
                    ULONG               ulTimerSupervisorStackSize,
                    LPRTK_CREATE_TASK_FKT   lpTimerFunction,
                    ULONG               ulTimerContext,
                    LPULONG             lpulTimerIdent          /* Output */
                    );
EXIMPORT RTK_ERROR RtkDeleteTimer (
                    ULONG               ulTimerIdent
                    );
EXIMPORT RTK_ERROR RtkStartTimer (
                    ULONG               ulTimerIdent,
                    ULONG               ulTimerCycleUsec,
                    ULONG               ulTimerFlags
                    );
EXIMPORT RTK_ERROR RtkStopTimer (
                    ULONG               ulTimerIdent
                    );

/****************************************************************************/
/* Interrupt                                                                */
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Flags for Interrupt													    */
/*--------------------------------------------------------------------------*/
typedef unsigned long                   RTK_INTERRUPTFLAG;
#define RTK_INTERRUPT_DEFAULT			0x00000000
#define RTK_INTERRUPT_PCI				0x00000001

/*--------------------------------------------------------------------------*/
/* Interrupt handler function											    */
/*--------------------------------------------------------------------------*/
typedef  void (*LPRTK_IRQ_HANDLER_FKT)(ULONG param);

EXIMPORT RTK_ERROR RtkConnectInterrupt (
                    LPSTRING            lpszInterruptName,
                    ULONG				ulInterruptNumber,
                    WORD                wInterruptHandlerPollPriority,
                    LPRTK_IRQ_HANDLER_FKT   lpInterruptHandlerFunction,
                    ULONG               ulInterruptContext,
                    LPULONG             lpulInterruptIdent      /* Output */
                    );
EXIMPORT RTK_ERROR RtkConnectInterruptEx (
                    LPSTRING            lpszInterruptName,
                    ULONG				ulInterruptNumber,
					RTK_INTERRUPTFLAG	ulInterruptFlags,
                    WORD                wInterruptHandlerPollPriority,
                    LPRTK_IRQ_HANDLER_FKT   lpInterruptHandlerFunction,
                    ULONG               ulInterruptContext,
                    LPULONG             lpulInterruptIdent      /* Output */
                    );
EXIMPORT RTK_ERROR RtkDisconnectInterrupt (
                    ULONG               ulInterruptIdent
                    );
EXIMPORT void RtkDisableInterrupts (
                    void
                    );
EXIMPORT void RtkEnableInterrupts (
                    void
                    );

/****************************************************************************/
/* Critical Section                                                         */
/****************************************************************************/

EXIMPORT RTK_ERROR RtkCreateCriticalSection (
                    LPSTRING            lpszCriticalSectionName,
                    LPULONG             lpulCriticalSectionIdent    /* Output */
                    );
EXIMPORT RTK_ERROR RtkDeleteCriticalSection (
                    ULONG               ulCriticalSectionIdent
                    );
EXIMPORT RTK_ERROR RtkEnterCriticalSection (
                    ULONG               ulCriticalSectionIdent
                    );
EXIMPORT RTK_ERROR RtkLeaveCriticalSection (
                    ULONG               ulCriticalSectionIdent
                    );

/****************************************************************************/
/* RealTimeClock                                                            */
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Structure for RealTimeClock											    */
/*--------------------------------------------------------------------------*/

typedef struct
{
    WORD    Year;           /* 0 up (for example 1999)			*/
    BYTE    Month;          /* 1-12								*/
    BYTE    Day;            /* 1-31								*/
    BYTE    DayOfWeek;      /* 1=monday, ..., 7=sunday			*/
    BYTE    Hour;           /* 0-23								*/
    BYTE    Minute;         /* 0-59								*/
    BYTE    Second;         /* 0-59								*/
    WORD    Millisecond;    /* 0-999							*/
    WORD    Microsecond;    /* 0-999							*/
} RTK_RTC;

typedef RTK_RTC *   LPRTK_RTC;

EXIMPORT RTK_ERROR RtkSetRealTimeClock (
                    LPRTK_RTC           lpNewDateTime
                    );
EXIMPORT void RtkGetRealTimeClock (
                    LPRTK_RTC           lpDateTime
                    );

/****************************************************************************/
/* Utilities	                                                            */
/****************************************************************************/

EXIMPORT RTK_ERROR RtkGetIdent (
                    LPSTRING            lpszObjectName,
                    LPULONG             lpulObjectIdent,        /* Output */
                    LPRTK_OBJ_TYPE      lpObjectType            /* Output */
                    );
EXIMPORT RTK_ERROR RtkGetIdentList (
                    ULONG               ulMaxIdentCount,
                    ULONG               ulIdentList[],
                    LPULONG             lpulIdentCount          /* Output */
                    );
EXIMPORT RTK_ERROR RtkGetObjectInfo (
                    ULONG               ulObjectIdent,
                    ULONG               ulMaxNameLength,
                    LPRTK_OBJ_TYPE      lpObjectType,           /* Output */
                    LPSTRING            lpszObjectName          /* Output */
                    );

#endif /* ! _RTKUSER_ */
