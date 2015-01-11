local version = "1.28"

if myHero.charName ~= "Blitzcrank" and not VIP_USER then return end

local nbgrabwin = 0
local nbgrabtotal = 0
local missedgrab = (nbgrabtotal-nbgrabwin)
local pourcentage =0
local ts
local Target

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
		print("<b><font color=\"#FF001E\">| Blitzcrank | Ass-Grabber |</font></b> <font color=\"#FF980F\">Required libraries downloaded successfully, please reload (double F9).</font>")
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

local UPDATE_NAME = "| Blitzcrank | Ass-Grabber |"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/AMBER17/BoL/master/Blitzcrank%20:%20Ass-Grabber.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH


function AutoupdaterMsg(msg) print("<b><font color=\"#FF001E\">"..UPDATE_NAME.."</font></b> <font color=\"#FF980F\">"..msg..".</font>") end
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
	print("<b><font color=\"#FF001E\">| Blitzcrank | Ass-Grabber | </font></b><font color=\"#FF980F\"> Have a Good Game </font><font color=\"#FF001E\">| AMBER |</font>")
	ts = TargetSelector(TARGET_MOST_AD, 1250, DAMAGE_MAGICAL, false, true)
	Variables()
	Menu()
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	
	ts:update()
	Target = ts.target
	SxOrb:ForceTarget(Target)

	 test = tostring(math.ceil(ManashieldStrength()))
	
	if Settings.extra.baseW then 
		local pos = Vector(1316,1300) 
		if GetDistance(pos) < 800 then 
			CastW() 
		end
	end
	
	if Settings.extra.baseW then 
		local pos2 = Vector(13500,13600) 
		if GetDistance(pos2) < 800 then 
			CastW() 
		end
	end
	
	
	SxOrb:ForceTarget(Target)
	
	if Target ~= nil then
		if ComboKey then
			Combo(Target)
		end
	end
	
	KillSteall()
	Checks()
end

