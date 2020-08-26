--------------------------------------------------------------------------------------
-- author liuyang
-- date 2018-01-24
-- desc UI管理
--------------------------------------------------------------------------------------
local impl = {}
local _env = nil
local uloader = nil
local _util = {}

local base = require "fwk.ui.base"
local interim = require "fwk.ui.interim"
local net_mask = require "fwk.ui.net_mask"

local _ui_id = 0
local canvas_list = {}
local ui_list = {}
local ui_name_list = {}
local ui_tag_list = {}
local resident_ui_list = {}
local base_stack = {}

impl.CS = {}

impl.CS.LeanTween = CS.LeanTween
impl.CS.LeanTweenType = CS.LeanTweenType
impl.CS.Vector2 = CS.UnityEngine.Vector2
impl.CS.Vector3 = CS.UnityEngine.Vector3
impl.CS.RectTransformUtility = CS.UnityEngine.RectTransformUtility
impl.CS.Camera = CS.UnityEngine.Camera
impl.CS.Canvas = CS.UnityEngine.Canvas
impl.CS.platform = CS.UnityEngine.Application.platform
impl.CS.dataPath = CS.UnityEngine.Application.dataPath
impl.CS.RuntimePlatform = CS.UnityEngine.RuntimePlatform
impl.CS.Shader = CS.UnityEngine.Shader
impl.CS.Application = CS.UnityEngine.Application
impl.CS.ContentSizeFitter = CS.UnityEngine.UI.ContentSizeFitter
impl.CS.Random = CS.UnityEngine.Random
impl.CS.LayoutRebuilder = CS.UnityEngine.UI.LayoutRebuilder
impl.CS.Mathf = CS.UnityEngine.Mathf
impl.CS.LayerMask = CS.UnityEngine.LayerMask
impl.CS.Launcher_param = CS.Launcher_param
impl.CS.ScriptableObject = CS.UnityEngine.ScriptableObject
impl.CS.Handheld = CS.UnityEngine.Handheld
impl.CS.Physics2D = CS.UnityEngine.Physics2D
impl.CS.GUIUtility = CS.UnityEngine.GUIUtility
impl.CS.Input = CS.UnityEngine.Input

--------------------辅助函数-----------------------------------
-- @local
local function get_ui_id()
    _ui_id = _ui_id + 1
    return tostring(_ui_id)
end


--------------------------------------------------------------------------------------
-- 通过tag查找父节点游戏对象
-- @param root 查找起点
-- @param name 对象名字
-- @return gameObject 游戏对象
-- @local
function _util.all_parent_is_acvive(root)
    if not root.gameObject.activeSelf then
        return false
    end

    local parent = root.transform.parent
    if parent then
        if not parent.gameObject.activeSelf then
            return false
        else
            return _util.all_parent_is_acvive(parent.gameObject)
        end
    end
    return true
end
impl.all_parent_is_acvive = _util.all_parent_is_acvive

--------------------------------------------------------------------------------------
-- 通过tag查找父节点游戏对象
-- @param root 查找起点
-- @param name 对象名字
-- @return gameObject 游戏对象
-- @local
function _util.seek_parent_object_by_tag(root, tag)
    if root.tag == tag then
        return root
    end

    local parent = root.transform.parent
    if parent  then
        if parent.tag == tag then
            return parent.gameObject
        else
            return _util.seek_parent_object_by_tag(parent.gameObject, tag)
        end
    end
end
impl.seek_parent_object_by_tag = _util.seek_parent_object_by_tag

--------------------------------------------------------------------------------------
-- 查找父节点游戏对象
-- @param root 查找起点
-- @param name 对象名字
-- @return gameObject 游戏对象
-- @local
function _util.seek_parent_object(root, name)
    if root.name == name then
        return root
    end

    local parent = root.transform.parent
    if parent  then
        if parent.name == name then
            return parent.gameObject
        else
            return _util.seek_parent_object(parent.gameObject, name)
        end
    end
end
impl.seek_parent_object = _util.seek_parent_object

