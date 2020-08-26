U.log.i('game start')

local gu = require('game.gu.gu')

local main = function(run_mode)
    
    print('game main entry')

    -- -- 这个貌似是初始化proto的方法
    -- N.init_proto()

    -- UI.set_tips({name = 'common.systips'})

    -- N.register_net_callback('kick', function()
    --     U.log.i('kick')

    --     -- 被踢了 让他回到登陆界面
    --     UI.load({name = 'login.login_main'})
    -- end)

    -- N.register_net_callback('reconnection',
    --                         function() U.log.i('reconnection') end)

    -- -- 注册登陆回调
    -- local p2l = Game.U.platform_to_lua
    -- local l2p = Game.U.lua_to_platform

    -- -- 登陆成功回调
    -- p2l.set_callback('login_success', function(d)

    --     l2p.set_login(true)
    --     -- 数据转换
    --     local json_str = U.json.decode(d)
    --     -- 设置玩家账号数据
    --     local player_info = {username = d.id, passworld = d.passworld}
    --     -- 设置本地数据
    --     M.set_local_data('player_info', player_info)

    -- end)

    -- -- 登陆失败回调
    -- p2l.set_callback('login_fail', function(d) l2p.set_login(false) end)
    -- -- 主动退出
    -- p2l.set_callback('logout_success', function(d) l2p.set_login(false) end)


    local world_canvas = UI.get_canvas('world_canvas')
    local base_canvas = UI.get_canvas('base_canvas')
    local world_rect = UI.seek_component(world_canvas, world_canvas.name,
                                         'RectTransform')
    local base_rect = UI.seek_component(base_canvas, base_canvas.name,
                                        'RectTransform')
    local scale = base_rect.sizeDelta.x / world_rect.sizeDelta.x
    world_rect.localScale = {
        x = world_rect.localScale.x * scale,
        y = world_rect.localScale.y * scale,
        z = world_rect.localScale.z * scale
    }

    -- Game.U.audio.play_sound('sound/main_bgm')

    -- UI.set_common_sound_func(function()
    --     Game.U.audio.play_effect({path = Game.U.constant.sound.click})
    -- end)

    Game.U.audio.init_volume()

    UI.load({name = "loading.loading_main"})

end

return function(run_mode) return main, gu end
