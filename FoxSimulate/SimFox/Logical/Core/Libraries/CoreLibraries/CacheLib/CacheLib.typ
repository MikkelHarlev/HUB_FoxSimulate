
TYPE
	CacheInternalEssential_Type : 	STRUCT 
		Head : UDINT;
		End : UDINT;
		Lag : UINT;
	END_STRUCT;
	CacheManagerEssential_Type : 	STRUCT 
		State : UINT;
		CycleCount : UDINT;
		IdleMax : UINT;
		LimitFileSize : UDINT;
		DataTransactionBatch : USINT;
		DataBuffer : UDINT;
	END_STRUCT;
	CacheTrackEssential_Type : 	STRUCT 
		State : UINT;
		CriticalSectionIdent : UDINT; (* identity OF the critical section used TO protect list access *)
		BaseHead : UDINT; (* base pointer for the list ARRAY              *)
		FreeHead : UDINT; (* pointer TO the first free record in the list *)
		OlderHead : UDINT; (* pointer TO the oldest record in the list     *)
		YoungerHead : UDINT; (* pointer TO the youngest record in the list   *)
		DataHead : UDINT; (* base pointer TO the data ARRAY               *)
		DataSize : UINT; (* size OF a user data record                   *)
		TotalCount : UINT; (* total number OF records in the allocated ARRAY *)
		FreeCount : UINT; (* number OF free records in the list           *)
		GetKeyDataPtr : UDINT; (* pointer TO a function that computes a hash key for the user structure *)
		SetNullDataPtr : UDINT; (* pointer TO a function that resets the user structure TO an unused state *)
		IsNullDataPtr : UDINT; (* pointer TO a function that indicates if the user structure is unused *)
		IsEqualDataPtr : UDINT; (* pointer TO a function that compares 2 user structures *)
		Mirror : ARRAY[0..6]OF CacheInternalEssential_Type; (* base pointers for list mirroring*)
		HashTableHead : UDINT; (* base pointer TO the hash table               *)
		HashCount : UINT; (* number OF buckets in the hash table          *)
		HashToOne : UINT; (* number OF buckets assigned TO one record*)
		HashToTwo : UINT; (* number OF buckets assigned TO two records*)
		HashToMore : UINT; (* number OF buckets assigned TO more records*)
		Manager : CacheManagerEssential_Type; (* private structure OF the list manager*)
		Device : STRING[31]; (* device TO store the mirror journal*)
		File : STRING[31]; (* file TO store the mirror journal*)
		FOpen : FileOpen;
		FClose : FileClose;
		FCreate : FileCreate;
		FRead : FileRead;
		FWrite : FileWrite;
		FDelete : FileDelete;
		DInfo : DirInfo;
		Name : STRING[31];
	END_STRUCT;
	HangerASCII24_Type : 	STRUCT  (*A hanger with garment data*)
		Hanger : STRING[IDLength];
		Garment : STRING[IDLength];
		Flag : UINT;
		TimeStamp : DATE_AND_TIME := DT#1970-01-01-00:00; (*When the position changed*)
		MilliSec : UINT := 0; (*Milliseconds to the timestamp, if needed*)
		Position : UINT; (*A garment's current position*)
		Address : ARRAY[0..9]OF UINT;
		FinisherProgram : UINT;
		FinisherDestination : UINT;
		FolderProgram : UINT;
		FolderDestination : UINT;
		FolderSortID : UINT;
		Control : UINT;
		Presort : UINT;
		Exit : UINT;
		SortID : UINT;
		LotID : UINT;
		Size : UINT;
		GarmentType : UINT;
		Route : STRING[RouteLength];
		CustomerID : STRING[CustomerIDLength];
		CustomerName : STRING[CustomerNameLength];
		EmployeeID : STRING[EmployeeIDLength];
		EmployeeName : STRING[EmployeeNameLength];
		ArticleID : STRING[ArticleIDLength];
		ArticleName : STRING[ArticleNameLength];
		ArticleSize : STRING[ArticleSizeLength];
		InfoText : STRING[InfoTextLength];
		PresortString : STRING[PresortStringLength];
		StackString : STRING[StackStringLength];
		dummy : USINT;
	END_STRUCT;
	MT_MirrorThread : 	STRUCT  (*communication data type for the mirror's noncyclic thread*)
		threadId : UDINT;
		cmdStopThread : BOOL; (* true to request a thread stop *)
		threadActive : BOOL; (* true while thread running *)
		UdpOpenStruct : UdpOpen; (* UDP socket listenning for connection *)
		UdpCloseStruct : UdpClose;
		UdpSendStruct : UdpSend;
		UdpRecvStruct : UdpRecv;
		UdpIoctlStruct : UdpIoctl;
		client : STRING[16];
		buffer : ARRAY[0..MKUDPMirrorMAX]OF SINT; (* UDP communication buffer, should actually be 0..MKUDPMirrorMAX-1 if it was possible *)
		tk : REFERENCE TO CacheTrackEssential_Type;
		badCntRcx : UDINT;
		RcxCount : UDINT;
	END_STRUCT;
END_TYPE
