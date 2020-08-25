--[[

Copyright (c) 2015 gameboxcloud.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local string_format = string.format
local pairs = pairs

local ok, table_new = pcall(require, "table.new")
if not ok or type(table_new) ~= "function" then
    function table:new()
        return {}
    end
end

local _copy
_copy = function(t, lookup)
    if type(t) ~= "table" then
        return t
    elseif lookup[t] then
        return lookup[t]
    end
    local n = {}
    lookup[t] = n
    for key, value in pairs(t) do
        n[_copy(key, lookup)] = _copy(value, lookup)
    end
    return n
end

function table.copy(t)
    local lookup = {}
    return _copy(t, lookup)
end

function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

function table.map(t, fn)
    local n = {}
    for k, v in pairs(t) do
        n[k] = fn(v, k)
    end
    return n
end

function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

function table.filter(t, fn)
    local n = {}
    for k, v in pairs(t) do
        if fn(v, k) then
            n[k] = v
        end
    end
    return n
end

function table.length(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.readonly(t, name)
    name = name or "table"
    setmetatable(t, {
        __newindex = function()
            error(string_format("<%s:%s> is readonly table", name, tostring(t)))
        end,
        __index = function(_, key)
            error(string_format("<%s:%s> not found key: %s", name, tostring(t), key))
        end
    })
    return t
end

--array会被改变
function table.random_shuffle(array)
    local size = #array
    local randomArray = {}
    for i=1,size do
        local randomV = math.random(1, size + 1 - i)
        table.insert(randomArray, array[randomV])
        array[randomV] = array[size + 1 - i]
    end
    return randomArray
end

function table.array_to_hash(t)
    local n = #t
    -- print("n = ", n)
    local h = table_new(0, n / 2)
    for i = 1, n, 2 do
        h[t[i]] = t[i + 1]
    end
    return h
end

local _read_only_mt = {
    __newindex = function (...)
        error("table is read only!", 1)
    end
}
function table.set_read_only(tab)
    return setmetatable(tab, _read_only_mt)
end

function table.spairs(tab, sort_fun)
    local keys = table.keys(tab)
    table.sort(keys, sort_fun)
    local index = 1
    return function ()
        while index <= #keys do         -- 遍历找到一个非空的值，根据lua原生的定义，遍历过程中不能加新的元素
            local k = keys[index]
            index = index + 1
            if tab[k] then
                return k, tab[k]
            end
        end
        return nil, nil
    end, keys, nil
end
spairs = table.spairs
--[[
-- test
    local td = {a = 1, b = 2, c = 3}
    for k, v in pairs(td) do 
        print(k, v)
    end
    for k, v in spairs(td) do 
        print(k, v)
    end
--]]

return table