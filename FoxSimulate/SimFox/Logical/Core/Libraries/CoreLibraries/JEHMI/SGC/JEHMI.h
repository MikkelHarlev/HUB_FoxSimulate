/* Automation Studio generated header file */
/* Do not edit ! */
/* JEHMI  */

#ifndef _JEHMI_
#define _JEHMI_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG4
		#include "SYS_LIB.h"
		#include "DataObj.h"
		#include "brsystem.h"
		#include "AsMem.h"
		#include "Visapi.h"
#endif


/* Datatypes and datatypes of function blocks */
typedef struct HMIRuntime_Type
{	unsigned short autoReload;
} HMIRuntime_Type;

typedef struct HMIInit_Type
{	unsigned long VisObject;
	plcbit LoadPatch;
	unsigned long PatchDataObject;
	unsigned long DataObject;
	unsigned short LockTimeOut;
	unsigned short CalibrateTime;
	unsigned short ExitTime;
	unsigned short SystemPageID;
	unsigned short CalibratePageID;
	unsigned short InvalidPanelPageID;
	unsigned short WrongPasswordPageID;
	unsigned long pTaskInterface;
	unsigned long pPasswordArr;
	unsigned short NotificatorTimer;
	plcbit Enabled;
	unsigned char AnimationSpeed;
	unsigned long hwID;
} HMIInit_Type;

typedef struct HMIPageHandler_Type
{	unsigned short Request;
	unsigned short Active;
} HMIPageHandler_Type;

typedef struct HMIPageControllerKey_Type
{	unsigned short PageControllerLink;
	unsigned short TextID;
	unsigned short IconID;
	unsigned short Enabled;
	unsigned short Locked;
} HMIPageControllerKey_Type;

typedef struct HMIInput_Type
{	unsigned char KeyPressed;
	struct HMIPageControllerKey_Type Key[16];
} HMIInput_Type;

typedef struct HMIPasswordHandler_Type
{	unsigned char Level;
	unsigned short HideLogin;
	unsigned short HideInvalidPassword;
	unsigned char Entered;
	plcstring Password[5];
} HMIPasswordHandler_Type;

typedef struct hmiTouch_type
{	unsigned long status;
	unsigned long x;
	unsigned long y;
} hmiTouch_type;

typedef struct HMITaskInterface_Type
{	unsigned char KeyPressed;
	unsigned short PageControllerID;
	unsigned long pVCHandler;
	unsigned long pPanelHandler;
	plcbit Icons;
	plcbit SystemInitDone;
	unsigned char PasswordLevel;
	plcbit InitPassword;
	plcbit isInitDone;
	plcbit isDisableScreenCalibration;
	struct hmiTouch_type touch;
} HMITaskInterface_Type;

typedef struct HMIPageController_Type
{	unsigned short Page;
	unsigned short ID;
	struct HMIPageControllerKey_Type Button[16];
	unsigned long Next;
	plcbit NoHistory;
} HMIPageController_Type;

typedef struct HMIPageControllerHandler_Type
{	unsigned short RequestedPageController;
	unsigned short ParentPageController[32];
	unsigned long pPageController;
	unsigned char Level;
	unsigned char DisplayType;
	unsigned char ChangeDisplayType;
	plcbit GoBack;
	plcbit NoHistory;
} HMIPageControllerHandler_Type;

typedef struct HMIInternal_Type
{	unsigned short NotifyTimer;
	plcbit ValidDevice;
	struct HMIPageControllerHandler_Type PageControllerHandler;
	plcbit InputLock;
	unsigned char InputState;
	unsigned short InputTimer;
	unsigned char InputKey;
	unsigned short RequestPage;
	unsigned char PasswordLevel;
	unsigned long LockTimeOut;
	unsigned short ActivePageControllerID;
	unsigned short ActivePageControllerPage;
	unsigned char NewPasswordLevel;
	unsigned long PasswordList[3];
	unsigned char LoginTries;
	unsigned long LogTimer;
	plcbit PasswordInit;
	unsigned long TouchTimer;
	unsigned char TouchStatus;
	unsigned short PWRequestedPageHandler[2];
	unsigned short InputKeyLast;
	plcbit CheckLastInput;
	plcdt dataObjectDate1;
	plcdt dataObjectDate2;
	unsigned short calibrationImage;
	float calibrationProgress;
	unsigned short calibrationCounter;
	unsigned short dataObjectCheckCounter;
} HMIInternal_Type;

typedef struct HMINotificator_Type
{	unsigned short Hide;
	unsigned short Item;
} HMINotificator_Type;

typedef struct HMIHandler
{
	/* VAR_INPUT (analog) */
	unsigned long MemPool;
	struct HMIInit_Type Init;
	struct HMIInput_Type Key;
	struct HMIPageHandler_Type Page;
	struct HMIPasswordHandler_Type Password;
	/* VAR_OUTPUT (analog) */
	plcstring StatusString[81];
	unsigned short Status;
	unsigned long Ident;
	/* VAR (analog) */
	struct HMIRuntime_Type Runtime;
	struct HMINotificator_Type Notificator;
	/* VAR_INPUT (digital) */
	plcbit InitDone;
} HMIHandler_typ;

typedef struct Animate
{
	/* VAR_INPUT (analog) */
	unsigned char Type;
	unsigned short FirstImage;
	unsigned short LastImage;
	float Acceleration;
	unsigned short SetTimeout;
	unsigned long pPanelHandler;
	/* VAR (analog) */
	unsigned short NotifyIndex;
	unsigned short Timer;
	unsigned short Timeout;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	/* VAR (digital) */
	plcbit Direction;
	plcbit InitDone;
} Animate_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void HMIHandler(struct HMIHandler* inst);
_BUR_PUBLIC void Animate(struct Animate* inst);
_BUR_PUBLIC plcbit UpdateButton(unsigned long pPanelHandler, unsigned short PageControllerID, unsigned short ButtonNo, unsigned short ButtonID, unsigned short PasswordLevel, unsigned short PageControllerLink);
_BUR_PUBLIC plcbit Notify(unsigned long pPanelHandler, unsigned short BitmapNo, unsigned short Timer);
_BUR_PUBLIC plcbit CallPageControllerLink(unsigned short PageControllerID, unsigned long pPanelHandler);
_BUR_PUBLIC unsigned short LookupPageID(unsigned short PageID, unsigned long pPanelHandler);


#ifdef __cplusplus
};
#endif
#endif /* _JEHMI_ */

