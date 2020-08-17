local _M = {}
function _M:init()
    self.network_canvas = CS.UnityEngine.GameObject.Find("network_canvas")
    if self.network_canvas then

        local root = CS.UnityEngine.GameObject("network_mask")
        local rt = root:AddComponent(typeof(CS.UnityEngine.RectTransform))
        rt.offsetMax = CS.UnityEngine.Vector2(0, 0)
        rt.offsetMin = CS.UnityEngine.Vector2(0, 0)
        rt.anchorMin = CS.UnityEngine.Vector2(0, 0)
        rt.anchorMax = CS.UnityEngine.Vector2(1, 1)
        rt.sizeDelta = CS.UnityEngine.Vector2(0, 0)
        root.transform:SetParent(self.network_canvas.transform, false)
        local image = root:AddComponent(typeof(CS.UnityEngine.UI.Image))
        
        image.gameObject:SetActive(false)
        image.color = {r = 0, g = 0, b = 0, a = 0}
        self.network_mask_image = image
        
        self._is_init = true
        self:reset()
        -- N.register_net_callback("on_process_data", U.handle(self, self.on_process_data))
        -- N.register_net_callback("on_send_request", U.handle(self, self.on_send_request))

        
    end
end

function _M:update(dt)
    if not self._is_init then
        return
    end

    if self._show_time and self._show_time < 1 then
        self._show_time = self._show_time + dt
    end
    
    if self._show_time and self._content then
        self._content.gameObject:SetActive(self._show_time >= 1)
    end
    -- U.log.i(self._show_time)
    -- for k, v in pairs(self._session_list) do
    --     v.wait = v.wait + dt
    -- end
end

function _M:on_process_data(session)
    if not self._is_init then
        return
    end

    self._session_list[session] = nil
    if table.length(self._session_list) == 0 then
        self.network_mask_image.gameObject:SetActive(false)
        self._show_time = nil
    end
end

function _M:on_send_request(session)
    if not self._is_init then
        return
    end

    self._show_time = self._show_time or 0
    self._session_list[session] = {wait = 0}
    self.network_mask_image.gameObject:SetActive(true)
end

function _M:set_network_mask_panel(content)
    if not self._is_init then
        return
    end

    if self.network_canvas and content then
        if self._content then
            CS.UnityEngine.GameObject.Destroy(self._content.gameObject)
        end
        content.transform:SetParent(self.network_mask_image.transform)
        self._content = content
        self._content.gameObject:SetActive(false)
    end
end

function _M:reset()
    if not self._is_init then
        return
    end

    self._session_list = {}
    self._show_time = nil
    if self._content then
        self._content.gameObject:SetActive(false)
    end
    self.network_mask_image.gameObject:SetActive(false)
end
return _M