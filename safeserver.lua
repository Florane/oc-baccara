local modem = require("component").modem
local event = require("event")

local PORT = 841

local function link(sender,data)
	modem.send(sender,841,"200")
end

local function main()
	modem.open(PORT)
	local exec = {
		link = link
	}
	event.listen("modem_message",function(_,_,sender,_,_,code,data)
		exec[code](sender,data)
	end)
end

main()
