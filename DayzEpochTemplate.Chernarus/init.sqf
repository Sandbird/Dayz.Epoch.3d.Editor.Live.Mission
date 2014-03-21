if (isServer) then {
if (isnil "bis_fnc_init") then {
_side = createCenter sideLogic;
_group = createGroup _side;
_logic = _group createUnit ["FunctionsManager", [0,0,0], [], 0, "NONE"];
};
waituntil {!isnil "bis_fnc_init"};
};
enableSaving [false, false];
dayz_antihack = 0; // DayZ Antihack / 1 = enabled // 0 = disabled
dayz_REsec = 0; // DayZ RE Security / 1 = enabled // 0 = disabled
//REALLY IMPORTANT VALUES
dayZ_instance =	11;					//The instance
dayzHiveRequest = [];
initialized = false;
dayz_previousID = 0;
DZE_DiagFpsSlow = true; //Dont know if it works in 1041
server_name = ""; 
//disable greeting menu 
player setVariable ["BIS_noCoreConversations", true];
//disable radio messages to be heard and shown in the left lower corner of the screen
enableRadio true;
// May prevent "how are you civillian?" messages from NPC
enableSentences false;
// DayZ Epoch config
spawnShoremode = 1; // Default = 1 (on shore)
spawnArea= 1500; // Default = 1500
MaxHeliCrashes= 5; // Default = 5
MaxVehicleLimit = 50; // Default = 50
MaxDynamicDebris = 0; // Default = 100
MaxMineVeins = 10;  //Default: 50 veins will spawn on map (40% for gems to drop)
dayz_MapArea = 14000;	// Default = 10000

dayz_maxZeds = 100;								// Total zombie limit (Default: 500)
maxWildZombies = 20;							//default: 3
dayz_maxLocalZombies = 20; 				// Max number of zombies spawned per player. (Default: 40)
dayz_maxGlobalZombiesInit = 20; 		// Starting global max zombie count, this will increase for each player within 400m (Default: 40)
dayz_maxGlobalZombiesIncrease = 10;  // This is the amount of global zombie limit increase per player within 400m (Default: 10)
dayz_zedsAttackVehicles = true;

DZE_teleport = [99999,99999,99999,99999,99999]; 

dayz_paraSpawn = false;
dayz_minpos = -1; 
dayz_maxpos = 16000;
dayz_sellDistance_vehicle = 10;
dayz_sellDistance_boat = 30;
dayz_sellDistance_air = 40;
dayz_maxAnimals = 5; // Default: 8
dayz_tameDogs = false;
DynamicVehicleDamageLow = 0; // Default: 0
DynamicVehicleDamageHigh = 100; // Default: 100
//death messages
DZE_DeathMsgGlobal = true;
DZE_DeathMsgSide = true;
DZE_DeathMsgTitleText = true;
dayz_fullMoonNights = true;
DZE_BuildingLimit = 9999;
DZE_BuildOnRoads = false; // Default: False
DZE_PlotPole = [30,45];
DZE_PlayerZed = false;
DZE_HeliLift = false;					//need to be tested
DZE_MissionLootTable = false;		//Custom Loottables activated

////////////////////////////////////////////////////////////////////////////
// Default loadout like init.sqf loadout...or read a 'fake' database loadout.
DefaultTruePreMadeFalse = true;
// Premake player settings in sdbd_fnc_login and sdbd_fnc_setup
DefaultMagazines = ["ItemBandage","ItemBandage","ItemPainkiller","ItemMorphine","FoodSteakCooked","ItemSodaCoke","ItemBloodbag","SmokeShell","30Rnd_556x45_StanagSD","30Rnd_556x45_StanagSD","15Rnd_9x19_M9SD","PartGeneric","PartGeneric","PartWheel","PartWheel"];
DefaultWeapons 	=  ["ItemMap","ItemWatch","ItemToolbox","ItemFlashlightRed","ItemMachete","M9SD","M4A1_AIM_SD_camo","ItemGPS"];
DefaultBackpack = "DZ_Backpack_EP1";
DefaultBackpackWeapon = "";
//To show debug messages in the RPT file
DZEdebug = false;  // Debug messages on log file
////////////////////////////////////////////////////////////////////////////
//Load in compiled functions
call compile preprocessFileLineNumbers "dayz_code\init\variables.sqf";				//Initilize the Variables (IMPORTANT: Must happen very early)
progressLoadingScreen 0.1;
call compile preprocessFileLineNumbers "dayz_code\init\publicEH.sqf";				//Initilize the publicVariable event handlers
progressLoadingScreen 0.2;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\medical\setup_functions_med.sqf";	//Functions used by CLIENT for medical
progressLoadingScreen 0.3;
call compile preprocessFileLineNumbers "dayz_code\init\compiles.sqf"; //Compile custom compiles
progressLoadingScreen 0.4;
if (DefaultTruePreMadeFalse) then {
call compile preprocessFileLineNumbers "dayz_code\init\setupChar.sqf";
}else{
call compile preprocessFileLineNumbers "dayz_code\init\setupChar_Database.sqf";	
};
call compile preprocessFileLineNumbers "server_traders.sqf";				//Compile trader configs
progressLoadingScreen 1.0;

"filmic" setToneMappingParams [0.153, 0.357, 0.231, 0.1573, 0.011, 3.750, 6, 4]; setToneMapping "Filmic";

if (isServer) then {
	call compile preprocessFileLineNumbers "dayz_server\missions\DayZ_Epoch_17.Chernarus\dynamic_vehicle.sqf";	
	_nil = [] execVM "dayz_server\missions\DayZ_Epoch_17.Chernarus\mission.sqf";
	//Run the player monitor
	waitUntil {!isNil "dayz_loadScreenMsg"};
	_id = player addEventHandler ["Respawn", {_id = [] spawn player_death;}];
	_playerMonitor = 	[] execVM "dayz_code\system\player_monitor.sqf";
	if (DZE_R3F_WEIGHT) then {
		_void = [] execVM "\z\addons\dayz_code\external\R3F_Realism\R3F_Realism_Init.sqf";
	};
};

//Start Dynamic Weather
execVM "\z\addons\dayz_code\external\DynamicWeatherEffects.sqf";
#include "\z\addons\dayz_code\system\BIS_Effects\init.sqf"


// Custom Scripts
call compile preprocessFileLineNumbers "custom\bloodbag\init.sqf";   // Bloodbag script
