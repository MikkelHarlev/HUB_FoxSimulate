/********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: Peekaboo
 * File: metaTag.c
 * Author: eg
 * Created: January 17, 2014
 *******************************************************************/

#include <bur/plctypes.h>

#include "peek.h"
#include "AsMEM.h"
#include <string.h>

// first 169 primes below 1000
const UINT primes[170] = {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,521,523,541,547,557,563,569,571,577,587,593,599,601,607,613,617,619,631,641,643,647,653,659,661,673,677,683,691,701,709,719,727,733,739,743,751,757,761,769,773,787,797,809,811,821,823,827,829,839,853,857,859,863,877,881,883,887,907,911,919,929,937,941,947,953,967,971,977,983,991,997,10007};

// Prototypes
UDINT searchItemInBucket(UDINT *pTableEntry, UDINT adrKey, UDINT trackIdent, UDINT *level, UDINT value);
USINT insertNewItem (UDINT *pTableEntry, UDINT trackIdent, UDINT adrKey, UDINT value);

int check_prime(int a)
{
	int c;
 
    for ( c = 2 ; c <= a - 1 ; c++ ){ 
    	if ( a%c == 0 )
        return 0;
    }
    if ( c == a ){
		return 1;
	}
	else {
		return 0;
	}
}

unsigned char itox(unsigned char i, unsigned long adrStr)
{ 
    unsigned char n; 
  	char *s;
	s = (char*) adrStr;
	
    s += 2; 
    *s = '\0'; 
  
    for (n = 2; n != 0; --n) { 
        *--s = "0123456789ABCDEF"[i & 0x0F]; 
        i >>= 4; 
	}
	return 0;
} 

unsigned char tagIDtoString(unsigned long adrString, unsigned long adrID, unsigned char len){
	USINT i;
	char tmpString[3];
	memset((char*)adrString,0,len);
	for (i = 0; i != len; ++i) { 
		itox(*((USINT*)(adrID+i)),(UDINT)&tmpString);
		if (i) strcat((char*) adrString,(char*) &tmpString);
		else strcpy((char*) adrString,(char*) &tmpString);
		
	}
	return 0;
};


UDINT generatePreHash(UDINT pKey){
	const char*	s = ((const char*)pKey);
	unsigned long h = 0;
	USINT i = 0;
//	if (len) {
//		while (i < len) {
//			i++;	
//	    	h = (h << 5) + h + (unsigned char)*s++;
//		}
//	}
//	else {
		while (*s) {
			i++;	
    		h = (h << 5) + h + (unsigned char)*s++;
		}
//	}
	return h;
};

void clearTracker(clearTracker_typ* inst) {
	tracker_type  *internalStore;
	UDINT		  *pTableEntry;
	tracker_type	oldStore;
	if (inst->trackIdent) {
		internalStore = (tracker_type*) inst->trackIdent;
		oldStore = *internalStore;
		memset(inst->trackIdent,0,internalStore->allocatedMem);
		*internalStore = oldStore;
		internalStore->itemsUsed = 0;
		internalStore->items = 0;
		internalStore->loadFactor = 0;
		
		inst->status = 0;

		}
	}


void getItem(getItem_typ* inst) {
	tracker_type  *internalStore;
	UDINT		  *pTableEntry;
	inst->level = 0;
	if (inst->trackIdent) {
		internalStore = (tracker_type*) inst->trackIdent;		
		inst->preHashKey = generatePreHash(inst->adrKey);
		inst->hash		 = inst->preHashKey % internalStore->selectedPrime;
		inst->adrHsh	 = (UDINT) pTableEntry;
		pTableEntry 	 = (UDINT*) internalStore->adrHashTable;
		// Move entry to hash
		pTableEntry      = pTableEntry + inst->hash;
		inst->value = searchItemInBucket(pTableEntry, inst->adrKey, inst->trackIdent, &inst->level, 0);
		if (inst->value) {
			// Key found returning value
			inst->status = 0;
		}
		else {
			// Key not found set status error.
			inst->status = 1;
			}
	}
}

void addItem(addItem_typ* inst) {
	tracker_type  *internalStore;
	UDINT		  *pTableEntry;
	inst->level = 0;
	// Check if hashtable has been created
	if (inst->trackIdent) {
		internalStore = (tracker_type*) inst->trackIdent;		
		
		// looks like we are in business...
		if (internalStore->checkSize) { 
			// Lets insert the item...
			inst->preHashKey = generatePreHash(inst->adrKey);
			inst->hash		 = inst->preHashKey % internalStore->selectedPrime;
			pTableEntry 	 = (UDINT*) internalStore->adrHashTable;
			// Move entry to hash
			pTableEntry      = pTableEntry + inst->hash;
			inst->adrHsh	 = (UDINT) pTableEntry;
			//(*pTableEntry)   = internalStore->adrItemPool + internalStore->items;
			
			// We are in the bucket check if it is used.
			if (searchItemInBucket(pTableEntry, inst->adrKey, inst->trackIdent, &inst->level, inst->value)) {
				// Inserted
				inst->status = 0;
			}
			else {
				// not inserted
				inst->status = 1;
			}
		}
	}	
};

