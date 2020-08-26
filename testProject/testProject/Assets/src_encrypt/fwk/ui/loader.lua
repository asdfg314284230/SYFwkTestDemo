local loader_dev = {}
local loader_run = {}
local _util = {}
local common = {
    PREFAB = 1,
    IMAGE  = 2,
    SOUND  = 3,
}

local _type_prefab = typeof(CS.UnityEngine.GameObject)
local _type_sprite = typeof(CS.UnityEngine.Sprite)
local _type_sound = typeof(CS.UnityEngine.AudioClip)

local ab_root = nil
local sapath = CS.UnityEngine.Application.streamingAssetsPath .. "/"
local pepath = CS.UnityEngine.Application.streamingAssetsPath .. "/ver_data/ab/"

local plat = CS.SYFwk.Core.Core.GetPlatformId()
local platform_list = {
    [8] = "ios",
    [11] = "android",
}

if plat == 1 then
    ab_root = string.format("%sab/", sapath) 
elseif plat == 2 then
    ab_root = string.format("%sab/", sapath) 
elseif plat == 8 then
    ab_root = string.format("%sab/", sapath) 
elseif plat == 11 then  -- Android
    ab_root = string.format("%sab/", sapath) 
elseif plat == 7 then
    -- CS.UnityEngine.Application.dataPath, "../../data/ab/
    ab_root = string.format("%s/../../data/ab/%s/ab/", CS.UnityEngine.Application.dataPath, "win") 
elseif plat == 0 then
    ab_root = string.format("%s/../../data/ab/%s/ab/", CS.UnityEngine.Application.dataPath, "osx") 
end

_util.ab_info = {}
_util._pending = {}
_util.ref_map = {}
_util.res_ref_map = {}

function _util.add_ref_map_after(obj, path, ab_type, asset_lab)
    if ab_type == common.IMAGE then
        asset_lab = asset_lab or "sprite_load"
        asset_lab = asset_lab == "load" and "sprite_load" or asset_lab
        local asset_name = asset_lab .. ".ab"
        if not _util.ref_map[tostring(obj.gameObject:GetInstanceID())] then
            _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
        else
            _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
            _util.res_ref_map[asset_name] = _util.res_ref_map[asset_name] - 1
        end
        local com =  obj:GetComponent("DestroyEvent")
        if not com then
            com = CS.SYFwk.Core.Lua.AddComponent(obj, "SYFwk.Core.DestroyEvent")
        end
    elseif ab_type == common.PREFAB then
        local asset_name = string.gsub(path, "/", ".") .. ".ab"
        asset_name = string.lower(asset_name)  

        if not _util.ref_map[tostring(obj.gameObject:GetInstanceID())] then
            _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
        else
            _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
            _util.res_ref_map[asset_name] = _util.res_ref_map[asset_name] - 1
        end
        local com =  obj:GetComponent("DestroyEvent")
        if not com then
            com = CS.SYFwk.Core.Lua.AddComponent(obj, "SYFwk.Core.DestroyEvent")
        end
    end
end
common.add_ref_map_after = _util.add_ref_map_after

function _util.add_ref_map(obj, path, ab_type, asset_lab)
    if ab_type == common.IMAGE then
        asset_lab = asset_lab or "sprite_load"
        asset_lab = asset_lab == "load" and "sprite_load" or asset_lab
        local asset_name = asset_lab .. ".ab"
        _util.res_ref_map[asset_name] = (_util.res_ref_map[asset_name] or 0 ) + 1
        if obj then
            if not _util.ref_map[tostring(obj.gameObject:GetInstanceID())] then
                _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
            else
                _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
                _util.res_ref_map[asset_name] = _util.res_ref_map[asset_name] - 1
            end

            local com =  obj:GetComponent("DestroyEvent")
            if not com then
                com = CS.SYFwk.Core.Lua.AddComponent(obj, "SYFwk.Core.DestroyEvent")
            end
        end
    elseif ab_type == common.PREFAB then
        local asset_name = string.gsub(path, "/", ".") .. ".ab"
        asset_name = string.lower(asset_name)                           -- Unity中全是小写？？
        _util.res_ref_map[asset_name] = (_util.res_ref_map[asset_name] or 0 ) + 1
        if obj then
            if not _util.ref_map[tostring(obj.gameObject:GetInstanceID())] then
                _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
            else
                _util.ref_map[tostring(obj.gameObject:GetInstanceID())] = asset_name
                _util.res_ref_map[asset_name] = _util.res_ref_map[asset_name] - 1
            end
            local com =  obj:GetComponent("DestroyEvent")
            if not com then
                com = CS.SYFwk.Core.Lua.AddComponent(obj, "SYFwk.Core.DestroyEvent")
            end
        end
    end
