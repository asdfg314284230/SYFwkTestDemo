-- 这里对BestHttp封装一下。项目中不直接用BestHttp
local http = {}

local methods = {}
methods.__index = methods

local _n2t = {}
local form_usage = nil



function methods:request(uri, data, params, header)
	params = params or {
		method = "get",
	}
	local request = CS.BestHTTP.HTTPRequest(CS.System.Uri(uri), self._on_request_finish)
	if type(data) == "string" then
		request.RawData = data
	elseif type(data) == "table" then
		for k, v in pairs(data) do 
			request:AddField(tostring(k), tostring(v))
		end
		request.FormUsage = form_usage
		request.RawData = nil
	end
	
	request.Tag = self
	if header then
		for i = 1, #header do
			local name = header[i].name
			local value = header[i].value
			request:AddHeader(name, value)
		end
	end
	request.MethodType = _n2t[string.upper(params.method)] --CS.BestHTTP.HTTPMethods.Post
	-- request:SetConnectTimeout(5)
	request:Send()
end

function methods._on_request_finish(req, resp)
	local httpc = req.Tag
	if httpc and httpc._cb_fun then
		local ok, msg
		if req.State == CS.BestHTTP.HTTPRequestStates.Finished then
			if resp.IsSuccess then
				ok, msg = true, resp.DataAsText
			else 
				ok, msg = false, string.format("Revc *BUT* server => [%s][%s] [%s] ", 
										resp.StatusCode,
										resp.Message,
										resp.DataAsText)
			end
		elseif req.State == CS.BestHTTP.HTTPRequestStates.ConnectionTimedOut -- 单独区分一下timeout，这个需要处理
			or req.State == CS.BestHTTP.HTTPRequestStates.TimedOut then
			ok, msg = false, "timeout" .. tostring(req.State) 
			if req.Exception then
				msg = msg .. tostring(req.Exception.Message)
			end
		else
			-- FIXME
			ok, msg = false, "ZYTODO detail info" .. tostring(req.State) 
			if req.Exception then
				msg = msg .. tostring(req.Exception.Message)
			end
		end

		httpc.success = ok
		httpc.data    = msg
		httpc._cb_fun(httpc)
	else
		util.log.d("_on_request_finish error no httpc or cb_fun")
	end
end



function http.new(cb_fun)
	return setmetatable({
		_cb_fun = cb_fun,
	}, methods)
end

local function init (mode)
	if mode == "unity" then
		_n2t = {
			["POST"] =  CS.BestHTTP.HTTPMethods.Post,
			["GET"]  =  CS.BestHTTP.HTTPMethods.Get,
		}
		form_usage = CS.BestHTTP.Forms.HTTPFormUsage.UrlEncoded
	else 
		--TODO 再搞一个console版本
	end
end

return function (util)
	util.http = http
	return {
		init = init,
	}
end