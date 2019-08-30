local editor = {}

function editor:OpenEditor()
    self:CloseEditor()
    local window = vgui.Create("DFrame")
    self.window = window --store reference in editor object

    local curSelection = {}
    curSelection.tile0 = nil
    curSelection.tile1 = nil
    curSelection.tile2 = nil


    window:SetSize(1312,720)
    window:Center()
    window:MakePopup()

    dscG = vgui.Create("DScrollPanel",window)
    dscG:SetPos(0,25)
    dscG:SetSize(272,window:GetTall() - 25)
    local grid = vgui.Create("DGrid")
    grid:SetPos(0,0)
    grid:SetColWide(32)
    grid:SetCols(8)
    dscG:AddItem(grid)
    for i = 0,15 do --A1 tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
            curSelection.tile0 = i
            curSelection.tile1 = -1
            curSelection.tile2 = -1
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderA1(0,0,i,0)
        end
    end
    for i = 16,47 do --A2 tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
            if ( (i % 8) < 4) then
                curSelection.tile0 = i
                curSelection.tile1 = -1
                curSelection.tile2 = -1
            else
                curSelection.tile0 = nil
                curSelection.tile1 = i
                curSelection.tile2 = -1
            end
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderA2(0,0,i,0)
        end
    end
    for i = 48,79 do --A3 tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
                curSelection.tile0 = i
                curSelection.tile1 = -1
                curSelection.tile2 = -1
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderA3(0,0,i,0)
        end
    end
    for i = 80,127 do --A4 tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
                curSelection.tile0 = i
                curSelection.tile1 = -1
                curSelection.tile2 = -1
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderA4(0,0,i,0)
        end
    end
    for i = 128,255 do --A5 tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
                curSelection.tile0 = i
                curSelection.tile1 = -1
                curSelection.tile2 = -1
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderA5(0,0,i,0)
        end
    end
    for i = 256,511 do --B tiles
        local but = vgui.Create("DButton")
        but:SetText("")
        but:SetSize(32,32)
        grid:AddItem(but)
        function but:DoClick()
                curSelection.tile0 = nil
                curSelection.tile1 = nil
                curSelection.tile2 = i
        end
        function but:Paint(w,h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(TRPG.curmap:GetMat(i))
            TRPG.Map_Renderer:RenderB(0,0,i,0)
        end
    end

    dsc = vgui.Create("DScrollPanel",window)
    dsc:SetPos(272,25)
    local ax, ay = dsc:GetPos()
    dsc:SetSize(window:GetWide() - ax,window:GetTall() - ay) --makes it so I can change these later without worrying about them

    local editor_panel = vgui.Create("DPanel")
    editor_panel:SetSize(1024,1024)
    function editor_panel:Paint(w,h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(TRPG.mapmat)
        local adj = 16
        surface.DrawTexturedRectUV(0,0,1024,1024,-adj / 1024,-adj / 1024,(1024 + adj) / 1024,(1024 + adj) / 1024)
    end
    dsc:AddItem(editor_panel)




    function editor_panel:SetTile(x,y)
        local change = false
        if (curSelection.tile0) then TRPG.curmap:set_tile(x,y,0,curSelection.tile0) change = true end
        if (curSelection.tile1) then TRPG.curmap:set_tile(x,y,1,curSelection.tile1) change = true end
        if (curSelection.tile2) then TRPG.curmap:set_tile(x,y,2,curSelection.tile2) change = true end
        if (change) then TRPG.Map_Renderer:UpdateSurrounding(x,y,TRPG.curmap) end
    end
    function editor_panel:Think()
        local cx,cy = self:LocalCursorPos()
        if (cx > 0 and cx < 1024 and cy > 0 and cy < 1024) then --in bounds
            local x = math.floor(cx / 32)
            local y = math.floor(cy / 32)
            if (input.IsMouseDown(MOUSE_LEFT)) then
                self:SetTile(x, y)
            elseif (input.IsMouseDown(MOUSE_RIGHT)) then
                curSelection.tile0 = TRPG.curmap:tile_id(x,y,0)
                curSelection.tile1 = TRPG.curmap:tile_id(x,y,1)
                curSelection.tile2 = TRPG.curmap:tile_id(x,y,2)
            end
        end
    end
    TRPG.mapmat = TRPG.Map_Renderer:RenderMap(TRPG.curmap)
end



function editor:CloseEditor()
    if (self.window and self.window:IsValid()) then
        self.window:Remove()
    end
end

TRPG.editor = editor

list.Set("DesktopWindows","TRPG_EDITOR",{
    title = "Map Editor",
    icon = "autobox/icon64/mitch.png",
    init = function(icon,window)
        window:Remove()
        editor:OpenEditor()
    end
})