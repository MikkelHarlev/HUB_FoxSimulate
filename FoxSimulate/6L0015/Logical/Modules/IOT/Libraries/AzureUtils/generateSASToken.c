#include "AzureUtils.h"
#include "azure_c_shared_utility/sastoken.h"
#include "gettime.h"
#include <LogLib.h>
#include "aes.h"
#include <string.h> // CBC mode, for memset

void IOTLogger(IOTLogger_typ* inst)
{
	UINT i;
	BOOL 	*pVarBOOL;
	UDINT	*pVarUDINT;
	DINT	VarDINT, strLen;
	STRING	valueString[10];
	
	
	if (!inst->initDone)
	{
		inst->initDone = 1;
		strcpy(&inst->toJSON_0.varName, &inst->IOTStructName);
		toJSON(&inst->toJSON_0);
	}
	// Transmogryph to JSON
	
	
	// Add new header here.
	strcpy(&inst->event.publish.message,"{ ");
	// EVENT TYPE
	strcat(&inst->event.publish.message,"\"eventType\":\"");
	strcat(&inst->event.publish.message,&inst->eventType);
	strcat(&inst->event.publish.message,"\","); 
	// VERSION
	strcat(&inst->event.publish.message,"\"version\":\"");
	strcat(&inst->event.publish.message,&inst->version);
	strcat(&inst->event.publish.message,"\","); 
	// TIMESTAMP
	strcat(&inst->event.publish.message,"\"timeStamp\":\"");
	strcat(&inst->event.publish.message,&inst->timeStamp);
	strcat(&inst->event.publish.message,"\","); 
	
	
	strcat(&inst->event.publish.message,"\"payload\":{ ");
	for (i = 0; i < inst->toJSON_0.Length; i++)
	{
		BOOL isSkip = 0;
		
		
	
			
		// Gen value
		switch (inst->toJSON_0.entries.Element[i].Type) 
		{
			// String
			case 9:
				
				// Check if we need to skip this value
				if (strlen(inst->toJSON_0.entries.Element[i].Address) == 0) {
					isSkip = 1;
					break;
				}
				// Gen name
				strcat(&inst->event.publish.message, "\""); 
				strcat(&inst->event.publish.message, &inst->toJSON_0.entries.Element[i].Name);
				strcat(&inst->event.publish.message, "\":");
				
				if (!inst->isString) strcat(&inst->event.publish.message, "\""); 
				strcat(&inst->event.publish.message, inst->toJSON_0.entries.Element[i].Address);
				if (!inst->isString) strcat(&inst->event.publish.message, "\"");
				break;
		
			case 1:	/*	BOOL	*/
				pVarBOOL = (plcbit*)inst->toJSON_0.entries.Element[i].Address;
				VarDINT = (DINT)*pVarBOOL;
				
				
				// Check if we need to skip this value
				if (VarDINT == 0) {
					isSkip = 1;
					break;
				}
				
				// Gen name
				strcat(&inst->event.publish.message, "\""); 
				strcat(&inst->event.publish.message, &inst->toJSON_0.entries.Element[i].Name);
				strcat(&inst->event.publish.message, "\":");
				
				itoa(VarDINT,&valueString);
				
				strcat(&inst->event.publish.message, &valueString);
				
				break;
			
			
			case 7:

				pVarUDINT = (UDINT*)inst->toJSON_0.entries.Element[i].Address;
				VarDINT = (DINT)*pVarUDINT;
				
				// Check if we need to skip this value
				if (VarDINT == 0) {
					isSkip = 1;
					break;
				}
				
				// Gen name
				strcat(&inst->event.publish.message, "\""); 
				strcat(&inst->event.publish.message, &inst->toJSON_0.entries.Element[i].Name);
				strcat(&inst->event.publish.message, "\":");
				
				itoa(VarDINT,&valueString);
				
				strcat(&inst->event.publish.message, &valueString);
				
				break;
		
			default:
				// Catch if we do not know this parameter type.
				// Gen name
				strcat(&inst->event.publish.message, "\""); 
				strcat(&inst->event.publish.message, &inst->toJSON_0.entries.Element[i].Name);
				strcat(&inst->event.publish.message, "\":");
				
				strcat(&inst->event.publish.message, "\"\"");
				break;
		}
			
		// Add seperator
		if ( !isSkip)
		{
			strcat(&inst->event.publish.message, ", ");	
		}
	}
	strLen = strlen(&inst->event.publish.message);
	memset(((UDINT)(&inst->event.publish.message) + strLen - 2),0,2);
	
	strcat(&inst->event.publish.message," } }");
	
	if (inst->adrIOTLogIdent)
	{
		inst->IOTLogWrite.AdrWriteData  = &inst->event;
//		inst->event.publish.timestamp	= get_DTTime();
		inst->IOTLogWrite.enable		= 1;
		inst->IOTLogWrite.ident		    = inst->adrIOTLogIdent;	
		LogWrite(&inst->IOTLogWrite);
		inst->status 					= inst->IOTLogWrite.status;
	}
	return;
}

