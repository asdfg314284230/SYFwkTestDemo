--------------------------------------------------------------------------------------
-- author liu yang
-- date 2020-04-29
-- desc 选择关卡
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "base",
    prefab = "loading/loading_main",
    actionbar = {}
}

function mod:on_load(param)
    self:init_ui()
end



function mod:init_ui()
    self.ui = {}
    self:bind_button_click(
        self.gameObject,
        "start_btn",
        function()
            UI.load({name = "main.main"})
        end
    )

    self:bind_button_click(
        self.gameObject,
        "quit_btn",
        function()
            U.log.w("Quit Game")
        end
    )

    -- self:bind_button_click(self.gameObject,"btn_back",function()
    --     UI.back_base_for_name({name = "main.main"})
    -- end)    

    -- local layout = self:seek_component(self.gameObject,"layout","RectTransform")
    -- for i = 0, layout.transform.childCount - 1 do 
    --     local child = layout.transform:GetChild(i)
    --     local index = i + 1
    --     self:bind_button_click(child.gameObject,"btn",function()
    --         self:on_level_click(index)
    --     end)
    -- end
end


return UI.export(mod)