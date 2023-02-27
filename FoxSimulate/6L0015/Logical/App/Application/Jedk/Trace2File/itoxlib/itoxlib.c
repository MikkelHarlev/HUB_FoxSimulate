/********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Library: Peekaboo
 * File: metaTag.c
 * Author: eg
 * Created: January 17, 2014
 *******************************************************************/

//#include <bur/plctypes.h>

#include "itoxlib.h"
//#include "AsMEM.h"
#include <string.h>

unsigned char itox(unsigned char i, unsigned long adrStr)
{ 
    unsigned char n; 
  	char *s;
	s = (char*) adrStr;
	
    s += 2; 
    *s = '\0'; 
  
    for (n = 2; n != 0; --n) { 
        *--s = "0123456789ABCDEF"[i & 0x0F]; 
        i >>= 4; 
	}
	return 0;
} 
