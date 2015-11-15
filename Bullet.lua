local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

local _TextureCache = {};

local function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end

addon.Bullet = {};
local Bullet = addon.Bullet;
Bullet.__index = Bullet
setmetatable(Bullet, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

local function GetFirstInactiveBullet()

	for k, dot in ipairs(WH_GameFrame.dots) do
		if (not dot.active) then
			return dot;
		end
	end
	
	return nil;
end

function addon.CreateBullet(data)
	Bullet.new(data)
end

function Bullet.new(data)
	local self = nil;
	local inactive = GetFirstInactiveBullet();
	if (not inactive) then
		self = setmetatable({}, Bullet)
		self.name = "testdot"..#WH_GameFrame.dots;
		self.parent = WH_GameFrameBulletOverlay;
		self.texture = WH_GameFrameBulletOverlay:CreateTexture(self.name, "ARTWORK");
		table.insert(WH_GameFrame.dots, self);
	else
		self = inactive
	end

	self.active = true;
	self.x = data.x;
	self.y = data.y;
	self.tX = data.x;
	self.tY = data.y;
	self.radius = 6;
	self.elapsed = 0;
	
	self.isEnemy = true;
	if (data.isEnemy ~= nil) then
		self.isEnemy = data.isEnemy;
	end
	self.speed = 100;
	if (data.speed) then
		self.speed = data.speed;
	end
	
	self.angle = 90; -- default enemy straight down
	if (self.isEnemy) then
		self.angle = 270; -- default hero straight up
	end
	if (data.angle) then
		self.angle = self.angle + data.angle;
	end
	
	
	self.texture:SetPoint("CENTER", WH_GameFrameBulletOverlay, "BOTTOMLEFT", x, y);
	self.texture:SetSize(self.radius*2, self.radius*2);
	self.texture:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMaskSmall");
	self:UpdateTexture()

	
	--return self
end

function Bullet:UpdateTexture()
	if (self.isEnemy) then
		self.texture:SetVertexColor(1, 0.5, 0, 0.5);
	else
		self.texture:SetVertexColor(0.5, 0.5, 1, 0.5);
	end
end

function Bullet:UpdatePos(elapsed)
	if (not self.active) then return; end

	self.elapsed = self.elapsed + elapsed;
	
	local hor = math.cos(math.rad(self.angle));
	local vert = math.sin(math.rad(self.angle));

	hor = (math.abs(hor) < 0.001 and 0 or hor);
	vert = (math.abs(vert) < 0.001 and 0 or vert);
	
	
	self.x = self.x - (self.speed*elapsed*hor);
	self.y = self.y - (self.speed*elapsed*(-vert)); --minus because sin 270° = -1 and y = -1 is up
	self.tX = self.x;
	self.tY = self.y;
	--self.tX = self.x + (math.sin(self.elapsed*3) * 20);
	--self.tY = self.y + (math.sin(self.elapsed*5) * 10);
	self.texture:ClearAllPoints();
	self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.tX, self.tY);
	
	-- local x = self.tX;
	-- local y = self.tY;
	-- local r = self.radius;
	
	self:Show();
	
	-- if (x < 0-r or x > GAMEFIELD_WIDTH+r or y < 0-r or y > GAMEFIELD_HEIGHT+r) then
	if (self.tX < 0-self.radius or self.tX > GAMEFIELD_WIDTH+self.radius or self.tY < 0-self.radius or self.tY > GAMEFIELD_HEIGHT+self.radius) then
		self:Hide();
	end
end

function Bullet:Hide()	
	self.active = false;
	self.x = -16;
	self.y = -16;
	self.speed = 0;
	self.texture:Hide();
	self.texture:ClearAllPoints();
	self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x, self.y);
end

function Bullet:Show()
	self.texture:Show();
end

function Bullet:ToString()
	return self.name .. " : \n (" .. self.x .. ", " .. self.y ..")\n " .. self.tX .. "\n " .. self.tY .."\n";
end