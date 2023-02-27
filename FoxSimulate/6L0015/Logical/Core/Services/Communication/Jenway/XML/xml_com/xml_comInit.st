// Init program
PROGRAM _INIT
g_Core.Services.XMLCom.Runtime.isServerStarted := 0;

strcpy(ADR(XML_PVs_data.ParamModule),ADR('xmsvrcfg'));
//InitAllFlatServers();
//RegisterFlatFunctions( XML_PVs_status, rpc2dCBGet());
InitAllXMLServerAndClients();
RegisterXMLFunctions( XML_PVs_status, rpc2dCBGet());
RegisterJenFunctions(XML_PVs_status, rpc2dCBGet());

g_XMLServerData;
g_XMLClientData;


XML_ServerData[0] := 'g_XMLServerData[0]';
XML_ClientData[0] := 'g_XMLClientData[0]';
XML_ServerData[1] := 'g_XMLServerData[1]';
XML_ClientData[1] := 'g_XMLClientData[1]';
XML_ServerData[2] := 'g_XMLServerData[2]';
XML_ClientData[2] := 'g_XMLClientData[2]';
XML_ServerData[3] := 'g_XMLServerData[3]';
XML_ClientData[3] := 'g_XMLClientData[3]';
//------------------------------------------

// Ip Min/max 
IP_Min[0]:=	172;
IP_Min[1]:=	16;
IP_Min[2]:=	21;
IP_Min2XML := 0;
IP_Min[3]:=	1;		// 0 is not allowed

IP_Max[0]:=	172;
IP_Max[1]:=	16;
IP_Max[2]:=	30;
IP_Max2XML := 254;
IP_Max[3]:=	254;	// 255 is broadcast and so it's not allowed 

// get rid of warning
XML_Connection;
IpInvalid;
No;
FlatText;
XML_ServerData;
XML_ClientData;
count;
XMLServerComInfo;
XMLClientComInfo;
ConfState;
FlatClient;
InitDone;
Save_And_Restart;
Cnt ;
FlatServer;
IP_Min;
IP_Max;
TON_AlarmCheck;
FileSave_status;
EthAddressBuffer;
EthGenUDINT;
CountByte;
ComState;
FlatId;
TON_CommCheck;
RIPMax;
RIPMin;
IP_Min2XML;
IP_Max2XML;
connections;
Reboot_Required;

END_PROGRAM