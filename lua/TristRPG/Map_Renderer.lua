local tl = 128 --10000000
local tm = 64  --01000000
local tr = 32  --00100000
local mr = 16  --00010000
local br = 8   --00001000
local bm = 4   --00000100
local bl = 2   --00000010
local ml = 1   --00000001

local Map_Renderer = {}

function Map_Renderer:RenderMap(map)
    local renderTarget = GetRenderTargetEx("TRPG_Map",map:width() * 32,map:height() * 32, RT_SIZE_DEFAULT, MATERIAL_RT_DEPTH_NONE,1, 0, IMAGE_FORMAT_RGBA8888)
    render.PushRenderTarget(renderTarget, 0,0,map:width() * 32,map:height() * 32) --point sampling is enabled to give it the pixel art look
    render.Clear(0,0,0,0,true) --THIS FIXES THINGS IF IT DOESN'T DRAW
    cam.Start2D()

    for x = 0,map:width() do
        for y = 0,map:height() do
            self:GenerateTile(x,y,map)
        end
    end

    cam.End2D()

    data = render.Capture({
        format = "jpeg",
        quality = 100,
        h = ScrH(),
        w = ScrW(),
        x = 0,
        y = 0,
    } )
    f = file.Open( "MapData.jpg", "wb", "DATA" )
    f:Write( data )
    f:Close()

    render.PopRenderTarget()
    local tempMat = CreateMaterial("TRPG_Map","UnlitGeneric",{
        ["$basetexture"] = "",
        ["$vertexcolor"] = 1, --allows custom coloring
        ["$vertexalpha"] = 1 --allows custom coloring
    })
    tempMat:SetTexture("$basetexture",renderTarget)
    return Material("!TRPG_Map")
end
function Map_Renderer:GenerateTile(x,y,map)
    local TD = map:layered_tiles(x,y)
    for i = 0,2 do
        if (TD[i] > 0) then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(map:GetMat(TD[i]))
            self:RenderTile(x,y,TD[i],i,map)
        end
    end
end
function Map_Renderer:RenderTile(x,y,tile_id,layer,map)
    if (tile_id < 0) then return end --invalid
    if (tile_id < 16) then --A1
        self:RenderA1(x,y,tile_id)
    elseif (tile_id < 48) then --A2
        self:RenderA2(x,y,tile_id,self:ScanSides(x,y,tile_id,layer,map))
    elseif (tile_id < 80) then --A3
        self:RenderA3(x,y,tile_id)
    elseif (tile_id < 128) then --A4
        self:RenderA4(x,y,tile_id)
    elseif (tile_id < 256) then --A5
        self:RenderA5(x,y,tile_id)
    elseif (tile_id < 512) then --B
        self:RenderB(x,y,tile_id)
    elseif (tile_id < 768) then --C
        self:RenderC(x,y,tile_id)
    elseif (tile_id < 1024) then --D
        self:RenderD(x,y,tile_id)
    elseif (tile_id < 1280) then --E
        self:RenderE(x,y,tile_id)
    end
end
function Map_Renderer:RenderA1(x,y,tile_id)
    --TODO
end
function Map_Renderer:ScanSides(x,y,tile_id,layer,map)
    local bits = 0
    if (map:valid(x - 1,y)) then if (map:tile_id(x - 1,y,layer) == tile_id) then bits = bit.bor(bits,ml) end else bits = bit.bor(bits,ml) end
    if (map:valid(x - 1,y - 1)) then if (map:tile_id(x - 1,y - 1,layer) == tile_id) then bits = bit.bor(bits,tl) end else bits = bit.bor(bits,tl) end
    if (map:valid(x,y - 1)) then if (map:tile_id(x,y - 1,layer) == tile_id) then bits = bit.bor(bits,tm) end else bits = bit.bor(bits,tm) end
    if (map:valid(x + 1,y - 1)) then if (map:tile_id(x + 1,y - 1,layer) == tile_id) then bits = bit.bor(bits,tr) end else bits = bit.bor(bits,tr) end
    if (map:valid(x + 1,y)) then if (map:tile_id(x + 1,y,layer) == tile_id) then bits = bit.bor(bits,mr) end else bits = bit.bor(bits,mr) end
    if (map:valid(x + 1,y + 1)) then if (map:tile_id(x + 1,y + 1,layer) == tile_id) then bits = bit.bor(bits,br) end else bits = bit.bor(bits,br) end
    if (map:valid(x,y + 1)) then if (map:tile_id(x,y + 1,layer) == tile_id) then bits = bit.bor(bits,bm) end else bits = bit.bor(bits,bm) end
    if (map:valid(x - 1,y + 1)) then if (map:tile_id(x - 1,y + 1,layer) == tile_id) then bits = bit.bor(bits,bl) end else bits = bit.bor(bits,bl) end
    --print(bits)
    return bits
