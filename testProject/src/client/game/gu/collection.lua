-----------------------实现一些常用的数据结构----------------------
local mod = {}

--[[
    栈和队列的统一实现
    local my_list = mod.List.new()
    mod.List.pushHead(my_list, 1)
    mod.List.peekHead(my_list)
]]
mod.List = {}

function mod.List.new()
    local temp = {}
    local opration = {first = 1, last = 0}
    local met = {
        __index = opration,
        __newindex = function(sourceTable, k, v)
            if type(k) == "number" then
                rawset(sourceTable, k, v)
            else
                opration[k] = v
            end
        end
    }
    return setmetatable(temp, met)
end

function mod.List.pushHead(list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end

function mod.List.pushEnd(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function mod.List.peekHead(list)
    local first = list.first
    if first > list.last then
        return
    end
    return list[first]
end

function mod.List.peekEnd(list)
    local last = list.last
    if list.first > last then
        return
    end
    return list[last]
end

function mod.List.popHead(list)
    local first = list.first
    if first > list.last then
        return
    end
    local value = list[first]
    list[first] = nil
    list.first = first + 1
    return value
end

function mod.List.popEnd(list)
    local last = list.last
    if list.first > last then
        return
    end
    local value = list[last]
    list[last] = nil
    list.last = last - 1
    return value
end

function mod.List.isEmpty(list)
    if not list then
        return true
    end
    return list.first > list.last
end

function mod.List.dispose(list)
    if list then
        list = nil
    end
end

--[[
    LinkList 使用说明，当创建一个链表后，在使用结束后必须要调用dispose方法进行释放
    因为如果链表只要不为空,即便把链表置空,链表中原来的节点 会存在相互引用,节点不能被GC
    --用法
    local my_link_list = mod.LinkLlist.new()
    mod.LinkLlist.pushHead(my_link_list, {1, 2, 3})
    local value = mod.LinkLlist.peekHead(my_link_list).Value
    --用完释放
    mod.LinkLlist.dispose(my_link_list)
]]
------------------------------------双向LinkList实现-------------------------------------
mod.Note = {}
function mod.Note.new(value)
    return {PrevNote = nil, Value = value, NextNote = nil}
end

mod.LinkLlist = {}
function mod.LinkLlist.new()
    local linkList = {Head = nil, End = nil}
    return linkList
end

function mod.LinkLlist.pushEnd(list, value)
    if not list then
        return
    end

    local endNote = list.End
    local newNote = mod.Note.new(value)
    --空链表
    if not endNote then
        list.Head = newNote
        list.End = newNote
    else
        endNote.NextNote = newNote
        newNote.PrevNote = endNote
        list.End = newNote
    end
end

function mod.LinkLlist.peekHead(list)
    if mod.LinkLlist.isEmpty(list) then
        return
    end
    return list.Head.Value
end

function mod.LinkLlist.peekEnd(list)
    if mod.LinkLlist.isEmpty(list) then
        return
    end
    return list.End.Value
end

function mod.LinkLlist.pushHead(list, value)
    if not list then
        return
    end
    local newNote = mod.Note.new(value)
    local curHead = list.Head
    if not curHead then
        list.Head = newNote
        list.End = newNote
    else
        list.Head = newNote
        newNote.NextNote = curHead
        curHead.PrevNote = newNote
    end
end

function mod.LinkLlist.popHead(list)
    if not list or not list.Head then
        return
    end
    local curHead = list.Head

    local nextHead = curHead.NextNote
    if nextHead then
        nextHead.PrevNote = nil
        curHead.NextNote = nil
        list.Head = nextHead
    else
        list.Head = nil
        list.End = nil
    end

    return curHead
end

function mod.LinkLlist.popEnd(list)
    if not list or not list.End then
        return
    end

    local curEnd = list.End

    local prvEnd = curEnd.PrevNote
    if prvEnd then
        prvEnd.NextNote = nil
        curEnd.PrevNote = nil
        list.End = prvEnd
    else
        list.Head = nil
        list.End = nil
    end

    return curEnd
end

function mod.LinkLlist.insertNote(list, index, value)
    if not list or index < 0 then
        return
    end

    local listLength = mod.LinkLlist.getLength(list)
    if index == (listLength + 1) then
        mod.LinkLlist.pushEnd(list, value)
        return
    end

    local j = 1
    local curNote = list.Head
    while curNote and j < index do
        curNote = curNote.NextNote
        j = j + 1
    end
    --插入位置节点元素不存在
    if not curNote then
        return
    end

    local prevNote = curNote.PrevNote
    --在头节点插入
    if not prevNote then
        mod.LinkLlist.pushHead(list, value)
    else
        local newNote = mod.Note.new(value)
        prevNote.NextNote = newNote
        newNote.PrevNote = prevNote
        newNote.NextNote = curNote
        curNote.PrevNote = newNote
    end
end

function mod.LinkLlist.removeValue(list, value)
    if not list or not value then
        return
    end

    --如果是头节点
    if list.Head.Value == value then
        mod.LinkLlist.popHead(list)
        return
    end

    --如果是尾节点
    if list.End.Value == value then
        mod.LinkLlist.popEnd(list)
        return
    end

    --普通节点
    local curNote = list.Head
    while curNote do
        if curNote.Value == value then
            break
        end
        curNote = curNote.NextNote
    end

    --当前节点存在
    if curNote then
        local prevNote = curNote.PrevNote

        local nextNote = curNote.NextNote

        prevNote.NextNote = nextNote

        nextNote.PrevNote = prevNote

        curNote.PrevNote = nil
        curNote.NextNote = nil
    end
end

function mod.LinkLlist.getLength(list)
    local count = 0
    local curNote = list.Head
    while curNote do
        count = count + 1
        curNote = curNote.NextNote
    end
    return count
end

function mod.LinkLlist.isEmpty(list)
    if not list then
        return true
    end
    if not list.Head and not list.End then
        return true
    end
end

function mod.LinkLlist.dispose(list)
    if not list then
        return
    end
    local curNote = list.Head
    while curNote do
        curNote.PrevNote = nil
        local nextNote = curNote.NextNote
        curNote.NextNote = nil
        curNote = nextNote
    end
    list.Head = nil
    list.End = nil
end

------------------------------------双向LinkList实现-------------------------------------
return mod
