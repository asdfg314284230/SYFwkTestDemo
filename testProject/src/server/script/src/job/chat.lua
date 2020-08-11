
local function _on_init( )
    print( "[chat.lua : finish ]" )
end

local _command = {} 


function _command.multicast( )

    print( "[chat.lua : _multicast]" )      
    _jctx.multicast( 200 + 11, "test broadcast" )


    local code = EC.OK
    local msg = {}
    return code, msg

end


function _command.brocast2group( pcid, userlist )

    print( "[ chat.lua : _command.brocast2group ]" )      
    _jctx.multicast2group( 200 + 11, "test brocast2group", userlist )

    local code = EC.OK
    local msg = {}
    return code, msg 
    
end


local function on_finish( )
    print( "[chat.lua : finish ]" )
end


local function _new_day( ... )
    print( "[chat.lua : _new_day]" )
end

return {
    init = _on_init,
    command = _command,
    finish = on_finish,
    new_day = _new_day
}
