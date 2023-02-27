
TYPE
	HMI_CUR_ALRMLIST : 	STRUCT 
		TimePerTrig : UDINT;
		Time : UDINT;
		Time_Sec : UDINT;
		Count : USINT;
		Timer_10ms : UDINT;
		AlarmSaved : BOOL;
		FirstAlarm : BOOL;
		Alarm : BOOL;
		Index : UDINT;
	END_STRUCT;
	HMIStatistic_ALM : 	STRUCT 
		CurrentAlrmList : ARRAY[0..70] OF HMI_CUR_ALRMLIST;
		CurLayer : USINT;
		Date : DATE_AND_TIME;
		Delete : BOOL;
		NumberOfPiecesTotal : UDINT;
	END_STRUCT;
END_TYPE
