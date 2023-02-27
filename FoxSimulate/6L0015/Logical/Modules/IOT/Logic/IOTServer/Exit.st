

PROGRAM _EXIT
	IF (NOT isSimulated) THEN
		IotMqttClient_0(Enable	:= FALSE);
		IotMqttPublish_0(Enable	:= FALSE);	
		IotMqttSubscribe_0(Enable := FALSE);
		IotMqttSubscribe_1(Enable := FALSE);
	END_IF
END_PROGRAM