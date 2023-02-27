PROGRAM _INIT

END_PROGRAM
PROGRAM _CYCLIC
	//
	// Interface for reading time globally
	// Get system time
	//
	RTime(enable := TRUE);
	//
	// Split time
	//
	g_Core.Services.Time.Runtime.Date_Time := RTime.DT1;
	DT_TO_DTStructure(RTime.DT1, ADR(g_Core.Services.Time.Runtime.Split));
	//
	// Distribute Milli second from power on.
	//
	g_Core.Services.Time.Runtime.MilliSeconds := TIME_TO_UDINT( clock_ms());
	g_Core.Services.Time.Runtime.Seconds		:= g_Core.Services.Time.Runtime.MilliSeconds / 1000;
	
	// Year
	itoa(g_Core.Services.Time.Runtime.Split.year, ADR(tmpString));
	strcpy(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR('-'));
	// Month
	itoa(g_Core.Services.Time.Runtime.Split.month, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.month < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR('-'));
	// Day
	itoa(g_Core.Services.Time.Runtime.Split.day, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.day < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR('T'));
	// Hour
	itoa(g_Core.Services.Time.Runtime.Split.hour, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.hour < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR(':'));
	// Minute
	itoa(g_Core.Services.Time.Runtime.Split.minute, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.minute < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR(':'));
	// Second
	itoa(g_Core.Services.Time.Runtime.Split.second, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.second < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	strcat(ADR(timeString), ADR('.'));
	// MilliSecond
	itoa(g_Core.Services.Time.Runtime.Split.millisec, ADR(tmpString));
	IF (g_Core.Services.Time.Runtime.Split.millisec < 100) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	IF (g_Core.Services.Time.Runtime.Split.millisec < 10) THEN
		strcat(ADR(timeString), ADR('0'));
	END_IF
	strcat(ADR(timeString), ADR(tmpString));
	IF (localTimeDifference = 0) THEN
		strcat(ADR(timeString), ADR('Z'));
	ELSIF (localTimeDifference > 0) THEN
		strcat(ADR(timeString), ADR('+'));
		convNumber := localTimeDifference - (localTimeDifference MOD 3600);
		convNumber := convNumber / 3600;
		itoa(convNumber, ADR(tmpString));
		strcat(ADR(timeString), ADR(tmpString));
		strcat(ADR(timeString), ADR(':'));
		IF (localTimeDifference MOD 3600) <> 0 THEN
			convNumber := (localTimeDifference MOD 3600) / 60;
			itoa(convNumber, ADR(tmpString));
			IF (convNumber < 10) THEN
				strcat(ADR(timeString), ADR('0'));
			END_IF
			strcat(ADR(timeString), ADR(tmpString));
		ELSE
			strcat(ADR(timeString), ADR('00'));
		END_IF
	ELSE
		strcat(ADR(timeString), ADR('-'));
		convNumber := localTimeDifference - (localTimeDifference MOD 3600);
		convNumber := convNumber / -3600;
		itoa(convNumber, ADR(tmpString));
		strcat(ADR(timeString), ADR(tmpString));
		strcat(ADR(timeString), ADR(':'));
		IF (localTimeDifference MOD 3600) <> 0 THEN
			convNumber := (localTimeDifference MOD 3600) / -60;
			itoa(convNumber, ADR(tmpString));
			IF (convNumber < 10) THEN
				strcat(ADR(timeString), ADR('0'));
			END_IF
			strcat(ADR(timeString), ADR(tmpString));
		ELSE
			strcat(ADR(timeString), ADR('00'));
		END_IF
	END_IF

	g_Core.Services.Time.Runtime.ISO := timeString;
	
END_PROGRAM
