#ifndef GETTIME_H
#define GETTIME_H
#include <BRSE_RTK.h>
//#include <stdlib.h> 
unsigned long get_DTTime();
unsigned long get_UtcTime();
unsigned long get_difftime();


void   free(void* ptr);
void*  realloc(void* ptr, UDINT size);
void*  calloc(UDINT nbrElem ,UDINT size);
void*  malloc(UDINT size);
#endif // GETTIME_H

