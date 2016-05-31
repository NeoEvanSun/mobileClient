module("MainFightingResultView", package.seeall)
local activity_list = "n_ui/gameresult_1.json" 
local m_fnGetWidget = g_fnGetWidgetByName
local result
-- 胡牌数据
local huResult
local layBack
local tfdUserOne
local tfdUserTwo
local tfdUserThree
local tfdUserFour
local layUserOne
local layUserTwo
local layUserThree
local layUserFour
local btnCancle
local tfd_hupaijieguo

local pengSequences = {}
local eatSequences = {}
local gangSequences = {}

local function init(...)

end

function destroy(...)
    package.loaded["MainFightingResultView"] = nil
end

function moduleName()
    return "MainFightingResultView"
end

function reloadSource()
    local plistCache = CCSpriteFrameCache:sharedSpriteFrameCache()
    plistCache:addSpriteFramesWithFile(tpPath,ttPath)
    require "script/module/fighting/SpriteFramesManager"
    SpriteFramesManager.add(tpPath,ttPath)
end
function getSpecSprite( imgPath )
   
    return CCSprite:create(imgPath)
end
function getWord( word )
   local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
 
   local frameData = cache:spriteFrameByName(word)
    if(word == nil or frameData == nil) then 
      reloadSource()
          frameData = cache:spriteFrameByName(word)
          if(word == nil or frameData == nil) then 
            error("CCSpriteFrame can't find :" .. word) 
          end
    end -- if end
    local frameSprite = CCSprite:create()
     
    frameSprite:setDisplayFrame(frameData)
    frameSprite:setAnchorPoint(ccp(0.5, 0.5))
    frameSprite:setCascadeOpacityEnabled(true)
    return frameSprite
end

function changeCardName( num)
  local imageName
  local row = math.floor(num / 10)
  local col = num % 10
  if col ~= 0 then
    if row == 0 then 
      -- 第一行，条 c_31~c_39
      imageName = "c_3"..col..".png"
    end
    if row == 1 then
      -- 第二行，筒 c_21~c_29
      imageName = "c_2"..col..".png"
    end
    if row == 2 then
      -- 第三行 万 c_11~c_19
      imageName = "c_1"..col..".png"
    end
    if row == 3 then
      -- 第四行
      imageName = "c_4"..col..".png"
    end
  end
  return imageName
end

function createCards( array, layer)
    local count = 0
    local change = -8
    local margin = 0
    -- 处理特殊操作的牌
    -- 吃
    if eatSequences ~= nil then
        -- local chiSprite = getSpecSprite("n_ui/chi.png")
        -- layer:addNode(chiSprite)
        -- chiSprite:setPosition(ccp(count*50,change))
        -- count = count + 1
        for i=1,#eatSequences do
            local tempResult = eatSequences[i]
            for j=1,3 do
                local num = tempResult[j]+1
                local imageName = changeCardName(num)
                print("imageName "..imageName)
                local base = getWord("b_04.png")
                local face = getWord(imageName)
                -- base:setPosition(ccp(count*50 +40 ,0+change))
                -- face:setPosition(ccp(count*50+3 +40  ,10+change))
                base:setPosition(ccp(count*50+margin,0+change))
                face:setPosition(ccp(count*50+3+margin,10+change))
               -- base:setPosition(ccp(count*50,0+change))
               -- face:setPosition(ccp(count*50+3,10+change))
                base:setAnchorPoint(ccp(0,0))
                face:setAnchorPoint(ccp(0,0))
                face:setScale(0.8)
                layer:addNode(base)
                layer:addNode(face)
                count = count + 1
            end
        end
        margin = margin + 10
    end
    -- 碰
    if pengSequences ~= nil then
        -- local pengSprite = getSpecSprite("n_ui/peng.png")
        -- layer:addNode(pengSprite)
        -- pengSprite:setPosition(ccp(count*50,change))
        -- count = count + 1
        for i=1,#pengSequences do
            local tempResult = pengSequences[i]
            for j=1,3 do
                local num = tempResult[j]+1
                local imageName = changeCardName(num)
                print("imageName "..imageName)
                local base = getWord("b_04.png")
                local face = getWord(imageName)
                base:setPosition(ccp(count*50+margin,0+change))
                face:setPosition(ccp(count*50+3+margin,10+change))
                -- base:setPosition(ccp(count*50,0+change))
                -- face:setPosition(ccp(count*50+3,10+change))
                base:setAnchorPoint(ccp(0,0))
                face:setAnchorPoint(ccp(0,0))
                face:setScale(0.8)
                layer:addNode(base)
                layer:addNode(face)
                count = count + 1
            end
        end
        margin = margin + 10
    end
    -- 杠
    if gangSequences ~= nil then
        -- local gangSprite = getSpecSprite("n_ui/gang.png")
        -- layer:addNode(gangSprite)
        -- gangSprite:setPosition(ccp(count*50,change))
        -- count = count + 1
        for i=1,#gangSequences do
            local tempResult = gangSequences[i]
            for j=1,4 do
                local num = tempResult[j]+1
                local imageName = changeCardName(num)
                print("imageName "..imageName)
                local base = getWord("b_04.png")
                local face = getWord(imageName)
                base:setPosition(ccp(count*50+margin,0+change))
                face:setPosition(ccp(count*50+3+margin,10+change))
               -- base:setPosition(ccp(count*50,0+change))
               -- face:setPosition(ccp(count*50+3,10+change))
                base:setAnchorPoint(ccp(0,0))
                face:setAnchorPoint(ccp(0,0))
                face:setScale(0.8)
                layer:addNode(base)
                layer:addNode(face)
                count = count + 1
            end
        end
        margin = margin + 10
    end
    -- 处理没有特殊操作的牌
    for i=1,37 do
        local num = array[i]
        if num > 0 then
            local imageName = changeCardName(i)
            for j=1,num do
                print("imageName "..imageName)
                local base = getWord("b_04.png")
                local face = getWord(imageName)
                base:setPosition(ccp(count*50+margin  ,0+change))
                face:setPosition(ccp(count*50+3+margin  ,10+change))
                base:setAnchorPoint(ccp(0,0))
                face:setAnchorPoint(ccp(0,0))
                face:setScale(0.8)
             --   sprite:setPosition(ccp(count*50+3,10+change+100))
                layer:addNode(base)
                layer:addNode(face)
            --    layer:addNode(sprite)
                count = count + 1
            end
        end
    end
