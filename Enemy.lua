local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local PHASE1 = 0;
local PHASE2 = 1;

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
		if (not e.texture:IsShown()) then
			return e;
		end
	end
	
	return nil;
end

function addon.CreateEnemy(data)
	local e = GetFirstInactiveEnemy()
	if (e) then
		e:Reuse(data)
	else
		Enemy.new(data)
	end
	
	data = nil;
end

-- function addon.CreateEnemy(x, y, width, height, texture, sources, name, speed)
	-- local e = GetFirstInactiveEnemy()
	-- if (e) then
		-- e:Reuse(x, y, width, height, texture, sources, name, speed)
	-- else
		-- Enemy.new(x, y, width, height, texture, sources, name, speed)
	-- end
-- end

function Enemy.new(data)
	local self = setmetatable({}, Enemy)
	self.name = ""..#WH_GameFrame.enemies;

	self.phase = PHASE1;
	self.x = data.x;
	self.y = data.y;
	self.tX = data.x;
	self.tY = data.y;
	self.elapsed = 0;
	self.parent = WH_GameFrameEnemyOverlay;
	self.sources = {};
	self.speed = data.speed;
	self.width = data.width;
	self.height = data.height;
	self.radius = self.height /2;
	self.healthMax = data.health;
	self.health = data.health;
	--local sources = {{["x"] = -50, ["y"] = -32, ["speed"] = 100, ["dir"] = 1, ["bType"] = "WAVE"}
	--				,{["x"] = 50, ["y"] = -32, ["speed"] = 100, ["dir"] = -1, ["bType"] = "WAVE"}
	--				};

	for k, s in ipairs(data.sources) do
		table.insert(self.sources, Bs(self.x, self.y, 0.05, 0.5, s, true, 3));
	end
	
	self.func = addon.GetEnemyFunction(data.name);
	
	self.texture = self.parent:CreateTexture(nil, "BORDER");
	self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x, self.y);
	self.texture:SetSize(self.width, self.height);
	self.texture:SetTexture(data.texture);

	self.healthbar = self.parent:CreateTexture(nil, "BORDER");
	self.healthbar:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x-1, self.y - self.height/2 - 5);
	self.healthbar:SetSize( self.health / self.healthMax * self.width, 3);
	self.healthbar:SetTexture(0.8, 0.2, 0.2);
	--self.healthbar:SetTexture("Interface/CHARACTERFRAME/BarFill");
	--self.healthbar:SetVertexColor(1, 0.3, 0.3)
	
	--self.texture:SetTexture("Interface\\AddOns\\WowHou\\Images\\UI-EJ-BOSS-Earthrager Ptah");

	table.insert(WH_GameFrame.enemies, self);
	
	data = nil;
end

function Enemy:Tick(elapsed)
	if (not self.texture:IsShown()) then return; end

	if (self.health <= 0) then
		self:Hide();
		return;
	end
	
	self.elapsed = self.elapsed + elapsed;
	
	self = self.func(self, elapsed);
	
	for k, s in ipairs(self.sources) do
		s:SetPos(self.tX, self.tY);
		s:Tick(elapsed);
	end
	
	self.texture:ClearAllPoints();
	self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.tX, self.tY);
	self.healthbar:ClearAllPoints();
	self.healthbar:SetPoint("BOTTOMLEFT", self.parent, "BOTTOMLEFT", self.x - self.width/2, self.y - self.height/2 - 5);
	self.healthbar:SetSize( self.health / self.healthMax * self.width, 3);
	
	local x = self.tX;
	local y = self.tY;
	local w = self.width;
	local h = self.height;
	
	if (x < 0-w/2 or x > GAMEFIELD_WIDTH+w/2 or y < 0-h/2 or y > GAMEFIELD_HEIGHT+h/2) then
		self:Hide();
	end
end

function Enemy:Damage(amount)
	self.health = self.health - amount;
end

function Enemy:Reuse(data)
	self.phase = PHASE1;
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

	for k, s in ipairs(data.sources) do
		table.insert(self.sources, Bs(self.x, self.y, 0.1, 0.5, s, true, 3));
	end
	self.func = addon.GetEnemyFunction(data.name);
	
	self.texture:SetSize(self.width, self.height);
    self.texture:SetTexture(data.texture);
	self.texture:Show();
	
	self.healthbar:SetPoint("BOTTOMLEFT", self.parent, "BOTTOMLEFT", self.x - self.width/2-1, self.y - self.height/2 - 5);
	self.healthbar:SetSize(self.width, 5);
	self.healthbar:Show();
	
	data = nil;
end

function Enemy:Hide()
	self.texture:Hide();
	self.healthbar:Hide();
	self.sources = {};
end