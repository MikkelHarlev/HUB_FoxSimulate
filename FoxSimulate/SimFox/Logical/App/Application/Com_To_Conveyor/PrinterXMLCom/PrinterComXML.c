/********************************************************************
 * COPYRIGHT -- JENSEN
 ********************************************************************
 * Program: PrinterComXML
 * File: PrinterComXML.c
 * Author: jsnicsey
 * Created: September 23, 2009
 ********************************************************************
 * Implementation of program PrinterComXML
 * Version 0.01 NS20090915
 ********************************************************************/

#include <bur/plctypes.h>

#ifdef _DEFAULT_INCLUDES
#include <AsDefault.h>
#endif

#include <bur/plc.h>
//#include <AsString.h>
#include <String.h>
#include "rtk.h"
#include "rtkuser.h"
#include <Convert.h>
#include <ethsock.h>
#include <metutils.h>
#include <errdef.h>
#include "ApplicationVAR.h"
#include "CMSupport.h"

/*———[ debug code ]—————————————————————————————————————————————————————————————————————————————————————————————*/

#undef NDEBUG                                                   /* assert macro active + extra check added      */
#define NDEBUG/**/                                              /* no debug code included in the build          */
#include <errutils.h>                                           /* assert macro definition & log book utilities */

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

#define PACK_PORT				81								/* Server is listening here						*/
#define PACK_MAXBUF				16384							/* size of communication buffer					*/
#define PACK_MAXERROR			50								/* the maximum number of char in an error string*/

#define PACK_STATUS_FAIL		0								/* Pack com is permanently down					*/
#define PACK_STATUS_OK			1								/* Pack com is ready							*/
#define PACK_STATUS_WAIT		2								/* Pack com is busy, not connected				*/
#define PACK_STATUS_OFF			3								/* Pack com is disabled							*/
#define PACK_STATUS_SEND		4								/* Pack com asked to send						*/
#define PACK_STATUS_SENDING		5								/* Pack com is sending							*/
#define PACK_STATUS_RECEIVE		6								/* Pack com asked to receive					*/
#define PACK_STATUS_RECEIVING	7								/* Pack com is receiving						*/
#define CONN_INIT		0										/* Connection setup								*/
#define CONN_RUNTIME	1										/* Conncection running							*/
#define MLABEL_SYSID	3										/* SysID system file							*/

/*———[ Types     ]——————————————————————————————————————————————————————————————————————————————————————————————*/

/*- Private types -----------------------------------------------------------*/

const char XML_CLIENT_CALL_HTTP[] = "POST / HTTP/1.0\nContent-Length: %5d\nConnection: Keep-Alive\nContent-Type: text/xml\n\n";

typedef struct PackMessage_Type									/* structure of an XML server reply				*/
{
	unsigned long		headerSize;								/* where message starts in buffer				*/
	unsigned long		httpStatus;								/* last http status number						*/
	char				httpText[PACK_MAXERROR];				/* last http status text description			*/
	unsigned long		messageSize;							/* message size + header size = used buffer size*/
	signed	 long		messageID;								/* returned message counter						*/
	signed   long		errorNumber;							/* last XML error number						*/
	char				errorText[PACK_MAXERROR];				/* last XML error message						*/
	BOOL				errorFlag;								/* is it an error?								*/
	signed   long		serverStatus;							/* typical value returned by server				*/
} PackMessage_Type;

typedef struct PackModule_Type									/* structure of a Pack connection				*/
{
	UINT				status;
	char				IPstr[17];								/* IP address in string format					*/
	UINT				timeOut;								/* Keep alive / timeout delay					*/
	char	*			buffer;									/* composition buffer							*/
	PackMessage_Type	reply;									/* parsed reply from the server					*/
	UINT				connectCount;							/* number of connection attempts				*/
	UINT				connectedCount;							/* number of connection success					*/
	UINT				sendCount;								/* number of messages sent						*/
	UINT				recieveCount;							/* number of messages recieved					*/
	UINT				errorCount;								/* number of errors								*/
	DINT				errorNumber;							/* last error number							*/
	char				errorText[PACK_MAXERROR];				/* last error message							*/
} PackModule_Type;
typedef PackModule_Type * PackModulePtr_Type;

typedef struct PackThread_Type									/* communication data type to Pack thread		*/
{
	/* default variables for thread handling */
	UDINT				threadId;
	BOOL				cmdStopThread;
	BOOL				threadActive;
	/* any other variables can be added here */
	BOOL				reinitIP;								/* close and reopen socket (used by PackActivate)*/
	DINT				state;									/* private status								*/
	PackModulePtr_Type	public;									/* reference to a Pack connection				*/
	UINT				index;									/* Pack connection index						*/
	signed long			socket;
	ETH_sockaddr_typ	eth_serv_adr;
} PackThread_Type;
typedef PackThread_Type * PackThreadPtr_Type;

/*———[ Globals   ]——————————————————————————————————————————————————————————————————————————————————————————————*/

/*———[ Locals ]—————————————————————————————————————————————————————————————————————————————————————————————————*/

_LOCAL PackThread_Type	MVPackThreadData;						/* define communcation variable to the thread	*/
_LOCAL PackModule_Type	MVPack;									/* public interface of the PackXML client		*/
_LOCAL BOOL				isEnabled;
_LOCAL UINT				FolderStatus;
_LOCAL DINT				messageID, MLabelComRefreshTimer;
_LOCAL UDINT			OldMilliseconds;
_LOCAL char				tmpStr[17];				
_LOCAL char				statusStr[200];				
_LOCAL UDINT			strLen1[10];				
_LOCAL char				IPStr[17];				
_LOCAL USINT			Log;				
_LOCAL ComCMIFCon_Type*					pConnInterface;				
_LOCAL XMLComServiceInterfaceCon_Type*	pConnRuntime;				
_LOCAL int				conState;

/*———[ Forward decl ]———————————————————————————————————————————————————————————————————————————————————————————*/

