PROGRAM _INIT
(*-----------------------------------------------------------------------------------
	Responsible Person: Peter Hauser

	Project Name: 	JENSEN common HMI Project

	Task Name:		op_pageh.src	INIT PART

	Description: 	This task can be used to manage the page handling in the machine specific operator part
					of the HMI.
					Prepared pages:
					"Machine Main Page" (ID 1) for the connection of the machine specific part to the
					"System Login Page" (ID 98) (last operator page before the system pages).
					"System Login Page" (ID 98) for labeling the buttons and the connection back to the
					"Machine Main Page".

					Additional pages can be inserted by the user.
					For this purpose the page ID, the page specific actions and the connection to other pages
					must be inserted in the case-statement.

					If this task is not used the connection beween the "Machine Main Page" and the
					"System Login Page" and the labeling of the buttons must be done by the machine
					programmer!


	References:  	Interface of the task: OpPageh of op_pageh_type as global variable

	Libraries:		JenPanel	minimum V2.01

	History:
	28.05.2004		V0.00.0			Peter Hauser			created
-----------------------------------------------------------------------------------*)
(*	ReWrite := TRUE;
	StatusSetMenu := SetMenuDirect(g_HMIHandler, PAGE_MACHINE_MAIN_1);*)
g_OperatorCommand.NewFoldProgram 	:= g_Machine.Program;
NAMELENGTH 							:= SIZEOF(g_CustomerArticleName);
MAXVISUALNAMELENGTH					:= 25;
FoldProgramList.MaxFoldPrograms 	:= MAX_NUMBER_OF_CATEGORIES;
//MAX_NUMBER_OF_FOLDPROGRAMS 			:= MAX_NUMBER_OF_CATEGORIES;			(*MTS*)
OldArticleNumber					:= 0;
OldCustomerNumber 					:= 0;


FOR i := 0 TO FoldProgramList.MaxFoldPrograms-1 DO
	itoa(i+1, ADR(FoldProgramList.IdString[i]));
END_FOR
END_PROGRAM

