/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| comportshared.h : definitions shared by the users of comports													       |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.1 SF20000929																					                 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef ComportSharedHeader
#define ComportSharedHeader

/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plctypes.h>
#include <metutils.h>			/* general metric library functions       */
#include <cachelib.h>

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

/*···[ Dialogue constants ]·····················································································*/

/* comport reading states */
#define MKScanReadStateIdle				0						/* free to send new messages						*/
#define MKScanReadStateWaitData			1						/* waiting for data to be send from L40 module	*/
#define MKScanReadStateWaitChk			2						/* waiting for checksum from L40 module			*/
#define MKScanReadStateWaitEchoData		3						/* waiting for local echo before true data		*/
#define MKScanReadStateWaitEchoChk		4						/* waiting for local echo before true data		*/

/* comport general states */
#define MKComStateOk					0						/* free to poll scanners again						*/
#define MKComStateWait4Data				1						/* waiting for scanner answer from L40 module	*/
#define MKComTextStateOk				10						/* free to poll commodules  						*/
#define MKComTextStateWait4Data			11						/* waiting for poll data from L40 Text module	*/
#define MKComStateFail					20						/* failed to work										*/

/* comport general error messages */
#define MKTraceErrComportFail			1					/* comport has fail to open 						*/
#define MKTraceErrReadFail				2					/* reading a buffer failed 							*/
#define MKTraceErrWriteBufferToSmall	3					/* the recieived write buffer was to small for the message to be send */
#define MKTraceErrClientMsgToLong		4					/* The message to send dont fit into the sned buffer */
#define MKTraceErrCurrentIdInvalid		5					/* current poll id invalid */
#define MKTraceErrComportIdleRecieved	10					/* free to poll scanners again						*/
#define MKTraceErrComportIllegalChar	11					/* free to poll scanners again						*/
#define MKTraceErrComportCheckSum		12					/* free to poll scanners again						*/
#define MKTraceErrComportPtrIsnull		13					/* the pointer to the comport is null 			*/
#define MKTraceErrBuffLengthToSmall		14					/* the buffer length was to small					*/
#define MKTraceErrNotInitiated			15					/* L40 was never initiated */
#define MKTraceErrNotPolled				16					/* l40 has not been polled */
#define MKTraceErrPointerIsNull			17					/* the passed pointer is null */
#define MKTraceErrComportToManyCommodul 18					/* differens between first id and last id is to big */
#define MKTraceErrComportToManyScanners 19					/* differens between first id and last id is to big */

#define MKTraceErrorInvalidFunctionType 30
#define MKTraceErrorOpenFail			31
#define MKTraceErrReadTagModule			32
#define MKTraceErrorComBusInvalidNodeId	33

#define MKTraceErrorInitComBus			36
#define MKTraceErrorComBusWrongBusType	37
#define MKTraceErrorComBusInitComUnit	39
#define MKTraceErrorAllBuffersFull		40
#define MKTraceErrorFailClearBuffer		41
#define MKTraceErrorNoBufferFound		42
#define MKTraceErrorNodeAlreadyInitiated 43
#define MKTraceErrorAllComUnitsUsed		44

#define MKTraceErrTimeout				50					/* time out on a L40. 								*/

															/* This error is combined with the id of the L40	*/
															/* Like 52 is L40 #2, 53 is L40 #2					*/
#define MKComportMaxCnxSize				13					/* maximum size of strings for connector loc.		*/
#define MKComportMaxComSize				31					/* maximum size of strings for com. param.			*/
#define MKComportLocal_TX_CNT			3					/* number of tx buffer								*/
#define MKComportLocal_TX_LNG			125					/* length of tx buffer								*/
#define MKComportLocal_RX_CNT			3					/* number of rx buffer								*/
#define MKComportLocal_RX_LNG			125					/* length of rx buffer								*/
#define MKComportMaxCycleWait			5					/* Max # of cycles to wait for an answer 			*/
#define MKComportHighestScanId			63					/* higest id of an L40 moduel 						*/
#define MKComportMaxScanners			20					/* Max # of scanners on one comport					*/
#define MKComportMaxComModules			10					/* Max # of writers on one comport					*/
#define MKComportHighestComModuleId		63					/* highest Id for a Com Module						*/
#define MKComModuleMaxIncompleteMsgCntr 5					/* Max # of cycles to wait for incomplete msg   	*/


/*———[ Typedefs ]——————————————————————————————————————————————————————————————————————————————————————*/
typedef	UINT						MTComportReadState;		/* frame read state indicator					*/
typedef	UINT						MTComportState;			/* frame state indicator						*/


enum MTcomportreadflag
{
	COMPORT_NEW_MSG						=  	   	1, /* commodule has recieved a new message					*/
	COMPORT_CLIENT_READ_ATTEMPT			=     	2, /* commodule client tries to read message 				*/
	COMPORT_CLIENT_HAS_READ_MSG			=		4, /* commodule client has read the message					*/
};

enum MTScanState
{
	SCAN_STATE_READ_ACK			=     1, 					/* Application has read value, to be cleared		*/
};

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/
signed short ReadComUnitTagId(ComUnit_Type* scanner, char* readerdata);
signed short SendToComUnit(ComUnit_Type* ComUnit, unsigned long SendMessage, unsigned char Delimiter);
int ComUnitMsg2Send(ComUnit_Type* comunit);
//signed short ReadScanDirect(Scanner_Type* Scanner, char* ReaderData);
signed long ComUnitGetTelegram(ComUnit_Type* comunit,char* ReturnMsg );
signed short ComUnitAddMsg(ComUnit_Type* comunit, unsigned long SendMessage);
short InitScan( ScanPort_Type* scanport);
short RunScan( ScanPort_Type* scanport);



#endif