--------------------------------------------------------------------------------------
-- 查找游戏对象
-- @param root 查找起点
-- @param name 对象名字
-- @return gameObject 游戏对象
-- @local
function _util.seek_object(root, name)
    -- 如果为直接子节点
    local obj = root.transform:Find(name)

    if obj then  return obj.gameObject end

    for i = 0, root.transform.childCount - 1 do 
        local child_transform = root.transform:GetChild(i)
        obj = _util.seek_object(child_transform.gameObject, name)
        if obj then return obj.gameObject end
    end
end
impl.seek_object = _util.seek_object
--------------------------------------------------------------------------------------
-- 查找组件
-- @param root 查找起点
-- @param name 对象名字
-- @param com_type 组件类型
-- @return Component 游戏组件
-- @local
function _util.seek_component(root, name, com_type)
    -- Find from self
    if root.name == name or name == nil or root.name == name .. "(Clone)" then
        local com = root:GetComponent(com_type)
        if com then
            return com
        end
    end

    -- find from direct child
    local obj = root.transform:Find(name)
    if obj and obj:GetComponent(com_type) then
        return obj:GetComponent(com_type)
    end
    -- find from indirect child
    for i = 0, root.transform.childCount - 1 do 
        local child = root.transform:GetChild(i)

        local com = _util.seek_component(child, name, com_type)
        if com then return com end
    end
end
impl.seek_component = _util.seek_component

local component_type_map = {
    Canvas = CS.UnityEngine.Canvas,
    GraphicRaycaster = CS.UnityEngine.UI.GraphicRaycaster,
    LineRenderer = CS.UnityEngine.LineRenderer,
    AudioSource = CS.UnityEngine.AudioSource,
    SpriteRenderer = CS.UnityEngine.SpriteRenderer,
}


--------------------------------------------------------------------------------------
--- 添加组件
-- @function UI.load_sound
-- @param ob 添加对象
-- @param name 组件名 
function impl.add_component(ob, name, ...)
    return _util.add_component(ob, name, ...)
end

function _util.add_component(ob, name, ...)
    if component_type_map[name] then
        return ob.gameObject:AddComponent(typeof(component_type_map[name]))
    else
        U.log.w("not find type：" .. tostring(name))
    end
end

--------------------------------------------------------------------------------------
-- 异步加载预制
-- @local
local function load_prefab_sync(name, func)
    uloader.load(name, uloader.PREFAB, func)
end
_util.load_prefab_sync = load_prefab_sync


--------------------------------------------------------------------------------------
--- 加载图片资源
-- @function UI.load_image
-- @param name 资源路径
-- @param func 完成回调 
function impl.load_image(name, func)
    uloader.load(name, uloader.IMAGE, func)
end

--------------------------------------------------------------------------------------
--- 加载音频资源
-- @function UI.load_sound
-- @param name 资源路径
-- @param func 完成回调 
function impl.load_sound(name, func)
    uloader.load(name, uloader.SOUND, func)
end

function impl.set_common_sound_func(func)
    _util.common_sound_func = func
end
--------------------------------------------------------------------------------------
-- 异步创建游戏对象
-- @local
function _util.inflate_sync(name, parent, func, ... )
    load_prefab_sync(name, function(prefab)
        if prefab then
            local destroy_flag = false
            local obj = nil
            if parent then
                -- 如果加载过程中父节点被销毁了则加载到场景上然后再销毁，保证走完完整的生命周期
                -- 现在暂时使用保护模式来处理父节点不存在的情况
                local status, err = pcall(function()
                    obj =  CS.UnityEngine.GameObject.Instantiate(prefab, parent.transform)
                end)
                -- if not parent:IsNull() and parent.transform and not parent.transform:IsNull() then
                --     obj =  CS.UnityEngine.GameObject.Instantiate(prefab, parent.transform)
                -- end

                if not obj then
                    obj = CS.UnityEngine.GameObject.Instantiate(prefab)
                    destroy_flag = true
                end
            else
                obj = CS.UnityEngine.GameObject.Instantiate(prefab)
            end
            func(obj, destroy_flag)
        end
    end)
end

