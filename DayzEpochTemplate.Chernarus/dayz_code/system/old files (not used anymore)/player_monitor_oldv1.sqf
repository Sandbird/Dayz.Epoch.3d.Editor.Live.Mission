dayz_forceSave = {
_gearSave = false;

if (!dialog) then {
	createGearDialog [player, "RscDisplayGear"];
	_gearSave = true;
};

_dialog = 			findDisplay 106;
_magazineArray = 	[];

//Primary Mags
for "_i" from 109 to 120 do 
{
	_control = 	_dialog displayCtrl _i;
	_item = 	gearSlotData _control;
	_val =		gearSlotAmmoCount _control;
	_max = 		getNumber (configFile >> "CfgMagazines" >> _item >> "count");
	if (_item != "") then {
		if (_val != _max) then {
			_magazineArray set [count _magazineArray,[_item,_val]];
		} else {
			_magazineArray set [count _magazineArray,_item];
		};
	};
};

//Secondary Mags
for "_i" from 122 to 129 do 
{
	_control = 	_dialog displayCtrl _i;
	_item = 	gearSlotData _control;
	_val =		gearSlotAmmoCount _control;
	_max = 		getNumber (configFile >> "CfgMagazines" >> _item >> "count");
	if (_item != "") then {
		if (_val != _max) then {
			_magazineArray set [count _magazineArray,[_item,_val]];
		} else {
			_magazineArray set [count _magazineArray,_item];
		};
	};
};

if (_gearSave) then {
	closeDialog 0;
};

	_medical = player call player_sumMedical;
		
	/*
		Get character state details
	*/
	_currentWpn = 	currentMuzzle player;
	_currentAnim =	animationState player;
	_config = 		configFile >> "CfgMovesMaleSdr" >> "States" >> _currentAnim;
	_onLadder =		(getNumber (_config >> "onLadder")) == 1;
	_isTerminal = 	(getNumber (_config >> "terminal")) == 1;
	_isInVehicle = vehicle player != player;
	//_wpnDisabled =	(getNumber (_config >> "disableWeapons")) == 1;
	_currentModel = typeOf player;
	_charPos = getPosATL player;
	_playerPos = 	[round(direction player),_charPos];
	
	if (_onLadder or _isInVehicle or _isTerminal) then {
		_currentAnim = "";
		//If position to be updated, make sure it is at ground level!
		if ((count _playerPos > 0) and !_isTerminal) then {
			_charPos set [2,0];
			_playerPos set[1,_charPos];
		};
	};
	if (_isInVehicle) then {
		_currentWpn = "";
	} else {
		if ( typeName(_currentWpn) == "STRING" ) then {
			_muzzles = getArray(configFile >> "cfgWeapons" >> _currentWpn >> "muzzles");
			if (count _muzzles > 1) then {
				_currentWpn = currentMuzzle player;
			};	
		} else {
			//diag_log ("DW_DEBUG: _currentWpn: " + str(_currentWpn));
			_currentWpn = "";
		};
	};
	_temp = round(player getVariable ["temperature",100]);
	_currentState = [_currentWpn,_currentAnim,_temp];
	
	dayz_Magazines = _magazineArray;
	PVDZE_plr_Save = [player,dayz_Magazines,false,true];
	publicVariable "PVDZE_plr_Save";
			
	if (isServer) then {
//		PVDZE_plr_Save call server_playerSync;
	};
						
	dayz_lastSave = diag_tickTime;
	dayz_Magazines = [];
};

dayz_medicalH = 	[] execVM "\z\addons\dayz_code\medical\init_medical.sqf";	//Medical Monitor Script (client only)
[player] call fnc_usec_damageHandle;

if (r_player_unconscious) then {
	r_player_timeout = player getVariable["unconsciousTime",0];
	player playActionNow "Die";
};

