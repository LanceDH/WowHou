local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local level = {};
level.name = "Deadmines";
level.image = "Interface/LFGFRAME/UI-LFG-BACKGROUND-DEADMINES";
level.enemies = {};

table.insert(addon.Levels, level);

-- Bullet source presets
local BS_LOW_SIDEWAYS = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 1, ["angle"] = 0, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.5, ["count"] = 2};
							
local BS_ADD_ROTATION = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "ROTATE", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.1, ["count"] = 2};


local BossAdd1 = {["name"] = "add1", ["func"] = function(enemy, elapsed) return enemy; end, ["x"] = 0, ["y"] = 0, ["invulnerable"] = true, ["isAdd"] = "true"
							, ["width"] = 0, ["height"] = 0, ["speed"] = 0, ["health"] = 1, ["texture"] = "", ["sources"] = {BS_ADD_ROTATION}}

							
-- unit functions
local function Glubtok(enemy, elapsed)

	if (enemy.phase == 2 and enemy.health / enemy.healthMax <= 0.5) then
		enemy.phase = 3;
	end
	
	if (enemy.phase == 2 or enemy.phase == 4) then
		enemy.tX = enemy.x + math.sin(enemy.elapsed) * 50;
		enemy.tY = enemy.y;

	elseif (enemy.phase == 3) then
		for i=1, 5 do
		local data = {};
		for k, v in pairs(BossAdd1) do
			data[k] = v;
		end
		data.y = math.random(GAMEFIELD_HEIGHT);
		data.x = math.random(GAMEFIELD_WIDTH);
		data.owner = enemy;
		addon.CreateEnemy(data);
		end
		enemy.phase = 4;
	end
	return enemy
end

-- table.insert(level.enemies , {["time"] = 2, ["name"] = "PlebTest", ["funcName"] = "Waypoints", ["x"] = GAMEFIELD_WIDTH/4, ["y"] = GAMEFIELD_HEIGHT , ["width"] = 32, ["height"] = 32
							-- , ["speed"] = 50, ["health"] = 50, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {BS_LOW_SIDEWAYS}
							-- ,["waypoints"] = {{["x"] = 200, ["y"]=400}, {["x"] = 100, ["y"]=300}}})
table.insert(level.enemies , {["time"] = 2, ["name"] = "Glubtok", ["func"] = function(enemy, elapsed) return Glubtok(enemy, elapsed); end, ["x"] = GAMEFIELD_WIDTH/2, ["y"] = GAMEFIELD_HEIGHT
							, ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 200, ["isBoss"] = true, ["texture"] = "Interface/ENCOUNTERJOURNAL/UI-EJ-BOSS-Glubtok"
							, ["sources"] = {BS_LOW_SIDEWAYS}, ["intro"] = "VO_DM_GlubtokHead1_Aggro01", ["introDur"] = 4, ["introText"] = "Glubtok show you da power of de arcane!"
							, ["waypoints"] = {{["x"] = GAMEFIELD_WIDTH/2, ["y"]=GAMEFIELD_HEIGHT - 64}}})