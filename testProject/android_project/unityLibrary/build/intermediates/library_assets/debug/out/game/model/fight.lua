local _M = {}

function _M:on_load()
    self.fight = M.get_local_data("fight") or {}
    self.fight.lv = self.fight.lv or 1

    self.enemy_conf = {
        ["001"] = {
            name = "冰毒",
            tp = 1
        },
        ["002"] = {
            name = "K粉",
            tp = 1
        },
        ["003"] = {
            name = "大麻",
            tp = 1
        },
        ["004"] = {
            name = "大麻糖果",
            tp = 1
        },
        ["005"] = {
            name = "果冻冰毒",
            tp = 1
        }
    }

    self:save()
end

function _M:set_lv(lv)
    self.fight.lv = lv
    self:save()
end

function _M:set_value(value)
    self.fight.value = value
    self:save()
end

function _M:get_info(key)
    if key then
        return self.fight[key] or 0
    else
        return self.fight
    end
end

function _M:get_fight_conf()
    return self.enemy_conf
end

function _M:save()
    M.set_local_data("fight", self.fight)
end

return _M
