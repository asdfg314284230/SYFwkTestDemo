--------------------------------------------------------------------------------------
-- 网络模块
-- @module N
-- @author liuyang
-- @date 2019-02-28
--------------------------------------------------------------------------------------
local proto = require "fwk.network.proto"
local socket_core = require "socket.core"
local _net_fwk = {}
local _net_user = {}
local _msg_handler = {}
local _msg_err_handler = {}
local _msg_handler_ex = {}

local message 	    = require "fwk.network.message"
local client 	    = require "fwk.network.client"

local cur_client = nil
local mmodel = nil
local _cfg = nil

local net_callback = {}

local client_handle = {
    message = function(op_id, msg_id, msg, session, session_data)
        local nm_info = NMINFO[msg_id]
        if nm_info then
            local data = proto.decode("B2C_COMMON", msg)

            if data.t then
                mmodel.set_offset_time(data.t - os.time())
                mmodel.set_offset_precise_time(data.precise_t - socket_core.gettime())
            end

            local e = data.e
            if e ~= EC.OK then
                UI.show_tips(EC:toString(e))
                if _msg_err_handler[nm_info.name] then
                    _msg_err_handler[nm_info.name](m, session_data)
                end
            else
                local m = U.json.decode(data.m)
                if nm_info.nm_type == "INITDATA" then
                    mmodel.reset_data(m.d)
                end
    
                if data.change_tab then
                    mmodel.update_data(data.change_tab, session_data)
                end
    
                local func = _msg_handler[nm_info.name]
                if func then
                    func(m, session_data)
                end
            end

            if _msg_handler_ex[nm_info.name] then
                _msg_handler_ex[nm_info.name](m, session_data)
            end
        else
            UI.show_tips("unknow msg_id:" .. tostring(msg_id))
            U.log.e("unknow msg_id:" .. tostring(msg_id))
        end
    end,
    push = function(op_id, msg_id, msg, session, session_data)
        -- local data = U.json.decode(msg)
        -- U.log.dump(data)
        U.log.i(op_id, msg_id, msg)
        local nm_info = NMINFO[msg_id]
        if nm_info then
            local data = proto.decode("B2C_COMMON", msg)
            U.log.dump(data)
            if data.t then
                mmodel.set_offset_time(data.t - os.time())
                mmodel.set_offset_precise_time(data.precise_t - socket_core.gettime())
            end

            local e = data.e
            if e ~= EC.OK then
                U.log.i(e, EC:toString(e))
                UI.show_tips(EC:toString(e))
                return
            end
            
            local m = U.json.decode(data.m)
            if nm_info.nm_type == "INITDATA" then
                mmodel.reset_data(m.d)
            end

            if data.change_tab then
                mmodel.update_data(data.change_tab, session_data)
            end

            local func = _msg_handler[nm_info.name]
            if func then
                func(m)
            end
        else
            UI.show_tips("unknow msg_id:" .. tostring(msg_id))
            U.log.e("unknow msg_id:" .. tostring(msg_id))
        end
    end,

    ----------------------net_callback-------------------------
    on_process_data = function(session)
        UI.net_mask_on_process_data(session)
        local f = net_callback["on_process_data"]
        if f then
            f(session)
        end
    end,

    on_send_request = function(session)
        UI.net_mask_on_send_request(session)
        local f = net_callback["on_send_request"]
        if f then
            f(session)
        end
    end,

    kick = function()
        UI.net_mask_reset()
        local f = net_callback["kick"]
        if f then
            f()
        end
    end,
    -- reconnection = function()
    --     UI.net_mask_reset()
    --     local f = net_callback["reconnection"]
    --     if f then
    --         f()
    --     end
    -- end,
    auth_fail = function (state)
        UI.net_mask_reset()
        local f = net_callback["auth_fail"]
        if f then
            f(state)
        end
    end,
    close = function ()
        UI.net_mask_reset()
        local f = net_callback["close"]
        if f then
            f()
        end
    end
}


function _net_fwk.init(mode, cfg, model)
    mmodel = model
    _cfg = cfg
    message.init()
    _net_user.NM = message.NM
    _net_user.NMINFO = message.NMINFO
    _net_user.EC = message.EC
    return _net_user
end

function _net_fwk.update()
    -- socket_game.update()
    if cur_client then
        cur_client:update()
    end
end

function _net_user.init_proto()
    -- _cfg .. "game/pb"
    proto.init_proto(_cfg.root)
    -- pb.loadfile(_cfg.root .. "game/pb/test.pb")
    -- pb.loadfile(_cfg.root .. "game/pb/player.pb")
end

function _net_user.open(param)
    cur_client = client.create(mmodel, client_handle)
    cur_client:open(param, mmodel)
end

function _net_user.register_net_callback(key, func)
    net_callback[key] = func
end

--------------------------------------------------------------------------------------
-- 注册消息
-- @function N.register
-- @param mn[string]        NM.xxx xxx对应message中定义的消息名称
-- @param handle[function]  收到消息后的回调函数 
-- @see msg_handler
function _net_user.register(mn, handler)
    if not _msg_handler[mn.name] and type(handler) == "function" then
        _msg_handler[mn.name] = handler
    end 
end

function _net_user.register_err_handler(mn, handler)
    if not _msg_err_handler[mn.name] and type(handler) == "function" then
        _msg_err_handler[mn.name] = handler
    end 
end

function _net_user.register_handler_ex(mn, handler)
    if not _msg_handler_ex[mn.name] and type(handler) == "function" then
        _msg_handler_ex[mn.name] = handler
    end 
end

--------------------------------------------------------------------------------------
-- 发送消息
-- @function N.send
function _net_user.send(param)
    param = param or {}
    if cur_client then
        cur_client:send_request(param)
    else
        U.log.e("client not init")
    end
end


function _net_user.close_game_socket()
    if cur_client then
        cur_client:close_game_socket()
    else
        U.log.e("client not init")
    end
end


-- function _net_user.event(cb)

-- end

return {
    init = _net_fwk.init,
    update = _net_fwk.update,
}