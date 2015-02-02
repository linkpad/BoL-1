--[[
IN COMING THIS EVENING


if myHero.charName ~= "Irelia" or not VIP_USER then return end 

function OnLoad()
	print("<b><font color=\"#FF001E\">| Irelia |</font></b><font color=\"#FF980F\"> Have a Good Game </font><font color=\"#FF001E\">| AMBER |</font>")
	TargetSelector = TargetSelector(TARGET_LOW_HP , 700, DAMAGE_PHYSICAL, false, true)
	Variables()
	Menu()
end

function OnTick()

	Checks()
	KillSteal()
	ComboKey = Settings.combo.comboKey	
	TargetSelector:update()
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)
	
	if Target ~= nil then
		if ComboKey then
			Combo(Target)
		end
	end
end

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)

	 _G.DrawCircle = _G.oldDrawCircle 
	 
end

function Variables()
	SkillQ = { range = 650, delay = 0.1, speed = math.huge, width = nil, ready = false }
	SkillW = { range = 125, delay = 0.1, speed = math.huge, width = nil, ready = false }
	SkillE = { range = 425 , delay = 0.1, speed = math.huge, width = nil, ready = false }
	SkillR = { range = 1200, delay = 0.1, speed = math.huge, width = 40, ready = false }
	
	DariusP = 0

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

function OnDraw()

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
		
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, RGB(Settings.drawing.eColor[2], Settings.drawing.eColor[3], Settings.drawing.eColor[4]))
		end
		
		if SkillR.ready and Settings.drawing.rDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, RGB(Settings.drawing.rColor[2], Settings.drawing.rColor[3], Settings.drawing.rColor[4]))
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range, RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
	end
end

function GetCustomTarget()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1400) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
		return SelectedTarget
	end
	TargetSelector:update()	
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function OnWndMsg(Msg, Key)	

	if Msg == WM_LBUTTONDOWN then
		local minD = 0
		local Target = nil
		for i, unit in ipairs(GetEnemyHeroes()) do
			if ValidTarget(unit) then
				if GetDistance(unit, mousePos) <= minD or Target == nil then
					minD = GetDistance(unit, mousePos)
					Target = unit
				end
			end
		end

		if Target and minD < 115 then
			if SelectedTarget and Target.charName == SelectedTarget.charName then
				SelectedTarget = nil
			else
				SelectedTarget = Target
			end
		end
	end
end


function Combo(unit)

	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		
		if Settings.combo.UseQ then
			CastQ(unit)
		end
		if Settings.combo.UseW then
			CastW(unit)
		end
		if Settings.combo.UseE then
			CastE(unit)
		end
		if Settings.combo.UseR then
			CastR(unit)
		end
	end
end

function KillSteal(unit)
end


function CastQ(unit)	
end	
	
function CastW(unit)
end


function CastE(unit)
end


function CastR(unit)nd
end

function Menu()
	Settings = scriptConfig("Irelia", "AMBER")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("UseQ", "Use (Q) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseW", "Use (W) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseE", "Use (E) in combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("UseR", "Use (R) in combo", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "KillSteal")
		Settings.KillSteal:addParam("UseQ", "Use (Q) for KS", SCRIPT_PARAM_ONOFF, true)
		Settings.KillSteal:addParam("UseR", "Use (R) for KS", SCRIPT_PARAM_ONOFF, true)
		
		
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("eColor", "Draw "..SkillE.name.." (E) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {0, 100, 44, 255})
		Settings.drawing:addParam("text", "Draw Current Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("targetcircle", "Draw Circle On Target", SCRIPT_PARAM_ONOFF, true)
		
		
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("UseR")
		Settings.KillSteal:permaShow("UseQ")
		Settings.KillSteal:permaShow("UseR")
	
	TargetSelector.name = "Darius"
	Settings:addTS(TargetSelector)
	
end
]]
