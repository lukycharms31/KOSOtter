//Original Craft Youtube video: https://www.youtube.com/watch?v=-v85HOATx4M&list=LL&index=25&t=1s
//Original Craft Github: https://github.com/CalebJ2/kOS-landing-script
//Original Craft KerbalX: https://kerbalx.com/Caleb9000/kOS2
//Script Optimized for "Otter 7" 
//Youtube: https://youtu.be/kNVjwnXZGQM
//Github: https://github.com/lukycharms31/KOSOtter
//KerbalX: https://kerbalx.com/lukycharms31/Otter-7

//**********UPDATE PAYLOAD LIQUIDFUEL NUMBER AT LINE 40!!!!!**********

ON AG1 {
	SET runMode TO runMode - 1.
	SET updateSettings TO true.
}
ON AG8 {
	SET runMode TO runMode + 1.
	SET updateSettings TO true.
}

CLEARSCREEN.
if addons:tr:available() = false {
	print "Trajectories mod is not installed or is the wrong version." at(0,8).
	print "Script will fail, but you may press 1 to launch anyway." at(0,9).
} else {
	print "Press 1 to launch." at(0,9).
}
print "Press 1 to launch." at(0,9).
RUN land_lib.ks. //Includes the function library

SET steeringDir TO 90. //0-360, 0=north, 90=east
SET steeringPitch TO 90. // 90 is up
LOCK STEERING TO HEADING(steeringDir,steeringPitch).

set ship:control:pilotmainthrottle to 0.
SET thrott TO 0.
LOCK THROTTLE TO thrott.
SAS OFF.
RCS OFF.

SET payload TO 0. //Make this the amount of liquid fuel in payload/third stage.
LOCK radar TO terrainDist().
SET radarOffset TO 14.//ship:altitude - radar. //rocket should be on ground at this point
LOCK trueRadar TO alt:radar - radarOffset.			// Offset radar to get distance from gear to ground
SET launchPad TO latlng(-0.195570702220158, -74.4851394526656).//LATLNG(-0.0972077635067718, -74.5576726244574).
SET launchPad2 TO latlng(-0.195570702220158, -74.5576726244574).
LOCK targetDist TO geoDistance(launchPad, ADDONS:TR:IMPACTPOS).
LOCK targetDist2 TO geoDistance(launchPad2, ADDONS:TR:IMPACTPOS).
LOCK targetDir TO geoDir(ADDONS:TR:IMPACTPOS, launchPad2).
SET cardVelCached TO cardVel().
SET targetDistOld TO 0.

SET g TO constant:G * BODY:Mass / BODY:RADIUS^2. //g in m/s^2 at sea level.
LOCK maxVertAcc TO (SHIP:AVAILABLETHRUST / SHIP:MASS) - g. //max acceleration in up direction the engines can create
LOCK sBurnDist TO SHIP:VERTICALSPEED^2 / (2 * maxVertAcc).
lock idealThrottle to sBurnDist / trueRadar.			// Throttle required for perfect hoverslam
lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

SET stopLoop TO false.
//0 = landed, 1 = hoverslam, 2 = falling pt2, 3 = falling pt1, 4 = boostback, 5 = pitch over, 6 = launch, 7 = pre-launch
SET runMode TO 7.
SET ag2 TO false.
SET ag3 TO false.
SET ag4 TO false.
SET ag5 TO false.
SET ag10 TO false.
WAIT 0.1.
SET ag2 TO true.
SET updateSettings TO true.

SET eastVelPID TO PIDLOOP(3, 0.01, 0.0, -35, 35). //Controls horizontal speed by tilting rocket
SET northVelPID TO PIDLOOP(3, 0.01, 0.0, -35, 35).
SET eastPosPID TO PIDLOOP(1700, 0, 100, -30, 30). //controls horizontal position by changing velPID setpoints
SET northPosPID TO PIDLOOP(1700, 0, 100, -30, 30).
SET eastPosPID:SETPOINT TO launchPad:LNG.
SET northPosPID:SETPOINT TO launchPad:LAT.