/* to initialize a Pack communication thread*/
UINT PackInit(PackThreadPtr_Type pThread, PackModulePtr_Type pPack, UINT idx );
/* terminate thread and close sockets	*/
UINT PackExit(PackThreadPtr_Type pThread);
/* change the socket address	*/
UINT PackActivate(PackThreadPtr_Type pThread, const char *address);

void PackThreadFunction(PackThreadPtr_Type pThread);			/* declaration of the noncyclic funtion			*/
void PackRun(PackThreadPtr_Type pThread);						/* main communication loop						*/
unsigned long PackFilterHttp(PackModulePtr_Type client, unsigned long len);
void PackParseHttp(PackModulePtr_Type client, unsigned long len);
void PackParseXML(PackModulePtr_Type client, unsigned long len);
void PackOpenTCP(PackThreadPtr_Type pThread);					/* to open a connection to a server				*/
int  PackCheckTCP(PackThreadPtr_Type pThread);					/* to check a TCP connection status				*/
void PackCloseTCP(PackThreadPtr_Type pThread);					/* to close a connection to a server			*/
UINT PackSendTCP(PackThreadPtr_Type pThread, void * buf, unsigned long * len);	/* to send a message			*/
UINT PackReceiveTCP(PackThreadPtr_Type pThread, void * buf, unsigned long * len);	/* to get a reply			*/
void PackError(PackThreadPtr_Type pThread, DINT errnbr, char * errtxt, DINT status);	/* to set an error state*/

int PackProcessBuffer(PackThreadPtr_Type pThread, unsigned long * size);
void PackEncodeHTTP(PackModulePtr_Type client, long size);
long PackEncodeXML(PackModulePtr_Type client, char * MNum, long MId, char * v, long FolderStatus, long msgID, long stackID, UINT count, StackItemData_Type * item);

/*———[ Task ]———————————————————————————————————————————————————————————————————————————————————————————————————*/

void _INIT PrinterComXMLINIT( void )
{
	pConnInterface = (ComCMIFCon_Type*) &g_Core.Services.Communication.ConnectionManager.Interface.connection[2];
	pConnRuntime = (XMLComServiceInterfaceCon_Type*) &g_Core.Services.Communication.ConnectionManager.Runtime.connection[2];

	Log = 1;
	MVPack.timeOut = 6000; 
	strLen1[0] = (UDINT) strcpy( MVPack.IPstr, "0.0.0.0" );
	PackInit( &MVPackThreadData, &MVPack, g_PrinterComHMI.MachineId );
	MVPack.buffer[0] = 0;
	FolderStatus = g_PrinterCom.FolderStatus;
	messageID = 0;
	MLabelComRefreshTimer = 2000;
}

void _CYCLIC PrinterComXMLCYCLIC( void )
{
	unsigned long i;

	switch (conState)
	{
		case CONN_INIT:	// Communication setup
			addConnectionPrinter.sysID = MLABEL_SYSID;
			addConnectionPrinter.descriptionID = 40;
			addConnectionPrinter.isEnabled = 1;
			addConnectionPrinter.modeAddress = SELECTABLE; 
			addConnectionPrinter.modeID = SELECTABLE;
			addConnectionPrinter.transportType = TCPIP; 
			addConnectionPrinter.roleType = CLIENT; 
			addConnectionPrinter.logicType = CUSTOM;
			addConnectionPrinter.modeBASE64 = OFF;
			addConnectionPrinter.modeRefreshTime = SELECTABLE; 
			addConnectionPrinter.maxConnectionID = 19;
			addConnectionPrinter.hierarchy = AFTER;// No time sync
			addConnectionPrinter.port = 81;
			addConnection(&addConnectionPrinter);
			if (addConnectionPrinter.status == 0 || addConnectionPrinter.status == 3) {
				// Adding connections done.
				pConnInterface = (ComCMIFCon_Type*) &g_Core.Services.Communication.ConnectionManager.Interface.connection[2];
				pConnRuntime = (XMLComServiceInterfaceCon_Type*) &g_Core.Services.Communication.ConnectionManager.Runtime.connection[2];
				conState = 1;
			}
			break;
		
		case CONN_RUNTIME:
			g_PrinterCom.isEnabled = pConnRuntime->metaData.isEnabled;
			pConnInterface->status.serverState = g_PrinterComHMI.CommunicationStatus;;
			pConnInterface->status.clientState = 1;
			strcpy(statusStr, "");
			itoa(MVPack.errorNumber, (unsigned long)&statusStr);
			strcat(statusStr, " ");
			strcat(statusStr, MVPack.errorText);
			strcat(statusStr, " - Folder status: ");
			itoa(g_PrinterCom.FolderStatus, (unsigned long)&tmpStr);
			strcat(statusStr, tmpStr);
			strcat(statusStr, " Printer status: ");
			itoa(g_PrinterCom.MLabelStatus, (unsigned long)&tmpStr);
			strcat(statusStr, tmpStr);
			pConnInterface->status.adrStatusString = (unsigned long)&statusStr;
			pConnInterface->status.adrStatusString = (unsigned long)&statusStr;
			pConnInterface->status.rxCounts = MVPack.recieveCount;
			pConnInterface->status.txCounts = MVPack.sendCount;
			pConnInterface->status.txErrors = MVPack.errorCount;
			pConnRuntime->initState = RUNTIME;
			g_PrinterComHMI.PrinterStatus = MVPack.status;
			break;
		
	}

	MVPack.timeOut = pConnRuntime->metaData.refreshTime * 3;
	if ((strcmp(IPStr, pConnRuntime->metaData.address) || isEnabled != pConnRuntime->metaData.isEnabled) && (strlen(pConnRuntime->metaData.address) >= 7) && (pConnRuntime->metaData.refreshTime > 0) )
	{
		strcpy( IPStr, pConnRuntime->metaData.address );
		isEnabled = pConnRuntime->metaData.isEnabled;
		if (isEnabled)
			strcpy( MVPack.IPstr, pConnRuntime->metaData.address );
		else
			strcpy( MVPack.IPstr, "0.0.0.0" );

		LogEntry(g_MCfg.Trace2File, (UDINT)&T2FD, 1, Log, 1001, MVPack.IPstr );
		MVPackThreadData.reinitIP = TRUE;
		g_PrinterComHMI.CommunicationStatus = 0;
	}

	if (MVPackThreadData.reinitIP) return;

	MLabelComRefreshTimer = MLabelComRefreshTimer - (g_MilliSeconds - OldMilliseconds);
	OldMilliseconds = g_MilliSeconds;

	if (PACK_STATUS_OK != MVPack.status)
	{
		switch (MVPack.status)
		{
			case PACK_STATUS_FAIL:								/* Pack com is permanently down					*/
			case PACK_STATUS_WAIT:								/* Pack com is busy, not connected				*/
			case PACK_STATUS_OFF:								/* Pack com is disabled							*/
				g_PrinterComHMI.CommunicationStatus = 0;
				break;
			default:
				/*g_PrinterComHMI.CommunicationStatus = 2*/;	/* busy state									*/
		}
		return;
	}

	if (FolderStatus != g_PrinterCom.FolderStatus || MLabelComRefreshTimer < 0)
	{
		FolderStatus = g_PrinterCom.FolderStatus;
		if (++messageID > 32767) messageID = 1;
		i = PackEncodeXML(&MVPack, g_Core.System.Configuration.SystemDescription.MachineNumber, g_PrinterComHMI.MachineId, g_Core.System.Configuration.SystemDescription.ProgramVersion, g_PrinterCom.FolderStatus, messageID, g_OutletProcess.StackerUnit[1].StackData[1].BatchId, g_OutletProcess.StackerUnit[1].StackData[1].Count, g_OutletProcess.StackerUnit[1].StackData[1].ItemData);
		PackEncodeHTTP(&MVPack, i);
		MVPack.status = PACK_STATUS_SEND;
		MLabelComRefreshTimer = pConnRuntime->metaData.refreshTime;
		return; 
	}

	if (MVPack.reply.errorFlag)
	{
		MVPack.reply.errorFlag = FALSE;
		MVPack.reply.messageID = -1;
		MLabelComRefreshTimer = pConnRuntime->metaData.refreshTime;
		MVPack.errorCount++;
		MVPack.errorNumber = MVPack.reply.errorNumber;
		strcpy( MVPack.errorText, MVPack.reply.errorText );
		g_PrinterCom.MLabelStatus = MVPack.reply.serverStatus;
		g_PrinterComHMI.CommunicationStatus = 0;
	}
	else if (MVPack.reply.messageID == messageID)
	{
		MVPack.reply.messageID = -1;
		MLabelComRefreshTimer = pConnRuntime->metaData.refreshTime;
		g_PrinterCom.MLabelStatus = MVPack.reply.serverStatus;
		g_PrinterComHMI.CommunicationStatus = 1;
		
	}
	
	MVPack.status = PACK_STATUS_RECEIVE;
}

