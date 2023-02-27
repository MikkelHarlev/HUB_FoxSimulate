/****************************************************************************
*																			*
*																			*
*		Copyright:		Bernecker & Rainer Industrieelektronik Ges.m.b.H	*
*																			*
*		Title :			Rtk.h												*
*		Date  :			November 6th 2000									*
*		Author:			Bernhard Hochstrasser								*
*		Description:	RTK interface: definitions, types and prototypes	*
*																			*
*																			*
****************************************************************************/

#ifndef _INC_RTK_H_
#define _INC_RTK_H_

/** #include <Packed.h> ; geändert am 12.Juni, Andreas Nenning**/
#include "Packed.h"


/* Default handling for RTK functions : "normal C-functions" */
#ifndef EXIMPORT
	#define EXIMPORT
#endif

/*--- Rtk-Objektgruppen-Umschaltung (alt/neu) */

/* globale Umschaltung: 1=Neu, 0=alt */
#define _NEWRTK_ 1

#define _NEWRTK_LOG_        /* immer neu !!! */
#define _NEWRTK_PLAINFIFO_  /* immer neu !!! */
#define _NEWRTK_INTERRUPT_  /* immer neu !!! */

#if _NEWRTK_
/* no risk, no fun */
#define _NEWRTK_TASK_
#define _NEWRTK_SEMAPHORE_
#define _NEWRTK_CRITICAL_
#define _NEWRTK_TIMER_
#define _NEWRTK_EXCEPTION_
#define _NEWRTK_FIFO_
#define _NEWRTK_MEMORY_
#define _NEWRTK_SHAREDMEMORY_
#define _NEWRTK_DEBUGGER_ 
#define _NEWRTK_RTC_
#define _NEWRTK_MISC_

/* Initialisiere neuen Rtk */
#define _NEWRTK_INIT_

/* alten Rtk uebersetzen */
#else
    #define _OLDRTK_
#endif
/*--- end Rtk-Objektgruppen-Umschaltung (alt/neu) */

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
/*    ERR_OK				= 0,*/		/* No error										*/

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

    ERR_RTK_NO_DEBUG	= 25100,	/* Debug: Debugging not supported				*/
    ERR_RTK_BREAKNOTSET,            /* Debug: Breakpoint not set					*/
	ERR_RTK_BREAKNOTDEL,			/* Debug: Breakpoint not deleted				*/
	ERR_RTK_NOSTEP,					/* Debug: Step is not supported					*/
	ERR_RTK_NOGO,					/* Debug: GO is not supported					*/
	ERR_RTK_REGISTER_NUMBER,		/* Debug: invalid registernumber				*/
	ERR_RTK_DB_NOMEM,				/* Debug: not enough free memory				*/
	ERR_RTK_DB_NOEVENT,				/* Debug: no pending event						*/
	ERR_RTK_DB_BPTABFULL,			/* Debug: breakpoint table full					*/ 
	ERR_RTK_DB_BPNOTFOUND,			/* Debug: breakpoint not in breakpoint table	*/		

    ERR_RTK_SOFTPLC_CREATE = 25200,	/* RtkCreateSoftPlc not possible				*/
    ERR_RTK_INIT,                   /* RTK not initialized							*/
    ERR_RTK_DEINIT,                 /* RTK not deinitialized						*/
    ERR_RTK_FATAL,                  /* Fatal internal RTK error						*/
    ERR_RTK_TIMEOUT,                /* Timeout in RTK functions with wait			*/
	ERR_RTK_NOTSUPPORTED,			/* Function not supported in this RTK version	*/

    ERR_RTK_CRITSECCREATE = 25250,	/* CriticalSection not created					*/
    ERR_RTK_CRITSECDELETE,          /* CriticalSection not deleted					*/
    ERR_RTK_CRITSECENTER,           /* CriticalSection not enterd					*/
    ERR_RTK_CRITSECLEAVE,           /* CriticalSection not left						*/

	ERR_RTK_EXC_BASE = 25300,		/* Base for RTK exceptions -> + RTK_EXCTYP_xx	*/
    
    ERR_RTK_LOG_CREATE = 25400,     /* Log not created                              */
    ERR_RTK_LOG_DELETE,             /* Log not deleted                              */
    ERR_RTK_LOG_NOBUFSET,           /* no Log-Buffer set                            */
    ERR_RTK_LOG_LOGACTIVE,          /* Log activ                                    */
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
#define RTK_EVENT_NO_DELETE             0x00000002  /* todo: ???? */

