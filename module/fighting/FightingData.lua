module("FightingData", package.seeall)
require "script/model/DataCache"
 _ret = {}
 _huResult = {}
 _xulian = {}
local function init(...)

end
_isReady = false
local userId = DataCache.getUserInfo().userId
local cjson = require "cjson"
local roomType = 3
_groupId = nil
_password = nil

function destroy(...)
    package.loaded["FightingData"] = nil
end

function moduleName()
    return "FightingData"
end
function getIsReady( ... )
    return _isReady
end
function setIsReady( isReady )
    _isReady = isReady
end
function getHuResult( ... )
    return _huResult
end
function setHuResult( huResult )
    _huResult =  huResult
end
function getPw( ... )
   return _password
end
function setPw( pw )
   _password = pw
end
function getRet( ... )
    return _ret
end
function setRet( ret )
     _ret = ret
end
function setGroupId( groupId )
    _groupId = groupId
end
function getGroupId(  )
    if _groupId == nil then
        _groupId = ""
    end
    return _groupId  
end
function getXulian( ... )
    return _xulian
end
function setXulian( xulian )
    _xulian = xulian
end
function xulian(   )
    local content = {}
    content["userId"] = userId
    content["commandType"] = 930
    local jsonStr = cjson.encode(content);
    return jsonStr
end
function byebye(   )
    local content = {}
    content["userId"] = userId
    content["commandType"] = 910
    local intDatas = {} 
    intDatas["groupId"] = _groupId
    content["content"] = intDatas
    local jsonStr = cjson.encode(content);
    return jsonStr
end
function ready(   )
    local content = {}
    content["userId"] = userId
    content["commandType"] = 950
    local intDatas = {} 
    intDatas["groupId"] = _groupId
    content["content"] = intDatas
    local jsonStr = cjson.encode(content);
    return jsonStr
end
--将json数据转换成 table类型
-- local sampleJson = [[{"age":"23","testArray":{"array":[8,9,11,14,25]},"Himi":"himigame.com"}]];
-- local data = cjson.decode(sampleJson);
-- --打印json字符串中的age字段
-- print(data["age"]);
-- --打印数组中的第一个值(lua默认是从0开始计数)
-- print(data["testArray"]["array"][1]);   富文本
function deCodeJson(jsonStr)
    return cjson.decode(jsonStr);
end
 
--吃牌 type =102 operateCards [1,2,3,4]
--碰牌 type =103 operateCards [1,2,3,4]
--杠牌 type =104 operateCards [1,2,3,4]
--听牌 type =105 operateCards nil
--吃听 type =106 operateCards nil
--碰听 type =107 operateCards nil
--听打 type =108 operateCards nil 
--胡牌 type =206 operateCards nil
--过牌 type =207 operateCards nil
function operationCard( commandType,operateCards )
    local intDatas = {} 
    intDatas["commandType"] = commandType 
    intDatas["userId"] = userId
    local content = {}
    content["groupId"] = _groupId 
    if operateCards then
        content["operateCards"] = operateCards 
    end
    intDatas["content"] = content
    local jsonStr = cjson.encode(intDatas);
    return jsonStr
end

function gameMessage( message )
    local content = {}
    local sendMessageText = {}
    sendMessageText["userId"] = userId
    sendMessageText["commandType"] = 940 
    content["msg"] = message
    sendMessageText["content"] = content 
    local jsonStr = cjson.encode(sendMessageText);
    return jsonStr
end
--创建房间
--playRounds打几圈 tranditional玩法，true or  false  ,playRuleIds 是个数组，可不传
function gameBegining(  playRounds,password,tranditional,playRuleIds )
    local content = {}
    if playRuleIds == nil then
        playRuleIds={}
        playRuleIds[1]=-1 
    end  
    content["playRounds"] = playRounds 
    content["tranditional"] = tranditional
    content["playRuleIds"] = playRuleIds
    content["password"] = password
         
    local sendBeginText = {}
    local intDatas = {}
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 900 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--加入房间
function joinGame(  password )
    local sendBeginText = {}
    local content = {}
    local intDatas = {}
    content["roomType"] = roomType 
    content["groupId"] = _groupId 
    content["password"] = password
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 901 
    sendBeginText["content"] = content
    
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--開局請求
function beginGame()
    local sendBeginText = {}
    local intDatas = {}
    local content = {}
    content["groupId"] = _groupId 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 902 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--抓牌請求
function getOne()
    local sendBeginText = {} 
    local content = {}
    content["groupId"] = _groupId 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 100 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
function sendTingDaOne(operateCards)
    local sendBeginText = {} 
    local content = {}
    content["groupId"] = _groupId 
    content["operateCards"] = operateCards 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 108 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--打牌請求 operateCards 打的什么牌 是个数组 传入方式 类似 与 operateCards{}  operateCards[1]="要打的牌" ，operateCards【2】要打的牌
function sendOne(operateCards)
    local sendBeginText = {} 
    local content = {}
    content["groupId"] = _groupId 
    content["operateCards"] = operateCards 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 101 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--吃牌请求
function eatOne(operateCards)
     local sendBeginText = {}
    local content = {}
    content["groupId"] = _groupId 
    content["operateCards"] = operateCards 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 102 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--吃牌请求
function eatTingOne(operateCards)
     local sendBeginText = {}
    local content = {}
    content["groupId"] = _groupId 
    content["operateCards"] = operateCards 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 106 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--听牌请求
function listenOne(operateCards)
    local sendBeginText = {} 
    local content = {}
    content["groupId"] = _groupId 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 105 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
--胡牌请求
function finally()
    local sendBeginText = {} 
    local content = {}
    content["groupId"] = _groupId 
    sendBeginText["userId"] = userId
    sendBeginText["commandType"] = 106 
    sendBeginText["content"] = content 
    local jsonStr = cjson.encode(sendBeginText);
    return jsonStr
end
function tranferCodeToWord(pos)
    if tonumber(pos) == 2 then
        return "西"
    elseif tonumber(pos) == 0 then
        return "东"
    elseif tonumber(pos) == 1 then
        return "南"
    else
        return "北"
    end
end
function utils( myCards )
 
    local hasCards = {}
    for i=1,#myCards do
       if(myCards[i] ~= 0) then
            if myCards[i] == 1 then
                table.insert(hasCards,i-1)
            else
                for j=1,tonumber(myCards[i])  do
                    table.insert(hasCards,i-1)
                end
            end
       end
    end
    return hasCards
end