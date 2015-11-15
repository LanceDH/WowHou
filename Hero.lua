local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;
local OVERLAY_OFFSET = 32;

local function round(num, idp)
	local ret = 0
	if num >= 0 then
		ret = tonumber(string.format("%." .. (idp or 0) .. "f", num))
	end
	return ret
end

local Bs = addon.BulletStream;

addon.Hero = {};
local Hero = addon.Hero;
Hero.__index = Hero
setmetatable(Hero, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

function Hero.new(x, y)
	local self = setmetatable({}, Hero)
	self.name = "testdot"..#WH_GameFrame.enemies;

	self.x = x;
	self.y = y;
	self.targetX = x;
	self.targetY = y;
	self.elapsed = 0;
	self.speed = 250;
	self.radius = 5;
	self.parent = WH_GameFrameHeroOverlay;
	
	self.sources = {};
	
	local sources = {{["x"] = 0, ["y"] = 25, ["speed"] = 400, ["dir"] = 1, ["bType"] = "", ["angle"] = 0, ["spread"] = 45
						, ["arc"] = 90, ["interval"] = 0.1, ["rotSpeed"] = 1, ["count"] = 1}
					-- ,{["x"] = 25, ["y"] = 0, ["speed"] = 400, ["dir"] = 1, ["bType"] = "WAVE", ["angle"] = 0, ["spread"] = 45
						-- , ["arc"] = 20, ["interval"] = 0.1, ["rotSpeed"] = 1, ["count"] = 1}
					-- ,{["x"] = -25, ["y"] = 0, ["speed"] = 400, ["dir"] = -1, ["bType"] = "WAVE", ["angle"] = 0, ["spread"] = 45
						-- , ["arc"] = 20, ["interval"] = 0.1, ["rotSpeed"] = 1, ["count"] = 1}
						
					--,{["x"] = 25, ["y"] = 0, ["speed"] = 400, ["dir"] = 1, ["bType"] = "WAVE", ["angle"] = 90, ["spread"] = 45, ["arc"] = 90}
					--,{["x"] = -25, ["y"] = 0, ["speed"] = 400, ["dir"] = 1, ["bType"] = "WAVE", ["angle"] = -90, ["spread"] = 45, ["arc"] = 90}
					};
	
	for k, s in ipairs(sources) do
		table.insert(self.sources, Bs(self.x, self.y, s, false));
	end
	
	
	
	self.texture = WH_GameFrameHeroOverlay:CreateTexture(nil, "BORDER");
	self.texture:SetPoint("CENTER", WH_GameFrameHeroOverlay, "BOTTOMLEFT", OVERLAY_OFFSET+x-1, OVERLAY_OFFSET+y);
	self.texture:SetSize(64, 64);
	if (UnitFactionGroup("player") == "Horde") then
		self.texture:SetTexture("Interface/MINIMAP/VEHICLE-AIR-HORDE");
	elseif (UnitFactionGroup("player") == "Alliance") then
		self.texture:SetTexture("Interface/MINIMAP/VEHICLE-AIR-ALLIANCE");
	else -- panda
		self.texture:SetTexture("Interface/VEHICLES/SeatIndicator/Vehicle-Bomber");
	end
	self.hitmarker = WH_GameFrameHeroOverlay:CreateTexture(nil, "BORDER");
	self.hitmarker:SetPoint("CENTER", WH_GameFrameHeroOverlay, "BOTTOMLEFT", OVERLAY_OFFSET+x, OVERLAY_OFFSET+y);
	self.hitmarker:SetSize(10, 10);
	self.hitmarker:SetTexture("Interface/FriendsFrame/StatusIcon-Online");

	return self;
end

function Hero:Tick(elapsed)

	--if (math.abs(self.x - self.targetX) < 0.0001 and math.abs(self.y - self.targetY) < 0.0001) then return; end

	local travelDistance = elapsed * self.speed;
	local xDif = self.x - self.targetX;
	local yDif = self.y - self.targetY;
	local distance = math.sqrt(math.pow(xDif, 2) + math.pow(yDif, 2));
	
	if (distance <= travelDistance ) then
		self.x = self.targetX;
		self.y = self.targetY;
	else
	
		local angle = math.deg(math.atan2(xDif, yDif)) + 90;
		if angle < 0 then angle = 360 + angle end
		angle = 360 - angle;
	
		local hor = math.cos(math.rad(angle));
		local vert = math.sin(math.rad(angle));
		self.x = self.x + (travelDistance*hor);
		self.y = self.y + (travelDistance*vert); --minus because sin 270° = -1 and y = -1 is up
	
	end

	self.texture:ClearAllPoints();
	self.texture:SetPoint("CENTER", self.parent, "BOTTOMLEFT", OVERLAY_OFFSET+self.x, OVERLAY_OFFSET+self.y);
	self.hitmarker:ClearAllPoints();
	self.hitmarker:SetPoint("CENTER", self.parent, "BOTTOMLEFT", OVERLAY_OFFSET+self.x, OVERLAY_OFFSET+self.y);
	
	
	for k, s in ipairs(self.sources) do
		s:SetPos(self.x, self.y);
		s:Tick(elapsed);
	end
end

function Hero:SetTarget(x, y)
	self.targetX = x;
	self.targetY = y;
end

function Hero:GetPos()
	return self.x, self.y, self.radius;
end