void IOTLoggerSimple(IOTLoggerSimple_typ* inst)
{
	UINT i;
	BOOL 	*pVarBOOL;
	UDINT	*pVarUDINT;
	DINT	VarDINT;
	STRING	valueString[10];
		
	// Transmogryph to JSON

	// Add new header here.
	strcpy(&inst->event.publish.message,"{ ");
	// EVENT TYPE
	strcat(&inst->event.publish.message,"\"eventType\":\"");
	strcat(&inst->event.publish.message,&inst->eventType);
	strcat(&inst->event.publish.message,"\","); 
	// VERSION
	strcat(&inst->event.publish.message,"\"version\":\"");
	strcat(&inst->event.publish.message,&inst->version);
	strcat(&inst->event.publish.message,"\","); 
	// TIMESTAMP
	strcat(&inst->event.publish.message,"\"timeStamp\":\"");
	strcat(&inst->event.publish.message,&inst->timeStamp);
	strcat(&inst->event.publish.message,"\","); 
	
	
	strcat(&inst->event.publish.message,"\"payload\":{ ");
	
	strcat(&inst->event.publish.message, &inst->json);	

	strcat(&inst->event.publish.message," } }");
	
	if (inst->adrIOTLogIdent)
	{
		inst->IOTLogWrite.AdrWriteData  = &inst->event;
//		inst->event.publish.timestamp	= get_DTTime();
		inst->IOTLogWrite.enable		= 1;
		inst->IOTLogWrite.ident		    = inst->adrIOTLogIdent;	
		LogWrite(&inst->IOTLogWrite);
		inst->status 					= inst->IOTLogWrite.status;
	}
	return;
}

