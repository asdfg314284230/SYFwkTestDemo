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

function _MGR:init()
    self.state = "nor"
    self.fight_time = 0
    self:fight_start()
end

function _MGR:fight_start()
    -- 初始化时间
    self:init_all_enmey()
end

function _MGR:init_all_enmey()
    -- 获取当前关卡
    local lv = M.fight:get_info("lv")
    -- 根据关卡配置生成item
end

function _MGR:update(dt)
    if self.state == "fight_start" then
        self.fight_time = self.fight_time + dt
    end
end

function _MGR:fight_end()
    self.state = "fight_end"
    self.fight_time = nil
end

function _MGR:exit()
    -- MGR.unload("fight")
    -- UI.go_last_base()
end

return _MGR
