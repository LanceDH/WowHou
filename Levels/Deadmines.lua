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
							
local BS_ADD_BOMB = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 360
							, ["arc"] = 360, ["interval"] = 2, ["count"] = 10};

local BS_BOSS_ROTATE = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "ROTATE", ["rotSpeed"] = 0.05, ["angle"] = 0, ["spread"] = 360
							, ["arc"] = 360, ["interval"] = 0.1, ["count"] = 2};
							
							
local BS_BOSS_DEFAULTLEFT = {["x"] = -40, ["y"] = -20, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 270, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.4, ["count"] = 1};
local BS_BOSS_DEFAULTRIGHT = {["x"] = 40, ["y"] = -20, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 270, ["spread"] = 180
							, ["arc"] = 90, ["interval"] = 0.4, ["count"] = 1};
local BS_FELIX_CHARGE = {["x"] = 0, ["y"] = 0, ["speed"] = 100, ["dir"] = -1, ["bType"] = "", ["rotSpeed"] = 0.5, ["angle"] = 0, ["spread"] = 20
							, ["arc"] = 90, ["interval"] = 0.1, ["count"] = 3};
							
-- unit functions
local function Bomb(enemy, elapsed)
	
	if(enemy.elapsed > 2.5) then
		enemy:Hide();
	end
	
	return enemy
end

local BossAdd1 = {["name"] = "add1", ["func"] = function(enemy, elapsed) return Bomb(enemy, elapsed); end, ["x"] = 0, ["y"] = 0, ["invulnerable"] = true, ["isAdd"] = "true"
							, ["width"] = 64, ["height"] = 64, ["speed"] = 0, ["health"] = 1, ["texture"] = "Interface/SPELLBOOK/UI-GlyphFrame-Locked", ["sources"] = {BS_ADD_BOMB}}
							
local function BossSpawnBomb(enemy, count)
	for i=1, (count and count or 1) do
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
		enemy.tX = GAMEFIELD_WIDTH/2;
		enemy.tY = GAMEFIELD_HEIGHT/2;
		enemy.phase = 3;
		enemy.tickCount = 0;
		enemy.soundCount = 0;
		enemy.soundPlayed = false;
		enemy.invulnerable = true;
	end
	
	if (enemy.phase ~= 10 and enemy.health <= 0) then
		enemy.sources = {};
		enemy.phase = 10;
		enemy.soundCount = 0;
		enemy.soundPlayed = false;
		enemy.tickCount = 0;
	end
	
	if (enemy.phase == 2) then
		enemy.tX = enemy.x + math.sin(enemy.elapsed) * 75;
		enemy.tY = enemy.y;

	elseif (enemy.phase == 3) then
		-- Glubtok ready?
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_GlubtokHead1_Spell02");
			enemy.soundPlayed = true;
		end
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 2) then
			enemy.phase = 4;
			enemy.soundCount = 0;
			enemy.soundPlayed = false;
		end
	elseif (enemy.phase == 4) then
		-- Let's do it!
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_GlubtokHead2_Spell02");
			enemy.soundPlayed = true;
		end
		
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 2) then
			enemy.phase = 5;
			enemy.soundCount = 0;
			table.insert(enemy.sources, Bs(enemy.x, enemy.y, BS_BOSS_ROTATE, true));
			enemy.soundPlayed = false;
		end
	elseif (enemy.phase == 5) then
		-- ARCANE POWER!!!
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_GlubtokBoth_Spell03");
			enemy.soundPlayed = true;
		end
		
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 5) then
			enemy.phase = 6;
			enemy.soundCount = 0;
			enemy.invulnerable = false;
			enemy.soundPlayed = false;
		end
		
		enemy.tickCount = enemy.tickCount + elapsed;
		
		if(enemy.tickCount >= 2) then
			enemy.tickCount = enemy.tickCount - 2;
			BossSpawnBomb(enemy);
		end
		
	elseif (enemy.phase == 6) then
		
		enemy.tickCount = enemy.tickCount + elapsed;
		
		if(enemy.tickCount >= 2) then
			enemy.tickCount = enemy.tickCount - 2;
			BossSpawnBomb(enemy);
		end
		
	elseif (enemy.phase == 10) then
		-- TOO...MUCH...POWER!!!
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_GlubtokBoth_Death01");
			enemy.soundPlayed = true;
		end
		
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 6) then
			enemy.soundCount = 0;
			enemy.soundPlayed = false;
			enemy:Hide();
		end
		
	end
	return enemy
end

local bombTimer = 0;
local bombWait = 4;
local bombCount = 2;

