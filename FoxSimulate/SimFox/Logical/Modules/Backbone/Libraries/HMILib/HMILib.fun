

FUNCTION getTimeString : BOOL (*Gets date/time as string. TRUE on success, FALSE of error. Date/time string as pointer.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		dateAndTimeStr : REFERENCE TO STRING[40];
	END_VAR
	VAR
		dateAndTime : DATE_AND_TIME;
		DTstructure_0 : DTStructure;
		tmpStr : STRING[4];
		DTGetTime_0 : DTGetTime;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION buildItem : BOOL (*Builds items used in ItemCollection like '{"value":"1","text":"AAA"}'*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		value : STRING[10];
		text : STRING[200];
		item : REFERENCE TO STRING[250];
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION getDateString : BOOL (*Gets date as string*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		dateStr : REFERENCE TO STRING[10];
	END_VAR
	VAR
		date : DATE_AND_TIME;
		DTstructure_0 : DTStructure;
		tmpStr : STRING[4];
		DTGetTime_0 : DTGetTime;
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION convertIPString : BOOL (*Splits IP string to four IP octets*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		IPString : STRING[15];
	END_VAR
	VAR_IN_OUT
		StatusMessage : STRING[200];
		Octets : ARRAY[0..3] OF DINT;
	END_VAR
	VAR
		strLength : UINT;
		i : UINT;
		currentCharAscii : USINT;
		currentChar : USINT;
		octetCount : USINT;
		r : USINT;
		octetTemp : ARRAY[0..80] OF USINT;
		OctetIdxStr : STRING[4];
		status : BOOL;
		octetsStr : ARRAY[0..3] OF STRING[80];
	END_VAR
END_FUNCTION

{REDUND_ERROR} FUNCTION convertIPoctets : BOOL (*Merges IP octets to string*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		Octets : ARRAY[0..3] OF DINT;
	END_VAR
	VAR_IN_OUT
		IPString : STRING[15];
		StatusMessage : STRING[200];
	END_VAR
	VAR
		error : BOOL;
		tempString : STRING[15];
	END_VAR
END_FUNCTION

FUNCTION_BLOCK getNamespaceKey
	VAR_INPUT
		adrMessageString : UDINT;
	END_VAR
	VAR_OUTPUT
		strNamespace : STRING[80];
		strKey : STRING[MAX_TRANSLATION_LENGTH];
		isFound : BOOL;
	END_VAR
	VAR
		isStartFound : BOOL;
		isStartBraceFound : BOOL;
		isStartDollarSignFound : BOOL;
		isNameSpaceFound : BOOL;
		isKeyFound : BOOL;
		charNo : UDINT;
		pChar : REFERENCE TO USINT;
		strChar : STRING[2];
	END_VAR
END_FUNCTION_BLOCK


{REDUND_ERROR} FUNCTION FindClientUsingAPage : INT (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		clientListAdr : {REDUND_UNREPLICABLE} UDINT; (**)
		pageName1 : {REDUND_UNREPLICABLE} STRING[80]; (**)
		pageName2 : {REDUND_UNREPLICABLE} STRING[80]; (**)
		clientStructSize : UDINT; (**)
		lastClientIndex : INT; (**)
		highestClientSlot : INT; (**)
	END_VAR
	VAR
		i : INT;
	END_VAR
END_FUNCTION
