local _M = {}


function _M:convert_diff_l_to_w(transform, l_pos)
    l_pos = {
        x = l_pos.x or 0,
        y = l_pos.y or 0,
        z = l_pos.z or 0,
    }
    local o_localPosition = transform.localPosition
    local o_position = transform.position

    transform.localPosition = {
        x = transform.localPosition.x + l_pos.x,
        y = transform.localPosition.y + l_pos.y,
        z = transform.localPosition.z + l_pos.z,
    }

    local diff = {
        x = transform.position.x - o_position.x,
        y = transform.position.y - o_position.y,
        z = transform.position.z - o_position.z,
    }

    transform.localPosition = o_localPosition
    return diff
end


function _M:convert_diff_w_to_l(transform, w_pos)
    w_pos = {
        x = w_pos.x or 0,
        y = w_pos.y or 0,
        z = w_pos.z or 0,
    }
    local o_localPosition = transform.localPosition
    local o_position = transform.position

    transform.position = {
        x = transform.position.x + w_pos.x,
        y = transform.position.y + w_pos.y,
        z = transform.position.z + w_pos.z,
    }

    local diff = {
        x = transform.localPosition.x - o_localPosition.x,
        y = transform.localPosition.y - o_localPosition.y,
        z = transform.localPosition.z - o_localPosition.z,
    }

    transform.localPosition = o_localPosition
    return diff
end

function _M:formatNum (num)
    if num <= 0 then
        return 0
    else
        local t1, t2 = math.modf(num)
        ---小数如果为0，则去掉
        if t2 > 0 then
            return num
        else
            return t1
        end
    end
end


return _M