WHEN runMode = 6 THEN { //launch
	SET thrott TO 1.
    SET ag3 TO true.
	GEAR OFF.
    SET KUniverse:ACTIVEVESSEL TO VESSEL("Otter 7").
	SET updateSettings TO true.
    WHEN SHIP:altitude > 300 THEN{ //pitch over
        SET runMode TO 5.
        SET ag4 TO true.
	    WHEN SHIP:LIQUIDFUEL < 121 + 180 + payload AND SHIP:LIQUIDFUEL > 0 + 180 + payload THEN { //boostback
            //PRINT ROUND(SHIP:LIQUIDFUEL -180 - payload, 2) AT(0,14).
		    SET thrott TO 0.
		    SET runMode TO 4.
		    SET updateSettings TO true.
		    WHEN runMode = 3 THEN { //falling pt1
                //PRINT ROUND(SHIP:LIQUIDFUEL, 2) AT(0,15).
			    SET updateSettings TO true.
			    SET thrott TO 0.
                WHEN ship:altitude < 7300 THEN { //falling pt2
                    SET updateSettings TO true.
                    SET runMode TO 2.
			        WHEN sBurnDist > radar - radarOffset + 50 AND SHIP:VERTICALSPEED < -5 THEN { //hoverslam
                        //PRINT ROUND(RADAR - RADAROFFSET, 2) AT(0,17).
				        SET runMode TO 1.
				        SET updateSettings TO true.
				        WHEN SHIP:VERTICALSPEED > -0.2 THEN { //landing
                            //PRINT ROUND(SHIP:LIQUIDFUEL, 2) AT(0,16).
                            //PRINT ROUND(RADAR - RADAROFFSET, 2) AT(0,18).
					        SET thrott TO 0.
							SET runMode to 0.
						    WHEN runMode = 0 THEN { //landed
							    SET updateSettings TO true.
							    SET thrott TO 0.
							    RCS OFF.
                            }
						}
					}
				}
			}
		}
	}
}


