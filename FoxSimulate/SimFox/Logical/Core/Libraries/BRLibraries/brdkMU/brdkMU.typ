
TYPE
	brdk_em_states_typ : 
		( (*Module states. Based on ISA–TR88.00.02 state model.*)
		STATE_DEACTIVATED := 0, (*State Type: Wait
The module has not been activated yet. An activate command will cause an exit from
DEACTIVATED to a ACTIVATING state.*)
		STATE_CLEARING := 1, (*State Type: Acting
Initiated by a state command to clear faults that may have occurred
when ABORTING, and are present in the ABORTED state before
proceeding to a STOPPED state.*)
		STATE_STOPPED := 2, (*State Type: Wait
The machine is powered and stationary after completing the
STOPPING state. All communications with other systems are
functioning (if applicable). A Reset command will cause an exit from
STOPPED to the RESETTING state.*)
		STATE_STARTING := 3, (*State Type: Acting
This state provides the steps needed to start the machine and is a
result of a starting type command (local or remote). Following this
command the machine will begin to Execute.*)
		STATE_IDLE := 4, (*State Type: Wait
This is a state which indicates that RESETTING is complete. This
state maintains the machine conditions which were achieved during
the RESETTING state, and performs operations required when the
machine is in IDLE.*)
		STATE_SUSPENDED := 5, (*State Type: Wait
The machine may be running at a relevant set point speed, but
there is no product being produced while the machine is waiting for
external process conditions to return to normal. When the offending
process conditions return to normal, the SUSPENDED state will
transition to UNSUSPENDING and hence continue towards the
normal EXECUTE state.*)
		STATE_EXECUTE := 6, (*State Type: Dual
Once the machine is processing materials it is deemed to be
executing or in the EXECUTE state. Different machine modes will
result in specific types of EXECUTE activities. For example, if the
machine is in the Production mode, the EXECUTE will result in
products being produced, while in Clean Out mode the EXECUTE
state refers to the action of cleaning the machine.*)
		STATE_STOPPING := 7, (*State Type: Acting
This state executes the logic which brings the machine to a
controlled stop as reflected by the STOPPED state. Normal
STARTING of the machine can not be initiated unless RESETTING
had taken place.*)
		STATE_ABORTING := 8, (*State Type: Acting
The ABORTED state can be entered at any time in response to the
Abort command or on the occurrence of a machine fault. The
aborting logic will bring the machine to a rapid safe stop. Operation
of the emergency stop will cause the machine to be tripped by its
safety system. It will also provide a signal to initiate the
ABORTING State.*)
		STATE_ABORTED := 9, (*State Type: Wait
This state maintains machine status information relevant to the
Abort condition. The machine can only exit the ABORTED state
after an explicit Clear command, subsequently to manual
intervention to correct and reset the detected machine faults.*)
		STATE_HOLDING := 10, (*State Type: Acting
When the machine is in the EXECUTE state, the Hold command
can be used to start HOLDING logic which brings the machine to a
controlled stop or to a state which represents HELD for the
particular unit control mode. A machine can go into this state either
when an internal equipment fault is automatically detected or by an
operator command. The Hold command offers the operator a safe
way to intervene manually in the process (such as removing a
broken bottle from the in-feed) and restarting execution when
conditions are safe. To be able to restart production correctly after
the HELD state, all relevant process set-points and return status of
the procedures at the time of receiving the Hold command must be
saved in the machine controller when executing the HOLDING
procedure.*)
		STATE_HELD := 11, (*State Type: Wait
The HELD state holds the machine's operation while material
blockages are cleared, or to stop throughput while a downstream
problem is resolved, or enable the safe correction of an equipment
fault before the production may be resumed.*)
		STATE_UNHOLDING := 12, (*State Type: Acting
The UNHOLDING state is a response to an Operator command to
resume the EXECUTE state. Issuing the Unhold command will
retrieve the saved set-points and return the status conditions to
prepare the machine to re-enter the normal EXECUTE state.*)
		STATE_SUSPENDING := 13, (*State Type: Acting
This state is a result of a change in monitored conditions due to
process conditions or factors. The trigger event will cause a
temporary suspension of the EXECUTE state. SUSPENDING is
typically the result of starvation of upstream material in-feeds (i.e.,
container feed, beverage feed, crown feed, lubricant feed, etc.) that
is outside the dynamic speed control range or a downstream outfeed
blockage that prevents the machine from EXECUTING
continued steady production. During the controlled sequence of
SUSPENDING the machine will transition to a SUSPENDED state.
The SUSPENDING state might be forced by the operator.*)
		STATE_UNSUSPENDING := 14, (*State Type: Acting
This state is a result of a machine generated request from
SUSPENDED state to go back to the EXECUTE state. The actions
of this state may include ramping up speeds, turning on vacuums,
and the re-engagement of clutches. This state is done prior to
EXECUTE state, and prepares the machine for the EXECUTE state.*)
		STATE_RESETTING := 15, (*State Type: Acting
This state is the result of a RESET command from the STOPPED or
complete state. RESETTING will typically cause a machine to
sound a horn and place the machine in a state where components
are energized awaiting a START command.*)
		STATE_COMPLETING := 16, (*State Type: Acting
This state is an automatic response from the EXECUTE state.
Normal operation has run to completion (i.e., processing of material
at the infeed will stop).*)
		STATE_COMPLETE := 17, (*State Type: Wait
The machine has finished the COMPLETING state and is now
waiting for a Reset command before transitioning to the
RESETTING state.*)
		STATE_DEACTIVATING := 18, (*State Type: Acting
This state is the result of a disabled ACTIVATE command.*)
		STATE_ACTIVATING := 19 (*State Type: Acting
State between DEACTIVATED and STOPPED. This state is done prior to
STOPPED state, and prepares the machine for the STOPPED state.*)
		) := STATE_DEACTIVATED;
	brdk_em_activation_typ : 
		( (*Type of activation of equipment module.*)
		BRDK_EM_ACTIVATE := 0, (*Activates the equipment module.*)
		BRDK_EM_DEACTIVATE := 1, (*Deactivated the equipment module.*)
		BRDK_EM_ACTIVATE_BY_PARENT := 2, (*Automatically follows it's parent activation.*)
		BRDK_EM_ACTIVATE_BY_CHILD := 3 (*Activates automatically if a child demand the activation.*)
		) := BRDK_EM_DEACTIVATE;
	brdk_em_command_typ : 	STRUCT  (*Equipment module commands. Based on ISATR88.00.02.*)
		abort : BOOL := FALSE; (*Abort --> Go to STATE_ABORTING - Can be set in all states.*)
		clear : BOOL := FALSE; (*Clear --> Go to STATE_STOPPING - Can only be set in STATE_ABORTED.*)
		stop : BOOL := FALSE; (*Stop --> Go to STATE_STOPPING - Can be set in all states.*)
		reset : BOOL := FALSE; (*Reset --> Go to STATE_RESETTING - Can only be set in STATE_STOPPED.*)
		start : BOOL := FALSE; (*Start --> Go to STATE_STARTING - Can only be set in STATE_IDLE, STATE_SUSPENDED, STATE_HELD.*)
		hold : BOOL := FALSE; (*Hold --> Go to STATE_HOLDING - Can only be set in STATE_EXECUTE.*)
		suspend : BOOL := FALSE; (*Suspend --> Go to STATE_SUSPENDING - Can only be set in STATE_EXECUTE.*)
		complete : BOOL := FALSE; (*Complete --> Go to STATE_COMPLETING - Can only be set in STATE_EXECUTE.*)
		sc : BOOL := FALSE; (*The State Complete indication within the Acting state procedure will cause a state transition to occur. Same functionality as subsuate = SC.*)
	END_STRUCT;
	brdk_em_setup_typ : 	STRUCT  (*Equipment module setup structure.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the module. If empty the name of the task will be given.*)
		nameIdx : DINT := -1; (*Index to be added to name. If -1 no index will be set.*)
		reactTo : brdk_em_setup_react_typ := BRDK_EM_REACT_TO_ALL; (*Indicates which parent state the module should react to.*)
		parent : brdk_mu_setup_module_typ; (*Parameters to setup a parent module.*)
		skipStopSC : BOOL := FALSE; (*When this parameter is set the module will stop even though is not in sub state SC.*)
		sibling : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF brdk_mu_setup_module_typ; (*List of siblings to a module.*)
		activation : brdk_em_activation_typ := BRDK_EM_ACTIVATE; (*Type of activation of equipment module.*)
		useSubstateSC : BOOL := FALSE; (*Enables the if substate is set to SC it will work as cmd.sc.*)
	END_STRUCT;
	brdk_em_setup_react_typ : 
		( (*Indicates witch command/state the module should react to.*)
		BRDK_EM_REACT_TO_ALL := 0, (*Reacts to all states.*)
		BRDK_EM_REACT_TO_ABORT_AND_STOP := 1, (*Reacts only to abort and stop states.*)
		BRDK_EM_REACT_TO_ABORT_ONLY := 2, (*Reacts only to abort state.*)
		BRDK_EM_REACT_TO_STOP_ONLY := 3, (*Reacts only to stop state.*)
		BRDK_EM_REACT_TO_NONE := 4, (*Doesn't react to any state or mode change. Runs total independent. Equal to the old cmd.ignore.*)
		BRDK_EM_LISTEN_TO_ABORT_AND_STOP := 5, (*The module listen to it's parent aborting and stopping only. Parent don't react to the module.*)
		BRDK_EM_LISTEN_TO_ABORT_ONLY := 6, (*The module listen to it's parent aborting only. Parent don't react to the module.*)
		BRDK_EM_LISTEN_TO_STOP_ONLY := 7 (*The module listen to it's parent stopping only. Parent don't react to the module.*)
		) := BRDK_EM_REACT_TO_ALL;
	brdk_mu_setup_module_typ : 	STRUCT  (*Parameters to setup a connection to a module.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Logical name of the module.*)
		index : DINT := -1; (*Index to be added to the module name. If -1 no index will be set.*)
	END_STRUCT;
	brdk_mu_status_module_typ : 	STRUCT  (*Status of a module.*)
		state : brdk_em_states_typ := STATE_DEACTIVATED; (*Module states. Based on ISA-TR88.00.02 state model.*)
		substate : UINT := 0; (*Equipment module substate can be used in the task. When a state is done set cmd.sc = true and the fb will take the unit to it's next state.*)
		sleeping : BOOL := FALSE; (*Indicates that the module is sleeping meaning that the module is not being executed because a new instance is being transferred.*)
		mode : DINT; (*Mode of the module.*)
	END_STRUCT;
	brdk_em_status_typ : 	STRUCT  (*Equipment module status.*)
		state : STRING[21]; (*String representation of the state.*)
		substate : STRING[BRDK_MU_MAX_DESCRIPTION_STRING]; (*Can be set in the task to descripe what the module is doing in this substate.*)
		mode : STRING[21]; (*String representation of the mode.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the module. If empty the name of the task will be given.*)
		time : UDINT; (*[ms] Actual time spend in the current state.*)
		substateTime : UDINT; (*[ms] Actual time spend in the current substate. JEDK MODIFICATION*)
		last : ARRAY[0..BRDK_MU_MAX_LAST_SIZE]OF STRING[100]; (*The last state and substate the module was in and the spend time.*)
		childCount : UDINT; (*How many children are registered.*)
		waitingFor : brdk_em_waiting_for_typ; (*Info: Which child the parent and the underlying modules are waiting for.*)
		interruptedBy : brdk_em_interrupted_by_typ; (*Info: Which child interruped the parent by going into STOPPING or ABORTING.*)
		color : brdk_em_color_typ; (*Color depending af the unit state.*)
		lightTree : brdk_em_status_light_tree_typ; (*Light tree indicating the status of the module.*)
		cycleTime : REAL; (*[µsec] Cycle time of the modules's task.*)
		parent : brdk_mu_status_module_typ; (*Information about the parent.*)
		sibling : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF brdk_mu_status_module_typ; (*List of available siblings.*)
		unvalidatedCmd : BOOL; (*Indicates that the current state cannot accept the given command.*)
		unvalidatedMode : BOOL; (*Indicates that the current state cannot accept the given mode change. Modes can only be changed in STATE_STOPPED and in STATE_ACTIVATING. The status flag will be reset by a state change.*)
		sleeping : BOOL; (*Indicates that the module is sleeping meaning that the module is not being executed because a new instance is being transferred.*)
		level : UDINT; (*Level in the hierarchy. Parent is level 0.*)
	END_STRUCT;
	brdk_em_status_light_tree_typ : 	STRUCT  (*Light tree indicating the status of the module. The idea of the light tree status is that it can be mapped directly to an output module.*)
		red : BOOL := FALSE; (*Color red.*)
		yellow : BOOL := FALSE; (*Color yellow.*)
		blue : BOOL := FALSE; (*Color blue.*)
		green : BOOL := FALSE; (*Color green.*)
	END_STRUCT;
	brdk_em_color_typ : 
		( (*Color to display the current state.*)
		GREY := 0, (*Wait State - Unit is disabled*)
		BLUE := 1, (*Wait State – A stable state used to identify that a Unit has achieved a defined set of
conditions. In such a state the Unit is holding or maintaining a status until transitioning
to an Acting state (White color). The unit is powered and stationary.*)
		WHITE := 2, (*Acting State – A state which represents some processing activity, for example ramping
up speed.
It implies the single or repeated execution of processing steps in a logical order, for a
finite time or until a specific condition has been reached, for example within the
Starting state the quality of the received data is checking, before raping up speed for
execution.*)
		GREEN := 3, (*Dual State - The Unit is in a stable acting state. The unit is running and drives are active
and the unit is producing.*)
		RED := 4, (*Wait state – A state which represents an error state on the Unit. In this state the Unit is
not producing, until the operator have managed to make a transition to the EXECUTING
state. The state holds the units operation in a safe environment, until the command
unhold are executed. For example a material blockage will move the unit into the HELD
state. The unit will leave the state HELD, when the operator have entered the unit,
removed the the bloackage, and enabled all safeguards and activated the Unhold
command.*)
		ORANGE := 5 (*Wait State – A state which represents an error state on the line and the Unit is running
at a relevant set point speed, but there is no product being produced while the unit is
waiting for external process conditions to return to normal. The unit will also enter this
state if the operator want to have a break.*)
		) := GREY;
	brdk_em_interrupted_by_typ : 	STRUCT  (*Tells which unit has interrupted the hierarchy into STATE_ABORTING or STATE_STOPPING.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the child that has interrupted the parent.*)
		state : brdk_em_states_typ := STATE_DEACTIVATED; (*State info.*)
		substate : UINT := 0; (*Substate info.*)
	END_STRUCT;
	brdk_em_waiting_for_typ : 	STRUCT  (*Tells which child module the hierarchy are waiting for. Can be that the modules are waiting for more children, but only one of them a shown at a time.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the child that the parent is waiting for.*)
		substate : STRING[BRDK_MU_MAX_DESCRIPTION_STRING]; (*Child substate.*)
	END_STRUCT;
	brdk_cm_setup_typ : 	STRUCT  (*Equipment module setup structure.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the module.*)
		nameIdx : DINT := -1; (*Index to be added to name. If -1 no index will be set.*)
		parent : brdk_mu_setup_module_typ; (*Parameters to setup a parent module.*)
		sibling : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF brdk_mu_setup_module_typ; (*List of siblings to a module.*)
	END_STRUCT;
	brdk_cm_status_typ : 	STRUCT  (*Control module status type.*)
		ready : BOOL := FALSE; (*Control module is ready for use.*)
		state : STRING[BRDK_MU_MAX_DESCRIPTION_STRING]; (*Can be set in the task to descripe what the module is doing in this state.*)
		time : UDINT; (*[ms] Actual time spend in the current state.*)
		last : ARRAY[0..BRDK_MU_MAX_LAST_SIZE]OF STRING[25]; (*The last state the module was in.*)
		cycleTime : UDINT; (*[µsec] Cycle time of the modules's task.*)
		parent : brdk_mu_status_module_typ; (*Information about the parent.*)
		sibling : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF brdk_mu_status_module_typ; (*List of available siblings.*)
		sleeping : BOOL; (*Indicates that the module is sleeping meaning that the module is not being executed because a new instance is being transferred.*)
		level : UDINT; (*Level in the hierarchy. Parent is level 0.*)
		name : STRING[BRDK_MU_NAME_STRING_SIZE]; (*Name of the module.*)
	END_STRUCT;
	brdk_um_mode_typ : 
		( (*Unit Machine running modes.*)
		BRDK_UM_MODE_MANUAL := 0, (*Commands from the remote system is set in the structure but everthing has to be set from outside the function block.*)
		BRDK_UM_MODE_STATUS_ONLY := 1, (*Possible status and admin tags are written automatically. All commands from the remote system has to be handled from outside the function block.*)
		BRDK_UM_MODE_ALL_ENABLED := 2 (*Possible command, status and admin tags are written automatically.*)
		) := BRDK_UM_MODE_MANUAL;
	brdk_um_pml_c_typ : 	STRUCT  (*Command tags are used to control the operation of the unit machine.  Command tags include unit state commands which control the state transitions in the base state model.  The command tags also include parameters and process variables which control how the machine operates.  Command tags generally originate from the machine user or a remote system.  The originator of the command in this report is defined as the “requestor” or “information sender”.  The unit machine in this report is known as the “execution system”.*)
		UnitMode : DINT := 0; (*This value is predefined by the user / OEM, and are the desired unit modes of the machine.  The UnitMode tag is a numerical representation of the commanded mode.  There can be any number of unit modes, and for each unit mode there is an accompanying state model. Example unit modes are Production, Maintenance, Manual, Clean Out, Dry Run, Setup, etc.*)
		UnitModeChangeRequest : BOOL := FALSE; (*When a unit mode request takes place a numerical value must be present in the Command.UnitMode tag to change the unit mode.  Local processing and conditioning of the requested mode change is necessary in order to accept, reject, or condition the timing of the change request.*)
		MachSpeed : REAL := 0; (*This defines the set point for the current speed of the machine in primary packages per minute.  Keeping speed in a primary package unit of measure (UOM) allows for easier control integration.  The primary package UOM is the normalized rate for the machine, normalized to a value chosen on the line.  The following example is for a bottle line running at balance line speed of 1000 packages/minute.  The UOM chosen is equivalent to be the actual count of the Filler, or Labeler.*)
		CntrlCmd : DINT := 0; (*The tag holds the value of the command that provides the state command to drive a state change in the Base State Model, this tag is typically manipulated locally.  Local processing of this tag, local machine conditions and local commands drive changes between machine states.  This tag can be set by a local or remote source.  All values in the table below are reserved.  *)
		CmdChangeRequest : BOOL := FALSE; (*This CmdChangeRequest bit will command the machine to proceed to change the state to the target state. The tag can be used to condition when a change of state can occur.  The target state will be one of the states in the base state model.*)
	END_STRUCT;
	brdk_um_pml_c_ctrl_cmd_typ : 
		( (*Control commands as enumerations.*)
		CTRL_CMD_UNDEFINED := 0,
		CTRL_CMD_RESET := 1, (*Reset --> Go to STATE_RESETTING - Can only be set in STATE_STOPPED.*)
		CTRL_CMD_START := 2, (*Start --> Go to STATE_STARTING - Can only be set in STATE_IDLE, STATE_SUSPENDED, STATE_HELD.*)
		CTRL_CMD_STOP := 3, (*Stop --> Go to STATE_STOPPING - Can be set in all states.*)
		CTRL_CMD_HOLD := 4, (*Hold --> Go to STATE_HOLDING - Can only be set in STATE_EXECUTE.*)
		CTRL_CMD_UNHOLD := 5, (*Unhold --> Go to STATE_EXECUTE - Can only be set in STATE_HOLDING.*)
		CTRL_CMD_SUSPEND := 6, (*Suspend --> Go to STATE_SUSPENDING - Can only be set in STATE_EXECUTE.*)
		CTRL_CMD_UNSUSPEND := 7, (*Unsuspend --> Go to STATE_EXECUTE - Can only be set in STATE_SUSPENDED.*)
		CTRL_CMD_ABORT := 8, (*Abort --> Go to STATE_ABORTING - Can be set in all states.*)
		CTRL_CMD_CLEAR := 9 (*Clear --> Go to STATE_STOPPING - Can only be set in STATE_ABORTED.*)
		);
	brdk_um_pml_s_typ : 	STRUCT  (*Status tags are used to describe the operation of the unit machine.  Status tags include state commands which describe the state transitions in the base state model.  The status tags also include parameters and process variables which describe how the machine operates.  Status tags generally originate from the unit machine user and can be used on a remote system.  The originator of the status tags in this report is defined as the “Execution system”.  *)
		UnitModeCurrent : DINT := 0; (*This value is predefined by the user / OEM of the available unit modes of the machine allowing a possible different set of states for the base State Model and could provide completely different functionality in the same machinery such as Cleanout, Production, Etc. *)
		StateCurrent : DINT := 0; (*The StateCurrent status tag specifies the current state in the current unit mode of the unit machine.  The numerical values are in the table below are reserved.*)
		MachSpeed : REAL := 0; (*This describes the set point for the current speed of the machine in primary packages per minute.  Keeping speed in a primary package unit of measure (UOM) allows for easier control integration.  The primary package UOM is the normalized rate for the machine, normalized to a value chosen on the line.  The following example is for a bottle line running at balance line speed of 1000 packages/minute.  The UOM chosen is equivalent to be the actual count of the Filler, or Labeler.*)
		CurMachSpeed : REAL := 0; (*This the actual value of the machine speed. Keeping units in primary package unit of measure (UOM), allows for easier control integration.  The primary package UOM is the normalized rate for the machine, normalized to a value chosen on the line.  Pack Counts are parameters stored in the Administration tags or downloaded parameters stored in Command tags parameters.*)
		EquipmentInterlock : brdk_um_pml_s_ei_typ; (*Equipment interlock.*)
		StateRequested : DINT := 0; (*This value is used for state transition checking to ensure that a target state can be transitioned to.  The target state, StateRequested, is a numerical value corresponding to a state in the base state model.*)
		StateChangeInProcess : BOOL := FALSE; (*This bit indicates that a change in state is in progress following a state change request command.*)
	END_STRUCT;
	brdk_um_pml_s_ei_typ : 	STRUCT  (*Equipment interlock.*)
		Blocked : BOOL := FALSE; (*This bit, when set to 1, indicates that a downstream system is not able to accept product.  In this condition, the equipment is capable of producing product but is in a suspended state due to a downstream system.  This tag is necessary for external equipment monitoring so that the reason for the machine being in a suspended state can be identified.*)
		Starved : BOOL := FALSE; (*This bit, when set to 1, indicates that an upstream system is not able to supply product.  In this condition, the equipment is capable of producing product but is in a suspended state due to an upstream system.  This tag is necessary for external equipment monitoring so that the reason for the machine being in a suspended state can be identified.*)
	END_STRUCT;
	brdk_um_pml_a_typ : 	STRUCT  (*Administration tags are used to describe the quality and alarm information of the unit machine.  Administration tags include alarm parameters which describe the conditions within the base state model typically for production data acquisition (PDA) systems. The administration tags also include parameters which can describe how well the machine operates, or specific information on the product quality produced by the machine.  Administration tags generally originate from the unit machine and can be used on the HMI or a remote system.*)
		StopReason : brdk_um_pml_a_sr_typ; (*Stop reason.*)
		ProdProcessedCount : ARRAY[0..BRDK_UM_MAX_PRODUCTS]OF brdk_um_pml_a_pc_typ; (*This tag represents the number of products processed by the production machine.  An example of tag usage would be the number of products that were made, including all good and defective products. This tag can be used locally or remotely if needed.  The extent of the array is typically limited to the number of products needed to be counted.  The number of products processed minus the defective count is the number of products made by the machine. The array index of # = 0 can be reserved for the count of the number of units from the primary production stream.*)
		ProdDefectiveCount : ARRAY[0..BRDK_UM_MAX_PRODUCTS]OF brdk_um_pml_a_pc_typ; (*This tag represents the product that is marked as defective in the production machine, to be used if applicable.  An example of tag usage would the number of products rejected or products that are termed defective. This tag can be used locally or remotely if needed.  The extent of the array is typically limited to the number of products needed to be counted as defective. When this tag is used with Admin.ProdProcessedCount[#] the number of good products / well formed cycles made by the machine can be calculated.  The array index of # = 0 can be reserved for the total cumulative rejected units from the primary production stream.*)
		PLCDateTime : ARRAY[0..6]OF DINT; (*The data elements associated with time and date shall be in the format of year:month:day and hour:min:sec:usec per ISO 8601.  The data type shall be an array of 32 bit Integers.*)
	END_STRUCT;
	brdk_um_pml_a_sr_typ : 	STRUCT  (*Stop reason.*)
		ID : DINT := 0; (*Stop Reason ID number.  Unique value assigned to each Stop Reason.*)
	END_STRUCT;
	brdk_um_pml_a_pc_typ : 	STRUCT  (*Product structure.*)
		Count : DINT := 0; (*The count value is used as a variable for displaying information about the amount of product.  The value is indexed upon the machine processing a unit of the product defined by the ID and NAME.  This could be displayed on HMI screens or higher level PDA systems.  The counter rolls over to 0 at 2,147,483,647*)
	END_STRUCT;
	brdk_em_internal_typ : 	STRUCT  (*Internal variables.*)
		SemCreate_0 : SemCreate; (*Module semaphore.*)
		old : brdk_em_state_old_typ; (*Last state info.*)
		flashTime : UDINT := 0; (*Flash time counter.*)
		initSubstate : UINT := 0; (*Internal temp sub state to be used in STATE_DEACTIVATED.*)
		pInterrupter : UDINT := 0; (*Pointer to the module that interrupted.*)
		findParent : BOOL := FALSE; (*The module automatically finds it's parent's state.*)
		muList : brdk_em_internal_mu_list_typ; (*Holds index's in the MU list.*)
		substateTimeReal : REAL;
	END_STRUCT;
	brdk_em_state_old_typ : 	STRUCT  (*Holds the old states.*)
		state : brdk_em_states_typ := STATE_DEACTIVATED; (*Old state.*)
		substate : UINT := 0; (*Old substate.*)
		mode : DINT := 0; (*Old mode.*)
		reactTo : brdk_em_setup_react_typ := BRDK_EM_REACT_TO_ALL; (*Old reactTo.*)
	END_STRUCT;
	brdk_em_internal_mu_list_typ : 	STRUCT  (*Holds index's in the MU list.*)
		idx : DINT := -1; (*Own index in the mu list.*)
		parentIdx : DINT := -1; (*Parent index in the mu list.*)
		siblingIdx : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF DINT := [4(-1)]; (*Siblings index in the mu list.*)
		childrenIdx : ARRAY[0..BRDK_EM_MAX_CHILDREN]OF DINT; (*Children index in the mu list.*)
	END_STRUCT;
	brdk_cm_internal_mu_list_typ : 	STRUCT  (*Holds index's in the MU list.*)
		idx : DINT := -1; (*Own index in the mu list.*)
		parentIdx : DINT := -1; (*Parent index in the mu list.*)
		siblingIdx : ARRAY[0..BRDK_MU_MAX_SIBLINGS]OF DINT := [4(-1)]; (*Siblings index in the mu list.*)
	END_STRUCT;
	brdk_cm_internal_typ : 	STRUCT  (*Control module internal variables.*)
		initSubstate : UINT := 0; (*Internal temp sub state to be used in INIT PROGRAM.*)
		muList : brdk_cm_internal_mu_list_typ; (*Holds index's in the MU list.*)
		old : brdk_cm_state_old_typ; (*Holds the old states.*)
	END_STRUCT;
	brdk_um_pml_internal_typ : 	STRUCT  (*Internal variables.*)
		modeState : UINT; (*Mode change state.*)
		commandState : UINT; (*Command change state.*)
		oldMode : DINT; (*Mode before command request.*)
		oldState : brdk_em_states_typ; (*State before command request.*)
		rtc : RTCtime_typ; (*Holds the current date and time.*)
	END_STRUCT;
	brdk_cm_state_old_typ : 	STRUCT  (*Holds the old states.*)
		state : UINT; (*Old CM state.*)
		substate : UINT; (*Old CM substate.*)
	END_STRUCT;
END_TYPE
