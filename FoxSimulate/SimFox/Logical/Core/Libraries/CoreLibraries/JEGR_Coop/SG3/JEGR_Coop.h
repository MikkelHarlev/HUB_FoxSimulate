/* Automation Studio generated header file */
/* Do not edit ! */
/* JEGR_Coop  */

#ifndef _JEGR_COOP_
#define _JEGR_COOP_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct PassWord_Type
{	unsigned long Code;
	plcstring String[5];
} PassWord_Type;

typedef struct MachinePermInfo_Type
{	unsigned char Byte[17];
} MachinePermInfo_Type;

typedef struct Scroll
{
	/* VAR_INPUT (analog) */
	unsigned short DelayScroll;
	unsigned short DelayRepeat;
	unsigned long pTimeReference;
	/* VAR (analog) */
	unsigned char State;
	unsigned long StartTime;
	unsigned long* TimeReference;
	/* VAR_INPUT (digital) */
	plcbit In;
	/* VAR_OUTPUT (digital) */
	plcbit Out;
	/* VAR (digital) */
	plcbit Init;
} Scroll_typ;

typedef struct DeCode
{
	/* VAR_INPUT (analog) */
	unsigned long PassWordAdr;
	/* VAR (analog) */
	unsigned long* Copy;
	unsigned char (*Pass)[4];
	unsigned long TLong;
	unsigned short (*TWord)[2];
	unsigned char (*TByte)[4];
	signed char b;
	signed char i;
	signed char s;
	/* VAR (digital) */
	plcbit Init;
} DeCode_typ;

typedef struct Encrypt
{
	/* VAR_INPUT (analog) */
	unsigned long PassWordAdr;
	/* VAR (analog) */
	unsigned char (*Copy)[4];
	unsigned char Pass[4];
	unsigned long* TLong;
	unsigned short (*TWord)[2];
	unsigned char (*TByte)[4];
	signed char b;
	signed char i;
	signed char s;
	/* VAR (digital) */
	plcbit Init;
} Encrypt_typ;

typedef struct MachineInfo
{
	/* VAR_INPUT (analog) */
	unsigned char Counts;
	unsigned short State;
	unsigned long pInfoMemory;
	unsigned long pInfoCFCard;
	/* VAR_OUTPUT (analog) */
	unsigned long PowerOnHours;
	unsigned long OperatingHours;
	unsigned long ProductionCounts;
	unsigned short ProductionCountsSmall;
	unsigned short StatusCode;
	plcstring StatusString[33];
	/* VAR (analog) */
	unsigned char SumPanel;
	unsigned char SumCF;
	unsigned char Sum;
	unsigned char Size;
	unsigned char Cnt;
	unsigned long* TempUdint;
	unsigned short* TempUint;
	struct MachinePermInfo_Type* InfoMemory;
	struct MachinePermInfo_Type* InfoCFCard;
	struct TON_10ms TON_10ms_0;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit Running;
	/* VAR_OUTPUT (digital) */
	plcbit FileSave;
	/* VAR (digital) */
	plcbit InitDone;
	plcbit Check;
	plcbit Restart;
} MachineInfo_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void Scroll(struct Scroll* inst);
_BUR_PUBLIC void DeCode(struct DeCode* inst);
_BUR_PUBLIC void Encrypt(struct Encrypt* inst);
_BUR_PUBLIC void MachineInfo(struct MachineInfo* inst);


#ifdef __cplusplus
};
#endif
#endif /* _JEGR_COOP_ */

