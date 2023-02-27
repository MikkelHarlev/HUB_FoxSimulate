(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: Peekaboo
 * File: Peekaboo.typ
 * Author: eg
 * Created: January 17, 2014
 ********************************************************************
 * Data types of library Peekaboo
 ********************************************************************)

TYPE
	hashItem_type : 	STRUCT 
		key : STRING[16];
		value : UDINT;
		adrNext : UDINT;
	END_STRUCT;
	metaDataTag_type : 	STRUCT 
		ID : UINT; (*Unique ID for a metaDataTag*)
		name : UDINT; (*Name of the Meta Data tag*)
		transcoding : UDINT; (*How to understand the value*)
	END_STRUCT;
	tracker_type : 	STRUCT 
		selectedPrime : UDINT;
		allocatedMem : UDINT;
		memIdent : UDINT;
		poolSize : UDINT;
		items : UDINT;
		adrItemPool : UDINT;
		adrHashTable : UDINT;
		itemsUsed : UDINT;
		end : UDINT;
		checkSize : UDINT;
		loadFactor : UDINT;
	END_STRUCT;
END_TYPE
