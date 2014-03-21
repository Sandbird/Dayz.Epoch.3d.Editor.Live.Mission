private ["_isInfected","_doLoop","_hiveVer","_isHiveOk","_playerID","_playerObj","_primary","_key","_charID","_playerName","_backpack","_isNew","_inventory","_survival","_model","_mags","_wpns","_bcpk","_config","_newPlayer","_isHiveOk"];

if(isNil "DZEdebug") then { DZEdebug = false; };
_debug = DZEdebug;
if (_debug) then {
	diag_log ("PLOGIN: Initating");
};

_playerID = _this select 0;
_playerObj = _this select 1;
_playerName = name _playerObj;

//diag_log format["playerID Player: %1, playerName: %2",_playerID, _playerName];
//diag_log ("playerID Player [" + _playerID + "]");

//if (_playerName == '__SERVER__' || _playerID == '') exitWith {};

//Variables
_inventory =	[];
_backpack = 	[];
_survival =		[0,0,0];
_isInfected =   0;
_model =		"";

/*
if (_playerID == "") then {
	_playerUID = (player getVariable ["playerUID", 0]);
};

if ((_playerID == "") or (isNil "_playerID")) exitWith {
	if (_debug)then{
	diag_log ("LOGIN FAILED: Player [" + _playerName + "] has no login ID");
	};
};
	if (_debug)then{
diag_log ("LOGIN ATTEMPT: " + str(_playerID) + " " + _playerName);
	};
*/

//Do Connection Attempt
_doLoop = 0;
while {_doLoop < 5} do {
	//_key = format["CHILD:101:%1:%2:%3:",_playerID,dayZ_instance,_playerName];
	//_primary = _key call server_hiveReadWrite;
/*	
	OK or Error 							= _primary select 0;
	Is newPlayer (true/false) = _primary select 1;
	_charID   								=	_primary select 2;
	_isInfected (1/0)					= _primary select 3;
	_inventory 								= _primary select 4;
	_backpack 								= _primary select 5;
	_survival									=	_primary select 6;  //last ate+ last drunk +totalminutes alive
	_model 										=	_primary select 7;
	_hiveVer 									=	_primary select 8;
	//[91,[3247.04,8787.94,0.001]]
	//[false,false,false,false,false,false,false,12000,[],[0,0],0,[114.9,42.753]]
	//["M9SD","aidlpknlmstpsraswpstdnon_player_idlesteady02",37,[]]
	
*/
	_primary = call compile format ["%1",primaryPre];  //check variables.sqf at the bottom
	if (count _primary > 0) then {
		if ((_primary select 0) != "ERROR") then {
			_doLoop = 9;
		};
	};
	_doLoop = _doLoop + 1;
};

if (isNull _playerObj or !isPlayer _playerObj) exitWith {
	if (_debug)then{
	diag_log ("LOGIN RESULT: Exiting, player object null: " + str(_playerObj));
	};
};

if ((_primary select 0) == "ERROR") exitWith {
	if (_debug)then{
    diag_log format ["LOGIN RESULT: Exiting, failed to load _primary: %1 for player: %2 ",_primary,_playerID];
  };
};

//Process request
_newPlayer = 	_primary select 1;
_isNew = 		count _primary < 7; //_result select 1;
_charID = 		_primary select 2;
if (_debug)then{
diag_log ("LOGIN RESULT: " + str(_primary));
};

/* PROCESS */
_hiveVer = 11;

if (!_isNew) then {
	//RETURNING CHARACTER		
	_inventory = 	_primary select 4;
	_backpack = 	_primary select 5;
	_survival =		_primary select 6;
	_model =		_primary select 7;
	_hiveVer =		_primary select 8;
	
	if (!(_model in AllPlayers)) then {
		_model = "Survivor2_DZ";
	};
	
};

//diag_log ("LOGIN LOADED: " + str(_playerObj) + " Type: " + (typeOf _playerObj) + " at location: " + (getPosATL _playerObj));

if (worldName == "chernarus") then {
	([4654,9595,0] nearestObject 145259) setDamage 1;
	([4654,9595,0] nearestObject 145260) setDamage 1;
};

//diag_log format["######### dayzPlayerLogin >>> charID:%1, inventory:%2, backpack:%3, survival:%4, isNew:%5, dayzversionNo:%6, model:%7, newPlayer:%9, isInfected:%10",_charID,_inventory,_backpack,_survival,_isNew,dayz_versionNo,_model,_newPlayer,_isInfected];
_isHiveOk = false;
dayzPlayerLogin = [_charID,_inventory,_backpack,_survival,_isNew,dayz_versionNo,_model,_isHiveOk,_newPlayer,_isInfected];
publicVariable "dayzPlayerLogin";
