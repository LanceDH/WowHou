local addonName, addon = ...

local GAMEFIELD_HEIGHT = 500;
local GAMEFIELD_WIDTH = 300;

addon.Levels = {}
local _Levels = addon.Levels;
local _Bullet = addon.Bullet;
local _Bs = addon.BulletStream;
local _Enemy = addon.Enemy;
local _Hero = addon.Hero;
local _GamePaused = true;
local _InPlayfield = false;

local _GameState = 1;
local STATE_LEVELSELECT = 1;
local STATE_INLEVEL = 2;

local _tick = 0;

local _elpasedTotal = 0;
local _TickCount = 0;
local _FPS = 0;
local _LastMemory = 0;

local _MemHistory = {}
local _MemMaxHistory = 200;

local _EnemyList = {};

local _Score = 0;
local _GameTimer = 0;

local _Mem = 0;
local _MemMax = 0;
local _MemMin = 1000000;


local function CopyLevelSpawns(list)
	_EnemyList = {};
	local temp = {};
	for k1, data in ipairs(list) do
		temp = {};
		for k, v in pairs(data) do
			temp[k] = v;
		end
		table.insert(_EnemyList, temp);
	end
end

function addon.ShowBossGossip(texture, name, text, duration)
	WH_BossGossipFrame.duration = duration;
	
	SetPortraitToTexture(WH_BossGossipFrame.image, texture)
	--WH_BossGossipFrame.image:SetTexture(texture);
	WH_BossGossipFrame.name:SetText(name);
	WH_BossGossipFrame.gossip:SetText(text);
	WH_BossGossipFrame:Show();
end

local function round(num, idp)
	local result = 0;
	local mult = math.pow(10, (idp and idp or 0));
	if num >= 0 then
		result = (math.floor (num*mult + 0.5))/mult
	else 
		result = (math.ceil (num*mult - 0.5))/mult
	end
	
	return result

end

local function MouseIsInPayfield()
	
	local left, bottom, width, height = WH_GameFrame:GetBoundsRect();
	local mouseX, mouseY = GetCursorPosition()
	local s = WH_GameFrame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s;
	
	if (mouseX > left and mouseX < left + width and mouseY > bottom and mouseY < bottom + height) then
		return true;
	end
	
	return false;
end

local function UpdateBullet(elapsed)
	for k, dot in ipairs(WH_GameFrame.dots) do
		dot:UpdatePos(elapsed);
	end
end

local function UpdateSources(elapsed)
	for k, source in ipairs(WH_GameFrame.sources) do
		source:Tick(elapsed);
	end
end

local function UpdateEnemies(elapsed)
	for k, e in ipairs(WH_GameFrame.enemies) do
		e:Tick(elapsed);
	end
end

local function CreateDot(parent, button) 
	local left, bottom, width, height = WH_GameFrame:GetBoundsRect();
	local mouseX, mouseY = GetCursorPosition()
	local s = WH_GameFrame:GetEffectiveScale();
	mouseX, mouseY = mouseX/s, mouseY/s;

	_Enemy(mouseX-left, mouseY-bottom);
	--_Bullet(mouseX-left, mouseY-bottom);
end

local function CheckHeroBulletCollision(bullet)
	local mouseX
	local mouseY = GetCursorPosition()
	local hor = 0;
	local vert = 0;
	local distance = 0;
	
	for kb, bullet in ipairs(WH_GameFrame.dots) do
		if (bullet.isActive and not bullet.isEnemy ) then
			for ke, enemy in ipairs(WH_GameFrame.enemies) do
				if (enemy.isActive) then
					hor = bullet.tX - enemy.tX;
					vert = bullet.tY - enemy.tY;
					distance = math.sqrt(math.pow(hor, 2) + math.pow(vert, 2));
					if (distance <= bullet.radius + enemy.radius) then
						if (enemy:Damage(1)) then
							bullet:Hide();
						end
						
					end
				end
			end
		end
	end
	
	
end

local function MouseHitsDot()

	local left, bottom, width, height = WH_GameFrame:GetBoundsRect();
	local mouseX, mouseY = GetCursorPosition()
	local s = UIParent:GetEffectiveScale();
	mouseX, mouseY = WH_GameFrame.hero:GetPos();
	
	local distance = 0;
	local hor = 0;
	local vert = 0;
	
	for k, bullet in ipairs(WH_GameFrame.dots) do
		if (bullet.isEnemy and bullet.isActive) then
			hor = bullet.tX - mouseX;
			vert = bullet.tY - mouseY;
			distance = math.sqrt(math.pow(hor, 2) + math.pow(vert, 2));
			
			if (distance <= bullet.radius) then
				return bullet;
			end
		end
	end
	
	return nil;
