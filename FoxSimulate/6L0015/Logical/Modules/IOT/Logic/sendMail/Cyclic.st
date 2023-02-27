
PROGRAM _CYCLIC
	
	IF GO THEN	
		SmtpSend_0(enable := TRUE , pHost := ADR('smtp.sendgrid.net'), pUser := ADR('apikey'), pPassword := ADR('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'), pSender := ADR(sender), pReceiver := ADR(receiver), pSubject := ADR(subject), pText := ADR(body) , pDomain := ADR('jensen.group.com'), timeout := 10, port := 25);
		IF SmtpSend_0.status = 0 THEN
			SmtpSend_0.enable := FALSE;
			SmtpSend_0();
			GO := FALSE;
			counts := counts + 1;
		END_IF
	END_IF
	types;
	values;
END_PROGRAM
