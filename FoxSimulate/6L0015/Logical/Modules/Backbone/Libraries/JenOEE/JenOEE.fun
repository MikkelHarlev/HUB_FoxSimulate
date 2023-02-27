
{REDUND_ERROR} FUNCTION_BLOCK FB_Jen_OEE_ST (*Jensen OEE Data Average for the last hour of production*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL;
		saveSample : BOOL;
		data : OEE_Data_type;
		currentTime : DATE_AND_TIME;
		extractOEEData : TIME;
	END_VAR
	VAR_OUTPUT
		averageOEEValues : OEE_Average_type;
		averageOEEData : OEE_LT_Sample_type;
		status : UINT;
	END_VAR
	VAR
		OEESamples : ARRAY[0..ST_BUFFER_SIZE] OF OEE_Sample_type;
		idx : INT;
		prevIdx : INT;
		numOfICT : INT;
		i : INT;
		Head : INT;
		Tail : INT;
		OEEPerfCalculation : ARRAY[0..ST_BUFFER_SIZE] OF OEE_PerformanceCalcData_type;
		tempPPT : DINT;
		tempRT : DINT;
		tempST : DINT;
		tempOptimalProdTime : REAL;
		tempActualProdCount : REAL;
		tempGPC : REAL;
		tempTPC : REAL;
		isICTregistered : BOOL;
	END_VAR
END_FUNCTION_BLOCK

{REDUND_ERROR} FUNCTION_BLOCK FB_Jen_OEE_LT (*TODO: Add your comment here*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL;
		saveSample : BOOL;
		data : OEE_LT_Sample_type;
		extractOEEData : TIME;
	END_VAR
	VAR_OUTPUT
		averageOEEValues : OEE_Average_type;
		averageOEEData : OEE_LT_Sample_type;
		status : UINT;
	END_VAR
	VAR
		OEESamples : ARRAY[0..LT_BUFFER_SIZE] OF OEE_LT_Sample_type;
		idx : INT;
		Head : INT;
		Tail : INT;
		OEEAvailCalculation : OEE_AvailabilityCalcData_type;
		OEEPerfCalculation : OEE_PerformanceCalcData_type;
		OEEQualCalculation : OEE_QualityCalcData_type;
	END_VAR
END_FUNCTION_BLOCK