void _EXIT PrinterComXMLEXIT( void )
{
	PackExit( &MVPackThreadData );
}

/*———[ Thread ]—————————————————————————————————————————————————————————————————————————————————————————————————*/

/* to initialize a Pack communication thread	*/
UINT PackInit(PackThreadPtr_Type pThread, PackModulePtr_Type pPack, UINT idx)
{
	char name[6];												/* thread name									*/
	USINT priority = 191;										/* task priority								*/
	UDINT svStack  = 2*1024;									/* supervisor stack 							*/
	UDINT uStack   = 20*1024;									/* user stack									*/

	pThread->public = pPack;
	pThread->reinitIP = FALSE;
	pThread->index = idx;
	PackError( pThread, 0, "Not initialized", PACK_STATUS_WAIT );
	
	pThread->state = TMP_alloc( PACK_MAXBUF, (void*)(&(pThread->public->buffer)) ) ;
	if (pThread->state)											/* allocation failed							*/
	{
		PackError( pThread, pThread->state, "Thread failed to start", PACK_STATUS_FAIL );
		ERRxwarning( idx, pThread->state, pThread->public->errorText );
		return pThread->state;
	}

	pThread->public->connectCount = 0;	
	pThread->public->connectedCount = 0;
	pThread->public->sendCount = 0;
	pThread->public->recieveCount = 0;
	pThread->public->errorCount = -1;
	pThread->socket = ERR_SOCKET;
	
	metsprintf( name, "Pack%d", idx );
	pThread->cmdStopThread = FALSE;
	/* install non-cyclic function					*/
	pThread->state = RtkCreateTask( name, priority, svStack, uStack, 0, (void*)PackThreadFunction, (UDINT)pThread, &(pThread->threadId) );
	if (pThread->state)
	{
		PackError( pThread, pThread->state, "Thread failed to start", PACK_STATUS_FAIL );
		ERRxwarning( idx, pThread->state, pThread->public->errorText );
	}
	return pThread->state;
}

UINT PackExit(PackThreadPtr_Type pThread)
{
	if (pThread->threadActive)
	{
		RtkDeleteTask(pThread->threadId);
		PackError( pThread, 0, "Thread stopped", PACK_STATUS_FAIL );
		ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
	}
	if (pThread->socket != ERR_SOCKET )
		PackCloseTCP(pThread);
	TMP_free( PACK_MAXBUF, pThread->public->buffer );
	return 0;
}

UINT PackActivate(PackThreadPtr_Type pThread, const char *address)
{
	if (!pThread->threadActive) return pThread->state;
	if ( *address == '0' )
		ERRxwarning( 0, pThread->index, "de-activate" );
	else
		logprintf( 0, pThread->index, "activate '%s'", address );
	PackError( pThread, 0, "Not initialized", PACK_STATUS_WAIT );
	metsprintf( pThread->public->IPstr, "%.*s", 16, address );
	pThread->reinitIP = TRUE;
	return pThread->state;
}