/*--------------------------------------------------------------------------*/
/* Task state flags (taskInfo)                                              */
/*--------------------------------------------------------------------------*/
#define RTK_TASKSTATE_READY             0x00000000  /* Task is not waiting for any resource other than the CPU. */
#define RTK_TASKSTATE_SUSPENDED         0x00000001  /* Task is unavailable for execution. */
#define RTK_TASKSTATE_PENDED            0x00000002  /* Task is blocked due to the unavailability of some resource. */
#define RTK_TASKSTATE_DELAYED           0x00000004  /* Task is asleep for some duration. */
/* RTK_TASKSTATE_DELAYED + RTK_TASKSTATE_SUSPENDED     Task is both delayed and suspended 
   RTK_TASKSTATE_PENDED  + RTK_TASKSTATE_SUSPENDED     Task is both pended and suspended
*/

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
#define RTK_MEM_NO_READ                 0x00000000      /* no read			*/
#define RTK_MEM_NO_WRITE                0x00000000      /* no write		    */
#define RTK_MEM_NOT_EXECUTE             0x00000000      /* no execute		*/
#define RTK_MEM_READ_ALL                0x00000001      /* read for all		*/
#define RTK_MEM_WRITE_ALL               0x00000002      /* write for all	*/
#define RTK_MEM_EXECUTE_ALL             0x00000004      /* execute for all	*/
#define RTK_MEM_READ_LOCAL              0x00000008      /* read only for this task      */
#define RTK_MEM_WRITE_LOCAL             0x00000010      /* write only for this task		*/
#define RTK_MEM_EXECUTE_LOCAL           0x00000020      /* execute only for this task	*/
#define RTK_MEM_NO_INIT                 0x00000000      /* no initialization			*/
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
EXIMPORT RTK_ERROR RtkCreateSemaphore (                         /* !!! obsolet !!! */
                    LPSTRING            lpszSemaphoreName,
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
/* Exceptions																*/
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Exception types                                                          */
/*--------------------------------------------------------------------------*/
#define RTK_EXCTYP_DIVIDE_ERROR		    0
#define RTK_EXCTYP_DEBUG				1
#define RTK_EXCTYP_NMI_INTERRUPT		2
#define RTK_EXCTYP_BREAKPOINT			3
#define RTK_EXCTYP_OVERFLOW				4
#define RTK_EXCTYP_BOUND_RANGE_EXCEEDED	5
#define RTK_EXCTYP_INVALID_OPCODE		6
#define RTK_EXCTYP_DEVICE_NOT_AVAILABLE	7
#define RTK_EXCTYP_DOUBLE_FAULT			8
#define RTK_EXCTYP_COPROCESSOR_SEGMENT_OVERRUN  9
#define RTK_EXCTYP_INVALID_TASK_STATE_SEGMENT	10
#define RTK_EXCTYP_SEGMENT_NOT_PRESENT	11
#define RTK_EXCTYP_STACK_FAULT			12
#define RTK_EXCTYP_GENERAL_PROTECTION	13
#define RTK_EXCTYP_PAGE_FAULT			14
#define RTK_EXCTYP_FLOATING_POINT_ERROR	16
#define RTK_EXCTYP_ALIGNMENT_CHECK		17
#define RTK_EXCTYP_MACHINE_CHECK		18
#define RTK_EXCTYP_RESERVED				98
#define RTK_EXCTYP_UNKNOWN				99

EXIMPORT RTK_ERROR RtkWaitForException (
				    LPULONG		        lpulExceptionType,
					LPULONG				lpulExceptionRtkTaskIdent,
					LPULONG				lpulExceptionProgramCounter
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
/* Debugger                                                                 */
/****************************************************************************/

/* breakpoint valid for all tasks */
#define	RTK_DEBUG_BREAK_ANY_TASK	    0x00000000

/* delete all breakpoints with 1 call */
#define	RTK_DEBUG_DELETE_ALL_BREAKPOINTS    0x00000000

/* informationen in message structure */
#define	RTK_DEBUG_KONTEXT_STEP_DONE	    0xFFFFFFFF

/*--------------------------------------------------------------------------*/
/* Message structure for debugger breakpoint and debugger step			    */
/*--------------------------------------------------------------------------*/
typedef struct {
	ULONG	BreakAddress;	/* address of breakpoint/step (ProgramCounter)	*/
	ULONG	TaskIdent;		/* ident of breaked/stepped task				*/
	ULONG	BreakKontext;	/* optional RTK_DEBUG_KONTEXT_STEP_DONE			*/
} RTK_DEBUG_MESSAGE;

typedef  RTK_DEBUG_MESSAGE *	LPRTK_DEBUG_MESSAGE;
	
/*--------------------------------------------------------------------------*/
/* Register structure (depending on processor type)						    */
/*--------------------------------------------------------------------------*/
#ifdef RTK_68000
 	/* Register structure for 68000 processors */
	typedef struct {
		ULONG	ssp;
		ULONG	usp;
		ULONG	d0;
		ULONG	d1;
		ULONG	d6;
		ULONG	a0;
		ULONG	a1;
		ULONG	a2;
		ULONG	a3;
		ULONG	d2;
		ULONG	d3;
		ULONG	d4;
		ULONG	d5;
		ULONG	d7;
		ULONG	a4;
		ULONG	a5;
		ULONG	a6;
		WORD	sr;
		ULONG	pc;
	} RTK_68K_REGISTER;
	typedef  RTK_68K_REGISTER	RTK_REGISTER;
#else
	/* Register structure for x86 processors (INtime, WinNT, WinCE) */
	typedef struct {
		ULONG	eax;
		ULONG	ebx;
		ULONG	ecx;
		ULONG	edx;
		ULONG	esi;
		ULONG	edi;
		ULONG	eip;
		ULONG	esp;
		ULONG	ebp;
		ULONG	efl;
		WORD	cs;
		WORD	ds;
		WORD	es;
		WORD	fs;
		WORD	gs;
		WORD	ss;
	} RTK_X86_REGISTER;
	typedef  RTK_X86_REGISTER	RTK_REGISTER;
#endif
typedef  RTK_REGISTER *	LPRTK_REGISTER;

EXIMPORT RTK_ERROR RtkConnectDebugger (
					LPSTRING		    lpszDebuggerName,
                    LPULONG             lpulDebuggerIdent       /* Output */
                    );
EXIMPORT RTK_ERROR RtkDisconnectDebugger (
                    ULONG			    ulDebuggerIdent
                    );
EXIMPORT RTK_ERROR RtkSetBreakpoint (
                    ULONG				ulDebuggerIdent,
                    LPVOID              lpCodeaddress,
					ULONG			    ulTaskIdent,
					ULONG				ulBreakpointContext
                    );
EXIMPORT RTK_ERROR RtkDeleteBreakpoint (
                    ULONG			    ulDebuggerIdent,
                    LPVOID              lpCodeadresse,
					ULONG				ulTaskIdent
                    );
EXIMPORT RTK_ERROR RtkDebugStep (
                    ULONG				ulDebuggerIdent,
					ULONG			    ulTaskIdent
                    );
EXIMPORT RTK_ERROR RtkDebugGo (
                    ULONG				ulDebuggerIdent,
					ULONG			    ulTaskIdent
                    );
EXIMPORT RTK_ERROR RtkReceiveDebugMessage (
                    ULONG			    ulDebuggerIdent,
                    LPVOID              lpMessage,
                    ULONG               ulMaxMessageLength,
                    ULONG               ulTimeoutUsec,
                    LPULONG             lpulMessageLength		/* Output */
                    );
EXIMPORT RTK_ERROR RtkReadRegister (
                    ULONG				ulDebuggerIdent,
					ULONG			    ulTaskIdent,
				    LPRTK_REGISTER		lpRegisterStructure	    /* InOut */
                    );
EXIMPORT RTK_ERROR RtkWriteRegister (
                    ULONG				ulDebuggerIdent,
					ULONG				ulTaskIdent,
				    LPRTK_REGISTER		lpRegisterStructure
                    );

/****************************************************************************/
/* Logging (new)    														*/
/****************************************************************************/

/*--------------------------------------------------------------------------*/
/* Default System-Log-Object (always created from RTK)                      */
/*--------------------------------------------------------------------------*/
#define RTK_SYSTEM_LOG                  "PROFILER"

/*--------------------------------------------------------------------------*/
/* Definitions for Log-Mode                                                 */
/*--------------------------------------------------------------------------*/
#define RTK_LOGMODE_UNTIL_FULL			0	/* Log only until buffer full (from start to end)	*/
#define	RTK_LOGMODE_CONTINUOUS			1   /* Log continuous start->end->start... (Overwrite)	*/

/*--------------------------------------------------------------------------*/
/* Definitions for Log-State                                                */
/*--------------------------------------------------------------------------*/
#define	RTK_LOGSTATE_STOPPED			0	/* Log stopped */
#define	RTK_LOGSTATE_STARTED			1	/* Log started */

/*--------------------------------------------------------------------------*/
/* Log Group's                                                              */
/*--------------------------------------------------------------------------*/
#define	RTK_LOGGRP_TASK_SWITCH		    0   /* Group Task-Switch */
#define	RTK_LOGGRP_IRQ_HANDLER			1   /* Group IRQ-Handler */
#define RTK_LOGGRP_CYCLIC_TASK          2   /* Group Cyclic-Tasks */
#define RTK_LOGGRP_LIB_FUNC             3   /* Group Library Functions */
#define	RTK_LOGGRP_TASK					4   /* Group Rtk-Task Functions */
#define	RTK_LOGGRP_IRQ					5   /* Group Rtk-IRQ Functions */
#define	RTK_LOGGRP_MEMORY				6   /* Group Rtk-Memory Functions */
#define	RTK_LOGGRP_SEMAPHORE			7   /* Group Rtk-Semaphore Functions */
#define	RTK_LOGGRP_FIFO					8   /* Group Rtk-FIFO Functions */
#define	RTK_LOGGRP_SHARED_MEMORY		9   /* Group Rtk-Shared Memory Functions */
#define	RTK_LOGGRP_CRITICAL_SECTION		10  /* Group Rtk-Critical Section Functions */
#define	RTK_LOGGRP_TIMER				11  /* Group Rtk-Timer Functions */
#define	RTK_LOGGRP_RTC				    12  /* Group Rtk-RTC Functions */
#define	RTK_LOGGRP_DEBUGGER				13  /* Group Rtk-Debugger Functions */
#define	RTK_LOGGRP_EXC					14  /* Group Rtk-Exception Functions */
#define	RTK_LOGGRP_MISC					15  /* Group Rtk-miscellaneous Functions */
#define	RTK_LOGGRP_PLAIN_FIFO			16  /* Group Rtk-Plain-FIFO Functions */
#define	RTK_LOGGRP_USEREVENT			31  /* Group USER Events */

/*--------------------------------------------------------------------------*/
/* Log Group's Enable/Disable masks                                         */
/*--------------------------------------------------------------------------*/

/* macro to generate log group mask */
#define RTK_LOGGRPMSK(GROUP)                                                \
        (1<<GROUP)

/* internal: macro to determine if log group is enabled */
#define RTK_LOGGRPISSET(EVENT, MASK)                                        \
        (MASK & (1<<(EVENT>>24)))

/*--------------------------------------------------------------------------*/
/* Definitions of all RTK/System internal log event idents                  */
/*--------------------------------------------------------------------------*/

/* macro to generate event */
#define RTK_LOGEV(GROUP,EVENT)                                              \
        ((GROUP << 24) | (EVENT & 0x00FFFFFF))

/* System internal log event idents */
#define	RTK_LOGEV_TASKSWITCH		    0   /* Group Task-Switch */

#define	RTK_LOGEV_IRQ_HANDLER_BEGIN		0   /* Group IRQ-Handler */
#define	RTK_LOGEV_IRQ_HANDLER_END		1

#define RTK_LOGEV_CYCLIC_TASK_BEGIN     0   /* Group Cyclic-Tasks */
#define RTK_LOGEV_CYCLIC_TASK_END       1

#define	RTK_LOGEV_LIB_FUNC_BEGIN		0   /* Group Library-Functions */
#define	RTK_LOGEV_LIB_FUNC_END			1

#define	RTK_LOGEV_CREATETASK			0   /* Group Rtk-Task Functions */
#define	RTK_LOGEV_DELETETASK			1
#define	RTK_LOGEV_SUSPENDTASK			2
#define	RTK_LOGEV_RESUMETASK			3
#define	RTK_LOGEV_SLEEPTASKUSEC			4
#define	RTK_LOGEV_SENDTASKEVENT			5
#define	RTK_LOGEV_RECEIVETASKEVENT		6
#define	RTK_LOGEV_RECEIVEDTASKEVENT		7
#define	RTK_LOGEV_SENDTASKEVENTCYCLIC	8
#define	RTK_LOGEV_SENDTASKEVENTAFTER	9
#define	RTK_LOGEV_CANCELTASKTIMER		10
#define	RTK_LOGEV_SETTASKVALUE			11
#define	RTK_LOGEV_GETTASKVALUE			12
#define	RTK_LOGEV_GETTASKPRIORITY		13
#define	RTK_LOGEV_SETTASKPRIORITY		14

#define	RTK_LOGEV_CONNECTINTERRUPT		0   /* Group Rtk-IRQ Functions */
#define	RTK_LOGEV_DISCONNECTINTERRUPT	1

#define	RTK_LOGEV_ALLOCATEMEMORY		0   /* Group Rtk-Memory Functions */
#define	RTK_LOGEV_FREEMEMORY			1

#define	RTK_LOGEV_CREATESEMAPHORE		0   /* Group Rtk-Semaphore Functions */
#define	RTK_LOGEV_DELETESEMAPHORE		1
#define	RTK_LOGEV_ACQUIRESEMAPHORE		2
#define	RTK_LOGEV_RELEASESEMAPHORE		3

#define	RTK_LOGEV_CREATEFIFO			0   /* Group Rtk-FIFO Functions */
#define	RTK_LOGEV_DELETEFIFO			1
#define	RTK_LOGEV_WRITEFIFO				2
#define	RTK_LOGEV_READFIFO				3
#define	RTK_LOGEV_CLEARFIFO				4
#define	RTK_LOGEV_ATTACHFIFO			5
#define	RTK_LOGEV_RELEASEFIFO			6

#define	RTK_LOGEV_CREATESHAREDMEMORY	0   /* Group Rtk-Shared Memory Functions */
#define	RTK_LOGEV_DELETESHAREDMEMORY	1
#define	RTK_LOGEV_MAPSHAREDMEMORY		2
#define	RTK_LOGEV_UNMAPSHAREDMEMORY		3

#define	RTK_LOGEV_CREATECRITICALSECTION	0   /* Group Rtk-Critical Section Functions */
#define	RTK_LOGEV_DELETECRITICALSECTION	1
#define	RTK_LOGEV_ENTERCRITICALSECTION	2
#define	RTK_LOGEV_LEAVECRITICALSECTION	3

#define	RTK_LOGEV_CREATETIMER			0   /* Group Rtk-Timer Functions */
#define	RTK_LOGEV_DELETETIMER			1
#define	RTK_LOGEV_STARTTIMER			2
#define	RTK_LOGEV_STOPTIMER				3

/* todo */                                  /* Group Rtk-RTC Functions */
/* todo */                                  /* Group Rtk-Debugger Functions */
/* todo */                                  /* Group Rtk-Exception Functions */
/* todo */                                  /* Group Rtk-miscellaneous Functions */
/* todo */                                  /* Group Rtk-Plain-Fifo Functions */

/*--------------------------------------------------------------------------*/
/* Structure for log buffer entry										    */
/*--------------------------------------------------------------------------*/

/* Because the length of the additional data within a log buffer entry is fixed,
but variable for different log buffers, only the "header" of a log buffer
entry can be defined. An entry consists of this header and the additional
data following immediately */
#ifndef _MRI
    #pragma pack(1)
#endif

typedef struct
{
	ULONG	ulTickCountLow  PACKED; /* High-Long of TickCount (output of LogTimeFunction)   */
	ULONG	ulTickCountHigh PACKED;	/* Low-Long of TickCount (output of LogTimeFunction)    */
	ULONG	ulEventIdent    PACKED;	/* unique event-ident								    */
	ULONG	ulObjIdent      PACKED;	/* unique object-ident							        */
} RTKLOGENTRY;

#ifndef _MRI
    #pragma pack()
#endif

typedef RTKLOGENTRY*  LPRTKLOGENTRY;

/* !!!! todo: weg damit -> z. Zt. Befriedigung des alten RTK */
typedef struct
{
	ULONG	ulTickCountHigh;	/* High-Long of TickCount (output of LogTimeFunction)		*/
	ULONG	ulTickCountLow;		/* Low-Long of TickCount (output of LogTimeFunction)		*/
	ULONG	ulEventIdent;		/* unique event-ident										*/
	ULONG	ulDataFlags;		/* Flags for datainterpreter (string, BY/WO/LO-array, ...)	*/
	ULONG	ulDataLength;		/* Length of additional data of this event					*/
} RTK_LOG_ENTRY_HEADER;

typedef RTK_LOG_ENTRY_HEADER*  LPRTK_LOG_ENTRY_HEADER;
/* end old */

/*--------------------------------------------------------------------------*/
/* Function for timestamp												    */
/*--------------------------------------------------------------------------*/

/* void GetLogTime (ULONG ulTickCount[2]); */
typedef  void (*LPRTK_LOGTIME_FKT) (ULONG ulTickCount[2]);

EXIMPORT RTK_ERROR RtkCreateLog (
				    LPSTRING		    lpszLogName,
					LPRTK_LOGTIME_FKT	lpLogTimeFunction,
					LPULONG				lpulLogIdent			/* Output */
					);
EXIMPORT RTK_ERROR RtkDeleteLog (
					ULONG				ulLogIdent
					);
EXIMPORT RTK_ERROR RtkSetLogBuffer (
					ULONG				ulLogIdent,
                    LPBYTE              lpbyLogBuffer,
                    ULONG               ulLogBufferLen,
					ULONG 				ulLogEntryAdditionalDataSize,
                    ULONG               ulLogMode
					);
EXIMPORT RTK_ERROR RtkStartLog (
					ULONG				ulLogIdent,
					ULONG				ulEnableMask
					);
EXIMPORT RTK_ERROR RtkStopLog (
					ULONG				ulLogIdent,
					ULONG				ulDisableMask
					);
EXIMPORT RTK_ERROR RtkLogEvent (
					ULONG				ulLogIdent,
					ULONG				ulEventIdent,
                    ULONG               ulObjectIdent
					);
EXIMPORT RTK_ERROR RtkLogEventEx (
					ULONG				ulLogIdent,
					ULONG				ulEventIdent,
                    ULONG               ulObjectIdent,
					LPBYTE				lpbyAdditionalData,
					ULONG				ulAdditionalDataLength
					);
EXIMPORT RTK_ERROR RtkLogInfo (
   					ULONG				ulLogIdent,
					LPBYTE *			lpbyLogBuffer,			/* Output */
					LPULONG				lpulLogEntrySize,	    /* Output */
					LPULONG				lpulMaxEntryCount,	    /* Output */
                    LPULONG             lpulFirstEntry,         /* Output */
                    LPULONG             lpulLastEntry,          /* Output */
                    LPULONG             lpulLogState,           /* Output */
					LPULONG				lpulTimeStampTicksPerSecond,	/* Output */
					LPULONG				lpulTimeStampTicksPerUsec		/* Output */
					);

/****************************************************************************/
/* miscelleanous functions    										        */
/****************************************************************************/

EXIMPORT RTK_ERROR RtkLibInit (
                    void
                    );
EXIMPORT RTK_ERROR RtkLibExit (
                    void
                    );
EXIMPORT void RtkShutDown (
                    RTKBOOLEAN          bRestartFlag
                    );
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
EXIMPORT ULONG RtkReadUsecCounter (
                    void
                    );
EXIMPORT RTK_ERROR RtkSetSystemTick (
                    ULONG               ulUsec
                    );
EXIMPORT ULONG RtkGetSystemTick (
                    void
                    );
EXIMPORT void RtkShowObjects (
                    void
                    );

#endif /* ! _INC_RTK_H_ */
