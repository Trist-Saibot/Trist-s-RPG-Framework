function TRPG:LoadTilesets()
    local path = "materials/tristRPG/tilesets/"
    for _,set in ipairs(file.Find(path .. "tileset_*.json","GAME")) do
        local tab = util.JSONToTable(file.Read(path .. set,"GAME"))
        local tileset = include("tristRPG/structs/Tileset.lua")
        tileset.id = tab.id
        tileset.mode = tab.mode
        tileset.name = tab.name
        for i = 0,8 do
            tileset.tileset_names[i] = tab.tileset_names[i + 1]
            tileset.tileset_mats[i] = Material(path .. tab.tileset_names[i + 1])
        end
        TRPG.data_tilesets[tileset.id] = tileset
        --tab.flags
    end
end
function TRPG:Load_Map(map_id)
--HACKY TEMPORARY THING HERE
    local map = include("tristRPG/structs/Map.lua")
    map.display_name = "Trist's Test Map"
    map.map_id = map_id
    map.width = 32
    map.height = 32
    map.data = TRPG:Autotable(3)
    map.tileset_id = 0
    --[[
    for x = 0,map.width do
        for y = 0,map.height do
            for i = 0,2 do
                map.data[x][y][i] = -1
            end
        end
    end
    ]]
    for x = 0,map.width do
        for y = 0,map.height do
            map.data[x][y][0] = 32
        end
    end
    for x = 3,5 do
        for y = 3,5 do
            map.data[x][y][0] = 17
        end
    end
    return map
end
--https://stackoverflow.com/questions/21229211/three-dimensional-table-in-lua
function TRPG:Autotable(dim)
    local MT = {};
    for i = 1, dim do
        MT[i] = {__index = function(t, k)
            if i < dim then
                t[k] = setmetatable({}, MT[i + 1])
                return t[k];
            end
        end}
    end
    return setmetatable({}, MT[1]);
end