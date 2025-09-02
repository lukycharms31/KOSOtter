This is a script for kOS that can autonomously land a rocket.

Video of this in action: https://youtu.be/kNVjwnXZGQM

Script is tuned for this ship: https://kerbalx.com/lukycharms31/Otter-7

This requires kOS to have a Trajectories addon, which is not in kOS 0.19.3, but will probably be in the version after.

To use, download or1.ks, oc1.ks, and land_lib.ks and in your KSP directory put them under Ships/Script. Download the ship file and put it in the Ships folder of your save.

Make sure to setup action groups.
Launch the vehicle and activate the decoupler allowing the two stages to dock. 
Check if your first stage engines are in the right staging order, if not place them into a first stage. 
Open the kOS terminal on the second stage, and type "switch to 0." then "run oc1.". 
Then open the kOS terminal on the first stage, and type "switch to 0." then "run or1." 
Click away from the terminal and press "1". The rocket should launch.

edited to remove physics range extender requirement. 
