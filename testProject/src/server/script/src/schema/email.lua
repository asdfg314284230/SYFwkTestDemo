return {
    base = {},
    data = {
        personal = {
            pk = {"id"}, -- id为时间戳拼接 23232332#1
            col = {
                title = {"", SCHEMA_TYPE.STRING, "邮件标题"},
                info = {"",SCHEMA_TYPE.STRING,"邮件简介"},
                icon = {"",SCHEMA_TYPE.STRING,"邮件icon"},
                content = {"", SCHEMA_TYPE.STRING, "邮件正文"},
                attach = {nil, SCHEMA_TYPE.STRING_BIG, "邮件附件"},
                send_time = {0, SCHEMA_TYPE.INT, "发送时间"},
                expire_time = {0, SCHEMA_TYPE.INT, "过期时间"},
                type = {1, SCHEMA_TYPE.INT, "邮件类型"},
                from_type = {1, SCHEMA_TYPE.INT, "邮件发送方"},
                state = {"", SCHEMA_TYPE.STRING, "邮件状态"}, -- 未读 unread；已读 read；已领取：get
            },
        },
    }
}
