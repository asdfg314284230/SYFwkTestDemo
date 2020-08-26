--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-11
-- desc 选择关卡
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "base",
    prefab = "main/main",
    actionbar = {}
}

function mod:on_load(param)
    self:init_ui()    
end



function mod:init_ui()
    self:bind_button_click(
        self.gameObject,
        "start_btn",
        function()
            UI.load({name = "fight.fight_main"})
        end
    )

end



return UI.export(mod)