void PackThreadFunction(PackThreadPtr_Type pThread)
{
	pThread->threadActive = TRUE;
	pThread->public->errorText[0] = 0;							/* not-not initialized							*/
	PackOpenTCP( pThread);

	while ( pThread->cmdStopThread == FALSE )					/* loop until stop command is received			*/
		PackRun( pThread );										/* main communication loop						*/
	if ( pThread->socket != ERR_SOCKET )
		PackCloseTCP( pThread );								/* close connections							*/

	pThread->threadActive  = FALSE;								/* response to user that thread was stopped		*/
	pThread->cmdStopThread = FALSE;								/* reset stop command							*/
	RtkDeleteTask(pThread->threadId);							/* stop noncyclic task .. should not be done in cyclic part because of execution time */
	PackError( pThread, 0, "Thread stopped", PACK_STATUS_FAIL );
	ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
}

/*- Mainfunc. ---------------------------------------------------------------*/

void PackRun(PackThreadPtr_Type pThread)						/* main communication loop						*/
{
	int ret;
	long count;
	unsigned long len, total;
	char * buf;
	
	if ( pThread->reinitIP )									/* if re-activated: try new IP address			*/
	{
		pThread->reinitIP = FALSE;
		PackError( pThread, 0, "Not initialized", PACK_STATUS_WAIT );
		if (pThread->socket != ERR_SOCKET ) PackCloseTCP(pThread);
	}

	switch (pThread->public->status)
	{
		case PACK_STATUS_FAIL:									/* Pack com is permanently down					*/
			RtkSleepTaskUsec( 1000000 );
			break;
		case PACK_STATUS_OK:									/* Pack com is ready							*/
			RtkSleepTaskUsec( 25000 );							/* idle at 25msec								*/
			break;
		case PACK_STATUS_WAIT:									/* Pack com is busy, not connected				*/
			PackOpenTCP(pThread);
			if (PACK_STATUS_WAIT == pThread->public->status)
				RtkSleepTaskUsec( pThread->public->timeOut * 1000 );
			break;
		case PACK_STATUS_OFF:									/* Pack com is disabled							*/
			RtkSleepTaskUsec( 1000000 );
			break;
		case PACK_STATUS_SEND:									/* Pack com asked to send						*/
			pThread->public->status = PACK_STATUS_SENDING;
		case PACK_STATUS_SENDING:								/* Pack com is sending							*/
			buf = pThread->public->buffer;
			total = strlen(pThread->public->buffer);
			len = total;
			count = pThread->public->timeOut >> 1;
			while (0 == PackSendTCP(pThread, buf, &len))
			{
				if (total == len)
				{
					pThread->public->status = PACK_STATUS_OK;
					break;
				}
				if (total < len)
				{
					ERRxwarning( pThread->public->status, len, "Sent more than available" );
					PackError( pThread, 0, "sent more than available", PACK_STATUS_FAIL );
					PackCloseTCP( pThread );
					break;
				}
				buf += len;
				total -= len;
				len = total;
				if (--count < 0)
				{
					PackError( pThread, 0, "send time-out", PACK_STATUS_WAIT );
					PackCloseTCP( pThread );
					break;
				}
				RtkSleepTaskUsec( 2000 );
			}
			break;
		case PACK_STATUS_RECEIVE:								/* Pack com asked to receive					*/
			pThread->public->status = PACK_STATUS_RECEIVING;
		case PACK_STATUS_RECEIVING:								/* Pack com is receiving						*/
			buf = pThread->public->buffer;
			total = 0;
			len = PACK_MAXBUF-1;
			while (0 == PackReceiveTCP(pThread, buf, &len))
			{
				if (0 == len)
				{
					ret = PackProcessBuffer(pThread, &total);
					if (ret > 1)
						buf[0] = 0;
					if (ret > 0)
						break;
					len = pThread->public->reply.messageSize + pThread->public->reply.headerSize;
					if ( total == len )
					{
						PackParseXML( pThread->public, len );	/* if the message is complete: parse it			*/
						pThread->public->status = PACK_STATUS_OK;
						break;
					}
#ifndef NDEBUG
					else
					{
						ERRxwarning( pThread->public->status, total, "Total buffer incomplete" );
						ERRxwarning( pThread->public->status, pThread->public->reply.headerSize, "Header part" );
						ERRxwarning( pThread->public->status, pThread->public->reply.messageSize, "Message part" );
					}
#endif
					while ( total > len )
					{
						PackParseXML( pThread->public, len );	/* if the message is multiple: parse begining	*/
						
						total -= len;
						memmove( pThread->public->buffer, pThread->public->buffer + len, total );	/* shift */
						buf = pThread->public->buffer + total;
						ret = PackProcessBuffer(pThread, &total);
						if (ret > 1)
							buf[0] = 0;
						if (ret > 0)
						{
							total = len = 0;
							break;
						}
						len = pThread->public->reply.messageSize + pThread->public->reply.headerSize;
						if ( total == len )
						{
							PackParseXML( pThread->public, len );	/* if the message is complete: parse it	*/
							pThread->public->status = PACK_STATUS_OK;
							break;
						}
#ifndef NDEBUG
						else
						{
							ERRxwarning( pThread->public->status, total, "+Total buffer incomplete" );
							ERRxwarning( pThread->public->status, pThread->public->reply.headerSize, "+Header part" );
							ERRxwarning( pThread->public->status, pThread->public->reply.messageSize, "+Message part" );
						}
#endif
					}
					if ( total == len )
						break;
					for (count = pThread->public->timeOut >> 1, len = PACK_MAXBUF-1-total; count > 0 && 0 == PackReceiveTCP(pThread, buf, &len); count--)
						{
						if (0 == len)
						{
							len = PACK_MAXBUF-1-total;
							RtkSleepTaskUsec( 2000 );
							continue;
						}
#ifndef NDEBUG
						ERRxwarning( pThread->public->status, len, "Receive buffer part" );
						ERRxwarning( pThread->public->status, total, "Total buffer" );
						ERRxwarning( pThread->public->status, pThread->public->reply.headerSize, "Header part" );
						ERRxwarning( pThread->public->status, pThread->public->reply.messageSize, "Message part" );
#endif
						buf += len;
						total += len;
						if (total >= PACK_MAXBUF-1)
						{
							ERRxwarning( pThread->public->status, total, "Receive buffer too small" );
							PackError( pThread, 0, "receive buffer too small", PACK_STATUS_FAIL );
							PackCloseTCP( pThread );
							break;
						}
						buf[0] = 0;
						if ( total == pThread->public->reply.messageSize + pThread->public->reply.headerSize )
						{
							PackParseXML( pThread->public, total );	/* if the message is complete: reception is finished*/
							pThread->public->status = PACK_STATUS_OK;
							break;
						}
						len = PACK_MAXBUF-1-total;
						RtkSleepTaskUsec( 2000 );
					}
					if (count <= 0)
					{
						PackError( pThread, 0, "receive time-out", PACK_STATUS_WAIT );
#ifndef NDEBUG
						ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
#endif
						PackCloseTCP( pThread );
					}
	
					break;
				}
				buf += len;
				total += len;
				if (total >= PACK_MAXBUF-1)
				{
					ERRxwarning( pThread->public->status, total, "Receive buffer too small" );
					PackError( pThread, 0, "receive buffer too small", PACK_STATUS_FAIL );
					PackCloseTCP( pThread );
					break;
				}
				len = PACK_MAXBUF-1-total;
				RtkSleepTaskUsec( 2000 );
			}
			break;
		default:
			PackError( pThread, 0, "Invalid state", PACK_STATUS_FAIL );
	}
}

