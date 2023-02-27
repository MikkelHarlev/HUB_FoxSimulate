/* Automation Studio generated header file */
/* Do not edit ! */
/* base64 0.01.0 */

#ifndef _BASE64_
#define _BASE64_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _base64_VERSION
#define _base64_VERSION 0.01.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif



/* Prototyping of functions and function blocks */
_BUR_PUBLIC signed short base64Code(signed short op, unsigned char* src, signed short len, unsigned char* dst, signed short dst_size);
_BUR_PUBLIC signed short base64Size(signed short op, unsigned char* src, signed short len);


#ifdef __cplusplus
};
#endif
#endif /* _BASE64_ */

