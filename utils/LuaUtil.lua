
-- Filename：	LuaUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-5-17
-- Purpose：		Lua的通用工具方法


-- zhangqi, 2015-03-31, ExceptionCollect 用到
function io.writefile(path, content, mode)
    mode = mode or "w+b"
    if(content==nil) then
        return false
    end
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end
-- zhangqi, 2015-03-31
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end
-- zhangqi, 2015-03-31
function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

-- 打印出tbl的所有(key, value)
-- 该函数主要功能是自动计算缩进层次打印出table内容
-- added by fang. 2013-05-30

local tab_indent_count = 0
function print_table (tname, tbl)
    if not g_debug_mode then
        return
    end
    if (tname == nil or tbl == nil) then
        print ("Error, in LuaUtil.lua file. You must pass \"table name\" and \"table`s data\" to print_table function.")
        return
    end
    local tabs = ""
    for i = 1, tab_indent_count do
        tabs = tabs .. "    "
    end
    local param_type = type(tbl)
    if param_type == "table" then
        for k, v in pairs(tbl) do
            -- 如果value还是一个table，则递归打印其内容
            if (type(v) == "table") then
                print (string.format("T %s.%s", tabs, k))
                -- 子table加一个tab缩进
                tab_indent_count = tab_indent_count + 1
                print_table (k, v)
                -- table结束，则退回一个缩进
                tab_indent_count = tab_indent_count - 1
            elseif (type(v) == "number") then
                print (string.format("N %s.%s: %d", tabs, k, v))
            elseif (type(v) == "string") then
                print (string.format("S %s.%s: \"%s\"", tabs, k, v))
            elseif (type(v) == "boolean") then
                print (string.format("B %s.%s: %s", tabs, k, tostring(v)))
            elseif (type(v) == "nil") then
                print (string.format("N %s.%s: nil", tabs, k))
            else 
                print (string.format("%s%s=%s: unexpected type value? type is %s", tabs, k, v, type(v)))
            end
        end
    end
end

---------------------------------------- table 方法 ---------------------------------------
-- added by fang. 2013.07.12
-- 增加一个表硬拷贝函数，把t_data表里的数据拷到t_dest中
-- 目的：确保数据拷贝成功（硬拷贝），防止函数返回指针，在指针引用计数为零时lua变量指向野指针引起异常
-- 建议：不建议使用，理论上是不应该出现这种问题的，由于组内个别成员提出了可能有这种灵异事件，因此写个函数确保，也可以测试。
---         有谁发现确实有这种情况，请告诉我一下。
-- @params, t_data: 数据表，t_dest：目标数据表
-- @return, 调用者可不接收返回值
table.hcopy = function(t_data, t_dest)
    if (type(t_dest) ~= "table") then
        print ("Error, t_dest table must be table type.")
        return nil
    end
    local mt = getmetatable(t_data)
    if mt then
        setmetatable(t_dest, mt)
    end
    for k, v in pairs(t_data) do
        if (type(v) == "table") then
            t_dest[k] = {}
            table.hcopy(v, t_dest[k])
        else
            t_dest[k] = v
        end
    end
    return t_dest
end

-- 判断一个table是否为空 是 nil 或者 长度为0 （非table 返回 true）
table.isEmpty = function (t_data)
    return (type(t_data) ~= "table") or (_G.next(t_data) == nil)
end

-- 获得所有的key
table.allKeys = function ( t_table )
    local tmplTable = {}
    if( not table.isEmpty(t_table)) then
        for k,v in pairs(t_table) do
            
            table.insert(tmplTable, k)
        end
    end

    return tmplTable
end

--得到table中所有元素的个数
-- added by lichengyang on 2013-08-13
table.count = function ( t_table )
    if type(t_table) ~= "table" then
        return 0
    end
    local tNum = 0
    for k,v in pairs(t_table) do
        tNum = tNum + 1
    end
    return tNum
end
-- added by fang. 2013.08.20
-- 颠倒一个数组类型的table
table.reverse = function (tArray)
    if tArray == nil or #tArray == 0 then
        return nil
    end
    local tArrayReversed = {}
    local nArrCount = #tArray
    for i=1, nArrCount do
        tArrayReversed[i] = tArray[nArrCount-i+1]
    end

    return tArrayReversed
end

