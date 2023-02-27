
TYPE
	gLiteBucket_type : 	STRUCT 
		index : ARRAY[0..9]OF gLiteData_type;
		bucketId : STRING[16];
		accessTimes : INT;
	END_STRUCT;
	gLiteStatus_type : 	STRUCT 
		index : UDINT;
		statusId : UDINT;
		alarm : STRING[1000];
		customerId : UDINT;
		processCodeId : UDINT;
		articleId : UDINT;
	END_STRUCT;
	gLiteStatusAlarm_type : 	STRUCT 
		id : UDINT;
	END_STRUCT;
	gLiteData_type : 	STRUCT 
		index : UDINT;
		qualityCount : UDINT;
		productionCountOut : UDINT;
		productionCountIn : UDINT;
		processCodeId : UDINT;
		articleId : UDINT;
		customerId : UDINT;
		durationOut : UDINT;
		durationIn : UDINT;
		durationNoFlow : UDINT;
		processNorm : UDINT;
		rewashCount : UDINT;
		repairCount : UDINT;
		sortCategoryId : UDINT;
		weight : UDINT;
		batchCount : UDINT;
	END_STRUCT;
	gLiteDataFile_type : 	STRUCT 
		index : UDINT;
		timeStamp : STRING[20];
		indexType : STRING[10];
		qualityCount : UDINT;
		dropCount : UDINT;
		productionCount : UDINT;
		processCodeId : UDINT;
		articleId : UDINT;
		customerId : UDINT;
		duration : UDINT;
		processNorm : UDINT;
		reWashCount : UDINT;
		repairCount : UDINT;
		sortCategoryId : UDINT;
		weight : UDINT;
		batchCount : UDINT;
	END_STRUCT;
	PLCInfo_type : 	STRUCT 
		serialNumber : UDINT;
		moduleID : UINT;
		firmwareVersion : UINT;
		batteryStatusCPU : USINT;
		temperatureCPU : UINT;
		temperatureENV : UINT;
	END_STRUCT;
	meta_type : 	STRUCT 
		softwareVersion : STRING[32];
		machineType : STRING[32];
		productionHours : UDINT;
		uptimeHours : UDINT;
		totalUptimeHours : UDINT;
		totalCount : UDINT;
		ipAddress : STRING[32];
		gatewayAddress : STRING[32];
		subnetMask : STRING[32];
		macAddress : STRING[32];
		dnsAddress1 : STRING[32];
		dnsAddress2 : STRING[32];
		dnsAddress3 : STRING[32];
	END_STRUCT;
	MCfg_IOT_Type : 	STRUCT 
		host : STRING[50];
		deviceID : STRING[50];
		key : STRING[50];
		isEnabled : BOOL;
		isSendInfo : BOOL;
		isSendAlert : BOOL;
		connectTimeoutInSeconds : DINT;
		reconnectIntervalInSeconds : DINT;
		heartBeatInSeconds : UINT;
		liteInterfaceSampleInterval : INT;
		isLiteInterfaceEnabled : BOOL;
	END_STRUCT;
	topic_typ : 	STRUCT 
		New_Member : USINT;
		topic : STRING[300];
		message : STRING[300];
		messageLen : UINT;
	END_STRUCT;
END_TYPE