void analyzeStruct(plcstring VarName[80+1], toJSON_typ* inst)
{	/*Local vars*/
	UINT			status_item, Data_Dimensions,Tmp_Data_Dimensions,i, subi;
	UDINT			Data_Type, Data_Len;
	plcstring		Tmp_VarName[80+1],PresentVarName[80+1],TmpElementString[80+1]; /*PresentName = Products. not Products[0]. etc... id datatype is an Array*/			
	USINT			*pChar;
	/*Logic*/
	status_item = PV_ninfo(VarName,&Data_Type, &Data_Len, &Data_Dimensions);
	strcpy(PresentVarName,VarName);
			
	for (i = 0; i < Data_Dimensions; i++)
	{
		status_item = PV_item(VarName, i, inst->entries.Element[inst->Length].Name);
		if (!status_item)
		{
			// Array fix for name
			//strcpy((char*) &inst->entries.Element[inst->Length].parentName ,(char*) parentName);
			
			strcpy((char*) &inst->entries.Element[inst->Length].FullName,(char*) &PresentVarName);
			strcat((char*) &inst->entries.Element[inst->Length].FullName,".");
			strcat((char*) &inst->entries.Element[inst->Length].FullName,inst->entries.Element[inst->Length].Name);
			status_item = PV_ninfo(inst->entries.Element[inst->Length].FullName,&Data_Type, &Data_Len, &Tmp_Data_Dimensions);
			
			if (!status_item)
			{	
				
				if (Data_Type == 0) /*Struct*/ /*Keep searching up the tre*/
				{
					strcpy((char*) &Tmp_VarName,(char*) &inst->entries.Element[inst->Length].FullName);
					analyzeStruct(Tmp_VarName, inst);	
				}
				if (Data_Type == 2) /*Arrays???*/
				{
					strcpy((char*) &TmpElementString,(char*) &inst->entries.Element[inst->Length].FullName);
					
					for (subi = 0; subi < Tmp_Data_Dimensions; subi++)
					{
						strcpy((char*) &Tmp_VarName, (char*) &TmpElementString);
						strcat((char*) &Tmp_VarName,"[");
						itoa(subi, (UDINT) (&Tmp_VarName)+strlen(Tmp_VarName));
						strcat((char*) &Tmp_VarName,"]");
						
						strcpy((char*) &inst->entries.Element[inst->Length].FullName, (char*)&Tmp_VarName);
						
						PV_xgetadr((char*)&inst->entries.Element[inst->Length].FullName, &inst->entries.Element[inst->Length].Address, &Data_Len);
						inst->entries.Element[inst->Length].Type = Data_Type;
						inst->entries.Element[inst->Length].Length = Data_Len;
						pChar = (USINT*) strrchr((char*) &inst->entries.Element[inst->Length].FullName,'.'); pChar++;
						strcpy((char*) &inst->entries.Element[inst->Length].Name, (char*) pChar);
						inst->Length++;
					}
				}
				else if (Data_Type == 15) /*An Array of structs*/
				{
					strcpy((char*) &TmpElementString, (char*) &inst->entries.Element[inst->Length].FullName);
					
					for (subi = 0; subi < Tmp_Data_Dimensions; subi++)
					{
						strcpy((char*) &Tmp_VarName, (char*) &TmpElementString);
						strcat((char*) &Tmp_VarName,"[");
						itoa(subi, (UDINT) (&Tmp_VarName)+strlen(Tmp_VarName));
						strcat((char*) &Tmp_VarName,"]");
						
						strcpy((char*) &inst->entries.Element[inst->Length].parentName, (char*) &inst->entries.Element[inst->Length].Name);
						analyzeStruct(Tmp_VarName, inst); 
					}
				}
				
				else
				{
					inst->entries.Element[inst->Length].Type = Data_Type;
					inst->entries.Element[inst->Length].Length = Data_Len;
					PV_xgetadr((char*)&inst->entries.Element[inst->Length].FullName, &inst->entries.Element[inst->Length].Address, &Data_Len);
					inst->Length++;
				}
			}
			/*Error handling here*/
		}
		/*Error handling here*/
	}
}

void toJSON(toJSON_typ* inst)
{
	analyzeStruct(inst->varName, inst);
}


unsigned char generateSASToken(unsigned long adrResult, unsigned long adrPrivatekey, unsigned long adrUser, unsigned long expiry )
{
	BOOL result;
	STRING_HANDLE strSasToken;
	strSasToken = SASToken_CreateString((char*)adrPrivatekey,(char*)adrUser,NULL,expiry+get_UtcTime());
	if (!SASToken_Validate(strSasToken))
	{
		return 1;
	}
	else
	{
		strcpy(adrResult, STRING_c_str(strSasToken));	
		return 0;
	}
	
	
}


unsigned char AESDecrypt()

