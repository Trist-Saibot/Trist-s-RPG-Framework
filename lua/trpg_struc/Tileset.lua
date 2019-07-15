-----
-- the data class for tile sets
-----

--initialize
local tileset = {}
tileset.id = 0 --the ID of the tileset
tileset.mode = 1 --the mode of the tileset, (0: Field type, 1: Area type, 2: VX compatible type)
tileset.name = "" --The name of the tile set.
tileset.tileset_mats = {}
tileset.tileset_names = {} --The file name of the graphic used as the number index (0-8) tile set.
tileset.tileset_names[0] = "" --A1 (Animation)
tileset.tileset_names[1] = "" --A2 (Ground)
tileset.tileset_names[2] = "" --A3 (Buildings)
tileset.tileset_names[3] = "" --A4 (Walls)
tileset.tileset_names[4] = "" --A5 (Normal)
tileset.tileset_names[5] = "" --B
tileset.tileset_names[6] = "" --C
tileset.tileset_names[7] = "" --D
tileset.tileset_names[8] = "" --E

tileset.flags = {}
tileset.flags[0] = 0x0010
for i = 1,8191 do --populate
    tileset.flags[i] = 0x0000
end
for i = 2048,2815 do --update
    tileset.flags[i] = 0x000F
end
for i = 4352,8191 do --update
    tileset.flags[i] = 0x000F
end
--[[

Uses tile IDs as subscripts. The correspondence of each bit is as shown below:

0x0001: Impassable downward
0x0002: Impassable leftward
0x0004: Impassable rightward
0x0008: Impassable upward
0x0010: Display on normal character
0x0020: Ladder
0x0040: Bush
0x0080: Counter
0x0100: Damage floor
0x0200: Impassable by boat
0x0400: Impassable by ship
0x0800: Airship cannot land
0xF000: Terrain tag

]]

return tileset