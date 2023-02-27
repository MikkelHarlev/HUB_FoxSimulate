(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * Program: duo_inlet
 * File: duo_inlet.typ
 * Author: munchp
 * Created: April 06, 2017
 ********************************************************************
 * Local data types of program duo_inlet
 ********************************************************************)

TYPE
	length_Typ : 	STRUCT 
		startPoint : UDINT;
		endPoint : UDINT;
		lengthPulses : UDINT;
		length_mm : UINT;
		done_meas : BOOL;
	END_STRUCT;
	local_powersave_Typ : 	STRUCT 
		TOF_Inlet : TOF;
		timeBeforePowersave : UINT;
	END_STRUCT;
	local_Head_Typ : 	STRUCT 
		startInlet : BOOL;
		blockInlet : BOOL;
		linenSeen : BOOL;
		filter : Duo_Filter_Typ;
		TON_DelayStartInlet : TON;
		TON_DelayCheckPh : TON;
		TON_DelayCheckIBLF : TON;
		TOF_LiftInlet : TOF;
		TOF_GarmentOnTop : TOF;
		TOF_GarmentOnInlet : TOF;
		powersave : local_powersave_Typ;
		length : length_Typ;
	END_STRUCT;
	Duo_Filter_Typ : 	STRUCT 
		IBLF : FB_Filter;
		IBInlet : FB_Filter;
		IBAutoL : ARRAY[0..4]OF FB_Filter;
		IBAutoW : ARRAY[0..4]OF FB_Filter;
	END_STRUCT;
END_TYPE