/*- RPC Subfunc. ------------------------------------------------------------*/
int PackProcessBuffer(PackThreadPtr_Type pThread, unsigned long * size)
{
	*size = PackFilterHttp( pThread->public, *size );			/* if we get a reply: filter the header			*/
	if (0 == *size)												/* nothing was sent								*/
	{
		pThread->public->status = PACK_STATUS_OK;
		return 2;
	}

	PackParseHttp( pThread->public, *size );					/* if we get a reply: parse the header			*/
	if ( 0 == pThread->public->reply.headerSize )
	{
		PackError( pThread, 9999, "Invalid message header", PACK_STATUS_OK );
#ifndef NDEBUG
		ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
#endif
		return 1;
	}
	if ( 200 != pThread->public->reply.httpStatus )
	{
		PackError( pThread, pThread->public->reply.httpStatus, pThread->public->reply.httpText, PACK_STATUS_OK );
#ifndef NDEBUG
		ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
#endif
		return 1;
	}
	if ( 0 == pThread->public->reply.messageSize )
	{
		PackError( pThread, 9998, "Invalid message size", PACK_STATUS_OK );
#ifndef NDEBUG
		ERRxwarning( pThread->index, pThread->state, pThread->public->errorText );
#endif
		return 1;
	}
	return 0;
}

void PackEncodeHTTP(PackModulePtr_Type client, long size)
{
	metsprintf( client->buffer, XML_CLIENT_CALL_HTTP, (int)size );
	client->buffer[1+sizeof(XML_CLIENT_CALL_HTTP)] = '<';
	//client->buffer[85] = '<';
}

long PackEncodeXML(PackModulePtr_Type client, char * MNum, long MId, char * v, long FolderStatus, long msgID, long stackID, UINT count, StackItemData_Type * item)
{
	const char XML_START[] = "<?xml version=\"1.0\" ?><methodCall><methodName>XMLRPCComServer</methodName><params>"
		"<param><value><struct>"
		"<member><name>MachineIndex</name><value><int>%d</int></value></member>"
		"<member><name>CO_Status</name><value><int>%d</int></value></member>"
		"<member><name>Sequence_n</name><value><int>%d</int></value></member>"
		"<member><name>MachineID</name><value><string>%s</string></value></member>"
		"<member><name>Version</name><value><string>%s</string></value></member>";
	const char XML_MEMBER_INT[] = "<member><name>%s</name><value><int>%d</int></value></member>";
	const char XML_MEMBER_STRING[] = "<member><name>%s</name><value><string>%s</string></value></member>";
	const char XML_MEMBER_STACK_START[] = "<member><name>StackItem[%d]</name><value><struct>";
	const char XML_MEMBER_STACK_STOP[] = "</struct></value></member>";
	const char XML_STOP[] = "</struct></value></param></params></methodCall>";
	char * start = client->buffer+1+sizeof(XML_CLIENT_CALL_HTTP);
	char * cursor = start;
	unsigned long i;

	cursor += metsprintf( cursor, XML_START, (int)MId, (int)FolderStatus, (int)msgID, MNum, v );
	if (count > 0 && FolderStatus >= 30 && FolderStatus < 40)
	{
		cursor += metsprintf( cursor, XML_MEMBER_INT, "StackID", (int)stackID );
		cursor += metsprintf( cursor, XML_MEMBER_INT, "StackSize", count );
		for (i=1; i<=count; i++)
			{
			cursor += metsprintf( cursor, XML_MEMBER_STACK_START, (int)i-1 );
			cursor += metsprintf( cursor, XML_MEMBER_INT, "ClientNumber", (int)item[i].CustomerId );
			cursor += metsprintf( cursor, XML_MEMBER_INT, "ArticleNumber", (int)item[i].ArticleId );
			cursor += metsprintf( cursor, XML_MEMBER_STRING, "HangerID", item[i].HangerId );
			cursor += metsprintf( cursor, XML_MEMBER_STRING, "GarmentID", item[i].GarmentId );
			cursor += metsprintf( cursor, XML_MEMBER_INT, "FoldProgramNumber", item[i].FoldProgram );
			strcpy( cursor, XML_MEMBER_STACK_STOP );
			cursor += sizeof(XML_MEMBER_STACK_STOP)-1;
		}
	}
	strcpy( cursor, XML_STOP );
	cursor += sizeof(XML_STOP)-1;
	return cursor-start;
}

