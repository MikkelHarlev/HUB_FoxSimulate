
TYPE
	OEE_Data_type : 	STRUCT 
		runTime : DINT;
		stopTime : OEE_timeDetails_type;
		waitTime : OEE_timeDetails_type;
		idealCycleTime : REAL;
		actualProdCount : UDINT;
		totalProdCount : UDINT;
		goodProdCount : UDINT;
	END_STRUCT;
	OEE_Sample_type : 	STRUCT 
		OEEData : OEE_Data_type;
		timeStamp : DATE_AND_TIME;
	END_STRUCT;
	OEE_LT_Sample_type : 	STRUCT 
		OEEData : OEE_Data_type;
		timeStamp : DATE_AND_TIME;
		duration : TIME;
	END_STRUCT;
	OEE_PerformanceCalcData_type : 	STRUCT 
		runTime : DINT;
		idealCycleTime : REAL;
		SUM_actualProdCount : UDINT;
	END_STRUCT;
	OEE_AvailabilityCalcData_type : 	STRUCT 
		runTime : DINT;
		stopTime : DINT;
	END_STRUCT;
	OEE_QualityCalcData_type : 	STRUCT 
		goodProdCount : DINT;
		totalProdCount : DINT;
	END_STRUCT;
	OEE_Average_type : 	STRUCT 
		averageAvailability : REAL;
		averagePerformance : REAL;
		averageQuality : REAL;
	END_STRUCT;
	OEE_timeDetails_type : 	STRUCT 
		internal : DINT; (* Hold PackML *)
		externalUpstream : DINT; (* Suspend PackML *)
		externalDownstream : DINT; (* Suspend PackML *)
		total : DINT;
	END_STRUCT;
END_TYPE
