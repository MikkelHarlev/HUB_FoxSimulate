#include <brdkEM_func.h>

void brdkEM(struct brdkEM* this) {

	brdkEM_typ* parent;
	wakeMU(this->internal.muList.idx,(unsigned long)this);
	parent = getEm(this->internal.muList.parentIdx);

	if(this->setup.useSubstateSC) {
		if(this->substate == SC) this->cmd.sc = true;	/* if enabled and substate is SC the cmd.sc is set */
	}

	switch(this->state) {
			
		case STATE_STOPPED:
			this->status.color = BLUE;
			lightTree(this,BLUE,RED);
			setSubStateText(this);
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);						/* check if a child is in STATE- ABORTING or ABORTED */
			observeParentState(this, parent, 2, STATE_RESETTING, STATE_ABORTING);					/* check if parent is in STATE- RESETTING */
			if(this->internal.findParent) findParent(this,parent,STATE_RESETTING,11,STATE_IDLE,STATE_STARTING,STATE_EXECUTE,STATE_HOLDING,STATE_HELD,STATE_UNHOLDING,STATE_SUSPENDING,STATE_SUSPENDED,STATE_UNSUSPENDING,STATE_COMPLETING,STATE_COMPLETE);
			checkCommands(this, parent, 3, STATE_RESETTING, STATE_ABORTING, STATE_DEACTIVATING);		/* check commands reset, abort, not activate */
			setChildrenMode(this);
			if(this->mode == MODE_UNDEFINED) this->mode = MODE_PRODUCING;
			this->status.level = parent != NULL ? parent->status.level+1  : 0;	/* sets the hierarchy level */	
			break;
			
		case STATE_RESETTING:
			this->status.color = WHITE;
			lightTree(this,BLUE,WHITE);
			setSubStateText(this);
			checkChildren(this, STATE_IDLE); 													/* CHECK IF ALL CHILDREN ARE IN STATE_IDLE */
			observeChildrensState(this, 3, STATE_ABORTING, STATE_ABORTED, STATE_STOPPING);		/* CHECK IF ONE CHILD IS IN STATE_ABORTING OR STATE_ABORTED */
			observeParentState(this,parent, 2, STATE_STOPPING,STATE_ABORTING);							/* checks if parent is in STATE- STOPPING or ABORTING */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);								/* check commands stop and abort */
			break;
			
		case STATE_IDLE:
			this->status.color = BLUE;
			lightTree(this,BLUE,WHITE);
			setSubStateText(this);
			observeChildrensState(this, 4, STATE_ABORTING, STATE_ABORTED, STATE_STOPPING, STATE_STOPPED);		/* check child state */
			observeParentState(this, parent, 3,STATE_STARTING,STATE_STOPPING,STATE_ABORTING);						/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			if(this->internal.findParent) findParent(this,parent,STATE_STARTING,9,STATE_EXECUTE,STATE_HOLDING,STATE_HELD,STATE_UNHOLDING,STATE_SUSPENDING,STATE_SUSPENDED,STATE_UNSUSPENDING,STATE_COMPLETING,STATE_COMPLETE);
			checkCommands(this, parent, 3, STATE_STOPPING, STATE_ABORTING, STATE_STARTING);								/* check commands stop, abort, start */
			break;

		case STATE_STARTING:		
			this->status.color = WHITE;
			lightTree(this,flashColor(this,GREEN),WHITE);
			setSubStateText(this);
			checkChildren(this, STATE_EXECUTE); 															/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 4, STATE_ABORTING, STATE_ABORTED, STATE_STOPPING, STATE_STOPPED);	/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this, parent,2,STATE_STOPPING,STATE_ABORTING); 										/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);											/* check commands stop, abort */
			break;

		case STATE_EXECUTE:
			this->status.color = GREEN;
			lightTree(this,GREEN,WHITE);
			setSubStateText(this);
			observeChildrensState(this, 8, STATE_ABORTING, STATE_ABORTED, STATE_STOPPING, STATE_STOPPED, STATE_SUSPENDING, STATE_SUSPENDED, STATE_HOLDING, STATE_HELD);		/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,5,STATE_HOLDING,STATE_SUSPENDING,STATE_COMPLETING,STATE_STOPPING,STATE_ABORTING); /* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			if(this->internal.findParent) findParent(this,parent,STATE_EXECUTE,7,STATE_HOLDING,STATE_HELD,STATE_SUSPENDING,STATE_SUSPENDED,STATE_COMPLETING,STATE_COMPLETE);
			checkCommands(this, parent, 5, STATE_STOPPING, STATE_ABORTING, STATE_HOLDING, STATE_SUSPENDING, STATE_COMPLETING);		/* check commands stop, abort, hold, suspend, complete */
			break;

		case STATE_HOLDING:					
			this->status.color = WHITE;
			lightTree(this,flashColor(this,RED),WHITE);
			setSubStateText(this);
			checkChildren(this, STATE_HELD); 											/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);				/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 					/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);						/* check commands stop, abort */
			break;

		case STATE_HELD:
			this->status.color = RED;
			lightTree(this,flashColor(this,RED),WHITE);
			setSubStateText(this);
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,3,STATE_UNHOLDING,STATE_STOPPING,STATE_ABORTING); 	/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			if(this->internal.findParent) findParent(this,parent,STATE_UNHOLDING,6,STATE_EXECUTE,STATE_SUSPENDING,STATE_SUSPENDED,STATE_UNSUSPENDING,STATE_COMPLETING,STATE_COMPLETE);
			checkCommands(this, parent, 3, STATE_STOPPING, STATE_ABORTING, STATE_UNHOLDING);		/* check commands stop, abort, start */
			break;

		case STATE_UNHOLDING:
			this->status.color = WHITE;
			lightTree(this,RED,GREEN);
			setSubStateText(this);
			checkChildren(this, STATE_EXECUTE); 											/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 						/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);							/* check commands stop, abort */
			break;

		case STATE_SUSPENDING:
			this->status.color = WHITE;
			lightTree(this,ORANGE,WHITE);
			setSubStateText(this);
			checkChildren(this, STATE_SUSPENDED); 											/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 						/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);							/* check commands stop, abort */
			break;
			
		case STATE_SUSPENDED:
			this->status.color = ORANGE;
			lightTree(this,ORANGE,WHITE);
			setSubStateText(this);
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,3,STATE_UNSUSPENDING,STATE_STOPPING,STATE_ABORTING); 	/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			if(this->internal.findParent) findParent(this,parent,STATE_UNSUSPENDING,6,STATE_EXECUTE,STATE_HOLDING,STATE_HELD,STATE_UNHOLDING,STATE_COMPLETING,STATE_COMPLETE);
			checkCommands(this, parent, 3, STATE_STOPPING, STATE_ABORTING, STATE_UNSUSPENDING);		/* check commands stop, abort, start */
			break;
			
		case STATE_UNSUSPENDING:
			this->status.color = WHITE;
			lightTree(this,ORANGE,GREEN);
			setSubStateText(this);
			checkChildren(this, STATE_EXECUTE); 											/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 						/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);							/* check commands stop, abort */
			break;

		case STATE_COMPLETING:
			this->status.color = WHITE;
			lightTree(this,GREEN,BLUE);
			setSubStateText(this);
			checkChildren(this, STATE_COMPLETE); 											/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 						/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_STOPPING, STATE_ABORTING);							/* check commands stop, abort */
			break;
			
		case STATE_COMPLETE:
			this->status.color = BLUE;
			lightTree(this,flashColor(this,BLUE),WHITE);
			setSubStateText(this);
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);					/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,3,STATE_RESETTING,STATE_STOPPING,STATE_ABORTING); 		/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			if(this->internal.findParent) findParent(this,parent,STATE_RESETTING,10,STATE_IDLE,STATE_STARTING,STATE_EXECUTE,STATE_HOLDING,STATE_HELD,STATE_UNHOLDING,STATE_SUSPENDING,STATE_SUSPENDED,STATE_UNSUSPENDING,STATE_COMPLETING);
			checkCommands(this, parent, 3, STATE_STOPPING, STATE_ABORTING, STATE_RESETTING);		/* check commands stop, abort, reset */
			break;

		case STATE_ABORTING:
			this->status.color = WHITE;
			lightTree(this,RED,WHITE);
			setSubStateText(this);
			checkChildren(this, STATE_ABORTED);
			break;

		case STATE_ABORTED:
			this->status.color = RED;
			lightTree(this,RED,WHITE);
			setSubStateText(this);
			observeParentState(this,parent,1,STATE_CLEARING); 										/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_CLEARING, STATE_DEACTIVATING);						/* check commands clar, not activate */
			break;	
			
		case STATE_CLEARING:
			this->status.color = WHITE;
			lightTree(this,RED,flashColor(this,BLUE));
			setSubStateText(this);
			checkChildren(this, STATE_STOPPED); 										/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);				/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,2,STATE_STOPPING,STATE_ABORTING); 			/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			break;

		case STATE_STOPPING:
			this->status.color = WHITE;
			lightTree(this,GREEN,BLUE);
			setSubStateText(this);
			checkChildren(this, STATE_STOPPED); 									/* SUBSTATE MUST BE IN SC - CHECK IF ALL CHILDREN ARE IN STATE_EXECUTE */
			observeChildrensState(this, 2, STATE_ABORTING, STATE_ABORTED);			/* CHECK IF ONE CHILD IS IN STATE */
			observeParentState(this,parent,1,STATE_ABORTING); 								/* CHECK STATE OF THE PARENT AND MAYBE FOLLOW */
			checkCommands(this, parent, 2, STATE_ABORTING, STATE_DEACTIVATING);								/* check commands abort */
			break;
			
		case STATE_DEACTIVATING:
			this->status.color = WHITE;
			lightTree(this,flashColor(this,GREY),WHITE);
			setSubStateText(this);
			this->mode = MODE_UNDEFINED;
			this->internal.initSubstate = 0;
			if(this->cmd.sc) {
				UnregisterChild(this, parent);
				this->state = STATE_DEACTIVATED;
			}
			break;
			
		case STATE_ACTIVATING:
			this->status.color = WHITE;
			lightTree(this,flashColor(this,GREY),BLUE);
			setSubStateText(this);
			if(this->cmd.sc) {
				if(parent != NULL) {
					switch(parent->state) {

						case STATE_STOPPED:
							if(this->mode == MODE_UNDEFINED && this->setup.reactTo == BRDK_EM_REACT_TO_NONE) this->mode = MODE_PRODUCING;
							else this->mode = parent->mode;
							this->state = STATE_STOPPED;
							break;

						case STATE_DEACTIVATED:
							brdkStrCpy((unsigned long)this->status.substate,(unsigned long)"waiting for parent to be activated");
							break;

						default:
							brdkStrCpy((unsigned long)this->status.substate,(unsigned long)"waiting for parent to be in STATE_STOPPED");
							break;

					}
				}
				else {
					if(this->mode == MODE_UNDEFINED) this->mode = MODE_PRODUCING;
					this->state = STATE_STOPPED;
				}
			}
			break;
		
		case STATE_DEACTIVATED:
			brdkStrCpy((unsigned long)this->status.state,(unsigned long)brdkEMStateToA(this->state));
			this->status.color = GREY;
			lightTree(this,GREY,WHITE);
			setSubStateText(this);
			if(this->status.mode[0] == 0) brdkStrCpy((unsigned long)this->status.mode,brdkEMModeToA(this->mode));
			if(this->status.cycleTime == 0) this->status.cycleTime = getCycleTime();								/* get the modules cycle time */
			brdkEMInitialize(this,parent);
			checkCommands(this, parent, 1, STATE_ACTIVATING);
			break;
	}

	/* mode change */
	if(this->mode != this->internal.old.mode) {
		if(this->state == STATE_STOPPED || this->state == STATE_ACTIVATING || this->state == STATE_DEACTIVATING || this->state == STATE_DEACTIVATED) {
			/* save last state for log */
			brdkStrMemMove((unsigned long)this->status.last[1],(unsigned long)this->status.last[0], sizeof(this->status.last[0])*BRDK_MU_MAX_LAST_SIZE);
			brdkStrCpy((unsigned long)this->status.last[0], brdkEMModeToA(this->internal.old.mode));
			brdkStrCat((unsigned long)this->status.last[0], (unsigned long)"-->");
			brdkStrCat((unsigned long)this->status.last[0], brdkEMModeToA(this->mode)); 
			this->internal.old.mode = this->mode;
			brdkStrCpy((unsigned long)this->status.mode,brdkEMModeToA(this->mode)); 
		}
		else { /* avoid mode being change in other states than STATE_STOPPED */
			this->status.unvalidatedMode = true;
			this->mode = this->internal.old.mode;
		}
	}
	
	this->status.time += this->status.cycleTime/1000;
	
	/* JEDK MODIFICATION | PMU */
	// Time coversion to real to avoid time loss
	this->internal.substateTimeReal += this->status.cycleTime/1000;
	this->status.substateTime = this->internal.substateTimeReal;