unsigned long PackFilterHttp(PackModulePtr_Type client, unsigned long len)
{
	unsigned long i, t;
	char * c;
	
	client->reply.headerSize = 0;
	client->reply.httpStatus = 0;
	client->reply.httpText[0] = 0;
	client->reply.messageSize = 0;
	if (len > 50 || 0 == len) return len;
	for (i=0, t=0, c = client->buffer; i<len; i++, c++)
		if (' ' == *c) t++;											/* Search for space ' '						*/
	if ( t == len ) return 0;
	return len;
}

void PackParseHttp(PackModulePtr_Type client, unsigned long len)
{
	unsigned long s;
	char * cursor;
	char * mark;
	char * start = client->buffer;
	char * end = client->buffer + len;
	
	for (cursor = start; cursor < end; cursor++)					/* look for the HTTP line					*/
		{
		if (*cursor != 'H') continue;
		if (memcmp(cursor,"HTTP",4) == 0) break;
	}
	if (cursor >= end) return;										/* no HTTP header found						*/
	for (cursor += 4; cursor < end && *cursor != ' '; cursor++);	/* look for the next blank					*/
		if (cursor >= end) return;										/* no more relevant data found				*/
	for (cursor += 1; cursor < end && *cursor == ' '; cursor++);	/* look for the next word					*/
		if (cursor >= end) return;										/* no more relevant data found				*/
	client->reply.httpStatus = simple_strtoul( cursor, &mark, 10 );	/* parse the HTTP status code				*/
	for (cursor = mark; cursor < end && *cursor == ' '; cursor++);	/* look for the next word					*/
		mark = cursor;
	for (; cursor < end && *cursor >= ' '; cursor++);				/* look for the end of line					*/
		if ((s=cursor-mark) > (PACK_MAXERROR-1)) s = PACK_MAXERROR-1;	/* copy the HTTP status string				*/
	memcpy( client->reply.httpText, mark, s );
	client->reply.httpText[s] = 0;

	if (cursor >= end) return;										/* no more relevant data found				*/
	for (; cursor < end; cursor++)									/* look for the message size				*/
		{
		if (*cursor != 'C') continue;
		if (memcmp(cursor,"Content-Length:",15) == 0) break;
	}
	if (cursor >= end) return;										/* no message size found					*/
	for (cursor += 15; cursor < end && *cursor == ' '; cursor++);	/* look for the next word					*/
		if (cursor >= end) return;										/* no more relevant data found				*/
	client->reply.messageSize = simple_strtoul( cursor, &mark, 10 );/* parse the message size					*/

	client->reply.headerSize = len;
	for (cursor=mark; cursor < end && *cursor != '<'; cursor++);	/* look for the message start				*/
		client->reply.headerSize = cursor - start;
}

long PackParseXMLint( char ** c, char * e )
{
	long i;
	char * mark;
	char * cursor;
	
	for (cursor = *c; cursor < e && *cursor != '<'; cursor++);		/* look for starts							*/
		*c = ++cursor;
	if (cursor >= e) return -1;										/* no more relevant data found				*/
	if (memcmp(cursor,"value>",6) != 0) return -1;
	for (cursor += 6; cursor < e && *cursor != '<'; cursor++);		/* look for starts							*/
		*c = ++cursor;
	if (cursor >= e) return -1;										/* no more relevant data found				*/
	if (memcmp(cursor,"int>",4) != 0) return -1;
	cursor += 4;
	i = simple_strtoul( cursor, &mark, 10 );
	*c = mark;
	if (mark >= e) return -1;										/* no more relevant data found				*/
	return i;
}

char * PackParseXMLstring( char ** c, char * e )
{
	char * mark;
	char * cursor;
	
	for (cursor = *c; cursor < e && *cursor != '<'; cursor++);		/* look for starts							*/
		*c = ++cursor;
	if (cursor >= e) return NULL;									/* no more relevant data found				*/
	if (memcmp(cursor,"value>",6) != 0) return NULL;
	for (cursor += 6; cursor < e && *cursor != '<'; cursor++);		/* look for starts							*/
		*c = ++cursor;
	if (cursor >= e) return NULL;									/* no more relevant data found				*/
	if (memcmp(cursor,"string>",7) != 0) return NULL;
	cursor += 7;
	*c = cursor;
	if (cursor >= e) return NULL;									/* no more relevant data found				*/
	mark = cursor;
	for (; cursor < e && *cursor != '<'; cursor++);					/* look for end								*/
		*c = cursor;
	if (cursor >= e) return NULL;									/* no more relevant data found				*/
	return mark;
}

