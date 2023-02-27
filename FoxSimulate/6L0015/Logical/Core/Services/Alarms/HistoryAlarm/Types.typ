
TYPE
	HMI_Type : 	STRUCT 
		alarmText : ARRAY[0..MAX_HMI_ALARMS]OF STRING[80];
		min : ARRAY[0..MAX_HMI_ALARMS]OF STRING[10];
		sec : ARRAY[0..MAX_HMI_ALARMS]OF STRING[3];
		events : ARRAY[0..MAX_HMI_ALARMS]OF STRING[10];
		totalPercentage : ARRAY[0..MAX_HMI_ALARMS]OF STRING[4];
		durationTime : ARRAY[0..MAX_HMI_ALARMS]OF STRING[10];
		totalTime : STRING[10];
	END_STRUCT;
	alarmHistory_type : 	STRUCT 
		DescAscii : STRING[80];
		DescUniCode : ARRAY[0..79]OF UINT;
		runtimeText : STRING[12];
		runtimeInSec : UDINT;
		events : UDINT;
		ID : UDINT;
		Index : INT;
		lastSeen : DATE_AND_TIME;
		totalPercentage : USINT;
	END_STRUCT;
END_TYPE
