TRPG = {}
TRPG.data_tilesets = {}

include("tristRPG/Data_Loader.lua")
TRPG:LoadTilesets()
local game_map = include("tristRPG/structs/Game_Map.lua")
game_map:setup("Map001")
include("tristRPG/Map_Renderer.lua")
TRPG.Map_Renderer:RenderMap(game_map)

--include('autorun/client/TRPG_setup.lua')