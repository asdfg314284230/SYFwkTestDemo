--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-11
-- desc 子弹
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "item",
    prefab = "fight/fight_bullet",
    actionbar = {}
}

function mod:on_load(param)
    self:init_data(param)
    self:init_ui()
end

function mod:init_data(param)
    --　生成就设置一下自己的默认位置
    local pos = param.pos
    self.gameObject.transform.position = {
        x = pos.x,
        y = pos.y,
        z = pos.z
    }

    self.speed = 100
    self.dead_t = 5
    self.up_t = 0
end

function mod:init_ui()
    self.ui = {}
    local u = {}
    u.colillder_h = self:seek_component(self.gameObject, "", "ColliderHandle")
    u.colillder_h.on_trigger_enter = U.handle(self, self.on_trigger_enter)
    self.ui = u
end

function mod:on_update(dt)
    self.up_t = self.up_t + dt

    if self.up_t >= self.dead_t then
        UI.destroy(self:get_ui_id())
    else
        -- 每帧移动自己位置
        self.gameObject.transform.position = {
            x = self.gameObject.transform.position.x,
            y = self.gameObject.transform.position.y + dt * self.speed,
            z = self.gameObject.transform.position.z
        }
    end
end

function mod:on_trigger_enter(other)
    local lua_o = self:seek_component(other.gameObject, "", "LuaUIBehaveour").luaCtx.luaobj

    -- 增加分数

    -- 消除两边
    UI.destroy(lua_o:get_ui_id())
    UI.destroy(self:get_ui_id())
end

return UI.export(mod)
