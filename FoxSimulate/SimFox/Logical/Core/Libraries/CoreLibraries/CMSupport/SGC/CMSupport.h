/* Automation Studio generated header file */
/* Do not edit ! */
/* CMSupport  */

#ifndef _CMSUPPORT_
#define _CMSUPPORT_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef enum modeCom_Enum
{	OFF = 0,
	ON = 1,
	SELECTABLE = 2
} modeCom_Enum;

typedef enum ComCMCT_Enum
{	NO_ROLE_TYPE = 0,
	SERVER = 1,
	CLIENT = 2
} ComCMCT_Enum;

typedef enum XMLComServiceType_Enum
{	NO_PROTOCOL_TYPE = 0,
	M2M = 1,
	FUTURAIL = 2,
	JENWAYV1 = 3,
	INTERCOM = 4,
	REMOTECOM = 5,
	COCKPIT = 6,
	ARCNET = 7,
	CUSTOM = 8
} XMLComServiceType_Enum;

typedef enum runtimeState_enum
{	RS_IDLE = 0,
	RS_LOAD = 1,
	RS_SAVE = 2,
	RS_EDIT = 3,
	RS_ERROR = 4,
	RS_STATUS = 5
} runtimeState_enum;

typedef enum ComSettings_Enum
{	BASE64ENABLED = 0,
	ENABLE = 1,
	CONNECTIONID = 2,
	ADDRESS = 3,
	OPTIONS = 4,
	REFRESHTIME = 5,
	PORT = 6
} ComSettings_Enum;

typedef enum ComHierarchy_Enum
{	GLOBAL = 0,
	BEHIND = 1,
	AFTER = 2
} ComHierarchy_Enum;

typedef enum ComCMLT_Enum
{	NO_TRANSPORT_TYPE = 0,
	FLATXML = 1,
	JENTRANS = 2,
	JENTRANS_LOOPBACK = 3,
	SERIAL = 4,
	BCD = 5,
	FOLDXML = 6,
	TCPIP = 7,
	UDP = 8,
	SQL = 9
} ComCMLT_Enum;

typedef enum initState_enum
{	INIT = 0,
	RUNTIME = 1,
	ERROR = 2,
	NA = 3,
	LOAD = 4,
	SAVE = 5,
	CHECK = 6,
	EDIT = 7,
	SETUP = 8
} initState_enum;

typedef enum COMCLCMDType_Enum
{	CMD_NONE = 0,
	CMD_SAVE = 1,
	CMD_SAVE_AND_REBOOT = 2,
	CMD_LOAD = 3,
	CMD_REFRESH = 4
} COMCLCMDType_Enum;

typedef struct SystemFile_Connection_Type
{	plcbit isBASE64Enabled;
	plcbit isEnabled;
	unsigned long connectionID;
	plcstring address[81];
	plcstring options[21];
	unsigned long refreshTime;
	unsigned short port;
} SystemFile_Connection_Type;

typedef struct XMLComServiceInterfaceCon_Type
{	unsigned char serverIPSegments[4];
	enum initState_enum initState;
	unsigned short changeID;
	plcbit isConnected;
	unsigned char enableStateTextID;
	struct SystemFile_Connection_Type metaData;
	enum initState_enum logicState;
	unsigned long pServerHandler;
	unsigned long pClientHandler;
	unsigned long pServerLogic;
	unsigned long pClientLogic;
} XMLComServiceInterfaceCon_Type;

typedef struct ComCMIFConStatus_Type
{	unsigned long txErrors;
	unsigned long rxErrors;
	unsigned long serverState;
	unsigned long clientState;
	unsigned long rxCounts;
	unsigned long txCounts;
	unsigned long RefreshTime;
	unsigned long adrStatusString;
} ComCMIFConStatus_Type;

typedef struct ComCMIFCon_Type
{	plcbit isEnabled;
	unsigned short descriptionID;
	enum ComCMLT_Enum transportType;
	enum XMLComServiceType_Enum logicType;
	unsigned short sysID;
	enum ComCMCT_Enum roleType;
	enum modeCom_Enum modeAddress;
	enum modeCom_Enum modeID;
	enum modeCom_Enum modeBASE64;
	struct ComCMIFConStatus_Type status;
	unsigned long maxConnectionID;
	enum modeCom_Enum modeOptions;
	enum modeCom_Enum modeRefreshTime;
	unsigned long pServerLogic;
	unsigned long pClientLogic;
	unsigned long pServerHandler;
	unsigned long pClientHandler;
	enum ComHierarchy_Enum hierarchy;
	enum modeCom_Enum modePort;
	unsigned long connectionID;
	unsigned long adrOptions;
	unsigned long adrAddress;
} ComCMIFCon_Type;

