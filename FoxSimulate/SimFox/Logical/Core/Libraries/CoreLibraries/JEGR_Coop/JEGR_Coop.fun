
FUNCTION_BLOCK Scroll
	VAR_INPUT
		In : BOOL;
		DelayScroll : UINT;
		DelayRepeat : UINT;
		pTimeReference : UDINT;
	END_VAR
	VAR_OUTPUT
		Out : BOOL;
	END_VAR
	VAR
		Init : BOOL;
		State : USINT;
		StartTime : UDINT;
		TimeReference : REFERENCE TO UDINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK DeCode
	VAR_INPUT
		PassWordAdr : UDINT;
	END_VAR
	VAR
		Copy : REFERENCE TO UDINT;
		Pass : REFERENCE TO ARRAY[0..3] OF USINT;
		Init : BOOL;
		TLong : UDINT;
		TWord : REFERENCE TO ARRAY[0..1] OF UINT;
		TByte : REFERENCE TO ARRAY[0..3] OF USINT;
		b : SINT;
		i : SINT;
		s : SINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK Encrypt
	VAR_INPUT
		PassWordAdr : UDINT;
	END_VAR
	VAR
		Copy : REFERENCE TO ARRAY[0..3] OF USINT;
		Pass : ARRAY[0..3] OF USINT;
		Init : BOOL;
		TLong : REFERENCE TO UDINT;
		TWord : REFERENCE TO ARRAY[0..1] OF UINT;
		TByte : REFERENCE TO ARRAY[0..3] OF USINT;
		b : SINT;
		i : SINT;
		s : SINT;
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK MachineInfo
	VAR_INPUT
		Enable : BOOL;
		Running : BOOL;
		Counts : USINT;
		State : UINT;
		pInfoMemory : UDINT;
		pInfoCFCard : UDINT;
	END_VAR
	VAR_OUTPUT
		PowerOnHours : UDINT;
		OperatingHours : UDINT;
		ProductionCounts : UDINT;
		ProductionCountsSmall : UINT;
		FileSave : BOOL;
		StatusCode : UINT;
		StatusString : STRING[32];
	END_VAR
	VAR
		InitDone : BOOL;
		Check : BOOL;
		Restart : BOOL;
		SumPanel : USINT;
		SumCF : USINT;
		Sum : USINT;
		Size : USINT;
		Cnt : USINT;
		TempUdint : REFERENCE TO UDINT;
		TempUint : REFERENCE TO UINT;
		InfoMemory : REFERENCE TO MachinePermInfo_Type;
		InfoCFCard : REFERENCE TO MachinePermInfo_Type;
		TON_10ms_0 : TON_10ms;
	END_VAR
END_FUNCTION_BLOCK
(********************************************************************
 * COPYRIGHT -- Jensen Denmark A/S
 ********************************************************************
 * Library: JEGR_Coop
 * File: JEGR_Coop.fun
 * Author: eg
 * Created: June 09, 2010
 ********************************************************************
 * Functions and function blocks of library JEGR_Coop
 ********************************************************************)