--add by lichenyang
--把一个table序列号成一个字符串
table.serialize = function(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{\n"
    for k, v in pairs(obj) do
        lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
    end
    local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
        for k, v in pairs(metatable.__index) do
            lua = lua .. "[" .. table.serialize(k) .. "]=" .. table.serialize(v) .. ",\n"
        end
    end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end

--add by lichenyang
--把一个序列化的字符串转换成一个lua table 此方法和table.serialize对应
table.unserialize = function (lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

--[[desc: 检测一个table是否包含另一个table(全集和子集的关系), zhangqi, 2014-04-12
    tbParent: 全集 table
    tbChild: 子集 table 或是一个非table类型的元素
    return: true, 包含; false, 不包含  
—]]
table.include = function (tbParent, tbChild)
    if (type(tbChild) ~= "table") then
        for k, v in pairs(tbParent) do
            if (v == tbChild) then
                return true
            end
        end
        return false
    end

    local boolSet = {}
    for _, v in ipairs(tbParent) do
        boolSet[v] = true
    end

    for _, v in ipairs(tbChild) do
        if (not boolSet[v]) then
            return false
        end
    end
    return true
end

-- zhangqi, 2015-03-31
table.tostring = function (t)
    local mark={}
    local assign={}
    local function ser_table(tbl,parent)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and ""..k.."" or "".. string.format("%q", k) ..""
            if type(v)=="table" then
                local dotkey= parent.. key
                if mark[v] then
                    table.insert(assign,dotkey.."="..mark[v] )
                else
                    table.insert(tmp, key.."="..ser_table(v,dotkey))
                end
            elseif type(v) == "string" then
                table.insert(tmp, key.."=".. string.format('%q', v))
            elseif type(v) == "number" or type(v) == "boolean" then
                table.insert(tmp, key.."=".. tostring(v))
            end
        end
      return "{"..table.concat(tmp,",").."}"
    end
    return ""..ser_table(t,"ret")..table.concat(assign," ")..""

   -- return "do local ret="..ser_table(t,"ret")..table.concat(assign," ").." return ret end"
end
table.tostringArray = function (t)
    local mark={}
    local assign={}
    local function ser_table(tbl,parent)
        mark[tbl]=parent
        local tmp={}
        for k,v in pairs(tbl) do
            local key= type(k)=="number" and ""..k.."" or "".. string.format("%q", k) ..""
            if type(v)=="table" then
                local dotkey= parent.. key
                if mark[v] then
                    table.insert(assign,dotkey.."="..mark[v] )
                else
                    table.insert(tmp, key.."="..ser_table(v,dotkey))
                end
            elseif type(v) == "string" then
                table.insert(tmp, key.."=".. v)
            elseif type(v) == "number" or type(v) == "boolean" then
                table.insert(tmp, key.."=".. tostring(v))
            end
        end
      return ""..table.concat(tmp,",")..""
    end
    return ""..ser_table(t,"ret")..table.concat(assign," ")..""

   -- return "do local ret="..ser_table(t,"ret")..table.concat(assign," ").." return ret end"
end

table.loadstring = function (strData)
    local f = loadstring(strData)
    if f then
       return f()
    end
end

-----------------------------------string 类方法增加-----------------------------

-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function lua_string_split(str, split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + 1, #str)
    end
    return sub_str_tab
end
-- 按split_char分割字符串str
-- added by fang. 2013.07.17
string.split = function (str, split_char)
    return string.strsplit(str, split_char)
end
-- 按splitByChar分割字符串str
-- added by fang. 2013.10.14
string.splitByChar = function (str, char)
    local sub_str_tab = {}

    local lastPos=1

    local bLeft = false 
    for i=1, #str do
        local curChar = string.char(string.byte(str, i))
        if curChar == char then
            local size = #sub_str_tab
            sub_str_tab[size+1] = string.sub(str, lastPos, i-1)
            lastPos = i+1
            bLeft = false 
        else
            bLeft = true
        end
    end
    if bLeft then
       local size = #sub_str_tab
       sub_str_tab[size+1] = string.sub(str, lastPos)
    end
        
    return sub_str_tab
end

function file_exists(path)
    --print("file_exists:",path)
    --[[
    local realPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    local file = io.open(realPath, "rb")
    if file then file:close() end
    return file ~= nil
     --]]
    
    local realPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
    print("realPath:",realPath)
    if(realPath==path)then
        return false
    else
        return true
    end
    --return CCFileUtils:sharedFileUtils():isFileExist(path)
end


-- 判断一个字符串是否是整型数字
string.isIntergerByStr = function ( m_str )
    print("m_str===",m_str)
    if(type(m_str) ~= "string")then
        return false
    end

    local isInterger = true
    for i=1,string.len(m_str) do
        local char_num =  string.byte(m_str, i)
        print("char_num===",char_num, type(char_num))
        if(char_num<48 or char_num>57)then
            print("char_num<0 or char_num>9char_num<0 or char_num>9")
            isInterger = false
            break
        end
    end

    return isInterger
end

-- zhangqi, 2014-04-13, 返回分割后的字符串table
string.strsplit = function (str, delim)
    if (not str) then
        return {}
    end
    
    local delStr = "[^" .. delim .."]+"
    local tbStr = {}
    for str in string.gmatch(str, delStr) do
        table.insert(tbStr, str)
    end
    return tbStr
end


---打印tab结构 lichenyang
function print_t(sth)
    if not g_debug_mode then
        return
    end
    if type(sth) ~= "table" then
        print(sth)
        return
    end

    local temp = {}
    local space, deep = string.rep(' ', 4), 0
    local function _dump(t)
        for k,v in pairs(t) do
            local key = tostring(k)

            if type(v) == "table" then
                deep = deep + 1
                table.insert(temp, string.format("\n%s[%s] => Table\n%s(", string.rep(space, deep - 1), key, string.rep(space, deep - 1)))

                _dump(v)

                table.insert(temp, string.format("\n%s)",string.rep(space, deep - 1)))
                deep = deep - 1
            else
                table.insert(temp, string.format("\n%s[%s] => %s", string.rep(space, deep), key, tostring(v)))
            end 
        end
    end
    _dump(sth)
    print(table.concat(temp))
end

-----------------------------------其他类方法增加-----------------------------

-- zhangqi, 2015-03-03, 参考三国代码
-- 返回 str 的字符个数，chAs2:1个汉字按2个字符长度计算；strLen:1个汉字和1个英文字母都按1个字符算
function getStringLength( str )
    local strLen = 0
    local chAs2 = 0 -- 记录1个汉字作为2个字符的字符长度
    local i =1
    while i <= #str do
        if (string.byte(str,i) > 127) then
            -- 汉字
            strLen = strLen + 1
            chAs2 = chAs2 + 2
            i = i + 3
        else
            i = i + 1
            strLen = strLen + 1
            chAs2 = chAs2 + 1
        end
    end
    return chAs2, strLen
end

-- zhangqi, 2015-03-04, 去掉字符串str尾部的\0，主要用于玩家名称Base64解码后的处理
function sliceEndFlag( str )
    local i = 1
    while i <= string.len(str) do
        if (string.byte(str, i) == 0) then
            break
        end
        -- logger:debug("ascii = %d, char = %s",string.byte(str, i), string.char(string.byte(str, i)))
        i = i + 1
    end

    -- logger:debug(" i = %d, str = %s", i, string.sub(str, 1, i - 1))

    return string.sub(str, 1, i - 1)
end

--CCArray 迭代器，zhangqi, 20140324
function array_iter(array)
    local i = -1
    local ccArr = tolua.cast(array, "CCArray")
    local count = ccArr:count()

    return function()
        i = i + 1
        if (i < count) then
            return ccArr:objectAtIndex(i), i
        else
            return nil
        end
    end
end

--[[desc: 根据分子分母得出一个2位的百分比整数, 向下取整。例如 (1, 3) 返回 33
    nMember: 分子
    nDenominator: 分母
    return: 整数  
—]]
function intPercent( nMember, nDenominator )
    return math.floor(nMember/nDenominator*100)
end

--[[desc: 根据传入的十进制数据获取其n位的二进制数据，例如传入num为7，n为3则返回 table的内容为111，因程序中的编号需求故保留倒序排列
    num: 传入的十进制数
    n: 要获取的二进制位数
    return: 表 
--]]
function i2bit( num,n )
    local tn = {}
    local iv = num
    for i=1,n do
        table.insert(tn, iv % 2)
        iv = math.floor(iv / 2)
    end
    -- table.reverse(tn) 
    return tn 
end

--[[desc: 根据传入的二进制数据获取其十进制数据,传入的为倒序的二进制table序列
    tbData: 传入的二进制位数
    return: num十进制数字 
--]]
function bit2i( tbData )
    local num = 0
    if (tbData ~= nil) then
        for k,v in pairs(tbData) do
            num = num + v * math.pow(2,k-1)
        end
    end
    return num 
end

---获取utf8编码字符串正确长度的方法
-- @param str
-- @return number length
function utfstrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i
                break
            end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end

--[[desc: 跟踪一个table的访问, 可以在table的查找和修改时输出log
    tbOrig: 需要跟踪的table
    return: 
—]]
local track_index = {}
local track_mt = {
    __index = function (t, k)
        print("*access to element ", tostring(k))
        print_t(t[track_index])
        return t[track_index][k]
    end,

    __newindex = function ( t, k, v )
        print("*update of element ", tostring(k), " to ", tostring(v))
        t[track_index][k] = v
        print(debug.traceback)
    end
}
function track( tbOrig )
    local proxy = {}
    proxy[track_index] = tbOrig
    setmetatable(proxy, track_mt)
    return proxy
end
