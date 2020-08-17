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
        monster_pos = self.ui.monster_pos
    }

    MGR.fight_mgr:init(temp_data)
    MGR.fight_mgr:fight_start()
end

function mod:init_data()
    self.num_value = 0
end

function mod:init_ui()
    self.ui = {}
    local u = {}
    u.top_panel = self:seek_object(self.gameObject, "top_panel")
    u.down_value = self:seek_component(u.top_panel, "value", "Text")
    u.level_num = self:seek_component(u.top_panel, "level_num", "Text")

    u.bottom_panel = self:seek_object(self.gameObject, "bottom_panel")

    u.tp_item_list = {}

    for i = 1, 3 do
        local key = "tp" .. i
        local obj = self:seek_object(u.bottom_panel, key)
        local o = {}
        o.obj = obj
        o.collider = self:seek_component(o.obj, nil, "BoxCollider2D")

        o.collider_handle = self:seek_component(o.obj, nil, "ColliderHandle")

        o.on_trigger_enter = function(self,other)
            local beh = self:seek_component(other.gameObject, other.gameObject.name, "LuaUIBehaveour")
            if beh then
                local luaCtx = beh.luaCtx
                local tp = luaCtx.luaobj.tp
                
                if tp == i then
                    self.num_value = self.num_value + 5
                else
                    self.num_value = self.num_value - 5
                end

                -- ???????
                M.fight:set_value(self.num_value)

                u.level_num.text = self.num_value

                luaCtx.luaobj:command_remove()
            end
        end

        o.collider_handle.on_trigger_enter = U.handle(self, o.on_trigger_enter)
        
        table.insert(u.tp_item_list, o)
    end

    u.monster_pos = self:seek_component(self.gameObject, "monster_pos", "RectTransform")

    self.ui = u
end



return UI.export(mod)
