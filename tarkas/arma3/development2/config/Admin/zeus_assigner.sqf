/*
-------------------------------------
Zeus Assigner (serverside) by Hansen.H
License: Persmission from author only
Last Update: 28APR19 - Further corrections
Format - "64 Bit SteamID", //	(Primary Access Level) Last.F
-------------------------------------

WhiteList:
----------
*/

ACV_ZeusWhiteList = [

"76561197976646388", //	(General) Baeder.S
"76561198102939824", //	(S3 NCOIC) Geki.T
"76561198044786766", //	(S3 Pub Staff) Greibrok.J
"76561198188757405", // (S3 Pub Staff) Skeith.J
"76561198015391577", // (S3 Pub Staff) Tucker.C
"76561197980047087", // (S3 Pub Staff) Tsin.S
"76561198191853361", // (S3 Pub Staff) Waldie.A
"76561198131061103", //	(S3 Pub Staff) Wolfman.C
"76561198039932196", //	(IMO OIC) Jarvis.A
"76561197988661394", //	(IMO) Treck.M
"76561198168754324", // (MP NCOIC) Dakota.N
"76561198019973923", // (MP) Velasquez.J
"76561198006212102", // (MP) Binks.J
"76561198080532671", // (MP) Archer.T
"76561198031348897", // (MP) Gibbs.K
"76561198057951824", //	(A/1-7 XO) Mitsuma.R
"76561198021174042", // (A/1/A/1-7 SL) Robbi.J
"76561198033027736", // (B/1/A/1-7 SL) Muth.S
"76561198015751648", // (C/1/A/1-7 SL) Shepard.J
"76561198020735648", // (2/A/1-7 PL) Ratcliff.M
"76561197990791438", //	(2/A/1-7 PSG) Echelon.E
"76561198106455726", //	(A/2/A/1-7 SL) Colvin.M
"76561198321204423", // (B/2/A/1-7 SL) Cosme.OB
"76561198007260563", //	(B/1-7 CO) Tharen.R
"76561198105515122", // (B/1-7 XO) Storm.A
"76561198081516483", //	(B/1-7 1SG) Ryan.B
"76561198046338375", // (A/1/B/1-7 SL) Manus.E
"76561198191853361", // (2/B/1-7 PSG) Waldie.A
"76561197970381172", // (B/2/B/1-7 SL) Katsu.I
"76561197963459537", // (C/2/B/1-7 SL) Sweetwater.I
"76561198072632764", // (3/B/1-7 PL) Kane.T
"76561198070476801", // (3/B/1-7 PSG) Gerrish.T
"76561198013421442", // (A/3/B/1-7 SL) Nexhex.A
"76561197972476022", // (B/3/B/1-7 SL) Thor.J
"76561198107824267", // (C/3/B/1-7 SL) Grimm.J
"76561198006952602", //	(C/1-7 CO) Rosefield.M
"76561198018765603", //	(C/1-7 XO) Wiese.M
"76561198108752125", // (1/C/1-7 PL) Graton.M
"76561198067238492", // (1/C/1-7 PSG) Atherton.H
"76561198023841569", // (2/C/1-7 PL) Lacombe.M
"76561198070981528", // (A/2/C/1-7 SL) Schmidt.A
"76561198069537665", // (D/2/C/1-7 SL) Morrey.L
"76561198122626607" //  (C/2/C/1-7 SL) Saint.D

];

sleep 5;

0 spawn {
	private ["_uid"];
	while {true} do {
		if (isNil "zeusman1") then {zeusman1 = objNull};
		_uid = getPlayerUID zeusman1;
		if (_uid in ACV_ZeusWhiteList) then {
			if (getAssignedCuratorUnit zeusmodule1 != zeusman1) then {
				zeusman1 assignCurator zeusmodule1;
			};
		} else {
			unassignCurator zeusmodule1;
			if (isPlayer zeusman1) then {
				zeusman1 setPos [0,0,0];
				["You are not authorized to use this slot, vacate the slot!", "hint", zeusman1, false] call BIS_fnc_MP;
				sleep 2;
				[["end1",false], "BIS_fnc_endMission", zeusman1, false] call BIS_fnc_MP;
				sleep 15;
			};
		};
		sleep 5;
	};//while
};

0 spawn {
	private ["_uid"];
	while {true} do {
		if (isNil "zeusman2") then {zeusman2 = objNull};
		_uid = getPlayerUID zeusman2;
		if (_uid in ACV_ZeusWhiteList) then {
			if (getAssignedCuratorUnit zeusmodule2 != zeusman2) then {
				zeusman2 assignCurator zeusmodule2;
			};
		} else {
			unassignCurator zeusmodule2;
			if (isPlayer zeusman2) then {
				zeusman2 setPos [0,0,0];
				["You are not authorized to use this slot, vacate the slot!", "hint", zeusman2, false] call BIS_fnc_MP;
				sleep 2;
				[["end1",false], "BIS_fnc_endMission", zeusman2, false] call BIS_fnc_MP;
				sleep 15;
			};
		};
		sleep 5;
	};//while
};

0 spawn {
	private ["_uid"];
	while {true} do {
		if (isNil "zeusman3") then {zeusman3 = objNull};
		_uid = getPlayerUID zeusman3;
		if (_uid in ACV_ZeusWhiteList) then {
			if (getAssignedCuratorUnit zeusmodule3 != zeusman3) then {
				zeusman3 assignCurator zeusmodule3;
			};
		} else {
			unassignCurator zeusmodule3;
			if (isPlayer zeusman3) then {
				zeusman3 setPos [0,0,0];
				["You are not authorized to use this slot, vacate the slot!", "hint", zeusman3, false] call BIS_fnc_MP;
				sleep 2;
				[["end1",false], "BIS_fnc_endMission", zeusman3, false] call BIS_fnc_MP;
				sleep 15;
			};
		};
		sleep 5;
	};//while
};
0 spawn {
	private ["_uid"];
	while {true} do {
		if (isNil "zeusman4") then {zeusman4 = objNull};
		_uid = getPlayerUID zeusman4;
		if (_uid in ACV_ZeusWhiteList) then {
			if (getAssignedCuratorUnit zeusmodule4 != zeusman4) then {
				zeusman4 assignCurator zeusmodule4;
			};
		} else {
			unassignCurator zeusmodule4;
			if (isPlayer zeusman4) then {
				zeusman4 setPos [0,0,0];
				["You are not authorized to use this slot, vacate the slot!", "hint", zeusman4, false] call BIS_fnc_MP;
				sleep 2;
				[["end1",false], "BIS_fnc_endMission", zeusman4, false] call BIS_fnc_MP;
				sleep 15;
			};
		};
		sleep 5;
	};//while
};

0 spawn {

while {true} do {
	{
		_currentCurator = _x;
		{
			_currentCurator addCuratorEditableObjects [[_x],true ];
		} forEach allPlayers;
	} forEach allCurators;
	sleep 30;
};

};
