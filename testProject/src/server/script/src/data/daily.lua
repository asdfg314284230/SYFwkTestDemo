--[[
    new_day:

    job服务 cmd time_callback(s, ...) {jobs} new_day(...)
    -- 可以通过cmd和ctx调到
    msgagent服务 cmd time_callback(s, ...) time_callback(...) daily.new_day(...) daily是data.daily.lua
                 _ctx.init(time_callback = time_callback)

    time_callback:

    syctx
        -- ctx初始化保存timecallback
        ctx.init(param) ctx.time_callback = param.time_callback

        ctx.load_data_by_cid(cid)
            -- 比较当前天和登出天
            _ctx.sytime.day() > _ctx.sytime.day(d.fwk_sys.logout_time)
                ctx.time_callback("day_diff_login")

    symsgserver
        cmd time_callback = assert(conf.time_callback)

    gated
        server.time_callback(...)
            {users} time_callback

    timeserver
        -- 给gate服务发送time_callback，gate服务会给每个user发送time_callback user会调用daily.new_day
        skynet.send(gate, "lua", "time_callback", k)
        -- 给job服务发送time_callback，job服务会调用每个job的 new_day
        skynet.send(job, "lua", "time_callback", k)

]]
local daily = {}

function daily.new_day(...)
    _ctx.log.w('daily.new_day', ...)

    local key = ...
    _ctx.ctrl.daily.daily(key)
    -- 每日任务数据刷新
    _ctx.ctrl.mission.init_daily_mission_data()
    -- 军团冒险每日刷新
    _ctx.ctrl.legion.refresh_daily_data()
    -- 酒馆每日刷新
    _ctx.ctrl.recruit_bar.today_refresh_data()
end

return daily
