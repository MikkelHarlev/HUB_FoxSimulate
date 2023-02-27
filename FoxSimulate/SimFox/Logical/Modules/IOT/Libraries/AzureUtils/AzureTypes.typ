
TYPE
	IOTEventType_enum : 
		(
		error,
		machineInfo,
		serviceLogin,
		productionLog
		);
	IOTEvent_Type : 	STRUCT 
		type : USINT; (*Defines the message topic*)
		message : STRING[5000];
	END_STRUCT;
	IOTLog_Type : 	STRUCT 
		Index : UINT;
		publish : IOTEvent_Type;
	END_STRUCT;
	AzureLogin_type : 	STRUCT 
		device : STRING[256];
		SASresource : STRING[256];
		host : STRING[256];
		primarykey : STRING[256];
		user : STRING[256];
		aliveAndConnected : BOOL;
		isEnabled : BOOL;
		SASToken : STRING[256];
		isConnected : BOOL;
	END_STRUCT;
	JSONElement_type : 	STRUCT 
		FullName : STRING[64];
		Name : STRING[32];
		Address : UDINT;
		Length : UDINT;
		Type : USINT;
		parentName : STRING[32];
	END_STRUCT;
	JSONEntry_type : 	STRUCT 
		Name : STRING[32];
		Elements : UINT;
		Element : ARRAY[0..63]OF JSONElement_type;
	END_STRUCT;
END_TYPE