player allowDamage true;
player enableSimulation true;
//0 cutText ["", "BLACK IN",3];
//Add core tools
//player addMagazine "ItemWaterbottle";
//player addWeapon "Flare";
if ((currentWeapon player == "")) then { player action ["SWITCHWEAPON", player,player,1]; };
//load in medical details
r_player_dead = 		player getVariable["USEC_isDead",false];
r_player_unconscious = 	player getVariable["NORRN_unconscious", false];
r_player_infected =		player getVariable["USEC_infected",false];
r_player_injured = 		player getVariable["USEC_injured",false];
r_player_inpain = 		player getVariable["USEC_inPain",false];
r_player_cardiac = 		player getVariable["USEC_isCardiac",false];
r_player_lowblood =		player getVariable["USEC_lowBlood",false];
r_player_blood = 		player getVariable["USEC_BloodQty",r_player_bloodTotal];
"colorCorrections" ppEffectEnable true;
"colorCorrections" ppEffectAdjust [1, 1, 0, [1, 1, 1, 0.0], [1, 1, 1, 1 min (4*r_player_blood/3/r_player_bloodTotal)],  [1, 1, 1, 0.0]];
"colorCorrections" ppEffectCommit 0;


dayz_gui = [] spawn {
	private["_distance"];
	dayz_musicH = [] spawn player_music;
	_wasInVehicle = false;
	_thisVehicle = objNull;
	while {true} do {
		_array = player call world_surfaceNoise;
		dayz_surfaceNoise = _array select 1;
		dayz_surfaceType = 	_array select 0;

		call player_checkStealth;
		dayz_statusArray = [] call player_updateGui;

		_vehicle = vehicle player;
		if (_vehicle != player) then {
			_wasInVehicle = true;
			_thisVehicle = _vehicle;
        	} else {
			if (_wasInVehicle) then {
				_wasInVehicle = false;
				//_thisVehicle call player_antiWall;
			};
		};
		sleep 0.2;
	};
};

dayz_slowCheck = 	[] spawn player_spawn_2;

_world = toUpper(worldName); //toUpper(getText (configFile >> "CfgWorlds" >> (worldName) >> "description"));
_nearestCity = nearestLocations [getPos player, ["NameCityCapital","NameCity","NameVillage","NameLocal"],1000];
Dayz_logonTown = "Wilderness";

if (count _nearestCity > 0) then {Dayz_logonTown = text (_nearestCity select 0)};

_first = [_world,Dayz_logonTown,localize ("str_player_06") + " " + str(_days)] spawn BIS_fnc_infoText;

Dayz_logonTime = daytime;
Dayz_logonDate = dayz_Survived;

dayz_animalCheck = 	[] spawn player_spawn_1;

dayz_spawnCheck = [] spawn {
	while {true} do {
		["both"] call player_spawnCheck;
		sleep 8;
	};
};

dayz_Totalzedscheck = [] spawn {
	while {true} do {
		dayz_maxCurrentZeds = {alive _x} count entities "zZombie_Base";
		sleep 60;
	};
};

dayz_backpackcheck = [] spawn {
	while {true} do {
		call player_dumpBackpack;
		sleep 1;
	};
};

// TODO: questionably
{ _x call fnc_veh_ResetEH; } forEach vehicles;

private["_fadeFire"];
{
	_fadeFire = _x getVariable['fadeFire', true];
	if (!_fadeFire) then {
		_nul = [_x,2,0,false,false] spawn BIS_Effects_Burn;
	};
} forEach entities "SpawnableWreck";

// remove box 
[] spawn {
	private ["_counter"];
	_counter = 0;
	while {true} do {
		if ((player getVariable["combattimeout", 0] >= time) or (_counter >= 60) or (player distance DZE_PROTOBOX > 2)) exitWith {
			deleteVehicle DZE_PROTOBOX;
		};
		sleep 1;
		_counter = _counter + 1;
	};
};


//Bring up display
//call player_updateGui;


_myLoc = getPosATL player;
3 cutRsc ["playerStatusGUI", "PLAIN",0];
//5 cutRsc ["playerKillScore", "PLAIN",2];
//Update GUI
call player_updateGui;
_id = [] spawn {
	disableSerialization;
	_display = uiNamespace getVariable 'DAYZ_GUI_display';
	_control = 	_display displayCtrl 1204;
	_control ctrlShow false;
	if (!r_player_injured) then {
		_ctrlBleed = 	_display displayCtrl 1303;
		_ctrlBleed ctrlShow false;
	};
	if (!r_fracture_legs and !r_fracture_arms) then {
		_ctrlFracture = 	_display displayCtrl 1203;
		_ctrlFracture ctrlShow false;
	};
};
call ui_changeDisplay;

