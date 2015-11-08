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

table.insert(enemyData, {["name"] = "BossTest", ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 1000
							, ["texture"] = "Interface/ENCOUNTERJOURNAL/UI-EJ-BOSS-Alzzin the Wildshaper", ["sources"] = {{["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "WAVE", ["rotSpeed"] = 1}}}
			)
table.insert(enemyData, {["name"] = "PlebTest", ["width"] = 32, ["height"] = 32, ["speed"] = 50, ["health"] = 50
							, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {{["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = 1, ["bType"] = "ROTATE", ["rotSpeed"] = 1}}}
							--, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {}}
			)
			