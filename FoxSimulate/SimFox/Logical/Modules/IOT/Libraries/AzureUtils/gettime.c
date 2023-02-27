#include "gettime.h"
#include <AsIecCon.h>
#include <AsTime.h>


// Works only for hardware with clock
unsigned long get_UtcTime()
{
	UtcDTGetTime_typ time;
	time.enable = 1;
	UtcDTGetTime(&time);
	return (time.DT1);
}

unsigned long get_DTTime()
{
	DTGetTime_typ time;
	time.enable = 1;
	DTGetTime(&time);
	return (time.DT1);
}

// Works only for hardware with clock
unsigned long get_difftime()
{
	UtcDTGetTime_typ time;
	time.enable = 1;
	UtcDTGetTime(&time);
	return (time.DT1);
}


void*  malloc(UDINT size)
{
	return (void*)BRSE_RTK_malloc((UDINT)size);
}

void*  calloc(UDINT nbrElem ,UDINT size)
{
	UDINT addr;
	addr = BRSE_RTK_malloc(nbrElem * (UDINT)size);
	if (addr) memset(addr, 0, size);
	return (void*)addr;
}

void*  realloc(void* ptr, UDINT size)
{
	return (void*)BRSE_RTK_realloc((UDINT) ptr, (UDINT)size);
}

void free(void* ptr)
{
	if (ptr == 0)
	{
		return;
	}
	BRSE_RTK_free((UDINT)ptr);
}