end

local function CheckCollision()
	if(MouseHitsDot() ~= nil) then
		_GamePaused = true;
		--WH_GameFrame.mouse:SetTexture("Interface/MINIMAP/Minimap_shield_elite");
	else
		--WH_GameFrame.mouse:SetTexture("Interface/MINIMAP/Minimap_shield_normal");
	end
	
	if(CheckHeroBulletCollision() ~= nil) then
		
		--_GamePaused = true;
		--WH_GameFrame.mouse:SetTexture("Interface/MINIMAP/Minimap_shield_elite");
	else
		--WH_GameFrame.mouse:SetTexture("Interface/MINIMAP/Minimap_shield_normal");
	end
	
end

local function UpdateHero(elapsed)
	if (not _InPlayfield) then return; end
	
	local left, bottom, width, height = WH_GameFrame:GetBoundsRect();
	local mouseX, mouseY = GetCursorPosition()
	local s = UIParent:GetEffectiveScale();
	mouseX, mouseY = mouseX/s-left, mouseY/s-bottom;

	WH_GameFrame.hero:SetTarget(mouseX, mouseY);
	WH_GameFrame.hero:Tick(elapsed);
end

local function BossIsActive()
	for ke, enemy in ipairs(WH_GameFrame.enemies) do
		if (enemy.isBoss and enemy.isActive) then
			return true;
		end
	end
	return false;
end

local function UpdateHealthbar()
	WH_BossHealthFrame.health:SetWidth(200);
	WH_BossHealthFrame:Hide();
	for ke, enemy in ipairs(WH_GameFrame.enemies) do
		if (enemy.isBoss and enemy.isActive) then
			WH_BossHealthFrame.health:SetWidth(200 * enemy.health / enemy.healthMax);
			if (enemy.health <= 0) then
				WH_BossHealthFrame.health:SetWidth(1);
			end
			WH_BossHealthFrame:Show();
		end
	end
end

local function ResetGamefield()
	--CopyLevelSpawns(_ActiveLevel);
	for k, v in ipairs(WH_GameFrame.dots) do
		v:Hide();
	end
	for k, v in ipairs(WH_GameFrame.enemies) do
		v:Hide();
	end
	_GamePaused = false;
	_Score = 0;
	_GameTimer = 0;
end

local function HandleWaves()
	local spawn = nil;
	local data = nil
	for i= #_EnemyList, 1, -1 do
		spawn = _EnemyList[i];
		if (spawn.time < _GameTimer) then
			addon.CreateEnemy(spawn);
			table.remove(_EnemyList, i);
		end
	end
	--local spawn = nil;
	--local data = nil
end

