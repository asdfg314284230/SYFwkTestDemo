local client = {}
client.__index = client
local proto 	    = require "fwk.network.proto"
local socket_auth 	    = require "fwk.network.socket_auth"
local socket_game 	    = require "fwk.network.socket_game"

local ping_time = 5

local ping = 0
local push = 1
local request = 2
local kick = 3

local OPT_STR_DATA           = string.pack("BB", 1, 0) 
local OPT_STR_PING           = string.pack("BB", 2, 0)
local OPT_STR_COMPRESS_DATA  = string.pack("BB", 3, 0)
local OPT_STR_CMD            = string.pack("BB", 5, 0)
local OPT_STR_DATA_SUB_BEGIN = string.pack("BB", 6, 0)
local OPT_STR_DATA_SUB       = string.pack("BB", 7, 0)
local OPT_STR_DATA_SUB_END   = string.pack("BB", 8, 0)

local session_data = {}

-- 创建新的对象
function client.create(mmodel, cb)
    local obj = {
        _mmodel = mmodel,
        _cb = cb,
        _session = 0,
        _socket_game = nil,
        _is_handshake = false,
        _last_send_time = os.time(),
        _queue = {},
        _state = "init",
        _ver = 0,
    }

    return setmetatable(obj, client)
end

function client:update()
    socket_game.update()
    if os.time() - self._last_send_time > ping_time then
        self:send_ping()
    end
end

function client:open(param)
    param = param or {}
    local auth_host = param.auth_host
    local auth_port = param.auth_port
    local game_host = param.game_host
    local game_port = param.game_port
    local player_id = param.player_id
    local state, subid, secret = socket_auth.open(auth_host, auth_port, player_id)
    -- print(state, subid, secret)
    if state == 0 then
        self:content_game(param, subid, secret)
    else
        self._cb.auth_fail(state)
    end
end

function client:content_game(param, subid, secret)
    param = param or {}
    local auth_host = param.auth_host
    local auth_port = param.auth_port
    local game_host = param.game_host
    local game_port = param.game_port
    local player_id = param.player_id
    self._ver = self._ver + 1
    self._socket_game = socket_game.open(game_host, game_port, function(cmd, socket, ...)
        if cmd == "open" then
            self._state = "open"
            socket:handshake()
        elseif cmd == "close" then
            U.log.w("网络断开")
            self._cb.close()

            -- if self._state ~= "kick" then
            --     self._state = "close"
            --     self._cb.close()
            -- end
            
        elseif cmd == "handshake" then
            local state = ...
            if state == "200" then
                self._is_handshake = true
                -- self:send_request_push()
                for k, v in pairs(self._queue) do
                    self:send_request(v)
                end
                self._queue = {}

                -- if self._is_reconnection then
                --     self._cb.reconnection()
                --     self._is_reconnection = false
                -- end
            else
                self._is_handshake = false
                U.log.e("handshake fail state:" .. tostring(state))
            end
        elseif cmd == "package" then
            local package = ...
            self:package(package)
        end
    end, player_id, subid, secret, self._ver)
end

function client:process_data(package)
    local len = string.len(package)
    local op_id, msg_id, msg, ok, session = string.unpack(">I2I2c" .. len - 4 - 5 .. "BI4", package)
    if op_id == ping then
    elseif op_id == push then
        self._cb.push(op_id, msg_id, msg, session, session_data[tostring(session)])
    elseif op_id == request then
        self._cb.message(op_id, msg_id, msg, session, session_data[tostring(session)])
        self._cb.on_process_data(session)
    elseif op_id == kick then
        self._state = "kick"
        self._cb.kick()

        if self._socket_game then
            self._socket_game:close()
        end
    else
        U.log.e("unknown op_id:" .. tostring(op_id))
    end
end

function client:package(package)
    -- local opt, op_id, msg_id, msg, ok, session = string.unpack(">c2I2I2c" .. len - 2 - 4 - 5 .. "BI4", package)
    local opt = string.sub(package, 1, 2)
    if opt == OPT_STR_PING then

    elseif opt == OPT_STR_COMPRESS_DATA or opt == OPT_STR_DATA then
        self:process_data(string.sub(package, 3))
    elseif opt == OPT_STR_DATA_SUB_BEGIN then
        self._sub_data_cache = {
            [1] = string.sub(package, 3)
        }
    elseif opt == OPT_STR_DATA_SUB then
        if self._sub_data_cache then
            table.insert(self._sub_data_cache, string.sub(package, 3))
        end
    elseif opt == OPT_STR_DATA_SUB_END then
        if self._sub_data_cache then
            table.insert(self._sub_data_cache, string.sub(package, 3))
            local msg = table.concat(self._sub_data_cache)
            self:process_data(msg)
            self._sub_data_cache = nil
        end        
    else
        print("recv unknown op ", opt)
    end  
end


--[[
    param.message_info      消息定义
    param.message_data      消息数据
    param.no_mask           禁用网络遮罩
]]
function client:send_request(param)
    if not self._is_handshake then
        table.insert(self._queue, param)
    else
        param = param or {}
        self._session = self._session + 1
        session_data[tostring(self._session)] = param

        local message_info = param.message_info
        local message_data = param.message_data 

        local msg_id = message_info.id
        local msg = nil
        if message_info.pb == "NULL" then
            msg = U.json.encode(message_data)
        elseif message_info.pb ~= nil then
            msg = proto.encode(message_info.pb, message_data)
        end

        local size = #msg + 2 + 2 + 4
        local package = string.pack(">I2", size)..string.pack(">I2", request)..string.pack(">I2", msg_id)..msg..string.pack(">I4", self._session)
        self:send(package)
        
        if not param.no_mask then
            self._cb.on_send_request(self._session)
        end
    end
end

-- function client:send_request_push()
--     U.log.i("send_request_push")
--     self._session = self._session + 1
--     local size = 2 + 2 + 4
--     local package = string.pack(">I2", size)..string.pack(">I2", push)..string.pack(">I2", 0)..string.pack(">I4", self._session)
--     self:send(package)
-- end

function client:send_ping()
    self._session = self._session + 1
	local size = 2 + 2 + 4
	local package = string.pack(">I2", size)..string.pack(">I2", ping)..string.pack(">I2", 0)..string.pack(">I4", self._session)
    self:send(package)
end

function client:send(package)
    self._last_send_time = os.time()
    if self._socket_game then
        self._socket_game:send(package)
    else
        U.log.e("socket_game not init")
    end
end


function client:close_game_socket()
    if self._socket_game then
        self._socket_game:close()
    end
end

return client