-- 处理baseUI
-- @local
local function _base_ui_load_handle(ui_type, ui_id, load_param, on_load_param)
    -- 处理baseUI
    if ui_type == "base" then
        local root = canvas_list[ui_type .. "_canvas"]
        for i = 0, root.transform.childCount - 1 do 
            local child_transform = root.transform:GetChild(i)
            local beh = child_transform:GetComponent("LuaUIBehaveour")
            local child_ui_id = beh.luaCtx.luaobj:get_ui_id()
            if child_ui_id ~= ui_id then
                if ui_list[child_ui_id] and ui_list[child_ui_id].load_param.resident then
                    impl.hide(child_ui_id)
                else
                    impl.destroy(child_ui_id)
                end
            end
        end

        -- 检查导航栏
        local root = canvas_list["actionbar_canvas"]
        for i = 0, root.transform.childCount - 1 do 
            local child_transform = root.transform:GetChild(i)
            local beh = child_transform:GetComponent("LuaUIBehaveour")
            local child_ui_id = beh.luaCtx.luaobj:get_ui_id()
            if load_param.actionbar then
                impl.show(child_ui_id, load_param.actionbar)
            else
                impl.hide(child_ui_id)
            end
        end

        for i = #base_stack, 1, -1 do
            if base_stack[i].load_param.name == load_param.name then
                table.remove(base_stack, i)
            end
        end

        for i = #base_stack, 1, -1 do
            if base_stack[i].load_param.temp_stack then
                table.remove(base_stack, i)
            end
        end

        table.insert(base_stack, {load_param = load_param, on_load_param = on_load_param})
    end
end

-- 加载完成
-- @local
local function load_finish(luaobj, obj, ui_id, load_param, on_load_param, destroy_flag)
    if load_param.interim then
        interim:hide({enter = "2"})
    end

    local ui_type = load_param.ui_type or "base"
    local tag = load_param.tag
    local prefab = load_param.prefab or load_param.name
    local parent = load_param.parent or canvas_list[ui_type .. "_canvas"]
    local is_full = not not load_param.is_full

    local com = CS.SYFwk.Core.Lua.AddComponent(obj, "SYFwk.Core.LuaUIBehaveour")
    local ctx = {
        name = load_param.name,
        obj  = obj,
        com  = com,
        ui_id = ui_id,
        luaobj = luaobj,
    }
    com.luaCtx = ctx
    -- print(tostring(obj), tostring(com))
    luaobj.gameObject = obj
    -- U.log.dump(com.luaCtx)
    ui_list[luaobj._base_data._ui_id].load_state = "finish"

    if not load_param.silent then
        _base_ui_load_handle(ui_type, ui_id, load_param, on_load_param)
    end

    if luaobj and luaobj.on_load then
        luaobj:on_load(on_load_param)
    end

    
    -- if ui_type == "base" or ui_type == "actionbar" then
    --     local rect = luaobj:seek_component(luaobj.gameObject, luaobj.gameObject.name, "RectTransform")
    --     rect:SetSizeWithCurrentAnchors(CS.UnityEngine.RectTransform.Axis.Horizontal, CS.Flz.UI.AutoFixScreen.ResolutionWidth);
    --     rect:SetSizeWithCurrentAnchors(CS.UnityEngine.RectTransform.Axis.Vertical, CS.Flz.UI.AutoFixScreen.ResolutionHeight);
    --     rect.localPosition = {x = 0, y = CS.Flz.UI.AutoFixScreen.ResolutionOffset, z = 0}
    -- end
    -- -- 检查背景图
    -- if ui_type == "base" then
    --     local bg = luaobj:seek_component(luaobj.gameObject, "bg", "Image")
    --     if not bg then
    --         error("no find bg")
    --     end

    --     local scale = CS.Flz.UI.AutoFixScreen.ResolutionScale   
    --     if(is_full and scale > 1) then
    --         scale = scale + 0.08
    --     end
    --     bg.transform.localScale = {x = scale, y = scale, z = scale}
    -- end

    if not load_param.no_auto_show then
        impl.show(ui_id, load_param)
    end

    if load_param.silent then
        obj.transform:SetAsFirstSibling()
        impl.hide(ui_id)
    end

    if destroy_flag then
        impl.destroy(ui_id)
    end

    if load_param.finish_callback then
        load_param.finish_callback(ui_id)
    end
end

