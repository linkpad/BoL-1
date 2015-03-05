	--[[
	          _    _ _______ ____     _____ __  __ _____ _______ ______                          
     /\  | |  | |__   __/ __ \   / ____|  \/  |_   _|__   __|  ____|                         
    /  \ | |  | |  | | | |  | | | (___ | \  / | | |    | |  | |__                            
   / /\ \| |  | |  | | | |  | |  \___ \| |\/| | | |    | |  |  __|                           
  / ____ \ |__| |  | | | |__| |  ____) | |  | |_| |_   | |  | |____                          
 /_/    \_\____/_ _|_|  \____/ _|_____/|_|  |_|_____|  |_|__|______|_  _______        _____  
     /\   |  \/  |  _ \|  ____|  __ \    ___    | |    |_   _| \ | | |/ /  __ \ /\   |  __ \ 
    /  \  | \  / | |_) | |__  | |__) |  ( _ )   | |      | | |  \| | ' /| |__) /  \  | |  | |
   / /\ \ | |\/| |  _ <|  __| |  _  /   / _ \/\ | |      | | | . ` |  < |  ___/ /\ \ | |  | |
  / ____ \| |  | | |_) | |____| | \ \  | (_>  < | |____ _| |_| |\  | . \| |  / ____ \| |__| |
 /_/    \_\_|  |_|____/|______|_|  \_\  \___/\/ |______|_____|_| \_|_|\_\_| /_/    \_\_____/ 
                                                                                             
                                                                                             
]]

local AutoSmite_Version = 1.0

class "SxUpdate"
function SxUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, Callback)
    self.Callback = Callback
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = VersionPath
    self.ScriptPath = ScriptPath
    self.SavePath = SavePath
    self.LuaSocket = require("socket")
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function SxUpdate:GetOnlineVersion()
    if not self.OnlineVersion and not self.VersionSocket then
        self.VersionSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.VersionSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.VersionPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
    end

    if not self.OnlineVersion and self.VersionSocket then
        self.VersionSocket:settimeout(0, 'b')
        self.VersionSocket:settimeout(99999999, 't')
        self.VersionReceive, self.VersionStatus = self.VersionSocket:receive('*a')
    end

    if not self.OnlineVersion and self.VersionSocket and self.VersionStatus ~= 'timeout' then
        if self.VersionReceive then
            self.OnlineVersion = tonumber(string.sub(self.VersionReceive, string.find(self.VersionReceive, "<bols".."cript>")+11, string.find(self.VersionReceive, "</bols".."cript>")-1))
        else
            print('AutoUpdate Failed')
            self.OnlineVersion = 0
        end
        self:DownloadUpdate()
    end
end

function SxUpdate:DownloadUpdate()
    if self.OnlineVersion > self.LocalVersion then
        self.ScriptSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.ScriptPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
        self.ScriptReceive, self.ScriptStatus = self.ScriptSocket:receive('*a')
        self.ScriptRAW = string.sub(self.ScriptReceive, string.find(self.ScriptReceive, "<bols".."cript>")+11, string.find(self.ScriptReceive, "</bols".."cript>")-1)
        local ScriptFileOpen = io.open(self.SavePath, "w+")
        ScriptFileOpen:write(self.ScriptRAW)
        ScriptFileOpen:close()
    end

    if type(self.Callback) == 'function' then
        self.Callback(self.OnlineVersion)
    end
end

local ForceReload = false
SxUpdate(AutoSmite_Version,
	"raw.githubusercontent.com",
	"/AMBER17/BoL/master/AutoSmite.version",
	"/AMBER17/BoL/master/AutoSmite.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > AutoSmite_Version then print("<font color=\"#F0Ff8d\"><b>AutoSmite : </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#F0Ff8d\"><b>AutoSmite: </b></font> <font color=\"#FF0F0F\">You have the Latest Version</b></font>") end 
end)
	
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/Superx321/BoL/master/common/SxOrbWalk.Version",
		"/Superx321/BoL/master/common/SxOrbWalk.lua",
		LIB_PATH.."/SxOrbWalk.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>SxOrbWalk: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end
	
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/Ralphlol/BoLGit/master/VPrediction.version",
		"/Ralphlol/BoLGit/master/VPrediction.lua",
		LIB_PATH.."/VPrediction.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>VPrediction: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end


function OnLoad()
	Variable()
	Menu()
end

function OnTick()
	Checks()
	if Settings.killsteal.killsteal then
		KillSteall()
	end
	checkSmite()
end

function OnDraw()
	if not myHero.dead then
		if Settings.Draw.drawSmite then
			DrawCircle(myHero.x, myHero.y, myHero.z, Smite.range, RGB(100, 44, 255))
		end
		if Settings.Draw.drawSmitable then
			local minion = checkSmite()
			if ValidMinion(minion) and Smite.ready then 
				local dmg = minion.health - smiteDmg
				if minion.health > smiteDmg then
					DrawText3D(tostring(math.ceil(dmg)),minion.x, minion.y+450, minion.z, 24, 0xFFFF0000)
				else
					DrawText3D("SMITABLE",minion.x, minion.y+450, minion.z, 24, 0xff00ff00)
				end
			end
		end
	end
end

function OnCreateObj(minion)
	if ValidMinion(minion) then 
    	MyMinionTable[#MyMinionTable + 1] = minion 
	end
end

function OnDeleteObj(minion)
  	if MyMinionTable ~= nil then
      for i, msg in pairs(MyMinionTable)  do 
          if msg.networkID == minion.networkID then
              table.remove(MyMinionTable, i)
          end
      end
    end
end

function checkSmite()
	for i, minion in pairs(MyMinionTable) do
		local isMinion = MyMinionTable[i]
		smiteDmg = math.max(20*myHero.level+370,30*myHero.level+330,40*myHero.level+240,50*myHero.level+100)
		if Settings.settings.redBuff then
			if isMinion.name == "SRU_Red4.1.1" or isMinion.name == "SRU_Red10.1.1" then
				if isMinion.visible and not isMinion.dead then
					if GetDistance(isMinion) <= Smite.range and isMinion.health <= smiteDmg then
						if Settings.settings.Smite then
							CastSpell(Smite.slot, isMinion)
						end
					end
					return isMinion
				end
			end
		end
		if Settings.settings.blueBuff then
			if isMinion.name == "SRU_Blue1.1.1" or isMinion.name == "SRU_Blue7.1.1" then
				if isMinion.visible and not isMinion.dead then
					if GetDistance(isMinion) <= Smite.range and isMinion.health <= smiteDmg then
						if Settings.settings.Smite then
							CastSpell(Smite.slot, isMinion)
						end
					end
					return isMinion
				end
			end
		end
		if Settings.settings.Drake then
			if isMinion.name == "SRU_Dragon6.1.1" then
				if isMinion.visible and not isMinion.dead then
					if GetDistance(isMinion) <= Smite.range and isMinion.health <= smiteDmg then
						if Settings.settings.Smite then
							CastSpell(Smite.slot, isMinion)
						end
					end
					return isMinion
				end
			end
		end
		if Settings.settings.Nashor then
			if isMinion.name == "SRU_Baron12.1.1" then
				if isMinion.visible and not isMinion.dead then
					if GetDistance(isMinion) <= Smite.range and isMinion.health <= smiteDmg then
						if Settings.settings.Smite then
							CastSpell(Smite.slot, isMinion)
						end
					end
					return isMinion
				end
			end
		end
   end
end

function KillSteall()
	for _, unit in pairs(GetEnemyHeroes()) do
		local health = unit.health
		local smiteDmg = 20 + (8 *myHero.level)
		if health < smiteDmg * 0.95 and ValidTarget(unit) then
			CastSpell(Smite.slot, unit)
		end
	 end
end

function Checks()
	Smite.ready = (Smite.slot ~= nil and myHero:CanUseSpell(Smite.slot) == READY )
end

function Variable()
	MyMinionTable = { }
  
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			MyMinionTable[#MyMinionTable + 1] = object
		end
	end
  
    Smite = { name = "summonersmite", range = 550, slot = nil, ready = false }

    if myHero:GetSpellData(SUMMONER_1).name:find(Smite.name) then
        Smite.slot = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find(Smite.name) then
        Smite.slot = SUMMONER_2
    end
  
end

function ValidMinion(m)
	return (m and m ~= nil and m.type and not m.dead and m.name ~= "hiu" and m.name and m.type:lower():find("min") and not m.name:lower():find("camp") and m.team ~= myHero.team and m.charName and not m.name:find("OdinNeutralGuardian") and not m.name:find("OdinCenterRelic"))
end

function Menu()
	Settings = scriptConfig("AutoSmite", "AMBER & Linkpad")
		Settings:addSubMenu("[AutoSmite] - Settings", "settings")
			Settings.settings:addParam("Smite", "Use AutoSmite", SCRIPT_PARAM_ONKEYTOGGLE, true, GetKey("T"))
			Settings.settings:addParam("redBuff","Use On Red Buff ", SCRIPT_PARAM_ONOFF, true)
			Settings.settings:addParam("blueBuff", "Use On Blue Buff ", SCRIPT_PARAM_ONOFF, true)
			Settings.settings:addParam("Drake", "Use On Drake ", SCRIPT_PARAM_ONOFF, true)
			Settings.settings:addParam("Nashor" , "Use On Nashor " , SCRIPT_PARAM_ONOFF, true)
		Settings:addSubMenu("[AutoSmite] - Draw", "Draw")
			Settings.Draw:addParam("drawSmite" , "Draw Smite Range " , SCRIPT_PARAM_ONOFF, true)
			Settings.Draw:addParam("drawSmitable" , "Draw Dammage " , SCRIPT_PARAM_ONOFF, true)
		Settings:addSubMenu("[AutoSmite] - KillSteal", "killsteal")
			Settings.killsteal:addParam("killsteal" , "KillSteal With Chilling Smite" , SCRIPT_PARAM_ONOFF, true)
			
		Settings.settings:permaShow("Smite")
		Settings.killsteal:permaShow("killsteal")
			
end
