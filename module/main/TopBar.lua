-- FileName: TopBar.lua
-- Author: zhangqi
-- Date: 2014-05-29
-- Purpose: 主界面顶部的跑马灯
--[[TODO List]]
-- modified:
-- 2015-04-15, zhangqi, 添加如果是在主界面就创建独有跑马灯的处理

module("TopBar", package.seeall)
require "script/module/main/BulletinData"
-- UI控件引用变量 --
local m_layMain
local m_layBar -- "LAY_PAOMADENG"
local m_layBarSize

-- 模块局部变量 --
local strTempInfo = " "
local m_fnLoadUI = g_fnLoadUI
local m_fnGetWidget = g_fnGetWidgetByName

local fnCreatePaoMaDeng

local function init(...)

end

function destroy(...)
	package.loaded["TopBar"] = nil
end

function moduleName()
    return "TopBar"
end

local _showYellow = nil

function shouldShowYellow( ... )
    return _showYellow
end

function create(noYellow)
    _showYellow = not (LayerManager.curModuleName() ~= "MainShip" or noYellow)
    if (LayerManager.curModuleName() ~= "MainShip" or noYellow) then
        m_layMain = m_fnLoadUI("ui/home_paomadeng.json")
        m_layBar = m_fnGetWidget(m_layMain, "LAY_PAOMADENG")
        m_layBarSize = m_layBar:getSize()

        m_layMain.tttopBarType = "blackTB"
    else
        m_layMain = m_fnLoadUI("ui/home_new_pmd.json") -- 2015-04-15
        local imgBar = m_fnGetWidget(m_layMain, "IMG_PMD_EDGE")
        imgBar:setScale(g_fScaleX)
        local imgBg = m_fnGetWidget(m_layMain, "IMG_PMD_MIDDLE")
        imgBg:setScale(g_fScaleX)
        
        m_layBar = m_fnGetWidget(m_layMain, "LAY_NEW_PMD")
        m_layBar:setScale(g_fScaleX)
        m_layBarSize = m_layBar:getSize()

        m_layMain.tttopBarType = "yellowTB"
    end 
    
    fnCreatePaoMaDeng()
    return m_layMain
end

function fnCreatePaoMaDeng()
    if(m_layBar) then
         m_layBar:removeChildByTag(9876,true)
    else
        m_layBar = m_fnGetWidget(m_layMain, "LAY_PAOMADENG")
    end

    --创建滚动文字动画 
    local labelItem = BulletinData.getBulletNode()

    labelItem:setAnchorPoint(ccp(0.0, 0.5))
    labelItem:setPosition(ccp(m_layBarSize.width, m_layBarSize.height / 2))
    m_layBar:addChild(labelItem,0,9876)

    local labSize = labelItem:getSize()

    local array = CCArray:create()
    local callfunc = CCCallFunc:create(fnCreatePaoMaDeng)
    local move = CCMoveBy:create(15*g_fScaleX, ccp(-m_layBarSize.width - labSize.width, 0))
     array:addObject(move)
     array:addObject(CCDelayTime:create(1.5))
    array:addObject(callfunc)
    local action = CCSequence:create(array)
    labelItem:runAction(action)
    
end
