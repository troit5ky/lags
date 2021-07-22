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
			lags.sendMsg(":warning: Обнаружены лаги, фризим энтити")
		end
	end 
	lags.lags = 0
	--
end)
--

print("------------------------\n\n", "Lags LOADED", "\n\n------------------------" )