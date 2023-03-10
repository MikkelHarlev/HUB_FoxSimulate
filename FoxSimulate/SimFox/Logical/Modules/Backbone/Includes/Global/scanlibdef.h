/*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*\
| Scannershared.h : definitions shared by the users of Scanners
+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
| Version 1.0 NS19990820
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?+
| Version 1.01 SF 20020419 is now a libaray
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?+
| Version 1.02 SF 20020426 returning error codes, hangerID + macro is now declared in MetUtils (dependency)
| 								counters like checksumerror,senderror and requestsmade etc. is introduced
\*覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

#ifndef ScannerSharedHeader
#define ScannerSharedHeader

/*覧夕 Includes ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?*/

#include <bur/plctypes.h>
#include "comportshared.h"
#include "scanlib.h"

/*覧夕 Constants ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/

#define MKScannerMaxNameSize				3						/* maximum size of strings for Scanner names		*/
#define MKScannerMaxStringSize				15						/* maximum size of strings for connection names	*/
#define MKScannerReaders					20						/* max number of scanners to use */
#define MKScanner_CR						13						/* carriage return code								*/
#define MKScanner_LF						10						/* line feed code										*/
#define MKScanner_ESC						27						/* escape code										*/
#define MKScanner_Single					68						/* single reading code								*/
#define MKScanner_Repeat					66						/* continuous reading code							*/


/*ｷｷｷ[ ComModule states ]ｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷ*/

#define MKWriterMaxNameSize					3						/* maximum size of strings for Writer names		*/
#define MKWriterMaxStringSize				15						/* maximum size of strings for connection names	*/

#define MKWriter_CR							13						/* carriage return code								*/
#define MKWriter_LF							10						/* line feed code										*/
#define MKWriter_ESC						27						/* escape code										*/
#define MKWriter_Single						68						/* single reading code								*/
#define MKWriter_Repeat						66						/* continuous reading code							*/

/*ｷ states & messages						ｷ*/
#define MKWriterStateOK						100						/* client and server happy together				*/
#define MKWriterStateBusy					1						/* Writer polling										*/
#define MKWriterStateResult					5						/* waiting for the client to ack. the result		*/
#define MKWriterStateResult2				6						/* waiting for the client to ack. the result		*/
#define MKWriterStateCnxWait				7						/* connection waiting for the remote host			*/
#define MKWriterStateCnxLocalOK				8						/* almost connected									*/
#define MKWriterStateCnxOK					9						/* connected											*/
#define MKWriterStateCnxTmOut				10						/* fail to connect (no error)						*/
#define MKWriterStateCnxFail				11						/* fail to connect (cold sart, sysconf...)		*/

/*ｷ commands									ｷ*/
#define MKWriterStateStart					501						/* start the Writer (polling on)					*/
#define MKWriterStateStop					502						/* stop the Writer (polling off)					*/
#define MKWriterStateACK					503						/* acknowledge the result							*/
#define MKWriterStateACK2					504						/* acknowledge the result							*/
#define MKWriterStateCancel					505						/* switch back to OK if not failing				*/
#define MKWriterStateWait					506						/* client waiting										*/
#define MKWriterStateSending				507						/* Message send but not ack 						*/
#define MKComportLocal_Idle					1000					/* idle time within a frame							*/


#define MKComModuleWriteStateIdle			100
#define MKComModuleWriteStateMsginBuf		101

#define MKWriterL40LocalEcho				TRUE					/* flag if L40 module is echo back or not	   		*/


/*ｷ critical errors							ｷ*/
#define MKWriterStateFail					1001					/* Writer module failed (give up...)				*/

/*ｷｷｷ[ Dialogue constants ]ｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷｷ*/

/*ｷ states & messages					ｷ*/
#define MKScannerStateOK					100						/* client and server happy together				*/
#define MKScannerStateBusy					1						/* Scanner polling									*/
#define MKScannerStateResult				5						/* waiting for the client to ack. the result		*/
#define MKScannerStateCnxWait				7						/* connection waiting for the remote host			*/
#define MKScannerStateCnxLocalOK			8						/* almost connected									*/
#define MKScannerStateCnxOK					9						/* connected											*/
#define MKScannerStateCnxTmOut				10						/* fail to connect (no error)						*/
#define MKScannerStateCnxFail				11						/* fail to connect (cold sart, sysconf...)		*/

/*ｷ commands									ｷ*/
#define MKScannerStateStart					501						/* start the Scanner (polling on)					*/
#define MKScannerStateStop					502						/* stop the Scanner (polling off)					*/
#define MKScannerStateACK					503						/* acknowledge the result							*/
#define MKScannerStateCancel				504						/* switch back to OK if not failing				*/
#define MKScannerStateWait					505						/* client waiting										*/

#define MKScannerVersion					"V02.00"				/* version definition for init log					*/

#define MKComportLocal_Idle					1000					/* idle time within a frame							*/

#define MKScannerModeInitiated				1						/* Scanner initiated							*/
#define MKScannerModeVerified				2						/* Scanner has answered						*/
#define MKScannerModeNoAnswer				3						/* Scanner dont answer						*/

#define MKScannerFrameOK					0
#define MKScannerFrameHalt					1
#define MKScannerFrameNewID					2
#define MKScannerFrameNewResult				8
#define MKScannerFrameBadID					10
#define MKScannerFrameWait4Answer			11
#define MKScannerFrameFail					1001

#define MKScanRequestLng					5						/* Request string to L40 module is 5 char long 	*/
#define MKScannerL40LocalEcho			TRUE						/* flag if L40 module is echo back or not	   		*/


/*ｷ critical errors					ｷ*/
#define MKScannerStateFail			1001							/* Scanner module failed (give up...)				*/

/*覧夕 Typedefs ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?*/
//typedef 	Scanner_Type * 			ScannerPtr;
typedef	UINT						ScannerSize;		  		/* type of a length									*/
typedef	UINT						ScannerState;				/* client/server relation state indicator			*/


/*覧夕 Methods ]覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧*/



#endif


