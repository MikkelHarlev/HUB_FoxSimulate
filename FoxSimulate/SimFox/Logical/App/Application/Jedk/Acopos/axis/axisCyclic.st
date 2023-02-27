
(********************************************************************
 * COPYRIGHT --  
 ********************************************************************
 * PROGRAM: axis
 * File: axisCyclic.st
 * Author: corduak
 * Created: September 25, 2014
 ********************************************************************
 * Implementation OF PROGRAM axis
 ********************************************************************)

PROGRAM _INIT

	rInit := TRUE;
END_PROGRAM

PROGRAM _CYCLIC

	IF (g_Core.Services.Hardware.Runtime.initState <> RUNTIME) OR g_sim.Test THEN
		RETURN;
	END_IF

	IF rInit THEN
		rInit := FALSE;
		g_Core.Services.AcoposAlarm.Runtime.FirstDrive := 0;
		g_Core.Services.AcoposAlarm.Runtime.LastDrive := g_MaxAxis;
		g_Core.Services.AcoposAlarm.Runtime.Initializing := TRUE;
	END_IF

	//--------------------------------------------------------------------------------------------------------------------
	// axis Case 
	//--------------------------------------------------------------------------------------------------------------------

	FOR no := 0 TO g_MaxAxis DO
		IF (g_Axis[no].axisRef > 0) THEN
			// Set AxisReference For All Funktions Used 
			axis[no].Power.Axis := g_Axis[no].axisRef;
			axis[no].Home.Axis := g_Axis[no].axisRef;
			axis[no].MoveAdditive.Axis := g_Axis[no].axisRef;
			axis[no].MoveAbsolute.Axis := g_Axis[no].axisRef;
			axis[no].Follow.Axis := g_Axis[no].axisRef;
			axis[no].MoveVelocity.Axis := g_Axis[no].axisRef;
			axis[no].TorqueMode.Axis := g_Axis[no].axisRef;
			axis[no].TorquePull.Axis := g_Axis[no].axisRef;
			axis[no].Stop.Axis := g_Axis[no].axisRef;
			axis[no].BR_WriteParID.Axis := g_Axis[no].axisRef;
			axis[no].BR_ReadParID.Axis := g_Axis[no].axisRef;
			axis[no].BR_ReadReqParID.Axis := g_Axis[no].axisRef;
			axis[no].ReadAxisError.Axis := g_Axis[no].axisRef;
			axis[no].Reset.Axis := g_Axis[no].axisRef;
			axis[no].ReadStatus.Axis := g_Axis[no].axisRef;
		 
			// Call Funktion Cyclic 
			axis[no].Power();
			axis[no].Home();
			axis[no].MoveAdditive();
			axis[no].MoveAbsolute();
			axis[no].Follow();
			axis[no].MoveVelocity();
			axis[no].TorqueMode();
			axis[no].TorquePull();
			axis[no].Stop();
			axis[no].BR_WriteParID();
			axis[no].BR_ReadParID();
			axis[no].BR_ReadReqParID();
			axis[no].ReadAxisError();
			axis[no].Reset();
			axis[no].ReadStatus();

			// Check For General Axis Error 
			IF ((axis[no].ReadAxisError.AxisErrorID <> 0) AND (axis[no].ReadAxisError.Valid = TRUE)) AND NOT axis[no].Error THEN
				axis[no].Error := TRUE;
				axis[no].DelayAlarmCheck := 0;
				g_Axis[no].state := AXIS_ERROR;
			END_IF

			// Delay Recall Funktion AXIS_ABS 
			IF axis[no].TempCounter >= 1 THEN
				axis[no].MoveAbsolute.Execute := FALSE;
				axis[no].TempCounter := axis[no].TempCounter - 1;
			END_IF				
	
			CASE g_Axis[no].state OF
				// -----------------------------------------------------------------------------------------------------------
				// Ready 
				// -----------------------------------------------------------------------------------------------------------
						
				// 
				AXIS_RESETTING:
					// Reset All FB Execute Inputs In Use 
					axis[no].Home.Execute	:= FALSE;
					axis[no].MoveAdditive.Execute := FALSE;
					axis[no].MoveAbsolute.Execute	:= FALSE;
					axis[no].Follow.Execute := FALSE;
					axis[no].MoveVelocity.Execute	:= FALSE;
					axis[no].TorqueMode.Execute := FALSE;
					axis[no].TorqueMode.Reset	:= FALSE;
					axis[no].TorqueMode.Stop := FALSE;
					axis[no].TorquePull.Execute := FALSE;
					axis[no].TorquePull.Reset	:= FALSE;
					axis[no].TorquePull.Stop := FALSE;
					axis[no].Stop.Execute	:= FALSE;
					axis[no].BR_WriteParID.Execute := FALSE;
					axis[no].BR_ReadParID.Execute	:= FALSE;
					axis[no].ReadAxisError.Acknowledge := FALSE;
					axis[no].Reset.Execute := FALSE;
					axis[no].Resetting := FALSE;
					axis[no].DelayAlarmCheck := 0;
					g_Axis[no].move.stop := FALSE;
					g_Axis[no].move.reset := FALSE;
					g_Axis[no].move.maxposition := FALSE;
					g_Axis[no].state := AXIS_IDLE;
						
				AXIS_IDLE:
					// IDLE
					
					// -----------------------------------------------------------------------------------------------------------
					// Axis Power On 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_POWER_ON:	// 10 
					// Reset Axis If In ErrorStop Mode 
					IF ((axis[no].ReadStatus.Errorstop = 1) AND (axis[no].ReadStatus.Valid = TRUE)) THEN
						axis[no].Resetting := TRUE;
						g_Axis[no].state := AXIS_ERROR_RESET;
					ELSIF axis[no].Power.Error = TRUE THEN
						axis[no].Resetting := TRUE;
						g_Axis[no].state := AXIS_POWER_OF;
					ELSE
						axis[no].Power.Enable:= TRUE;
						g_Axis[no].state := AXIS_POWER_ON_WAIT;
					END_IF

				AXIS_POWER_ON_WAIT:	// 11
					IF axis[no].Power.Status = TRUE THEN
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].Power.Error = TRUE THEN
						g_Axis[no].ErrorId := axis[no].Power.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Power Off 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_POWER_OF:	// 20 
					axis[no].Power.Enable:= FALSE;
					g_Axis[no].state := AXIS_POWER_OF_WAIT;

				AXIS_POWER_OF_WAIT:	// 21 
					IF axis[no].Power.Status = FALSE THEN
						IF axis[no].Resetting THEN
							axis[no].Resetting := FALSE;
							g_Axis[no].state := AXIS_POWER_ON;
						ELSE
							g_Axis[no].state := AXIS_RESETTING;
						END_IF
					END_IF
					IF axis[no].Power.Error = TRUE THEN
						g_Axis[no].ErrorId := axis[no].Power.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF
					// -----------------------------------------------------------------------------------------------------------
					// Axis Home 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_HOME:	// 30 
					axis[no].Home.Execute := TRUE;
					g_Axis[no].state := AXIS_HOME_WAIT;

				AXIS_HOME_WAIT:	// 31 
					IF axis[no].Home.Done = TRUE THEN
						axis[no].Home.Execute := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].Home.Error = TRUE THEN
						axis[no].Home.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].Home.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Additive 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_ADD:		// 40 
					axis[no].MoveAdditive.Execute := TRUE;
					axis[no].MoveAdditive.Distance := g_Axis[no].move.position;
					axis[no].MoveAdditive.Velocity := g_Axis[no].move.velocity;
					axis[no].MoveAdditive.Acceleration := g_Axis[no].move.acceleration;
					axis[no].MoveAdditive.Deceleration := g_Axis[no].move.deceleration;
					g_Axis[no].state := AXIS_ADD_WAIT;

				AXIS_ADD_WAIT:	// 41 
					axis[no].MoveAdditive.Execute := FALSE;
					IF axis[no].MoveAdditive.Done = TRUE THEN
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].MoveAdditive.Error = TRUE THEN
						g_Axis[no].ErrorId := axis[no].MoveAdditive.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Absolute 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_ABS:		// 50 
					IF axis[no].TempCounter = 0 THEN
						axis[no].MoveAbsolute.Execute := TRUE;
						axis[no].MoveAbsolute.Position := g_Axis[no].move.position;
						axis[no].MoveAbsolute.Velocity := g_Axis[no].move.velocity;
						axis[no].MoveAbsolute.Acceleration := g_Axis[no].move.acceleration;
						axis[no].MoveAbsolute.Deceleration := g_Axis[no].move.deceleration;
						axis[no].MoveAbsolute.Direction := mcSHORTEST_WAY;
						axis[no].TempCounter := 30;
						g_Axis[no].state := AXIS_ABS_WAIT;
					END_IF

				AXIS_ABS_WAIT:	// 51 
					axis[no].MoveAbsolute.Execute := FALSE;
					IF axis[no].MoveAbsolute.Done = TRUE THEN
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].MoveAbsolute.Error = TRUE THEN
						g_Axis[no].ErrorId := axis[no].MoveAbsolute.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Follow 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_FOLLOW:		// 55 
					axis[no].Follow.Execute := TRUE;
					axis[no].Follow.Position1 := g_Axis[no].move.position1;
					axis[no].Follow.Position2 := g_Axis[no].move.position2;
					axis[no].Follow.Velocity := g_Axis[no].move.velocity;
					axis[no].Follow.Acceleration := g_Axis[no].move.acceleration;
					axis[no].Follow.Deceleration := g_Axis[no].move.deceleration;
					axis[no].Follow.input1 := g_Axis[no].move.input1;
					axis[no].Follow.input2 := g_Axis[no].move.input2;
					g_Axis[no].state := AXIS_FOLLOW_WAIT;

				AXIS_FOLLOW_WAIT:	// 56 
					axis[no].Follow.Stop := g_Axis[no].move.stop;
					axis[no].Follow.input1 := g_Axis[no].move.input1;
					axis[no].Follow.input2 := g_Axis[no].move.input2;
					axis[no].Follow.Position1 := g_Axis[no].move.position1;
					axis[no].Follow.Position2 := g_Axis[no].move.position2;
					g_Axis[no].move.maxposition := axis[no].Follow.MaxPosition; 
				
					IF axis[no].Follow.Done = TRUE THEN
						axis[no].Follow.Execute := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].Follow.Error = TRUE THEN
						axis[no].Follow.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].Follow.Status;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Velocity 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_VEL:		// 60 
					IF axis[no].TempCounter = 0 THEN
						axis[no].MoveVelocity.Execute := TRUE;
						axis[no].MoveVelocity.Velocity := g_Axis[no].move.velocity;
						axis[no].MoveVelocity.Acceleration := g_Axis[no].move.acceleration;
						axis[no].MoveVelocity.Deceleration := g_Axis[no].move.deceleration;
						axis[no].MoveVelocity.Direction := g_Axis[no].move.direction;
						axis[no].TempCounter := 30;
						g_Axis[no].state := AXIS_VEL_WAIT;
					END_IF
				AXIS_VEL_WAIT:	// 61 
					axis[no].MoveVelocity.Execute := FALSE;
					IF axis[no].MoveVelocity.InVelocity = TRUE THEN
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].MoveVelocity.Error = TRUE THEN
						g_Axis[no].ErrorId := axis[no].MoveVelocity.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Torque Mode 
					// -----------------------------------------------------------------------------------------------------------

				AXIS_TORQUE_MODE:		// 70 
					IF axis[no].TempCounter = 0 THEN
						axis[no].TorqueMode.Execute:= TRUE;
						axis[no].TorqueMode.Position:= g_Axis[no].move.position;
						axis[no].TorqueMode.Velocity:= g_Axis[no].move.velocity;
						axis[no].TorqueMode.Acceleration:= g_Axis[no].move.acceleration;
						axis[no].TorqueMode.Deceleration:= g_Axis[no].move.deceleration;
						axis[no].TorqueMode.Torque:= g_Axis[no].move.torque;
						axis[no].TorqueMode.LagLimit:= g_Axis[no].move.lagLimit;
						axis[no].TorqueMode.Release:= g_Axis[no].move.release;
						axis[no].TorqueMode.Reset:= g_Axis[no].move.reset;
						axis[no].TorqueMode.NewValue:= g_Axis[no].move.newvalue;
						axis[no].TorqueMode.NewSpeed:= g_Axis[no].move.newspeed;
						g_Axis[no].move.newvalue := FALSE;
						g_Axis[no].move.newspeed := FALSE;
						g_Axis[no].move.reset := FALSE;
						axis[no].TempCounter := 30;
						g_Axis[no].state := AXIS_TORQUE_MODE_WAIT;
					END_IF

				AXIS_TORQUE_MODE_WAIT:	// 71 
					axis[no].TorqueMode.Stop := g_Axis[no].move.stop;
					axis[no].TempCounter := 30;
					IF axis[no].TorqueMode.Done = TRUE THEN
						axis[no].TorqueMode.Execute := FALSE;
						axis[no].TorqueMode.Reset := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].TorqueMode.Error = TRUE THEN
						axis[no].TorqueMode.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].TorqueMode.Status;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Torque Pull 
					// -----------------------------------------------------------------------------------------------------------

				AXIS_TORQUE_PULL:		// 75 
					IF axis[no].TempCounter = 0 THEN
						axis[no].TorquePull.Execute:= TRUE;
						axis[no].TorquePull.Position:= g_Axis[no].move.position;
						axis[no].TorquePull.Velocity:= g_Axis[no].move.velocity;
						axis[no].TorquePull.Acceleration:= g_Axis[no].move.acceleration;
						axis[no].TorquePull.Deceleration:= g_Axis[no].move.deceleration;
						axis[no].TorquePull.Torque:= g_Axis[no].move.torque;
						axis[no].TorquePull.Reset:= g_Axis[no].move.reset;
						g_Axis[no].move.reset := FALSE;
						axis[no].TempCounter := 30;
						g_Axis[no].state := AXIS_TORQUE_PULL_WAIT;
					END_IF

				AXIS_TORQUE_PULL_WAIT:	// 76 				
					axis[no].TorquePull.Stop := g_Axis[no].move.stop;
					g_Axis[no].move.maxposition := axis[no].TorquePull.MaxPosition; 
					axis[no].TempCounter := 30;
					IF axis[no].TorquePull.Done = TRUE THEN
						axis[no].TorquePull.Execute := FALSE;
						axis[no].TorquePull.Reset := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].TorquePull.Error = TRUE THEN
						axis[no].TorquePull.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].TorquePull.Status;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Stop 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_STOP:	// 80
					//				IF NOT axis[no].ReadStatus.Stopping THEN				 
					axis[no].Stop.Execute := TRUE;
					axis[no].Stop.Deceleration := g_Axis[no].move.deceleration;
					axis[no].TorqueMode.StopFbk := TRUE;
					axis[no].TorquePull.StopFbk := TRUE;
					tCnt[no] := 0;
					g_Axis[no].state := AXIS_STOP_WAIT;
					//				END_IF	

				AXIS_STOP_WAIT:	// 81 
					axis[no].TorqueMode.StopFbk := FALSE;
					axis[no].TorquePull.StopFbk := FALSE;
					tCnt[no] := tCnt[no] + 1;