//Load_In
{player reveal _x} forEach (nearestObjects [getPosATL player, dayz_reveal, 50]);
dayz_clientPreload = true;
3 fadeSound 1;
1 cutText ["", "PLAIN"];
0 fadeMusic 0.5;
//Check mission objects
{
	if (typeOf _x == "RoadFlare") then {
		_id = [_x,0] spawn object_roadFlare
	} else {
		 _id = [_x,1] spawn object_roadFlare
	};
 } forEach (allMissionObjects "LitObject");



//Preload_Display
dayz_lastCheckBit = 0;

(findDisplay 46) displayAddEventHandler ["KeyDown","_this call dayz_spaceInterrupt"];
player disableConversation true;

eh_player_killed = player addeventhandler ["FiredNear",{_this call player_weaponFiredNear;} ];
//_eh_combat_projectilenear = player addEventHandler ["IncomingFire",{_this call player_projectileNear;}];

//Select Weapon
// Desc: select default weapon & handle multiple muzzles
_playerObjName = format["PVDZE_player%1",_playerUID];
call compile format["PVDZE_player%1 = player;",_playerUID];
////diag_log (format["player%1 = player",_playerUID]);
publicVariable _playerObjName;

_state = player getVariable["state",[]];
_currentWpn = "";
_currentAnim = "";
if (count _state > 0) then {
	//Reload players state
	_currentWpn		=	_state select 0;
	_currentAnim	=	_state select 1;
	//Reload players state
	if (count _state > 2) then {
		dayz_temperatur = _state select 2;
	}; 
	if ((count _state > 3) and DZE_FriendlySaving) then {
		DZE_Friends = _state select 3;
	}; 
} else {
	_currentWpn	=	"Makarov";
	_currentAnim	=	"aidlpercmstpsraswpstdnon_player_idlesteady02";
};

if (player hasWeapon "MeleeCrowbar") then {
	player removeMagazine 'crowbar_swing';	
	player addMagazine 'crowbar_swing';
};
if (player hasWeapon "MeleeSledge") then {
	player removeMagazine 'sledge_swing';	
	player addMagazine 'sledge_swing';
};
if (player hasWeapon "MeleeHatchet_DZE") then {
	player removeMagazine 'Hatchet_Swing';		
	player addMagazine 'Hatchet_Swing';
};
if (player hasWeapon "MeleeMachete") then {
	player removeMagazine 'Machete_Swing';		
	player addMagazine 'Machete_Swing';
};
if (player hasWeapon "MeleeFishingPole") then {
	player removeMagazine 'Fishing_Swing';		
	player addMagazine 'Fishing_Swing';
};

reload player;

if (_currentAnim != "" and !dayz_paraSpawn) then {
	[objNull, player, rSwitchMove,_currentAnim] call RE;
};

if (_currentWpn != "") then {
	player selectWeapon _currentWpn;
} else {
	//Establish default weapon
	if (count weapons player > 0) then
	{
		private["_type", "_muzzles"];

		_type = ((weapons player) select 0);
		// check for multiple muzzles (eg: GL)
		_muzzles = getArray(configFile >> "cfgWeapons" >> _type >> "muzzles");

		if (count _muzzles > 1) then {
			player selectWeapon (_muzzles select 0);
		} else {
			player selectWeapon _type;
		};
	};
};

//Player control loop
dayz_monitor1 = [] spawn {
	while {true} do {
		call player_zombieCheck;
		call debug_monitor;
		sleep 1;
	};
};



dayzGearSave = true;
dayz_myPosition = getPosATL player;
PVDZE_plr_LoginRecord = [_playerUID,_charID,0];
publicVariable "PVDZE_plr_LoginRecord";