-- 创建ui对象
-- @local
local function _creat_ui(ui_id, luaobj, load_param, on_load_param)
    local ui_type = load_param.ui_type or "item"
    local tag = load_param.tag
    local prefab = load_param.prefab or load_param.name
    local parent = load_param.parent or canvas_list[ui_type .. "_canvas"]
    if ui_type ~= "scene" then
        assert(parent, "not find parent")
    end

    local obj = nil
    luaobj._base_data = {}
    luaobj._base_data._ui_id = ui_id
    luaobj._base_data.load_param = load_param

    ui_list[luaobj._base_data._ui_id] = {
        luaobj=luaobj, 
        name = load_param.name,
        tag = tag, 
        ui_type = ui_type,
        load_param = load_param,
        ui_id = ui_id,
        load_state = "loading"
    }
    
    ui_name_list[load_param.name] = ui_name_list[load_param.name] or {}
    ui_name_list[load_param.name][luaobj._base_data._ui_id] = ui_list[luaobj._base_data._ui_id]

    if tag then
        local tag_list = string.split(tag, "#")
        for k, v in pairs(tag_list) do
            ui_tag_list[v] = ui_tag_list[v] or {}
            ui_tag_list[v][luaobj._base_data._ui_id] = ui_list[luaobj._base_data._ui_id]
        end
    end

    if load_param.ui_type == "base" and load_param.resident then
        resident_ui_list[load_param.name] = ui_list[luaobj._base_data._ui_id]
    end
    
    _util.inflate_sync(prefab, parent, function(obj, destroy_flag)
        load_finish(luaobj, obj, ui_id, load_param, on_load_param, destroy_flag)
    end)

    return ui_id
end

--------------------------------------------------------------------------------------
--- 创建UI
-- @function UI.load
-- @param param load参数
-- <br>&emsp; name:文件名 必填
-- <br>&emsp; prefab:预制
-- <br>&emsp; parent:父节点
-- <br>&emsp; tag:标签
-- <br>&emsp; is_sync:异步加载
-- <br>&emsp; no_auto_show:取消自动调用show
-- <br>&emsp; interim:启用过渡
-- <br>&emsp; finish_callback:加载完成回调 function(uiid)
-- <br>&emsp; start_finish_callback:start完成回调 function(uiid)

-- @param on_load_param 用户数据
function impl.load(param, on_load_param)
    assert(param)
    assert(type(param.name) == "string")

    -- 判断是否已存在 base 常驻UI
    local base_resident_ui = resident_ui_list[param.name]
    local name = "game.ui." .. param.name
    local luaobj = nil
    if base_resident_ui then
        U.log.w("base_resident")
        luaobj = base_resident_ui.luaobj
    else
        U.log.w("base_resident_load")
        luaobj = U.loader.load(name, _env)
        if param.superclass then
            local superclass_name = "game.ui." .. param.superclass
            local luaobj_superclass = U.loader.load(superclass_name, _env)
            luaobj_superclass.__index = luaobj_superclass
            setmetatable(luaobj, luaobj_superclass)
        end
    end

    local load_param = table.copy(luaobj._load_param) or {}
    local valid_key = {
        name = true,
        prefab = true,
        parent = true,
        tag = true,
        resident = true,
        no_auto_show = true,
        interim = true,
        silent = true,
        start_finish_callback = true,
        finish_callback = true,
        superclass = true,
    }

    for k, v in pairs(param) do
        if valid_key[k] then
            load_param[k] = v
        end
    end

    local ui_type = load_param.ui_type or "base"

    local ui_id = nil
    if load_param.intenrim and ui_type == "base" then
        if base_residet_ui then
            ui_id = base_resident_ui.ui_id
        else
            ui_id = get_ui_id()
        end

        interim:show({
            func = function()
                -- 检查是否为常驻ui
                if base_resident_ui then
                    if base_resident_ui.luaobj.gameObject then
                        base_resident_ui.luaobj.gameObject.transform:SetAsLastSibling()
                    end
                    impl.show(ui_id, param)
                    interim:hide({enter = "1"})
                end

                if not base_resident_ui then
                    -- 创建ui对象
                    _creat_ui(ui_id, luaobj, load_param, on_load_param)
                else
                    -- 处理baseUI
                    _base_ui_load_handle(ui_type, ui_id, load_param, on_load_param)
                    if load_param.finish_callback then
                        load_param.finish_callback(ui_id)
                    end
                end
            end
        })
    
    else
        load_param.interim = false
        -- 检查是否为常驻ui
        if base_resident_ui then
            if base_resident_ui.luaobj.gameObject then
                base_resident_ui.luaobj.gameObject.transform:SetAsLastSibling()
            end
            ui_id = base_resident_ui.ui_id
            impl.show(ui_id, param)
        end

        if not ui_id then
            -- 创建ui对象
            ui_id = get_ui_id()
            _creat_ui(ui_id, luaobj, load_param, on_load_param)
        else
            -- 处理baseUI
            _base_ui_load_handle(ui_type, ui_id, load_param, on_load_param)
            if load_param.finish_callback then
                load_param.finish_callback(ui_id)
            end
        end
    end

    

    
    return ui_id
    -- return luaobj
