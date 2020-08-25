--------------------------------------------------------------------------------------
-- author liuyang
-- date 2019-02-12
-- desc 用户UI模块基础方法
--------------------------------------------------------------------------------------
local base = {}
base.__index = base
local _load_id = 0

local _util = nil
local function init(util)
    _util = util
end

local function get_load_id()
    _load_id = _load_id + 1
    return tostring(_load_id)
end

--------------------------------------------------------------------------------------
-- 添加游戏对象组件
-- @param ob gameObject
-- @param name 组件名字
function base:add_component(ob, name, ...)
    return _util.add_component(ob, name, ...)
end

--------------------------------------------------------------------------------------
-- 添加无lua脚本的游戏对象
-- @param prefab 预制
-- @param parent 父节点
function base:add(prefab, parent, ...)
    assert(parent, "not find parent")
    return CS.UnityEngine.GameObject.Instantiate(prefab, parent, ...)
end

--------------------------------------------------------------------------------------
-- 通过预制添加无lua脚本的游戏对象
-- @param path 预制
-- @param parent 父节点
-- @param func 回调
-- @param instantiateInWorldSpace instantiateInWorldSpace
function base:add_by_path(path, parent, func, instantiateInWorldSpace)
    _util.uloader.add_ref_map(nil, path, _util.uloader.PREFAB)
    _util.load_prefab_sync(path, function(prefab)
        assert(parent, "not find parent")
        local ob = CS.UnityEngine.GameObject.Instantiate(prefab, parent, not not instantiateInWorldSpace)
        _util.uloader.add_ref_map_after(ob.gameObject, path, _util.uloader.PREFAB)
        if func then
            func(ob)
        end
    end)
end

--------------------------------------------------------------------------------------
-- 移除无lua脚本的游戏对象
-- @param ob 游戏对象
function base:remove(ob, ...)
    CS.UnityEngine.GameObject.Destroy(ob, ...)
end

--------------------------------------------------------------------------------------
-- 立即移除无lua脚本的游戏对象
-- @param ob 游戏对象
function base:remove_immediate(ob, ...)
    CS.UnityEngine.GameObject.DestroyImmediate(ob, ...)
end
--------------------------------------------------------------------------------------
-- 销毁自身
-- @param param 用户数据
function base:destroy_self(param)
    UI.destroy(self:get_ui_id(), param)
end

--------------------------------------------------------------------------------------
-- 查询游戏组件<br>
-- 重载1：node(父节点), name（对象名字）, type_string(组件类型)<br>
-- 重载2：name（对象名字）, type_string(组件类型)
function base:seek_component(...)
    local node, name, com_type = ...
    if select("#", ...) == 2 then
        name, com_type = ...
        node = self.gameObject
    end
    --assert(type(name) == "string", "seek_component name must string")
    assert(type(com_type) == "string", "seek_component component_type must string")
    return _util.seek_component(node, name, com_type)
end


--------------------------------------------------------------------------------------
-- 查询游戏对象 <br>
-- 重载1：node(父节点), name（对象名字） <br>
-- 重载2：name（对象名字）
function base:seek_object(...)
    local node, name, com_type = ...
    if select("#", ...) == 1 then
        name = ...
        node = self.gameObject
    end
    return _util.seek_object(node, name)
end

--------------------------------------------------------------------------------------
-- 通过tag查找父节点游戏对象 <br>
-- 重载1：node(父节点), tag（标签） <br>
-- 重载2：tag（标签）
function base:seek_parent_object_by_tag(...)
    local node, tag, com_type = ...
    if select("#", ...) == 1 then
        tag = ...
        node = self.gameObject
    end
    return _util.seek_parent_object_by_tag(node, tag)
end


