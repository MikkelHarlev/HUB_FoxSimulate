
FUNCTION_BLOCK brdk_safety_remote_control (*Function block for trigger remote safety controller actions such as acknowledging modules or reading the status.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL := FALSE; (*enables the funtion block*)
		cmd : brdkSafety_remote_cmd_typ; (*commands for the function block*)
		setup : brdkSafety_remote_setup_typ; (*setup for the function block*)
	END_VAR
	VAR_OUTPUT
		done : BOOL := FALSE; (*last command is done*)
		busy : BOOL := FALSE; (*function block is active and must continue to be called*)
		error : BOOL := FALSE; (*error occurred during execution*)
		status : brdkSafety_remote_status_typ; (*status information from the function block*)
	END_VAR
	VAR
		internal : brdkSafety_remote_internal_typ; (*internal structure*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK brdk_safety_application (*Function block for download the safety application to the safety controller.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL := FALSE; (*enables the funtion block*)
		cmd : brdkSafety_app_cmd_typ; (*commands for the function block*)
		setup : brdkSafety_app_setup_typ; (*setup for the function block*)
	END_VAR
	VAR_OUTPUT
		done : BOOL := FALSE; (*last command is done*)
		busy : BOOL := FALSE; (*function block is active and must continue to be called*)
		waitForAcknowledge : BOOL := FALSE; (*waiting for acknowledgement. Set cmd.acknowledge*)
		error : BOOL := FALSE; (*error occurred during execution*)
		status : brdkSafety_app_status_typ; (*status information from the function block*)
	END_VAR
	VAR
		internal : brdkSafety_app_internal_typ; (*internal structure*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION_BLOCK brdk_safety_data (*Function block for download & read data such as machine options to the safety controller.*) (*$GROUP=User,$CAT=User,$GROUPICON=User.png,$CATICON=User.png*)
	VAR_INPUT
		enable : BOOL := FALSE; (*enables the funtion block*)
		cmd : brdkSafety_data_cmd_typ; (*commands for the function block*)
		par : brdkSafety_data_par_typ; (*parameters for the function block*)
		setup : brdkSafety_data_setup_typ; (*setup for the function block*)
	END_VAR
	VAR_OUTPUT
		done : BOOL := FALSE; (*last command is done*)
		busy : BOOL := FALSE; (*function block is active and must continue to be called*)
		waitForAcknowledge : BOOL := FALSE; (*waiting for acknowledgement. Set cmd.acknowledge*)
		error : BOOL := FALSE; (*error occurred during execution*)
		status : brdkSafety_data_status_typ; (*status information from the function block*)
	END_VAR
	VAR
		internal : brdkSafety_data_internal_typ; (*internal structure*)
	END_VAR
END_FUNCTION_BLOCK
