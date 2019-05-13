if (SERVER) then return end

--Bitwise representations of each direction
local tl = 128 --10000000
local tm = 64  --01000000
local tr = 32  --00100000
local mr = 16  --00010000
local br = 8   --00001000
local bm = 4   --00000100
local bl = 2   --00000010
local ml = 1   --00000001

--Map Rendering Functions
local map = {} --map metatable
map.size = 32 -- # of tiles x and y

--Tilemap Drawing Functions
local tilemap = {} --tilemap metatable
tilemap.layers = {}
tilemap.maps = {}


function map:ProcessLayer(layer,MaterialName,isAnimated)
    local renderTarget = GetRenderTargetEx("TRPG_" .. MaterialName,self.size * 32,self.size * 32, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_NONE, 0, 0, IMAGE_FORMAT_RGBA8888)
    render.PushRenderTarget(renderTarget, 0,0,self.size * 32,self.size * 32)
    render.Clear(0,0,0,0,true) --THIS FIXES THINGS IF IT DOESN'T DRAW

    cam.Start2D()

    if (isAnimated) then
        --render animated map files
    else
        self:RenderNonAnimated(layer) --render solid map file
    end

    cam.End2D()

    --[[
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
    ]]

    render.PopRenderTarget()


    local tempMat = CreateMaterial("TRPG_" .. MaterialName,"UnlitGeneric",{
        ["$basetexture"] = "",
        ["$vertexcolor"] = 1, --allows custom coloring
        ["$vertexalpha"] = 1 --allows custom coloring
    })
    tempMat:SetTexture("$basetexture",renderTarget)



    return Material("!TRPG_" .. MaterialName)
end
function map:RenderNonAnimated(layer)
    --draw all tiles here
    for y = 0, map.size, 1 do
        for x = 0, map.size, 1 do
            tilemap:RenderTile(x, y, 1)
        end
    end
