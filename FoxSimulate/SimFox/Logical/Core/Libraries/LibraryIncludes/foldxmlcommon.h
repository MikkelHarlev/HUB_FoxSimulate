/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| FoldXMLCommon.h : Declarations common to FoldXML.c
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 SF
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef JenFoldXMLCommonHeader
#define JenFoldXMLCommonHeader

#include "FoldXML.h"			/* internal structures used */

USINT unknown_call( saxMethod_t* pCall );			/* Default function*/
USINT response_cb( saxMethod_t* pCall );				/* Default function*/
int ClearGarmentData(XMLFoldGarmentData_Type* XMLGarmdataPointer);
signed long InitXMLCommInfo( JenXMLCommInfo_Type* XMLCommInfoPointer);


#define ALLOC_SIZE 100*1024
#define XML_VERSION 	 "2.03.4"

#define JE_XML_READREADY 1
#define JE_XML_READ_SUCCESS 64001

#define XMLRPC_MAX_NUMBER_OF_FOLDERS 100

#define MKFoldXMLErrClientInitOK			1
#define MKFoldXMLErrConnectOK				2
#define MKFoldXMLErrServerInitOK			3
#define MKFoldXMLErrFunctionAdded			4
#define MKFoldXMLErrInvalidParser			5
#define MKFoldXMLErrEmptyResponse			6
#define MKFoldXMLErrInvalidreplyString		7
#define MKFoldXMLErrInvalidCachePointer		8
#define MKFoldXMLErrCacheError				9
#define MKFoldXMLErrInvalidPointer			10
#define MKFoldXMLErrInvalidMachineId		11
#define MKFoldXMLErrMachineIdNotFound		12
#define MKFoldXMLErrClose					13
#define MKFoldXMLErrNoClientTimeOut			14
#define MKFoldXMLErrTimeOut					15
#define MKFoldXMLErrWrongXMLText			16
#define MKFoldXMLErrWrongMessageId			17
#define MKFoldXMLErrTagName					18
#define MKFoldXMLErrIllegalHangerRequest	19
#define MKFoldXMLErrInvalidMachineType		20
#endif