local function InitMainframe()
	WH_GameFrame:SetWidth(GAMEFIELD_WIDTH);
	WH_GameFrame:SetHeight(GAMEFIELD_HEIGHT);
	--WH_GameFrame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background"});
	WH_GameFrame:SetBackdrop({bgFile = "Interface/BlackMarket/BlackMarketBackground-Tile", tile = true, tileSize = 500,});
	WH_MainFrame:RegisterForDrag("LeftButton");
	WH_MainFrame:SetScript("OnDragStart", WH_MainFrame.StartMoving );
	WH_MainFrame:SetScript("OnDragStop", WH_MainFrame.StopMovingOrSizing);
	
	WH_GameFrame.dots = {};
	WH_GameFrame.sources = {};
	WH_GameFrame.enemies = {};
	
	WH_GameFrameEnemyOverlay:SetFrameLevel(WH_GameFrame:GetFrameLevel() + 1);
	WH_GameFrameHeroOverlay:SetFrameLevel(WH_GameFrame:GetFrameLevel() + 2);
	WH_GameFrameBulletOverlay:SetFrameLevel(WH_GameFrame:GetFrameLevel() + 3);
	WH_BorderOverlay:SetFrameLevel(WH_GameFrame:GetFrameLevel() + 4);
	WH_LevelSelect:SetFrameLevel(WH_GameFrame:GetFrameLevel() + 5);
	
	WH_BossHealthFrame.health:SetWidth(200);
	WH_BossHealthFrame:Hide();

	WH_BossGossipFrame.elapsed = 0;
	WH_BossGossipFrame.duration = 0;
	WH_BossGossipFrame:SetScript("OnUpdate", function(self, elapsed) 
						if (self.duration == 0 or _GamePaused) then return; end
						
						self.elapsed = self.elapsed + elapsed;
						
						if (self.elapsed >= self.duration) then
							self:Hide();
							self.duration = 0;
							self.elapsed = 0;
						end
					end);
	
	
	--_Enemy(GAMEFIELD_WIDTH/2, GAMEFIELD_HEIGHT - 32);
	
	WH_GameFrame:SetScript("OnUpdate", function(self,elapsed) 
			_elpasedTotal = _elpasedTotal + elapsed;
			if (not MouseIsInPayfield() or _GamePaused) then return; end
			
			if (_elpasedTotal >= 1) then
				_FPS = _TickCount;
				_TickCount = 0;
				_elpasedTotal = _elpasedTotal -1;
			end
			
			
			_tick = _tick + elapsed;
			--if (_tick >= 0.01) then
				_tick = elapsed;
				_TickCount = _TickCount + 1;
				
				if (not BossIsActive()) then
					_GameTimer = _GameTimer + _tick;
					HandleWaves()
				end
				
				UpdateEnemies(_tick);
				UpdateSources(_tick);
				UpdateBullet(_tick); 
				UpdateHero(_tick);
				CheckCollision();
				UpdateHealthbar();
				
				_Score = _Score + _tick;
				WH_BorderOverlay.Score:SetText("Score: " .. round(_Score*10, 0));
				_tick = 0;
			--end
			--if (round(_GameTimer, 0)%5 == 0) then
			--	collectgarbage("collect");
			--end
		end)
	--WH_GameFrame:SetScript("OnMouseDown", function(self,button) CreateDot(self, button); end)
	WH_GameFrame:SetScript("OnEnter", function(self,button) 
			_InPlayfield = true;
			if (_GamePaused) then
				ResetGamefield()
			end
			
		end);
	WH_GameFrame:SetScript("OnLeave", function(self,button) _InPlayfield = false; end);
	
	
	WH_GameFrame.hero = _Hero(GAMEFIELD_WIDTH/2, GAMEFIELD_HEIGHT/2);
	
	
end

local function InitLevelSelect()
	for k, v in ipairs(_Levels) do
		local button = _G["WH_LevelSelectLevel"..k];
		button.text:SetText(v.name);
		button.image:SetTexture(v.image);
		
		button:SetScript("OnClick", function()
						CopyLevelSpawns(v.enemies);
						WH_LevelSelect:Hide();
						_GameState = STATE_INLEVEL;
					end);
		button:Show();
	end
end

local TEST_LoadFrame = CreateFrame("FRAME", "TEST_LoadFrame"); 
TEST_LoadFrame:RegisterEvent("ADDON_LOADED");
TEST_LoadFrame:RegisterEvent("PLAYER_LOGOUT");
TEST_LoadFrame:RegisterEvent("PLAYER_LOGIN");
TEST_LoadFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function TEST_LoadFrame:ADDON_LOADED(loadedAddon)
	if loadedAddon ~= addonName then return end
	self:UnregisterEvent("ADDON_LOADED");

	InitMainframe();
	InitLevelSelect()
	ILWCreateDebugThingy();
	
	self.ADDON_LOADED = nil;
end

function TEST_LoadFrame:PLAYER_LOGIN(loadedAddon)

end

function TEST_LoadFrame:PLAYER_LOGOUT(loadedAddon)

end

SLASH_TESTGAME1 = '/wowhou';
local function TESTGAMESlash(msg, editbox)
	if msg ~= nil then
		--MouseHitsDot()
	end
	
	if (WH_MainFrame:IsShown()) then
		WH_MainFrame:Hide();
	else
		WH_MainFrame:Show();
	end
	
end
SlashCmdList["TESTGAME"] = TESTGAMESlash



-- Debug help
----------------------------------------------
local DEFAULT_BG = "Interface\\DialogFrame\\UI-DialogBox-Background"
local DEFAULT_EDGEFILE = "Interface\\DialogFrame\\UI-DialogBox-Border"
local mainEdgefile = nill
local DEFAULT_LOCKVERTEX_OFF = 0.5
local DEFAULT_LOCKVERTEX_ON = 0.8
local _updateTimer = 0

