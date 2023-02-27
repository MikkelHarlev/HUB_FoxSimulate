

PROGRAM _INIT
	// Create a mem partition of 1 megabyte for the object bool.
	initTracker_0(poolSize := 100, minHashSize := 2000);
	buckets;
	bucketsUsed 																:= 0;
	
END_PROGRAM