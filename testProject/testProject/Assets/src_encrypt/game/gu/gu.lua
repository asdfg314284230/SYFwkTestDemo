local gu = {}

local mod = {}
local list = {
    ["common"] = "common",
    ["tools"] = "tools",
    ["collection"] = "collection",
    ["constant"] = "constant",
    ["text"] = "text",
    ["image"] = "image",
    ["lua_to_platform"] = "lua_to_platform",
    ["platform_to_lua"] = "platform_to_lua",
    ["audio"] = "audio",
}

gu.language = M.get_local_data("language") or "eng"

for k, v in pairs(list) do
    gu[k] = require("game.gu." .. v)
    if gu[k] and gu[k].init then
        gu[k].init()
    end
end


return gu