end

-- 处理胡牌数据
function handleResult( ... )
    local string = huResult["fan"]
    local resultString = string.gsub(string,"\n"," ")
    print(resultString)
    tfd_hupaijieguo:setText(huResult["fan"])
    local playerInfo = huResult["playerCards"]
    for i=1,4 do
        print(i)
        local tempResult = playerInfo[i]
        print(tempResult["userId"])
        eatSequences = tempResult["eatSequences"]
        pengSequences = tempResult["pengSequences"]
        gangSequences = tempResult["outGangCards"]
        if i == 1 then
            tfdUserOne:setText("玩家"..tempResult["userId"])
            createCards(tempResult["cards"],layUserOne)
        end
        if i == 2 then
            tfdUserTwo:setText("玩家"..tempResult["userId"])
            createCards(tempResult["cards"],layUserTwo)
        end
        if i == 3 then
            tfdUserThree:setText("玩家"..tempResult["userId"])
            createCards(tempResult["cards"],layUserThree)
        end
        if i == 4 then
            tfdUserFour:setText("玩家"..tempResult["userId"])
            createCards(tempResult["cards"],layUserFour)
        end
    end
end

function backToMain( ... )
    require "script/module/fighting/MainFightingView"
    require "script/module/fighting/MainFightingCtrl"
    MainFightingView.destroy()
    MainFightingCtrl.destroy()
    require "script/module/mainTips/MainTipsCtrl"
    local tips = MainTipsCtrl.create() 
    LayerManager.changeModule(tips, MainTipsCtrl.moduleName(), {1}, true)
end

function create( tbBtnEvent )
    layBack = g_fnLoadUI(activity_list)
    tfdUserOne = m_fnGetWidget(layBack,"tfd_one")
    tfdUserTwo = m_fnGetWidget(layBack,"tfd_two")
    tfdUserThree = m_fnGetWidget(layBack,"tfd_three")
    tfdUserFour = m_fnGetWidget(layBack,"tfd_four")
    layUserOne = m_fnGetWidget(layBack,"lay_one")
    layUserOne:setAnchorPoint(ccp(0,0.2))
    layUserTwo = m_fnGetWidget(layBack,"lay_two")
    layUserTwo:setAnchorPoint(ccp(0,0.2))
    layUserThree = m_fnGetWidget(layBack,"lay_three")
    layUserThree:setAnchorPoint(ccp(0,0.2))
    layUserFour = m_fnGetWidget(layBack,"lay_four")
    layUserFour:setAnchorPoint(ccp(0,0.2))
    btnCancle = m_fnGetWidget(layBack,"btn_cancle")
    btnCancle:addTouchEventListener(tbBtnEvent.byebye)
    btnSure = m_fnGetWidget(layBack,"btn_sure")
    btnSure:addTouchEventListener(tbBtnEvent.ready)
    tfd_hupaijieguo = m_fnGetWidget(layBack,"tfd_hupaijieguo")

    require "script/module/fighting/FightingData"
    huResult = FightingData.getHuResult()
    handleResult()
    return layBack
end