end


--------------------------------------------------------------------------------------
--- 显示UI
-- @function UI.show
-- @param ui_id UIID
-- @param param 用户数据
function impl.show(ui_id, param)
    if not ui_list[ui_id] then
        return
    end

    if not ui_list[ui_id].on_start_finish then
        ui_list[ui_id].start_finish_func_list = ui_list[ui_id].start_finish_func_list or {}
        table.insert(ui_list[ui_id].start_finish_func_list, function()
            impl.show(ui_id, param)
        end)
        return
    end

    local luaobj = ui_list[ui_id].luaobj
    if luaobj then
        -- 有些操作需要Active为true才能生效所以先设置再调接口
        luaobj.gameObject:SetActive(true)
        if luaobj.on_show then
            luaobj:on_show(param)
        end
    end
end


--------------------------------------------------------------------------------------
--- 隐藏UI
-- @function UI.hide
-- @param ui_id UIID
-- @param param 用户数据
function impl.hide(ui_id, param)
    if not ui_list[ui_id] then
        return
    end

    if not ui_list[ui_id].on_start_finish then
        ui_list[ui_id].start_finish_func_list = ui_list[ui_id].start_finish_func_list or {}
        table.insert(ui_list[ui_id].start_finish_func_list, function()
            impl.hide(ui_id, param)
        end)
        return
    end

    local ret = {}
    local luaobj = ui_list[ui_id].luaobj
    if luaobj then
        if luaobj.on_hide then
            luaobj:on_hide()
        end
        luaobj.gameObject:SetActive(false)
    end
end


--------------------------------------------------------------------------------------
--- 调用目标函数
-- @function UI.call
-- @param ui_id UIID
-- @param command 命令（函数）
function impl.call(ui_id, command, param)
    if not ui_list[ui_id] then
        U.log.w("not find ui_id:" .. ui_id .. " command:" .. tostring(command))
        return
    end

    local luaobj = ui_list[ui_id].luaobj
    if luaobj and luaobj[command] and type(luaobj[command]) == "function" then
        return true, luaobj[command](luaobj, param)
    else
        if luaobj then
            U.log.w(tostring(luaobj._base_data.load_param.name) .. " not find luaobj or luaobj[" .. tostring(command) .. "]")
        else
            U.log.w("not find luaobj")
        end
    end
end

--------------------------------------------------------------------------------------
--- 发送命令
-- @function UI.send_command
-- @param ui_id UIID
-- @param param 用户数据
function impl.send_command(ui_id, param)
    if not ui_list[ui_id] then
        U.log.w("not find ui_id:" .. ui_id .. " command:" .. tostring(param.command))
        return
    end

    if not ui_list[ui_id].on_start_finish then
        ui_list[ui_id].start_finish_func_list = ui_list[ui_id].start_finish_func_list or {}
        table.insert(ui_list[ui_id].start_finish_func_list, function()
            impl.send_command(ui_id, param)
        end)
        return
    end

    local luaobj = ui_list[ui_id].luaobj
    if luaobj and luaobj.on_command then
        luaobj:on_command(param)
    else
        U.log.w("not find ui_id:" .. ui_id)
    end
