-- Net for message sending
util.AddNetworkString( "lags_sendmsg" )

-- Vars
local lags = {
	interval = true,
	maxLag = true,
	prevTime = true,
	maxDiff = true,
	lags = true,
	lastMsgTime = true,
	lastMsg = "",
	lvl = true,
	lastLag = true
}
-- Lags vars
lags.interval = 1 / engine.TickInterval()
lags.maxLag = lags.interval * .2
lags.prevTime = SysTime()
lags.maxDiff = lags.interval * 3
lags.lags = 0
lags.lastMsgTime = 0
lags.lastMsg = ""
lags.lvl = 0
lags.lastLag = SysTime()

-- Function for freeze conflict ents on the server
function lags.FreezeConflict () 
	lags.sendMsg("поиск конфликтов...")

	for _,e in ipairs(ents.GetAll()) do
		local phys = e:GetPhysicsObject()

		if ( IsValid(phys) ) then
			if ( phys:GetStress() >= 2 or phys:IsPenetrating() and e:GetMoveType() ~= 7 ) then 
				local owner = e:CPPIGetOwner()
				
				if ( owner != nil ) then
					local name = owner:Name()
					lags.sendMsg( Format("%s, твои конфликтующие пропы заморожены!", name) )
				end

				phys:EnableMotion(false)
			end
		end
	end
end
--

-- Function for clean conflict ents on the server
function lags.ClearConflict () 
	lags.sendMsg("поиск конфликтов...")

	for _,e in ipairs(ents.GetAll()) do
		local phys = e:GetPhysicsObject()

		if ( IsValid(phys) ) then
			if ( phys:GetStress() >= 2 or phys:IsPenetrating() and e:GetMoveType() ~= 7 ) then 
				local owner = e:CPPIGetOwner()
				
				if ( owner != nil ) then
					local name = owner:Name()
					lags.sendMsg( Format("%s, твои конфликтующие пропы удалены", name) )
				end

				e:Remove()
			end
		end
	end
end
--

-- Freeze all Ents
function lags.FreezeAll() 
	lags.sendMsg("фриз всех энтити")

	for _,ent in ipairs(ents.GetAll()) do
		local phys = ent:GetPhysicsObject()

		if IsValid(phys) and not ent:IsPlayer() and e:GetMoveType() ~= 7 then 
			phys:EnableMotion(false)
			phys:Sleep()
		end
	end
end
--

-- Kill E2s
function lags.StopE2s() 
	lags.sendMsg("остановка E2 чипов...")

	local chips = ents.FindByClass("gmod_wire_expression2")
	for k,e2 in pairs(chips) do
		e2:PCallHook( "destruct" )
	end
end
--

-- For timescale control
function lags.SetTimeScale( scale ) 
	if ( game.GetTimeScale() > scale ) then 
		local percent = (1 - scale) * 100
		lags.sendMsg("замедление времени на " .. percent .. "%")
		game.SetTimeScale( scale )
	end
end
--

-- Function for send Msg to player and server console
function lags.sendMsg(str)
	-- anti-flood
	if ( lags.lastMsgTime > SysTime() or str == lags.lastMsg ) then return end

	print("[Lags]:", str)

	-- send msg to players
	net.Start("lags_sendmsg")
		net.WriteString(str)
	net.Broadcast()

	lags.lastMsg = str
	lags.lastMsgTime = SysTime()
end
--

-- Lags checkcer
timer.Create('Lags', 0, 0, function()
	lags.tickDiff = lags.interval - ( 1 / ( SysTime() - lags.prevTime ) )
	lags.prevTime = SysTime()

	if( lags.tickDiff < 0 ) then lags.tickDiff = 0 end
	if (game.GetTimeScale() != 1) then 
		lags.tickDiff = lags.tickDiff - (lags.interval / ( game.GetTimeScale() * 4 ) )
	end

	-- if server lagged
	if ( lags.tickDiff*lags.interval >= lags.maxLag ) then 
		if ( lags.lags < lags.maxDiff ) then 
			lags.lags = lags.lags + lags.tickDiff

			if ( lags.lags < lags.maxDiff) then return end

			lags.lastLag = SysTime()
			lags.lvl = math.Clamp( lags.lvl + 1 , 0, 5)

			lags.sendMsg(":warning: уровень лагов " .. lags.lvl)

			if ( lags.lvl == 1 ) then 
				lags.FreezeConflict()
			end 
			if ( lags.lvl == 2 ) then 
				lags.ClearConflict()
			end 
			if ( lags.lvl >= 3 ) then 
				lags.SetTimeScale(0.8)
				lags.ClearConflict()
				lags.FreezeAll()
				lags.StopE2s()
			end 
			if ( lags.lvl >= 4 ) then 
				lags.SetTimeScale(0.6)
			end
			if ( lags.lvl == 5 ) then 
				lags.sendMsg("очистка карты...")
				game.CleanUpMap(false, {})
			end
		end
	end 

	lags.lags = 0

	if ( lags.lastLag + 15 < SysTime() and lags.lvl != 0 ) then
		lags.sendMsg("уровень лагов сброшен!")

		game.SetTimeScale(1)
		lags.lvl = 0
	end
	--
end)
--

print("------------------------\n\n", "Lags LOADED", "\n\n------------------------" )
lags.sendMsg( ":white_check_mark: скрипт инициализирован" )