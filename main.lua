local pixel = require("pixel")
local cards = require("card")
local component = require("component")
local gpu = component.gpu
local event = require("event")
local thread = require("thread")
local safe = require("safeclient")

local function mainMenu()
	gpu.bitblt(0,1,1,33,9,pixel.background(),1,1)
	gpu.setBackground(0x006d00)

	local graphics = thread.create(function()
		while true do
			gpu.setForeground(0x000000)
			gpu.set(3,7,"Insert card to start playing")
			os.sleep(1)
			gpu.setForeground(0xffffff)
			gpu.set(3,7,"Insert card to start playing")
			os.sleep(1)
		end
	end)
	local _ = event.pull("component_added",nil,"drive")
	graphics:kill()

	return "loading"
end

local function loading(data)
	local graphics = thread.create(function()
		gpu.fill(1,7,33,1," ")
		gpu.setForeground(0xffffff)
		while true do
			gpu.set(12,7,"Loading.  ")
			os.sleep(0.5)
			gpu.set(12,7,"Loading.. ")
			os.sleep(0.5)
			gpu.set(12,7,"Loading...")
			os.sleep(0.5)
		end
	end)
	data.playerid = string.sub(component.drive.readSector(1),1,8) or "nil"
	if data.playerid ~= "nil" then safe.init(data.playerid) end
	data.balance = safe.getBalance()
	if data.balance < 0 then
		data.balance = 5000
		data.playerid = "nil"
		safe.player_id = "nil"
	end

	graphics:kill()

	return "start"
end

local function start(data)
	data.bet = 0
	data.betOn = "Punto!"
	data.select = data.select or 1

	local next = "start"
	local mainthread = thread.create(function()
		gpu.fill(1,1,33,9," ")

		local denoms = {100,500,1000,5000,10000}

		while true do
			pixel.chipTable(2,1,"PUNTO")
			pixel.chipTable(13,1,"BANKO")
			pixel.chipTable(24,1,"TIE")

			pixel.chip(14,6,denoms[data.select])
			pixel.chip(2,6,data.balance)

			gpu.setBackground(pixel.TABLE)
			gpu.setForeground(pixel.TABLEDARK)
			gpu.set(26,7,"     ")
			if data.bet > 0 then
				gpu.set(26,7,"START")

				local shift = 0
				if data.betOn == "Banko!" then shift=11 end
				if data.betOn == "Tie!" then shift=22 end
				pixel.chip(3+shift,2,data.bet)
			end

			gpu.setForeground(0xffffff)
			gpu.set(12,7,"<")
			gpu.set(22,7,">")
			local _,_,x,y = event.pull("touch")
			gpu.set(1,10,string.format("%d %d   ",x,y))
			if y>=2 and y<=4 then
				if x>=2 and x<=10 then
					if data.betOn ~= "Punto!" then data.betOn = "Punto!"
					else data.bet = data.bet+denoms[data.select] end
				elseif x>=2+11 and x<=10+11 then
					if data.betOn ~= "Banko!" then data.betOn = "Banko!"
					else data.bet = data.bet+denoms[data.select] end
				elseif x>=2+22 and x<=10+22 then
					if data.betOn ~= "Tie!" then data.betOn = "Tie!"
					else data.bet = data.bet+denoms[data.select] end
				end
				if data.bet == 0 then data.bet = data.bet+denoms[data.select] end
			elseif y>=6 and y<=8 then
				if x>=14 and x<=20 then
					data.bet = data.bet-denoms[data.select]
				elseif x>=25 and x<=31 and data.bet>0 then
					next = "pregame"
					return 0
				elseif x>=11 and x<=13 then
					data.select = data.select-1
					if data.select<1 then data.select=5 end
				elseif x>=21 and x<=23 then
					data.select = data.select + 1
					if data.select>5 then data.select=1 end
				end
			end

			if data.bet < 0 then data.bet=0
			elseif data.bet > data.balance then data.bet=data.balance
			end
		end

	end)

	local diskthread = thread.create(function()
		local _ = event.pull("component_removed",nil,"drive")
		next = "mainMenu"
		return 0
	end)

	thread.waitForAny({mainthread,diskthread})
	mainthread:kill()
	diskthread:kill()

	return next
end

