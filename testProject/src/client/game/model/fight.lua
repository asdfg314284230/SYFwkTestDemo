local _M = {}
function _M:on_load()
    self.fight = M.get_local_data("fight") or {}
    self.fight.lv = self.fight.lv or 1

    self:save()
end

function _M:set_lv(lv)
    self.fight.lv = lv
    self:save()
end

function _M:get_info(key)
    if key then
        return self.fight[key] or 0
    else
        return self.fight
    end
end

function _M:save()
    M.set_local_data("fight", self.fight)
end

return _M
