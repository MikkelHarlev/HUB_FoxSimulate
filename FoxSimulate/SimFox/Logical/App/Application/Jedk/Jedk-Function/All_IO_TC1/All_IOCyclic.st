(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: All_IO
 * File: All_IOCyclic.st
 * Author: AHO
 * Created: February 22, 2011
 ********************************************************************
 * Implementation of program All_IO
 ********************************************************************)

PROGRAM _CYCLIC
(* IO Declaration in Init part *)

(* Stop this task *)
IF ST_ident(ADR('All_IO_TC1'), 0, ADR(ident)) = 0 THEN
    ST_tmp_suspend(ident);
END_IF;

END_PROGRAM
