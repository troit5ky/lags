-- Net for message sending
util.AddNetworkString( "lags_sendmsg" )

-- Vars
local lags = {}
-- Table vars
lags.interval = 1 / engine.TickInterval()
lags.maxLag = lags.interval * .24
lags.prevTime = SysTime()
lags.maxDiff = lags.interval * 6
lags.lags = 0
lags.lastMsgTime = 0

-- Function for freeze all ents on the server
function lags.FrAll () 
	for i,e in ipairs(ents.GetAll()) do
		local phys = e:GetPhysicsObject()

		if ( IsValid(phys) ) then
			phys:EnableMotion(false)
		end
	end
end
--

-- Kill E2s
function lags.StopE2s () 
	local chips = ents.FindByClass("gmod_wire_expression2")
	for k,e2 in pairs(chips) do
		e2:PCallHook( "destruct" )
	end
end
--

-- Function for send Msg to player and server console
function lags.sendMsg (str)
	-- anti-flood
	if ( lags.lastMsgTime > SysTime() ) then return end

	print("[Lags]:", str)

	-- send msg to players
	net.Start("lags_sendmsg")
		net.WriteString(str)
	net.Broadcast()

	lags.lastMsgTime = SysTime()
end
--

-- Lags checkcer
hook.Add("Think", "lags", function ()
	if (game.GetTimeScale() != 1) then return end

	lags.tickDiff = lags.interval - ( 1 / ( SysTime() - lags.prevTime ) )
	lags.prevTime = SysTime()

	-- if server lagged
	if ( lags.tickDiff*lags.interval >= lags.maxLag ) then 
		if ( lags.lags < lags.maxDiff ) then 
			lags.lags = lags.lags + lags.tickDiff

			if ( lags.lags < lags.maxDiff) then return end

			lags.FrAll()
			lags.StopE2s()

			lags.sendMsg(":warning: Обнаружены лаги, фризим энтити, стопим E2")
		end
	end 
	lags.lags = 0
	--
end)
--

print("------------------------\n\n", "Lags LOADED", "\n\n------------------------" )