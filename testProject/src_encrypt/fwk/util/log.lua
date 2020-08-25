--------------------------------------------------------------------------------------
-- 工具类
-- @module U.log
-- @author Yang Zhang
-- @copyright yang zhang 2018
-- @date 2018-03-15
--------------------------------------------------------------------------------------

-- @table log
local log = {}
local debug_traceback = debug.traceback

local _real_print       = print
local _lvl_print        = _real_print
local _lvl_dump_print   = _real_print             -- 专门为dump写的print函数

local _mt = {
	__call = function (self, ...)
		local traceback = string.split(debug_traceback("", 2), "\n")
		_lvl_print("d", "[" .. string.trim(traceback[2]).."]", ...)
    end,
}
setmetatable(log, _mt)

for _, v in ipairs({"d", "i", "w", "e"}) do 
	local _create_logger = function (lvl)
		return function (...)
			local traceback = string.split(debug_traceback("", 2), "\n")
			_lvl_print(lvl, "[" .. string.trim(traceback[2]).."]", ...)
		end
	end
	log[v] = _create_logger(v)
end

--------------------------------------------------------------------------------------
-- @function dump
local function _dump_value(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

local function _dump_trackback (traceback)
    return "dump from: " .. string.trim(traceback[2])
end

local function dump (value, desciption, nesting, _print, costom_pairs)
    if type(nesting) ~= "number" then nesting = 5 end
    _print = _print or _lvl_dump_print

    
    local pairs = costom_pairs or pairs

    local lookup = {}
    local result = {}
    -- local traceback = string.split(debug_traceback("", 2), "\n")
    -- table.insert(result, (_dump_trackback(traceback)))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_dump_value(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _dump_value(desciption), spc, _dump_value(value))
        elseif lookup[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, _dump_value(desciption), spc)
        else
            lookup[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, _dump_value(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _dump_value(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _dump_value(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)
    local traceback = string.split(debug_traceback("", 2), "\n")
    _print(traceback[2], result[1],table.concat(result, "\r\n", 2))
end

--------------------------------------------------------------------------------------
-- 打印
-- @param value 需要打印的值
-- @param desciption 打印描述
-- @param nesting 打印table的层级
-- @param _print 自定义输出函数
-- @function mdump
local function mdump(value, desciption, nesting, _print)
    dump(value, desciption, nesting, _print, M.mpairs)
end
log.dump = dump
log.mdump = mdump

local init = function (mode, cfg)
	if mode == "console" then
		local _color_print = nil
		local ok, zz_log = pcall(require, "zz.log")
		if ok then
			_color_print = zz_log.print
		else
			_color_print = function (color, ...)
				_real_print(...)
			end
		end
		local _color = {
			d = 0x08,
			i = 0x01,
			w = 0x06,
			e = 0x0d,
		}
		_lvl_print = function (lvl, ...)
			local len = select("#", ...)
			local ret = {}
			for i = 1, len do 
				table.insert(ret, tostring(select(i, ...)))
			end
			_color_print(_color[lvl], table.concat( ret, "\t" ))
		end
    elseif mode == "unity" and cfg.editor then
        _dump_trackback = function (traceback)
            return "dump from: " .. string.trim(traceback[2]) .. "</color>\r\n<color=#D670D6>"
        end

		local _template = {
			-- d = {"<color=#666666>", "", "</color>"},
			-- i = {"<color=#2065C8>", "", "</color>"},
			-- w = {"<color=#F3C81C>", "", "</color>"},
            -- e = {"<color=#D670D6>", "", "</color>"},
            
            d = {"<color=#000000>", "", "</color>"},
			i = {"<color=#0095FF>", "", "</color>"},
			w = {"<color=#F3C81C>", "", "</color>"},
			e = {"<color=#D670D6>", "", "</color>"},
		}
		local _DATA_INDEX = 2
		_lvl_print = function (lvl, ...)
			local len = select("#", ...)
			local ret = {}
			for i = 1, len do 
				table.insert(ret, tostring(select(i, ...)))
			end
			_template[lvl][_DATA_INDEX] = table.concat(ret, "\t")
			_real_print(table.concat( _template[lvl]))
        end
        
        _lvl_dump_print = function (log_trace, log_desc, log_text)
            local d = {
                string.format("<color=#519A59FF>Dump from %s</color>", log_trace),
                string.format("<color=#519A59FF>%s</color>", log_desc),
                string.format("<color=#519A59FF>%s</color>", log_text),
            }
            _real_print(table.concat(d, "\r\n"))
        end
	end

	print = log		-- Global value
end


-- 框架调用这个函数，函数的返回值为对外导出函数列表
return function (util)
    util.log = log
    return {
		init = init,
	}
end

--[[
# Windows CMD命令行 字体颜色定义 text colors
FOREGROUND_BLACK = 0x00 # black.
FOREGROUND_DARKBLUE = 0x01 # dark blue.
FOREGROUND_DARKGREEN = 0x02 # dark green.
FOREGROUND_DARKSKYBLUE = 0x03 # dark skyblue.
FOREGROUND_DARKRED = 0x04 # dark red.
FOREGROUND_DARKPINK = 0x05 # dark pink.
FOREGROUND_DARKYELLOW = 0x06 # dark yellow.
FOREGROUND_DARKWHITE = 0x07 # dark white.
FOREGROUND_DARKGRAY = 0x08 # dark gray.
FOREGROUND_BLUE = 0x09 # blue.
FOREGROUND_GREEN = 0x0a # green.
FOREGROUND_SKYBLUE = 0x0b # skyblue.
FOREGROUND_RED = 0x0c # red.
FOREGROUND_PINK = 0x0d # pink.
FOREGROUND_YELLOW = 0x0e # yellow.
FOREGROUND_WHITE = 0x0f # white.


# Windows CMD命令行 背景颜色定义 background colors
BACKGROUND_BLUE = 0x10 # dark blue.
BACKGROUND_GREEN = 0x20 # dark green.
BACKGROUND_DARKSKYBLUE = 0x30 # dark skyblue.
BACKGROUND_DARKRED = 0x40 # dark red.
BACKGROUND_DARKPINK = 0x50 # dark pink.
BACKGROUND_DARKYELLOW = 0x60 # dark yellow.
BACKGROUND_DARKWHITE = 0x70 # dark white.
BACKGROUND_DARKGRAY = 0x80 # dark gray.
BACKGROUND_BLUE = 0x90 # blue.
BACKGROUND_GREEN = 0xa0 # green.
BACKGROUND_SKYBLUE = 0xb0 # skyblue.
BACKGROUND_RED = 0xc0 # red.
BACKGROUND_PINK = 0xd0 # pink.
BACKGROUND_YELLOW = 0xe0 # yellow.
BACKGROUND_WHITE = 0xf0 # white.
]]