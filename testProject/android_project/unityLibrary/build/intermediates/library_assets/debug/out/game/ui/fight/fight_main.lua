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
        move_panel_list = self.ui.move_panel_list
    }
    local player_data = {
        player_pos = self.ui.player_pos,
        bullet_obj = self.ui.bullet_obj,
        bullet_pos_obj = self.ui.monster_pos
    }


    MGR.fight_mgr:init(temp_data)
    MGR.player_mgr:init(player_data)
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
    u.player_pos = self:seek_object(self.gameObject, "player_role")
    u.bullet_obj = self:seek_object(self.gameObject,"bullet")
    u.bullet_pos_obj = self:seek_object(self.gameObject,"bullet_pos")
    u.move_panel_list = {}

    for i = 1, 2 do
        local o = self:seek_object(self.gameObject, "bg" .. i)
        table.insert(u.move_panel_list, o)
    end

    u.monster_pos = self:seek_component(self.gameObject, "monster_pos", "RectTransform")

    self.ui = u
end

return UI.export(mod)