void PackParseXML(PackModulePtr_Type client, unsigned long len)
{
	unsigned long s;
	char * cursor;
	char * mark;
	char * start = client->buffer + client->reply.headerSize;
	char * end = client->buffer + len;

	client->reply.messageID = -1;
	client->reply.errorNumber = -1;
	client->reply.errorText[0] = 0;
	client->reply.errorFlag = FALSE;
	client->reply.serverStatus = -1;
	cursor = start;
	while (cursor < end)											/* look for names							*/
	{
		for (; cursor < end && *cursor == '>'; cursor++);			/* look for starts							*/
			if (cursor >= end) return;									/* no more relevant data found				*/
		switch (*cursor)
		{
			case 'S':
				if (memcmp(cursor,"Sequence_n</name>",17) == 0)
				{
					cursor += 17;
					if (cursor >= end) return;
					client->reply.messageID = PackParseXMLint(&cursor,end);
				}
				else
					cursor++;
				break;
			case 'C':
				if (memcmp(cursor,"CO_Status</name>",16) == 0)
				{
					cursor += 16;
					if (cursor >= end) return;
					client->reply.serverStatus = PackParseXMLint(&cursor,end);
				}
				else
					cursor++;
				break;
			case 'E':
				if (memcmp(cursor,"ErrorNumber</name>",18) == 0)
				{
					client->reply.errorFlag = TRUE;
					cursor += 18;
					if (cursor >= end) return;
					client->reply.errorNumber = PackParseXMLint(&cursor,end);
				}
				else if (memcmp(cursor,"ErrorDiscription</name>",23) == 0)
				{
					client->reply.errorFlag = TRUE;
					cursor += 23;
					if (cursor >= end) return;
					mark = PackParseXMLstring(&cursor,end);
					if ( NULL == mark )
						s = 0;
					else
					{
						if ((s=cursor-mark) > (PACK_MAXERROR-1)) s = PACK_MAXERROR-1;
						memcpy( client->reply.errorText, mark, s );
					}
					client->reply.errorText[s] = 0;
				}
				else
					cursor++;
				break;
			case 'f':
				if (memcmp(cursor,"faultCode</name>",16) == 0)
				{
					client->reply.errorFlag = TRUE;
					cursor += 16;
					if (cursor >= end) return;
					client->reply.errorNumber = PackParseXMLint(&cursor,end);
				}
				else if (memcmp(cursor,"faultString</name>",18) == 0)
				{
					client->reply.errorFlag = TRUE;
					cursor += 18;
					if (cursor >= end) return;
					mark = PackParseXMLstring(&cursor,end);
					if ( NULL == mark )
						s = 0;
					else
					{
						if ((s=cursor-mark) > (PACK_MAXERROR-1)) s = PACK_MAXERROR-1;
						memcpy( client->reply.errorText, mark, s );
					}
					client->reply.errorText[s] = 0;
				}
				else
					cursor++;
				break;
			default:
				cursor++;
		}
	}
}

/*- TCP Subfunc. ------------------------------------------------------------*/

void PackOpenTCP(PackThreadPtr_Type pThread)					/* to open a TCP connection to a server			*/
{
	signed long status;
	unsigned long arg;
	int arg2;
	struct linger lingerArg;
	ETH_fd_set_typ myset;
	ETH_timeval_typ tv;

	pThread->socket = ERR_SOCKET;
	
	if ( pThread->public->IPstr[0] == '0' )
	{
		pThread->state = 0;
		PackError( pThread, pThread->state, "Disabled", PACK_STATUS_OFF );
		return;
	}
	
	pThread->public->connectCount++;
	memset( &(pThread->eth_serv_adr), 0, sizeof(ETH_sockaddr_typ) );
	pThread->eth_serv_adr.sin_family = ETH_AF_INET;
	pThread->eth_serv_adr.sin_addr = inet_addr((unsigned long)pThread->public->IPstr);
	pThread->eth_serv_adr.sin_port = H_TO_NUINT(PACK_PORT);

	if ( pThread->eth_serv_adr.sin_addr == ERR_SOCKET )
	{
		pThread->state = EthGetError();
		PackError( pThread, pThread->state, "Invalid address", PACK_STATUS_OFF );
		return;
	}
	
	pThread->socket = socket( ETH_AF_INET, ETH_SOCK_STREAM, 0 );
	if ( ERR_SOCKET == pThread->socket )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Error opening %s", pThread->public->IPstr );
		PackError( pThread, pThread->state, "Socket error", PACK_STATUS_FAIL );
		return;
	}
	
	arg = 1; /* non blocking calls */
	status = ioctl( pThread->socket, ETH_FIONBIO, (unsigned long)&arg);
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Error ETH_FIONBIO %s", pThread->public->IPstr );
		PackError( pThread, pThread->state, "ioctl error", PACK_STATUS_FAIL );
		PackCloseTCP(pThread);
		return;
	}
	
	arg2 = 1; /* activate keep alive */
	status = setsockopt( pThread->socket, ETH_SOL_SOCKET, ETH_SO_KEEPALIVE, (unsigned long)&arg2, sizeof(arg2) );
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Error ETH_SO_KEEPALIVE %s", pThread->public->IPstr );
		PackError( pThread, pThread->state, "setsockopt error", PACK_STATUS_FAIL );
	}

	lingerArg.l_onoff = 1;
	lingerArg.l_linger = 0;
	status = setsockopt( pThread->socket, ETH_SOL_SOCKET, ETH_SO_LINGER, (unsigned long)&lingerArg, sizeof(lingerArg));
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Error ETH_SO_LINGER %s", pThread->public->IPstr );
		PackError( pThread, pThread->state, "setsockopt error", PACK_STATUS_FAIL );
	}

	status = connect( pThread->socket, (unsigned long)&(pThread->eth_serv_adr), sizeof(pThread->eth_serv_adr));
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		if ( pThread->state == ERR_ETH_HOSTDOWN )
		{
			PackError( pThread, pThread->state, "host is down", PACK_STATUS_WAIT );
			PackCloseTCP(pThread);
			return;
		}
		if ( pThread->state != ERR_ETH_INPROGRESS )
		{
			logprintf( 0, pThread->state, "Connect error %s", pThread->public->IPstr );
			PackError( pThread, pThread->state, "connect error", PACK_STATUS_FAIL );
			PackCloseTCP(pThread);
			return;
		}
		tv.tv_sec = pThread->public->timeOut/1000; 
		tv.tv_usec = 0; 
		fd_zero((unsigned long)&myset); 
		fd_set(pThread->socket, (unsigned long)&myset);
		status = sock_select(pThread->socket+1, 0, (unsigned long)&myset, 0, (unsigned long)&tv);
		if ( ERR_SOCKET == status )
		{
			pThread->state = EthGetError();
			logprintf( 0, pThread->state, "Select error %s", pThread->public->IPstr );
			PackError( pThread, pThread->state, "select error", PACK_STATUS_FAIL );
			PackCloseTCP(pThread);
			return;
		}
		if ( 0 == status )
		{
			pThread->state = 1;
			PackError( pThread, pThread->state, "connect timeout", PACK_STATUS_WAIT );
			PackCloseTCP(pThread);
			return;
		}
		arg = sizeof(int); 
		status = getsockopt(pThread->socket, ETH_SOL_SOCKET, ETH_SO_ERROR, (unsigned long)&arg2, (unsigned long)&arg); 
		if ( ERR_SOCKET == status )
		{
			pThread->state = EthGetError();
			logprintf( 0, pThread->state, "Connect error %s", pThread->public->IPstr );
			PackError( pThread, pThread->state, "getsockopt error", PACK_STATUS_FAIL );
			PackCloseTCP(pThread);
			return;
		}
		if (61 == arg2)
		{
			pThread->state = arg2;
			PackError( pThread, pThread->state, "connect refused", PACK_STATUS_WAIT );
			PackCloseTCP(pThread);
			return;
		}
		if (arg2)
		{
			pThread->state = arg2;
			PackError( pThread, pThread->state, "connect error", PACK_STATUS_WAIT );
			PackCloseTCP(pThread);
			return;
		}
	}

	pThread->public->connectedCount++;
	pThread->state = 0;
	PackError( pThread, 0, "Connected", PACK_STATUS_OK );
}

