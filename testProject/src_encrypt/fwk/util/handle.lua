--------------------------------------------------------------------------------------
-- 函数包装
-- @module U.handle
-- @author yang zhang
-- @copyright yang zhang 2018
-- @date 2018-03-26

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- 生成一个函数proxy, 调用proxy(...)内部会调用target:func(...)
-- @function U.handle
-- @param target 函数调用时的对象
-- @param func   函数调用时的函数
function handle(target, func)
	local proxy = function(...)
		return func(target, ...)
	end
	return proxy
end

--------------------------------------------------------------------------------------
-- 生成一个函数proxy, 调用proxy(...)内部会调用target:func(param, ...)
-- @function U.handle_args
-- @param target 函数调用时的对象
-- @param func   函数调用时的函数
function handle_args(target, func, param)
	local proxy = function(...)
		return func(target, param, ...)
	end
	return proxy
end

-- 框架调用这个函数，函数的返回值为对外导出函数列表
return function (util)
    util.handle         = handle
    util.handle_args    = handle_args
    return {}
end