{

#if defined(AES256)
	uint8_t key[] = { 0x60, 0x3d, 0xeb, 0x10, 0x15, 0xca, 0x71, 0xbe, 0x2b, 0x73, 0xae, 0xf0, 0x85, 0x7d, 0x77, 0x81,
		0x1f, 0x35, 0x2c, 0x07, 0x3b, 0x61, 0x08, 0xd7, 0x2d, 0x98, 0x10, 0xa3, 0x09, 0x14, 0xdf, 0xf4 };
	uint8_t in[]  = { 0xf5, 0x8c, 0x4c, 0x04, 0xd6, 0xe5, 0xf1, 0xba, 0x77, 0x9e, 0xab, 0xfb, 0x5f, 0x7b, 0xfb, 0xd6,
		0x9c, 0xfc, 0x4e, 0x96, 0x7e, 0xdb, 0x80, 0x8d, 0x67, 0x9f, 0x77, 0x7b, 0xc6, 0x70, 0x2c, 0x7d,
		0x39, 0xf2, 0x33, 0x69, 0xa9, 0xd9, 0xba, 0xcf, 0xa5, 0x30, 0xe2, 0x63, 0x04, 0x23, 0x14, 0x61,
		0xb2, 0xeb, 0x05, 0xe2, 0xc3, 0x9b, 0xe9, 0xfc, 0xda, 0x6c, 0x19, 0x07, 0x8c, 0x6a, 0x9d, 0x1b };
#elif defined(AES192)
	uint8_t key[] = { 0x8e, 0x73, 0xb0, 0xf7, 0xda, 0x0e, 0x64, 0x52, 0xc8, 0x10, 0xf3, 0x2b, 0x80, 0x90, 0x79, 0xe5, 0x62, 0xf8, 0xea, 0xd2, 0x52, 0x2c, 0x6b, 0x7b };
	uint8_t in[]  = { 0x4f, 0x02, 0x1d, 0xb2, 0x43, 0xbc, 0x63, 0x3d, 0x71, 0x78, 0x18, 0x3a, 0x9f, 0xa0, 0x71, 0xe8,
		0xb4, 0xd9, 0xad, 0xa9, 0xad, 0x7d, 0xed, 0xf4, 0xe5, 0xe7, 0x38, 0x76, 0x3f, 0x69, 0x14, 0x5a,
		0x57, 0x1b, 0x24, 0x20, 0x12, 0xfb, 0x7a, 0xe0, 0x7f, 0xa9, 0xba, 0xac, 0x3d, 0xf1, 0x02, 0xe0,
		0x08, 0xb0, 0xe2, 0x79, 0x88, 0x59, 0x88, 0x81, 0xd9, 0x20, 0xa9, 0xe6, 0x4f, 0x56, 0x15, 0xcd };
#elif defined(AES128)
	uint8_t key[] = { 0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c };
	uint8_t in[]  = { 0x76, 0x49, 0xab, 0xac, 0x81, 0x19, 0xb2, 0x46, 0xce, 0xe9, 0x8e, 0x9b, 0x12, 0xe9, 0x19, 0x7d,
		0x50, 0x86, 0xcb, 0x9b, 0x50, 0x72, 0x19, 0xee, 0x95, 0xdb, 0x11, 0x3a, 0x91, 0x76, 0x78, 0xb2,
		0x73, 0xbe, 0xd6, 0xb8, 0xe3, 0xc1, 0x74, 0x3b, 0x71, 0x16, 0xe6, 0x9e, 0x22, 0x22, 0x95, 0x16,
		0x3f, 0xf1, 0xca, 0xa1, 0x68, 0x1f, 0xac, 0x09, 0x12, 0x0e, 0xca, 0x30, 0x75, 0x86, 0xe1, 0xa7 };
#endif
	uint8_t iv[]  = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f };
	uint8_t out[] = { 0x6b, 0xc1, 0xbe, 0xe2, 0x2e, 0x40, 0x9f, 0x96, 0xe9, 0x3d, 0x7e, 0x11, 0x73, 0x93, 0x17, 0x2a,
		0xae, 0x2d, 0x8a, 0x57, 0x1e, 0x03, 0xac, 0x9c, 0x9e, 0xb7, 0x6f, 0xac, 0x45, 0xaf, 0x8e, 0x51,
		0x30, 0xc8, 0x1c, 0x46, 0xa3, 0x5c, 0xe4, 0x11, 0xe5, 0xfb, 0xc1, 0x19, 0x1a, 0x0a, 0x52, 0xef,
		0xf6, 0x9f, 0x24, 0x45, 0xdf, 0x4f, 0x9b, 0x17, 0xad, 0x2b, 0x41, 0x7b, 0xe6, 0x6c, 0x37, 0x10 };
	//  uint8_t buffer[64];
	struct AES_ctx ctx;

	AES_init_ctx_iv(&ctx, key, iv);
	AES_CBC_decrypt_buffer(&ctx, in, 64);

	//printf("CBC decrypt: ");

	if (0 == memcmp((char*) out, (char*) in, 64)) {
		//printf("SUCCESS!\n");
		return(0);
	} else {
		//printf("FAILURE!\n");
		return(1);
	}
}


unsigned char prepLoginInfo(unsigned long adrLoginInfo)
{
	AzureLogin_type *loginInfo = (AzureLogin_type *)adrLoginInfo;
	
	// Generate SAS resource.
	strcpy(&loginInfo->SASresource, &loginInfo->host);
	strcat(&loginInfo->SASresource, "%2Fdevices%2F");
	strcat(&loginInfo->SASresource, &loginInfo->device);
	
	// Generate Azure MQTT username
	strcpy(&loginInfo->user, &loginInfo->host);
	strcat(&loginInfo->user, "/");
	strcat(&loginInfo->user, &loginInfo->device);
	strcat(&loginInfo->user, "/?api-version=2018-06-30");
	
}
