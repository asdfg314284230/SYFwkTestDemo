--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-11
-- desc ä¸»åœºæ™¯
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "dialog",
    prefab = "fight/fight_lose_dialog",
    actionbar = {}
}

function mod:on_load(param)
    self:init_ui()
end

function mod:init_ui()
    self:bind_button_click(
        self.gameObject,
        "quit_btn",
        function()
            UI.load({name = "loading.loading_main"})
            self:destroy()
        end
    )
end

return UI.export(mod)
