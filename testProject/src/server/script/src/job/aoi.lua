--数据库数据
local _all_data
--外部调用
local _command = {}
--
local function on_init(all_data)
    _all_data = all_data or {}
    --初始化数据
    _jctx.log.i("job_aoi on_init")
end

--加载完成后方法
local function on_finish()
    _jctx.log.i("job_aoi on_finish")
    -- _jctx.job.racing.send("get_tid")
end

function _command.test(...)
    -- _jctx.log.dump(_all_data)
    -- _all_data.aoi_room_num = _all_data.aoi_room_num + 1
    -- _all_data.room_list["p1"].player = _all_data.room_list["p1"].player + 1
    -- _all_data.room_list["p3"] = {
    --     player = 1024
    -- }
    -- _all_data.room_list["p2"] = nil
    local code = EC.OK
    local msg = {
        a = 1,
        b = 2,
        s = "AS"
    }

    local s_pcid,  mod, cmd, param = ...
    _jctx.log.i(mod, cmd, param)

    _jctx.send_command("all", mod, cmd, param)
    
    return code, msg
end

--[[    
    新一天执行的方法
]]
local function _new_day(...)
    _jctx.log.i("job_aoi _new_day", ...)
end

return {
    init = on_init, -- 模块初始化完毕后，会调用这个函数
    schema = "job_aoi", -- 指定模块数据的schema文件名称
    command = _command, -- logic模块可以通过call/send调用本模块接口
    finish = on_finish, -- 所有job加载完成之后的回调
    auto_sync = false, -- 自动同步本模块数据到客户端
    new_day = _new_day --新一天执行的方法
}
