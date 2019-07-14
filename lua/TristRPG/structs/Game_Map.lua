-----
-- Class that handles maps
-----

local Game_Map = {}

--initialize
Game_Map.map_id = 0
Game_Map.events = {}

function Game_Map:setup(map_id)
    self.map_id = map_id
    self.map = TRPG:Load_Map(map_id) --should load a map object
    self.tileset_id = self.map.tileset_id
    --self.tileset = TRPG.data_tilesets[self.tileset_id]
end
function Game_Map:map_id()
    return self.map.map_id
end
function Game_Map:tileset()
    --TODO make some data_tileset table
    --index by tileset ID
    return TRPG.data_tilesets[self.tileset_id]
    --return self.tileset
end
function Game_Map:width()
    return self.map.width
end
function Game_Map:height()
    return self.map.height
end
function Game_Map:data()
    return self.map.data
end
function Game_Map:events_xy(x,y) --returns an array of events in specified coordinates
    --todo:
end
function Game_Map:valid(x,y)
    return x >= 0 and x < self:width() and y >= 0 and y < self:height()
end
function Game_Map:tile_id(x,y,z)
    --todo, make auto table
    return self.map.data[x][y][z] or -1
end
function Game_Map:check_passage(x,y,bit) --return true if you can travel to specified tile
    --the bit variable shows the direction the player is moving from
    for _,tile in ipairs(self:layered_tiles(x,y)) do
        local flag = self:tileset().flags[tile] --FLAG SHOULD SHOW IF TILE IS PASSABLE
        if (bit.band(flag,0x10) == 0) then continue end --this is the special case, passage below this tile allowed
        if (bit.band(flag,bit) == 0) then return true end
        if (bit.band(flag,bit) == bit) then return false end
    end
    return false
end
function Game_Map:passable(x,y,d)
    check_passage(x,y, bit.lshift(1, bit.band(d / 2 - 1,0x0f)))
end
function Game_Map:layered_tiles(x,y) --returns an array of tile_ids on all layers at specified coordinates top to bottom
    local TD = {}
    for z = 0,2 do
        TD[z] = self:tile_id(x,y,z)
    end
    return TD
end
-- if the tile is an autotile (A1 -> A4) retrieve the index of it
function Game_Map:autotile_type(x,y,z)
    if (self:tile_id(x,y,z) >= 2048) then
        return (self:tile_id(x,y,z) - 2048) / 48
    else
        return -1
    end
end

function Game_Map:GetMat(tile_id)
    local TS = self:tileset().tileset_mats
    if (tile_id < 0) then return nil end
    if (tile_id < 16) then return TS[0]
    elseif (tile_id < 48) then return TS[1]
    elseif (tile_id < 80) then return TS[2]
    elseif (tile_id < 128) then return TS[3]
    elseif (tile_id < 256) then return TS[4]
    elseif (tile_id < 512) then return TS[5]
    elseif (tile_id < 768) then return TS[6]
    elseif (tile_id < 1024) then return TS[7]
    elseif (tile_id < 1280) then return TS[8]
    else return nil
    end
end

return Game_Map