local modem = require("component").modem
local event = require("event")

local Lib = {port = 841}

function Lib.init(player_id)
	modem.open(Lib.port)
	Lib.player_id = player_id
	event.listen("modem_message",function(_,_,sender,_,_,response)
		if response == "200" then
			Lib.server = sender
		end
		return false
	end)
	modem.broadcast(Lib.port,player_id,"link")
end

function Lib.getbalance()
end

function Lib.setbalance()
end

return Lib
