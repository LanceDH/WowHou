local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local PHASE1 = 0;
local PHASE2 = 1;

addon.enemyFunctions = {};

function addon.GetEnemyFunction(name)
	for k, v in ipairs(addon.enemyFunctions) do
		if (v.name == name) then
			return v.func;
		end
	end
	
	return nil;
end

local function BossTest(enemy, elapsed)

	enemy.tX = enemy.x + math.sin(enemy.elapsed) * 50;
	enemy.tY = enemy.y;
	
	
	-- if (enemy.phase == PHASE1 and enemy.elapsed > 10) then
		-- enemy.phase = PHASE2;
		-- enemy.sources = {};
		-- local sources = {{["x"] = -50, ["y"] = -32, ["speed"] = 100, ["dir"] = 1, ["bType"] = "WAVE"}
						-- ,{["x"] = 50, ["y"] = -32, ["speed"] = 100, ["dir"] = -1, ["bType"] = "WAVE"}			
						-- };			
		-- table.insert(enemy.sources, Bs(enemy.x, enemy.y, 0.1, 3, sources));
	-- end
	
	-- if (enemy.elapsed > 4) then
		-- enemy.texture:Hide();
	-- end
	
	return enemy
end

table.insert(addon.enemyFunctions, { ["name"] = "BossTest", ["func"] = function(enemy, elapsed) return BossTest(enemy, elapsed); end});

local function PlebTest(enemy, elapsed)

	--enemy.tX = enemy.x + math.sin(enemy.elapsed) * 50;
	enemy.y = enemy.y  -- - elapsed * enemy.speed;
	enemy.tY = enemy.y;
	
	return enemy
end

table.insert(addon.enemyFunctions, { ["name"] = "PlebTest", ["func"] = function(enemy, elapsed) return PlebTest(enemy, elapsed); end});