-- 登陆模块的控制器副本中的奖励宝箱有丰厚的奖励

module("MainCreatRoomCtrl", package.seeall)
require "script/module/room/MainCreatRoomView"
require "script/module/fighting/FightingData"
require "script/network/WebSocketClient"
require "script/module/public/ShowNotice"
require "script/module/config/AudioHelper"
-- 按钮事件
local tbBtnEvent = {}
 local roomPw
local m_layMain 
local function init(...)

end

function destroy(...)
    package.loaded["MainCreatRoomCtrl"] = nil
end

function moduleName()
    return "MainCreatRoomCtrl"
end
 tbBtnEvent.close = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCloseEffect()
        LayerManager.removeLayout()
       
    end
end
tbBtnEvent.sure = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
          AudioHelper.playCommonEffect()
          roomPw = MainCreatRoomView.getPassWord()
        if roomPw == nil or roomPw == "" then
            -- local alert = UIHelper.createCommonDlg("请输入房间密码",nil,nil,1,nil)
            -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            ShowNotice.showShellInfo("请输入房间密码")
        else
    		LayerManager.removeLayout()
            local array = CCArray:create()       
            local beginingData = FightingData.gameBegining(MainCreatRoomView.getMoshi(),roomPw,true)
            print("beginingData" .. beginingData)
            FightingData.setPw(roomPw)
            -- WebSocketClient.rpc(function ( ret )
            --     -- print("beginingDataRet"..ret)
            --     local check = ret["ret"]
            --     local tbData = ret["data"]
            --     FightingData._groupId = tbData["groupId"]
            --     if check then
                    -- require "script/module/fighting/MainFightingCtrl"
                    -- local fight = MainFightingCtrl.create()
                    -- LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                    -- local joinData = FightingData.joinGame("123456")
                    --     print("joinData" .. joinData)
                    --     WebSocketClient.rpc(function ( ret )
                    --         -- print("joinData"..ret)
                    --         local joinCheck = ret["ret"]
                    --         if joinCheck then
                    --             print("准备跳转了")
                    --             -- WebSocketClient.close()
                    --             require "script/module/fighting/MainFightingCtrl"
                    --             local fight = MainFightingCtrl.create()
                    --             LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                    --         end
                    --     end,"joinGame",joinData)
            --     end
            -- end,"beginin11g",beginingData)

            WebSocketClient.request(beginingData,function ( ret )
                -- body
                local check = ret["ret"]
                local tbData = ret["data"]
                FightingData._groupId = tbData["groupId"]
                if check then
                    FightingData.setPw( roomPw)
                    require "script/module/fighting/MainFightingCtrl"
                    local fight = MainFightingCtrl.create()
                    LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                end
            end)

        end
  
    end
end
function create( ... ) 
    
    MainCreatRoomView.create(tbBtnEvent)
   
    return m_layMain
end