function OnDraw()

	if Settings.drawstats.stats then
		if Settings.drawstats.pourcentage then
			DrawText("Pourcentage Grab done : " .. tostring(math.ceil(pourcentage)) .. "%" ,18, 400, 920, 0xff00ff00)
		end
		if Settings.drawstats.grabdone then
			DrawText("Grab Done : "..tostring(nbgrabwin),18, 400, 940, 0xff00ff00)
		end
		if Settings.drawstats.grabfail then
			DrawText("Grab Miss : "..tostring(missedgrab),18, 400, 960, 0xFFFF0000)
		end
		if Settings.drawstats.mana and test ~= nil then
			DrawText("Passive's Shield : ".. tostring(math.ceil(test)) .. "HP" ,18, 400, 980, 0xffffff00)
		end
	end

	if not myHero.dead and not Settings.drawing.mDraw then	
		if ValidTarget(Target) then 
			if Settings.drawing.text then 
				DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
			end
			if Settings.drawing.targetcircle then 
				DrawCircle(Target.x, Target.y, Target.z, 150, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
			end
		end
	
	
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

function ManashieldStrength()
 local ShieldStrength = myHero.mana*0.5
 return ShieldStrength
end

function OnProcessSpell(enemy, spell)
	
	if spell.name == "summonerteleport" and enemy.isMe and Settings.extra.teleportW then 
		CastW()
	end
	
    if spell.name == "RocketGrab" and enemy.isMe then
		nbgrabtotal=nbgrabtotal+1
		missedgrab = (nbgrabtotal-nbgrabwin)
		pourcentage =((nbgrabwin*100)/nbgrabtotal)
    end
end


function OnGainBuff(enemy,buff)

	if buff.name=="powerfistslow" and buff and buff.valid and not enemy.isMe then
		if Settings.combo.useR then 
			if 	Settings.combo.useRafterE then
				CastR(enemy)
			end
		end
	
	end

	if enemy.type == myHero.type and buff and buff.valid and buff.name == "rocketgrab2" and not enemy.isMe then 
		nbgrabwin = nbgrabwin +1 
		missedgrab = (nbgrabtotal-nbgrabwin)
		pourcentage =((nbgrabwin*100)/nbgrabtotal)
	end		
end

function KillSteall()
	for _, enemy in pairs(GetEnemyHeroes()) do
		local health = enemy.health
		local dmgR = getDmg("R", enemy, myHero) + (myHero.ap)
			if health < dmgR and Settings.killsteal.useR and ValidTarget(enemy) then
				CastR(enemy)
			end
	 end
end

function Combo(enemy)
	if ValidTarget(enemy) and enemy ~= nil and enemy.type == myHero.type then
	
		CastQ(enemy)
		if Settings.combo.useE then 
			CastE(enemy)
		end
		
		if Settings.combo.useR then 
			if not Settings.combo.useRafterE then
				CastR(enemy)
			end
		end
		if Settings.combo.RifKilable then
				local dmgR = getDmg("R", enemy, myHero) + (myHero.ap)
				if enemy.health < dmgR then
					CastR(enemy)
				end
		end
	end
end

function CastE(enemy)
	if GetDistance(enemy) <= SkillE.range and SkillE.ready then
			Packet("S_CAST", {spellId = _E}):send()
			myHero:Attack(enemy)
	end	
end

function CastQ(enemy)
	if enemy ~= nil and GetDistance(enemy) <= SkillQ.range and SkillQ.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(enemy, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)	
		
		if HitChance >= 2 then
			Packet("S_CAST", {spellId = _Q, fromX = CastPosition.x, fromY = CastPosition.z, toX = CastPosition.x, toY = CastPosition.z}):send()
		end
	end
end

function CastW()
	if SkillW.ready then
		Packet("S_CAST", {spellId = _W}):send()
	end
end

function CastR(enemy)
	if GetDistance(enemy) <= SkillR.range and SkillR.ready then
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

	 _G.DrawCircle = _G.oldDrawCircle 
	 
end

function Menu()
	Settings = scriptConfig("| | Blitzcrank | Ass-Grabber | |", "AMBER")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("useE", "Use (E) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useRafterE", "Use (R) After (E)", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useR", "Use (R) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("RifKilable", "Use (R) if enemy is kilable", SCRIPT_PARAM_ONOFF, false)
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal", "killsteal")	
	Settings.killsteal:addParam("useR", "Steal With (R)", SCRIPT_PARAM_ONOFF, true)
	
	Settings:addSubMenu("["..myHero.charName.."] - Extra Option", "extra")
	Settings.extra:addParam("teleportW", "Auto use (W) after a teleport", SCRIPT_PARAM_ONOFF, true)
	Settings.extra:addParam("baseW", "Auto use (W) when leave base", SCRIPT_PARAM_ONOFF, true)
	
	
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("text", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("targetcircle", "Draw Circle On Target", SCRIPT_PARAM_ONOFF, true)
		
		
	Settings:addSubMenu("["..myHero.charName.."] - Draw Stats", "drawstats")
		Settings.drawstats:addParam("stats", "Draw Stats", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("pourcentage", "Show Pourcentage", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("grabdone", "Show Grab Done", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("grabfail", "Show Grab Fail", SCRIPT_PARAM_ONOFF, true)
		Settings.drawstats:addParam("mana", "Show Passive's shield", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("useR")
		Settings.combo:permaShow("RifKilable")
		Settings.killsteal:permaShow("useR")
		Settings.drawstats:permaShow("stats")
		Settings.extra:permaShow("teleportW")
		Settings.extra:permaShow("baseW")
		
	
	TargetSelector.name = "Blitzcrank"
	Settings:addTS(ts)
	
end

function Variables()
	SkillQ = { name = "Rocket Grab", range = 925, delay = 0.25, speed = math.huge, width = 80, ready = false }
	SkillW = { name = "Overdrive", range = nil, delay = 0.375, speed = math.huge, width = nil, ready = false }
	SkillE = { name = "Power Fist", range = 250, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Static Field", range = 590, delay = 0.5, speed = math.huge, angle = 80, ready = false }
	
	VP = VPrediction()
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end


function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
end
