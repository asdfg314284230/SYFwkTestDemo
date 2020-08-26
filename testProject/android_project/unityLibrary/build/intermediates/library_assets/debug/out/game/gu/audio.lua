local audio = {}

-- 背景音乐
local _sound = {
    obj = nil,
    as_list = {},
}

-- 音效
local _effect = {
    obj = nil,
    effect_id = 0,
    as_list = {
        --[[
            index:key
            as:AudioSource
            tag:标签
            task_id:计时器任务id
            effect_id:音效id
        ]]
    },
}

function audio.init(mode)
    local audio_obj = CS.UnityEngine.GameObject.Find("audio")

    _sound.obj = audio_obj.transform:Find("sound").gameObject
    audio.add_audiosource_component(_sound, true)

    _effect.obj = audio_obj.transform:Find("effect").gameObject
    audio.add_audiosource_component(_effect)
end

-- 设置背景音乐是否可用
-- @param enable 是否可用
function audio.set_sound_enable(enable)
    _sound.obj:SetActive(not not enable)
end

--游戏登录初始化声音大小
function audio.init_volume()
   local volume1 = M.get_local_data("player_info_set_music_value") or 1
   local volume2 = M.get_local_data("player_info_set_effect_value") or 1
   
   audio.set_sound_volume(volume1)
   audio.set_effect_volume(volume2)
end
--设置音乐大小
function audio.set_sound_volume(value)
    for i = 1,#_sound.as_list do
        _sound.as_list[1].as.volume = value
    end
end
--设置音效大小
function  audio.set_effect_volume(value)
    for i = 1,#_effect.as_list do
        _effect.as_list[i].as.volume = value
    end
end
--------------------------------------------------------------------------------------
-- 设置音效是否可用
-- @param enable 是否可用
function audio.set_effect_enable(enable)
    _effect.obj:SetActive(not not enable)
end

-- 添加音源组件
function audio.add_audiosource_component(t, loop)
    local as = UI.add_component(t.obj, "AudioSource")
    as.loop = not not loop
    as.playOnAwake = false
    
    local effect_value = M.get_local_data("player_info_set_effect_value") or 0.5
    as.volume = effect_value

    table.insert(t.as_list, {as = as, index = #t.as_list + 1})
    return as
end

--------------------------------------------------------------------------------------
-- 播放背景音乐
-- @param path[stirng] 音乐文件路径
--------------------------------------------------------------------------------------
function audio.play_sound(path)
    local info = _sound.as_list[1]
    if info then
        -- 正在播放该背景音乐，不重新播放
        if info.path == path then
            return
        end

        UI.load_sound(path, function(asset)
            info.as.clip = asset
            info.as:Play()
            info.path = path
        end)
    end
end

--------------------------------------------------------------------------------------
-- 停止背景音乐
--------------------------------------------------------------------------------------
function audio.stop_sound()
    local info = _sound.as_list[1]
    if info then
        info.as:Stop()
        info.path = nil
    end
end

--------------------------------------------------------------------------------------
-- 暂停/播放
--------------------------------------------------------------------------------------
function audio.pause_sound(flag)
    local info = _sound.as_list[1]
    if info then
        if flag then
            info.as:Pause()
        else
            info.as:UnPause()
        end
    end
end

--------------------------------------------------------------------------------------
-- 播放音效
-- @param path[string] 音乐文件名
-- @param interrupt[string] 是否中断前一个音效 这里的前一个表示前一个通过传递interrupt为true播放的音效
-- @param loop 是否循环播放
-- @param cb 播放音效完成回调
--------------------------------------------------------------------------------------
function audio.play_effect(param)
    local path = param.path
    local interrupt = param.interrupt
    local noSound = param.noSound
    local cb = param.cb
    local tag = param.tag
    local loop = not not param.loop
    audio.stop_effect_by_tag({interrupt = interrupt})

    local info, index = audio.get_audio_source_effect()
    if info then
        _effect.effect_id = _effect.effect_id + 1
        info.effect_id = _effect.effect_id
        info.tag = tag

        UI.load_sound(path, function(asset)
            info.as.clip = asset
            -- 空资源，仍然需要调用回调
            if not info.as.clip then
                if type(cb) == "function" then 
                    audio.stop_effect({index = index, effect_id = info.effect_id})
                    cb() 
                end
                return
            end
            info.as.loop = loop
            info.as:Play()

            if not loop then
                local length = info.as.clip.length
                local task_id = U.schedule.add_task({
                    delay = length,
                    func = function()
                        if type(cb) == "function" then
                            audio.stop_effect({index = index, effect_id = info.effect_id})
                            cb()
                        end
                    end
                })
                info.task_id = task_id
            end
        end)

        local handler = {}
        handler.index = index
        handler.effect_id = info.effect_id
        return handler
    end
end


function audio.stop_effect_by_tag(param)
     -- 中断响应tag的音效
     local interrupt = param.interrupt
     for i = 1, #_effect.as_list do
        local info = _effect.as_list[i]
        if info.tag and (info.tag == interrupt or interrupt == "all") then
            audio.stop_effect({index = info.index, effect_id = info.effect_id})
        end
    end
end

function audio.stop_effect(param)
    local index = param.index
    local effect_id = param.effect_id
    local info = _effect.as_list[index]
    if info and info.effect_id == effect_id then
        if info.task_id then
            U.schedule.remove_task(info.task_id)
        end
        info.task_id = nil
        info.as:Stop()
        info.tag = nil
        info.effect_id = nil
    end
end

function audio.get_audio_source_effect()
    for i = 1, #_effect.as_list do
        local info = _effect.as_list[i]
        if not info.as.isPlaying then
            return info, i
        end
    end

    audio.add_audiosource_component(_effect)
    return _effect.as_list[#_effect.as_list], #_effect.as_list
end

return audio