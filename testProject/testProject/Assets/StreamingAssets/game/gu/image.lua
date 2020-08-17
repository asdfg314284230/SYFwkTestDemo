local image = {}

local path = {
    ch = "image/Text/Chinese/",
    eng = "image/Text/English/",
}

function image.get(key)
    return (path[Game.U.language] or path["ch"]) .. key
end

return image