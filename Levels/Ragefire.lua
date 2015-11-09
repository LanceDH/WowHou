local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local level = {};
level.name = "Ragefire Chasm";
level.image = "Interface/LFGFRAME/UI-LFG-BACKGROUND-RAGEFIRECHASM";
level.enemies = {};

table.insert(addon.Levels, level);

table.insert(level.enemies , {["time"] = 2, ["name"] = "PlebTest", ["funcName"] = "Waypoints", ["x"] = GAMEFIELD_WIDTH/4, ["y"] = GAMEFIELD_HEIGHT })
table.insert(level.enemies , {["time"] = 8, ["name"] = "PlebTest", ["funcName"] = "Waypoints", ["x"] = GAMEFIELD_WIDTH/4, ["y"] = GAMEFIELD_HEIGHT })
table.insert(level.enemies , {["time"] = 10, ["name"] = "BossTest", ["funcName"] = "BossTest", ["x"] = GAMEFIELD_WIDTH/2, ["y"] = GAMEFIELD_HEIGHT - 64})

