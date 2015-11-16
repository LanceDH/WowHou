local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local PHASE0 = 0;
local PHASE1 = 1;
local PHASE2 = 2;

local function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end

local Bs = addon.BulletStream;

addon.Enemy = {};
local Enemy = addon.Enemy;
Enemy.__index = Enemy
setmetatable(Enemy, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local function GetFirstInactiveEnemy()

	for k, e in ipairs(WH_GameFrame.enemies) do
		if (not e.isActive) then
			return e;
		end
	end
	
	return nil;
end

function addon.CreateEnemy(data)
	Enemy.new(data);
end

function Enemy.new(data)
	local self = nil;
	local inactive = GetFirstInactiveEnemy();
	if (not inactive) then
		self = setmetatable({}, Enemy);
		self.name = "ILW_Enemy"..#WH_GameFrame.enemies;
		self.parent = WH_GameFrameEnemyOverlay;
		
		self.frame = CreateFrame("frame", self.name, WH_GameFrameEnemyOverlay, "WH_EnemyFrameTemplateTemplate")
		self.frame:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x, self.y);
		-- self.texture = self.parent:CreateTexture(nil, "BACKGROUND");
		-- self.healthbar = self.parent:CreateTexture(nil, "BACKGROUND");
		-- self.border = self.parent:CreateTexture(nil, "BORDER");

		-- self.border:SetSize(64, 64);
		-- self.border:SetTexture("Interface/Garrison/GarrLanding-TradeskillTimerFill");
		-- self.border:Hide()
		
		table.insert(WH_GameFrame.enemies, self);
	else
		self = inactive;
	end
	
	

	
	self.isBoss = false;
	if (data.isBoss ~= nil) then
		self.isBoss = data.isBoss;
	end
	self.data = data;
	self.owner = data.owner;
	self.x = data.x;
	self.y = data.y;
	self.tX = data.x;
	self.tY = data.y;
	self.elapsed = 0;
	
	self.sources = {};
	self.speed = data.speed;
	self.width = data.width;
	self.height = data.height;
	self.radius = self.height /2;
	self.healthMax = data.health;
	self.health = data.health;
	self.waypoints = data.waypoints;
	self.waypointNr = 1;
	self.isActive = true;
	
	-- For bosses
	self.phase = PHASE0;
	self.soundCount = 0;
	self.soundPlayed = false;
	self.tickCount = 0;
	
	self.frame:Show();
	
	self.frame:SetSize(self.height, self.height);
	self.frame.image:SetSize(self.height, self.height);
	
	self.invulnerable = (self.isBoss and true or false);
	if (data.invulnerable ~= nil and self.isBoss == false) then
		self.invulnerable = data.invulnerable
	end

	if (not self.isBoss) then -- boss stuff gets added after the intro
		for k, s in ipairs(data.sources) do
			table.insert(self.sources, Bs(self.x, self.y, s, true));
		end
	end
	
	self.func = data.func;
	
	self.frame.arrow:SetRotation(math.rad(180));
	self.frame.arrow:Hide();
	
	self.frame.image:SetTexture(data.texture);
	if (self.isBoss) then
		self.frame.image:SetSize(self.height, self.height);
		SetPortraitToTexture(self.frame.image, data.texture)
	end

	if (self.isBoss or self.invulnerable) then
		self.frame.healthbar:Hide();
	else
		self.frame.healthbar:Show();
	end
	
	if (self.isBoss) then
		self.frame.border:Show();
	else
		self.frame.border:Hide();
		
	end
	
end

function Enemy:Tick(elapsed)
	if (not self.isActive) then return; end

	-- Bosses need their own death phase.
	if (not self.isBoss and self.health <= 0) then
		self:Hide();
		return;
	-- elseif (self.isBoss and self.canHideBoss) then
		-- self:Hide();
	end
	
	self.elapsed = self.elapsed + elapsed;
	
	if(self.isBoss and self.phase < 2) then
		self:BossIntro(elapsed);
	else
		self = self.func(self, elapsed);
	end
	
	for k, s in ipairs(self.sources) do
		s:SetPos(self.tX, self.tY);
		s:Tick(elapsed);
	end
	
	--self.frame.image:ClearAllPoints();
	self.frame:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.tX, self.tY);
	self.frame.healthbar:SetSize( self.health / self.healthMax * self.width, 3);
	
	if(self.isBoss and self.invulnerable) then
		self.frame.invulnerable:Show();
	else
		self.frame.invulnerable:Hide();
	end
	
	local x = self.tX;
	local y = self.tY;
	local w = self.width;
	local h = self.height;
	
	if (x < 0-w/2 or x > GAMEFIELD_WIDTH+w/2 or y < 0-h/2 or y > GAMEFIELD_HEIGHT+h/2) then
		self:Hide();
	end
end

function Enemy:Damage(amount)
	if (self.invulnerable or self.health == 0) then return false; end
	self.health = self.health - amount;
	return true;
end

function Enemy:BossIntro(elapsed)
	if (self.phase == 0) then
		if (self.waypoints[1] ~= nil) then
			-- move the boss to its position
			local targetX, targetY = 0, 0;
			local travelDistance = elapsed * self.speed;
			local xDif = 0;
			local yDif = 0;
			local distance = 0;
		
			targetX = self.waypoints[1].x;
			targetY = self.waypoints[1].y;
	
			xDif = self.x - targetX;
			yDif = self.y - targetY;
			distance = math.sqrt(math.pow(xDif, 2) + math.pow(yDif, 2));
			
			if (distance <= travelDistance ) then
				-- reached destination
				self.x = targetX;
				self.y = targetY;
				self.phase = 1;
				self.elapsed = 0;
				PlaySound(self.data.intro);
				self.introDur = self.data.introDur;
				addon.ShowBossGossip(self.data.texture, self.data.name,  self.data.introText, self.data.introDur)
			else
				-- still moving
				local angle = math.deg(math.atan2(xDif, yDif)) + 90;
				if angle < 0 then angle = 360 + angle end
				angle = 360 - angle;
			
				local hor = math.cos(math.rad(angle));
				local vert = math.sin(math.rad(angle));
				self.x = self.x + (travelDistance*hor);
				self.y = self.y + (travelDistance*vert); --minus because sin 270° = -1 and y = -1 is up
				
				self.tY = self.y;
				self.tX = self.x;
			end	
		
		else
			
		end
	
	elseif (self.phase == 1 and self.elapsed >= self.data.introDur) then
		self.phase = 2;
		self.elapsed = 0;
		self.invulnerable = false;
		for k, s in ipairs(self.data.sources) do
			table.insert(self.sources, Bs(self.x, self.y, s, true));
		end
	end
end

function Enemy:Hide()
	self.frame:Hide();
	-- self.healthbar:Hide();
	self.sources = {};
	self.isActive = false;

	-- Also hide all the adds if any
	self.owner = nil;
	for k, v in ipairs(WH_GameFrame.enemies) do
		if (v.owner == self) then
			v:Hide();
		end
	end
end

function Enemy:ArrowAngleRad(rads) 
	self.frame.arrow:SetRotation(rads - math.pi/2);
	self.frame.arrow:SetPoint("CENTER", self.frame, "CENTER", 35*math.cos(rads), 35*math.sin(rads));
end