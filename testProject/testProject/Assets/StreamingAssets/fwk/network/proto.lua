local pb = require "pb"
local proto = {}

function proto.init_proto(root)
    -- _cfg .. "game/pb"
    pb.loadfile(root .. "game/pb/test.pb")
    pb.loadfile(root .. "game/pb/player.pb")
end


function proto.encode(pb_name, data)
    local msg = pb.encode(pb_name, data)
    return msg, string.len(msg)
end

function proto.decode(pb_name, data)
    local msg = pb.decode(pb_name, data)
    return msg
end

return proto