UDINT searchItemInBucket(UDINT *pTableEntry, UDINT adrKey, UDINT trackIdent, UDINT *level, UDINT value) {
	
	hashItem_type *hashItem;
	tracker_type *internalStore;
	internalStore = (tracker_type*) trackIdent;
	// Check if the bucket is used.
	if (*pTableEntry) {
		// Bucket found
		hashItem = (hashItem_type*) (*pTableEntry);
		if (strcmp((char*)adrKey, (char*)&hashItem->key) == 0) {
			// Update, key is the same.
			//hashItem->adrItem++;
			return hashItem->value;
		}
		// Search next for a match
		else if (hashItem->adrNext) {
			(*level)++;
			if (*level > internalStore->loadFactor) internalStore->loadFactor = *level;
			return searchItemInBucket(&hashItem->adrNext, adrKey, trackIdent, level, value);
		}
		else if (!hashItem->adrNext && value){
			// Add sub
			return insertNewItem(&hashItem->adrNext, trackIdent, adrKey, value);
		}
	}
	else if (value){
		return insertNewItem(pTableEntry, trackIdent, adrKey, value);
		
	}
	return 0;
}

USINT insertNewItem (UDINT *pTableEntry, UDINT trackIdent, UDINT adrKey, UDINT value) {
	
	hashItem_type *hashItem;
	
	// Allocate new object.
	tracker_type *internalStore;
	internalStore = (tracker_type*) trackIdent;
	
	if (internalStore->poolSize > internalStore->items) {
	// We still have free items in our item pool.
		*pTableEntry = internalStore->adrItemPool + (internalStore->items * sizeof(hashItem_type));
		// One item used from the pool
		internalStore->items++;
		// Accessing new item in bucket.
		hashItem = (hashItem_type*) (*pTableEntry); 
		// Insert
		strcpy((char*)&hashItem->key, (char*)adrKey);		
		hashItem->value = value;
		// Update load factor
		
		
		return hashItem->value;
	}
	else {
		return 0;
	}
}

void initTracker(initTracker_typ* inst) {
	// struct for allocating memory for the item pool.
	AsMemPartCreate_typ AsMemPartCreate_0;
	AsMemPartAllocClear_typ AsMemPartAllocClear_0;
	
	tracker_type* internalStore;
	UDINT allocatedMem, selectedPrime, primeBase;
	// set status to initializing.
	inst->status = 2;
	//                            memory for pool                memory for Asmem overhead
	// check closest prime for hashing uniqueIDs
	if (inst->minHashSize) {
		primeBase = inst->minHashSize;
	}
	else {
		primeBase = inst->poolSize;
	}
	while(!check_prime(primeBase)) {
		primeBase++; 
	}
	selectedPrime = primeBase;
	//
//	for (i = 0;i < (sizeof(primes) / sizeof(primes[0])); i++ ) {
//		if (primes[i] > inst->poolSize) {
//			selectedPrime = primes[i];	
//			break;
//		}
//	
//	}
	allocatedMem = (selectedPrime * sizeof(UDINT))+(sizeof(hashItem_type)*inst->poolSize)+(sizeof(tracker_type));
	
	
	// Ask AsMEM for memory partition.
	AsMemPartCreate_0.enable = 1;
	AsMemPartCreate_0.len 	 = allocatedMem+108+16;
	inst->usedMem = AsMemPartCreate_0.len;
	AsMemPartCreate(&AsMemPartCreate_0);
	
	if (!AsMemPartCreate_0.status) {
		AsMemPartAllocClear_0.enable = 1;
		AsMemPartAllocClear_0.ident  = AsMemPartCreate_0.ident;
		AsMemPartAllocClear_0.len    = allocatedMem;
		inst->wantedMem				 = allocatedMem;
		AsMemPartAllocClear(&AsMemPartAllocClear_0);
		
		if (!AsMemPartAllocClear_0.status) {
			internalStore                = (tracker_type*) AsMemPartAllocClear_0.mem;
			inst->trackIdent             = (UDINT) internalStore;
			internalStore->memIdent      = AsMemPartCreate_0.ident;
			internalStore->allocatedMem  = allocatedMem;
			
			internalStore->poolSize      = inst->poolSize;
			internalStore->selectedPrime = selectedPrime;
			internalStore->adrHashTable  = (UDINT) internalStore + sizeof(tracker_type);
			internalStore->adrItemPool   = internalStore->adrHashTable + (selectedPrime * sizeof(UDINT));
			internalStore->end			 = internalStore->adrItemPool + (internalStore->poolSize * sizeof(hashItem_type));
			internalStore->checkSize     = internalStore->end - (UDINT) internalStore;
			internalStore->itemsUsed	 = 0;
			
			// Test
			
			inst->status   = 0;
			inst->initDone = 1;
		}
		else {
			inst->status = AsMemPartAllocClear_0.status;
			inst->initDone = 2;
		}
	}
	else {
		inst->status = AsMemPartCreate_0.status;
		inst->initDone = 3;
	}
};
	
USINT createTrackItem(USINT externalID[8], UDINT trackIdent) {
	
	
	return 1;
	};

USINT initMetaTagHashTable(UDINT memIdent) {
	
	
	return 1;
};
