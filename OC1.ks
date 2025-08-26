//Original Craft Youtube video: https://www.youtube.com/watch?v=-v85HOATx4M&list=LL&index=25&t=1s
//Original Craft Github: https://github.com/CalebJ2/kOS-landing-script
//Original Craft SpaceX: https://kerbalx.com/Caleb9000/kOS2
//Script Optimized for "Otter 7" 
//Youtube: 
//Github: 
//SpaceX: https://kerbalx.com/lukycharms31/Otter-7

clearScreen.
print "Waiting" at(0,9).
RUN land_lib.ks. //Includes the function library

LOCK radar TO terrainDist().
SET updateSettings TO false.
SET steeringDir TO 90. //0-360, 0=north, 90=east
SET steeringPitch TO 90. // 90 is up

LOCK SemiPeri TO max(ETA:PERIAPSIS,ETA:APOAPSIS)-min(ETA:PERIAPSIS,ETA:APOAPSIS).
LOCK PeriOff TO (180/SemiPeri) * ETA:APOAPSIS.
SET ExtraOffset TO 0. // Raise for faster, less accurate burning. (don't go over 5) usefull for launch scripts.
SET accuracy TO 100. // Meters of difference between apoapsis and periapsis the script can stop at.
SET apotarg TO 85000. // Target apoapsis height. 

SET stopLoop TO false.
//0 = crash, 1 = burn 3(deorbit), 2 = deploy playload, 3 = burn 2(circularize), 4 = coast, 5 = burn 1(raise apoapsis), 6 = launching
SET runMode TO 6.

WHEN STAGE:NUMBER = 2 THEN { //burn 1(raise apoapsis)
    SET SHIP:SHIPNAME TO "Otter 7 Sat".
    SET ag6 TO TRUE.
	LOCK THROTTLE TO 0.
	SET updateSettings TO true.
	SET runMode TO 5.
	WHEN SHIP:APOAPSIS > apotarg  THEN { //coast
		LOCK THROTTLE TO 0.
        SET updateSettings TO true.
        SET runMode TO 4.
        WHEN KUniverse:ACTIVEVESSEL = VESSEL("Otter 7 Sat") THEN { //burn 2(circularize)
            SET updateSettings TO true.
            SET runMode TO 3.
            WHEN ship:periapsis > ship:apoapsis-2500 THEN { //deploy payload
                SET updateSettings TO true.
                SET runMode TO 2.
                WHEN runMode = 1 THEN { //burn 3(deorbit)
                    SET updateSettings TO true.
                    WHEN SHIP:LIQUIDFUEL < 0.1 THEN { //crash
                        SET runMode to 0.
                        SET updateSettings TO true.
                    }
                }
            }  
        }
	}
}


UNTIL stopLoop = true { //Main loop
	if runMode = 5 { //burn 1(raise apoapsis)
		if updateSettings = true {
			WAIT 2.
			SAS OFF.
			LOCK THROTTLE TO 1.
			LOCK STEERING TO HEADING(steeringDir,steeringPitch).
			SET updateSettings TO false.
            clearScreen.
		}
		SET steeringPitch TO 90 * (60000 - SHIP:ALTITUDE) / 60000.
	}
    if runMode = 4 { //coast
        if updateSettings = true {
            LOCK THROTTLE TO 0.
            LOCK STEERING TO prograde.
            SET updateSettings TO false.
        }
    }
    if runMode = 3 { //burn 2(circularize)
        if updateSettings = true {
            wait 2.
            stage.
            wait until ship:altitude > apotarg -1000.
            LOCK THROTTLE TO min(((ship:apoapsis-(ship:periapsis-accuracy))/20000),1).
            SET updateSettings TO false.
        }
        LOCK STEERING TO HEADING(90,ExtraOffset-PeriOff) + R(0,0,0).
    }
    if runMode = 2 { //deploy payload
        if updateSettings = true {
            LOCK THROTTLE TO 0.
            LOCK STEERING TO HEADING(steeringDir,steeringPitch).
            SET ag10 TO true.
            wait 5.
            stage.
            wait 0.1.
            SET updateSettings TO false.
            SET runMode to 1.
        }
    }
    if runMode = 1 { //burn 3(deorbit)
        if updateSettings = true {
            LOCK STEERING TO HEADING(steeringDir - 180,steeringPitch - 5).
            wait 10.
            LOCK THROTTLE TO 1.
            SET updateSettings TO false.
        }
    }
    if runMode = 0 { //crash
        if updateSettings = true {
            SET stopLoop to true.
        }
    }

	printData2().
	WAIT 0.01.
}
function printData2 {
	PRINT "runMode: " + runMode AT(0,1).
	PRINT "radar: " + ROUND(radar, 2) AT(0,2).
    PRINT "HORIZONTALSPEED: " + ROUND(SHIP:groundspeed, 2) AT(0,3).
	PRINT "VERTICALSPEED: " + ROUND(SHIP:VERTICALSPEED, 2) AT(0,4).
    PRINT "Apoapsis Height: " + ROUND(SHIP:apoapsis, 2) AT(0,5).
    PRINT "Periapsis Height: " + ROUND(SHIP:periapsis, 2) AT(0,6).
}