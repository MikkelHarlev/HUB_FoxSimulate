
(* TODO: Add your comment here *)
FUNCTION GetDifferenceCount
	GetDifferenceCount								:= 0;
	calculatedDifference							:= 0;
	
	IF new > 0 THEN
		// Is current bigger then old?
		IF new > old THEN
			// current is bigger than the old. Add the difference
			calculatedDifference 					:= (current + (new - old));
		ELSIF new < old THEN
			// curent is smaller than old. Meaning that current has reset bag to 0. Add the diffrence between 0 and current to old.
			calculatedDifference					:= (current + (new));
		ELSE
			calculatedDifference					:= current;
		END_IF
	ELSE
		calculatedDifference						:=  current;
	END_IF
	
	GetDifferenceCount								:= calculatedDifference;
END_FUNCTION
