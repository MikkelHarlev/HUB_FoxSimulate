/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| JenTransCommon.h : Declarations common to JenTrans.c
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 SF
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef JenTransCommonHeader
#define JenTransCommonHeader
#include <httputil.h>
#include "JenTrans.h"			/* internal structures used */

USINT unknown_call( saxMethod_t* pCall );			/* Default function*/
USINT response_cb( saxMethod_t* pCall );				/* Default function*/
signed long ClearObjectData(JenTransCommonInfo_Type* xmlCommInfoPtr);
signed long InitXMLCommInfo( JenTransCommonInfo_Type* XMLCommInfoPointer);
int	AddTagValue(char* totstring,char* fieldname,int* totalstringlength, int value);
int	AddTagString(char* totstring,char* fieldname,int* totalstringlength, char* text);
/*signed long InitAllGeneralPanelServerAndClients();*/
USINT	XMLRPCObjectServer( saxMethod_t* pCall );
USINT methodObjectResponse( saxMethod_t* pCall );	/* Response Function for PV-Read to write the Data */
/*USINT	XMLRPCPanelGeneralServer( saxMethod_t* pCall );
USINT methodPanelGeneralResponse( saxMethod_t* pCall );*/	/* Response Function for PV-Read to write the Data */

typedef struct XMLDataStructFormat_Type
{
	signed short VariableType;
	plcstring Name[20+1];
	signed short StartPosition;
	signed short FieldLength;
} XMLDataStructFormat_Type;


#define MAX_DATA_STRING_LENGTH  1500
#define MAX_SEND_STRING_LENGTH  2000

#define ALLOC_SIZE 100*1024
#define XML_VERSION 	 "2.03.0"

#define JE_XML_READREADY 1
#define JE_XML_READ_SUCCESS 64001

#define XMLRPC_MAX_NUMBER_OF_OBJECTS 100

#define JenTransErrClientInitOK			1
#define JenTransErrConnectOK			2
#define JenTransErrServerInitOK			3
#define JenTransErrFunctionAdded		4
#define JenTransErrInvalidParser		5

#define JenTransErrInvalidPointer		10
#define JenTransErrInvalidObjectId		11
#define JenTransErrObjectIdNotFound		12
#define JenTransErrClose				13
#define JenTransErrNoClientTimeOut		14
#define JenTransErrTimeOut				15
#define JenTransErrWrongXMLText			16
#define JenTransErrWrongMessageId		17
#define JenTransErrTagName				18
#define JenTransErrInvalidDataTypFormat	19
#define JenTransErrInvalidObjectType	20
#define JenTransErrInitServerAndClient	21
#define JenTransErrDataStringTooLong	22
#define JenTransErrSendStringTooLong	23
#define JenTransErrNoIpAddress			25
#define JenTransErrWrbackNotFound		26
#endif