UNTIL stopLoop = true { //Main loop
	if runMode = 7 { //pre-launch
		if updateSettings = true {
			UNLOCK THROTTLE.
			UNLOCK STEERING.
			SET updateSettings TO false.
		}
	}
    if runMode = 6 { //launch
		if updateSettings = true {
			LOCK STEERING TO HEADING(steeringDir,steeringPitch).
			LOCK THROTTLE TO thrott.
			SET updateSettings TO false.
			CLEARSCREEN.
		}
		SET steeringPitch TO 90.
	}	
	if runMode = 5 { //pitch over
		if updateSettings = true {
			LOCK STEERING TO HEADING(steeringDir,steeringPitch).
			SET updateSettings TO false.
		}
		SET steeringPitch TO 90 * (45000 - SHIP:ALTITUDE) / 45000.
	}
	if runMode = 4 { //boostback
		if updateSettings = true {
			RCS ON.
			SAS OFF.
			SET thrott TO 0.
			WAIT 0.1.
			STAGE.
			WAIT 1.
            STAGE.
            WAIT 1.
            SET ag5 TO true.
            WAIT 2.
			SET newvess TO vessel("Otter 7 Sat").
			SET updateSettings TO false.
		}
		if ADDONS:TR:HASIMPACT = true { //If ship will hit ground
			SET steeringDir TO targetDir - 180. //point towards launch pad
			SET steeringPitch TO -20.
			if VANG(HEADING(steeringDir,steeringPitch):VECTOR, SHIP:FACING:VECTOR) < 25 {  //wait until pointing in right direction
				SET thrott TO targetDist2 / 5000 + 0.2.
			} else {
				SET thrott TO 0.
			}
			if targetDist2 < 2000 {
				wait 0.2.
				SET thrott TO 0.
				SET runMode TO 3.
			}
			SET targetDistOld TO targetDist2.
		}
	}
	if runMode = 3 { //falling pt1
		SET shipProVec TO (SHIP:VELOCITY:SURFACE * -1):NORMALIZED.
		if SHIP:VERTICALSPEED < -10 {
			SET launchPadVect TO (launchPad2:POSITION - ADDONS:TR:IMPACTPOS:POSITION):NORMALIZED. //vector with magnitude 1 from impact to launchpad2
			SET rotateBy TO MIN(targetDist2*2, 15). //how many degrees to rotate the steeringVect
			PRINT "rotateBy: " + rotateBy at(0,7).
			SET steeringVect TO shipProVec * 40. //velocity vector lengthened
			SET loopCount TO 0.
			UNTIL (rotateBy - VANG(steeringVect, shipProVec)) < 3 { //until steeringVect gets close to desired angle
				PRINT "entered loop" at(0,9).
				if VANG(steeringVect, shipProVec) > rotateBy { //stop from overshooting
					PRINT "broke loop" at(0,9).
					BREAK.
				}
				SET loopCount TO loopCount + 1.
				if loopCount > 100 {
					PRINT "broke infinite loop" at(0,10).
					BREAK.
				}
				SET steeringVect TO steeringVect - launchPadVect. //essentially rotate steeringVect in small increments by subtracting the small vector.
			}
			PRINT "steeringAngle: " + VANG(steeringVect, shipProVec) at(0,8).
			LOCK STEERING TO steeringVect:DIRECTION.
		} else {
			LOCK STEERING TO (shipProVec):DIRECTION.
		}
	}
    if runMode = 2 { //falling pt2
		SET shipProVec TO (SHIP:VELOCITY:SURFACE * -1):NORMALIZED.
		if SHIP:VERTICALSPEED < -10 {
			SET launchPadVect TO (launchPad:POSITION - ADDONS:TR:IMPACTPOS:POSITION):NORMALIZED. //vector with magnitude 1 from impact to launchpad
			SET rotateBy TO MIN(targetDist*2, 5). //how many degrees to rotate the steeringVect
			PRINT "rotateBy: " + rotateBy at(0,7).
			SET steeringVect TO shipProVec * 40. //velocity vector lengthened
			SET loopCount TO 0.
			UNTIL (rotateBy - VANG(steeringVect, shipProVec)) < 3 { //until steeringVect gets close to desired angle
				PRINT "entered loop" at(0,9).
				if VANG(steeringVect, shipProVec) > rotateBy { //stop from overshooting
					PRINT "broke loop" at(0,9).
					BREAK.
				}
				SET loopCount TO loopCount + 1.
				if loopCount > 100 {
					PRINT "broke infinite loop" at(0,10).
					BREAK.
				}
				SET steeringVect TO steeringVect - launchPadVect. //essentially rotate steeringVect in small increments by subtracting the small vector.
			}
			PRINT "steeringAngle: " + VANG(steeringVect, shipProVec) at(0,8).
			LOCK STEERING TO steeringVect:DIRECTION.
		} else {
			LOCK STEERING TO (shipProVec):DIRECTION.
		}
	}
	if runMode = 1 {//hover slam 
		if updateSettings = true {
			SET eastVelPID:MINOUTPUT TO -2.5.
			SET eastVelPID:MAXOUTPUT TO 2.5.
			SET northVelPID:MINOUTPUT TO -2.5.
			SET northVelPID:MAXOUTPUT TO 2.5.
			SET steeringDir TO 0.
			SET steeringPitch TO 90.
			LOCK STEERING TO HEADING(steeringDir,steeringPitch).
	        lock throttle to idealThrottle.
	        when impactTime < 3 then {gear on.}
			SET updateSettings TO false.
		}
		SET cardVelCached TO cardVel().
		steeringPIDs().
	}
	if runMode = 0 { //landed
		SET thrott TO 0.
		SET ag10 TO true.
		wait 2.
        KUniverse:forcesetactivevessel(newvess).
        SET updateSettings TO false.
		WAIT 0.1.
        SET stopLoop to true.
	}

	printData2().
	WAIT 0.01.
}
function printData2 {
	PRINT "runMode: " + runMode AT(0,1).
	PRINT "radar: " + ROUND(radar, 4) AT(0,2).
	PRINT "sBurnDist: " + ROUND(sBurnDist, 4) AT(0,3).
	PRINT "HORIZONTALSPEED: " + ROUND(SHIP:groundspeed, 4) AT(0,4).
	PRINT "VERTICALSPEED: " + ROUND(SHIP:VERTICALSPEED, 4) AT(0,5).
	if ADDONS:TR:HASIMPACT = true { PRINT "Impact point dist from pad: " + ROUND(targetDist,4) at(0,6). }
}