local function countInactiveBullets()
	local count = 0;
	
	for k, dot in ipairs(WH_GameFrame.dots) do
		if (not dot.isActive) then
			count = count + 1;
		end
	end
	
	return count;
end

local function countInactiveEnemies()
	local count = 0;
	
	for k, e in ipairs(WH_GameFrame.enemies) do
		if (not e.isActive) then
			count = count + 1;
		end
	end
	
	return count;
end

local debugText = {};

local function debug_updatext()
	
	UpdateAddOnMemoryUsage();
	
	_Mem = round(GetAddOnMemoryUsage(addonName), 1)
	-- if (_Mem > _MemMax) then
		-- _MemMax = _Mem;
	-- end
	-- if (_Mem < _MemMin) then
		-- _MemMin = _Mem;
	-- end
	
	if (#_MemHistory >= _MemMaxHistory) then
		table.remove(_MemHistory, 1);
	end
	
	table.insert(_MemHistory, _Mem);

	local prevheight = 0;
	for k, v in ipairs(_MemHistory) do
		ILW_Debug.memHistory[k]:SetPoint("BOTTOM", ILW_Debug, "TOP", 0, 5 + v/10);
		ILW_Debug.memHistory[k]:Show();
		ILW_Debug.memHistory[k]:SetHeight(1);
		if (prevheight > round(v/10, 0)) then
			ILW_Debug.memHistory[k]:SetHeight((prevheight - round(v/10, 0) > 1 and prevheight - round(v/10, 0) or 1));
		elseif (k>1 and prevheight < round(v/10, 0)) then
			ILW_Debug.memHistory[k]:SetPoint("BOTTOM", ILW_Debug, "TOP", 0, 5 + prevheight);
			ILW_Debug.memHistory[k]:SetHeight((round(v/10, 0) - prevheight > 1 and round(v/10, 0) - prevheight or 1));
		end
		prevheight = round(v/10, 0);
		--ILW_Debug.memHistory[k]:SetHeight(v/10);
	end

	debugText[1] = "State: " .. _GameState .. "    Mem: " .. _Mem --" (".._MemMin..", ".._MemMax..")\n";
	debugText[2] = "Memdif: " .. round(_Mem - _LastMemory, 1) .. "    FPS: " .. _FPS;
	debugText[3] = "Bullets: " .. #WH_GameFrame.dots .. " (" .. countInactiveBullets() ..")";
	debugText[4] = "Enemy: " .. #WH_GameFrame.enemies .. " (" .. countInactiveEnemies() ..")";
	debugText[5] = "Mouse: " .. (_InPlayfield and "in" or "out");
	
	ILW_Debug.text:SetText(table.concat(debugText, "\n"));
	
	_LastMemory = _Mem;
end

local function UpdateMainFrameBG()
	if ILW_Debug:IsMouseEnabled() then
		mainEdgefile = DEFAULT_EDGEFILE
	else
		mainEdgefile = nill
	end
	ILW_Debug:SetBackdrop({bgFile = DEFAULT_BG,
      edgeFile = mainEdgefile,
	  tileSize = 0, edgeSize = 16,
      insets = { left = 3, right = 3, top = 3, bottom = 3 }
	  })
end

local function DebugToggleLockbutton() 
	if ILW_Debug:IsMouseEnabled() then
		ILW_Debug_MoveButton.tex:SetVertexColor(DEFAULT_LOCKVERTEX_OFF, DEFAULT_LOCKVERTEX_OFF, DEFAULT_LOCKVERTEX_OFF )
		PlaySound("igMainMenuOptionCheckBoxOff");
		ILW_Debug:EnableMouse(false)
	else	
		ILW_Debug_MoveButton.tex:SetVertexColor(DEFAULT_LOCKVERTEX_ON, DEFAULT_LOCKVERTEX_ON, DEFAULT_LOCKVERTEX_ON )
		PlaySound("igMainMenuOptionCheckBoxOn");
		ILW_Debug:EnableMouse(true)
	end
		UpdateMainFrameBG()
end


function ILWCreateDebugThingy()
local L_ILW_Debug = CreateFrame("frame", "ILW_Debug", UIParent)

ILW_Debug:EnableMouse(true)
UpdateMainFrameBG()
ILW_Debug:SetFrameLevel(5)
ILW_Debug:SetMovable(true)
ILW_Debug:SetPoint("Center", 250, 0)
ILW_Debug:RegisterForDrag("LeftButton")
ILW_Debug:SetScript("OnDragStart", ILW_Debug.StartMoving )
ILW_Debug:SetScript("OnDragStop", ILW_Debug.StopMovingOrSizing)
ILW_Debug.text = ILW_Debug:CreateFontString(nil, nil, "GameFontNormal")
ILW_Debug.text:SetPoint("topleft", 10, -10)
ILW_Debug.text:SetJustifyH("left")
local debugWidth = 200;
ILW_Debug:SetWidth(debugWidth)
ILW_Debug:SetHeight(80)
ILW_Debug:SetClampedToScreen(true)
ILW_Debug:SetScript("OnUpdate", function(self,elapsed) 
	_updateTimer = _updateTimer + elapsed
	if _updateTimer >= 0.3 then
		debug_updatext()
		_updateTimer = 0
	end
	end)
ILW_Debug:Show()

ILW_Debug.historyBG = ILW_Debug:CreateTexture(nil, "BACKGROUND");
ILW_Debug.historyBG:SetPoint("BOTTOMLEFT", ILW_Debug, "TOPLEFT", 0, 5);
ILW_Debug.historyBG:SetSize(debugWidth, 10*10);
ILW_Debug.historyBG:SetTexture(0, 0, 0);
ILW_Debug.historyBG:Show();

ILW_Debug.memHistory = {}

local historywidth = debugWidth/_MemMaxHistory;

-- for i=0, _MemMaxHistory-1 do
	-- local temp = ILW_Debug:CreateTexture(nil, "OVERLAY");
	-- temp:SetPoint("BOTTOMLEFT", ILW_Debug, "TOPLEFT", historywidth * i, 5);
	-- temp:SetSize(historywidth-1, 1);
	-- temp:SetTexture(1, 1, 1);
	-- temp:Show();
	-- table.insert(ILW_Debug.memHistory, temp);
-- end

for i=0, _MemMaxHistory-1 do
	local temp = ILW_Debug:CreateTexture(nil, "OVERLAY");
	temp:SetPoint("LEFT", ILW_Debug, "LEFT", historywidth * i, 0);
	temp:SetPoint("BOTTOM", ILW_Debug, "TOP", 0, 5);
	temp:SetSize(historywidth, 1);
	temp:SetTexture(0.9, 0.75, 0);
	temp:Hide();
	table.insert(ILW_Debug.memHistory, temp);
end

ILW_Debug.memHeights = {}

for i=0, 10 do
	local temp = ILW_Debug:CreateTexture(nil, "ARTWORK");
	temp:SetPoint("BOTTOMLEFT", ILW_Debug, "TOPLEFT", 0, 5+i*10);
	temp:SetSize(debugWidth, 1);
	temp:SetTexture(0.1, 0.1, 0.1);
	if (i%5 == 0) then
		temp:SetTexture(0.2, 0.2, 0.2);
	end
	temp:Show();
	table.insert(ILW_Debug.memHistory, temp);
end


local L_ILW_Debug_MoveButton = CreateFrame("Button", "ILW_Debug_MoveButton", ILW_Debug)
ILW_Debug_MoveButton:SetWidth(8)
ILW_Debug_MoveButton:SetHeight(8)
ILW_Debug_MoveButton:SetPoint("topright", ILW_Debug, "topright", -5, -5)
ILW_Debug_MoveButton:Show()
ILW_Debug_MoveButton.tex = ILW_Debug_MoveButton:CreateTexture("ILW_Debug_MoveButton_Tex")
ILW_Debug_MoveButton.tex:SetTexture("Interface\\COMMON\\UI-ModelControlPanel")
ILW_Debug_MoveButton.tex:SetPoint("center", ILW_Debug_MoveButton)
ILW_Debug_MoveButton.tex:SetTexCoord(18/64, 36/64, 37/128, 53/128)
ILW_Debug_MoveButton.tex:SetSize(8,8)
ILW_Debug_MoveButton.tex:SetVertexColor(.8, .8, .8 )

 

ILW_Debug_MoveButton:SetScript("OnClick",  function() 
	DebugToggleLockbutton()
	
end)
ILW_Debug_MoveButton:SetScript("OnEnter",  function() 
	ILW_Debug_MoveButton.tex:SetVertexColor(1, 1, 1 )
	
end)
end
