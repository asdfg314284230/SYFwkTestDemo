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

    local temp_data = {
        time_obj = self.ui.down_value,
        level_obj = self.ui.level_num,
        monster_pos = self.ui.monster_pos,
        move_panle_list = self.ui.move_panle_list
    }

    MGR.fight_mgr:init(temp_data)
    MGR.fight_mgr:fight_start()
end

function mod:init_data()
    -- self.num_value = 0
end

function mod:init_ui()
    self.ui = {}
    local u = {}
    u.top_panel = self:seek_object(self.gameObject, "top_panel")
    u.down_value = self:seek_component(u.top_panel, "value", "Text")
    u.level_num = self:seek_component(u.top_panel, "level_num", "Text")
    u.bottom_panel = self:seek_object(self.gameObject, "bottom_panel")
    u.move_panle_list = {}

    for i = 1, 2 do
        table.insert(u.move_panle_list, self:seek_object(self.gameObject, "bg" .. i))
    end

    u.monster_pos = self:seek_component(self.gameObject, "monster_pos", "RectTransform")

    self.ui = u
end

return UI.export(mod)
