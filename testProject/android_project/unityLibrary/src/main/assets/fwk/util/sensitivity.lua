--------------------------------------------------------------------------------------
-- DFA敏感字屏蔽算法
-- @module U.sensitivity
-- @author liu yang
-- @copyright liu yang 2018
-- @date 2018-05-16

--------------------------------------------------------------------------------------
local sensitivity = {}

--------------------------------------------------------------------------------------
--- 设置敏感字库
-- @function U.sensitivity:set_sensitivity
-- @param conf 敏感字配置
-- @local
function sensitivity:set_sensitivity(conf)
    self._conf = conf or {}
    self:createTree()
end


--------------------------------------------------------------------------------------
--- 初始化树结构
-- @function U.sensitivity:createTree
-- @local
function sensitivity:createTree()
    self.rootNode = self:createNode('R')  --根节点  
    for k, v in pairs(self._conf) do
        local chars = self:getCharArray(v.word)
        if #chars > 0 then
            self:insertNode(self.rootNode,chars,1)
        end
    end
end

--------------------------------------------------------------------------------------
--- 树节点创建
-- @function U.sensitivity:createNode
-- @local
function sensitivity:createNode(c,flag,nodes)
    local node = {}
    node.c = c or nil           --字符
    node.flag = flag or 0       --是否结束标志，0：继续，1：结尾
    node.nodes = nodes or {}    --保存子节点
    return node
end

--------------------------------------------------------------------------------------
--- 树节点创建
-- @function U.sensitivity:getCharArray
-- @local
function sensitivity:getCharArray(str)
    local array = {}
    local len = string.len(str)
    while str do
        local fontUTF = string.byte(str,1)

        if fontUTF == nil then
            break
        end

        --lua中字符占1byte,中文占3byte
        if fontUTF > 127 then 
            local tmp = string.sub(str,1,3)
            table.insert(array,tmp)
            str = string.sub(str,4,len)
        else
            local tmp = string.sub(str,1,1)
            table.insert(array,tmp)
            str = string.sub(str,2,len)
        end
    end
    return array
end

--------------------------------------------------------------------------------------
--- 插入节点
-- @function U.sensitivity:insertNode
-- @local
function sensitivity:insertNode(node,cs,index)
    local n = self:findNode(node,cs[index])
    if n == nil then
        n = self:createNode(cs[index])
        table.insert(node.nodes,n)
    end

    if index == #cs then
        n.flag = 1
    end

    index = index + 1
    if index <= #cs then
        self:insertNode(n,cs,index)
    end
end

--------------------------------------------------------------------------------------
--- 节点中查找子节点
-- @function U.sensitivity:findNode
-- @local
function sensitivity:findNode(node,c)
    local nodes = node.nodes
    local rn = nil
    for i,v in ipairs(nodes) do
        if v.c == c then
            rn = v
            break
        end
    end
    return rn
end

--------------------------------------------------------------------------------------
--- 将字符串中敏感字用*替换返回
-- @function U.sensitivity:warningStrGsub
-- @param inputStr 字符串
-- @local
function sensitivity:warningStrGsub(inputStr)
    assert(type(inputStr) == "string", "type(inputStr) ~= string !!!")
    local chars = self:getCharArray(inputStr)
    local index = 1
    local node = self.rootNode
    local word = {}

    while #chars >= index do
        --遇空格节点树停止本次遍历[习 近  平 -> ******]
        if chars[index] ~= ' ' then
            node = self:findNode(node,chars[index])
        end

        if node == nil then
            index = index - #word 
            node = self.rootNode
            word = {}
        elseif node.flag == 1 then
            table.insert(word,index)
            for i,v in ipairs(word) do
                chars[v] = '*'
            end
            node = self.rootNode
            word = {}
        else
            table.insert(word,index)
        end
        index = index + 1
    end

    local str = ''
    for i,v in ipairs(chars) do
        str = str .. v
    end

    return str
end

--------------------------------------------------------------------------------------
--- 字符串中是否含有敏感字
-- @function U.sensitivity:isWarningInPutStr
-- @param inputStr 字符串
-- @local
function sensitivity:isWarningInPutStr(inputStr)
    assert(type(inputStr) == "string", "type(inputStr) ~= string !!!")
    local chars = self:getCharArray(inputStr)
    local index = 1
    local node = self.rootNode
    local word = {}
    local sensitive_word = ""
    while #chars >= index do
        if chars[index] ~= ' ' then
            node = self:findNode(node,chars[index])
        end

        if node == nil then
            index = index - #word 
            node = self.rootNode
            word = {}
        elseif node.flag == 1 then
            table.insert(word,index)
            for i,v in ipairs(word) do
                sensitive_word = sensitive_word .. chars[v]
            end
            return true, sensitive_word
        else
            table.insert(word,index)
        end
        index = index + 1
    end

    return false
end

local export = {}

--------------------------------------------------------------------------------------
--- 设置敏感字库
-- @function U.sensitivity:set_sensitivity
-- @param conf 敏感字配置
function export:set_sensitivity(conf)
    return sensitivity:set_sensitivity(conf)
end

--------------------------------------------------------------------------------------
--- 将字符串中敏感字用*替换返回
-- @function U.sensitivity:sensitivity_str_gsub
-- @param inputStr 字符串
function export:sensitivity_str_gsub(inputStr)
    return sensitivity:warningStrGsub(inputStr)
end

--------------------------------------------------------------------------------------
--- 字符串中是否含有敏感字
-- @function U.sensitivity:is_sensitivity_input_str
-- @param inputStr 字符串
function export:is_sensitivity_input_str(inputStr)
    return sensitivity:isWarningInPutStr(inputStr)
end

return function (util)
    util.sensitivity = export
    return {}
end