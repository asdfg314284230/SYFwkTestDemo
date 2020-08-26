-- 平台返回lua的脚本工程
local _M = {}
local PlatformToUnity = nil

-- 回调List
local callback_check_list = {
    -- 登陆回调
    login_success = true,
    login_fail = true,
    logout_success = true,

    -- pay_success = true,
    -- pay_fail = true,
    -- video_event = true,
}

local callback_list = {}

-- 初始化并把对象委托连接到消息组中
function _M.init(run_mode)
    if run_mode == "unity" then
        local sdk_ob = CS.UnityEngine.GameObject.Find("sdk")
        PlatformToUnity = sdk_ob:GetComponent("PlatformToUnity")
        PlatformToUnity.func = _M.platform_msg
        return _M
    end
end

-- 设置回调
function _M.set_callback(key, value)
    assert(callback_check_list[key])
    callback_list[key] = value
end

-- 通过接受消息组收到消息调用
function _M.platform_msg(json_str)

    -- 测试通讯流程
    local d,err = json_str

    -- 添加收到消息的打印 
    U.log.w(json_str)

    -- 如果不为空,就说明登陆成功
    if d then
        -- 默认全部登陆成功
        local call_key = "login_success"

        -- 判断是否有该回调
        if callback_list[call_key] then
            -- 执行回调
            callback_list[call_key](d)
        else
            -- 打印错误
            print("no find callback call_key:" .. tostring(call_key))
        end

    end

    -- local d, err = U.json.decode(json_str)

    -- if d then
    --     U.log.dump(d)
    --     if d.type == "purchase" then
    --         d.type = "pay"
    --     end
    --     if d.type == "pay" or d.type == "login" then
    --         -- common.destroy_platform_mask_canvas()
    --     end

    --     local call_key = tostring(d.type) .. "_" .. tostring(d.result)
        
    --     if callback_list[call_key] then
    --         callback_list[call_key](d)
    --     else
    --         print("no find callback call_key:" .. tostring(call_key))
    --     end
    -- end
end

return _M