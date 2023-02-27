
TYPE
	XML_JENWAYV1_Type : 	STRUCT 
        Tx1 : INT;
        Tx2 : INT;
        DateAndTime : DATE_AND_TIME;
        LineNumber : UINT;
        LineName : STRING[32];
        CustomerNumber : UINT;
        CustomerName : STRING[32];
        ArticleNumber : UINT;
        ArticleName : STRING[32];
        RecipeNumber : UINT;
        RecipeName : STRING[32];
        NumbersInStack : UINT;
	END_STRUCT;
	XML_FUTURAIL_Type : 	STRUCT 
		Tx1 : INT;
		Tx2 : INT;
		CustomerNumber : DINT;
		ArticleNumber : DINT;
		CategoryNumber : INT;
		ArticleCount : INT;
		ExitNumber : INT;
		Option : DINT;
		LastBatch : INT;
		BatchID : DINT;
		SourceID : DINT;
		Weight : INT;
	END_STRUCT;
	XML_Connection_Type : 	STRUCT 
		IpAddress : ARRAY[0..13]OF XML_Connection_IpSplit_Type;
		Enable : ARRAY[0..13]OF BOOL;
		Id : ARRAY[0..13]OF USINT;
		Port : UINT;
		Base64 : BOOL;
		TextId : ARRAY[0..13]OF USINT;
		Show : ARRAY[0..13]OF USINT;
	END_STRUCT;
	XML_Connection_IpSplit_Type : 	STRUCT 
		Split : ARRAY[0..3]OF USINT;
	END_STRUCT;
	M2M_Info_Type : 	STRUCT 
		Data : ARRAY[0..9]OF USINT;
	END_STRUCT;
	M2M_Flat_Type : 	STRUCT 
		Data : ARRAY[0..9]OF UDINT;
	END_STRUCT;
	XML_Com_Type : 	STRUCT 
		ComState : INT;
		UpdateTrigger : UINT;
	END_STRUCT;
END_TYPE
