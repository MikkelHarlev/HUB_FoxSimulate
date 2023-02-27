
TYPE
	safetyIO_typ : 	STRUCT  (* SIGNALS FROM SAFETY CONTROLLER *)
		isRunning : BOOL;
		emergencyRelay1OK : BOOL;
		emergencyRelay2OK : BOOL;
		generalError : BOOL;
		emergencyError : BOOL;
		emergencyStatus : BOOL;
		extEmergencyError : BOOL;
		extEmergencyStatus : BOOL;
		interlockError : ARRAY[1..21]OF BOOL;
		interlockStatus : ARRAY[1..21]OF BOOL;
		contactorError : ARRAY[1..2]OF BOOL;
		resetButton : BOOL;
		errorCode : INT; (* SIGNALS TO SAFETY CONTROLLER *)
		resetSafetyErrors : BOOL;
	END_STRUCT;
END_TYPE
