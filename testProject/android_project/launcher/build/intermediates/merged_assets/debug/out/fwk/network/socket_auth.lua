--------------------------------------------------------------------------------------
-- author liuyang
-- date 2019-06-17
-- copyright 2019 -- 2019 yang zhang
-- desc socket
-- @local
--------------------------------------------------------------------------------------

local core = require "socket.core"
local socket = {}

local function writeline(fd, text)
	fd:send(text .. "\n")
end

local function encode_token(token)
    return string.format("%s@%s:%s",
        CS.Skynet.Crypt.Base64Encode(token.user),
        CS.Skynet.Crypt.Base64Encode(token.server),
        CS.Skynet.Crypt.Base64Encode(token.pass))
end

local cur_retry_count = 0
local max_retry_count = 3

function socket.open(host, port, player_id)
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
        fd:settimeout(3)                -- no block
        fd:setoption("tcp-nodelay", true)
        success, err = fd:connect(host, port)
    end

    print(success, err)
    if err then
        -- cur_retry_count = cur_retry_count + 1
        -- U.log.i("retry_count = " .. cur_retry_count)
        -- if cur_retry_count >= max_retry_count then
        --     cur_retry_count = 0
        --     return
        -- end
        -- socket.open(host, port, player_id)
        return
    end

    local challenge_byte = fd:receive("*l")
    if not challenge_byte then
        U.log.e("SSSSSSSSS")
        return 
    end

    local challenge = CS.Skynet.Crypt.Base64Decode(challenge_byte)
    local clientkey = CS.Skynet.Crypt.RandomKey()
    writeline(fd, CS.Skynet.Crypt.Base64Encode(CS.Skynet.Crypt.DHExchange(clientkey)))
    local secret = CS.Skynet.Crypt.DHSecret(CS.Skynet.Crypt.Base64Decode(fd:receive("*l")), clientkey)
    local hmac = CS.Skynet.Crypt.HMAC64(challenge, secret)
    writeline(fd, CS.Skynet.Crypt.Base64Encode(hmac))

    local token = {
        server = "sample",
        user = tostring(player_id),
        pass = "password",
    }


    local etoken = CS.Skynet.Crypt.DesEncode(secret, encode_token(token))
    local b = CS.Skynet.Crypt.Base64Encode(etoken)
    writeline(fd, CS.Skynet.Crypt.Base64Encode(etoken))
    local result = fd:receive("*l")
    print(result)
    local code = tonumber(string.sub(result, 1, 3))
    if code ~= 200 then
        U.log.w(type(code), code)
        return code
    end
    local subid = CS.Skynet.Crypt.Base64Decode(string.sub(result, 5))
    return 0, subid, secret
end


return socket