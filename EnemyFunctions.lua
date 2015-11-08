﻿local addonName, addon = ...

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

	enemy.y = enemy.y - elapsed * enemy.speed;
	enemy.tY = enemy.y;
	
	return enemy
end

table.insert(addon.enemyFunctions, { ["name"] = "PlebTest", ["func"] = function(enemy, elapsed) return PlebTest(enemy, elapsed); end});

local function WayPoints(enemy, elapsed)

	local targetX, targetY = 0, 0;
	local travelDistance = elapsed * enemy.speed;
	local xDif = 0;
	local yDif = 0;
	local distance = 0;
	
	if (enemy.waypoints[1] ~= nil) then
		targetX = enemy.waypoints[1].x;
		targetY = enemy.waypoints[1].y;

		xDif = enemy.x - targetX;
		yDif = enemy.y - targetY;
		distance = math.sqrt(math.pow(xDif, 2) + math.pow(yDif, 2));
		
		if (distance <= travelDistance ) then
			enemy.x = targetX;
			enemy.y = targetY;
			table.remove(enemy.waypoints, 1);
		else
		
			local angle = math.deg(math.atan2(xDif, yDif)) + 90;
			if angle < 0 then angle = 360 + angle end
			angle = 360 - angle;
		
			local hor = math.cos(math.rad(angle));
			local vert = math.sin(math.rad(angle));
			enemy.x = enemy.x + (travelDistance*hor);
			enemy.y = enemy.y + (travelDistance*vert); --minus because sin 270° = -1 and y = -1 is up
			
			enemy.tY = enemy.y;
			enemy.tX = enemy.x;
		end	
	
	else
		return PlebTest(enemy, elapsed);
	
	end

	return enemy;
end

table.insert(addon.enemyFunctions, { ["name"] = "Waypoints", ["func"] = function(enemy, elapsed) return WayPoints(enemy, elapsed); end});
