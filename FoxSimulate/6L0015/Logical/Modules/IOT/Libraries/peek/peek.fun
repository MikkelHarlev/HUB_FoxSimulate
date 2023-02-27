(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: Peekaboo
 * File: Peekaboo.fun
 * Author: eg
 * Created: January 17, 2014
 ********************************************************************
 * Functions and function blocks of library Peekaboo
 ********************************************************************)

FUNCTION tagIDtoString : USINT
	VAR_INPUT
		adrString : UDINT;
		adrID : UDINT;
		len : USINT;
	END_VAR
END_FUNCTION

FUNCTION_BLOCK clearTracker
	VAR_INPUT
		trackIdent : UDINT;
	END_VAR
	VAR_OUTPUT
		status : USINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK getItem
	VAR_INPUT
		adrKey : UDINT;
		trackIdent : UDINT;
	END_VAR
	VAR_OUTPUT
		status : USINT;
		value : UDINT;
		level : UDINT;
	END_VAR
	VAR
		hash : UDINT;
		preHashKey : UDINT;
		adrHsh : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK addItem
	VAR_INPUT
		adrKey : UDINT; (*For now keys have fixed 8 byte lenght*)
		trackIdent : UDINT;
		value : UDINT;
	END_VAR
	VAR_OUTPUT
		level : UDINT;
		Ident : UDINT;
		status : USINT;
		itemIdent : UDINT;
	END_VAR
	VAR
		hash : UDINT;
		preHashKey : UDINT;
		adrHsh : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK initTracker
	VAR_INPUT
		poolSize : UDINT; (*Number of unique item to track.*)
		minHashSize : UDINT;
	END_VAR
	VAR_OUTPUT
		trackIdent : UDINT;
		status : UDINT;
		initDone : USINT;
	END_VAR
	VAR
		usedMem : UDINT;
		wantedMem : UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION createTrackItem : USINT
	VAR_INPUT
		externalID : ARRAY[0..7] OF USINT;
		trackIdent : UDINT;
	END_VAR
END_FUNCTION

FUNCTION generatePreHash : UDINT
	VAR_INPUT
		adrString : UDINT;
	END_VAR
END_FUNCTION

FUNCTION initMetaTagHashTable : USINT
	VAR_INPUT
		memIdent : UDINT;
	END_VAR
END_FUNCTION