local function Felix(enemy, elapsed)

	if (enemy.phase ~= 10 and enemy.health <= 0) then
		enemy.sources = {};
		enemy.phase = 10;
		enemy.soundCount = 0;
		enemy.soundPlayed = false;
		enemy.tickCount = 0;
	end
	
	if (enemy.phase < 5 and enemy.health / enemy.healthMax <= 0.25) then
		enemy.sources = {};
		enemy.phase = 5;
		enemy.x = GAMEFIELD_WIDTH / 2;
		enemy.y = GAMEFIELD_HEIGHT - 128;
		enemy.tX = enemy.x;
		enemy.tY = enemy.y;
		enemy.frame.arrow:Hide();
		bombWait = 2;
		bombCount = 3;
		enemy.soundCount = 0;
		enemy.soundPlayed = false;
		enemy.tickCount = 0;
	end
	
	-- always throw bombs unless dead
	if (enemy.phase ~= 10) then
	
		bombTimer = bombTimer + elapsed;

		if(bombTimer >= bombWait) then
			bombTimer = bombTimer - bombWait;
			BossSpawnBomb(enemy, bombCount);
		end
	end
	
	if (enemy.phase == 2) then
		-- pick location to charge
		enemy.speed = 400;
		enemy.frame.arrow:Show();
		enemy.targetX = math.random(GAMEFIELD_WIDTH-64)+32;
		enemy.targetY = math.random(GAMEFIELD_HEIGHT-64)+32;
		local distance = math.sqrt(math.pow(enemy.x - enemy.targetX, 2) + math.pow(enemy.y - enemy.targetY, 2));
		while (distance <= 256) do
			enemy.targetX = math.random(GAMEFIELD_WIDTH-64)+32;
			enemy.targetY = math.random(GAMEFIELD_HEIGHT-64)+32;
			distance = math.sqrt(math.pow(enemy.x - enemy.targetX, 2) + math.pow(enemy.y - enemy.targetY, 2));
		end
		
		enemy.phase = 3;
		enemy:ArrowAngleRad(math.atan2(enemy.targetY - enemy.y, enemy.targetX - enemy.x));
		
	elseif (enemy.phase == 3) then
		-- wait before charging
		enemy.tickCount = enemy.tickCount + elapsed;
		if (enemy.tickCount >= 2) then
			enemy.phase = 4;
			enemy.tickCount = 0;
			BS_FELIX_CHARGE.angle = math.deg(math.atan2(enemy.targetY - enemy.y, enemy.targetX - enemy.x));
			if BS_FELIX_CHARGE.angle < 0 then BS_FELIX_CHARGE.angle = 360 + BS_FELIX_CHARGE.angle end
			BS_FELIX_CHARGE.angle = 180 - BS_FELIX_CHARGE.angle;
			enemy.frame.arrow:Hide();
			
			--print(BS_FELIX_CHARGE.angle);
			table.insert(enemy.sources, Bs(enemy.x, enemy.y, BS_FELIX_CHARGE, true));
		end
	
	elseif (enemy.phase == 4) then
		-- charge
		--enemy.tickCount = enemy.tickCount + elapsed;
		local travelDistance = elapsed * enemy.speed;
		local distance = math.sqrt(math.pow(enemy.x - enemy.targetX, 2) + math.pow(enemy.y - enemy.targetY, 2));
		
		if (distance <= travelDistance ) then
			enemy.x = enemy.targetX;
			enemy.y = enemy.targetY;
			enemy.waypointNr = enemy.waypointNr + 1;
			--pick new location
			enemy.phase = 2;
			enemy.sources = {};
		else
			local angle = math.deg(math.atan2(enemy.targetY - enemy.y, enemy.targetX - enemy.x));
			if angle < 0 then angle = 360 + angle end
			angle = 360 - angle;
		
			local hor = math.cos(math.rad(angle));
			local vert = math.sin(math.rad(angle));
			enemy.x = enemy.x + (travelDistance*hor);
			enemy.y = enemy.y - (travelDistance*vert);
			
			enemy.tY = enemy.y;
			enemy.tX = enemy.x;
		end	
	
	elseif (enemy.phase == 5) then
		-- Bombs away!
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_Helix_Spell01");
			enemy.soundPlayed = true;
		end
		
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 4) then
			enemy.phase = 6;
			enemy.soundCount = 0;
			enemy.soundPlayed = false;
		end
		
	elseif (enemy.phase == 10) then
		-- The scales...have...tipped...
		if (not enemy.soundPlayed) then
			PlaySound("VO_DM_Helix_HelixDies01");
			enemy.soundPlayed = true;
		end
		
		enemy.soundCount = enemy.soundCount + elapsed;
		
		if (enemy.soundCount >= 3) then
			enemy.soundCount = 0;
			enemy.soundPlayed = false;
			enemy:Hide();
			bombTimer = 0;
		end
		
	end

	return enemy
end

-- Units
-- table.insert(level.enemies , {["time"] = 2, ["name"] = "Glubtok", ["func"] = function(enemy, elapsed) return Glubtok(enemy, elapsed); end, ["x"] = GAMEFIELD_WIDTH/2, ["y"] = GAMEFIELD_HEIGHT
							-- , ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 200, ["isBoss"] = true, ["texture"] = "Interface/AddOns/WowHou/Images/BossGlubtok" --"Interface/ENCOUNTERJOURNAL/UI-EJ-BOSS-Glubtok"
							-- , ["sources"] = {BS_BOSS_DEFAULTLEFT, BS_BOSS_DEFAULTRIGHT}, ["intro"] = "VO_DM_GlubtokHead1_Aggro01", ["introDur"] = 4, ["introText"] = "Glubtok show you da power of de arcane!"
							-- , ["waypoints"] = {{["x"] = GAMEFIELD_WIDTH/2, ["y"]=GAMEFIELD_HEIGHT - 64}}})
							
table.insert(level.enemies , {["time"] = 2, ["name"] = "Helix Gearbreaker", ["func"] = function(enemy, elapsed) return Felix(enemy, elapsed); end, ["x"] = GAMEFIELD_WIDTH/2, ["y"] = GAMEFIELD_HEIGHT
							, ["width"] = 128, ["height"] = 64, ["speed"] = 100, ["health"] = 200, ["isBoss"] = true, ["texture"] = "Interface/AddOns/WowHou/Images/BossFelix"
							, ["sources"] = {}, ["intro"] = "VO_DM_Helix_Aggro01", ["introDur"] = 4, ["introText"] = "The mistress will pay me handsomely for your heads!"
							, ["waypoints"] = {{["x"] = GAMEFIELD_WIDTH/2, ["y"]=GAMEFIELD_HEIGHT - 64}}})
							
							