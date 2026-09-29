local drive = require("component").drive

local buffer = ""
for _ = 1,4 do
	buffer = buffer .. string.format("%02x",math.random(0,255))
end
drive.writeSector(1,buffer)
local file = io.open("balance.dat","a")
file:write(buffer..string.format("%08x",1000))
