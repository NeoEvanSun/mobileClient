-- FileName: LoginNoticeView.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]


module("LoginNoticeView", package.seeall)


-- UI控件引用变量 --
local m_UIMain

local m_btnSure
local m_btnClose
local m_lsv


-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName


function addAnnounce( tbAnnounce )
	local lsvSize = m_lsv:getSize()

	local labelTitle = UIHelper.createUILabel(tbAnnounce.title, g_FontPangWa, 24)
	labelTitle:ignoreContentAdaptWithSize(false)
	labelTitle:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	labelTitle:setAnchorPoint(ccp(0.5, 0.5))
	local colorT = tbAnnounce.colorT
	labelTitle:setColor(ccc3(colorT[1], colorT[2], colorT[3]))
	local tSize = labelTitle:getContentSize()
	local titleWidth
	if tSize.width <= lsvSize.width * 0.95 then
		titleWidth = tSize.width
	else
		titleWidth = lsvSize.width * 0.95
	end
	labelTitle:setSize(CCSizeMake(titleWidth, math.ceil(tSize.width / (lsvSize.width * 0.95)) * tSize.height + 1))

	local imgTitleBg = ImageView:create()
	imgTitleBg:setAnchorPoint(ccp(0.5, 0.5))
	imgTitleBg:setScale9Enabled(true)
	imgTitleBg:setSize(CCSizeMake(lsvSize.width, labelTitle:getSize().height + 30))
	imgTitleBg:addChild(labelTitle)
	imgTitleBg:setTouchEnabled(true)
	m_lsv:pushBackCustomItem(imgTitleBg)

	local labelWord = UIHelper.createUILabel(tbAnnounce.word, g_FontInfo.name, 22)
	labelWord:ignoreContentAdaptWithSize(false)
	labelWord:setAnchorPoint(ccp(0, 0.5))
	labelWord:setPosition(ccp(15, 0))
	local colorW = tbAnnounce.colorW
	labelWord:setColor(ccc3(colorW[1], colorW[2], colorW[3]))
	local tSize = labelWord:getContentSize()
	labelWord:setSize(CCSizeMake(lsvSize.width * 0.9, math.ceil(tSize.width / (lsvSize.width * 0.9)) * 27))
	local rSize = labelWord:getVirtualRenderer():getContentSize()
	labelWord:setSize(CCSizeMake(rSize.width + 10, rSize.height + 24))

	m_lsv:pushBackCustomItem(labelWord)
end


local function init(...)

end


function destroy(...)
	package.loaded["LoginNoticeView"] = nil
end


function moduleName()
	return "LoginNoticeView"
end


function create(...)
	NewLoginView.setEditBoxEnabled(false)
	m_UIMain = g_fnLoadUI("ui/regist_announce.json")

	m_btnSure = m_fnGetWidget(m_UIMain, "BTN_CONFIRM")
	m_btnClose = m_fnGetWidget(m_UIMain, "BTN_CLOSE")
	m_lsv = m_fnGetWidget(m_UIMain, "LSV_CONTENT")

	UIHelper.titleShadow(m_btnSure, gi18n[2629])
	m_btnSure:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			LayerManager.removeLayout()
			NewLoginView.setEditBoxEnabled(true)
		end
	end)

	m_btnClose:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCloseEffect()
			LayerManager.removeLayout()
			NewLoginView.setEditBoxEnabled(true)
		end
	end)

	m_lsv:removeAllItems()

	return m_UIMain
end

