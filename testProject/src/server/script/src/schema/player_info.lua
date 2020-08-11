return {
    base = {
        personalized_signature = {"请输入个性签名",SCHEMA_TYPE.STRING, "玩家个性签名"},
        current_icon_id = {1,SCHEMA_TYPE.INT, "当前头像位置"},
        current_icon_frame_id = {1,SCHEMA_TYPE.INT, "当前头像框位置"},
    },
    data = {
        --头像列表 _id为存放头像的路径
       icon = {
           col = {
            _id = {"unknow", SCHEMA_TYPE.STRING, "头像id"},
           }
       },
        --头像框列表 _id为存放头像框的路径
        icon_frame = {
            col = {
             _id = {"unknow", SCHEMA_TYPE.STRING, "头像框id"},
            }
        },
        -- 整容信息 _id为存放为英雄id
        lineup = {
            col = {
                hero_id = {"0", SCHEMA_TYPE.STRING, "阵容"},
            }
        }
    },
}