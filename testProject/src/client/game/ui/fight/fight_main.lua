--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-11
-- desc 主场景
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "base",
    prefab = "fight/fight_main",
    actionbar = {}
}

function mod:on_load(param)
    self:init_ui()
    self:init_data()
    MGR.fight_mgr:init()
end

function mod:init_data()
end

function mod:init_ui()
    self.ui = {}
    local u = {}
    u.top_panel = self:seek_object(self.gameObject, "top_panel")
    u.down_vale = self:seek_component(u.top_panel, "value", "Text")
    u.level_num = self:seek_component(u.top_panel, "level_num", "Text")

    u.bottom_panel = self:seek_object(self.gameObject, "bottom_panel")

    u.tp_item_list = {}

    for i = 1, 3 do
        local key = "tp" .. i
        local obj = self:seek_object(u.bottom_panel, key)
        local o = {}
        o.obj = obj
        table.insert(u.tp_item_list, o)
    end

    u.monster_pos = self:seek_component(self.gameObject, "monster_pos", "RectTransform")

    self.ui = u
end

return UI.export(mod)