//	this->status.substateTime += this->status.cycleTime/1000; /* JEDK MODIFICATION | PMU */

	/* state change */
	if(this->state != this->internal.old.state || this->substate != this->internal.old.substate) {
		/* save last state for log */
		brdkStrMemMove((unsigned long)this->status.last[1],(unsigned long)this->status.last[0], sizeof(this->status.last[0])*BRDK_MU_MAX_LAST_SIZE);
		brdkStrCpy((unsigned long)this->status.last[0],(unsigned long)this->status.state);
		brdkStrCat((unsigned long)this->status.last[0],(unsigned long)": ");
		//brdkStrAppendUdintToA(this->substate,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1); /* JEDK MODIFICATION | PMU */
		brdkStrCat((unsigned long)this->status.last[0], (unsigned long)this->status.substate); /* JEDK MODIFICATION | PMU */
//		if(this->state != this->internal.old.state) brdkStrAppendUdintToA(this->substate,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1);
//		//else brdkStrAppendUdintToA(this->internal.old.substate,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1);
//		else {
//			brdkStrCat((unsigned long)this->status.last[0], (unsigned long)this->status.substate); /* JEDK MODIFICATION | PMU */
//			//this->status.substateTime = 0; /* JEDK MODIFICATION | PMU */
//		}
		brdkStrCat((unsigned long)this->status.last[0],(unsigned long)": ");
//KC		brdkStrAppendUdintToA(this->status.time,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1);
//KC		brdkStrCat((unsigned long)this->status.last[0],(unsigned long)"ms");
		brdkStrCpy((unsigned long)this->status.state,(unsigned long)brdkEMStateToA(this->state));
		if (this->status.time != this->status.substateTime) { /* JEDK MODIFICATION | PMU */
//KC			brdkStrCat((unsigned long)this->status.last[0],(unsigned long)" sub: ");
			brdkStrAppendUdintToA(this->status.substateTime,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1);
			brdkStrCat((unsigned long)this->status.last[0],(unsigned long)"ms");			
		}
		if(this->substate != this->internal.old.substate) this->internal.substateTimeReal = this->status.substateTime = 0; /* JEDK MODIFICATION | PMU */
		if(this->state != this->internal.old.state) {
			/* log who interrupted the module */
			if(this->internal.pInterrupter != 0 && this->status.interruptedBy.name[0] == 0) {
				brdkStrCpy((unsigned long)this->status.interruptedBy.name,(unsigned long)((brdkEM_typ*)this->internal.pInterrupter)->status.name);
				if(this->internal.pInterrupter != (unsigned long)this) {
					this->status.interruptedBy.state = ((brdkEM_typ*)this->internal.pInterrupter)->status.interruptedBy.state;
					this->status.interruptedBy.substate = ((brdkEM_typ*)this->internal.pInterrupter)->status.interruptedBy.substate;
				}
				else {
					this->status.interruptedBy.state = ((brdkEM_typ*)this->internal.pInterrupter)->internal.old.state;
					this->status.interruptedBy.substate = ((brdkEM_typ*)this->internal.pInterrupter)->internal.old.substate;
				}
				if(this->state == STATE_ABORTING || this->state == STATE_STOPPING) {
					brdkStrMemMove((unsigned long)this->status.last[1],(unsigned long)this->status.last[0], sizeof(this->status.last[0])*BRDK_MU_MAX_LAST_SIZE);
					if(this->state == STATE_ABORTING) brdkStrCpy((unsigned long)this->status.last[0],(unsigned long)"Aborted by: ");
					else brdkStrCpy((unsigned long)this->status.last[0],(unsigned long)"Stopped by: ");
					brdkStrCat((unsigned long)this->status.last[0],(unsigned long)this->status.interruptedBy.name);
					brdkStrCat((unsigned long)this->status.last[0],(unsigned long)": ");
					brdkStrCat((unsigned long)this->status.last[0],brdkEMStateToA(this->status.interruptedBy.state));
					brdkStrCat((unsigned long)this->status.last[0],(unsigned long)": ");
					brdkStrAppendUdintToA(this->status.interruptedBy.substate,(unsigned long)this->status.last[0],BRDK_STR_CONVERT_DECIMAL,-1);
				}
			}
			this->cmd.sc = this->cmd.start = this->cmd.reset = this->cmd.abort = this->cmd.stop = this->cmd.clear = this->cmd.hold = this->cmd.complete = this->cmd.suspend = false; /* reset commands when the state changes */
			this->substate = 0;	/* reset substate by a state change */
			this->status.time = 0;
			this->status.substateTime = 0; /* JEDK MODIFICATION | PMU */
			this->internal.substateTimeReal = 0; /* JEDK MODIFICATION | PMU */
			this->status.unvalidatedMode = false;
		}
		this->status.substate[0] = this->description[0] = 0;
		this->internal.old.state = this->state;
		this->internal.old.substate = this->substate;
		
	}

	/* update parent info */
	if(parent != NULL) {
		this->status.parent.state = parent->state;
		this->status.parent.substate = parent->substate;
		this->status.parent.sleeping = parent->status.sleeping;
		this->status.parent.mode = parent->mode;
		if(parent->setup.skipStopSC) this->setup.skipStopSC = true; /* check if skipStopSC is set in parent module */
	}

	/* reactTo has changed */
	if(this->internal.old.reactTo != this->setup.reactTo) {
		if(this->setup.reactTo == BRDK_EM_REACT_TO_ALL) {
			if(parent != NULL) this->internal.findParent = true;
		}
		this->internal.old.reactTo = this->setup.reactTo;
	}

	/* update siblings info */
	updateSiblingInfo(&this->internal.muList.siblingIdx, &this->status.sibling[0]);

}