end

--------------------------------------------------------------------------------------
--- 通过name发送命令
-- @function UI.send_command_by_name
-- @param name  加载时的文件名
-- @param param 用户数据
function impl.send_command_by_name(name, param)
    for k, v in pairs(ui_name_list[name] or {}) do
        impl.send_command(k, param)
    end
end

--------------------------------------------------------------------------------------
--- 通过tag发送命令
-- @function UI.send_command_by_tag
-- @param tag   加载时的tag
-- @param param 用户数据
function impl.send_command_by_tag(tag, param)
    for k, v in pairs(ui_tag_list[tag] or {}) do
        impl.send_command(k, param)
    end
end



--------------------------------------------------------------------------------------
--- 销毁UI
-- @function UI.destroy
-- @param ui_id UIID
-- @param param 用户数据
function impl.destroy(ui_id, param)
    param = param or {}
    if not ui_list[ui_id] then
        return
    end

    if not ui_list[ui_id].on_start_finish then
        ui_list[ui_id].start_finish_func_list = ui_list[ui_id].start_finish_func_list or {}
        table.insert(ui_list[ui_id].start_finish_func_list, function()
            impl.destroy(ui_id, param)
        end)
        return
    end

    
    impl.hide(ui_id, param)

    local luaobj = ui_list[ui_id].luaobj
    local name = ui_list[ui_id].name
    local tag = ui_list[ui_id].tag
    if luaobj then
        
        if luaobj.on_destroy then
            luaobj:on_destroy()
        end

        if not param.destroy_c then --如是由于C# destroy回掉 过来的，不再重复销毁
            if param.is_immediate then
                CS.UnityEngine.GameObject.DestroyImmediate(luaobj.gameObject)
            else
                CS.UnityEngine.GameObject.Destroy(luaobj.gameObject)
            end
        end

        -- 清理ui索引表
        ui_list[ui_id] = nil

        -- 清理name索引表
        if ui_name_list[name] then
            ui_name_list[name][ui_id] = nil
            if table.length(ui_name_list[name]) == 0 then
                ui_name_list[name] = nil
            end
        end

        -- 清理tag索引表
        if tag then
            local tag_list = string.split(tag, "#")
            for k, v in pairs(tag_list) do
                if ui_tag_list[v] then
                    ui_tag_list[v][ui_id] = nil
                    if table.length(ui_tag_list[v]) == 0 then
                        ui_tag_list[v] = nil
                    end
                end
            end
        end

        -- 清理常驻表
        if resident_ui_list[name] and resident_ui_list[name].ui_id == ui_id then
            resident_ui_list[name] = nil
        end
    end
end


--------------------------------------------------------------------------------------
--- 通过name销毁UI
-- @function UI.destroy_by_name
-- @param name 加载时的文件名
-- @param param 用户数据
function impl.destroy_by_name(name, param)
    for k, v in pairs(ui_name_list[name] or {}) do
        impl.destroy(k, param)
    end
end

--------------------------------------------------------------------------------------
--- 通过tag销毁UI
-- @function UI.destroy_by_tag
-- @param tag   加载时的tag
-- @param param 用户数据
function impl.destroy_by_tag(tag, param)
    for k, v in pairs(ui_tag_list[tag] or {}) do
        impl.destroy(k, param)
    end
end

--------------------------------------------------------------------------------------
--- 销毁所有dialog类型UI
-- @function UI.destroy_all_dialog
function impl.destroy_all_dialog(param)
    param = param or {}
    local root = canvas_list["dialog_canvas"]
    for i = 0, root.transform.childCount - 1 do 
        local child_transform = root.transform:GetChild(i)
        local beh = child_transform:GetComponent("LuaUIBehaveour")
        local ui_id = beh.luaCtx.luaobj:get_ui_id()
        impl.destroy(ui_id, param)
    end
end

