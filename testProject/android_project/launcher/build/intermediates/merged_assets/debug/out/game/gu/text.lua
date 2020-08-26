local text = {}

text.ch = {
    unknown = '未知',
    lack_money = "金钱不足",
    lack_place = "货架没有足够的位置",
    lack_ad = "没有可用广告",
    conf_err = "配置错误",
    received = "已领取",
    install = "安装",
    installed = "已安装",
    unlock = "解锁",
    get = "获得",
    no_thank = "不需要",
    award_dialog_title = "恭喜你获得",
    create_name_title = "创建名称",
    create_name_hint = "最多15字符",
    create_name_determine = "确定",
    gift_title = "礼物",
    next_tool_title = "下一个工具",
    double_reward = "双倍奖励",
    main_tap_start = "点击开始",
    quests_title = "任务",
    dailies = "日报",
    achievement = "成就",
    refreshes_in = "刷新",
    collect = "收集",
    advance = "前往",
    completed = "已完成",
    rank_title = "排行榜",
    rank_text_rank = "排名",
    rank_text_id = "ID",
    rank_text_lv = "等级",
    rank_text_sales = "销售",
    rank_text_reward = "给予相同的奖赏~\n观看视频~ ~",
    rank_text_mine = "我",
    setting_title = "设置",
    setting_text_creat_time = "创建日期",
    music = "音乐",
    sound_effect = "音效",
    upgrade_title = "升级",
    photo_frame = "相框",
    triole_for_sell = "三倍价格收买",
    evaluation = "评价",
    good = "好",
    great = "伟大",
    prefect = "完美",
    sell_now = "立即售卖",
    text_receive = "领取",
    language_title = "语言",
    language_title_text_close = "关闭",
    language_text_confirm = "确认",
}

text.eng = {
    unknown = 'Unknown',
    lack_money = "money require",
    lack_place = "Require more space",
    lack_ad = "No ad",
    conf_err = "Config error",
    received = "Received",
    install = "Install",
    installed = "Installed",
    unlock = "Unlock",
    get = "Reward",
    no_thank = "No thanks",
    award_dialog_title = "Reward",
    create_name_title = "Create a name",
    create_name_hint = "Less than 15 characters",
    create_name_determine = "OK",
    gift_title = "Gift",
    next_tool_title = "Next tool",
    double_reward = "Double reward",
    main_tap_start = "Tap to start",
    quests_title = "Quests",
    dailies = "Daily report",
    achievement = "Achievement",
    refreshes_in = "Refresdh",
    collect = "Collect",
    advance = "GO",
    completed = "Completed",
    rank_title = "Rank",
    rank_text_rank = "Rank",
    rank_text_id = "ID",
    rank_text_lv = "Level",
    rank_text_sales = "sales",
    rank_text_reward = "Give the same reward~\nWatch video~ ~",
    rank_text_mine = "My",
    setting_title = "Set up",
    setting_text_creat_time = "Create data",
    music = "Music",
    sound_effect = "Sound",
    upgrade_title = "Upgrade",
    photo_frame = "Photo frame",
    triole_for_sell = "Triple for sales",
    evaluation = "Review",
    good = "Good",
    great = "Great",
    prefect = "Perfect",
    sell_now = "立即售卖",
    text_receive = "Revieve",
    language_title = "Language",
    language_title_text_close = "Close",
    language_text_confirm = "OK",
}

function text.get(key)
    local l = text[Game.U.language]
    if not l then
        return ''
    end

    return l[key] or ''
end


local conf_map = {
    ch = "language_cn",
    eng = "language_en",
}
function text.get_by_conf(key)
    local s = ""
    local conf_name = conf_map[Game.U.language]
    
    if conf_name and C[conf_name] and C[conf_name][key] and C[conf_name][key].des then
        s = C[conf_name][key].des or ""
    end
    return s
end

return text
