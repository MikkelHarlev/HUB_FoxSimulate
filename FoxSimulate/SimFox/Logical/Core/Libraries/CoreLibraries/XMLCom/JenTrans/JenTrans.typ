TYPE
	JenTransClientInfo_Type : STRUCT
		ObjectStatus	:INT;	
		Version	:STRING[10];	
		ConnectionId	:UDINT;	
		ConnectionState	:INT;	
		ConnectionError	:UDINT;	
		MessageId	:UINT;	
		MessageIdEnable	:BOOL;	
	END_STRUCT;
			JenTransServerInfo_Type : STRUCT
		ObjectStatus	:INT;	
		Version	:STRING[10];	
		IPAddress	:STRING[25];	
		LastIPAddress	:STRING[25];	
	END_STRUCT;
			JenTransStatisticCounters : STRUCT
		ConnectedOkCounter	:UINT;	
		ClosedCounter	:UINT;	
		UpdateCounter	:UINT;	
		UpdateOkCounter	:UINT;	
		StatusTransmitCounter	:UINT;	
		StatusOkCounter	:UINT;	
		NoAnswerCounter	:UINT;	
		ErrorCounter	:UINT;	
		WrongMessageIdCounter	:UINT;	
		UnknownTagCounter	:UINT;	
	END_STRUCT;
			JenTransCommonInfo_Type : STRUCT
		ObjectType	:UINT;	
		ObjectId	:INT;	
		StatusRefreshTime	:UINT;	
		StatusRefreshTimer	:UINT;	
		RequestTimeOutTime	:UINT;	
		RequestTimeOutTimer	:UINT;	
		LastResponseTime	:UINT;	
		ComState	:INT;	
		UpdateTrigger	:UINT;	
		Flag	:UINT;	
		ClientInfo	:JenTransClientInfo_Type;	
		ServerInfo	:JenTransServerInfo_Type;	
		DataVariableAddressListPointer	:UDINT;	
		DataFieldNameListPointer	:UDINT;	
		DataVariableFields	:UINT;	
		DataFieldNameStartPos	:UINT;	
		Statistic	:JenTransStatisticCounters;	
	END_STRUCT;
END_TYPE
