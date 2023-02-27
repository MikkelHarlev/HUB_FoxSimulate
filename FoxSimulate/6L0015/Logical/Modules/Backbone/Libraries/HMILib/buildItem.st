
(* Builds items used in ItemCollection like '{"value":"1","text":"AAA"}' *)
FUNCTION buildItem
	strcpy(ADR(item), ADR('{"value":"'));
	strcat(ADR(item), ADR(value));
	strcat(ADR(item), ADR('","text":"'));
	strcat(ADR(item), ADR(text));
	strcat(ADR(item), ADR('"}'));
	
	buildItem := TRUE;
	
END_FUNCTION
