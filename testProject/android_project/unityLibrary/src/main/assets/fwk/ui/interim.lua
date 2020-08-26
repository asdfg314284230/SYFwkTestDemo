local _M = {}

function _M:init()
    self.interim_canvas = CS.UnityEngine.GameObject.Find("interim_canvas")
    if self.interim_canvas then
        local root = CS.UnityEngine.GameObject("interim_image")
        local rt = root:AddComponent(typeof(CS.UnityEngine.RectTransform))
        rt.offsetMax = CS.UnityEngine.Vector2(0, 0)
        rt.offsetMin = CS.UnityEngine.Vector2(0, 0)
        rt.anchorMin = CS.UnityEngine.Vector2(0, 0)
        rt.anchorMax = CS.UnityEngine.Vector2(1, 1)
        rt.sizeDelta = CS.UnityEngine.Vector2(0, 0)
        root.transform:SetParent(self.interim_canvas.transform, false)
        local image = root:AddComponent(typeof(CS.UnityEngine.UI.Image))
        local canvasGroup = root:AddComponent(typeof(CS.UnityEngine.CanvasGroup))
        image.gameObject:SetActive(false)
        image.color = {r = 0, g = 0, b = 0, a = 0}
        canvasGroup.alpha = 0
        self.interim_image = image
        self.interim_canvasGroup = canvasGroup
        self.interim_param = nil
    end
end

function _M:update(dt)
    if self.interim_param then
        U.log.dump(self.interim_param)
        if self.interim_param.mode == "show" then
            self.interim_param.t = self.interim_param.t - dt
            if self.interim_param.t <= 0 then
                if self._content then
                    self._content.gameObject:SetActive(true)
                end
                -- self.interim_image.color = {r = 0, g = 0, b = 0, a = 1}
                if self.interim_param.duration == 0 then
                    self.interim_canvasGroup.alpha = 0
                else
                    self.interim_canvasGroup.alpha = 1
                end
                local func = self.interim_param.func
                self.interim_param = nil
                if func then
                    func()
                end
            else
                self.interim_canvasGroup.alpha = (self.interim_param.duration - self.interim_param.t)/self.interim_param.duration
                -- self.interim_image.color = {r = 0, g = 0, b = 0, a = (self.interim_param.duration - self.interim_param.t)/self.interim_param.duration}
            end
        elseif self.interim_param.mode == "hide" then
            self.interim_param.t = self.interim_param.t - dt
            if self.interim_param.t <= 0 then
                self.interim_canvasGroup.alpha = 0
                -- self.interim_image.color = {r = 0, g = 0, b = 0, a = 0}
                local func = self.interim_param.func
                self.interim_param = nil
                if func then
                    func()
                end
                self.interim_image.gameObject:SetActive(false)
            else
                self.interim_canvasGroup.alpha = self.interim_param.t/self.interim_param.duration
                -- self.interim_image.color = {r = 0, g = 0, b = 0, a = self.interim_param.t/self.interim_param.duration}
            end
        end
    end
end

function _M:show(param)
    param = param or {}
    if self.interim_canvas then
        -- 如果有别的任务处理，暂时直接回调。
        if self.interim_param then
            if param.func then
                param.func()
            end
            return
        end

        if self._content then
            self._content.gameObject:SetActive(false)
        end
        self.interim_image.gameObject:SetActive(true)
        local duration  = param.duration or 0
        self.interim_param = {
            mode = "show",
            duration = duration,
            t = duration,
            func = param.func,
        }
    else
        if param.func then
            param.func()
        end
    end
end

function _M:hide(param)
    param = param or {}
    if self.interim_canvas then
        -- 如果有别的任务处理，暂时直接回调。
        if self.interim_param then
            if param.func then
                param.func()
            end
            return
        end

        if self._content then
            self._content.gameObject:SetActive(false)
        end
        local duration  = param.duration or 0
        self.interim_param = {
            mode = "hide",
            duration = duration,
            t = duration,
            func = param.func,
        }
    else
        if param.func then
            param.func()
        end
    end
end

function _M:set_interim_panel(content)
    if self.interim_canvas and content then
        if self._content then
            CS.UnityEngine.GameObject.Destroy(self._content.gameObject)
        end
        content.transform:SetParent(self.interim_image.transform)
        self._content = content
    end
end

return _M