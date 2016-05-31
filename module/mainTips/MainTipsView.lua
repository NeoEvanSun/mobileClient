
module("MainTipsView", package.seeall)
require "script/module/config/AudioHelper"
require "script/model/DataCache"
require "script/network/WebSocketClient"
require "script/module/fighting/FightingData"
-- 资源文件setAnchorPoint
local activity_list = "n_ui/funtiontips_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local stayTime = 0.1
local isUp = 11 --值是1 则为往上滑动 为 0 则是往下滑动
local function init( ... )
    -- body
end

function destroy(...)
    package.loaded["MainTipsView"] = nil
end

function moduleName()
    return "MainTipsView"
end
--得到其坐标
function getProcessPos( layout ) 
    local parentNode = layout:getParent() 
    return ccp(layout:getPositionX(),layout:getPositionY())
   -- return parentNode:convertToWorldSpace(ccp(layout:getPositionX(),layout:getPositionY()))
end
-- sender 跑到lay的坐标上去， sender 为中间的那个
-- lay 跑到 lay2 上面去 -- lay 为上面那个
-- lay1 跑到sender 上面去-- 下面那个 setZOrder
function moveToPostion( sender,lay,lay1 )
    local layPos =  getProcessPos(lay)
    local lay1Pos =  getProcessPos(lay1)
    local senderPos = getProcessPos(sender)
    local blinkArray = CCArray:create()
    local senderZ = sender:getZOrder()
    local size = sender:getSize()
    sender:setZOrder(lay1:getZOrder())
    lay:setZOrder(lay1:getZOrder())
    lay1:setZOrder(senderZ)
    --sender:setSize(CCSizeMake(lay1:getSize().width  ,lay1:getSize().height) ) 
    sender:setScale(1.2)
    lay:setScale(1)
   -- lay:setScale(-1.3)
    -- sender:setZOrder(senderZ)
    -- lay:setZOrder(senderZ)
    -- lay1:setZOrder(lay1:getZOrder())
    blinkArray:addObject(CCMoveTo:create(stayTime ,layPos))
  -- blinkArray:addObject(CCCallFunc:create(funCallfunc))
    local   actionBig = CCSequence:create(blinkArray)
    --sender:runAction(CCRepeatForever:create(actionBig)) ccTouchMoved
    sender:runAction(actionBig)
    local blinkArray1 = CCArray:create()
    blinkArray1:addObject(CCMoveTo:create(stayTime,lay1Pos))
  -- blinkArray:addObject(CCCallFunc:create(funCallfunc))
    local   actionBig1 = CCSequence:create(blinkArray1)
    --sender:runAction(CCRepeatForever:create(actionBig)) ccTouchMoved
    lay:runAction(actionBig1)

    local blinkArray2 = CCArray:create()
    blinkArray2:addObject(CCMoveTo:create(stayTime,senderPos))
  -- blinkArray:addObject(CCCallFunc:create(funCallfunc))
    local   actionBig2 = CCSequence:create(blinkArray2)
    --sender:runAction(CCRepeatForever:create(actionBig)) ccTouchMoved
    lay1:runAction(actionBig2)


end
---return 顺序为 中间应该放的是第一个返回值，上面那个是第二个返回值
function getTagUp( tag )
    if tonumber(tag) == 3 then
        return 3,2,1 
    elseif tonumber(tag) == 2 then
        return 3,1,2
    else  --1
        return 3,1,2
    end
    -- body
end
function getTagBottom( tag )
    if tonumber(tag) == 1 then
       return 2,3,1
    elseif tonumber(tag) == 2 then
        return 2,3,1
    else  --1
        return 2,3,1
    end
    -- body
end

