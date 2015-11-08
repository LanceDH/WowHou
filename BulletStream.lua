local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;



local function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end


local Bullet = addon.Bullet;

addon.BulletStream = {};
local Bs = addon.BulletStream;
Bs.__index = Bs
setmetatable(Bs, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Bs.new(x, y, source, isEnemy)
	local self = setmetatable({}, Bs)

	self.x = x;
	self.y = y;
	self.tX = x;
	self.tY = y;
	self.isEnemy = true;
	if (isEnemy ~= nil) then
		self.isEnemy = isEnemy;
	end
	self.elapsed = 0;--math.random(math.pi*2);
	self.bullerTimer = 0;
	self.interval = source.interval;
	self.rotSpeed = source.rotSpeed;
	self.parent = WH_GameFrameBulletOverlay;
	self.source = source;
	self.origin = origin;
	self.streams = source.count
	
	if (not self.isEnemy) then
		self.texture = self.parent:CreateTexture(nil, "BORDER");
		self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x + self.source.x-1, self.y + self.source.y);
		self.texture:SetSize(32, 32);
		self.texture:SetTexture("Interface/MINIMAP/ROTATING-MINIMAPARROW");
		self.texture:SetRotation(0);
	end

	return self;
end

local bulletData = {};

function Bs:SpwanBulletOfType(source)

	bulletData.x = self.x + source.x;
	bulletData.y = self.y + source.y;
	bulletData.angle = 0;
	bulletData.speed = source.speed;
	bulletData.isEnemy = self.isEnemy
	bulletData.origin = self.origin;

	
	local nr = self.streams;
	
	if source.bType == "WAVE" then

		local spacing = source.spread /(nr-1);
		if (nr == 1) then
			source.spread = 0;
			spacing = 0;
		end
		
		if (not self.isEnemy) then
			self.texture:SetRotation(math.rad(-source.dir *(source.arc / 2 * math.sin(self.elapsed*self.rotSpeed) + source.angle)));
		end

		for i=0, nr-1 do
			bulletData.angle = source.dir *((spacing*i) -(source.spread/2) + (source.arc/2*math.sin(self.elapsed*self.rotSpeed)+ source.angle));
			addon.CreateBullet(bulletData);
		end
		
		
		return;
	elseif source.bType == "ROTATE" then
		local spacing = 360 /nr;
		
		for i=0, nr-1 do
			bulletData.angle = source.dir*((spacing*i)-(360*self.elapsed*self.rotSpeed)%360 + source.angle);
			addon.CreateBullet(bulletData);
		end
		
		return;
	end

	local spacing = source.spread /(nr-1);
	if (nr == 1) then
		source.spread = 0;
		spacing = 0;
	end
	
	if (not self.isEnemy) then
		self.texture:SetRotation(math.rad(360 - source.angle));
	end
	
	for i=0, nr-1 do
		bulletData.angle = (-(source.spread/2) + (spacing*i) + source.angle)
		addon.CreateBullet(bulletData);
	end
	--addon.CreateBullet(bulletData);
	
end

function Bs:Tick(elapsed)
	self.bullerTimer = self.bullerTimer + elapsed;
	self.elapsed = self.elapsed + elapsed;
	
	if (not self.isEnemy) then
		self.texture:ClearAllPoints();
		self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", self.x + self.source.x , self.y + self.source.y);
	end
	
	if (self.bullerTimer > self.interval) then

		self:SpwanBulletOfType(self.source);
		self.bullerTimer = self.bullerTimer - self.interval;
	end
end

function Bs:SetPos(x, y)
	self.x = x;
	self.y = y;
end

