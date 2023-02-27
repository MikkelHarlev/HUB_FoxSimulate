
TYPE
	Trace2FileStateEnum : 
		(
		T2F_WaitEnable := 0,
		T2F_Init := 1,
		T2F_WaitData := 2,
		T2F_MoreData := 3,
		T2F_WaitOpenFile := 4,
		T2F_WaitCreateFile := 5,
		T2F_WaitWriteBuffer := 6,
		T2F_CloseFile := 7,
		T2F_WaitCloseFile := 8,
		T2F_WaitInfo := 9,
		T2F_WaitDeleteFile := 10,
		T2F_RenameFile := 11,
		T2F_WaitRenameFile := 12,
		T2F_WaitWritingIdle := 13,
		T2F_WaitingWritingBuffer := 14,
		T2F_WaitingWritingBufferNF := 15,
		T2F_WaitingDataInBuffer := 16,
		T2F_WaitingNewFile := 17,
		T2F_WaitNewFile := 18,
		T2F_Waiting := 90,
		T2F_Error := 98,
		T2F_ErrorWait := 99
		);
END_TYPE
