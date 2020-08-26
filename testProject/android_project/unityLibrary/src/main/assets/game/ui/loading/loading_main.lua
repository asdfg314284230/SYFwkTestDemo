--------------------------------------------------------------------------------------
-- author CJW
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

end


return UI.export(mod)