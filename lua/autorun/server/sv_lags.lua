-- Net for message sending
util.AddNetworkString( "lags_sendmsg" )

-- Vars
local lags = {}

-- Table vars
lags.interval = 1/engine.TickInterval()
lags.maxDiff = lags.interval*.76
lags.prevTime = SysTime()
lags.lastMsg = 0
lags.lastLag = 0
lags.lastMsg = ""
--

-- freeze ents --
function lags.FrAll () 
	for i,e in ipairs(ents.GetAll()) do
		local phys = e:GetPhysicsObject()

		if ( IsValid(phys) ) then
			phys:EnableMotion(false)
		end
	end
end
--

-- Send warnings to players
function lags.sendMsg (str)
	if ( lags.lastMsg == str) then return end
	lags.lastMsg = str

	print( "[Lags]: Diff", lags.tickDiff, "maxDiff", lags.maxDiff )

	net.Start("lags_sendmsg")
		if (lags.lvl == nil) then net.WriteString(str) net.Broadcast() return end
		net.WriteString(":warning: Уровень: " .. lags.lvl .. " :warning: - " .. str)
	net.Broadcast()
end
--

-- Lags checkcer
hook.Add("Think", "lags", function ()
	lags.tickDiff = ( lags.interval - (1 / (SysTime() - lags.prevTime) ) )
	lags.prevTime = SysTime()

	if ( lags.tickDiff >= lags.maxDiff ) then
		lags.lvl = math.Clamp( math.Round( lags.tickDiff / (lags.maxDiff*.84) ) , 1, 5)
		
		if ( lags.lvl == 1 ) then
			lags.lastLag = SysTime()

			lags.FrAll()
			lags.sendMsg("Фризим пропы")
		end
		if ( lags.lvl == 2 and game.GetTimeScale() >= .8 ) then
			lags.lastLag = SysTime()

			lags.FrAll()
			game.SetTimeScale(.8)
			lags.sendMsg("Фризим пропы, останавливаем E2 чипы, замедляем время на 20% ")
		end
		if ( lags.lvl == 3 and game.GetTimeScale() >= .6 ) then
			lags.lastLag = SysTime()

			lags.FrAll()
			RunConsoleCommand("wire_expression2_quotatick", "0")
			game.SetTimeScale(.6)
			lags.sendMsg("Фризим пропы, останавливаем E2 чипы, замедляем время на 40%")
		end
		if ( lags.lvl == 4 and game.GetTimeScale() >= .6) then
			lags.lastLag = SysTime()

			lags.FrAll()
			RunConsoleCommand("wire_expression2_quotatick", "0")
			game.SetTimeScale(.4)
			lags.sendMsg("Фризим пропы, останавливаем E2 чипы, замедляем время на 40%")
		end
		if ( lags.lvl == 5 and game.GetTimeScale() >= .6) then
			lags.lastLag = SysTime()

			game.CleanUpMap(false, {})
			RunConsoleCommand("wire_expression2_quotatick", "0")
			game.SetTimeScale(.4)
			lags.sendMsg("Карта очищена, замедляем время на 40%")
		end
		return
	end
	--

	-- If lags == nil
	if ( lags.lastLag + 10 < SysTime() and lags.lvl != nil ) then 
		lags.lastLag = 0
		lags.lvl = nil
		game.SetTimeScale(1)
		RunConsoleCommand("wire_expression2_quotatick", "50000")
		lags.sendMsg("Лаги сброшены :green_heart:")
	end
	--
end)