local function pregame(data)
	gpu.fill(1,1,33,9," ")
	gpu.set(3,1,"Banko: 0")
	gpu.set(3,9,"Punto: 0")

	data.bankobuffer = gpu.allocateBuffer(11,3)
	data.puntobuffer = gpu.allocateBuffer(11,3)
	gpu.setActiveBuffer(data.bankobuffer)
	gpu.fill(1,1,11,3," ")
	gpu.setActiveBuffer(data.puntobuffer)
	gpu.fill(1,1,11,3," ")
	gpu.setActiveBuffer(0)

	if cards.total < 7 then cards.init(6) end

	return "game"
end

local function addCards(x,y,buffer,hand)
	gpu.setActiveBuffer(buffer)
	gpu.setBackground(0x006d00)
	gpu.fill(1,1,11,3," ")
	for i=1,#hand do
		pixel.getCard((4-#hand)*2-5+i*4,1,buffer,hand[i][1],hand[i][2])
	end
	gpu.bitblt(0,x,y,11,3,buffer)
	gpu.setActiveBuffer(0)
end

local function clamp(data,min,max)
	if data < min then return min end
	if data > max then return max end
	return data
end

local function bankoswitch(number,score)
	if score < 3 then return true end
	if number == 8 then return false end
	if score < 4 then return true end
	if number == 9 then return false end
	if score < 5 and number > 1 then return true end
	if score < 6 and number > 3 then return true end
	if score < 7 and number > 5 then return true end
	return false
end

local function game(data)
	data.banko = {}
	data.bankosum = 0
	data.punto = {}
	data.puntosum = 0
	local function putCard(arg)
		local delay = arg.delay or 1.0
		local suit,number = cards.take()
		table.insert(arg.table,{suit,number})
		arg.sum = arg.sum + clamp(number,1,10)

		os.sleep(delay)
		addCards(11,arg.yt,arg.buffer,arg.table)
		gpu.set(10,arg.yc,tostring(arg.sum%10))
		return clamp(number,1,10)
	end

	for _=1,2 do
		data.puntosum = data.puntosum + putCard{table=data.punto, buffer=data.puntobuffer,sum=data.puntosum,yt=6,yc=9}
		data.bankosum = data.bankosum + putCard{table=data.banko, buffer=data.bankobuffer,sum=data.bankosum,yt=2,yc=1}
	end

	if data.puntosum%10 <= 5 then
		local number = putCard{table=data.punto, buffer=data.puntobuffer,sum=data.puntosum,yt=6,yc=9}
		data.puntosum = data.puntosum + number
		if bankoswitch(clamp(number,1,10),data.bankosum%10) then
			data.bankosum = data.bankosum + putCard{table=data.banko, buffer=data.bankobuffer,sum=data.bankosum,yt=2,yc=1}
		end
	elseif data.bankosum%10 <= 5 then
		data.bankosum = data.bankosum + putCard{table=data.banko, buffer=data.bankobuffer,sum=data.bankosum,yt=2,yc=1}
	end

	os.sleep(1.0)
	data.win = "Tie!"
	if data.puntosum%10 > data.bankosum%10 then data.win = "Punto!" end
	if data.puntosum%10 < data.bankosum%10 then data.win = "Banko!" end
	return "win"
end

local function win(data)
	local background, foreground = 0x006d00, 0xffffff
	for _=1,7 do
		gpu.setBackground(background)
		gpu.setForeground(foreground)
		gpu.set((33-string.len(data.win))//2,5,data.win)
		os.sleep(0.5)
		background, foreground = foreground, background
	end
	if data.win == data.betOn then
		if data.win == "Tie!" then data.balance = data.balance + data.bet*7 end
		if data.win == "Banko!" then data.balance = data.balance - data.bet//20 end
		data.balance = data.balance + data.bet
	elseif data.win == "Tie!" then
		return "pregame"
	else
		data.balance = data.balance - data.bet
	end
	safe.setBalance(data.balance)
	safe.save()

	local exit = "mainMenu"
	for _,_ in pairs(component.list("drive")) do exit="start" end
	if data.balance == 0 then exit="mainMenu" end
	return exit
end

local function main()
	pixel.cards()
	pixel.background()
	cards.init(6)
	gpu.setResolution(33,9)

	local select = "mainMenu"
	local stateMachine = {}
	stateMachine["mainMenu"] = mainMenu
	stateMachine["loading"] = loading
	stateMachine["start"] = start
	stateMachine["pregame"] = pregame
	stateMachine["game"] = game
	stateMachine["win"] = win
	
	local data = {}
	while select ~= "exit" do
		select = stateMachine[select](data)
	end
end

main()
