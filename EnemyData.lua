local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local enemyData = {};

function addon.GetEnemyData(name)
	
	for k, v in ipairs(enemyData) do
		if (v.name == name) then
			return v;
		end
	end
	
	return nil;
end

local BS_LOW_SIDEWAYS = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 1, ["angle"] = 0, ["spread"] = 180
						, ["arc"] = 90, ["interval"] = 0.5, ["rotSpeed"] = 1, ["count"] = 2};

table.insert(enemyData, {["name"] = "BossTest", ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 200, ["isBoss"] = true
						,["texture"] = "Interface/ENCOUNTERJOURNAL/UI-EJ-BOSS-Alzzin the Wildshaper", ["sources"] = {BS_LOW_SIDEWAYS}}
			)
table.insert(enemyData, {["name"] = "PlebTest", ["width"] = 32, ["height"] = 32, ["speed"] = 50, ["health"] = 50, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {BS_LOW_SIDEWAYS}
						,["waypoints"] = {{["x"] = 200, ["y"]=400}, {["x"] = 100, ["y"]=300}}}
			)
			