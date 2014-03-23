private ["_text","_dObj","_isDeployed","_playerUID","_adminList","_allowedDistance","_cursorTarget","_typeOfCursorTarget","_myGuy","_vehicle","_isPZombie","_inVehicle","_itemsPlayer","_hasKnife","_hasToolbox","_hasShovel","_onLadder","_canDo","_mags","_isAir","_isShip","_friendlies","_charID","_rcharID","_rfriendlies"];
_adminList = call compile preProcessFileLineNumbers "superadmins.sqf";
_myGuy = player;
_vehicle = vehicle player;
_isPZombie = player isKindOf "PZombie_VB";
_inVehicle = (_vehicle != player);
_itemsPlayer = items player;
_hasKnife = 	"ItemKnife" in _itemsPlayer;
_hasToolbox = "ItemToolbox" in _itemsPlayer;
_hasShovel = 	"ItemEtool" in _itemsPlayer;
_onLadder =		(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
_canDo = (!r_drag_sqf and !r_player_unconscious and !_onLadder);
_mags = magazines player;
_allowedDistance = 4;
_isAir = cursorTarget isKindOf "Air";
_isShip = cursorTarget isKindOf "Ship";
if(_isAir or _isShip) then {
	_allowedDistance = 8;
};
//	cutText [format["CursTarget: %1",cursorTarget], "PLAIN DOWN"];
if (!isNull cursorTarget and !_inVehicle and !_isPZombie and (player distance cursorTarget < _allowedDistance) and _canDo) then {	//Has some kind of target
	// set cursortarget to variable
	_cursorTarget = cursorTarget;
	_typeOfCursorTarget = typeOf _cursorTarget;
  _ownerID = _cursorTarget getVariable ["CharacterID","0"];
	_playerUID = player getVariable ["playerUID", 0];

	//cutText [format["CursTarget: %1",cursorTarget], "PLAIN DOWN"];

/*
	//To show friendlies with player
	_friendlies = player getVariable ["friendlies", []];
	_playerUID = player getVariable ["playerUID", "0"];

	cutText [format["MyFriendlies: %1\ncharID: %2",
	_friendlies,  // 222222,333333
	_playerUID
	], "PLAIN DOWN"];
*/
	
		// Example on how to use _adminList
    if((typeOf(cursortarget) == "Plastic_Pole_EP1_DZ") and _ownerID != "0" and (player distance _cursorTarget < 2)) then {
        if (_playerUID in _adminList) then {
            cutText [format["Plot Pole Owner PUID is: %1",_playerUID], "PLAIN DOWN"];
        };
     };
	

	//Deployable Vehicles
	_isDeployed = cursorTarget getVariable ["Deployed",false];
	_text = getText (configFile >> "CfgVehicles" >> _typeOfCursorTarget >> "displayName");
	
	if (_isDeployed) then {
		if (s_player_packOBJ < 0) then {
			s_player_packOBJ = player addaction [("<t color=""#00FF04"">" + ("Pack "+_text+"") +"</t>"),"custom\deploy\pack.sqf",cursorTarget,6,false,true,"", ""];
		};
	} else {
		player removeAction s_player_packOBJ;
		s_player_packOBJ = -1;
	};


		
} else {
	//Engineering
	dayz_myCursorTarget = objNull;
	s_player_lastTarget = [objNull,objNull,objNull,objNull,objNull];
	{player removeAction _x} forEach s_player_parts;s_player_parts = [];
	s_player_parts_crtl = -1;
	{player removeAction _x} forEach s_player_lockunlock;s_player_lockunlock = [];
	s_player_lockUnlock_crtl = -1;
	player removeAction s_player_checkGear;
	s_player_checkGear = -1;
	player removeAction s_player_SurrenderedGear;
	s_player_SurrenderedGear = -1;
	//Others
	player removeAction s_player_forceSave;
	s_player_forceSave = -1;
	player removeAction s_player_flipveh;
	s_player_flipveh = -1;
	player removeAction s_player_sleep;
	s_player_sleep = -1;
	//Sleep Base Asset
	player removeAction s_player_sleepba;
	s_player_sleepba = -1;
	player removeAction s_player_deleteBuild;
	s_player_deleteBuild = -1;
	player removeAction s_player_codeRemove;
	s_player_codeRemove = -1;
	player removeAction s_player_disarmBomb;
	s_player_disarmBomb = -1;
	player removeAction s_player_codeObject;
	s_player_codeObject = -1;
	player removeAction s_player_butcher;
	s_player_butcher = -1;
	player removeAction s_player_cook;
	s_player_cook = -1;
	player removeAction s_player_boil;
	s_player_boil = -1;
	player removeAction s_player_fireout;
	s_player_fireout = -1;
	player removeAction s_player_packtent;
	s_player_packtent = -1;
	player removeAction s_player_fillfuel;
	s_player_fillfuel = -1;
	player removeAction s_player_clothes;
	s_player_clothes = -1;
	player removeAction s_player_dance;
  s_player_dance = -1;
	player removeAction s_player_notebook;
	s_player_notebook = -1;
	player removeAction s_player_studybody;
	s_player_studybody = -1;
	player removeAction s_player_bury_human;
	s_player_bury_human = -1;
	player removeAction s_player_tamedog;
	s_player_tamedog = -1;
	player removeAction s_player_feeddog;
	s_player_feeddog = -1;
	player removeAction s_player_waterdog;
	s_player_waterdog = -1;
	player removeAction s_player_staydog;
	s_player_staydog = -1;
	player removeAction s_player_trackdog;
	s_player_trackdog = -1;
	player removeAction s_player_barkdog;
	s_player_barkdog = -1;
	player removeAction s_player_warndog;
	s_player_warndog = -1;
	player removeAction s_player_followdog;
	s_player_followdog = -1;
    // vault
	player removeAction s_player_unlockvault;
	s_player_unlockvault = -1;
	player removeAction s_player_packvault;
	s_player_packvault = -1;
	player removeAction s_player_lockvault;
	s_player_lockvault = -1;
	player removeAction s_player_information;
	s_player_information = -1;
	player removeAction s_player_fillgen;
	s_player_fillgen = -1;
	player removeAction s_player_upgrade_build;
	s_player_upgrade_build = -1;
	player removeAction s_player_maint_build;
	s_player_maint_build = -1;
	player removeAction s_player_downgrade_build;
	s_player_downgrade_build = -1;
	player removeAction s_player_towing;
	s_player_towing = -1;
	player removeAction s_player_fuelauto;
	s_player_fuelauto = -1;
	player removeAction s_player_fuelauto2;
	s_player_fuelauto2 = -1;
	player removeAction s_player_packOBJ;
	s_player_packOBJ = -1;
};