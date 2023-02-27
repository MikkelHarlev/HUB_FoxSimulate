/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| errdef.h : define error code groups for task/functions														 |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 20000317																							 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef ErrDefHeader
#define ErrDefHeader

/*———[ Constants ]——————————————————————————————————————————————————————————————————————————————————————————————*/

#define MKErrTraceCache			15000							/* error log for the cache module				*/
#define MKErrTraceCacheClient	15100							/* error log for a client to the cache module	*/
#define MKErrTraceScaner		15200							/* error log for the scaner module				*/
#define MKErrTraceScanerClient	15300							/* error log for a client to the scaner module	*/
#define MKErrTraceUDPMirror     15400                           /* error log for the UDP mirror                 */
#define MKErrTraceTCPQL         15500
#define MKErrTraceStatistic     15600
#define MKErrTraceRandom        15900                           /* error log for the random generator           */
#define MKErrTraceCan 			16100
#define MKErrTraceMap1			16200
#define MKErrTraceMap2			16300
#define MKErrTraceCanSend 		16400
#define MKErrTraceMapOut		16500
#define MKErrTraceConveyor		16600
#define MKErrTraceRail			16700
#define MKErrTraceFullogic		16800
#define MKErrTraceLogicMod		16900
#define MKErrTraceIOUtil		17000
#define MKErrTraceCtrlStn		17100
#define MKErrTraceMetFeed		17200
#define MKErrTraceConvScan		17300
#define MKErrTraceTermText		17400
#define MKErrTraceIndex			17500
#define MKErrTraceServ			17600
#define MKErrTraceNodeFunc		17700
#define MKErrTraceFeeder		17800
#define MKErrTraceMotor			17900
#define MKErrTraceDataModule	18000
#define MKErrTraceUnitScan		18100
#define MKErrTraceSort			18200
#define MKErrTraceWriter		18300
#define MKErrTraceIOShovel		19000							/* error log for the RIOX shovling				*/
#define MKErrTraceIOExcept		19100							/* error log for the RIOX exceptions			*/
#define MKErrTraceUDPHWlist		19200							/* error log for the UDP hardware list			*/
#define MKErrTraceUDPHWset		19300							/* error log for the UDP hardware list config	*/
#define MKErrTraceUDPOUTSet		19400							/* error log for the UDP ouputs multi server	*/
#define MKErrTraceUDPINSet		19500							/* error log for the UDP inputs multi server	*/
#define MKErrTraceLogD			19600
#define MKErrTraceHttpD			19700
#define MKErrTraceMetUtils		19800

#define MKAssertTrace			-1								/* = 65535										*/

#endif
