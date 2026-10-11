local gpu = require("component").gpu
local unicode = require("unicode")

local TABLE, TABLEDARK, WHITE, BLACK = 0x006d00, 0x004900, 0xffffff, 0x000000
local Pixel = {
	TABLE=TABLE,
	TABLEDARK=TABLEDARK,
	WHITE=WHITE,
	BLACK=BLACK
}

function Pixel.background()
	if Pixel.bgbuffer then return Pixel.bgbuffer end
	Pixel.bgbuffer = gpu.allocateBuffer(33,9)
	gpu.setActiveBuffer(Pixel.bgbuffer)
	gpu.setBackground(TABLE)
	gpu.setForeground(TABLEDARK)

	local u,l,f = unicode.char(0x2580),unicode.char(0x2584),unicode.char(0x2588)
	gpu.fill(1,1,33,9," ")
	gpu.set(2,2,f..u..u..l.."                           ")
	gpu.set(2,3,f..u..u..l.." "..l..u..u..l.." "..l..u..u.." "..l..u..u.." "..l..u..u..l.." "..l..u..u.." "..l..u..u..l)
	gpu.set(2,4,u..l..l..u.." "..u..l..l..f.." "..u..l..l.." "..u..l..l.." "..u..l..l..f.." "..f.."   "..u..l..l..f)

	gpu.setActiveBuffer(0)
	return Pixel.bgbuffer
end

function Pixel.cards()
	if Pixel.cardbuffer then return Pixel.cardbuffer end
	Pixel.cardbuffer = gpu.allocateBuffer(3*13,3*5)
	gpu.setActiveBuffer(Pixel.cardbuffer)
	
	gpu.setBackground(WHITE)
	gpu.fill(1,1,3*13,3*5," ")

	gpu.setForeground(BLACK)
	gpu.set(1,1,"A  2  3  4  5  6  7  8  9  10 J  Q  K")
	gpu.set(1,3,"  A  2  3  4  5  6  7  8  9 10  J  Q  K")
	gpu.set(1,7,"A  2  3  4  5  6  7  8  9  10 J  Q  K")
	gpu.set(1,9,"  A  2  3  4  5  6  7  8  9 10  J  Q  K")
	for i=2,3*13,3 do
		gpu.set(i,2,unicode.char(0x2660))
		gpu.set(i,8,unicode.char(0x2663))
	end

	gpu.setForeground(0x990000)
	gpu.set(1,4,"A  2  3  4  5  6  7  8  9  10 J  Q  K")
	gpu.set(1,6,"  A  2  3  4  5  6  7  8  9 10  J  Q  K")
	gpu.set(1,10,"A  2  3  4  5  6  7  8  9  10 J  Q  K")
	gpu.set(1,12,"  A  2  3  4  5  6  7  8  9 10  J  Q  K")
	for i=2,3*13,3 do
		gpu.set(i,5,unicode.char(0x2665))
		gpu.set(i,11,unicode.char(0x2666))
	end

	gpu.setForeground(BLACK)
	gpu.setBackground(0xff0000)
	local u,l = unicode.char(0x2580),unicode.char(0x2584)
	gpu.set(1,13,u..l..u)
	gpu.set(1,14,u..l..u)
	gpu.set(1,15,u..l..u)

	gpu.setActiveBuffer(0)
	return Pixel.cardbuffer
end

function Pixel.getCard(x,y,buffer,suit,num)
	if not Pixel.cardbuffer then return nil end
	gpu.bitblt(buffer,x,y,3,3,Pixel.cardbuffer,num*3-2,suit*3-2)
end

function Pixel.chip(x,y,denom)
	local chipbuffer = gpu.allocateBuffer(7,3)
	gpu.setActiveBuffer(chipbuffer)

	local colors = {0x0092ff,0x9900c0,0xcc0000,0xff9200,0x000000}
	local breaks = {0,500,1000,5000,10000}
	gpu.setBackground(TABLE)
	gpu.fill(1,1,7,3," ")
	for i = 5,1,-1 do
		if denom >= breaks[i] then
			gpu.setBackground(colors[i])
			break
		end
	end
	gpu.setForeground(TABLE)
	gpu.set(7,2,unicode.char(0x2590))
	gpu.set(1,2,unicode.char(0x258c))
	gpu.set(7,1,unicode.char(0x259c))
	gpu.set(7,3,unicode.char(0x259f))
	gpu.set(1,1,unicode.char(0x259b))
	gpu.set(1,3,unicode.char(0x2599))

	gpu.fill(2,1,5,1,unicode.char(0x2580))
	gpu.fill(2,2,5,1," ")
	gpu.fill(2,3,5,1,unicode.char(0x2584))

	gpu.setForeground(WHITE)
	local str = tostring(denom)
	gpu.set(string.len(str)==5 and 2 or 3,2,str)

	gpu.setActiveBuffer(0)
	gpu.bitblt(0,x,y,7,3,chipbuffer)
	gpu.freeBuffer(chipbuffer)
end

function Pixel.chipTable(x,y,text)
	local buffer = gpu.allocateBuffer(9,5)
	gpu.setActiveBuffer(buffer)

	gpu.setBackground(TABLEDARK)
	for i=0,23,11 do
		gpu.fill(1+i,2,1,3," ")
		gpu.fill(9+i,2,1,3," ")
	end

	gpu.setForeground(TABLEDARK)
	gpu.setBackground(TABLE)
	gpu.fill(2,2,7,3," ")
	for i=0,23,11 do
		gpu.fill(1+i,1,9,1,unicode.char(0x2584))
		gpu.fill(1+i,5,9,1,unicode.char(0x2580))
	end
	gpu.set(5-string.len(text)//2,3,text)

	gpu.setActiveBuffer(0)
	gpu.bitblt(0,x,y,9,5,buffer)
	gpu.freeBuffer(buffer)
end

return Pixel
