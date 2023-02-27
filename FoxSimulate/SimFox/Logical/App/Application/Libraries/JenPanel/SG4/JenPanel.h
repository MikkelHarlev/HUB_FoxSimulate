/* Automation Studio generated header file */
/* Do not edit ! */
/* JenPanel 2.40.2 */

#ifndef _JENPANEL_
#define _JENPANEL_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _JenPanel_VERSION
#define _JenPanel_VERSION 2.40.2
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "FileIO.h"
		#include "DataObj.h"
		#include "brsystem.h"
		#include "Visapi.h"
#endif


/* Constants */
#ifdef _REPLACE_CONST
 #define JENPANEL_PAGEHANDLER_BUSY 65535U
#else
 _GLOBAL_CONST unsigned short JENPANEL_PAGEHANDLER_BUSY;
#endif




/* Datatypes and datatypes of function blocks */
typedef struct HmiVC_Type
{	unsigned char ContrastNew;
	unsigned char ContrastOld;
	unsigned char BrightnessOld;
	unsigned char BrightnessNew;
	unsigned long Status;
	unsigned long Handle;
} HmiVC_Type;

typedef struct PageUserLabelData_type
{	unsigned short TextIndex;
	unsigned char Activate;
} PageUserLabelData_type;

typedef struct NavigateKeyData_type
{	plcstring FunctionKeyText[12];
	unsigned short PassWordLevel;
	unsigned short PageId;
	unsigned short IconId;
	unsigned short FunctionKeyStatus;
	unsigned short TextSnippetIndex;
	unsigned char TextGroupIndex;
} NavigateKeyData_type;

typedef struct PageHandler_Type
{	unsigned short CurrentKey;
	unsigned short CurrentPage;
	unsigned short NewPage;
	unsigned short PassWordLevel;
	plcstring PictureHeaderName[31];
	struct PageUserLabelData_type PictureHeaderUser;
	struct NavigateKeyData_type FunctionKeyData[12];
	unsigned short KeyPressed;
	unsigned short MenuIndex;
	unsigned short Flag;
	unsigned short LastMessageTimer;
	unsigned short HighestMenuIndex;
	unsigned char Activated;
	unsigned char RunJenPanel;
	unsigned short ExitTimeOut;
	unsigned short TouchKeyDelay;
	unsigned short TouchKeyDelayTimer;
	unsigned short CurrentLanguage;
	unsigned short NumberOfFunctionKeys;
	unsigned short PassWordTimeOut;
	unsigned long PassWordTimeOutTimer;
	unsigned short RootKeyTimeOut;
	unsigned short RootKeyTimeOutTimer;
	unsigned short HeaderTextIndex;
	unsigned char HeaderTextGroupIndex;
	unsigned long VcHandle;
} PageHandler_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed long GetPanelHandle(struct PageHandler_Type* PageHandler, plcstring* PanelName);
_BUR_PUBLIC signed long LogOutMenuHandler(struct PageHandler_Type* PageHandler);
_BUR_PUBLIC signed long GetMenuTexts(struct PageHandler_Type* PageHandler, plcstring* PanelName, unsigned short MenuHeaderTextGroup, unsigned short FunctionKeyTextGroup);
_BUR_PUBLIC signed long RunPageHandler(struct PageHandler_Type* PageHandler);
_BUR_PUBLIC signed long InitPageHandler(struct PageHandler_Type* PageHandler, plcstring* MenuFileName);
_BUR_PUBLIC signed long SetMenuDirect(struct PageHandler_Type* PageHandler, unsigned short MenuId);


#ifdef __cplusplus
};
#endif
#endif /* _JENPANEL_ */

