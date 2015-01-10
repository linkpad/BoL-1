local version = "1.20"

if myHero.charName ~= "Blitzcrank" then return end

 _G.UseUpdater = true

local REQUIRED_LIBS = {
	["SxOrbwalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#FF001E\">Blitzcrank : Ass-Grabber</font></b> <font color=\"#FF980F\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

local UPDATE_NAME = "Blitzcrank : Ass-Grabber"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/AMBER17/BoL/master/Blitzcrank%20:%20Ass-Grabber.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH


function AutoupdaterMsg(msg) print("<b><font color=\"#FF001E\">"..UPDATE_NAME..":</font></b> <font color=\"#FF980F\">"..msg..".</font>") end
if _G.UseUpdater then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
--			 Callbacks				
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

function OnLoad()
	print("<b><font color=\"#FF001E\">Blitzcrank : Ass-Grabber: </font></b><font color=\"#FF980F\"> Have a Good Game </font><font color=\"#FF001E\">| AMBER |</font>")
	Variables()
	Menu()
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	
	if ComboKey then
		Combo(Target)
	end
	
	KillSteall()
	Checks()
end

function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
		end
		if SkillR.ready and Settings.drawing.rDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, RGB(Settings.drawing.rColor[2], Settings.drawing.rColor[3], Settings.drawing.rColor[4]))
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range, RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
	end
end

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
--			 Functions				
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

function KillSteall()
	for _, unit in pairs(GetEnemyHeroes()) do
		local health = unit.health
		local dmgR = getDmg("R", unit, myHero) + (myHero.ap)
			if health < dmgR and Settings.killsteal.useR and ValidTarget(unit) then
				CastR(unit)
			end
	 end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
	
		CastQ(unit)
		CastE(unit)
		
		if Settings.combo.useR then 
			CastR(unit)
		end
		if Settings.combo.RifKilable then
				local dmgR = getDmg("R", unit, myHero) + (myHero.ap)
				if unit.health < dmgR then
					CastR(unit)
				end
		end
	end
end

function CastE(unit)
	if GetDistance(unit) <= SkillE.range and SkillE.ready then
			Packet("S_CAST", {spellId = _E}):send()
			myHero:Attack(unit)
	end	
end

function CastQ(unit)
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)	
		if HitChance >= 2 then
			Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
		end
	end
end



function CastR(unit)
	if GetDistance(unit) <= SkillR.range and SkillR.ready then
		Packet("S_CAST", {spellId = _R}):send()
	end	
end

------------------------------------------------------
------------------------------------------------------
------------------------------------------------------
--			MENU & CHECKS
------------------------------------------------------
------------------------------------------------------
------------------------------------------------------

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	
	TargetSelector:update()
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)
	
	--if VIP_USER and Settings.misc.skinList then ChooseSkin() end
	if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function Menu()
	Settings = scriptConfig("| Blitzcrank : Ass-Grabber |", "AMBER")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("useR", "Use (R) in Combo", SCRIPT_PARAM_ONOFF, false)
		Settings.combo:addParam("RifKilable", "Use (R) if enemy is kilable", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal", "killsteal")	
	Settings.killsteal:addParam("useR", "Steal With (R)", SCRIPT_PARAM_ONOFF, false)
		
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("useR")
		Settings.combo:permaShow("RifKilable")
		Settings.killsteal:permaShow("useR")
	
	
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		
	Settings.drawing:addSubMenu("Lag Free Circles", "lfc")	
		Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing.lfc:addParam("CL", "Quality", 4, 75, 75, 2000, 0)
		Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, SkillQ.range, DAMAGE_MAGIC, true)
	TargetSelector.name = "Blitzcrank"
	Settings:addTS(TargetSelector)
end

function Variables()
	SkillQ = { name = "Rocket Grab", range = 925, delay = 0.25, speed = math.huge, width = 80, ready = false }
	SkillW = { name = "Overdrive", range = nil, delay = 0.375, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "Power Fist", range = 250, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Static Field", range = 590, delay = 0.5, speed = math.huge, angle = 80, ready = false }
	
	VP = VPrediction()

	lastSkin = 0
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function GetCustomTarget()
 	TargetSelector:update() 	
	if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
	if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	return TargetSelector.target
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
end
