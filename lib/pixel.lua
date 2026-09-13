local Pixel = {}

local gpu = require("component").gpu
local unicode = require("unicode")

function Pixel.background()
	if Pixel.bgbuffer then return Pixel.bgbuffer end
	Pixel.bgbuffer = gpu.allocateBuffer(33,9)
	gpu.setActiveBuffer(Pixel.bgbuffer)
	gpu.setBackground(0x006d00)
	gpu.setForeground(0x004900)

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
	
	gpu.setBackground(0xffffff)
	gpu.fill(1,1,3*13,3*5," ")

	gpu.setForeground(0x000000)
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

	gpu.setForeground(0x000000)
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

return Pixel
