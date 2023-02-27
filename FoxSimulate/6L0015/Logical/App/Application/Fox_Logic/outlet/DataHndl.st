(********************************************************************
 * COPYRIGHT -- Microsoft
 ********************************************************************
 * Program: outlet
 * File: DataBuffer.st
 * Author: JENSEN
 * Created: October 30, 2019
 ********************************************************************
 * Implementation of program outlet
 ********************************************************************) 

(* Add a new action to your IEC program or library *)
ACTION DataBuffer: 	(*to keep track of stack data on outlet belt*)
	
	IF  (g_OutletProcess.StackerUnit[1].StackData[0].Count >= 0) THEN
				
		LogEntry(g_MCfg.Trace2File, ADR(T2FD), 8, g_OutletProcess.Common.LogBookFlag,0,'Buffer Jenw StackData');
		g_OutletProcess.JenwayExchange[bufcnt].Stack.BatchId				:= g_OutletProcess.StackerUnit[1].StackData[0].BatchId;		  // changed index from bufcnt to 0 to work with transport only mode MKH
		g_OutletProcess.JenwayExchange[bufcnt].Stack.Count					:= g_OutletProcess.StackerUnit[1].StackData[0].Count;
		g_OutletProcess.JenwayExchange[bufcnt].Stack.Destination			:= g_OutletProcess.StackerUnit[1].StackData[0].Destination; 
		g_OutletProcess.JenwayExchange[bufcnt].Stack.ArticleId				:= g_OutletProcess.StackerUnit[1].StackData[0].ArticleId;
		g_OutletProcess.JenwayExchange[bufcnt].Stack.FoldProgram			:= g_OutletProcess.StackerUnit[1].StackData[0].FoldProgram;
		g_OutletProcess.JenwayExchange[bufcnt].Stack.CustomerId			:= g_OutletProcess.StackerUnit[1].StackData[0].CustomerId;
		g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData			:=	g_OutletProcess.StackerUnit[1].StackData[0].ItemData;
//		FOR ItemIndex := 1 TO g_OutletProcess.JenwayExchange[bufcnt].Stack.Count DO
//			g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData[ItemIndex].GarmentId		:= g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].GarmentId;
//			g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData[ItemIndex].HangerId		:= g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].HangerId;
//			g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData[ItemIndex].ArticleId		:= g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].ArticleId;
//			g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData[ItemIndex].CustomerId 	:= g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].CustomerId;
//			g_OutletProcess.JenwayExchange[bufcnt].Stack.ItemData[ItemIndex].FoldProgram 	:= g_OutletProcess.StackerUnit[1].StackData[0].ItemData[ItemIndex].FoldProgram;
//		END_FOR	
		// to check with Jenway TrackID
		g_OutletProcess.JenwayExchange[bufcnt].StackIndex	:= g_OutletProcess.JenwayExchange[bufcnt].StackIndex +1;
		 
		 // RESET
		 g_OutletProcess.StackerUnit[1].StackData[0]	:= ZeroStackData;
		 		
		bufcnt := bufcnt + 1;	
		IF bufcnt > MaxBufferSize THEN 	// overflow
		// 	bufcnt	:= MaxBufferSize;
			g_Overflow	:= TRUE;		// used to shift entries in buffer arrary
		END_IF
		
END_IF	

END_ACTION

(*################################################################*)
(*################################################################*)
		
ACTION DataShifting:		(*shift buffer array whenever a stack is transfered to Jenway *OR* Belt is overflow i.e a stack is lost*)
	IF bufcnt > 0 THEN
		
		FOR bufIndex := 0 TO MaxBufferSize - 1 DO
			g_OutletProcess.JenwayExchange[bufIndex]	:= g_OutletProcess.JenwayExchange[bufIndex + 1];
		END_FOR
		g_OutletProcess.JenwayExchange[MaxBufferSize].Stack	:= ZeroStackData;
		bufcnt := bufcnt - 1;
	END_IF
		
END_ACTION

(*################################################################*)
(*################################################################*)

(*ACTION JenHMI:		
	// visualize stacks on outletBelt --> Not used yet
	
		CASE bufcnt OF
			0:
				PosHMI[1].Stack	:= ZeroStackData;
				PosHMI[2].Stack	:= ZeroStackData;
				PosHMI[3].Stack	:= ZeroStackData;
				PosHMI[4].Stack	:= ZeroStackData;
			1 :
			PosHMI[1].Stack	:= g_OutletProcess.JenwayExchange[0].Stack;
			PosHMI[2].Stack	:=	ZeroStackData;
			PosHMI[3].Stack	:=	ZeroStackData;
			PosHMI[4].Stack	:= ZeroStackData;
			2:
			PosHMI[1].Stack	:= g_OutletProcess.JenwayExchange[1].Stack;
			PosHMI[2].Stack	:= g_OutletProcess.JenwayExchange[0].Stack;
			PosHMI[3].Stack	:= ZeroStackData;
			PosHMI[4].Stack	:= ZeroStackData;
			3:
			PosHMI[1].Stack	:= g_OutletProcess.JenwayExchange[2].Stack;
			PosHMI[2].Stack	:= g_OutletProcess.JenwayExchange[1].Stack;
			PosHMI[3].Stack	:= g_OutletProcess.JenwayExchange[0].Stack;
			PosHMI[4].Stack	:= ZeroStackData;
			4:
			PosHMI[1].Stack	:= g_OutletProcess.JenwayExchange[3].Stack;
			PosHMI[2].Stack	:= g_OutletProcess.JenwayExchange[2].Stack;
			PosHMI[3].Stack	:= g_OutletProcess.JenwayExchange[1].Stack;
			PosHMI[4].Stack	:= g_OutletProcess.JenwayExchange[0].Stack;
		
		END_CASE;
		//
			FOR k := 1 TO 4  DO
				IF PosHMI[k].Stack.Count > 0 THEN		// empty stack is not shown
					HMIStackHide[k]		:= 0;
				ELSE
					HMIStackHide[k]		:= 1;
				END_IF;

				END_FOR

END_ACTION *)

