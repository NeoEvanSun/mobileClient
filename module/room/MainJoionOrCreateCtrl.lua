module("MainJoionOrCreateCtrl", package.seeall)
require "script/module/room/MainJoionOrCreateView"
require "script/network/WebSocketClient"
require "script/module/config/AudioHelper"
require "script/module/public/ShowNotice"
-- 按钮事件
local tbBtnEvent = {}
local m_layMain 
local function init(...)

end

function destroy(...)
    package.loaded["MainJoionOrCreateCtrl"] = nil
end

function moduleName()
    return "MainJoionOrCreateCtrl"
end
function confirmJoionRoom( ... )

     
end
tbBtnEvent.join = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCommonEffect()
        local roomCode = MainJoionOrCreateView.getInputText()
        local roomPw = MainJoionOrCreateView.getPassWText()
        print("roomCode-"..roomCode)
        print("roomPw-"..roomPw)
        if roomCode == nil or roomCode == "" then
            -- local alert = UIHelper.createCommonDlg("请输入房间号码",nil,nil,1,nil)
            -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
             ShowNotice.showShellInfo("请输入房间号码")

        elseif roomPw == nil or roomPw == "" then
            -- local alert = UIHelper.createCommonDlg("请输入房间密码",nil,nil,1,nil)
            -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            ShowNotice.showShellInfo("请输入房间密码")

        else
            require "script/module/fighting/FightingData"
            FightingData.setGroupId(roomCode)
            FightingData.setPw(roomPw)
            local joinData = FightingData.joinGame(roomPw)
            require "script/module/fighting/MainFightingCtrl"
                    local fight = MainFightingCtrl.create()
                    LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
               -- else
            -- WebSocketClient.rpc(function ( ret )
            --     local check = ret["ret"]
            --     if check then
            --      FightingData.setRet
            --         require "script/module/fighting/MainFightingCtrl"
            --         local fight = MainFightingCtrl.create()
            --         LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
            --     else
            --         -- local alert = UIHelper.createCommonDlg("加入房间失败",nil,nil,1,nil)
            --         -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            --         ShowNotice.showShellInfo("加入房间失败")

            --     end
            -- end,"join",joinData)
            -- print("jsonStr" .. joinData)
            -- WebSocketClient.request(joinData,function ( ret )
            --     local check = ret["ret"]
            --     if check then
            --         FightingData.setRet(ret)
            --         require "script/module/fighting/MainFightingCtrl"
            --         local fight = MainFightingCtrl.create()
            --         LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
            --     else
            --         -- local alert = UIHelper.createCommonDlg("加入房间失败",nil,nil,1,nil)
            --         -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            --         ShowNotice.showShellInfo("加入房间失败")

            --     end
            -- end)
        end
    end
end
 
tbBtnEvent.close = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        -- require "script/module/mainTips/MainTipsCtrl"
        -- MainTipsCtrl.removeFromParent()
       --  m_layMain:removeFromParentAndCleanup(true)
       AudioHelper.playCloseEffect()
       LayerManager.removeLayout()
    end
end
tbBtnEvent.createroom = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCommonEffect()
        LayerManager.removeLayout()
        require "script/module/room/MainCreatRoomCtrl"
         MainCreatRoomCtrl.create()
         
    end
end
function create( ... ) 

    m_layMain =  MainJoionOrCreateView.create(tbBtnEvent)

    return m_layMain
end