(********************************************************************
 * COPYRIGHT -- JENSEN Denmark A/S
 ********************************************************************
 * Library: CMSupport
 * File: CMSupport.fun
 * Author: eg
 * Created: June 13, 2013
 ********************************************************************
 * Functions and function blocks of library CMSupport
 ********************************************************************)

FUNCTION_BLOCK setConnectionSettings
	VAR_INPUT
		sysID : USINT;
		settingsType : ComSettings_Enum;
		adrSetting : UDINT;
	END_VAR
	VAR_OUTPUT
		status : UDINT;
	END_VAR
	VAR
		initDone : BOOL;
		identCM : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK addConnection
	VAR_INPUT
		sysID : USINT;
		descriptionID : UINT;
		isEnabled : BOOL;
		modeOptions : modeCom_Enum;
		modeAddress : modeCom_Enum;
		modeID : modeCom_Enum;
		transportType : ComCMLT_Enum;
		roleType : ComCMCT_Enum;
		logicType : XMLComServiceType_Enum;
		modeBASE64 : modeCom_Enum;
		modeRefreshTime : modeCom_Enum;
		modePort : modeCom_Enum;
		port : UINT;
		maxConnectionID : UDINT;
		adrOptions : UDINT;
		adrAddress : UDINT;
		connectionID : UDINT;
		hierarchy : ComHierarchy_Enum;
	END_VAR
	VAR_OUTPUT
		status : UINT;
		ident : USINT;
		debug : UDINT;
	END_VAR
	VAR
		initDone : BOOL;
		identCM : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK getConnectionInfo
	VAR_INPUT
		sysID : UINT;
	END_VAR
	VAR_OUTPUT
		status : USINT;
	END_VAR
	VAR
		initDone : BOOL;
		identCM : UDINT;
	END_VAR
	VAR_OUTPUT
		CMconnectionID : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK getConnectionIdent
	VAR_INPUT
		sysID : UINT;
		roleType : ComCMCT_Enum;
	END_VAR
	VAR_OUTPUT
		connectionType : USINT;
		connectionIdent : UDINT;
		status : USINT;
	END_VAR
	VAR
		initDone : BOOL;
		identCM : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK getLogicIdent
	VAR_INPUT
		sysID : UINT;
		roleType : ComCMCT_Enum;
	END_VAR
	VAR_OUTPUT
		logicType : XMLComServiceType_Enum;
		logicIdent : UDINT;
		status : USINT;
	END_VAR
	VAR
		initDone : BOOL;
		identCM : UDINT;
	END_VAR
END_FUNCTION_BLOCK
