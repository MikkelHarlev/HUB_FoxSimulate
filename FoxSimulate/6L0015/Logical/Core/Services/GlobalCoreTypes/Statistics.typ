
TYPE
	arrStatistics_Counters_Type : 	STRUCT 
		Production : ARRAY[0..9] OF UDINT;
		SortA : ARRAY[0..9] OF UDINT;
		SortB : ARRAY[0..9] OF UDINT;
		Drop : ARRAY[0..9] OF UDINT;
		Quality : ARRAY[0..9] OF UDINT;
		OverSize : ARRAY[0..9] OF UDINT;
		PreProduction : ARRAY[0..9] OF UDINT;
		TimeString : ARRAY[0..9] OF STRING[12];
		TimeInSec : ARRAY[0..9] OF UDINT;
		TooClose : ARRAY[0..9] OF UDINT;
		Option1 : ARRAY[0..9] OF UDINT;
		Option2 : ARRAY[0..9] OF UDINT;
		Option3 : ARRAY[0..9] OF UDINT;
		PU : USINT;
		Flow1 : ARRAY[0..9] OF UDINT;
		Flow2 : ARRAY[0..9] OF UDINT;
		Flow3 : ARRAY[0..9] OF UDINT;
		Target : ARRAY[0..9] OF USINT;
	END_STRUCT;
	ArrStatistics_Type : 	STRUCT 
		Statistics : ARRAY[0..98] OF arrStatistics_Counters_Type;
	END_STRUCT;
	JenLogStatistics_Type : 	STRUCT 
		Data : JenStatLog_Type;
		Write : BOOL;
	END_STRUCT;
	JenLogWrite_Type : 	STRUCT 
		Data : JenStatLogFile_Type;
		Write : BOOL;
	END_STRUCT;
	JenLogX_Type : 	STRUCT 
		PU : ARRAY[0..9] OF JenLogWrite_Type;
	END_STRUCT;
	JenStatLog_Type : 	STRUCT 
		TimeStart : ARRAY[0..9] OF DATE_AND_TIME;
		TimeStop : ARRAY[0..9] OF DATE_AND_TIME;
		TimeInSec : ARRAY[0..9] OF UDINT;
		CustomerNumber : ARRAY[0..9] OF UDINT;
		CustomerName : ARRAY[0..9] OF STRING[80];
		ArticleNumber : ARRAY[0..9] OF UDINT;
		ArticleName : ARRAY[0..9] OF STRING[80];
		RecipeNumber : ARRAY[0..9] OF UINT;
		RecipeName : ARRAY[0..9] OF STRING[80];
		SortA : ARRAY[0..9] OF UDINT;
		SortB : ARRAY[0..9] OF UDINT;
		Drop : ARRAY[0..9] OF UDINT;
		Quality : ARRAY[0..9] OF UDINT;
		OverSize : ARRAY[0..9] OF UDINT;
		PreProduction : ARRAY[0..9] OF UDINT;
		Production : ARRAY[0..9] OF UDINT;
		ShiftIndex : UDINT;
		LastReset : ARRAY[0..9] OF DATE_AND_TIME;
		TooClose : ARRAY[0..9] OF UDINT;
		Option1 : ARRAY[0..9] OF UDINT;
		Option2 : ARRAY[0..9] OF UDINT;
		Option3 : ARRAY[0..9] OF UDINT;
		Flow1 : ARRAY[0..9] OF UDINT;
		Flow2 : ARRAY[0..9] OF UDINT;
		Flow3 : ARRAY[0..9] OF UDINT; (*Master / Slave*)
		Target : ARRAY[0..9] OF USINT;
		Error : ARRAY[0..9] OF STRING[80];
	END_STRUCT;
	JenStatLogFile_Type : 	STRUCT 
		TimeStart : DATE_AND_TIME;
		TimeStop : DATE_AND_TIME;
		TimeInSec : UDINT;
		CustomerNumber : UDINT;
		CustomerName : STRING[80];
		ArticleNumber : UDINT;
		ArticleName : STRING[80];
		RecipeNumber : UINT;
		RecipeName : STRING[80];
		Production : UDINT;
		SortA : UDINT;
		SortB : UDINT;
		Drop : UDINT;
		Quality : UDINT;
		OverSize : UDINT;
		PreProduction : UDINT;
		Flow1 : UDINT;
		Flow2 : UDINT;
		Flow3 : UDINT;
		PU : USINT;
		ShiftIndex : UDINT;
		LastReset : DATE_AND_TIME;
		TooClose : UDINT;
		Option1 : UDINT;
		Option2 : UDINT;
		Option3 : UDINT;
		Target : USINT;
		Error : STRING[80];
	END_STRUCT;
	LogLib_Type : 	STRUCT 
		DataInBuffer : USINT;
		StepLogStore : USINT;
		StoreLastLineRead : USINT;
		CreateIndex : USINT;
		EntrysLogFile : UINT;
		EntrysLogBuffer : UINT;
		LogInitStatus : UINT;
		LastLineRead : UINT;
		LastLineWrite : UINT;
		LastLineWriteBuffer : UINT;
		CountlinesWritten : UINT;
		LinesToWrite : UINT;
		IndexType : UINT;
		pNameDevice : UDINT;
		pNameFile : UDINT;
		pLogBuffer : UDINT;
		pVariableDataList : UDINT;
		pVariableNameList : UDINT;
		CountVariables : UDINT;
		pWriteSemaphoreIdent : UDINT;
		pReadSemaphoreIdent : UDINT;
		FileSize : UDINT;
		FileIdent : UDINT;
		pFileData : UDINT;
		Offset2ndLine : UDINT;
		Offset3rdLine : UDINT;
		Offset4thLine : UDINT;
		VariableStructLength : UDINT;
		DataLineLength : UDINT;
		FirstLineLength : UDINT;
		pGetVariableData : UDINT;
		IndexMaxValue : UDINT;
		IndexOffset : UDINT;
		IndexValue : UDINT;
	END_STRUCT;
	No6_Type : 	STRUCT 
		Count : ARRAY[0..9] OF UDINT;
	END_STRUCT;
	StatConfig_Type : 	STRUCT 
		isRewash : BOOL;
		isRepair : BOOL;
		isDrop : BOOL;
		isQuality : BOOL;
		isOversize : BOOL;
		isPreproduction : BOOL;
		isTooClose : BOOL;
		isOption1 : BOOL;
		isOption2 : BOOL;
		isOption3 : BOOL;
		Flow1Type : USINT;
		Flow2Type : USINT;
		Flow3Type : USINT;
	END_STRUCT;
	Statistics_Counters_Type : 	STRUCT 
		Total : UDINT;
		Production : ARRAY[0..9] OF UDINT;
		SortA : UDINT;
		SortB : UDINT;
		Drop : UDINT;
		Quality : UDINT;
		OverSize : UDINT;
		PreProduction : UDINT;
		TimeString : STRING[12];
		TimeInSec : UDINT;
		TooClose : UDINT;
		Option1 : UDINT;
		Option2 : UDINT;
		Option3 : UDINT;
		Flow1 : UDINT;
		Flow2 : UDINT;
		Flow3 : UDINT;
	END_STRUCT;
	Statistics_DynanicVis_Type : 	STRUCT 
		Data : ARRAY[0..11] OF STRING[12];
	END_STRUCT;
	Statistics_DynLoad_Type : 	STRUCT 
		No : UDINT;
		Name : STRING[32];
		SubNo : UDINT;
		SubName : STRING[32];
		Counters : Statistics_Counters_Type;
		SubCount : UDINT;
		pNext : UDINT;
		pPrev : UDINT;
		pFirstSub : UDINT;
	END_STRUCT;
	Statistics_Vis_Type : 	STRUCT 
		SetupColors : ARRAY[0..11] OF UINT;
		Counters : Statistics_Counters_Type;
		ShowActiveOptions : ARRAY[0..11] OF UINT;
		ActiveOptions : ARRAY[0..11] OF UINT;
		ActiveLanes : ARRAY[0..11] OF UINT;
		ScrollBoxMinIndex : UINT;
		ScrollBoxMaxIndex : UINT;
		ScrollBoxDataPoint : UINT;
		ScrollBoxShow : UINT;
		ScrollBoxCmdEnter : BOOL;
		ScrollBoxCmdClose : BOOL;
		ScrollBoxList : ARRAY[0..9] OF STRING[32];
		ScrollBoxAllText : STRING[32];
		ScrollBoxCmdAll : BOOL;
		ScrollBoxCmdUp : BOOL;
		ScrollBoxCmdDown : BOOL;
		MainCmdCustomer : BOOL;
		MainCmdArticle : BOOL;
		MainCmdSubArticle : BOOL;
		MainCmdDate : BOOL;
		MainCustomerText : STRING[32];
		MainArticleText : STRING[32];
		MainSubArticleText : STRING[32];
		MainDateText : STRING[32];
		UnlockArticleSelect : UINT;
		UnlockBatchSelect : UINT;
		UnlockCustomerSelect : UINT;
		DateBoxMonthList : ARRAY[0..4] OF STRING[32];
		DateBoxDayList : ARRAY[0..4] OF STRING[3];
		DateBoxYearList : ARRAY[0..4] OF STRING[5];
		DateBoxSelected : UINT;
		DateBoxCmdMUp : BOOL;
		DateBoxCmdMDown : BOOL;
		DateBoxCmdDUp : BOOL;
		DateBoxCmdDDown : BOOL;
		DateBoxCmdYUp : BOOL;
		DateBoxCmdYDown : BOOL;
		DateBoxCmdEnter : BOOL;
		DateBoxCmdToday : BOOL;
		DateBoxShow : UINT;
		ShowCustomer : UINT;
		ShowArticle : UINT;
		ShowAll : UINT;
		ShowSetup : UINT;
	END_STRUCT;
	StatisticsMain_Type : 	STRUCT 
		pFirstCustomer : UDINT;
		CustomerCount : UINT;
		Counters : Statistics_Counters_Type;
		Vis : Statistics_Vis_Type;
		ListMode : USINT;
	END_STRUCT;
END_TYPE