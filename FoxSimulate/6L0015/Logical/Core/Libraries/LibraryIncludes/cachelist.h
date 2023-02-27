/*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*\
| CacheList.h : definitions for list manipulations                                                               |
+————————————————————————————————————————————————————————————————————————————————————————————————————————————————+
| Version 1.0 NS20040206 original version                                                                        |
\*——————————————————————————————————————————————————————————————————————————————————————————————————————————————*/

#ifndef CacheListHeader
#define CacheListHeader

/*———[ Includes ]———————————————————————————————————————————————————————————————————————————————————————————————*/

#include <bur/plctypes.h>
#include "cache_c.h"

/*———[ Methods ]————————————————————————————————————————————————————————————————————————————————————————————————*/

void CacheMirrorListRemove( CacheEssentialPtr_Type ce, CacheListPtr_Type href, USINT idx );
void CacheMirrorListAppend( CacheEssentialPtr_Type ce, CacheListPtr_Type href, USINT idx );

#endif


