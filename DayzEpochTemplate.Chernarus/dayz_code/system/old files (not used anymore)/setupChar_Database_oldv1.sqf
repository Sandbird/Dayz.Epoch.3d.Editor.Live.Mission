private ["_humanityMorph","_isHiveOk","_newPlayer","_isInfected","_model","_backpackMagTypes","_backpackMagQty","_backpackWpnTypes","_backpackWpnQtys","_countr","_isOK","_backpackType","_backpackWpn","_backpackWater","_mags","_wpns","_bcpk","_bcpkWpn","_config","_playerUID","_msg","_myTime","_charID","_inventory","_backpack","_survival","_isNew","_version","_debug","_lastAte","_lastDrank","_usedFood","_usedWater","_worldspace","_state","_setDir","_setPos","_legs","_arms","_totalMins","_days","_hours","_mins","_messing"];

if(isNil "DZEdebug") then { DZEdebug = false; };
_debug = DZEdebug;
if (_debug) then {
	diag_log ("PSETUP: Initating");
};
//LOGIN INFORMATION
_playerUID = dayz_playerUID;
//diag_log ("PSETUP playerID Player [" + _playerUID + "]");
_msg = [];
dayzPlayerLogin = [];

PVDZE_plr_Login = [_playerUID,player];
publicVariable "PVDZE_plr_Login";

if (isServer) then {
	PVDZE_plr_Login call sdbd_fnc_login;
};

if (count (dayzPlayerLogin) > 1) then {
	_msg = dayzPlayerLogin;
};

//dayzPlayerLogin = [_charID,_inventory,_backpack,_survival,_isNew,dayz_versionNo,_model,_isHiveOk,_newPlayer,_isInfected];

//Parse_Login
dayz_authed = true;
_charID		= _msg select 0;
_inventory	= _msg select 1;
_backpack	= _msg select 2;
_survival 	= _msg select 3;
_isNew 		= _msg select 4;
_state 		= _msg select 5;
_version	= _msg select 5;
_model		= _msg select 6;
_isHiveOk = false;
_newPlayer = false;
_isInfected = false;
diag_log format["survival: %1",_survival];

if (count _msg > 7) then {
	_isHiveOk = _msg select 7;
	_newPlayer = _msg select 8;
	_isInfected = _msg select 9;
//	diag_log ("PLAYER RESULT: " + str(_isHiveOk));
};

dayz_loadScreenMsg = (localize "str_player_17"); 
progressLoadingScreen 0.8;
//if (_debug) then {
//diag_log ("PLOGIN: authenticated with : " + str(_msg));
//};
//Not Equal Failure

if (isNil "_model") then {
	_model = "Survivor2_DZ";
	diag_log ("PSETUP: Model was nil, loading as survivor");
};
if (_model == "") then {
	_model = "Survivor2_DZ";
	diag_log ("PSETUP: Model was empty, loading as survivor");
};
if (_model == "Survivor1_DZ") then {
	_model = "Survivor2_DZ";
};


// Does not work properly
//_model call player_switchModel;



////////////
// Phase_One
////////////
player allowDamage false;
_lastAte = _survival select 1;
_lastDrank = _survival select 2;
_usedFood = 0;
_usedWater = 0;
dayzGearSave = false;
_inventory call player_gearSet;

//player addMagazine "7Rnd_45ACP_1911";

//Assess in backpack
if (count _backpack > 0) then {
	//Populate
	_backpackType = 	_backpack select 0;
	_backpackWpn = 		_backpack select 1;
	_backpackMagTypes = [];
	_backpackMagQty = [];
	if (count _backpackWpn > 0) then {
		_backpackMagTypes = (_backpack select 2) select 0;
		_backpackMagQty = 	(_backpack select 2) select 1;
	};
	_countr = 0;
	_backpackWater = 0;

	//Add backpack
	if (_backpackType != "") then {
		_isOK = 	isClass(configFile >> "CfgVehicles" >>_backpackType);
		if (_isOK) then {
			player addBackpack _backpackType; 
			dayz_myBackpack =	unitBackpack player;
			
			//Fill backpack contents
			//Weapons
			_backpackWpnTypes = [];
			_backpackWpnQtys = [];
			if (count _backpackWpn > 0) then {
				_backpackWpnTypes = _backpackWpn select 0;
				_backpackWpnQtys = 	_backpackWpn select 1;
			};
			_countr = 0;
			{
				if(_x in (DZE_REPLACE_WEAPONS select 0)) then {
					_x = (DZE_REPLACE_WEAPONS select 1) select ((DZE_REPLACE_WEAPONS select 0) find _x);
				};
				dayz_myBackpack addWeaponCargoGlobal [_x,(_backpackWpnQtys select _countr)];
				_countr = _countr + 1;
			} forEach _backpackWpnTypes;
			
			//Magazines
			_countr = 0;
			{
				if (_x == "BoltSteel") then { _x = "WoodenArrow" }; // Convert BoltSteel to WoodenArrow
				if (_x == "ItemTent") then { _x = "ItemTentOld" };
				dayz_myBackpack addMagazineCargoGlobal [_x,(_backpackMagQty select _countr)];
				_countr = _countr + 1;
			} forEach _backpackMagTypes;
			
			dayz_myBackpackMags =	getMagazineCargo dayz_myBackpack;
			dayz_myBackpackWpns =	getWeaponCargo dayz_myBackpack;
		} else {
			dayz_myBackpack		=	objNull;
			dayz_myBackpackMags = [];
			dayz_myBackpackWpns = [];
		};
	} else {
		dayz_myBackpack		=	objNull;
		dayz_myBackpackMags =	[];
		dayz_myBackpackWpns =	[];
	};
} else {
	dayz_myBackpack		=	objNull;
	dayz_myBackpackMags =	[];
	dayz_myBackpackWpns =	[];
};

