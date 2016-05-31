-- Filename: WebSocketClient.lua
-- Author: lziy
-- Date: 2016-03-30
-- Purpose: 该文件用于网络调用相关模块公用处理函数

module ("WebSocketClient", package.seeall)
require "script/module/main/LayerManager"
require "script/model/DataCache"
require "script/module/main/LayerManager"
local ip  = "45.78.9.171"
local port = "8080"

local wsSendText = nil
-- m_tbRpcBack = {} -- lizy, 2015-03-17, 记录一个rpc请求是否收到返回；发出请求记为 true, 收到返回记为nil
m_lastRpcFlag = "" -- 最近发出的rpc的自定义名称
local m_bShowLoading = false ---是否显示加载的那个框框
local tm_cbFuncs = {} -- 回调方法的tabl
local retFunction
-- lua层主动创建调用网络长连接
local function connect ()
    -- wsSendText = WebSocket:create("ws://45.78.9.171:8080") 
    local socket = DataCache.getRules().socket
    if socket then
        -- ip = socket.ip
        -- port = socket.port
    else
       
        -- ip = 192.168.0.109
        -- port = 8080
    end
    wsSendText = WebSocket:create("ws://".. ip ..":".. port ) 
end

function close ()
    wsSendText:close() 
end

 --调用网络接口
--cbFunc: 回调的方法 type->lua function
--cbFlag: 回调的标识名称, 用于区别其他回调 type->string
--rpcName: 调用后端函数的名称 type->string
--args: 调用函数需要的参数  type->CCArray
--autoRelease: 调用完成后是否删除此回调方法
--return:无
function rpc( cbFunc,cbFlag ,rpcName)
    m_lastRpcFlag = cbFlag  
    -- m_tbRpcBack[cbFlag] = true -- 2016-03-17, 发出请求
    if nil == wsSendText then
        connect()
    end
    -- wsSendText = WebSocket:create("ws://45.78.9.171:8080") 
    local function wsSendTextOpen(strData)
        LayerManager.addLoading() -- lizy, 显示网络请求Loading
        print("is connected")
        print("发了消息 "..rpcName)
        wsSendText:sendTextMsg(rpcName)
        print("Send Text WS was opened.")
    end
 
    local function wsSendTextMessage(strData) 
        LayerManager.removeLoading()
        local strInfo= "response text msg: "..strData
        print("response is " .. strInfo) 
        -- m_tbRpcBack[cbFlag] = nil
        require "script/module/fighting/FightingData"
        local table
        if strData ~= "系统异常" then
            table = FightingData.deCodeJson(strData)
        end
        -- if type(cbFunc) == "function" then 
        --     print("function = ",cbFunc)
        -- end
         LayerManager.removeLoading()
        if retFunction == nil then
            cbFunc(table)
        end
        
        if retFunction ~= nil then
            retFunction(table)
        end
        
    end

    local function wsSendTextClose(strData)
        print("_wsiSendText websocket instance closed.")
        sendTextStatus = nil
        wsSendText = nil
    end

    local function wsSendTextError(strData)
        print("sendText Error was fired")
        print(strData)
    end
     
    if nil ~= wsSendText then
    print("come in")
    wsSendText:registerScriptHandler(wsSendTextOpen,kWebSocketScriptHandlerOpen)
    wsSendText:registerScriptHandler(wsSendTextMessage,kWebSocketScriptHandlerMessage)
    wsSendText:registerScriptHandler(wsSendTextClose,kWebSocketScriptHandlerClose)
    wsSendText:registerScriptHandler(wsSendTextError,kWebSocketScriptHandlerError)    
    end
end

function request( requestData, retFunc )
    print("requestData "..requestData)
    LayerManager.addLoading("等待中···")
    if wsSendText == nil then
    print("调rpc 重新连接")
       rpc(retFunc,"reConnect",requestData)
    end
    wsSendText:sendTextMsg(requestData)
    retFunction = retFunc
end