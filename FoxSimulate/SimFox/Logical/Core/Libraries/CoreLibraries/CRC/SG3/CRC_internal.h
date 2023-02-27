/* Automation Studio generated header file */
/* Do not edit ! */
/* CRC 4.00.0 */

#ifndef _CRC_INTERNAL_
#define _CRC_INTERNAL_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _CRC_VERSION
#define _CRC_VERSION 4.00.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif



/* Prototyping of functions and function blocks */
_BUR_PUBLIC plcbit CheckCRC16(unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned short GetCRC16(unsigned short crc, unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned short SetCRC16(unsigned char* buffer, unsigned long size);
_BUR_PUBLIC plcbit CheckCRCbg16(unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned short SetCRCbg16(unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned short GetCRCbg16(unsigned short crc, unsigned char* buffer, unsigned long size);
_BUR_PUBLIC plcbit CheckCRC32(unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned long GetCRC32(unsigned long crc, unsigned char* buffer, unsigned long size);
_BUR_PUBLIC unsigned long SetCRC32(unsigned char* buffer, unsigned long size);


#ifdef __cplusplus
};
#endif
#endif /* _CRC_INTERNAL_ */

