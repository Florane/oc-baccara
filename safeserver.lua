local modem = require("component").modem
local event = require("event")

local PORT = 841
local balance = {}

local function link(sender)
	modem.send(sender,PORT,"200")
end

local function getBalance(sender,player_id)
	if not balance[player_id] then modem.send(sender,PORT,"-1"); return end
	modem.send(sender,PORT,balance[player_id])
end

local function setBalance(_,player_id,value)
	balance[player_id] = value
	print(player_id,balance[player_id])
end

local function save()
	local file = io.open("balance.dat","w")
	for k,v in pairs(balance) do
		print(k,v)
		file:write(k..string.format("%08x",v))
	end
	file:close()
end

local function loadBalance()
	local file = io.open("balance.dat","rb")
	if not file then return end
	for line in file:lines(16) do
		local player_id = string.sub(line,1,8)
		local balanceBuffer = tonumber(string.sub(line,-8),16)
		balance[player_id] = balanceBuffer
		print(player_id,balanceBuffer)
	end
end

local function main()
	loadBalance()

	modem.open(PORT)
	local exec = {
		link = link,
		getBalance = getBalance,
		setBalance = setBalance,
		save = save
	}
	while true do
		local _,_,sender,_,_,code,data,data2 = event.pull("modem_message")
		print(code,data,data2)
		exec[code](sender,data,data2)
	end
end

main()
