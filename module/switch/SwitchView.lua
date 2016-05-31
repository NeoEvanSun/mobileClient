-- FileName: SwitchView.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("SwitchView", package.seeall)

local json = "ui/new_function.json"
-- UI控件引用变量 --

-- 模块局部变量 --
local m_mainWidget
local m_fnGetWidget = g_fnGetWidgetByName
local m_tbData 
local m_fnGo
local m_i18n = gi18n
local function init(...)
	m_tbData = {}
end

function destroy(...)
	package.loaded["SwitchView"] = nil
end

function moduleName()
    return "SwitchView"
end

function create(tbData,fnGo)
	init()
	m_tbData = tbData
	m_fnGo = fnGo
	m_mainWidget = g_fnLoadUI(json)
	m_mainWidget:setSize(g_winSize)
	updateUI()
	return m_mainWidget
end

function updateUI(  )
	local i18nTFD_TITLE = m_fnGetWidget(m_mainWidget,"TFD_TITLE") -- “新系统开启”
	local IMG_FUNCTION = m_fnGetWidget(m_mainWidget, "IMG_FUNCTION") -- 新功能图标
	IMG_FUNCTION:loadTexture(m_tbData.icon)

	local LAY_RICHTEXT = m_fnGetWidget(m_mainWidget, "LAY_RICHTEXT") -- 富文本 占位
	-- 
	m_tbData.richText:setAlignCenter(true)
	m_tbData.richText:setSize(CCSizeMake(LAY_RICHTEXT:getSize().width,LAY_RICHTEXT:getSize().height))
	LAY_RICHTEXT:addChild(m_tbData.richText);
	
		
	local TFD_DESC = m_fnGetWidget(m_mainWidget, "TFD_DESC") -- switch表中配置alertContent
	TFD_DESC:setText(m_tbData.alertContent)

	-- local IMG_ARROW = m_fnGetWidget(m_mainWidget, "IMG_ARROW") -- 箭头
	-- runMoveAction(IMG_ARROW)

	local BTN_GO = m_fnGetWidget(m_mainWidget, "BTN_GO") -- 前往查看  按钮

	require "script/module/public/EffectHelper"
	local guideEff = EffGuide:new()
	-- guideEff:Armature():setPosition(ccp(ox+ow/2, oy+oh/2))
	BTN_GO:addNode(guideEff:Armature(),9999)


	BTN_GO:addTouchEventListener(m_fnGo)
	UIHelper.titleShadow(BTN_GO ,m_i18n[1929])

end