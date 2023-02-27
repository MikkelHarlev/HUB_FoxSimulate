(*This Datatype should cover Old jenway, old futurail and the new Jensen Intercom*)

TYPE
	Ipcfg_System_Type : 	STRUCT 
		IPAddressString : STRING[15];
		IPDefaultGatewayString : STRING[15];
	END_STRUCT;
	Ipcfg_Task_HMI_Type : 	STRUCT 
		Node : USINT;
		PingBar : USINT;
		PingColour : USINT;
		IPAddress : ARRAY[0..3] OF USINT;
		IPSubnetMask : ARRAY[0..3] OF USINT;
		IPDefaultGateway : ARRAY[0..3] OF USINT;
		IPAddressPing : ARRAY[0..3] OF USINT;
	END_STRUCT;
	Ipcfg_Task_Plc_Type : 	STRUCT 
		IPAddressString : STRING[15];
		IPSubnetMaskString : STRING[15];
		IPDefaultGatewayString : STRING[15];
		IPAddressVal : UDINT;
		IPSubnetMaskVal : UDINT;
		IPDefaultGatewayVal : UDINT;
	END_STRUCT;
	Ipcfg_Task_Range_Type : 	STRUCT 
		IPAddressMinString : STRING[15];
		IPAddressMaxString : STRING[15];
		IPSubnetMaskString : STRING[15];
		IPDefaultGatewayString : STRING[15];
		IPAddressMinVal : UDINT;
		IPAddressMaxVal : UDINT;
		IPDefaultGatewayMinVal : UDINT;
		IPDefaultGatewayMaxVal : UDINT;
	END_STRUCT;
	Ipcfg_Task_Type : 	STRUCT 
		ButtonSetIP : USINT;
		ButtonTestIP : USINT;
		Range : Ipcfg_Task_Range_Type;
		Plc : Ipcfg_Task_Plc_Type;
		HMI : Ipcfg_Task_HMI_Type;
		Change : Ipcfg_System_Type;
		State : USINT;
		ChangeStatus : Ipcfg_Task_Enum := CHANGENOTHING;
		ErrorIPChange : USINT;
		ErrorDefaultGatewayChange : USINT;
	END_STRUCT;
	Ipcfg_Task_Enum : 
		(
		CHANGEGOOD,
		CHANGEWRONG,
		CHANGEILLEGAL,
		CHANGEBUSY,
		CHANGEINIT,
		CHANGENOTHING
		);
END_TYPE
