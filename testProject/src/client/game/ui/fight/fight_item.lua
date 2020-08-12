--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-11
-- desc ä¸»åœºæ™¯
--------------------------------------------------------------------------------------
local mod = {}
mod._load_param = {
    ui_type = "item",
    prefab = "fight/fight_item",
    actionbar = {}
}

function mod:on_load(param)
    self:init_data(param)
    self:init_ui()
    self:refresh_ui()
end

function mod:init_data(param)
    self.cid = param.cid
    self.conf = M.fight:get_fight_conf()[self.cid]
    self.tp = self.conf.tp

    -- 生成的时候还要把X的坐标左右随机偏移点
    local pos_x = math.random(-750,750)

    self.gameObject.transform.localPosition = {
        x = pos_x,
        y = self.gameObject.transform.localPosition.y,
        z = self.gameObject.transform.localPosition.z
    }

end

function mod:init_ui()
    self.ui = {}
    local u = {}
    u.bg = self:seek_component(self.gameObject, "bg", "Image")
    u.info = self:seek_component(self.gameObject, "info", "Text")

    self.ui = u
end

function mod:refresh_ui()
    local u = self.ui
    u.info.text = self.conf.name
end


function mod:on_update(dt)
    self.gameObject.transform.localPosition = {
        x = self.gameObject.transform.localPosition.x,
        y = self.gameObject.transform.localPosition.y - (dt * 70),
        z = self.gameObject.transform.localPosition.z
    }
end

return UI.export(mod)
