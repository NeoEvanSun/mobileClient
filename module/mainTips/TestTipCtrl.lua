module("TestTipCtrl", package.seeall)

 
-- 资源文件setAnchorPoint
local activity_list = "n_ui/testLayout_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local stayTime = 0.1
local isUp = 1 --值是1 则为往上滑动 为 0 则是往下滑动
local function init( ... )
    -- body
end

function destroy(...)
    package.loaded["TestTipCtrl"] = nil
end

function moduleName()
    return "TestTipCtrl"
end
--相对坐标转化成世界坐标
function getProcessPos( layout ) 
    local parentNode = layout:getParent() 
   
    return parentNode:convertToWorldSpace(ccp(layout:getPositionX(),layout:getPositionY()))
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
    sender:setZOrder(lay1:getZOrder())
    lay:setZOrder(lay1:getZOrder())
    lay1:setZOrder(senderZ)
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
        return 2,1,3
    else  --1
        return 2,3,1
    end
    -- body
end
--加载触摸 用于记录当前是否向右滑动
function setTouchPropertyEvent(layBack)
    layBack:setTouchEnabled(true)
   local layer = CCLayer:create()
   layer:setTouchEnabled(true)
   local firstx,firsty=0,0
    local function onTouch(eventType, x,y)
        if eventType == "began" then
             firstx,firsty=x,y
            return true
        elseif eventType == "moved" then

        elseif eventType=="ended" then
            if (firsty-y>20) then
                isUp = 1
            else
                isUp = 0
            end
        end
    end
    print("fdsafsda" .. isUp)
    layer:registerScriptTouchHandler(onTouch,false,10000,false)
    layBack:addNode(layer)
end
--三个东东，第一个参数中间那个，第二个参数 上面那个，第三个参数
-- 下面那个
-- 往上滑 到中间显示的顺序为 1 2 3  1 23
-- 往下滑动，顺序为  3 2 1
function huadong(layBack, layOne,layTwo,layThree )
    
    layOne:setTag(1)
    layTwo:setTag(2)
    layThree:setTag(3)
    
    local function onMove( sender, eventType )
      
        local oldPosition = getProcessPos(sender)
        if (eventType == TOUCH_EVENT_BEGAN) then
            oldPosition = getProcessPos(sender)
            print("qqqqqqqq" .. oldPosition.y)
            return true
        end
        if (eventType == TOUCH_EVENT_MOVED) then
            -- local y = getProcessPos(sender).y
            -- if oldPosition.y > y then
            --     isUp = 0 
            -- else
            --     isUp = 1
            -- end
            
            -- print("wwwwwwwwwwwwww" ..  y)
        end
        
        if (eventType == TOUCH_EVENT_ENDED) then
            local y = getProcessPos(sender).y
            print("iiiiiiiii" ..  y) --zhu_dianji.plist
            --if tonumber(oldPositionY) ~= tonumber(sender:getPositionY()) then
                local tag = sender:getTag()
                local bettow , up,down
                if isUp == 1 then --向上
                    bettow , up,down  = getTagUp(tag)
                else
                    bettow , up,down  = getTagBottom(tag)
                end
                local centen = layBack:getChildByTag(bettow)
                local layUp = layBack:getChildByTag(up)
                local layDown = layBack:getChildByTag(down)
                moveToPostion(centen,layUp,layDown)
                centen:setTag(1)
                layUp:setTag(2)
                layDown:setTag(3)
                centen:setZOrder(1000)
                layUp:setZOrder(0)
                layDown:setZOrder(0)
            --end 
        end
    end
  
    
    layBack:addTouchEventListener(onMove)
    layOne:addTouchEventListener(onMove)
    layTwo:addTouchEventListener(onMove)
    layThree:addTouchEventListener(onMove)
end

 -- 手指按住移动  
    local function onTouchMoved(touch, event)  
        local location = touch:getLocation()  
        print("onTouchMoved: %0.2f, %0.2f", location.x, location.y)  
         
    end  
  
-- 显示场景
function create()
    local layoutMain = Layout:create()
    local  layBack = g_fnLoadUI(activity_list)

    local  layOne  = m_fnGetWidget(layBack,"lay_one")
    local  layTwo  = m_fnGetWidget(layBack,"lay_two")
    local  layThree  = m_fnGetWidget(layBack,"lay_three")
    setTouchPropertyEvent(layoutMain)
    
    -- layOne:setAnchorPoint(ccp(0.5, 0.5))
    -- layTwo:setAnchorPoint(ccp(0.5, 0.5))
    -- layThree:setAnchorPoint(ccp(0.5, 0.5))

   huadong(layBack,layOne,layTwo,layThree)
    -- local function onMoves( sender, eventType ) 
    --     if (eventType == TOUCH_EVENT_ENDED) then
    --         local layPos =  getProcessPos(layTwo)
    --         local blinkArray = CCArray:create()
    --         blinkArray:addObject(CCMoveTo:create(tonumber(1) ,layPos))
    --   -- blinkArray:addObject(CCCallFunc:create(funCallfunc)) convertToWorldSpaceAR
    --         local   actionBig = CCSequence:create(blinkArray)
    --     --sender:runAction(CCRepeatForever:create(actionBig)) ccTouchMoved
    --         sender:runAction(actionBig)
    --     end
    -- end
    --  layOne:addTouchEventListener(onMoves)
    -- layOne:addTouchEventListener(onMove)
    -- layOne:addTouchEventListener(onMove)
    
    return layBack
end
