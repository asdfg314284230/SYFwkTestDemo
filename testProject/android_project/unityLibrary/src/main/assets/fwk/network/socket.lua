--------------------------------------------------------------------------------------
-- author yang
-- date 2018-04-18
-- copyright 2018 -- 2018 yang zhang
-- desc socket
-- @local
--------------------------------------------------------------------------------------

local core = require "socket.core"
local socket = {}
socket.__index = socket

local _fd_opening = {}
local _fd_opened  = {}
local _fd_2_socket = {}

function socket.open(host, port, cb)
    local fd, err, success
    -- 检测地址类型
    local addrinfo, err = core.dns.getaddrinfo(host) -- 这个会阻塞
    if addrinfo then
        local v6 = false
        for k,v in pairs(addrinfo) do  
            if v.family == "inet6" then  
                v6 = true  
                break  
            end  
        end
        if v6 then
            fd = assert(core.tcp6())
        else
            fd = assert(core.tcp())
        end
    else
        -- 解析失败了，还是创建一个fd，走整个流程
        fd = core.top()
    end
    
    if fd then
        fd:settimeout(0)                -- no block
        fd:setoption("tcp-nodelay", true)
        success, err = fd:connect(host, port)
    end

    local obj = setmetatable({
        _fd = fd,
        _port = port,
        _host = host,
        _pkg_size = 0,              -- 解析出的包大小
        _cb = cb,
        _send_queue = {},
        _connect_time = os.time(),  -- 发起连接的时间
    }, socket)


    _fd_2_socket[fd] = obj
    _fd_opening[fd] = obj
    if not success and err ~= "timeout" then
        obj._err = err
    end
    return obj
end

function socket.update()

    local ws = table.keys(_fd_opened)
    local rs = table.keys(_fd_opening)
    local r, w = core.select(ws, rs, 0)
    --print(#ws, #rs, #r, #w)
    if #w > 0 then
        for _, fd in ipairs(w) do 
            local sock = assert(_fd_2_socket[fd])
            sock:_on_open()
        end
    end
    if #r > 0 then
        for _, fd in ipairs(r) do 
            local sock = assert(_fd_2_socket[fd])
            sock:_on_receive()
        end
    end

    -- 检测是否连接超时
    local now = os.time()
    for fd, sock in pairs(_fd_opening) do 
        local err = sock._err or fd:getoption("error")
        if err then
            print(fd, "close", err)
            sock:_on_close()
        end
    end
    -- 检测是否需要发送数据
    for fd, sock in pairs(_fd_opened) do 
        sock:_send()
    end
end

function socket:send(package)
    local buffer = string.pack(">s2", package)
    table.insert(self._send_queue, buffer)
end

function socket:_send()
    for i = 1, 16 do -- 每一帧最多发送16个包，暂时应该是够的
        local buffer = table.remove(self._send_queue, 1)
        if buffer then
            local ret, err = self._fd:send(buffer)
        else 
            break
        end
    end

end

function socket:_on_open()
    _fd_opening[self._fd] = nil
    _fd_opened[self._fd]  = self
    self._buffer_size = 0
    self:_notify("open")
end

function socket:_notify(cmd, ...)
    self._cb(cmd, self, ...)
end

function socket:_dispatch(package)
    self._cb("package", self, package)
end

local HEAD_SIZE = 2
function socket:_on_receive()
    local close = false
    local close_info = nil
    local _do_recvice = function (size)
        local data = nil
        local d1, err, d2 = self._fd:receive(size)      --读取足够数据d1, 非完整数据 d2
        if d1 then
            data = d1
        elseif err == "timeout" and d2 ~= nil then
            data = d2
        elseif err == "closed" then
            -- 远端断开了连接，可能最后会发送一条消息
            if d2 then
                data = d2
            end
            close = true
        end
        if data then
            if self._buffer == nil then
                self._buffer = data
            else 
                self._buffer = self._buffer .. data
            end
            self._buffer_size = string.len(self._buffer)
        end
    end
    while true do 
        if self._fd == nil then -- 连接上就被断开了
            close = true
            break
        end
        local data = nil
        if self._pkg_size == 0 then     -- 包大小为0，说明还没解析包头
            _do_recvice(HEAD_SIZE)
            if self._buffer_size >= HEAD_SIZE then
                -- 大端, 如果改了HEAD_SIZE 这个计算逻辑也要改
                local b1, b2 = string.byte(self._buffer, 1, 2); 
                self._pkg_size = b1 * 256 + b2
            else
                break
            end
        end
        if self._pkg_size > 0 then
            _do_recvice(self._pkg_size) -- 这里粘包第二次读取时，没有这么多数据，貌似多读一点没所谓
            -- 有完整包
            if self._buffer_size >= self._pkg_size + HEAD_SIZE then
                local package = string.sub(self._buffer, HEAD_SIZE + 1, self._pkg_size + HEAD_SIZE)
                self._buffer = string.sub(self._buffer, self._pkg_size + HEAD_SIZE + 1)
                self._buffer_size = string.len(self._buffer)
                self._pkg_size = 0
                self:_dispatch(package)
            -- 没有完整包
            else
                break
            end
        end
    end
    if close then
        self:_on_close(self._buffer)
    end
end

function socket:_on_close(close_info)
    if self._fd then
        _fd_opened[self._fd] = nil
        _fd_opening[self._fd] = nil
        _fd_2_socket[self._fd] = nil
        self._fd = nil
        self:_notify("close", close_info)
    end
end

function socket:close()
    if self._fd then
        self._fd:close()
        self:_on_close()    -- 主动关闭给上层补发一个close消息
    end
end

return socket