return {
    base = {
        aoi_room_num = {1, SCHEMA_TYPE.INT, "技能1等级"},
        aoi_room_num_xx = {1, SCHEMA_TYPE.INT, "技能1等级"},
    },
    data = {
        room_list = {
            pk = {"id"},  --ID
            col = {
                player = {0, SCHEMA_TYPE.INT, "技能1等级"},
                player_xx = {0, SCHEMA_TYPE.INT, "技能1等级"},
            }
        }
    },
}
