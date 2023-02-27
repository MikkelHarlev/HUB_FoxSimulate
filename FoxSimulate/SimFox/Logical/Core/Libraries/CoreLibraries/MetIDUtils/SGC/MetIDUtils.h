/* Automation Studio generated header file */
/* Do not edit ! */
/* MetIDUtils  */

#ifndef _METIDUTILS_
#define _METIDUTILS_
#ifdef __cplusplus
extern "C" 
{
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
/* Datatypes and datatypes of function blocks */
typedef struct HangerIDUtil_Type
{	unsigned long Low;
	unsigned long High;
} HangerIDUtil_Type;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC plcbit DataMakeStr(struct HangerIDUtil_Type* a, signed char* HangerStr);
_BUR_PUBLIC signed short DataSetNull(struct HangerIDUtil_Type* a);
_BUR_PUBLIC plcbit DataIsNull(struct HangerIDUtil_Type* a);
_BUR_PUBLIC plcbit DataEqual(struct HangerIDUtil_Type* a, struct HangerIDUtil_Type* b);
_BUR_PUBLIC plcbit DataMakeIdOfStr(struct HangerIDUtil_Type** binID, unsigned long idstring);


#ifdef __cplusplus
};
#endif
#endif /* _METIDUTILS_ */

