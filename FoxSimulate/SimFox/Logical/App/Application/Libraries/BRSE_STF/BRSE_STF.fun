(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: BRSE_STF
 * File: BRSE_STF.fun
 * Author: mar
 * Created: March 27, 2009
 ********************************************************************
 * Functions and function blocks of library BRSE_STF
 ********************************************************************)
(*Limitaions to the BRSE_STF Library*)
(*1) The depth of the struct is at most 10*)
(*2) A full variable name (i.e. Parameter.X.Y.Z) is at most 331 characters*)
(*3) A row in the file (parameter name, parameter value $r$n) is at most 500 characters*)
(*4) A String value may NOT contain any line breaks ($r or $n).*)
(*These limitations are treated as fulfilled, i.e. they are not part of error handling.*)

FUNCTION_BLOCK BRSE_STF_AppendStructToFile (*Appends a structure to a file. Each parameter is a line: "Parameter.X.Y.Z,value"*)
	VAR_INPUT
		pStructStates : REFERENCE TO ARRAY[0..9] OF StructState_typ;
		pFullName : UDINT; (*String containing the struct name. Should be large enough to hold any variable in the struct. (32*depth)*)
		pFB_FileWrite : REFERENCE TO FileWrite;
		pFileOffset : REFERENCE TO UDINT; (*Pointer to file offset. Will be updated to always point after the last byte written*)
		pMemBuf : UDINT;
		MemBufSize : UDINT;
		MaxExecutionMs : UDINT;
		Options : USINT; (*Bit 0 set --> Write csv file with (very) old syntax.*)
	END_VAR
	VAR_OUTPUT
		Status : UINT; (*Add your parameter comment*)
		Checksum : DINT;
		StructToFileSize : UDINT; (*Size of what's been written to the file*)
		Progress : USINT; (*Function block progress (%)*)
	END_VAR
	VAR
		Step : UINT; (*Add your parameter comment*)
		CurrentDepth : USINT;
		DataType : UDINT;
		DataLen : UDINT;
		DataAdr : UDINT;
		ErrorStatus : UINT;
		TmpDint : DINT;
		TmpReal : REAL;
		TmpAdr : UDINT;
		TmpString : STRING[20]; (*Used for itoa/ftoa*)
		GetFullName : BRSE_STF_GetFullName;
		TmpByte : USINT;
		StructSize : UDINT; (*Size of the structure*)
		WrittenSize : UDINT; (*Size of the variables that have been written*)
		TEnter : TIME;
		TElapsed : TIME;
		CanRepeat : BOOL;
		TmpOffset : UDINT;
		NextStep : UINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK BRSE_STF_GetFullName (*Builds full parameter name from StructStates and CurrentDepth. Puts the name info FullName*)
	VAR_INPUT
		pStructStates : REFERENCE TO ARRAY[0..9] OF StructState_typ;
		pFullName : UDINT; (*Should be large enough to hold any parameter name (32*depth)*)
		FullNameSize : UDINT;
		CurrentDepth : REFERENCE TO USINT;
	END_VAR
	VAR
		TmpUsint : USINT;
		TmpString : STRING[20];
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK BRSE_STF_StructToFile (*Write a struct to a complete file, including header and checksum. Any existing file will be deleted.*)
	VAR_INPUT
		FullName : STRING[331]; (*String containing the struct name. It's size limits the total variable name (32*depth)*)
		pDevice : UDINT; (*Pointer to the device name*)
		pFileName : UDINT; (*Pointer to the file name*)
		MaxExecutionMs : UDINT;
		Version : UINT;
		Options : USINT; (*Bit 0 set --> Write csv file with (very) old syntax.*)
	END_VAR
	VAR_OUTPUT
		Progress : USINT; (*Function block progress (%)*)
		Status : UINT;
	END_VAR
	VAR
		StructStates : ARRAY[0..9] OF StructState_typ; (*Array of structure states. It's size limits the depth of the structure.*)
		MemBuf : STRING[500];
		FB_FileDelete : FileDelete;
		FB_FileCreate : FileCreate;
		FB_FileWrite : FileWrite;
		FB_FileClose : FileClose;
		FB_AppendStructToFile : BRSE_STF_AppendStructToFile;
		Step : UINT;
		ErrorStatus : UINT;
		NextState : UINT;
		FileOffset : UDINT;
		FB_GetDT : DTGetTime;
		TmpString : STRING[30]; (*Used for acDT, itoa, ftoa*)
		Checksum : DINT;
		TEnter : TIME;
		TElapsed : TIME;
		CanRepeat : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK BRSE_STF_FileToStruct (*Reads parameter values from a file*)
	VAR_INPUT
		pDevice : UDINT; (*Pointer to the device name*)
		pFileName : UDINT; (*Pointer to the file name*)
		EnableChecksum : BOOL;
		MaxExecutionMs : UDINT;
	END_VAR
	VAR_OUTPUT
		Progress : USINT; (*Function block progress (%)*)
		Status : UINT; (*Add your parameter comment*)
		Version : UINT; (*User version*)
		StatusMessage : STRING[331];
	END_VAR
	VAR
		FullName : STRING[331]; (*String containing the struct name. Should be large enough to hold any variable in the struct. (32*depth)*)
		FB_FileOpen : FileOpen;
		FB_FileRead : FileRead;
		FB_FileClose : FileClose;
		Step : UINT; (*Add your parameter comment*)
		ErrorStatus : UINT;
		MemBuf : ARRAY[0..499] OF USINT; (*Memory buffer.*)
		FileOffset : UDINT;
		TmpByte : USINT;
		TmpOffset : UDINT;
		NextStep : UINT;
		ReadLen : UDINT;
		TmpString : STRING[30];
		OffsetStart : UDINT;
		DataType : UDINT;
		DataLen : UDINT;
		Dimension : UINT;
		TmpUsint : USINT;
		TmpDint : DINT;
		TmpAdr : UDINT;
		InitialError : USINT;
		TmpReal : REAL;
		GetChecksum : BRSE_STF_GetChecksum;
		OldVersion : BOOL;
		WarningStatus : UINT;
		TEnter : TIME;
		TElapsed : TIME;
		CanRepeat : BOOL;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK BRSE_STF_ValidateFile (*Controls checksum and reads version information*)
	VAR_INPUT
		pDevice : UDINT; (*Pointer to the device name*)
		pFileName : UDINT; (*Pointer to the file name*)
		EnableChecksum : BOOL;
	END_VAR
	VAR_OUTPUT
		Status : UINT; (*Add your parameter comment*)
		Version : UINT; (*User version*)
	END_VAR
	VAR
		FullName : STRING[331]; (*String containing the struct name. Should be large enough to hold any variable in the struct. (32*depth)*)
		FB_FileOpen : FileOpen;
		FB_FileRead : FileRead;
		FB_FileClose : FileClose;
		Step : UINT; (*Add your parameter comment*)
		ErrorStatus : UINT;
		MemBuf : ARRAY[0..499] OF USINT; (*Memory buffer.*)
		TmpByte : USINT;
		TmpOffset : UDINT;
		TmpString : STRING[30];
		TmpUsint : USINT;
		OffsetStart : UDINT;
		TmpDint : DINT;
		GetChecksum : BRSE_STF_GetChecksum;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK BRSE_STF_GetChecksum (*Reads a file and calculates the checksum*)
	VAR_INPUT
		pFB_FileRead : REFERENCE TO FileRead;
		pMemBuf : UDINT;
		MemBufSize : UDINT;
		OffsetStart : UDINT;
		OffsetEnd : UDINT;
	END_VAR
	VAR_OUTPUT
		Checksum : DINT;
		Status : UINT;
	END_VAR
	VAR
		ErrorStatus : UINT;
		Step : UINT;
		CurrentOffset : UDINT;
		TEnter : TIME;
		TElapsed : TIME;
		CanRepeat : BOOL;
		TmpByte : USINT;
	END_VAR
END_FUNCTION_BLOCK