--------------------------------------------------------------------------------------
--- 导航条点击回调
-- @function UI.on_navigate
-- @param ui_id UIID
-- @local
function impl.on_navigate(ui_id)
    if not ui_list[ui_id] then
        return
    end

    if not ui_list[ui_id].on_start_finish then
        ui_list[ui_id].start_finish_func_list = ui_list[ui_id].start_finish_func_list or {}
        table.insert(ui_list[ui_id].start_finish_func_list, function()
            impl.on_navigate(ui_id)
        end)
        return
    end

    local luaobj = ui_list[ui_id].luaobj
    if luaobj then
        if luaobj.on_navigate then
            luaobj:on_navigate()
        end
    end
end

--------------------------------------------------------------------------------------
--- 返回到上一级base界面
-- @function UI.go_last_base
-- @param load_param 参数
-- @param on_load_param 用户数据
function impl.go_last_base(param)
    param = param or {}
    if #base_stack > 1 then
        base_stack[#base_stack] = nil
        impl.load(param.load_param or base_stack[#base_stack].load_param, param.on_load_param or base_stack[#base_stack].on_load_param)
    end
end

--------------------------------------------------------------------------------------
--- 返回到指定文件界面
-- @function UI.back_base_for_name
-- @param name 文件名
-- @param load_param 参数
-- @param on_load_param 用户数据
function impl.back_base_for_name(param)
    param = param or {}
    local len = #base_stack
    local index = nil
    for i = len, 1, -1 do
        if base_stack[i].load_param.name == param.name then
            index = i
            break
        end
    end

    if index then
        local load_param = param.load_param or base_stack[index].load_param
        local on_load_param = param.on_load_param or base_stack[index].on_load_param
        -- impl.load(param.load_param or base_stack[index].load_param, param.on_load_param or base_stack[index].on_load_param)
        for i = index + 1, len do
            base_stack[i] = nil
        end
        impl.load(load_param, on_load_param)
    end
end

--------------------------------------------------------------------------------------
--- 根据名字移除操作路径
-- @function UI.remove_base_stack_by_name
-- @param name 文件名
function impl.remove_base_stack_by_name(name)
    for i = #base_stack, 1, -1 do
        if base_stack[i].load_param.name == name then
            table.remove(base_stack, i)
        end
    end
end

--------------------------------------------------------------------------------------
--- 新增获取base界面操作信息
-- @function UI.get_base_stack
function impl.get_base_stack(param)
    param = param or {}
    if param.mode == "top" then
        return table.copy(base_stack[#base_stack])
    end
    return table.copy(base_stack)
end

--------------------------------------------------------------------------------------
--- 检查UI是否可用
-- @function UI.check_enable
-- @param uiid uiid
function impl.check_enable(uiid)
    local ui = ui_list[uiid]
    if ui and ui.luaobj and ui.on_start_finish then
        return true
    end
    return false
end


--------------------------------------------------------------------------------------
--- 获取base类型列表
-- @function UI.get_base_ui_id_list
function impl.get_base_ui_id_list()
    local list = {}
    local root = canvas_list["base_canvas"]
    for i = 0, root.transform.childCount - 1 do 
        local child_transform = root.transform:GetChild(i)
        local beh = child_transform:GetComponent("LuaUIBehaveour")
        local child_ui_id = beh.luaCtx.luaobj:get_ui_id()
        table.insert(list, child_ui_id)
    end
    return list
end

local tips_param = nil
function impl.set_tips(param)
    param = param or {}
    tips_param = param
end


function impl.show_tips(str)
    if tips_param then
        impl.load(tips_param, {text = str or "???"})
    end
end

function impl.add_by_path(path, parent, func, instantiateInWorldSpace)
    _util.load_prefab_sync(path, function(prefab)
        assert(parent, "not find parent")
        local ob = CS.UnityEngine.GameObject.Instantiate(prefab, parent, not not instantiateInWorldSpace)
        if func then
            func(ob)
        end
    end)
end

--------------------------------------------------------------------------------------
-- 移除无lua脚本的游戏对象
-- @param ob 游戏对象
function impl.remove(ob, ...)
    CS.UnityEngine.GameObject.Destroy(ob, ...)
end

function impl.set_network_mask_panel(content)
    net_mask:set_network_mask_panel(content)
end

function impl.net_mask_on_process_data(session)
    net_mask:on_process_data(session)
end

function impl.net_mask_on_send_request(session)
    net_mask:on_send_request(session)
end

function impl.net_mask_reset(session)
    net_mask:reset(session)
end

function impl.get_ui_list()
    return ui_list
end

function impl.get_canvas(name)
    return canvas_list[name]
end

--------------------------------------------------------------------------------------
--- 设置timeScale
-- @function UI.settime_scale
-- @param time_scale 时间系数
function impl.set_time_scale(time_scale)
    CS.UnityEngine.Time.timeScale = time_scale
end

--------------------------------------------------------------------------------------
--- 卸载所有未引用资源
-- @function UI.UnloadUnusedAssets
-- @local
function impl.UnloadUnusedAssets()
    local list = {}
    for _, v in pairs(ui_list) do
        table.insert(list, v.load_param.prefab)
    end

    uloader.unload(list)
    CS.UnityEngine.Resources.UnloadUnusedAssets()
end

--------------------------------------------------------------------------------------
-- 响应
local function on_start(ctx)
    -- U.log.i("on_start")
    -- U.log.dump(ctx)
    local ui_id = ctx.ui_id
    if not ui_list[ui_id] then
        return
    end

    local luaobj = ui_list[ui_id].luaobj
    if luaobj and luaobj.on_start then
        luaobj:on_start()
    end
    ui_list[ui_id].on_start_finish = true

    if ui_list[ui_id].load_param and ui_list[ui_id].load_param.start_finish_callback then
        ui_list[ui_id].load_param.start_finish_callback(ui_id, luaobj)
    end

    for k, func in pairs(ui_list[ui_id].start_finish_func_list or {}) do
        func()
    end
    -- ui_list[ui_id].start_finish_func_list = nil
end

local function on_update(...)
    -- U.log.i("on_update")
    for k, v in pairs(ui_list) do
        if v and v.luaobj and v.luaobj.on_update and v.on_start_finish and v.luaobj.gameObject.activeSelf then
            if impl.all_parent_is_acvive(v.luaobj.gameObject) then
                v.luaobj:on_update(...)
            end
        end
    end
    interim:update(...)
    net_mask:update(...)
end

local function on_destroy(ctx)
    -- U.log.i("on_destroy")
    local ui_id = ctx.ui_id
    U.schedule.remove_task_by_uiid(ui_id)
    if not ui_list[ui_id] then
        return
    end
    
    local luaobj = ui_list[ui_id].luaobj
    if luaobj then
        impl.destroy(ui_id, {destroy_c = true})
    end
   
end

local event = function(en, ...) -- en => event name
    if en == "start" then
        on_start(...)
    end

    if en == "update" then
        on_update(...)
    end

    if en == "destroy" then
        on_destroy(...)
    end
    
end


base.init(_util)
interim:init()
net_mask:init()
local function export(def)
    setmetatable(def, base.base)
end

return 
{
    impl = impl,
    init = function (env)
        uloader = require("fwk.ui.loader").init()
        _util.uloader = uloader
        _env = env
        canvas_list.base_canvas = CS.UnityEngine.GameObject.Find("base_canvas")
        canvas_list.actionbar_canvas = CS.UnityEngine.GameObject.Find("actionbar_canvas")
        canvas_list.dialog_canvas = CS.UnityEngine.GameObject.Find("dialog_canvas")
        canvas_list.tip_canvas = CS.UnityEngine.GameObject.Find("tip_canvas")
        canvas_list.world_canvas = CS.UnityEngine.GameObject.Find("world_canvas")
        canvas_list.network_canvas = CS.UnityEngine.GameObject.Find("network_canvas")
        
        for k, v in pairs(canvas_list) do
            local canvasScaler = v:GetComponent("CanvasScaler")
            canvasScaler.screenMatchMode = 2
        end
        
        -- 隐藏工作画布
        local workCanvas = CS.UnityEngine.GameObject.Find("my_base_canvas")
        if workCanvas then
            workCanvas:SetActive(false)
        end
        CS.UnityEngine.GameObject.Find("MainBehaviour"):GetComponent("MainBehaviour").OnLowMemory_func = impl.UnloadUnusedAssets
    end, 
    export = export,
    event = event,
    res_destroy_event = function(...)
        _util.uloader.res_destroy_event(...)
    end
}