typedef struct XMLRPCCLRuntime_Type
{	enum initState_enum initState;
	struct XMLComServiceInterfaceCon_Type connection[100];
	unsigned char serversRunning;
	unsigned char maxConnections;
	enum initState_enum loadState;
	enum initState_enum saveState;
	unsigned char availableConnections;
	unsigned char addedConnections;
	enum runtimeState_enum state;
	unsigned long semaIdent;
	plcstring semaName[5];
} XMLRPCCLRuntime_Type;

typedef struct XMLRPCCLInterface_Type
{	enum COMCLCMDType_Enum cmd;
	unsigned char serverIPSegmentMin[4];
	unsigned char serverIPSegmentMax[4];
	struct ComCMIFCon_Type connection[100];
} XMLRPCCLInterface_Type;

typedef struct XMLRPCCL_Type
{	struct XMLRPCCLInterface_Type Interface;
	struct XMLRPCCLRuntime_Type Runtime;
} XMLRPCCL_Type;

typedef struct setConnectionSettings
{
	/* VAR_INPUT (analog) */
	unsigned char sysID;
	enum ComSettings_Enum settingsType;
	unsigned long adrSetting;
	/* VAR_OUTPUT (analog) */
	unsigned long status;
	/* VAR (analog) */
	unsigned long identCM;
	/* VAR (digital) */
	plcbit initDone;
} setConnectionSettings_typ;

typedef struct addConnection
{
	/* VAR_INPUT (analog) */
	unsigned char sysID;
	unsigned short descriptionID;
	enum modeCom_Enum modeOptions;
	enum modeCom_Enum modeAddress;
	enum modeCom_Enum modeID;
	enum ComCMLT_Enum transportType;
	enum ComCMCT_Enum roleType;
	enum XMLComServiceType_Enum logicType;
	enum modeCom_Enum modeBASE64;
	enum modeCom_Enum modeRefreshTime;
	enum modeCom_Enum modePort;
	unsigned short port;
	unsigned long maxConnectionID;
	unsigned long adrOptions;
	unsigned long adrAddress;
	unsigned long connectionID;
	enum ComHierarchy_Enum hierarchy;
	/* VAR_OUTPUT (analog) */
	unsigned short status;
	unsigned char ident;
	unsigned long debug;
	/* VAR (analog) */
	unsigned long identCM;
	/* VAR_INPUT (digital) */
	plcbit isEnabled;
	/* VAR (digital) */
	plcbit initDone;
} addConnection_typ;

typedef struct getConnectionInfo
{
	/* VAR_INPUT (analog) */
	unsigned short sysID;
	/* VAR_OUTPUT (analog) */
	unsigned char status;
	unsigned char CMconnectionID;
	/* VAR (analog) */
	unsigned long identCM;
	/* VAR (digital) */
	plcbit initDone;
} getConnectionInfo_typ;

typedef struct getConnectionIdent
{
	/* VAR_INPUT (analog) */
	unsigned short sysID;
	enum ComCMCT_Enum roleType;
	/* VAR_OUTPUT (analog) */
	unsigned char connectionType;
	unsigned long connectionIdent;
	unsigned char status;
	/* VAR (analog) */
	unsigned long identCM;
	/* VAR (digital) */
	plcbit initDone;
} getConnectionIdent_typ;

typedef struct getLogicIdent
{
	/* VAR_INPUT (analog) */
	unsigned short sysID;
	enum ComCMCT_Enum roleType;
	/* VAR_OUTPUT (analog) */
	enum XMLComServiceType_Enum logicType;
	unsigned long logicIdent;
	unsigned char status;
	/* VAR (analog) */
	unsigned long identCM;
	/* VAR (digital) */
	plcbit initDone;
} getLogicIdent_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void setConnectionSettings(struct setConnectionSettings* inst);
_BUR_PUBLIC void addConnection(struct addConnection* inst);
_BUR_PUBLIC void getConnectionInfo(struct getConnectionInfo* inst);
_BUR_PUBLIC void getConnectionIdent(struct getConnectionIdent* inst);
_BUR_PUBLIC void getLogicIdent(struct getLogicIdent* inst);


#ifdef __cplusplus
};
#endif
#endif /* _CMSUPPORT_ */

