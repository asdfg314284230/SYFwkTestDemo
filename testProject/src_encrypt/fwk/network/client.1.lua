local client = {}
client.__index = client
local proto 	    = require "fwk.network.proto"
local socket_auth 	    = require "fwk.network.socket_auth"
local socket_game 	    = require "fwk.network.socket_game"

local ping_time = 20

local ping = 0
local push = 1
local request = 2

local OPT_STR_DATA           = string.pack("BB", 1, 0) 
local OPT_STR_PING           = string.pack("BB", 2, 0)
local OPT_STR_COMPRESS_DATA  = string.pack("BB", 3, 0)
local OPT_STR_CMD            = string.pack("BB", 5, 0)
local OPT_STR_DATA_SUB_BEGIN = string.pack("BB", 6, 0)
local OPT_STR_DATA_SUB       = string.pack("BB", 7, 0)
local OPT_STR_DATA_SUB_END   = string.pack("BB", 8, 0)

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
        self._socket_game = socket_game.open(game_host, game_port, function(cmd, socket, ...)
            if cmd == "open" then
                socket:handshake()
            elseif cmd == "close" then
                U.log.w("网络断开")
            elseif cmd == "handshake" then
                local state = ...
                if state == "200" then
                    self._is_handshake = true
                    -- self:send_request_push()
                    for k, v in pairs(self._queue) do
                        self:send_request(v)
                    end
                    self._queue = {}
                else
                    self._is_handshake = false
                    U.log.e("handshake fail state:" .. tostring(state))
                end
            elseif cmd == "package" then
                local package = ...
                
                self:package(package)

                -- local len = string.len(package)
                -- U.log.i(len)
                -- local op, op_id, msg_id, msg, ok, session = string.unpack(">c2I2I2c" .. len - 2 - 4 - 5 .. "BI4", package)
                -- U.log.i(op, op_id, msg_id, msg, ok, session)
                -- U.log.i(op_id , push)
                -- if op_id == ping then
                -- elseif op_id == push then
                --     -- self:send_request_push()
                --     self._cb.push(msg)
                -- elseif op_id == request then
                --     self._cb.message(op_id, msg_id, msg)
                -- else
                --     U.log.e("unknown op_id:" .. tostring(op_id))
                -- end
            end
        end, player_id, subid, secret)
    end
end

function client:process_data(package)
    local len = string.len(package)
    local op_id, msg_id, msg, ok, session = string.unpack(">I2I2c" .. len - 4 - 5 .. "BI4", package)
    if op_id == ping then
    elseif op_id == push then
        self._cb.push(msg)
    elseif op_id == request then
        self._cb.message(op_id, msg_id, msg)
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



function client:send_request(param)
    if not self._is_handshake then
        table.insert(self._queue, param)
    else
        param = param or {}
        self._session = self._session + 1
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
    end
end

-- function client:send_request_push()
--     U.log.i("send_request_push")
--     self._session = self._session + 1
-- 	local size = 2 + 2 + 4
-- 	local package = string.pack(">I2", size)..string.pack(">I2", push)..string.pack(">I2", 0)..string.pack(">I4", self._session)
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

return client