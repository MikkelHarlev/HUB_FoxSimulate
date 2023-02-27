PROGRAM _INIT
	updateTime := 60;
	isUseDNS := TRUE;
	// simple ring buffer for messages.
	LogInit_0(enable:=1, EntrysLogfile:=1000, sizeLogbuffer:=SIZEOF(IOTLogBuffer), pNameDevice:=ADR('IOT'),
	pNameFile:=ADR('IOTLog.csv'), AdrLogbuffer:=ADR(IOTLogBuffer), pNameWriteData:=ADR('IOTServer:IOTLog'),
	pIndexName:=ADR('IOTServer:IOTLog.Index'));
	
	(* Ident to Logbuffer *)
	IOTLogWrite_0.enable := 1;
	IOTLogWrite_0.ident := LogInit_0.ident;
	IOTLogWrite_0.AdrWriteData := ADR( IOTLog );
	
	LogRead_0.ident := LogInit_0.ident;
	LogRead_0.enable := TRUE;
	
	LogSetLineRead_0.ident := LogInit_0.ident;
	LogSetLineRead_0.enable := TRUE;
	
	gAdrIOTLogIdent := LogInit_0.ident;
	
	// Use a loca instance of the IOTLogge to see if it works.
	IOTLogger_0.adrIOTLogIdent := gAdrIOTLogIdent;
	
	TOF_10ms_Sleep.PT := 500;
	
	TOF_10ms_reConnect.PT := 18000;
	
	logLevel := IOTMQTT_LOG_LEVEL_ERROR;
	
	//Init the Paho MQTT client.
	isSimulated := DiagCpuIsSimulated();
	
	IotMqttConfigParams.UseFile               := TRUE;
	IotMqttConfigParams.LogFileDevice	      := 'IOT';
	IotMqttConfigParams.LogFileName		      := 'IotMqttLog';
	IotMqttConfigParams.AppendTimestamp	      := FALSE;
	IotMqttConfigParams.OverwritteLogs	      := TRUE;
	IotMqttConfigParams.LogLevel		      := logLevel;
	IotMqttConfig(ADR(IotMqttConfigParams));
	
END_PROGRAM