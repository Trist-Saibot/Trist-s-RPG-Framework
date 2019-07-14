-----
-- the data class for map data
-----
local map = {}

map.display_name = ""
map.tileset_id = 1
map.width = 0
map.height = 0
map.scroll_type = 0
map.note = ""
map.data = {}
map.events = {}

function map:update() --updates any animation tiles
    --todo
end

return map