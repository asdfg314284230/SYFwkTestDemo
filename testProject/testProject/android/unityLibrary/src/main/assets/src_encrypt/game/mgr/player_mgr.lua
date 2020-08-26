--------------------------------------------------------------------------------------
-- author CJW
-- date 2020-08-25
-- desc 玩家MGR
--------------------------------------------------------------------------------------
local _MGR = {}

function _MGR:on_unload()
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
    -- 一直跟随鼠标移动
    local w_pos =
        UI.CS.Camera.main:ScreenToWorldPoint({x = UI.CS.Input.mousePosition.x, y = UI.CS.Input.mousePosition.y, z = 1})

    self.player_obj.transform.position = {
        x = w_pos.x,
        y = w_pos.y,
        z = w_pos.z
    }

    -- 间隔射击子弹
    if self.update_dt >= self.atk_time then
        UI.load({name = "fight.fight_bullet", parent = self.bullet_obj_pos.transform},{pos = self.bullet_obj.transform.position})
        self.update_dt = self.update_dt - self.atk_time
    else
        self.update_dt = self.update_dt + dt
    end

    -- -- 控制玩家移动
    -- if UI.CS.Input.GetMouseButton(0) then
    -- else
    --     if UI.CS.Input.touches.Length > 0 then
    --         local touch = UI.CS.Input:GetTouch(0)
    --         local w_pos = UI.CS.Camera.main:ScreenToWorldPoint({x = touch.position.x, y = touch.position.y, z = 1})
    --     -- U.log.dump(w_pos)
    --     end
    -- end
end

function _MGR:init(param)
    self.player_obj = param.player_pos
    self.bullet_obj = param.bullet_obj
    self.bullet_obj_pos = param.bullet_pos_obj
    self.update_dt = 0
    -- 攻击间隔
    self.atk_time = 0.5
end

function _MGR:exit()
end

return _MGR
