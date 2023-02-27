(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: MetriconSerial
 * File: MetriconSerial.typ
 * Author: jspernil
 * Created: May 06, 2010
 ********************************************************************
 * Local data types of program MetriconSerial
 ********************************************************************)

TYPE
	Diagnostics_Counter_Type : 	STRUCT 
		Request : UINT;
		DataRecieved : UINT;
		HangerAway : UINT;
		S2Recieved : UINT;
		s1Sent : UINT;
		s2Sent : UINT;
		RxError : UINT;
		TxError : UINT;
		TotalResend : UINT;
		Resend : UINT;
	END_STRUCT;
END_TYPE
