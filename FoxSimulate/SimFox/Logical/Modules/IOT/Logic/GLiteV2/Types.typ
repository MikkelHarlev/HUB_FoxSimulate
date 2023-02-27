
TYPE
	GLiteAlarmQueryOutput : 	STRUCT 
		updateCount : UDINT;
		alarmCode : UDINT;
		alarmSeverity : UDINT;
		alarmMessage : WSTRING[160];
	END_STRUCT;
	GLiteOldValues : 	STRUCT 
		processCodeId : UDINT;
		customerId : UDINT;
		articleId : UDINT;
		machineState : USINT;
	END_STRUCT;
	GLiteBucket_Main : 	STRUCT 
		bucket : GLiteBucket_Bucket;
		loadID : UDINT;
		oldValues : GLiteBucket_OldValues;
		noOfLanes : USINT;
		TON_NoFlow10ms : TON_10ms;
	END_STRUCT;
	GLiteBucket_Bucket : 	STRUCT 
		doMake : BOOL;
		ID : STRING[16];
		Ident : UDINT;
	END_STRUCT;
	GLiteBucket_OldValues : 	STRUCT 
		loadID : UDINT;
		productionCount : UDINT;
		repairCount : UDINT;
		reWashCount : UDINT;
		qualityCount : UDINT;
		timeCount : UDINT;
	END_STRUCT;
END_TYPE
