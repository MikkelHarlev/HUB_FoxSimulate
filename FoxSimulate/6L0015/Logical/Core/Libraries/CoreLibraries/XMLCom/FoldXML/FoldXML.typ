TYPE
	JenXMLFoldClientInfo_Type : STRUCT
		MachineStatus	:INT;	
		Version	:STRING[10];	
		InletActive	:INT;	
		InletFull	:INT;	
		InternalAlarm	:INT;	
		RequestHangerData	:INT;	
		AwayHangerUpdate	:INT;	
		HangerId	:STRING[IDLength];	
		ConnectionState	:INT;	
		ConnectionError	:UDINT;	
		MessageIdEnable	:BOOL;	
	END_STRUCT;
			JenXMLFoldServerInfo_Type : STRUCT
		MachineStatus	:INT;	
		Version	:STRING[10];	
		OutletFull	:INT;	
		OutletHalfFull	:INT;	
		HangersWaiting	:INT;	
		TableUpdate	:INT;	
		IPAddress	:STRING[IDLength];	
		CacheClientPointer	:UDINT;	
	END_STRUCT;
			XMLFoldGarmentData_Type : STRUCT
		Program	:INT;	
		ArticleId	:INT;	
		CustomerId	:DINT;	
		Destination	:INT;	
		StackChange	:INT;	
		GarmentId	:STRING[IDLength];	
		HangerId	:STRING[IDLength];	
		SeqId	:INT;	
		MetricHangerReadStatus	:UINT;	
	END_STRUCT;
			StatisticCounters : STRUCT
		ConnectedOkCounter	:UINT;	
		ClosedCounter	:UINT;	
		RequestCounter	:UINT;	
		RequestOkCounter	:UINT;	
		AwayCounter	:UINT;	
		AwayOkCounter	:UINT;	
		StatusTransmitCounter	:UINT;	
		StatusOkCounter	:UINT;	
		NoAnswerCounter	:UINT;	
		ErrorCounter	:UINT;	
		WrongMessageIdCounter	:UINT;	
		UnknownTagCounter	:UINT;	
	END_STRUCT;
			JenXMLCommInfo_Type : STRUCT
		MachineType	:UINT;	
		MachineId	:INT;	
		StatusRefreshTime	:UINT;	
		StatusRefreshTimer	:UINT;	
		RequestTimeOutTime	:UINT;	
		RequestTimeOutTimer	:UINT;	
		LastResponseTime	:UINT;	
		ComState	:INT;	
		ClientInfo	:JenXMLFoldClientInfo_Type;	
		ServerInfo	:JenXMLFoldServerInfo_Type;	
		GarmentData	:XMLFoldGarmentData_Type;	
		Statistic	:StatisticCounters;	
	END_STRUCT;
END_TYPE