end
function tilemap:LoadLayers()
    -- load in each layer from some file
    --  *ground
    --  *ground Animated
    --  *on level
    --  *on level Animated
    --  *above
    --  *above Animated

    --TODO
    tilemap.layers[1] = {}
    tilemap.layers[1].data = {}
    for x = 0,map.size,1 do
        for y = 0,map.size,1 do
            tilemap:SetTile(x,y,1,"Trist_Outside_Cornered",1)
        end
    end

    tilemap:SetTile(0,0,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(1,1,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(1,2,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(2,2,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(2,3,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(2,4,1,"Trist_Outside_Cornered",2)
    tilemap:SetTile(3,3,1,"Trist_Outside_Cornered",2)

    for x = 5,7 do
        for y = 3,4 do
            tilemap:SetTile(x,y,1,"Trist_Outside_Uncornered",3)
        end
    end
    for x = 5,7 do
        for y = 5,5 do
            tilemap:SetTile(x,y,1,"Trist_Outside_Uncornered",2)
        end
    end


end
function tilemap:RenderTile(x,y,layer) --Use bitwise operator to check sides of tile, then render
    local bits = self:CheckSides(x,y,layer)
    local type = self:GetTile(x,y,layer).Type

    --top left
    local sides = 0
    if (bit.band(bits,tm) == tm) then sides = bit.bor(sides,tm) end --check for direction, and add it to sides
    if (bit.band(bits,ml) == ml) then sides = bit.bor(sides,ml) end
    if ((bit.band(bits,tl) == tl or type == "uncornered") and bit.band(bits,tm + ml) == tm + ml) then sides = bit.bor(sides,tl) end --only check if both are checked
    if (sides == 0) then sides = "A2" end --cleanup edge cases
    if (sides == ml) then sides = "A" .. ml end
    if (sides == tm) then sides = "A" .. tm end
    tilemap:DrawTile(x,y,layer,sides,0,0)

    --top right
    sides = 0
    if (bit.band(bits,tm) == tm) then sides = bit.bor(sides,tm) end
    if (bit.band(bits,mr) == mr) then sides = bit.bor(sides,mr) end
    if ((bit.band(bits,tr) == tr or type == "uncornered") and bit.band(bits,mr + tm) == tm + mr) then sides = bit.bor(sides,tr) end
    if (sides == 0) then sides = "B2" end
    if (sides == mr) then sides = "B" .. mr end
    if (sides == tm) then sides = "B" .. tm end
    tilemap:DrawTile(x,y,layer,sides,16,0)

    --bottom left
    sides = 0
    if (bit.band(bits,bm) == bm) then sides = bit.bor(sides,bm) end
    if (bit.band(bits,ml) == ml) then sides = bit.bor(sides,ml) end
    if ((bit.band(bits,bl) == bl or type == "uncornered") and bit.band(bits,ml + bm) == ml + bm) then sides = bit.bor(sides,bl) end
    if (sides == 0) then sides = "C2" end
    if (sides == ml) then sides = "C" .. ml end
    if (sides == bm) then sides = "C" .. bm end
    tilemap:DrawTile(x,y,layer,sides,0,16)

    --bottom right
    sides = 0
    if (bit.band(bits,bm) == bm) then sides = bit.bor(sides,bm) end
    if (bit.band(bits,mr) == mr) then sides = bit.bor(sides,mr) end
    if ((bit.band(bits,br) == br or type == "uncornered") and bit.band(bits,mr + bm) == bm + mr) then sides = bit.bor(sides,br) end
    if (sides == 0) then sides = "D2" end
    if (sides == mr) then sides = "D" .. mr end
    if (sides == bm) then sides = "D" .. bm end
    tilemap:DrawTile(x,y,layer,sides,16,16)
end
function tilemap:DrawTile(x,y,layer,sides,offx,offy)
    local tile = self:GetTile(x,y,layer)
    local mat = self.map[tile.MapID].Mat
    surface.SetDrawColor(255,255,255)
    surface.SetMaterial(mat)

    local ol = self:OffsetLookup(x,y,layer)
    local w = mat:GetInt("$realwidth")
    local h = mat:GetInt("$realheight")

    local cy = 0 --shifts up for uncornered tiles
    if (tile.Type == "uncornered") then cy = -32 end

    local offsets = self.mapping[sides]
    local su = (offsets.x * 16 + ol.x) / w --Start X; this needs to be a number from 0 - 1
    local sv = (offsets.y * 16 + ol.y + cy) / h --Start Y
    local eu = (offsets.x * 16 + ol.x + 16) / w
    local ev = (offsets.y * 16 + ol.y + 16 + cy) / h

    surface.DrawTexturedRectUV(x * 32 + offx,y * 32 + offy,16,16,su,sv,eu,ev)
end
function tilemap:CheckSides(x,y,layer) --Checks each side of tile, return bitwise 1,0 for if side is used
    local bits = 0
    local curTile = self:GetMapTile(x,y,layer)
    if (x == 0) then --check if we're at the left corner of the map
        bits = bit.bor(bits,tl) --adds top left flag
        bits = bit.bor(bits,ml) --adds middle left flag
        bits = bit.bor(bits,bl) --adds bottom left flag
    else
        if ( y != 0 and self:CompareTile(x,y,x - 1,y - 1,layer) ) then --top left
            bits = bit.bor(bits,tl) --adds top left flag
        end
        if (self:CompareTile(x,y,x - 1,y,layer) ) then --middle left
            bits = bit.bor(bits,ml) --adds middle left flag
        end
        if ( y != map.size and self:CompareTile(x,y,x - 1,y + 1,layer) ) then --bottom left
            bits = bit.bor(bits,bl) --adds bottom left flag
        end
    end

    if (y == 0) then --check if we're at the top corner of the map
        bits = bit.bor(bits,tl) --adds the top left flag
        bits = bit.bor(bits,tm) --adds the top middle flag
        bits = bit.bor(bits,tr) --adds the top right flag
    else
        if ( x != 0 and self:CompareTile(x,y,x - 1,y - 1,layer) ) then --top left
            bits = bit.bor(bits,tl) --adds top left flag
        end
        if ( self:CompareTile(x,y,x,y - 1,layer) ) then --top middle
            bits = bit.bor(bits,tm) --adds the top middle flag
        end
        if ( x != map.size and self:CompareTile(x,y,x + 1,y - 1,layer) ) then --top right
            bits = bit.bor(bits,tr) --adds the top right flag
        end
    end

    if (x == map.size) then --check if we're at the right corner of the map
        bits = bit.bor(bits,tr) --adds the top right flag
        bits = bit.bor(bits,mr) --adds the middle right flag
        bits = bit.bor(bits,br) --adds the bottom right flag
    else
        if ( y != 0 and self:CompareTile(x,y,x + 1,y - 1,layer) ) then --top right
            bits = bit.bor(bits,tr) --adds the top right flag
        end
        if ( self:CompareTile(x,y,x + 1,y,layer) ) then --middle right
            bits = bit.bor(bits,mr) --adds the middle right flag
        end
        if ( y != map.size and self:CompareTile(x,y,x + 1,y + 1,layer)) then --bottom right
            bits = bit.bor(bits,br) --adds the bottom right flag
        end
    end

    if (y == map.size) then --checks if we're at the bottom corner of the map
        bits = bit.bor(bits,bl) --adds the bottom left flag
        bits = bit.bor(bits,bm) --adds the bottom middle flag
        bits = bit.bor(bits,br) --adds the bottom right flag
    else
        if ( x != 0 and self:CompareTile(x,y,x - 1,y + 1,layer) ) then --bottom left
            bits = bit.bor(bits,bl) --adds the bottom left flag
        end
        if ( self:CompareTile(x,y,x,y + 1,layer) ) then --bottom middle
            bits = bit.bor(bits,bm) --adds the bottom middle flag
        end
        if ( x != map.size and self:CompareTile(x,y,x + 1,y + 1,layer) ) then --bottom right
            bits = bit.bor(bits,br) --adds the bottom right flag
        end
    end
    return bits
end
function tilemap:GetTile(x,y,layer) --maintains consistency, this is the tile information
    local mapTile = self:GetMapTile(x,y,layer)
    --PrintTable(mapTile)
    return self.map[mapTile.MapID]
end
function tilemap:GetMapTile(x,y,layer) --this is the tile physically on the current map's layer
    return tilemap.layers[layer].data[1 + x + y * 32]
end
function tilemap:CompareTile(x1,y1,x2,y2,layer)
    mt1 = self:GetMapTile(x1,y1,layer)
    mt2 = self:GetMapTile(x2,y2,layer)
    if (mt1.MapID == mt2.MapID and mt1.TileID == mt2.TileID) then return true else return false end
end
function tilemap:SetTile(x,y,layer,MapID,TileID)
    local tab = {}
    tab.MapID = MapID
    tab.TileID = TileID
    tilemap.layers[layer].data[1 + x + y * 32] = tab
end
function tilemap:OffsetLookup(x,y,layer)
    local mapTile = self:GetMapTile(x,y,layer)
    local type = self.map[mapTile.MapID].Type
    local tile = self.map[mapTile.MapID].Tiles[mapTile.TileID]
    local tab = {x = 0,y = 0}



    if (type == "cornered") then
        tab.x = 64 * tile.x
        tab.y = 96 * tile.y
    elseif (type == "uncornered") then
        tab.x = 64 * tile.x
        tab.y = 64 * tile.y
    end
    return tab
end
function tilemap:LoadFiles()
    self.map = {}
    local path = "materials/TristRPG/tilemaps/"
    for _,mat in ipairs(file.Find(path .. "*.json","GAME")) do
        local tab = util.JSONToTable(file.Read(path .. mat, "GAME"))
        tab.Mat = Material(path .. tab.Mat)
        self.map[tab.MapID] = tab
    end
end
--hardcoding the tilemap mappings
tilemap.mapping = {}
--x and y values are describing where in the grid of 4x6 these 16px tiles are
--https://cdn.discordapp.com/attachments/563196219703296000/576885240375541770/AT-Organization.png
tilemap.mapping[tm + ml] = {x = 2,y = 0} -- A1 - Category 1
tilemap.mapping[tm + mr] = {x = 3,y = 0} -- B1
tilemap.mapping[bm + ml] = {x = 2,y = 1} -- C1
tilemap.mapping[bm + mr] = {x = 3,y = 1} -- D1
tilemap.mapping["A2"] = {x = 0,y = 2} -- A2 - Category 2
tilemap.mapping["B2"] = {x = 3,y = 2} -- B2
tilemap.mapping["C2"] = {x = 0,y = 5} -- C2
tilemap.mapping["D2"] = {x = 3,y = 5} -- D2
tilemap.mapping[tl + tm + ml] = {x = 2,y = 4} -- A3 - Category 3
tilemap.mapping[tr + tm + mr] = {x = 1,y = 4} -- B3
tilemap.mapping[bl + bm + ml] = {x = 2,y = 3} -- C3
tilemap.mapping[br + bm + mr] = {x = 1,y = 3} -- D3
tilemap.mapping["A" .. ml] = {x = 2,y = 2} -- A4 - Category 4
tilemap.mapping["B" .. mr] = {x = 1,y = 2} -- B4
tilemap.mapping["C" .. ml] = {x = 2,y = 5} -- C4
tilemap.mapping["D" .. mr] = {x = 1,y = 5} -- D4
tilemap.mapping["A" .. tm] = {x = 0,y = 4} -- A5 - Category 5
tilemap.mapping["B" .. tm] = {x = 3,y = 4} -- B5
tilemap.mapping["C" .. bm] = {x = 0,y = 3} -- C5
tilemap.mapping["D" .. bm] = {x = 3,y = 3} -- D5

tilemap:LoadFiles()
tilemap:LoadLayers()

local mat = map:ProcessLayer(1,"Ground",false) --DEBUG todo render in window
hook.Add("HUDPaint","trist_test",function()
    surface.SetMaterial(mat)
    surface.SetDrawColor(255,255,255,255)
    surface.DrawTexturedRect(0, 0, map.size * 32, map.size * 32)
    --map:RenderNonAnimated(1)
end)
