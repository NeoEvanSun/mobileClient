module("MainFightingResultCtrl", package.seeall)
require "script/module/config/AudioHelper"
require "script/module/fighting/MainFightingResultView"
require "script/network/WebSocketClient"
require "script/module/fighting/FightingData"
require "script/module/fighting/MainFightingView"
local function init(...)

end
-- 按钮事件
local tbBtnEvent = {}
function destroy(...)
    package.loaded["MainFightingResultCtrl"] = nil
end
function backToMain( ... )

    require "script/module/fighting/MainFightingCtrl"
    MainFightingView.destroy()
    MainFightingCtrl.destroy()
    require "script/module/mainTips/MainTipsCtrl"
    local tips = MainTipsCtrl.create() 
    LayerManager.changeModule(tips, MainTipsCtrl.moduleName(), {1}, true)
end
tbBtnEvent.close = function ( sender, eventType)
        if (eventType == TOUCH_EVENT_ENDED) then
            AudioHelper.playCloseEffect()
            LayerManager.removeLayout()
        end
    end
tbBtnEvent.ready = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCommonEffect()
        -- FightingData.setIsReady(true)
      --  FightingData.setIsReady(true)

        LayerManager.removeLayout()
        -- require "script/module/fighting/MainFightingCtrl"
        -- local fight = MainFightingCtrl.create()
        -- LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
        MainFightingView.ready()

        MainFightingView.ready()
        -- local fight = MainFightingCtrl.create()
        -- LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
        
    end
end
tbBtnEvent.byebye = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCloseEffect()

        WebSocketClient.request(FightingData.byebye(),function ( ret )
        
          local joinCheck = ret["ret"]
          if joinCheck then
              print("离开成功了")

            --  backToMain()
          else
            backToMain()--             ShowNotice.showShellInfo("离开失败")
          end
        end)
        backToMain()
    end
end
function moduleName()
    return "MainFightingResultCtrl"
end

function create( ... )
	-- body
	local view = MainFightingResultView.create(tbBtnEvent)
    LayerManager.addLayout(view,nil,11111111)
end
