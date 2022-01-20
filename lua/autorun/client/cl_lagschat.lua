function sendmsg()
	local str = net.ReadString()
	chat.AddText( Color(97,255,73), "[Lags]: ", Color(255, 255, 255), str )
end

net.Receive("lags_sendmsg", sendmsg)