local _MGR = {}

function _MGR:on_unload()
    U.log.i("on_unload fight mgr")
    if self._schedule_task then
        U.schedule.remove_task(self._schedule_task)
    end
end

function _MGR:on_load()
    self._schedule_task =
        U.schedule.add_task(
        {
            mode = "forever",
            func = U.handle(self, self.update)
        }
    )
end

function _MGR:update(dt)
    if self.state == "fight_start" then
        if self.time_temp < 1 then
            self.time_temp = self.time_temp + dt
        else
            self.time_temp = self.time_temp - 1
            self.fight_time = self.fight_time - 1
        end

        if self.fight_item_time < self.load_item_time then
            self.fight_item_time = self.fight_item_time + dt
        else
            self.fight_item_time = self.fight_item_time - self.load_item_time
            -- 生成item
            self:load_enemy_item()
        end

        if self.fight_time <= 0 then
            self:fight_end()
        end
    end

    self.time_obj.text = self.fight_time
end

function _MGR:init(param)
    self.state = "nor"
    self.fight_time = 60
    self.fight_value = 0
    self.time_temp = 0
    self.fight_item_time = 0
    self.load_item_list = {}

    self.time_obj = param.time_obj
    self.level_obj = param.level_obj
    self.monster_pos = param.monster_pos
    self.move_panel_list = param.move_panel_list
end

function _MGR:fight_start()
    -- 滚动背景布
    self:init_move_bg()

    -- 初始化怪物
    self:init_all_enmey()
end

function _MGR:init_all_enmey()
    -- 获取当前关卡（目前没有关卡的概念）
    local lv = M.fight:get_info("lv")

    self.enemy_list = {
        [1] = "001",
        [2] = "002",
        [3] = "003",
        [4] = "004",
        [5] = "005"
    }

    -- 根据关卡配置生成item
    self.enemy_conf = {
        ["001"] = {
            name = "冰毒"
        },
        ["002"] = {
            name = "K粉"
        },
        ["003"] = {
            name = "大麻"
        },
        ["004"] = {
            name = "大麻糖果"
        },
        ["005"] = {
            name = "果冻冰毒"
        }
    }

    -- 设置生成item的时间间隔
    self.load_item_time = 1.5

    self.state = "fight_start"
end

-- 背景布滚动
function _MGR:init_move_bg()
    for i = 1, 2 do
        
        -- local pos = self.move_panel_list[i].transform

    end
end

function _MGR:load_enemy_item()
    -- 这里算下随机权重给一个生成ID进来
    local randow = math.random(1, 5)

    local load_id = self.enemy_list[randow]

    if load_id then
        -- 生成item
        local uiid = UI.load({name = "fight.fight_item", parent = self.monster_pos.transform}, {cid = load_id})
        table.insert(self.load_item_list, uiid)
    end
end

function _MGR:fight_end()
    self.state = "nor"
    self.fight_time = 60

    -- -- 设置时间轴为0
    -- UI.set_time_scale(0)

    -- 清楚场上所有item
    for k, v in pairs(self.load_item_list) do
        UI.destroy(v)
    end

    -- -- 关卡积分
    -- local fight_value = M.fight:get_info("value")
end

function _MGR:exit()
    -- MGR.unload("fight")
    -- UI.go_last_base()
end

return _MGR
