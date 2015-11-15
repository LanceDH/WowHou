local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local level = {};
level.name = "Deadmines";
level.image = "Interface/LFGFRAME/UI-LFG-BACKGROUND-DEADMINES";
level.enemies = {};
local Bs = addon.BulletStream;

table.insert(addon.Levels, level);

-- Bullet source presets
local BS_LOW_SIDEWAYS = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 1, ["angle"] = 0, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.5, ["count"] = 2};
							
local BS_ADD_BOMB = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 315
							, ["arc"] = 360, ["interval"] = 2, ["count"] = 8};

local BS_BOSS_ROTATE = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "ROTATE", ["rotSpeed"] = 0.05, ["angle"] = 90, ["spread"] = 360
							, ["arc"] = 360, ["interval"] = 0.1, ["count"] = 2};
							
							
local BS_BOSS_DEFAULTLEFT = {["x"] = -40, ["y"] = -20, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.4, ["count"] = 1};
local BS_BOSS_DEFAULTRIGHT = {["x"] = 40, ["y"] = -20, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.4, ["count"] = 1};

							
-- unit functions
local function Bomb(enemy, elapsed)
	
	if(enemy.elapsed > 2.5) then
		enemy:Hide();
	end
	
	return enemy
end

local BossAdd1 = {["name"] = "add1", ["func"] = function(enemy, elapsed) return Bomb(enemy, elapsed); end, ["x"] = 0, ["y"] = 0, ["invulnerable"] = true, ["isAdd"] = "true"
							, ["width"] = 64, ["height"] = 64, ["speed"] = 0, ["health"] = 1, ["texture"] = "Interface/SPELLBOOK/UI-GlyphFrame-Locked", ["sources"] = {BS_ADD_BOMB}}
							
local function BossSpawnBomb(enemy)
	for i=1, 1 do
		local data = {};
		for k, v in pairs(BossAdd1) do
			data[k] = v;
		end
		data.y = math.random(GAMEFIELD_HEIGHT-128);
		data.x = math.random(GAMEFIELD_WIDTH);
		data.owner = enemy;
		addon.CreateEnemy(data);
	end
end
							
local function Glubtok(enemy, elapsed)

	if (enemy.phase == 2 and enemy.health / enemy.healthMax <= 0.5) then
		enemy.sources = {};
		table.insert(enemy.sources, Bs(enemy.x, enemy.y, BS_BOSS_ROTATE, true));
		
		enemy.tX = GAMEFIELD_WIDTH/2;
		enemy.tY = GAMEFIELD_HEIGHT/2;
		enemy.phase = 3;
		enemy.tickCount = 0;
	end
	
	if (enemy.phase == 2) then
		enemy.tX = enemy.x + math.sin(enemy.elapsed) * 75;
		enemy.tY = enemy.y;

	elseif (enemy.phase == 3) then
		enemy.tickCount = enemy.tickCount + elapsed;
		
		if(enemy.tickCount >= 2) then
			enemy.tickCount = enemy.tickCount - 2;
			BossSpawnBomb(enemy);
		end
	
		
	end
	return enemy
end


-- Units



-- table.insert(level.enemies , {["time"] = 2, ["name"] = "PlebTest", ["funcName"] = "Waypoints", ["x"] = GAMEFIELD_WIDTH/4, ["y"] = GAMEFIELD_HEIGHT , ["width"] = 32, ["height"] = 32
							-- , ["speed"] = 50, ["health"] = 50, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {BS_LOW_SIDEWAYS}
							-- ,["waypoints"] = {{["x"] = 200, ["y"]=400}, {["x"] = 100, ["y"]=300}}})
-- table.insert(level.enemies , {["time"] = 2, ["name"] = "Trash1", ["func"] = addon.enemyFunctions.waypoints, ["x"] = GAMEFIELD_WIDTH/3, ["y"] = GAMEFIELD_HEIGHT
							-- , ["width"] = 32, ["height"] = 32, ["speed"] = 100, ["health"] = 50, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {BS_LOW_SIDEWAYS}
							-- , ["waypoints"] = {{["x"] = 2*GAMEFIELD_WIDTH/3, ["y"]=GAMEFIELD_HEIGHT/2}}})
-- table.insert(level.enemies , {["time"] = 2, ["name"] = "Trash1", ["func"] = addon.enemyFunctions.waypoints, ["x"] = 2*GAMEFIELD_WIDTH/3, ["y"] = GAMEFIELD_HEIGHT
							-- , ["width"] = 32, ["height"] = 32, ["speed"] = 100, ["health"] = 50, ["texture"] = "Interface/WORLDSTATEFRAME/OrcHead", ["sources"] = {BS_LOW_SIDEWAYS}
							-- , ["waypoints"] = {{["x"] = GAMEFIELD_WIDTH/3, ["y"]=GAMEFIELD_HEIGHT/2}}})
table.insert(level.enemies , {["time"] = 2, ["name"] = "Glubtok", ["func"] = function(enemy, elapsed) return Glubtok(enemy, elapsed); end, ["x"] = GAMEFIELD_WIDTH/2, ["y"] = GAMEFIELD_HEIGHT
							, ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 200, ["isBoss"] = true, ["texture"] = "Interface/ENCOUNTERJOURNAL/UI-EJ-BOSS-Glubtok"
							, ["sources"] = {BS_BOSS_DEFAULTLEFT, BS_BOSS_DEFAULTRIGHT}, ["intro"] = "VO_DM_GlubtokHead1_Aggro01", ["introDur"] = 4, ["introText"] = "Glubtok show you da power of de arcane!"
							, ["waypoints"] = {{["x"] = GAMEFIELD_WIDTH/2, ["y"]=GAMEFIELD_HEIGHT - 64}}})
							
							
							