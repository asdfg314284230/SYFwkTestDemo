
-- lua访问平台的脚本工程
local _M = {}
local UnityToPlatform = nil
local is_login = false
function _M.init(run_mode)
    if run_mode == "unity" then
        local sdk_ob = CS.UnityEngine.GameObject.Find("sdk")
        UnityToPlatform = sdk_ob:GetComponent("UnityToPlatform")

        -- local online_param = Game.config.online_param.get_online_param()
        
        -- local param = {}
        -- param.isAu = online_param.isAu or 0
        -- param.youmeng_key = Game.Param_config.Umeng_key
        -- param.youmeng_channel = Game.Param_config.Umeng_channel
        -- local json_str = U.json.encode(param)
        -- 模拟初始化SDK

        _M.init_sdk("")
        return _M
    end
end

function _M.init_sdk(json_str)
    return UnityToPlatform:init_sdk(json_str)
end

function _M.get_login()
    return is_login
end

function _M.set_login(flag)
    is_login = not not flag
end

-- -- 获取平台登录标志
-- function _M.is_platform_login()
--     return UnityToPlatform:is_platform_login()
-- end

-- -- 获取平台是否支持登出
-- function _M.isSupportLogout()
--     return UnityToPlatform:isSupportLogout()
-- end

-- -- 获取平台是否支持用户中心
-- function _M.isSupportAccountCenter()
--     return UnityToPlatform:isSupportAccountCenter()
-- end

-- 登录（临时修改）
function _M.login(json_str)
    -- common.create_platform_mask_canvas()
    U.log.w("执行登陆函数")
    UnityToPlatform:login(json_str)
end

-- 登出
-- function _M.logout()
--     if _M.isSupportLogout() then
--         UnityToPlatform:logout()
--     end
-- end

-- -- 用户中心
-- function _M.showAccountCenter()
--     UnityToPlatform:showAccountCenter()
-- end

-- 传角色信息接口
--[[
    int callType = 0;
    int roleCTime = 0;
    String roleID = "";
    String roleName = "";
    String roleLevel = "";
    String gameName = "";
    String zoneId = "";
    String zoneName = "";
    String serverID = "";
    String serverName = "";
]]
-- function _M.submitExtraData(param)
--     param = param or {}
--     local json_str = U.json.encode(param)
--     UnityToPlatform:submitExtraData(json_str)
-- end

-- -- @param type 
-- -- 角色进入游戏时传0，
-- -- 角色等级改变时传1,
-- -- 用户过完新手引导传2，
-- -- 新创建角色传3，
-- -- 退出游戏4，
-- -- 解锁牢房5，
-- -- 解锁衙门6，
-- -- 成功加入联盟/公会7 ，
-- -- 发送聊天信息8，
-- -- 进入商城11，
-- -- 退出商城12（有则接入，没有可不接）
-- function _M:sdk_submit_extra_data(callType)
-- 	if callType then
--         local server_info = M.get_local_data("cur_server")
--         if server_info then
--             local msg = {}
--             msg.callType = tonumber(callType)
--             msg.serverID = tostring(server_info.server_id)
--             msg.zoneId = tostring(server_info.server_id)
--             msg.roleID = tostring(M.rtdata.login.uid or "")
--             msg.serverName = tostring(server_info.display_name)
--             msg.zoneName = tostring(server_info.display_name)
--             msg.roleName = tostring(M.info.data.name or "")
--             msg.roleLevel = tostring(M.info.data.player_level or "")
--             msg.create_time = tonumber(M.info.data.create_time or 1)
--             Game.config.sdk.lua_to_platform.submitExtraData(msg)
--         end
-- 	end
-- end

-- -- 退出游戏
-- function _M.exit()
--     UnityToPlatform:exit()
-- end

-- 支付
--[[
    String productId = "";
    int price = 0;
    String productName = "";
    String productDesc = "";
    String extension = "";
    String payNotifyUrl = "";
]]
-- function _M:pay(param)
--     param = param or {}
--     local server_info = M.get_local_data("cur_server")
    
--     local httpc = U.http.new(function(rep)
--         if rep.success then
--             local d, err = U.json.decode(rep.data)
--             U.log.dump(d)
--             if d.success == true then
--                 local msg = {}
--                 msg.price = param.price or 100
--                 msg.extension = rep.data
--                 msg.notifyUrl = Game.config.url_config.payNotifyUrl
--                 msg.productId = param.productId or ""
--                 msg.productName = param.productName or ""
            
--                 msg.serverid = tostring(server_info.server_id)
--                 msg.zoneid = tostring(server_info.server_id)
--                 msg.roleid = tostring(M.rtdata.login.uid or "")
--                 msg.serverName = tostring(server_info.display_name)
--                 msg.roleName = tostring(M.info.data.name or "")
--                 msg.roleLevel = tostring(M.info.data.player_level or "")
--                 local json_str = U.json.encode(msg)
--                 UnityToPlatform:pay(json_str)
--             else

--             end
--         else

--         end
-- 	end)
    
--     local url = Game.config.url_config.prepare
--     local post_data = {}
--     post_data.uid = tostring(M.rtdata.login.uid or "")
--     post_data.shopid = tostring(param.shopid)
--     post_data.zid = tostring(server_info.game_id)
--     -- 修改为创酷的渠道号
--     post_data.channel = tostring(_M.getCurrChannel())
--     post_data.serverid = tostring(server_info.server_id)
--     local json_str = U.json.encode(post_data)
-- 	httpc:request(url, json_str, {method = "POST"})
-- end

-- -- 获取创酷给每个渠道分配的渠道号
-- function _M.getCurrChannel()
--     local currChannel = UnityToPlatform:getCurrChannel()
--     if currChannel == "" then
--         currChannel = "sy"
--     end
--     return currChannel
-- end

-- -- 统计事件
-- function _M.analytics_event(event_id, attributes)

--     local json_str = nil
--     if attributes then
--         json_str = U.json.encode(attributes)
--         UnityToPlatform:analytics_event(event_id, attributes)
--     else
--         UnityToPlatform:analytics_event(event_id)
--     end
-- end

-- -- 统计付费
-- function _M.analytics_pay(param)
--     param = param or {}
--     local json_str = U.json.encode(param)
--     UnityToPlatform:analytics_pay(json_str)
-- end

------------------------------------------------------------------
-- 视频播放相关
------------------------------------------------------------------

------------------------------------------------------------------
-- -- 是否支出视频播放器
-- function _M.video_support()
--     return UnityToPlatform.video_support and UnityToPlatform:video_support()
-- end

------------------------------------------------------------------
-- -- 播放视频
-- -- param videoName 视频文件名
-- -- param orientation 视频方向 1 横屏 2 竖屏
-- function _M.video_play(videoName, orientation)
--     local jsonStr = U.json.encode({videoName = videoName, orientation = orientation})
--     UnityToPlatform:video_play(jsonStr)
-- end

-- ------------------------------------------------------------------
-- -- 显示剧情分支
-- -- param branch 剧情分支
-- function _M.video_branch(branch)
--     local jsonStr = U.json.encode(branch)
--     UnityToPlatform:video_branch(jsonStr)
-- end

-- ------------------------------------------------------------------
-- -- 销毁视频播放器
-- function _M.video_destroy()
--     UnityToPlatform:video_destroy()
-- end

-- ------------------------------------------------------------------
-- -- 清空所有下载的视频
-- function _M:video_clear()
--     if UnityToPlatform.video_clear then
--         UnityToPlatform:video_clear()
--     end
-- end

return _M