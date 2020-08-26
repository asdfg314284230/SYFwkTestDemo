--------------------------------------------------------------------------------------
-- author ly
-- date 2020-05-14
-- desc 导航条
--------------------------------------------------------------------------------------
local mod = {}

mod._load_param = {
    ui_type = "actionbar",
    tag = "actionbar",
    prefab = "actionbar/actionbar"
}

function mod:on_load(param)
    self:init_data(param)
    self:init_ui()
    self:refresh()

    self.refresh_ani = {}
    M.info:add_modify_listener("exp", U.handle(self, self.on_info_change))
    M.info:add_modify_listener("gold", U.handle(self, self.on_info_change))
end

function mod:init_data(param)
    
end

function mod:init_ui()
    self.ui = {}
    self.ui.bottom = self:seek_component(self.gameObject,"bottom","RectTransform")

    self.ui.item_lv = self:seek_component(self.gameObject,"item_lv","RectTransform")
    self.ui.text_lv = self:seek_component(self.ui.item_lv.gameObject,"text_lv","Text")
    self.ui.pro_lv = self:seek_component(self.ui.item_lv.gameObject,"pro","Image")
    self.ui.text_value_lv = self:seek_component(self.ui.item_lv.gameObject,"text_value","Text")
    
    self.ui.item_coin = self:seek_component(self.gameObject,"item_coin","RectTransform")
    self.ui.text_value_coin = self:seek_component(self.ui.item_coin.gameObject,"text_value","Text")


    self:bind_button_click(self.gameObject,"btn_set",function()
        -- UI.load({name = "common.debug"})
        UI.load({name = "setting.setting"})
    end)


    local bottom = self:seek_component(self.gameObject,"bottom","RectTransform")
    local bottom_layout = self:seek_component(bottom.gameObject,"layout","RectTransform")
    for i = 0, bottom_layout.transform.childCount - 1 do 
        local child = bottom_layout.transform:GetChild(i)
        self:bind_button_click(child.gameObject,"btn",function()
            self:bottom_button_on_click(child.name)
        end)
    end


    M.rtdata.star_recycle_pos = {
        x = self.ui.text_value_lv.transform.position.x,
        y = self.ui.text_value_lv.transform.position.y,
        z = self.ui.text_value_lv.transform.position.z,
    }

    M.rtdata.money_recycle_pos = {
        x = self.ui.item_coin.transform.position.x,
        y = self.ui.item_coin.transform.position.y,
        z = self.ui.item_coin.transform.position.z,
    }
end

function mod:on_show(param)
    param = param or {}
    self.ui.bottom.gameObject:SetActive(not not param.show_bottom)
end

function mod:on_command(param)
    param = param or {}
    local command = param.command
    if command and type(self[command]) == 'function' then
        self[command](self, param)
    else
    end
end

function mod:bottom_button_on_click(t)
    if t == "storage" then
        UI.load({name = "storage.storage_main"})
    elseif t == "ranking" then
        UI.load({name = "rank.rank_main"})
    elseif t == "collection" then
        UI.load({name = "illustrated.illustrated_main"})
    elseif t == "task" then
        UI.load({name = "quests.quests_main"})
    elseif t == "home" then
        UI.load({name = "upgrade.upgrade_main"})

    end
end

function mod:refresh(param)
    -- local exp = M.info:get_info("exp")
    -- local lv = math.floor( exp/100 ) + 1

    local lv, exp, next_exp = M.info:get_level_info()
    self.ui.text_lv.text = "Lv." .. lv
    self.ui.pro_lv.fillAmount = exp/next_exp
    self.ui.text_value_lv.text = exp .. "/" .. next_exp
    self.ui.text_value_coin.text = M.info:get_info("gold")
end

function mod:on_info_change(param)
    self:refresh()
end


return UI.export(mod)