end
common.add_ref_map = _util.add_ref_map

function _util.res_destroy_event(...)
    local mod, id = ...
    local asset_name = _util.ref_map[tostring(id)]
    if _util.res_ref_map[asset_name] then
        _util.res_ref_map[asset_name]= _util.res_ref_map[asset_name] - 1
    end
end
common.res_destroy_event = _util.res_destroy_event

function _util.unload_all_ab(list)
    if _util._manifest == nil and not _util._manifest_loading then
        return
    end
    local ref_list = {}
    local function handel_deps(abname)
        local deps = _util._get_deps(abname)
        for dep, _ in pairs(deps) do 
            local sun_deps = _util._get_deps(dep)
            for k, v in pairs(sun_deps) do
                if not ref_list[k] then
                    handel_deps(k)
                end
            end
            ref_list[dep] = dep
        end
    end

    for k, v in pairs(list) do
        local abname = string.gsub(v, "/", ".") .. ".ab"
        abname = string.lower(abname)                           -- Unity中全是小写？？
        handel_deps(abname)
        ref_list[abname] = abname
    end

    
    local resident_ab = {
        "font.ab",
        "shader.ab",
    }
    local remove_list = {}
    for k, v in pairs(_util.ab_info) do
        if v.ab and (v.ab_type == common.PREFAB or v.ab_type == common.SOUND) and not ref_list[v.name] and not resident_ab[v.name] then
            if not _util.res_ref_map[v.name] or _util.res_ref_map[v.name] <= 0 then
                v.ab:Unload(true)
                table.insert(remove_list, k)
            else
                -- U.log.i("Unload fail by ref:" .. v.name)
            end
        elseif  v.ab and v.ab_type == common.IMAGE and not resident_ab[v.name] then
            if not _util.res_ref_map[v.name] or _util.res_ref_map[v.name] <= 0 then
                v.ab:Unload(true)
                table.insert(remove_list, k)
            else
                -- U.log.i("Unload fail by ref:" .. v.name)
            end
        else
            U.log.i("Unload fail:" .. v.name)
        end
    end
    -- example.example_item
    U.log.i("#remove_list=" .. #remove_list)
    for k, v in pairs(remove_list) do
        U.log.i("remove:" .. v)
        _util.ab_info[v] = nil
    end
end

--------------------------------------------------------------------------------------
-- 为name对应的ab，添加引用计数
function _util._ab_ref(name, ab_type, no_async)
    local info = _util.ab_info[name]
    if info == nil then
        info = {
            name = name,
            ref  = 0,
            state = "waiting",
            cbs = {},
            deps = {},
            ab_type = ab_type,
            no_async = no_async,
        }
        _util.ab_info[name] = info
    end
    info.ref = info.ref + 1

    return info
end

--------------------------------------------------------------------------------------
-- 加载名字对应的ab
function _util.load_ab(name, cb, ab_type, no_async)
    -- 没加载一次，都要引用一次ab
    local info = _util._ab_ref(name, ab_type, no_async)
    if info.state == "loaded" then
        cb(info.name, info.ab)
    else
        table.insert(info.cbs, cb)
        _util._add_task(name)
    end
end

--------------------------------------------------------------------------------------
-- 内部添加一个加载ab的任务
function _util._add_task(name)
    if _util._manifest == nil then
        table.insert(_util._pending, name)
        return _util._load_manifest()
    end

    local info = assert(_util.ab_info[name])
    local deps = _util._get_deps(name)
    local to_load = {}
    for dep, _ in pairs(deps) do 

        local _dep = dep
        if string.split(_dep, "_")[1] == "updata" then
            _dep = string.sub(_dep, 8)
        end

        local dinfo = _util._ab_ref(_dep)
        info.deps[_dep] = dinfo
        if dinfo.state ~= "loaded" then
            table.insert(to_load, _dep)
        end
    end
    if #to_load > 0 then
        for _, dep in ipairs(to_load) do 
            _util._add_task(dep)
        end
    else 
        _util._do_add_task(name)
    end
end

--------------------------------------------------------------------------------------
-- 添加一个ab的真正逻辑，调用这个函数，要保证依赖已经全部加载了
function _util._do_add_task(name)
    local info = assert(_util.ab_info[name])
    if info.state ~= "waiting" then
        U.log.i(name, " state is ", info.state)
        return
    end
    assert(info.state == "waiting", tostring(info.state))
    info.state = "loading"
    U.log.w("!!!")
    _util._do_load_ab(name, function (nname, ab)
        if ab then
            info.ab = ab
            _util._on_task_loaded(nname)
        end
    end, info.no_async)
end

--------------------------------------------------------------------------------------
-- 获取name对应的ab所有依赖的ab名称
function _util._get_deps(name)
    assert(_util._manifest)
    local list = _util._manifest:GetAllDependencies(name)
    local ret = {}
    if list.Length == 0 then
        list = _util._manifest:GetAllDependencies("updata_" .. name)
    end

    for i = 0, list.Length - 1 do 
        local dn = list[i]
        print(dn)
        ret[dn] = dn
    end
    return ret
end

--------------------------------------------------------------------------------------
-- name对应的ab加载完毕后回调
function _util._on_task_loaded(name)
    local info = assert(_util.ab_info[name])
    info.state = "loaded"

    local cbs = info.cbs
    info.cbs = {}
    for _, cb in ipairs(cbs) do 
        cb(name, info.ab)
    end
    -- 检查是否有依赖这个资源的ab
    for dn, info in pairs(_util.ab_info) do 
        if info.state == "waiting" and info.deps[name] then
            local ok = true
            -- 遍历所有依赖的ab，如果依赖全部加载，添加自己到任务列表
            for dn, _ in pairs(info.deps) do 
                local dinfo = _util.ab_info[dn]
                if dinfo.state ~= "loaded" then
                    ok = false
                    break
                end
            end
            if ok then
                _util._do_add_task(dn)
            end
        end
    end
end


--------------------------------------------------------------------------------------
-- 加载AssetBundleManifest
function _util._load_manifest()
    if _util._manifest == nil and not _util._manifest_loading then
        _util._manifest_loading = true
        CS.UnityEngine.AssetBundle.UnloadAllAssetBundles(false)
        _util._do_load_ab("ab", function (name, ab)
            if ab then
                _util._manifest = ab:LoadAsset("AssetBundleManifest", typeof(CS.UnityEngine.AssetBundleManifest))
                local list = _util._manifest:GetAllAssetBundles()
                -- for i = 0, list.Length -1 do 
                --     U.log.w(list[i])
                -- end
                U.log.w("_util._pending length ", #_util._pending)
                -- 检查所有pending的ab
                for _, name in ipairs(_util._pending) do 
                    -- 状态变了，重新加一次任务
                    _util._add_task(name)
                end
            else
                U.log.e("Load ab error", name)
            end
        end)
    end
end

function _util._do_load_ab(name, cb, no_async)
    if string.split(name, "_")[1] == "updata" then
        name = string.sub(name, 8)
    end


    local path = pepath .. name
    local is_updata = false

    U.log.w(path)
    if not CS.System.IO.File.Exists(path) then
        path = pepath .. "updata_" .. name
        is_updata = true
    end


    local load_ab_func = function()
        if no_async then
            local assetBundle = CS.UnityEngine.AssetBundle.LoadFromFile(path)
            if assetBundle then
                local info = _util.ab_info[name]
                if not info then
                    info = {}
                    U.log.w("_util.ab_info no key：" .. name)
                end
                info.is_updata = is_updata
                cb(name, assetBundle)
            end
        else
            local req = CS.UnityEngine.AssetBundle.LoadFromFileAsync(path)
            req:completed("+", function (req)
                -- U.log.w(req.isDone, req.assetBundle, path)
                if req.isDone and req.assetBundle then
                    local info = _util.ab_info[name]
                    if not info then
                        info = {}
                        U.log.w("_util.ab_info no key：" .. name)
                    end
                    info.is_updata = is_updata
                    cb(name, req.assetBundle)
                else
                    cb(name, nil)
                    local path = ab_root .. name
                    local req = CS.UnityEngine.AssetBundle.LoadFromFileAsync(path)
                    req:completed("+", function (req)
                        U.log.w(req.isDone, req.assetBundle, path)
                        if req.isDone and req.assetBundle then
                            cb(name, req.assetBundle)
                        else
                            cb(name, nil)
                            local path = ab_root .. name
                        end
                    end)
                end
            end)
        end
        
    end

    local down_func = function()
        local ver = ""
        local data = CS.Launcher_param.online_param
        if data then
            local d, err = U.json.decode(data)
            if d and d.ver then
                ver = d.ver
            end
        end
        local oss_path = CS.Launcher_param.oss_path or "http://cdn.wawa31.racethunder.cn/wawa31/"
        local url = oss_path .. "ver/" .. platform_list[plat] .. "/ver_" .. ver .. "/ab_updata/" .. "updata_" .. name
        U.log.i("url = " .. url)
        CS.Fwk.Util.Downloader.AsyncLoadFile(url, pepath, "updata_" .. name,
        function(s)
            U.log.i(s)
            UI.refresh_down_panel({id = "updata_" .. name, progress = s, command = "refresh_progress"})
        end,
        function(s)
            U.log.i(s)
            UI.refresh_down_panel({id = "updata_" .. name, command = "remove_down"})
            local info = _util.ab_info[name]
            if not info then
                info = {}
                U.log.w("_util.ab_info no key：" .. name)
            end
            info.state = "waiting"
        end,
        function(a, b)
            U.log.i(a,b)
            if a == "Streaming finished!" then
                load_ab_func()
                UI.refresh_down_panel({id = "updata_" .. name, command = "remove_down"})
            end
        end)
        UI.refresh_down_panel({id = "updata_" .. name, command = "add_down"})
    end

    if not CS.System.IO.File.Exists(path) then
        U.log.i("file not Exists =====================")
        down_func()
        return
    else
        -- local res_list_data = CS.Launcher_param.res_list
        -- if res_list_data then
        --     local d, err = U.json.decode(res_list_data)
        --     if d then
        --         local list = d[is_updata and "updata_res_list" or "res_list"]
        --         -- local list = d["updata_res_list"]
        --         U.log.dump("is_updata = " .. tostring(is_updata))
        --         if list then
        --             local md5 = CS.SYFwk.Core.Extension.EncodeMd5File(path, true)
        --             local prefix = is_updata and "updata_" or ""
        --             if not list[prefix .. name] or list[prefix .. name] ~=  md5 then
        --                 U.log.i("md5 error:" .. tostring(list[prefix .. name]) .. ":" .. tostring(md5) .. ":" .. tostring(name))
        --                 down_func()
        --                 return
        --             end
        --         end
        --     end
        -- end
    end
    load_ab_func()
end

function loader_run.load(name, type_, cb, asset_lab, no_async)
    if type_ == common.PREFAB then
        -- 计算出资源所谓ab包
        local abname = string.gsub(name, "/", ".") .. ".ab"
        abname = string.lower(abname)                           -- Unity中全是小写？？
        local pname  = string.match(abname, "([^%.][%w_]+)%.ab")
        _util.load_ab(abname, function (nname, ab)
            if no_async then
                local asset = ab:LoadAssetAsync(pname)
                cb(asset)
            else
                local req = ab:LoadAssetAsync(pname)
                req:completed("+", function (req)
                    if cb then
                        cb(req.asset)
                    end
                end)
            end
        end, type_, no_async)
    elseif type_ == common.IMAGE then
        asset_lab = asset_lab or "sprite_load"
        asset_lab = asset_lab == "load" and "sprite_load" or asset_lab
        local asset_name = asset_lab .. ".ab"
        _util.load_ab(asset_name, function (nname, ab)
            local info = _util.ab_info[asset_name]
            if not info then
                info = {}
                U.log.w("_util.ab_info no key：" .. asset_name)
            end
            local aname = "Assets/" .. (info.is_updata and "res_updata" or "res") .."/" .. name .. ".png"
            if no_async then
                local asset = ab:LoadAsset(aname, _type_sprite)
                cb(asset)
            else
                local req = ab:LoadAssetAsync(aname, _type_sprite)
                req:completed("+", function (nreq)
                    local asset = req.asset 
                    -- if req.isDone and asset == nil then
                    --     print("try load use LoadAsset")
                    --     asset = ab:LoadAsset(aname, _type_sprite)
                    -- end
                    if cb then
                        cb(asset)
                    end
    
                end)
            end
            
        end, type_, no_async)
    elseif type_ == common.SOUND then
        local abname_ = string.gsub(name, "/", ".")
        abname_ = string.gsub(abname_, "sound.", "", 1)
        local s = string.split(abname_, ".")
        local abname = ""
        if table.length(s) > 1 then
            for i = 1, #s - 1 do
                if i == #s - 1 then
                    abname = abname .. s[i]
                else
                    abname = abname .. s[i] .. "."
                end
            end
        else
            abname = s[1]
        end

        abname = abname .. ".ab"
        abname = "sound_" .. string.lower(abname)  
        _util.load_ab(abname, function (nname, ab)
            local info = _util.ab_info[abname]
            if not info then
                info = {}
                U.log.w("_util.ab_info no key：" .. abname)
            end
            local aname = "Assets/" .. (info.is_updata and "res_updata" or "res") .."/" .. name .. ".mp3"
            if no_async then
                local asset = ab:LoadAsset(aname, _type_sound)
                cb(asset)
            else
                local req = ab:LoadAssetAsync(aname, _type_sound)
                req:completed("+", function (nreq)
                    local asset = req.asset 
                    if cb then
                        cb(asset)
                    end
    
                end)
            end
            

        end, type_, no_async)
    end
end

-- 注意这个接口实际上是同步的
function loader_dev.load(name, type_, cb)
    U.schedule.add_task({
        func = function()
            if type_ == common.PREFAB then
                CS.SYFwk.Core.Core.Load(string.format("prefab/%s", name), _type_prefab, function (asset)
                    if cb then
                        cb(asset)
                    end
                end)
            elseif type_ == common.IMAGE then
                CS.SYFwk.Core.Core.Load(name, _type_sprite, function (asset)
                    if cb then
                        cb(asset)
                    end
                end)
            elseif type_ == common.SOUND then
                CS.SYFwk.Core.Core.Load(name, _type_sound, function (asset)
                    if cb then
                        cb(asset)
                    end
                end)
            end
        end
    })
end


function loader_run.unload(list)
    _util.unload_all_ab(list)
end

function loader_dev.unload(list)
    _util.unload_all_ab(list)
end


setmetatable(loader_run, {__index = common})
setmetatable(loader_dev, {__index = common})


local function init ()
    U.log.i("Init ui loader with mode ", U.loader.mode)
    -- do 
    --     pepath = sapath .. "ab/ab/"
    --     return loader_run
    -- end
    if U.loader.mode == U.loader.MODE_RUN then
        return loader_run
    else 
        return loader_dev
    end
end

return {
    init = init,
}