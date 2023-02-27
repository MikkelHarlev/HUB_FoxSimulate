
PROGRAM _INIT
	// Set file device for storing and reading the alarm history summary.
	fDevice	:= 'statistics';
	
	// Access alarmHandler interface from core.
	pThis ACCESS ADR(g_Core.Services.Alarmhandler);
	
	// Get alarm cache ident, so we can do all magic in this task and not touch the AlarmHandler.
	GetAdr(ADR(adrAlarmCache),ADR('AlarmHandl:AlarmCache'));
	IF (adrAlarmCache > 0) THEN
		AlarmCache ACCESS adrAlarmCache;
	END_IF
	
	// Initial read of data
	ReadAlarmHistoryDataObject := 1;
	// avoid warning
	add;
END_PROGRAM

PROGRAM _CYCLIC
	
	// Sanity checks
	IF (adrAlarmCache = 0) THEN
		RETURN;
	END_IF
	
	// Reset
	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 4) AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_HISTORY_ALARMS AND g_Core.Services.HMIHandler.Runtime.Handler[0].PasswordLevel >= 1 THEN
		isResetAlarmHistorySummary := TRUE;
	END_IF

	// Sort toggle
	//	IF EDGEPOS(g_Core.Services.HMIHandler.Runtime.Handler[0].KeyPressed = 5) AND g_Core.Services.HMIHandler.Runtime.Handler[0].PageControllerID = PAGE_MACHINE_HISTORY_ALARMS THEN
	//		isSort := NOT isSort;
	//	END_IF
	
	// Reset
	IF (isResetAlarmHistorySummary) THEN
		isResetAlarmHistorySummary := FALSE;
		memset(ADR(alarmHistory),0,SIZEOF(alarmHistory));
		Reset_Date	:= DT_TO_UDINT(g_Core.Services.Time.Runtime.Date_Time);
	END_IF
	
	// Lock change in sorting mode, while sorting in progress.
	IF NOT isSorting THEN
		lSortMode := sortMode;
	END_IF

	// Run scans as total alarms in history, to finish running sorting.
	IF isSorting THEN
		isSortingCount := isSortingCount + 1;
		IF isSortingCount > isSortingCountMax THEN
			isSorting := FALSE;
		END_IF
	END_IF

	// Change in sorting mode. Count / Duration.
	IF lSortMode <> oldlSortMode THEN
		oldlSortMode := lSortMode;
		isSortingCount := 0;
		isSortingCountMax := SIZEOF(alarmHistory) / SIZEOF(alarmHistory[0]) - 1;
		isSorting := TRUE;
	END_IF
	
	// Storage
	handleAlarmHistoryObject;
	
	// Collect data.
	// Add time
	IF ((g_Core.Services.Time.Runtime.Seconds <> oldSeconds) OR (oldSeconds = 0)) THEN
		timeToAdd 	:= g_Core.Services.Time.Runtime.Seconds - oldSeconds;
		oldSeconds 	:= g_Core.Services.Time.Runtime.Seconds;
	ELSE
		timeToAdd 	:= 0;
	END_IF
	
	alarmHistory[100].runtimeInSec := alarmHistory[100].runtimeInSec + timeToAdd;

	
	totalTime := 0;
	FOR i := 0 TO SIZEOF(AlarmCache) / SIZEOF(AlarmCache[0]) - 1 DO
		totalTime := totalTime + alarmHistory[i].runtimeInSec;
		alarmID := (AlarmCache[i].GroupID * 1000) + AlarmCache[i].AlarmID;
		// Found active alarm to handle.
		IF (NOT AlarmCache[i].Acknowledged AND alarmID > 0 AND (AlarmCache[i].GroupID <> pThis.Runtime.UserGroupID[0]) AND (AlarmCache[i].GroupID <> pThis.Runtime.UserGroupID[1])) THEN
			FOR x := 0 TO SIZEOF(AlarmCache) / SIZEOF(AlarmCache[0]) - 1 DO
				// Found alarm in history slot, update time.
				IF (alarmHistory[x].ID = alarmID) THEN
					alarmHistory[x].runtimeInSec := alarmHistory[x].runtimeInSec + timeToAdd;
					SecToText(alarmHistory[x].runtimeInSec,ADR(alarmHistory[x].runtimeText),0);
					IF (AlarmCache[i].DateTime > alarmHistory[x].lastSeen) THEN
						alarmHistory[x].events 		:= alarmHistory[x].events + 1;
						alarmHistory[x].lastSeen 	:= AlarmCache[i].DateTime;
					END_IF
					EXIT;
				// Alarm not found in history, add it.
				ELSIF (alarmHistory[x].ID = 0) THEN
					alarmHistory[x].ID 			:= alarmID;
					alarmHistory[x].Index 		:= i;
					MHATestIndex[x] := i;
					alarmHistory[x].DescAscii 	:= AlarmCache[i].DescAscii;
					alarmHistory[x].DescUniCode := AlarmCache[i].DescUniCode;
					EXIT;
				END_IF
			END_FOR
		END_IF
		
		// update ~percentage time for each item in the list.
		IF (totalTimeFinal > 0) THEN
			alarmHistory[i].totalPercentage := REAL_TO_USINT( (UDINT_TO_REAL(alarmHistory[i].runtimeInSec) / UDINT_TO_REAL(totalTimeFinal)) * 100);
		END_IF
		
		// Do simple sorting
		IF (lSortMode = 1) THEN
			IF i < (SIZEOF(alarmHistory) / SIZEOF(alarmHistory[0]))-2 THEN
				// Swap places.
				IF alarmHistory[i+1].runtimeInSec = 0 THEN
					isSortingCountMax := i + 1;
					EXIT;
				ELSIF (alarmHistory[i+1].runtimeInSec > alarmHistory[i].runtimeInSec) AND strlen(ADR(alarmHistory[i+1].DescAscii)) > 1 THEN
					alarmHistoryTmp 	:= alarmHistory[i];
					alarmHistory[i] 	:= alarmHistory[i+1];
					alarmHistory[i+1] 	:= alarmHistoryTmp;
				END_IF
			END_IF
		ELSIF (lSortMode = 2) THEN
			IF i < (SIZEOF(alarmHistory) / SIZEOF(alarmHistory[0]))-2 THEN
				// Swap places.
				IF alarmHistory[i+1].events = 0 THEN
					isSortingCountMax := i + 1;
					EXIT;
				ELSIF (alarmHistory[i+1].events > alarmHistory[i].events) AND strlen(ADR(alarmHistory[i+1].DescAscii)) > 1 THEN
					alarmHistoryTmp 	:= alarmHistory[i];
					alarmHistory[i] 	:= alarmHistory[i+1];
					alarmHistory[i+1] 	:= alarmHistoryTmp; 		
				END_IF
			END_IF
		END_IF	
	END_FOR
	alarmHistory[0].events;

	memset(ADR(HMI), 0, SIZEOF(HMI));
	FOR i := 0 TO MAX_HMI_ALARMS DO
		IF strlen(ADR(alarmHistory[i])) > 0 THEN
			strcpy(ADR(HMI.alarmText[i]), ADR(alarmHistory[i]));
			itoa(alarmHistory[i].runtimeInSec / 60, ADR(HMI.min[i]));
			itoa(alarmHistory[i].runtimeInSec MOD 60, ADR(HMI.sec[i]));
			itoa(alarmHistory[i].events, ADR(HMI.events[i]));
			itoa(alarmHistory[i].totalPercentage, ADR(HMI.totalPercentage[i]));
			ascTIME(UDINT_TO_TIME(alarmHistory[i].runtimeInSec * 1000), ADR(HMI.durationTime[i]), 9);
		END_IF
	END_FOR
	
	ascTIME(UDINT_TO_TIME(alarmHistory[100].runtimeInSec * 1000), ADR(HMI.totalTime), 9);
	// Set time for next scan.
	totalTimeFinal := totalTime;
	totalTimeFinal := totalTime;
	// At interval do...
	historyUpdate_TON(IN := NOT historyUpdate_TON.Q, PT := 1000);
	
	IF (UpdateAlarmHistoryDataObject = 0 AND historyUpdate_TON.Q) THEN
		UpdateAlarmHistoryDataObject := 1;
	END_IF
	
END_PROGRAM

PROGRAM _EXIT
	
	 
END_PROGRAM