dayzPlayerLogin2 = [];
//["PVDZE_plr_Login2",[_charID,player,_playerUID]] call callRpcProcedure;

PVDZE_plr_Login2 = [_charID,player,_playerUID];
publicVariable "PVDZE_plr_Login2";
dayz_loadScreenMsg =  "Requesting Character data from server";
progressLoadingScreen 0.9;

if (isServer) then {
	PVDZE_plr_Login2 call sdbd_fnc_setup;
};

if (_debug) then {
	diag_log "Attempting Phase two...";
};

//_msg = 	player getVariable["worldspace",[]];

////////////
// Phase_Two
////////////
dayz_loadScreenMsg =  "Character Data received from server"; 
_worldspace = 	dayzPlayerLogin2 select 0;
_state =				dayzPlayerLogin2 select 1;
_setDir = 			_worldspace select 0;
_setPos = 			_worldspace select 1;
       
if (isNil "freshSpawn") then {
	freshSpawn = 0;
};
       


if(dayz_paraSpawn and (freshSpawn == 2)) then {
	player setDir _setDir;
	player setPosATL [(_setPos select 0),(_setPos select 1),2000];
	//[player,2000] spawn BIS_fnc_halo;
} else {
	// make protective box
	DZE_PROTOBOX = createVehicle ["DebugBoxPlayer_DZ", _setPos, [], 0, "CAN_COLLIDE"];
	DZE_PROTOBOX setDir _setDir;
	DZE_PROTOBOX setPosATL _setPos;
	player setDir _setDir;
	player setPosATL _setPos;
};

       
{
	if (player getVariable["hit_"+_x,false]) then { 
		[player,_x,_x] spawn fnc_usec_damageBleed; 
		usecBleed = [player,_x,_x];
		publicVariable "usecBleed"; // draw blood stream on character, on all gameclients
	};
} forEach USEC_typeOfWounds;
//Legs and Arm fractures
_legs = player getVariable ["hit_legs",0];
_arms = player getVariable ["hit_hands",0];
       
if (_legs > 1) then {
	player setHit["legs",1];
	r_fracture_legs = true;
};
if (_arms > 1) then {
	player setHit["hands",1];
	r_fracture_arms = true;
};
       
//Record current weapon state
dayz_myWeapons = 		weapons player;		//Array of last checked weapons
dayz_myItems = 			items player;		//Array of last checked items
dayz_myMagazines = 	magazines player;
dayz_playerUID = _playerUID;
       

//Work out survival time
_totalMins = _survival select 0;
_days = floor (_totalMins / 1440);
_totalMins = (_totalMins - (_days * 1440));
_hours = floor (_totalMins / 60);
_mins =  (_totalMins - (_hours * 60));
       
if ((count _state > 3) and DZE_FriendlySaving) then {
	DZE_Friends = _state select 3;
}; 
       
//player variables
dayz_characterID =		_charID;
dayz_hasFire = 			objNull;		//records players Fireplace object
dayz_myCursorTarget = 	objNull;
dayz_myPosition = 		getPosATL player;	//Last recorded position
dayz_lastMeal =			(_lastAte * 60);
dayz_lastDrink =		(_lastDrank * 60);
dayz_zombiesLocal = 	0;			//Used to record how many local zombies being tracked
dayz_Survived = _days;  //total alive dayz
dayz_playerName = name player;

//load in medical details
r_player_dead = 		player getVariable["USEC_isDead",false];
r_player_unconscious = 	player getVariable["NORRN_unconscious", false];
r_player_infected =	player getVariable["USEC_infected",false];
r_player_injured = 	player getVariable["USEC_injured",false];
r_player_inpain = 		player getVariable["USEC_inPain",false];
r_player_cardiac = 	player getVariable["USEC_isCardiac",false];
r_player_lowblood =	player getVariable["USEC_lowBlood",false];
r_player_blood = 		player getVariable["USEC_BloodQty",r_player_bloodTotal];
       
//Hunger/Thirst
_messing =			player getVariable["messing",[0,0]];
dayz_hunger = 	_messing select 0;
dayz_thirst = 		_messing select 1;
dayz_loadScreenMsg =  "Character Data received";