--三个东东，第一个参数中间那个，第二个参数 上面那个，第三个参数
-- 下面那个
-- 往上滑 到中间显示的顺序为 1 2 3  1 23
-- 往下滑动，顺序为  3 2 1 getIsDirect
function huadong(layBack, layOne,layTwo,layThree )
    layOne:setScale(1.2)
    layOne:setTag(1)
    layOne:setName("cj")
    layTwo:setName("zj")
    layThree:setName("vip")
    layTwo:setTag(2)
    layThree:setTag(3)
    local centen  
    local function onMove( sender, eventType )
      
        local oldPosition = getProcessPos(sender)
        if (eventType == TOUCH_EVENT_BEGAN) then
            AudioHelper.playMainUIEffect()
            oldPosition = getProcessPos(sender) 
            return true
        end
        if (eventType == TOUCH_EVENT_MOVED) then
            
        end
        
        if (eventType == TOUCH_EVENT_ENDED) then
            isUp = LayerManager.getIsDirect()
            
            local y = getProcessPos(sender).y 
                local tag = layOne:getTag()
                local bettow , up,down
                if tonumber(isUp) == 1 then --向上
                    bettow , up,down  = getTagUp(tag)
                    centen = layBack:getChildByTag(bettow)
	                local layUp = layBack:getChildByTag(up)
	                local layDown = layBack:getChildByTag(down)
	                moveToPostion(centen,layUp,layDown)
	                centen:setTag(1)
	                layUp:setTag(2)
	                layDown:setTag(3)
	                centen:setZOrder(1000)
	                layUp:setZOrder(0)
	                layDown:setZOrder(0) 
	                layOne = centen
                elseif tonumber(isUp) ==2 then
                    bettow , up,down  = getTagBottom(tag)
                    centen = layBack:getChildByTag(bettow)
	                local layUp = layBack:getChildByTag(up)
	                local layDown = layBack:getChildByTag(down)
	                moveToPostion(centen,layDown,layUp)
	                centen:setTag(1)
	                layUp:setTag(2)
	                layDown:setTag(3)
	                centen:setZOrder(1000)
	                layUp:setZOrder(0)
	                layDown:setZOrder(0) 
	                layOne = centen
                elseif tonumber(isUp) ==0 then
                    if(centen~=nil and centen:getName() == "vip") then
                        -- require "script/module/room/MainCreatRoomCtrl"
                        -- local layout = MainCreatRoomCtrl.create()
                        -- MainTipsCtrl.addLayChild(layout)
                        require "script/module/room/MainJoionOrCreateCtrl"
                        local layout = MainJoionOrCreateCtrl.create()
                        LayerManager.addLayout(layout,nil,g_tbTouchPriority.popDlg)
                        return false
                    elseif (centen~=nil and centen:getName() == "zj") then 
                        require "script/module/fighting/MainFightingCtrl"
                        FightingData._groupId = nil
                         FightingData.roomType = 1
                          require "script/module/public/ShowNotice"
                       ShowNotice.showShellInfo("中级房")
                        local fight = MainFightingCtrl.create()
                        LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                     elseif (centen~=nil and centen:getName() == "cj") then
                        require "script/module/fighting/MainFightingCtrl"
                         require "script/module/public/ShowNotice"
                       ShowNotice.showShellInfo("初级房")
                        FightingData._groupId = nil
                         FightingData.roomType = 0
                        local fight = MainFightingCtrl.create()
                        LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                    
                       --  require "script/module/public/ShowNotice"
                       -- ShowNotice.showShellInfo("功能尚未开启")
                    end
                    
                    -- require "script/module/fighting/MainFightingCtrl"
                    -- local fight = MainFightingCtrl.create()
                    -- LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
                    
                    return false
                else

                end
                
        end
    end
 
    
    layBack:addTouchEventListener(onMove)
    layOne:addTouchEventListener(onMove)
    layTwo:addTouchEventListener(onMove)
    layThree:addTouchEventListener(onMove)
end

-- 显示登陆场景
function create()
    AudioHelper.playMainMusic()
    local  layBack = g_fnLoadUI(activity_list)
    local  layBackChoose = m_fnGetWidget(layBack,"lay_huadong")
    local  imgOne  = m_fnGetWidget(layBack,"img_one")
    local  imgTwo  = m_fnGetWidget(layBack,"img_two")
    local  imgThree= m_fnGetWidget(layBack,"img_three")
    local  labName= m_fnGetWidget(layBack,"tfd_name")
    local  tfdSecond=m_fnGetWidget(layBack,"tfd_second")
    local  tfdThird=m_fnGetWidget(layBack,"tfd_third")
    local  tfdFour=m_fnGetWidget(layBack,"tfd_four")
    local  btnShop=m_fnGetWidget(layBack,"btn_note")
    local  btnMail=m_fnGetWidget(layBack,"btn_mail")
    local  btnSetting =m_fnGetWidget(layBack,"btn_setting")
    if DataCache.getUserInfo().userId then
        labName:setText(DataCache.getUserInfo().userName)
    end
    labName:setFontName(g_sFontName)
    tfdSecond:setText("房卡×" .. DataCache.getUserInfo().cardNum)
    tfdSecond:setFontName(g_sFontName)
    tfdThird:setText("积分×" ..  DataCache.getUserInfo().userScore)
    tfdThird:setFontName(g_sFontName)
    tfdFour:setText("等级×" .. DataCache.getUserInfo().userLevel)
    tfdFour:setFontName(g_sFontName)
    huadong(layBackChoose,imgOne,imgTwo,imgThree)

    btnShop:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            AudioHelper.playCommonEffect()
                                            require "script/module/shop/MainShopCtrl"
                                            MainShopCtrl.create()
                                        end
                                  end)
    btnMail:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            AudioHelper.playCommonEffect()
                                            require "script/module/message/MainMessageCtrl"
                                            MainMessageCtrl.create()
                                        end
                                  end)
    btnSetting:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            AudioHelper.playCommonEffect()
                                            require "script/module/setting/MainSettingCtrl"
                                            MainSettingCtrl.create()
                                        end
                                  end)
   
    -- -- 初始化WebSocket
    -- local cjson = require "cjson"
    -- local testData = FightingData.xulian()
    
    -- WebSocketClient.rpc(function ( ret )
    --     local a = cjson.encode(ret)
    --     for i=1,10 do
    --         print(a)
    --     end
    --     local check = ret["ret"]
    --     local tbData = ret["data"]
    --     if tbData ~= nil and tbData["groupId"] ~= nil then
    --         FightingData.setXulian(ret)
    --         require "script/module/fighting/MainFightingCtrl"
    --         local fight = MainFightingCtrl.create()
    --         LayerManager.changeModule(fight, MainFightingCtrl.moduleName(), {}, true)
    --     end
    -- end,"start",testData)

    return layBack
end