//					IF tCnt[no] > 40 THEN
//						axis[no].Stop.Execute := FALSE;
//						g_Axis[no].state := AXIS_STOP;
//					END_IF
					IF axis[no].Stop.Done = TRUE THEN
						axis[no].Stop.Execute := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].Stop.Error = TRUE THEN
						axis[no].Stop.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].Stop.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Command Write ParID 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_CMD_WRITE:	// 100 
					axis[no].BR_WriteParID.Execute := TRUE;
					axis[no].BR_WriteParID.ParID := g_Axis[no].parameter.parID;
					axis[no].BR_WriteParID.DataAddress	:= g_Axis[no].parameter.DataAddress;
					axis[no].BR_WriteParID.DataType := g_Axis[no].parameter.DataType;
					g_Axis[no].state := AXIS_CMD_WRITE_WAIT;

				AXIS_CMD_WRITE_WAIT:	// 101 
					IF axis[no].BR_WriteParID.Done = TRUE THEN
						axis[no].BR_WriteParID.Execute := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].BR_WriteParID.Error = TRUE THEN
						axis[no].BR_WriteParID.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].BR_WriteParID.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Command Read ParID 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_CMD_READ:	// 110 

					axis[no].BR_ReadParID.Execute := TRUE;
					axis[no].BR_ReadParID.ParID := g_Axis[no].parameter.parID;
					axis[no].BR_ReadParID.DataAddress := g_Axis[no].parameter.DataAddress;
					axis[no].BR_ReadParID.DataType	:= g_Axis[no].parameter.DataType;
					g_Axis[no].state := AXIS_CMD_READ_WAIT;

				AXIS_CMD_READ_WAIT:	// 111 
					IF axis[no].BR_ReadParID.Done = TRUE THEN
						axis[no].BR_ReadParID.Execute := FALSE;
						g_Axis[no].state := AXIS_RESETTING;
					END_IF
					IF axis[no].BR_ReadParID.Error = TRUE THEN
						axis[no].BR_ReadParID.Execute := FALSE;
						g_Axis[no].ErrorId := axis[no].BR_ReadParID.ErrorID;
						g_Axis[no].state := AXIS_ERROR;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Error On Axis Or Funktion Blok *)
					// -----------------------------------------------------------------------------------------------------------
				AXIS_ERROR:	// 200 
					axis[no].DelayAlarmCheck := axis[no].DelayAlarmCheck + 1;
					IF axis[no].DelayAlarmCheck > 100 THEN
						IF g_Core.System.Runtime.isEStopActivated AND NOT g_Axis[no].interface.cmdDisableAlarm THEN
							g_Axis[no].interface.isError := TRUE;
							g_Axis[no].interface.cmdStop := TRUE;
							// Copy Error Info 1 Down 
							memmove(ADR(g_Axis[no].errorList[1]), ADR(g_Axis[no].errorList[0]), SIZEOF(g_Axis[no].errorList[0])*3);
							// Clear First Entry 
							g_Axis[no].errorList[0].status  := 0;
							g_Axis[no].errorList[0].errorID	:= 0;
							g_Axis[no].errorList[0].errorInfo:= 0;
							g_Axis[no].errorList[0].line1 := '';
							g_Axis[no].errorList[0].line2 := '';
							g_Axis[no].errorList[0].line3 := '';
							g_Axis[no].errorList[0].line4 := '';
						END_IF
						g_Axis[no].state := AXIS_ERROR_1;
					END_IF
			
				AXIS_ERROR_1:	// 201 
					// Check If FB Or ReadAxisError 
					IF (g_Axis[no].ErrorId = 29226) OR axis[no].Error THEN
						g_Axis[no].state := AXIS_ERROR_2;
					ELSE
						g_Axis[no].errorList[0].errorID := g_Axis[no].ErrorId;
						g_Axis[no].ErrorId := 0;
						// Reset Axis If In ErrorStop Mode 
						IF ((axis[no].ReadStatus.Errorstop = 1) AND (axis[no].ReadStatus.Valid = TRUE) AND g_Core.System.Runtime.isEStopActivated) THEN
							g_Axis[no].state := AXIS_ERROR_RESET;
						ELSE
							g_Axis[no].state := AXIS_RESETTING;
						END_IF
					END_IF

				AXIS_ERROR_2:	// 202 
					// If Error Info Ready - Copy To HMI 
					IF (axis[no].ReadAxisError.Valid = TRUE) THEN
						IF g_Core.System.Runtime.isEStopActivated THEN
							g_Axis[no].errorList[0].status := axis[no].ReadAxisError.ErrorID;
							g_Axis[no].errorList[0].errorID	:= axis[no].ReadAxisError.AxisErrorID;
							g_Axis[no].errorList[0].errorInfo := axis[no].ReadAxisError.AxisErrorCount;
							g_Axis[no].errorList[0].line1 := g_Axis[no].ErrorText[0];
							g_Axis[no].errorList[0].line2 := g_Axis[no].ErrorText[1];
							g_Axis[no].errorList[0].line3 := g_Axis[no].ErrorText[2];
							g_Axis[no].errorList[0].line4 := g_Axis[no].ErrorText[3];
						END_IF
						axis[no].ReadAxisError.Acknowledge := 1;
						axis[no].TempCounter := 50;
						g_Axis[no].state := AXIS_ERROR_3;
					END_IF

				AXIS_ERROR_3:	// 203 
					// Acknowledge Errors 
					axis[no].ReadAxisError.Acknowledge := 0;
					IF axis[no].TempCounter = 0 THEN
						//				IF (axis[no].ReadAxisError.Busy = FALSE) THEN
						IF (axis[no].ReadAxisError.AxisErrorCount = 0) THEN
							axis[no].ReadAxisError.Acknowledge := 0;
							// Reset Axis If In ErrorStop Mode 
							IF (axis[no].ReadStatus.Valid = TRUE) THEN
								IF (axis[no].ReadStatus.Errorstop = 1) AND g_Core.System.Runtime.isEStopActivated THEN
									axis[no].Error := FALSE;
									g_Axis[no].state := AXIS_ERROR_RESET;
								ELSE
									axis[no].Error := FALSE;
									g_Axis[no].state := AXIS_RESETTING;
								END_IF
							END_IF
						ELSE
							g_Axis[no].state := AXIS_ERROR_4;
						END_IF
					END_IF
				
				AXIS_ERROR_4:	// 204 
					// Reset Acknowledge If More Errors 
					IF (axis[no].ReadAxisError.AxisErrorCount > 1) AND 
						((axis[no].ReadAxisError.AxisErrorID < 29200) OR (axis[no].ReadAxisError.AxisErrorID > 29220)) THEN
						IF ((g_Axis[no].errorList[0].errorID < 29200) OR (g_Axis[no].errorList[0].errorID > 29220)) THEN
							memmove(ADR(g_Axis[no].errorList[1]), ADR(g_Axis[no].errorList[0]), SIZEOF(g_Axis[no].errorList[0])*3);
							// Clear First Entry 
							g_Axis[no].errorList[0].status  := 0;
							g_Axis[no].errorList[0].errorID	:= 0;
							g_Axis[no].errorList[0].errorInfo:= 0;
							g_Axis[no].errorList[0].line1 := '';
							g_Axis[no].errorList[0].line2 := '';
							g_Axis[no].errorList[0].line3 := '';
							g_Axis[no].errorList[0].line4 := '';
						END_IF	
						g_Axis[no].state := AXIS_ERROR_2;
					ELSE	
						axis[no].ReadAxisError.Acknowledge := 1;
						axis[no].TempCounter := 50;
						g_Axis[no].state := AXIS_ERROR_3;
					END_IF

					// -----------------------------------------------------------------------------------------------------------
					// Axis Error Reset 
					// -----------------------------------------------------------------------------------------------------------
				AXIS_ERROR_RESET:	// 210 
					IF g_Axis[no].ready THEN
						axis[no].Reset.Execute := TRUE;
						IF (axis[no].Reset.Error = TRUE) THEN
							axis[no].Reset.Execute := FALSE;
						END_IF
						IF (axis[no].Reset.Done = TRUE) THEN
							axis[no].Reset.Execute := FALSE;
							IF axis[no].Resetting THEN
								axis[no].Resetting := FALSE;
								g_Axis[no].state := AXIS_POWER_ON;
							ELSE
								g_Axis[no].state := AXIS_RESETTING;
							END_IF
						END_IF
					END_IF
			END_CASE

			//--------------------------------------------------------------------------------------------------------------------
			// Read Axis Error 
			//--------------------------------------------------------------------------------------------------------------------

			axis[no].ReadAxisError.Enable := TRUE;
			axis[no].ReadAxisError.DataAddress := ADR (g_Axis[no].ErrorText);
			axis[no].ReadAxisError.DataLength := SIZEOF ((g_Axis[no].ErrorText));
			axis[no].ReadAxisError.DataObjectName := 'acp10etxen';

			//--------------------------------------------------------------------------------------------------------------------
			// Read Axis Status 
			//--------------------------------------------------------------------------------------------------------------------

			axis[no].ReadStatus.Enable := TRUE;
			g_Axis[no].power := axis[no].Power.Status;
			g_Axis[no].disable := axis[no].ReadStatus.Disabled;
			g_Axis[no].actValues.Errorstop	:= axis[no].ReadStatus.Errorstop;
			g_Axis[no].actValues.Stopping := axis[no].ReadStatus.Stopping;
			g_Axis[no].actValues.StandStill := axis[no].ReadStatus.StandStill;
			g_Axis[no].actValues.DiscreteMotion := axis[no].ReadStatus.DiscreteMotion;
			g_Axis[no].actValues.ContinuousMotion := axis[no].ReadStatus.ContinuousMotion;
			g_Axis[no].actValues.SynchronizedMotion := axis[no].ReadStatus.SynchronizedMotion;
			g_Axis[no].actValues.Homing := axis[no].ReadStatus.Homing;
		
			Delay_checkStandStill[no](Set:= NOT Delay_checkStandStill[no].Out, Delay:= 600, Comp:= 0, CntAdr:= ADR (g_MilliSeconds));
			IF Delay_checkStandStill[no].Trig THEN
				oldPos[no] := newPos[no];
				newPos[no] := g_Axis[no].actValues.dintPos;
				g_Axis[no].actValues.inMotion := oldPos[no] <> newPos[no];
			END_IF
			//--------------------------------------------------------------------------------------------------------------------
			// Read Axis (Actual Position - Velocity - Torque) 
			//--------------------------------------------------------------------------------------------------------------------

			axis[no].ReadActualPosition(Axis:= g_Axis[no].axisRef, Enable:= TRUE);
			axis[no].ReadActualVelocity(Axis:= g_Axis[no].axisRef, Enable:= TRUE);
			axis[no].ReadActualTorque(Axis:= g_Axis[no].axisRef, Enable:= TRUE);

			g_Axis[no].actValues.axisPos := axis[no].ReadActualPosition.Position;
			g_Axis[no].actValues.dintPos := REAL_TO_DINT(axis[no].ReadActualPosition.Position);
			g_Axis[no].actValues.velocity := axis[no].ReadActualVelocity.Velocity;
			g_Axis[no].actValues.actTorque	:= axis[no].ReadActualTorque.Torque;
	
			(* Read Lag Error *)
			IF NOT axis[no].ReadLagError.Done THEN
				axis[no].ReadLagError.Axis := g_Axis[no].axisRef;
				axis[no].ReadLagError.ParID	:= 112;				(* CTRL Position controller: Lag error [Units] - PARID 112 *)
				axis[no].ReadLagError.DataAddress := ADR(lagError[no]);
				axis[no].ReadLagError.DataType := ncPAR_TYP_REAL;
				axis[no].ReadLagError.Mode := 0;
				axis[no].ReadLagError.Execute := TRUE;
				axis[no].ReadLagError();
			END_IF
			g_Axis[no].actValues.actLagError := ABS(lagError[no]);
			axis[no].TorqueMode.LagError := lagError[no];
			axis[no].TorquePull.LagError := lagError[no];
			axis[no].TorqueMode.ActualPosition := axis[no].ReadActualPosition.Position;		
			axis[no].TorquePull.ActualPosition := axis[no].ReadActualPosition.Position;		
			axis[no].TorqueMode.ActualVelocity := axis[no].ReadActualVelocity.Velocity;

			//--------------------------------------------------------------------------------------------------------------------
			// Initialise Read Funktion At Startup 
			//--------------------------------------------------------------------------------------------------------------------
			// Read Ready Signal 
			IF NOT axis[no].BR_InitCyclicRead.Done THEN
				ready[no];
				axis[no].BR_InitCyclicRead.Axis := g_Axis[no].axisRef;
				axis[no].BR_InitCyclicRead.Execute:= TRUE;
				axis[no].BR_InitCyclicRead.ParID:= ACP10PAR_STAT_DRIVE_READY;
				axis[no].BR_InitCyclicRead.DataAddress:= ADR (ready[no]);
				axis[no].BR_InitCyclicRead.DataType:= ncPAR_TYP_UDINT;
				axis[no].BR_InitCyclicRead.Mode:= 0;
				axis[no].BR_InitCyclicRead();
			END_IF
			g_Axis[no].ready := UDINT_TO_BOOL (ready[no]);
			
			g_Axis[no].actValues.reference := UINT_TO_BOOL (gAxis01.dig_in.status.reference);
			g_Axis[no].actValues.trigger1  := UINT_TO_BOOL (gAxis01.dig_in.status.trigger1);	
			g_Axis[no].actValues.trigger2  := UINT_TO_BOOL (gAxis01.dig_in.status.trigger2);
		END_IF
	END_FOR

	//--------------------------------------------------------------------------------------------------------------------
	// Wait For Initialisation At StartUp 
	//--------------------------------------------------------------------------------------------------------------------
	TON_AcoposCheck(IN := g_Core.Services.AcoposAlarm.Runtime.Initializing, PT := T#10s);

	IF g_Core.Services.AcoposAlarm.Runtime.Initializing AND TON_AcoposCheck.Q THEN
		allReady := TRUE;
		FOR no := 0 TO g_MaxAxis DO
			IF (g_Axis[no].disable = FALSE) AND (g_Axis[no].axisRef > 0) THEN
				allReady := FALSE;
			END_IF
		END_FOR
		IF allReady THEN
			g_Core.Services.AcoposAlarm.Runtime.Initializing := FALSE;
		END_IF	
	END_IF
	IF g_Core.Services.AcoposAlarm.Runtime.Initializing THEN
		RETURN;
	END_IF

	//--------------------------------------------------------------------------------------------------------------------
	// Master Start/Stop Case 
	//--------------------------------------------------------------------------------------------------------------------
	FOR no := 0 TO g_MaxAxis DO
		IF (g_Axis[no].axisRef > 0) THEN
			IF NOT g_Core.System.Runtime.isEStopActivated OR EDGENEG(g_Core.System.Runtime.isRunning) THEN  
				g_Axis[no].interface.cmdStop := TRUE;
			END_IF
		
			CASE axis[no].MasterState OF
				// Wait For Start Command
				AXIS_MASTER_IDLE:
					g_Axis[no].interface.cmdStop := FALSE;
					IF g_Axis[no].interface.cmdStart AND NOT g_Axis[no].actValues.inMotion THEN
						// Upload Error To Hmi 
						IF (g_Axis[no].ready = FALSE) THEN
							g_Axis[no].parameter.parID := CMD_ERR_STATE_INTO_FIFO;	 			// 340 
							g_Axis[no].parameter.DataAddress := CMD_ERR_STATE_INTO_FIFO;		// 340 
							g_Axis[no].parameter.DataType := 0;
							g_Axis[no].state := AXIS_CMD_WRITE;
							axis[no].MasterState := AXIS_MASTER_UPLOAD_ERROR;
						ELSE
							// Reset Torque Funktion	
							g_Axis[no].move.reset := TRUE;
							g_Axis[no].state := AXIS_TORQUE_MODE;
							axis[no].MasterState := AXIS_MASTER_RESETTING;
						END_IF
					END_IF	
																
					// Wait For Reset Done 
				AXIS_MASTER_RESETTING:	
					IF g_Axis[no].state = AXIS_IDLE THEN
						g_Axis[no].state := AXIS_POWER_ON;
						axis[no].MasterState := AXIS_MASTER_POWER_ON;
					END_IF	
					// Goto Stop State
					IF g_Axis[no].interface.cmdStop THEN
						axis[no].MasterState := AXIS_MASTER_STOP;
					END_IF
										
					// Wait For Power On
				AXIS_MASTER_POWER_ON:
					IF g_Axis[no].state = AXIS_IDLE THEN
						g_Axis[no].state := AXIS_HOME;
						axis[no].MasterState := AXIS_MASTER_HOMING;
					END_IF
					// Goto Stop State
					IF g_Axis[no].interface.cmdStop THEN
						axis[no].MasterState := AXIS_MASTER_STOP;
					END_IF
									
					// Wait For Homing Done
				AXIS_MASTER_HOMING:
					IF g_Axis[no].state = AXIS_IDLE THEN
						axis[no].MasterState := AXIS_MASTER_RUNSTATE;
					END_IF
					// Goto Stop State
					IF g_Axis[no].interface.cmdStop THEN
						axis[no].MasterState := AXIS_MASTER_STOP;
					END_IF
												
					// Running State
				AXIS_MASTER_RUNSTATE:
					// Goto Stop State
					IF g_Axis[no].interface.cmdStop THEN
						axis[no].MasterState := AXIS_MASTER_STOP;
					END_IF
			
					// Wait For Upload Error
				AXIS_MASTER_UPLOAD_ERROR:
					// Goto Stop State
					IF g_Axis[no].interface.cmdStop THEN
						axis[no].MasterState := AXIS_MASTER_STOP;
					END_IF
			
					//--------------------------------------------------------------------------------------------------------------------
					// Stop Procedure 
					//--------------------------------------------------------------------------------------------------------------------

					// Stop Axis, There Are Ready, And Not In Error, And Power On
				AXIS_MASTER_STOP:
					g_Axis[no].interface.cmdStop := FALSE;
					IF g_Axis[no].ready AND g_Axis[no].power AND (g_Axis[no].state < AXIS_ERROR) THEN
						g_Axis[no].move.deceleration := 200000;
						g_Axis[no].state := AXIS_STOP;
					END_IF
					axis[no].MasterState := AXIS_MASTER_STOP_WAIT; 

					// Wait For Axis Stopped 
				AXIS_MASTER_STOP_WAIT:
					IF (g_Axis[no].state = AXIS_IDLE) THEN
						axis[no].MasterState := AXIS_MASTER_POWER_OF;
					END_IF

					// Power Off Axis, There Are Ready, And Not In Error, And Power On 
				AXIS_MASTER_POWER_OF:
					IF g_Axis[no].ready AND g_Axis[no].power AND (g_Axis[no].state < AXIS_ERROR) THEN
						g_Axis[no].state := AXIS_POWER_OF;
					END_IF
					axis[no].MasterState := AXIS_MASTER_POWER_OF_WAIT;

					// Wait For Axis Power Off 
				AXIS_MASTER_POWER_OF_WAIT:
					IF (g_Axis[no].state = AXIS_IDLE) THEN
						IF g_Axis[no].interface.isError THEN
							axis[no].MasterState := AXIS_MASTER_ERROR_RESET;
						ELSE
							axis[no].MasterState := AXIS_MASTER_IDLE;
						END_IF
					END_IF

					// Wait For Error Reset (All Axis Ready, And no Error) 
				AXIS_MASTER_ERROR_RESET:
					IF (g_Axis[no].ready = FALSE) OR (g_Axis[no].state >= AXIS_ERROR) OR (g_Axis[no].state >= AXIS_IDLE) THEN
						g_Axis[no].state := AXIS_POWER_OF;
						g_Axis[no].interface.isError := FALSE;
						axis[no].MasterState := AXIS_MASTER_POWER_OF_WAIT;
					END_IF
	
			END_CASE
	
			// Set Interface
			g_Axis[no].interface.isStarted := axis[no].MasterState = AXIS_MASTER_RUNSTATE AND g_Axis[no].power;
			g_Axis[no].interface.isStopped := NOT g_Axis[no].interface.isStarted AND (axis[no].MasterState = AXIS_MASTER_IDLE); 
			// Reset Start Command
			IF axis[no].MasterState <> AXIS_MASTER_IDLE OR g_Axis[no].interface.isError THEN
				g_Axis[no].interface.cmdStart := FALSE;
			END_IF
		END_IF
	END_FOR

	//--------------------------------------------------------------------------------------------------------------------
	// Set Core Alams
	//--------------------------------------------------------------------------------------------------------------------

	// Core Alarm Acopos Error	
	FOR no := 0 TO g_MaxAxis DO
		g_Axis[no].interface.isErrorReset := g_Axis[no].interface.isError OR g_Axis[no].interface.isErrorReset;
	END_FOR

	// Core Alarm PowerOf Error
	FOR no := 0 TO g_MaxAxis DO
		powerOff[no] := axis[no].ReadAxisError.Error OR axis[no].ReadStatus.Error OR axis[no].ReadActualPosition.Error OR
		axis[no].ReadActualVelocity.Error OR axis[no].ReadActualTorque.Error OR axis[no].BR_InitCyclicRead.Error;
		IF powerOff[no] THEN
			g_Core.Services.AcoposAlarm.Runtime.PowerOff := TRUE;
			EXIT;	
		END_IF	
	END_FOR	

	//--------------------------------------------------------------------------------------------------------------------
END_PROGRAM
//--------------------------------------------------------------------------------------------------------------------