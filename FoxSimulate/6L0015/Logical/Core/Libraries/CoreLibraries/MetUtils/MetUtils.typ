
TYPE
	DelayedOutput_Type : 	STRUCT 
		State : BOOL;
		StartTimer : UINT;
		Delay : UINT;
	END_STRUCT;
	HangerID_Type : 	STRUCT 
		Low : UDINT;
		High : UDINT;
	END_STRUCT;
	PresenceSensor_Type : 	STRUCT 
		RunTimer : UINT;
		State : UINT;
		Input : BOOL;
		OnDelay : UINT;
		OffDelay : UINT;
	END_STRUCT;
	Garment_Type : 	STRUCT 
		Description : STRING[20];
		ArticleId : UINT;
		FinisherAccum : UINT;
		FinisherCategory : UINT;
		FolderAccum : UINT;
		FolderRail : UINT;
		FolderCategory : UINT;
		FolderBelt : UINT;
		Inspection : UINT;
		PictureIndex : UINT;
		Reserve1 : UINT;
		Reserve2 : UINT;
	END_STRUCT;
	ArticleData_Type : 	STRUCT 
		Name : STRING[20];
		Value : UINT;
	END_STRUCT;
END_TYPE
