/****************************************************************************
*                                                                           *
*  $Workfile:: Packed.h                                                    $*
*  Titel    :  Textersatz fuer Compiler "pack" Anweisungen                  *
*  Version  :  V 1.00                                                       *
*  $Revision:: 4                                                           $*
*  $Date:: 23.11.01 13:58                                                  $*
*                                                                           *
*  BESCHREIBUNG:                                                            *
*  -------------                                                            *
*  Die unterschiedlichen Compiler benoetigen unterschiedliche Anweisungen   *
*  um das Strukturen gepackt anzulegen.                                     *
*                                                                           *
******************************COPYRIGHT (C)**********************************
*     THIS SOFTWARE IS THE PROPERTY OF B&R AUSTRIA: ALL RIGHTS RESERVED.    *
*     NO PART OF THIS SOFTWARE MAY BE USED OR COPIED IN ANY WAY WITHOUT     *
*              THE PRIOR WRITTEN PERMISSION OF B&R AUSTRIA.                 *
*****************************************************************************
*                                                                           *
*  Projekt  : Automation Runtime    										*
*  Datum    : 15-11-1999													*
*  Autor    : Thomas Wuernschimmel                      					*
*                                                                           *
*****************************************************************************
*                                                                           *
*  AENDERUNGEN:                                                             *
*  ------------                                                             *
*                                                                           *
*  Version  Datum       Aenderungsbeschreibung und Markierung               *
*                                                                           *
****************************************************************************/

#ifndef _PACKED_H_
#define _PACKED_H_

#if __GNUC__ 
 /* PACKED-definition for structure-member with GNU-Compiler */
 #define PACKED __attribute__((packed))
#else
 /* empty definition for other Compilers */
 #define PACKED 
#endif

#endif  /* ! _PACKED_H_ */
