module("LoginData", package.seeall)
require "script/model/DataCache"
require "script/network/HttpClient"

require "script/network/WebSocketClient"

local function init( ... )
    -- body
end

function destroy(...)
    package.loaded["LoginData"] = nil
end

function moduleName()
    return "LoginData"
end

function createCards( ... )
   -- local ret = DataCache.createCards()
  --  LayerManager.removeLoading()
    --LayerManager.removeLayout()
     HttpClient.setFalse()
    require "script/module/mainTips/MainTipsCtrl"
    local tips = MainTipsCtrl.create() 
    LayerManager.changeModule(tips, MainTipsCtrl.moduleName(), {1}, true) 
end

function ruleInfo( ... )
    HttpClient.get(function ( sender, res)
            require "script/model/DataCache"
            local cjson = require "cjson" 
            local jsonInfo = cjson.decode(res:getResponseData())  
             DataCache.setRules(jsonInfo)
           
            require "script/module/fighting/FightingData"
            local cjson = require "cjson"
            local testData = FightingData.xulian()
            
            WebSocketClient.rpc(function ( ret )
               -- local a = cjson.encode(ret) 
                local check = ret["ret"]
                local tbData = ret["data"]
                if tbData ~= nil and tbData["groupId"] ~= nil then
                     FightingData.setGroupId(tbData["groupId"])
                    FightingData.setXulian(ret)
                   
                    require "script/module/fighting/MainFightingCtrl"
                    local fight = MainFightingCtrl.create()
                    LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                else
                    FightingData.setXulian(nil)
                    createCards()
                end
            end,"start",testData)

             
        end,"ref/get_refresh_info","1")
end
function loginUserInfo( ... )
      HttpClient.get(function ( sender, res)
            local cjson = require "cjson"
            local jsonInfo = cjson.decode(res:getResponseData()) 
          
            DataCache.setUserInfo(jsonInfo)
            ruleInfo()
        end,"users/user_info",1)
end
function loginUserData( username,password )
            local cjson = require "cjson"
            local postDataTable = {}
            postDataTable["userName"] = username
            postDataTable["userPwd"] = password
        
            local postData =  cjson.encode(postDataTable)
            HttpClient.post(function ( sender, res)
               
             local cjson = require "cjson"
                   
                    local jsonInfo = cjson.decode(res:getResponseData())
                    if(jsonInfo.code == 0) then 
                        print("adfds" .. res:getResponseData())
                        CCUserDefault:sharedUserDefault():setStringForKey("username", username)
                        CCUserDefault:sharedUserDefault():setStringForKey("password", password)
                        DataCache.setUserInfo(jsonInfo.user)
                        ruleInfo() 
                    else
                        -- local alert = UIHelper.createCommonDlg("登陆失败",nil,nil,1,nil)
                        -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                        ShowNotice.showShellInfo("登陆失败")
                        LayerManager.removeLoading()
                    end    
            end,"users/login",postData,1)
end