
PROGRAM _CYCLIC
	
		(* Update Logfile *) 
	IF Update > (200) THEN
		Update := 0;
		Store  := 1;
	END_IF;

	IF (Store = 1) THEN
		LogStore_0(enable := 1, ident := LogInit_0.ident);
		IF (LogStore_0.status <> 65535) THEN
			Store := 0;
		END_IF;
	END_IF;

	IF Store = 0 THEN
		Update := Update + 1;
	END_IF
	
	
	IF (NOT g_HCfg.IOT.isEnabled) OR isSimulated THEN
		RETURN;
	END_IF
	
	IF (test) THEN
		test := 0;
		isDecrypt := AESDecrypt();
	END_IF

	CASE IOTConnectStep OF 
		
		0: // Setup IOT connection detials.
			IF g_Core.System.Runtime.isInitDone THEN
				// Kick start the Paho client.
				IF (strlen(ADR(g_HCfg.IOT.host)) > 0 AND strlen(ADR(g_HCfg.IOT.key)) > 0 AND strlen(ADR(g_HCfg.IOT.deviceID)) > 0 ) THEN
					gLoginInfo.host 		:= g_HCfg.IOT.host;
					gLoginInfo.primarykey 	:= g_HCfg.IOT.key;
					gLoginInfo.device 		:= g_HCfg.IOT.deviceID;
					gLoginInfo.isEnabled	:= g_HCfg.IOT.isEnabled;
					// Prep username and for SAS Token generation.
					prepLoginInfo(ADR(gLoginInfo));
					// Generate SAS Token and set password.
					generateSASToken(ADR(gLoginInfo.SASToken),ADR(gLoginInfo.primarykey), ADR(gLoginInfo.SASresource), 86400);
					IOTConnectStep := 1;
				END_IF
				
			END_IF
		
		1: // Check if we are connected.

			IotMqttParameters.ClientID                  := gLoginInfo.device;
			IotMqttParameters.ServerUri 				:= gLoginInfo.host;
			
			//PahoClient_0.ServerURI                    := loginInfo.host;
			IotMqttParameters.Password                 	:= gLoginInfo.SASToken;
			IotMqttParameters.UserName                 	:= gLoginInfo.user;
			
			//			Check is connection timeout is set. 
			//			IF (g_MCfg.IOT.connectTimeoutInSeconds = 0) THEN
			//				g_MCfg.IOT.connectTimeoutInSeconds := 10;
			//			END_IF
			//			PahoClient_0.Options.ConnectTimeout           	:= g_MCfg.IOT.connectTimeoutInSeconds;
			//			
			//			//Check is reconnect time is set.
			//			IF (g_MCfg.IOT.reconnectIntervalInSeconds = 0) THEN
			//				g_MCfg.IOT.reconnectIntervalInSeconds := 60;
			//			END_IF
			//			PahoClient_0.Options.ReconnectInterval         	:= g_MCfg.IOT.reconnectIntervalInSeconds;
			
			IotMqttParameters.ConnectionType			:= IotMqtt_TCP;
			IotMqttParameters.Port						:= 8883;
			IotMqttParameters.CleanSession				:= FALSE;
			IotMqttParameters.KeepAliveInterval			:= T#30s;
			IotMqttParameters.AutomaticReconnect		:= TRUE;

			IotMqttParameters.TLS.UseTLS				:= TRUE;
			IotMqttParameters.TLS.CA					:= ADR('//IOT/ca.cer');
			IotMqttParameters.TLS.EnableServerCertAuth	:= TRUE;
			//IotMqttParameters.TLS.EnabledCipherSuites	:= ADR('ECDHE-RSA-AES128-GCM-SHA256');
			
			IotMqttClient_0.Enable			:= TRUE;
			IotMqttClient_0.Connect 		:= TRUE;
			IotMqttClient_0.IotMqttLink 	:= ADR(IotMqttLink);
			IotMqttClient_0.Parameters		:= IotMqttParameters;	
			
			// Initalize
			IotMqttClient_0();
			
			gIOTMQTTClientIdent := IotMqttClient_0.IotMqttLink;
			IOTConnectStep := 2;
			connectTry := connectTry + 1;
			
			SubscribeTopic := 'devices/';
			strcat(ADR(SubscribeTopic), ADR(IotMqttParameters.ClientID));
			strcat(ADR(SubscribeTopic), ADR('/messages/devicebound/#'));

			IotMqttSubscribe_0.Enable := TRUE;
			IotMqttSubscribe_0.IotMqttLink			:= IotMqttClient_0.IotMqttLink; 
			IotMqttSubscribe_0.Topic				:= ADR(SubscribeTopic);
			IotMqttSubscribe_0.SubscriptionQoS		:= IotMqtt_QoS1;
			IotMqttSubscribe_0.RecievedTopic		:= ADR(ReceivedTopic); 
			IotMqttSubscribe_0.RecievedTopicSize	:= SIZEOF(ReceivedTopic);
			IotMqttSubscribe_0.QueueSize 			:= 50;
			IotMqttSubscribe_0.Buffer				:= ADR(ReceiveBuffer); 
			IotMqttSubscribe_0.BufferSize	 		:= SIZEOF(ReceiveBuffer);
			
			SubscribeTopic1 := '$$iothub/twin/res/#';
			IotMqttSubscribe_1.Enable := TRUE;
			IotMqttSubscribe_1.IotMqttLink			:= IotMqttClient_0.IotMqttLink; 
			IotMqttSubscribe_1.Topic				:= ADR(SubscribeTopic1);
			IotMqttSubscribe_1.SubscriptionQoS		:= IotMqtt_QoS1;
			IotMqttSubscribe_1.RecievedTopic		:= ADR(ReceivedTopic1); 
			IotMqttSubscribe_1.RecievedTopicSize	:= SIZEOF(ReceivedTopic1);
			IotMqttSubscribe_1.QueueSize 			:= 50;
			IotMqttSubscribe_1.Buffer				:= ADR(ReceiveBuffer1); 
			IotMqttSubscribe_1.BufferSize	 		:= SIZEOF(ReceiveBuffer1);
			
			SubscribeTopic2 := '$$iothub/methods/POST/#';
			IotMqttSubscribe_2.Enable := TRUE;
			IotMqttSubscribe_2.IotMqttLink			:= IotMqttClient_0.IotMqttLink; 
			IotMqttSubscribe_2.Topic				:= ADR(SubscribeTopic2);
			IotMqttSubscribe_2.SubscriptionQoS		:= IotMqtt_QoS1;
			IotMqttSubscribe_2.RecievedTopic		:= ADR(ReceivedTopic2); 
			IotMqttSubscribe_2.RecievedTopicSize	:= SIZEOF(ReceivedTopic2);
			IotMqttSubscribe_2.QueueSize 			:= 50;
			IotMqttSubscribe_2.Buffer				:= ADR(ReceiveBuffer2); 
			IotMqttSubscribe_2.BufferSize	 		:= SIZEOF(ReceiveBuffer2);
		
		2:
			IotMqttClient_0();
			IotMqttSubscribe_0();	
			IotMqttSubscribe_1();
			IotMqttSubscribe_2();
			
			gLoginInfo.isConnected := IotMqttClient_0.Connected;
								
			TOF_10ms_reConnect.IN := NOT gLoginInfo.isConnected;
			TOF_10ms_reConnect();
			
			IF (TOF_10ms_reConnect.Q) THEN
				IOTConnectStep := 3;
				TOF_10ms_reConnect.IN := FALSE;
				TOF_10ms_reConnect();
			END_IF
		
		3:
			IotMqttClient_0.Enable := FALSE;
			IotMqttClient_0();
			IF (NOT IotMqttClient_0.Active) THEN
				// Reconnect and update token.
				IOTConnectStep := 0;
			END_IF
		4:
			;
	END_CASE

	
	//Telemetry psuher below, reads the log and push it to the cloud.
	CASE IOTStep OF 
		
		0: // Start reading out buffer to publish.
			IF LogInit_0.status = 0 AND LogInit_0.ident > 0 AND IotMqttClient_0.Connected THEN
					
				TOF_10ms_Sleep.IN := FALSE;
				TOF_10ms_Sleep();
					
				IF NOT(TOF_10ms_Sleep.Q) THEN
						
					
					//piggy back on the delay
					IF EDGEPOS(IotMqttClient_0.Connected) THEN
							
						//					if (!isSubscribed)
						//					{ // Subscribe
						//						// Cloud to device messages.
						//						MQTTClient_subscribe(client, TOPICSUBSCRIBE, 0);
						//						// Method calls.
						//						MQTTClient_subscribe(client, "$iothub/methods/POST/#", 0); 
						//						// Live updates?
						//						MQTTClient_subscribe(client, "$iothub/twin/PATCH/properties/desired/#", 0);
						//						// Receive twin properties.
						//						MQTTClient_subscribe(client, "$iothub/twin/res/#", 0);
						//						// Send empty message to topic '$$iothub/twin/GET/?$rid=1' with unique rid, answer will come back with same rid, $iothub/twin/res/{status}/?$rid={request id}
						//						//Status	Description
						//						//200	Success
						//						//429	Too many requests (throttled), as per IoT Hub throttling
						//						//5**	Server errors	
						//						isSubscribed = 1;
						
						
					
						
						
						//							PahoSub_1.TopicName := '$$iothub/twin/res/#';
						//							PahoSub_1.Enable := TRUE;
						//							PahoSub_1.DataAddress := ADR(MQTTSubMethodCall1);
						//							PahoSub_1.DataSize := SIZEOF(MQTTSubMethodCall1);
						
			
					END_IF

					// First we need to find a new line
					LogRead_0.adrReadData 		:= ADR(IOTLog);
					LogRead_0.sizeofReadData 	:= SIZEOF(IOTLog);
					LogRead_0.startFirstEntry 	:= TRUE;
					LogRead_0();
					IF LogRead_0.status <> 65535 THEN
						IF LogRead_0.entries_read > 0 THEN
							// Has Read a line
							LogRead_0.startFirstEntry	:= FALSE;
							IOTStep						:= 1;
						ELSE
							// Has not read a line. No Line avalible
							// We need to sleep for 1 sec
							TOF_10ms_Sleep.IN := TRUE;
							TOF_10ms_Sleep();
						END_IF
					END_IF
				END_IF
			END_IF
			
		1:
			CASE IOTLog.publish.type OF
				
				1:	// Type 1 - telemetry - only one at the momement
					MQTTTopic		:= 'devices/';
					strcat(ADR(MQTTTopic),ADR(IotMqttParameters.ClientID));
					strcat(ADR(MQTTTopic),ADR('/messages/events/'));
					msgLengh := FIND(IOTLog.publish.message, '} }  ');
					messageSendCount := messageSendCount + 1;
					IotMqttPublish_0.Enable			:= TRUE;
					IotMqttPublish_0.IotMqttLink	:= IotMqttClient_0.IotMqttLink;
					IotMqttPublish_0.Topic			:= ADR(MQTTTopic);
					IotMqttPublish_0.QoS			:= IotMqtt_QoS1;
					IotMqttPublish_0.Buffer			:= ADR(IOTLog.publish.message);
					IotMqttPublish_0.BufferLength	:= msgLengh+3;
					IotMqttPublish_0.Retained		:= FALSE;
					IotMqttPublish_0.Send			:= TRUE;
					IotMqttPublish_0();
					
				2: // Type 2, update Twin data.
					MQTTTopic		:= '$$iothub/twin/PATCH/properties/reported/?$$rid=';
					rid := rid + 1;
					ftoa((rid ), ADR(tempStr));
					strcat(ADR(MQTTTopic), ADR(tempStr));
					IotMqttPublish_0.Enable			:= TRUE;
					IotMqttPublish_0.IotMqttLink	:= IotMqttClient_0.IotMqttLink;
					IotMqttPublish_0.Topic			:= ADR(MQTTTopic);
					IotMqttPublish_0.QoS			:= IotMqtt_QoS1;
					IotMqttPublish_0.Buffer			:= ADR(IOTLog.publish.message);
					IotMqttPublish_0.BufferLength	:= strlen(ADR(IOTLog.publish.message));
					IotMqttPublish_0.Retained		:= FALSE;
					IotMqttPublish_0.Send			:= TRUE;
					IotMqttPublish_0();
			END_CASE
			
			IOTStep := 2;	
			
		2:
			// Check if message has been sent.
			IotMqttPublish_0();
			IF IotMqttPublish_0.Done THEN
				IotMqttPublish_0.Send := FALSE;
				IotMqttPublish_0();
				IOTStep			:= 3;
				lastEventSent	:= g_Core.Services.Time.Runtime.Date_Time;
			END_IF
		3:
			LogSetLineRead_0();
			IF LogSetLineRead_0.status = 0 THEN
				IOTStep := 0;
			END_IF
	END_CASE

END_PROGRAM
