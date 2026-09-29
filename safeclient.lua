local modem = require("component").modem
local event = require("event")
local thread = require("thread")

local Lib = {port = 841}

function Lib.init(player_id)
	modem.open(Lib.port)
	Lib.player_id = player_id
	local lock = thread.create(function()
		local _,_,sender,_,_,response = event.pull("modem_message")
		if response == "200" then
			Lib.server = sender
		end
		return false
	end)
	modem.broadcast(Lib.port,"link",player_id)
	lock:join()
end

function Lib.getBalance()
	local ret = 0
	local lock = thread.create(function()
		local _,_,sender,_,_,response = event.pull("modem_message")
		if sender ~= Lib.server then ret = -2; return end
		ret = response
	end)
	modem.send(Lib.server,Lib.port,"getBalance",Lib.player_id)
	lock:join()
	return tonumber(ret)
end

function Lib.setBalance(value)
	modem.send(Lib.server,Lib.port,"setBalance",Lib.player_id,value)
end

function Lib.save()
	modem.send(Lib.server,Lib.port,"save")
end

return Lib