--------------------------------------------------------------------------------------
-- 通过路径设置图片
-- @param image image组件
-- @param path 资源路径 相对于Resources/
-- @param set_native_size 是否使用原本大小
-- @param callback 图片资源加载完毕的回调
-- @param asset_lab ab标签名
function base:load_image(image, path, set_native_size, callback, asset_lab, no_async)
    _util.uloader.add_ref_map(image.gameObject, path, _util.uloader.IMAGE, asset_lab)
    _util.uloader.load(path, _util.uloader.IMAGE, function (asset)
        if asset then
            if image == nil or image:IsNull() then
                return
            end
            image.sprite = asset
            if set_native_size then
                image:SetNativeSize()
            end
            if type(callback) == "function" then
                callback(asset)
            end
        else 
            U.log.d("Load Image Faild", path)
        end
    end, asset_lab, no_async)
    
end

--------------------------------------------------------------------------------------
-- 通过路径设置rander图片
-- @param rander rander组件
-- @param path 资源路径 相对于Resources/
-- @param set_native_size 是否使用原本大小
-- @param callback 图片资源加载完毕的回调
-- @param asset_lab ab标签名
function base:load_image_rander(rander, path, set_native_size, callback, asset_lab)
    _util.uloader.add_ref_map(rander.gameObject, path, _util.uloader.IMAGE, asset_lab)
    _util.uloader.load(path, _util.uloader.IMAGE, function (asset)
        if asset then
            if rander == nil or rander:IsNull() then
                return
            end
            rander.sprite = asset
            if type(callback) == "function" then
                callback(asset)
            end
        else 
            U.log.d("Load Image Faild", path)
        end
    end, asset_lab)
end

-- 绑定函数
local binders = {
    -- 值改变组件
    {
        components	= {"Toggle", "Slider", "ScrollRect","InputField", "Dropdown"},
        listener	= "onValueChanged",
        suffix		= "value_changed",
    },

    -- 输入框
    {
        components  = {"InputField",},
        listener    = "onEndEdit",
        suffix		= "end_edit", 
    },

    -- 按钮
    {
        components  = {"Button",},
        listener    = "onClick",
        suffix		= "click", 
    },

    -- 拖拽事件
    {
        components  = {"Drag",},
        listener    = "onDragBegin",
        suffix		= "begin", 
    },
    {
        components  = {"Drag",},
        listener    = "onDrag",
        suffix		= "drag", 
    },
    {
        components  = {"Drag",},
        listener    = "onDragEnd",
        suffix		= "end", 
    },

    -- 点击事件
    {
        components  = {"Click",},
        listener    = "onClickDown",
        suffix		= "down", 
    },
    {
        components  = {"Click",},
        listener    = "onClickUp",
        suffix		= "up", 
    },
}

for _, binder in ipairs(binders) do 
    for _, com_name in ipairs(binder.components) do 
        local fun_name = string.format("bind_%s_%s", com_name, binder.suffix)
        fun_name = string.lower(fun_name)
        
        base[fun_name] = function (self, ...)
            local node, name, fun, sound = ...
            -- if select("#", ...) == 2 then
            if type(node) ~= type(self.gameObject) then
                name, fun, sound = ...
                node = self.gameObject
            end
            local component = _util.seek_component(node, name, com_name)
            if component then
                component[binder.listener]:AddListener(function (...)
                    fun(...)
                    if _util.common_sound_func then
                        _util.common_sound_func(sound, node, name, com_name)
                    end
                end)
            else 
                U.log.w(2, string.format("can't bind component %s[%s]", tostring(name), tostring(com_name)))
            end
            return component
        end
    end	
end

--------------------------------------------------------------------------------------
-- 特殊的binder
local _type_media_player = typeof(CS.Flz.Media.MediaPlayer)
local _type_animator_behaviour = typeof(CS.Flz.UI.AniBehaviour)
base["bind_media_event"] = function (self, name, fun)
    local component = _util.seek_component(self.gameObject, name, _type_media_player)
    if component then
        component:mEvent("+", fun)
    else
        U.log.w("No media player find")
    end
    return component
end

base["bind_animator_event"] = function (self, name, fun)
    local component = _util.seek_component(self.gameObject, name, _type_animator_behaviour)
    if component then
        component.eventFunc = fun
    else
        U.log.w("No animator find")
    end
    return component
end

return {
    base = base,
    init = init,
}