Dayz.Epoch.3d.Editor.Live.Mission
=================

[![ScreenShot](http://oi58.tinypic.com/2s0fde8.jpg)](http://youtu.be/e4DKLVoBQgA)

A mission file for the purpose of testing/writing scripts for [DayZ Epoch](https://github.com/vbawol/DayZ-Epoch) without the need of a server.
It emulates the dayz_server and dayz_mission files, for live testing of code inside the 3d editor.

## Features:
* Fully working GUI, zombies, hit registration, addactions, everything!
* Write code and execute it on the fly. No need to start a server and join with a client.
* Use 99% of your init.sqf and it will work ! (dynamic weather, default loadouts, custom scripts etc)
* 2 setups. DefaultLoadout from init.sqf or a Fake database entry. (copy/paste your character info from the database)
* Includes most of BIS_fnc functions, so actions like BIS_fn_invAdd will work (with some changes, see bellow)

## Installation

### DayzEpochTemplate.Chernarus:
1. Click "[Download Zip](https://github.com/Sandbird/Dayz.Epoch.3d.Editor.Live.Mission/archive/master.zip)" on the right sidebar
2. Extract the Chernarus mission file in your \My Documents\ArmA 2\missions
3. Copy the DayzEpoch.bat file (included in the .zip) in your Arma2 OA root directory and execute it.  
4. When the game launches, press Alt+E, select Chernarus, then Load and select mission DayzEpochTemplate.
5. Start editing your files located in \My Documents\ArmA 2\missions\DayzEpochTemplate with your customizations.


## Customizing and Important Notes

### Default setup vs Fake Database setup:
There are 2 ways of initializing your player.
1. The default Epoch loadout (like the one if your init.sqf)
2. A manually entry of fake database data (coordinates, medical states, inventory etc)

The 1st way has no bugs (so far), and its the easiest thing you could start with. 
Just open the ***dayz_code\init\setupChar.sqf*** and at the bottom of the file change the values to your liking.
Make sure in the ***init.sqf***, ***DefaultTruePreMadeFalse*** is set to ***true***; and also from there you can change the Default loadout of the player.

The 2nd option is a bit more complicated. It works, but sometimes it bugs out, when you select Restart instead of Loading again the Mission file.
I left the PlayerUID in the debug monitor...so IF you see that it is set to 0 then you know something went wrong...Just reload the mission file and you should be fine.
To setup your character with the second method open ***dayz_code\init\variables.sqf***. The first 55 lines until ***//Model Variables*** is where the magic happens.

Some things have to be set twice. ***CharacterID*** and ***playerUID*** so we set them up here at first.
~~~~java
player setIdentity "My_Player";                   //check description.ext file....There is no way to get the name of player otherwise in the editor.
player setVariable ["CharacterID", "1", true];    // same as the line 28 (Your charID. Must be the same number)
player setVariable ["playerUID", "111111", true]; // Your player's UID
~~~~
....

Further down is our first fake database entry. The first and second value, leave it like that. The 3rd has to be the same value as the one above.
The only extra addition to this is the _survival state of the player. That is created in the dayz_server.pbo so i had to emulate the values.
~~~~java
    /*
        OK or Error               = _primary select 0;
        Is newPlayer (true/false) = _primary select 1;
        _charID                   = _primary select 2;
        _isInfected (1/0)         = _primary select 3;
        _inventory                = _primary select 4;
        _backpack                 = _primary select 5;
        _survival                 = _primary select 6;  //last ate+ last drunk +totalminutes alive
        _model                    = _primary select 7;
        _hiveVer                  = _primary select 8;
    */

    primaryPre = [
    "OK",
    false,
    "1", // My charID
    "0",
    [["ItemMap","ItemWatch","ItemToolbox","ItemFlashlightRed","Binocular_Vector","M9SD","NVGoggles","ItemRadio","ItemEtool","ItemHatchet_DZE","ItemCrowbar","ItemMatchbox_DZE","M4A1_HWS_GL_SD_Camo","ItemKnife","ItemCompass"],["30Rnd_556x45_StanagSD","30Rnd_556x45_StanagSD","30Rnd_556x45_StanagSD","FoodSteakCooked","ItemSodaCoke","PartGeneric","PartGeneric","PartWheel","PartWheel","15Rnd_9x19_M9SD","15Rnd_9x19_M9SD","ItemBandage","ItemBandage","ItemBandage"]],
    ["DZ_Backpack_EP1",[["AK_47_S"],[1]],[["ItemBloodbag"],[2]]],
    [4320,114.9,42.753],   // ------ This is the only extra thing i had to add: 4320 means 3 days (survival time) in minutes, 114.9: last ate, 42.753: last drunk   -----
    "TK_Commander_EP1_DZ",
    11];
~~~~

The second part is this
~~~~
    /*
        OK or Error        = _primary select 0;
        _medical           = _primary select 1;
        _stats             = _primary select 2;
        _state             = _primary select 3;
        _worldspace        = _primary select 4;
        _humanity          = _primary select 5;
        _lastinstance      = _primary select 6;
    */
    secondaryPre = [
    "OK",
    [false,false,false,false,false,false,false,6000,[],[0,0],0,[114.9,42.753]],  // 6000 blood
    [10,20,1,22],   // Kill stats
    ["M9SD","aidlpknlmstpsraswpstdnon_player_idlesteady02",42,["222222","333333"]],  //42 is the temperature, ["222222","333333"] are my friend UIDs
    [91,[4965.1968,10002.998,0.001]], // Coordinates
    11000,
    11];
~~~~

This is the medical condition, kill stats, stance, friendlist, coordinates, humanity and instance of the player.

Like i said the 2nd option is a bit buggy, you have to reload or restart the mission sometimes, to get accurate results.
Most of the scripts you'll test/write should work fine...but if you want to write code for something that requires more complex stuff, 
like for example that requires the friendsarray, then make sure the mission was loaded correctly.
Loading the mission again doesn not affect your custom scripts. It will reload the mission.beidi file.


The description.ext has your character's name in it. If you ever need to check player name...it will get it from there.
~~~~
	class My_Player
	{
		name="DemoPlayer";
		face="Face20";
		glasses="None";
		speaker="Dan";
		pitch=1.1;
	};
~~~~


## Important info

### Related to coding
Since this is an emulation of the dayz_server some things will never work. For example:

***_playerUID = getPlayerUID player;*** will never work in the editor. 
To get the _playerUID you have to do this: ***_playerUID = player getVariable ["CharacterID","0"];***
This is the most important thing to remember. Lots of scripts use ***getPlayerUID***. You have to remember to change it every time you want to use it.

Also some BIS_fnc functions have to be included in the ***dayz_code\init\compiles.sqf*** for them to work. For example i had to include:
~~~~
BIS_fnc_invAdd = 				compile preprocessFileLineNumbers "dayz_code\system\functions\inventory\fn_invAdd.sqf";	
~~~~
If your code has BIS_fnc functions in it then check the folder ***dayz_code\system\functions*** for the function and include it in the compiles.sqf.
I am sure there is a way to parse the folder and add a BIS_ infront of all the files, like epoch does it...but i didnt want to waste time and ran into problems, 
so manually adding the files is fine by me.

Use the debug option in the init.sqf if you are using the 2nd method (fake database entry). And ALWAYS check your RPT log file for debugging. Its located at : %AppData%\Local\ArmA 2 OA
Also enable this in the init.sqf if you want more details:
~~~~
DZEdebug = true;  // Debug messages on log file
~~~~

Dont let the file names trick you...These are heavily modified files...Dont overwrite them with your own files. Add to them instead of replacing them.

### Related to mission file included
You'll notice when you start the mission there are 2 bots standing there. If you double click the soldier you'll see that he initiates this script ***scripts\BotInit.sqf***.
I left that in purpose in case you want to do some scripting that requires 'another player', and you want to initialize the fake player like that.
The other bot can be deleted. I just left it there because i was testing a Tag Friendly script, and needed a 3rd 'player' that has me as a friend. (i got no friends lol).


### Bugs

* I disabled the call player_switchModel, on the Fake database method..meaning it wont switch the player to your skin when you press Preview, because it deletes one player and creates a new one. When this happens it kinda breaks tons of stuff. If you want to enable it its at line 70 in the ***dayz_code\init\setupChar_Database.sqf***
* Sometimes the player will spawn twice. That's because when you Preview the map you are also the Server and the Player. The code runs twice....hence the bugs with the 2nd method with the fake database.
Sometimes the dayz_Login and Setup method get all messed up cause in the 3d editor you have to have a Playable character for the mission to start...but dayz server doesnt work this way.
I did my best to 'ignore' the manually added player in the beidi file and use the player the game makes (2nd method) but sometimes this whole isServer isPlayer as well messes up things.
* There are no .fsm files so dont try to include them. 3d editor will not work with them, thats why i broke the player_monitor.fsm to 2 .sqf files...One emulates 'login to the server', and one 'setup of player'.


## Final Notes
These files took me alot of time to make. It wasnt easy, and i am sure you'll find bugs or some things could have been writen a better way.
The whole purpose of this project was to not waste any more time trying to code on this god forsaken Arma engine. I cant believe that there isnt an option to write 'on the fly'. With a proper debugger...
Sure there are little tricks and hacks you can add to ***diag_log*** variables, but to write an actual script that requires interaction with the environment or beta testing custom script ??? Forget it.
I've included the Deploy bike and Self bloodbag scripts in the pack...just to see how easy it is to add/run/debug them. (Check the youtube video).

And a personal note....You will NEVER find an easier way to code stuff for Dayz....period. I've been begging both at the Epoch forum and on Opendayz for a Guru to point me to the right direction for fast coding/debugging code in  Dayz and i got nothing.
This is the fastest way to write code and see it in action. 

Hope this code will help you write code faster and easier :)