int PackCheckTCP(PackThreadPtr_Type pThread)					/* to check a TCP connection status				*/
{
	signed long status;
	unsigned long arg;
	int arg2;

	arg = sizeof(int); 
	status = getsockopt(pThread->socket, ETH_SOL_SOCKET, ETH_SO_ERROR, (unsigned long)&arg2, (unsigned long)&arg); 
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Getsockopt error %s", pThread->public->IPstr );
		PackError( pThread, pThread->state, "getsockopt error", PACK_STATUS_FAIL );
		PackCloseTCP(pThread);
		return -1;
	}
	return arg2;
}

void PackCloseTCP(PackThreadPtr_Type pThread)					/* to close a TCP connection to a server		*/
{
	signed long status;

	status = shutdown(pThread->socket,2);
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Shutdown error %s", pThread->public->IPstr );
	}

	status = close(pThread->socket);
	if ( ERR_SOCKET == status )
	{
		pThread->state = EthGetError();
		logprintf( 0, pThread->state, "Error closing %s", pThread->public->IPstr );
	}
	pThread->socket = ERR_SOCKET;
}

UINT PackSendTCP(PackThreadPtr_Type pThread, void * buf, unsigned long * len)	/* to send a message			*/
{
	UINT status1;
	signed long status2;

	status2 = send( pThread->socket, (unsigned long)buf, (signed long)(*len), 0 );
	if ( ERR_SOCKET == status2 )
	{
		status1 = EthGetError();
		switch (status1)
		{
			case 27170: /*ERR_ETH_WOULDBLOCK*/
				status2 = 0;
				status1 = 0;
				break;
			case 27167: /*ERR_ETH_HOSTDOWN*/
				status2 = 0;
				logprintf( pThread->public->status, status1, "Server %s is down", pThread->public->IPstr );
				PackError( pThread, status1, "Server is down", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
				break;
			case 27154: /*ERR_ETH_CONNRESET*/
				status2 = 0;
				logprintf( pThread->public->status, status1, "Server %s disconnected", pThread->public->IPstr );
				PackError( pThread, status1, "Server disconnected", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
				break;
			default:
				status2 = 0;
				logprintf( pThread->public->status, status1, "Error sending to %s", pThread->public->IPstr );
				PackError( pThread, status1, "Failed to send", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
		}
	}
	else
	{
		status1 = 0;
		pThread->public->sendCount++;
	}
	pThread->state = status1;
	*len = status2;
	return status1;
}

UINT PackReceiveTCP(PackThreadPtr_Type pThread, void * buf, unsigned long * len)			/* to get a reply								*/
{
	UINT status1;
	signed long status2;
	
	status2 = recv( pThread->socket, (unsigned long)buf, (signed long)(*len), 0 );
	if ( ERR_SOCKET == status2 )
	{
		status1 = EthGetError();
		switch (status1)
		{
			case 27170: /*ERR_ETH_WOULDBLOCK*/
				status2 = 0;
				status1 = 0;
				break;
			case 27167: /*ERR_ETH_HOSTDOWN*/
				status2 = 0;
				logprintf( pThread->public->status, status1, "Server %s is down", pThread->public->IPstr );
				PackError( pThread, status1, "Server is down", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
				break;
			case 27154: /*ERR_ETH_CONNRESET*/
				status2 = 0;
				logprintf( pThread->public->status, status1, "Server %s disconnected", pThread->public->IPstr );
				PackError( pThread, status1, "Server disconnected", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
				break;
			default:
				status2 = 0;
				logprintf( pThread->public->status, status1, "Error recieving from %s", pThread->public->IPstr );
				PackError( pThread, status1, "Failed to recieve", PACK_STATUS_WAIT );
				PackCloseTCP( pThread );
		}
	}
	else
	{
		status1 = 0;
		if (status2) pThread->public->recieveCount++;
	}
	pThread->state = status1;
	*len = status2;
	return status1;
}

void PackError(PackThreadPtr_Type pThread, DINT errnbr, char * errtxt, DINT status)	/* to set a public error state		*/
{
	UINT s;
	
	pThread->public->errorCount++;
	pThread->public->errorNumber = errnbr;
	if (errtxt!=NULL)
	{
		s = strlen(errtxt);
		if (s >= PACK_MAXERROR)
		{
			s = PACK_MAXERROR-1;
			memcpy( pThread->public->errorText, errtxt, s );
			pThread->public->errorText[PACK_MAXERROR-1] = 0;
		}
		else
			strcpy( pThread->public->errorText, errtxt );
	}
	if (status>=0) pThread->public->status = status;
}
