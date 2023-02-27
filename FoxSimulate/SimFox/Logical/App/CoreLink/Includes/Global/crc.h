/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| crc.h : cyclic redundancy checks																			|
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0																									 |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef CRCUtilsHeader
#define CRCUtilsHeader

#include <bur/plc.h>

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

unsigned short SetCRC16( void * buffer, unsigned long size);
unsigned short GetCRC16(unsigned short crc, void * buffer, unsigned long size);
plcbit CheckCRC16( void * buffer, unsigned long size);
unsigned short SetCRCbg16( void * buffer, unsigned long size);
unsigned short GetCRCbg16(unsigned short crc, void * buffer, unsigned long size);
plcbit CheckCRCbg16( void * buffer, unsigned long size);
unsigned long SetCRC32( void * buffer, unsigned long size);
unsigned long GetCRC32(unsigned long crc, void * buffer, unsigned long size);
plcbit CheckCRC32( void * buffer, unsigned long size);

#endif
