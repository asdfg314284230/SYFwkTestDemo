local schema = {}
schema.all = {}
schema.user = {}
schema.job = {}
local file = {
    user = {
        "info",
        "bag",
        "battle",
        "battle_inside",
        "daily",
        "slodier_train",
        "analytics",
        "equip",
        "conduct",
        -- "factory",
        "shop",
        "email",
        "formation",
        "mission",
        "legion",
        "player_info",
        "recruit_bar",
        "hero",
        "soldier",
        "pit",
        "citydef",
        "genius",
        "mine",
        "dungeons",
        "campaign",
        "battle_array",
        "rune"
    },
    job = {}
}

SCHEMA_TYPE = {
    INT = "INT(11)",
    STRING = "VARCHAR(255)",
    STRING_BIG = "mediumtext",
    JSON = "text",
    BOOL = "tinyint(1)",
    FLOAT = "INT(11)"
    -- DOUBLE = "double",
}

for k, v in pairs(file.user) do
    schema.user[v] = require("schema." .. v)
    schema.all[v] = schema.user[v]
end

for k, v in pairs(file.job) do
    schema.job[v] = require("schema." .. v)
    schema.all[v] = schema.job[v]
end

return schema