end
function Map_Renderer:DrawAutoTile(x,y,tile_index,sides,offx,offy) --should work for A2 and A1 but you'll have to iterate somehow on A1
    local tx = tile_index % 8 * 64 --texture offset
    local ty = math.floor(tile_index / 8) * 96 --texture offset

    local w = 512
    local h = 512

    local offsets = autotile_map[sides]
    local su = (offsets.x * 16 + tx) / w --Start X; this needs to be a number from 0 - 1
    local sv = (offsets.y * 16 + ty) / h --Start Y
    local eu = (offsets.x * 16 + tx + 16) / w
    local ev = (offsets.y * 16 + ty + 16) / h

    surface.DrawTexturedRectUV(x * 32 + offx,y * 32 + offy,16,16,su,sv,eu,ev)
end
function Map_Renderer:RenderA2(x,y,tile_id,bits)
    --top left
    local sides = 0
    local tile_index = tile_id - 16
    if (bit.band(bits,tm) == tm) then sides = bit.bor(sides,tm) end --check for direction, and add it to sides
    if (bit.band(bits,ml) == ml) then sides = bit.bor(sides,ml) end
    if ((bit.band(bits,tl) == tl) and bit.band(bits,tm + ml) == tm + ml) then sides = bit.bor(sides,tl) end --only check if both are checked
    if (sides == 0) then sides = "A2" end --cleanup edge cases
    if (sides == ml) then sides = "A" .. ml end
    if (sides == tm) then sides = "A" .. tm end
    self:DrawAutoTile(x,y,tile_index,sides,0,0)
    --tilemap:DrawTile(x,y,layer,sides,0,0)

    --top right
    sides = 0
    if (bit.band(bits,tm) == tm) then sides = bit.bor(sides,tm) end
    if (bit.band(bits,mr) == mr) then sides = bit.bor(sides,mr) end
    if ((bit.band(bits,tr) == tr) and bit.band(bits,mr + tm) == tm + mr) then sides = bit.bor(sides,tr) end
    if (sides == 0) then sides = "B2" end
    if (sides == mr) then sides = "B" .. mr end
    if (sides == tm) then sides = "B" .. tm end
    self:DrawAutoTile(x,y,tile_index,sides,16,0)
    --tilemap:DrawTile(x,y,layer,sides,16,0)

    --bottom left
    sides = 0
    if (bit.band(bits,bm) == bm) then sides = bit.bor(sides,bm) end
    if (bit.band(bits,ml) == ml) then sides = bit.bor(sides,ml) end
    if ((bit.band(bits,bl) == bl) and bit.band(bits,ml + bm) == ml + bm) then sides = bit.bor(sides,bl) end
    if (sides == 0) then sides = "C2" end
    if (sides == ml) then sides = "C" .. ml end
    if (sides == bm) then sides = "C" .. bm end
    self:DrawAutoTile(x,y,tile_index,sides,0,16)
    --tilemap:DrawTile(x,y,layer,sides,0,16)

    --bottom right
    sides = 0
    if (bit.band(bits,bm) == bm) then sides = bit.bor(sides,bm) end
    if (bit.band(bits,mr) == mr) then sides = bit.bor(sides,mr) end
    if ((bit.band(bits,br) == br) and bit.band(bits,mr + bm) == bm + mr) then sides = bit.bor(sides,br) end
    if (sides == 0) then sides = "D2" end
    if (sides == mr) then sides = "D" .. mr end
    if (sides == bm) then sides = "D" .. bm end
    self:DrawAutoTile(x,y,tile_index,sides,16,16)
    --tilemap:DrawTile(x,y,layer,sides,16,16)
end



--hardcoded tile mappings for autotiles
autotile_map = {}
--x and y values are describing where in the grid of 4x6 these 16px tiles are
--https://cdn.discordapp.com/attachments/563196219703296000/576885240375541770/AT-Organization.png
autotile_map[tm + ml] = {x = 2,y = 0} -- A1 - Category 1
autotile_map[tm + mr] = {x = 3,y = 0} -- B1
autotile_map[bm + ml] = {x = 2,y = 1} -- C1
autotile_map[bm + mr] = {x = 3,y = 1} -- D1
autotile_map["A2"] = {x = 0,y = 2} -- A2 - Category 2
autotile_map["B2"] = {x = 3,y = 2} -- B2
autotile_map["C2"] = {x = 0,y = 5} -- C2
autotile_map["D2"] = {x = 3,y = 5} -- D2
autotile_map[tl + tm + ml] = {x = 2,y = 4} -- A3 - Category 3
autotile_map[tr + tm + mr] = {x = 1,y = 4} -- B3
autotile_map[bl + bm + ml] = {x = 2,y = 3} -- C3
autotile_map[br + bm + mr] = {x = 1,y = 3} -- D3
autotile_map["A" .. ml] = {x = 2,y = 2} -- A4 - Category 4
autotile_map["B" .. mr] = {x = 1,y = 2} -- B4
autotile_map["C" .. ml] = {x = 2,y = 5} -- C4
autotile_map["D" .. mr] = {x = 1,y = 5} -- D4
autotile_map["A" .. tm] = {x = 0,y = 4} -- A5 - Category 5
autotile_map["B" .. tm] = {x = 3,y = 4} -- B5
autotile_map["C" .. bm] = {x = 0,y = 3} -- C5
autotile_map["D" .. bm] = {x = 3,y = 3} -- D5

TRPG.Map_Renderer = Map_Renderer
