local pixel = require("pixel")
local gpu = require("component").gpu
local cards = require("card")

--pixel.cards()

local a,b = 3,4
a,b = b,a
print(a,b)

--gpu.bitblt(0,4,1,3,3,pixel.cardbuffer,4,4)

--[[
test = {}
for j=1,3 do
	table.insert(test,j)
	for i=1,#test do
		print((4-#test)*2-5+i*4)
	end
	print()
end
]]--
