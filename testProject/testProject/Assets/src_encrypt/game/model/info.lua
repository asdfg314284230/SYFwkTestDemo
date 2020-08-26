local _M = {}
function _M:on_load()
    self.info = M.get_local_data("info") or {}
    self.info.creatd_time = self.info.creatd_time or os.time()
    self.info.lv = self.info.lv or 1
    self.info.exp = self.info.exp or 0
    self.info.gold = self.info.gold or 200  
    self.modify_listener = {}
    
    if not self.info.last_start_time then
        M.statistics:record("login_num", 1)
    elseif M.time:today_start_time(self.info.last_start_time) ~= M.time:today_start_time() then
        M.statistics:record("login_num", 1)
    end
    self.info.last_start_time = os.time()
    self:save()
end

function _M:get_name()
    return self.info.name
end

function _M:set_name(name)
    self.info.name = name
    self:save()
end

function _M:add_modify_listener(key, func)
    self.modify_listener[key] = self.modify_listener[key] or {}
    if not self.modify_listener[key][func] then
        self.modify_listener[key][func] = true
    end
end

function _M:add_exp(value)
    self:set_info("exp", (self.info.exp or 0) + value)
end

function _M:add_gold(value) 
    self:set_info("gold", (self.info.gold or 0) + value)
    return 0
end

function _M:sub_gold(value)
    local gold = self.info.gold or 0
    if gold - value >= 0 then
        self:set_info("gold", (self.info.gold or 0) - value)
        return 0
    else
        return 1
    end
end

function _M:set_info(key, value)
    local old_valua = self.info[key] or 0
    self.info[key] = value
    local listeners = self.modify_listener[key]
    for listener, v in pairs(listeners or {}) do
        listener({
            key = key,
            old_valua = old_valua,
            value = value,
        })
    end
    self:save()
end

function _M:get_info(key)
    if key then
        return self.info[key] or 0
    else
        return self.info
    end
end


function _M:save()
    M.set_local_data("info", self.info)
end


function _M:get_level_info()
    local all_exp = self.info.exp
    local conf_level = C["level"]
    local lv = 1
    local exp = 0
    local next_exp = 0
    for i = 1, #conf_level do
        lv = i
        exp = all_exp
        next_exp = conf_level[i].exp

        all_exp = all_exp - conf_level[i].exp
        if all_exp < 0 then
            break
        end
        
    end
    M.statistics:record("levelup", lv, "=")
    return lv, exp, next_exp
end

function _M:inc( param )
    param = param or {}
    local reward = param.reward
    for k, v in pairs(reward or {}) do
        if v[1] == "item" then
            self:set_info(v[2], self:get_info(v[2]) + tonumber(v[3]))
        elseif v[1] == "goods" then
            M.shop:add_goods({goods_id = v[2], is_video = false, is_free = true})
        end
    end
end

function _M:dec( param )
    param = param or {}
    local reward = param.reward
    local error_list = {}
    for k, v in pairs(reward or {}) do
        if v[1] == "item" then
            if self:get_info(v[2]) - tonumber(v[3]) < 0 then
                local info = table.copy(v)
                info.err = "lack"
                table.insert(error_list, info)
            end
        end
    end

    if #error_list == 0 then
        for k, v in pairs(reward or {}) do
            if v[1] == "item" then
                self:set_info(v[2], self:get_info(v[2]) - tonumber(v[3]))
            end
        end
        return 0
    else
        return 1, error_list
    end
end

return _M