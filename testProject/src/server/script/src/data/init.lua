local logic_tab = {
    'logic.user',
    'logic.gm',
    'logic.bag',
    'logic.battle',
    'logic.battle_inside',
    'logic.daily',
    'logic.analytics',
    'logic.rank',
    'logic.equip',
    'logic.slodier_train',
    'logic.slodier_genius',
    'logic.slodier_skill',
    'logic.slodier_equip',
    'logic.smithy',
    'logic.conduct',
    -- 'logic.factory',
    'logic.shop',
    'logic.email',
    'logic.formation',
    'logic.mission',
    'logic.legion',
    'logic.player_info',
    'logic.recruit_bar',
    'logic.hero',
    'logic.soldier',
    'logic.pit',
    'logic.citydef',
    'logic.rank',
    'logic.rank_new',
    'logic.genius',
    'logic.mine',
    'logic.dungeons',
    "logic.campaign",
    "logic.battle_array",
    "logic.rune"

    -- "logic.reward_flag",
    -- "logic.tool",
}
local job_tab = {
    'job.aoi',
    'job.rank',
    'job.chat',
    'job.rank_new'
}

local all_data_mod = {
    ['logic.user'] = true,
    ['logic.gm'] = true,
    ['logic.slodier_genius'] = 'slodier_train',
    ['logic.slodier_skill'] = 'slodier_train',
    ['logic.slodier_equip'] = 'slodier_train',
    ['logic.hero_genius'] = 'hero_train',
    ['logic.hero_skill'] = 'hero_train',
    ['logic.hero_equip'] = 'hero_train'
}

return {
    logic_tab = logic_tab,
    job_tab = job_tab,
    all_data_mod = all_data_mod
}
