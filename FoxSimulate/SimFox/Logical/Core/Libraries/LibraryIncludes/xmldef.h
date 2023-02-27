/*
Copyright (c) 1998, 1999 Thai Open Source Software Center Ltd
See the file copying.txt for copying permission.
*/
#ifndef XML_DEF
#define XML_DEF 1

#ifndef BR_AR
#define BR_AR
#endif

#ifdef BR_AR
#define atoi br_atoi
#define atof br_atof
#include <AsString.h> 
#include <string.h>
#include <stddef.h>
#undef atoi
#undef atof
#define atoi br_atoi
#define atof br_atof
#else
#include <string.h>
#endif

#ifdef XML_WINLIB

#define WIN32_LEAN_AND_MEAN
#define STRICT
#include <windows.h>

#define malloc(x) HeapAlloc(GetProcessHeap(), 0, (x))
#define calloc(x, y) HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, (x)*(y))
#define free(x) HeapFree(GetProcessHeap(), 0, (x))
#define realloc(x, y) HeapReAlloc(GetProcessHeap(), 0, x, y)
#define abort() /* as nothing */

#else /* not XML_WINLIB */

#ifdef BR_AR
/*#include <stdlib.h>*/
#define atoi br_atoi
#define atof br_atof
#include <AsString.h> 
#include <string.h>
#undef atoi
#undef atof
#define atoi br_atoi
#define atof br_atof
#else
/*#include <stdlib.h>*/
#endif

#endif /* not XML_WINLIB */

/* This file can be used for any definitions needed in
particular environments. */

/* Mozilla specific defines */

#ifdef MOZILLA_CLIENT

#include "nspr.h"
#define malloc(x) PR_Malloc((size_t)(x))
#define realloc(x, y) PR_Realloc((x), (size_t)(y))
#define calloc(x, y) PR_Calloc((x),(y))
#define free(x) PR_Free(x)
#if PR_BYTES_PER_INT != 4
#define int int32
#endif

/* Enable Unicode string processing in expat. */
#ifndef XML_UNICODE
#define XML_UNICODE
#endif

/* Enable external parameter entity parsing in expat */
#ifndef XML_DTD
#define XML_DTD 1
#endif

#endif /* MOZILLA_CLIENT */

#ifdef BR_AR
/*#if !(size_t)
#error redefine size_t
typedef long unsigned int size_t;
#endif*/
#define __clib__incl_str AsString.h
#define __clib__incl_mem sys_lib.h
#define abort __brabort
void __brabort( void );

void* memmove( void*, const void*, size_t );

/*#define malloc( size)	br_pool_malloc( mm, size )*/
#define malloc( size)	br_pool_malloc( 0, size )
/*#define malloc( size ) br_malloc( size )*/
#define free( ptr ) 	br_pool_free( mm, ptr )
#define calloc( type, elem )	br_pool_calloc( mm, type, elem )
#define realloc( old, s ) br_pool_realloc( mm, old, s )

/*#ifdef BR_REDEFINE
#define free br_free
#define realloc br_realloc
#define calloc br_calloc
#define malloc br_malloc
	#define memcpy br_memcpy
#endif*/

void  br_pool_free( void*, void* );
void* br_pool_realloc( void*, void*, size_t);
void* br_pool_calloc( void*, size_t, size_t );
void* br_pool_malloc( void*, size_t );

/*void  free( void* );
void* realloc( void*, size_t);
void* calloc( size_t, size_t );
void* malloc( size_t );*/
void* memcpy( void*, const void*, size_t );

void* br_pool_initialize( size_t ); 
void br_pool_invalidate( void* );
void br_pool_delete( void* );


#define offsetof(TYPE, MEMBER) ((size_t)&((TYPE*)0)->MEMBER)

#endif

#endif /*XML_DEF*/
