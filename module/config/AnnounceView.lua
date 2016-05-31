-- FileName: AnnounceView.lua
-- Author: menghao
-- Date: 2014-06-19
-- Purpose: 公告view


module("AnnounceView", package.seeall)


-- UI控件引用变量 --
local m_UIMain

local m_btnEnter
local m_layContent
local m_lsv

local m_layTitle
local m_imgTitleBG


-- 模块局部变量 --
local m_fnGetWidget = g_fnGetWidgetByName
local m_layTitleCopy


local function createLabelWord( tbAnnounce , lsvSize)
	local labelWord = UIHelper.createUILabel(tbAnnounce.word)
	labelWord:ignoreContentAdaptWithSize(false)
	local colorW = tbAnnounce.colorW
	labelWord:setColor(ccc3(colorW[1], colorW[2], colorW[3]))
	local tSize = labelWord:getSize()

	labelWord:setSize(CCSizeMake(lsvSize.width * 0.9, 0))
	local rSize = labelWord:getVirtualRenderer():getContentSize()
	labelWord:setSize(CCSizeMake(rSize.width + 10, rSize.height))

	local image = ImageView:create()
	image:setScale9Enabled(true)
	image:addChild(labelWord)
	image:setSize(CCSizeMake(lsvSize.width, labelWord:getSize().height + 10))

	return image
end


function addAnnounce( tbAnnounce, num)
	local lsvSize = m_lsv:getSize()

	local layTitle = m_layTitleCopy:clone()

	local imgTitleBg = m_fnGetWidget(layTitle, "img_bg1")
	local tfdTitle = m_fnGetWidget(layTitle, "TFD_TITLE_1")
	local btnOpen = m_fnGetWidget(layTitle, "BTN_TEXT1_OPEN")
	local btnClose = m_fnGetWidget(layTitle, "BTN_TEXT1_CLOSE")

	local curBtn

	tfdTitle:setText(tbAnnounce.title)
	local colorT = tbAnnounce.colorT
	tfdTitle:setColor(ccc3(colorT[1], colorT[2], colorT[3]))

	btnOpen:setEnabled(false)
	curBtn = btnClose

	imgTitleBg:setTag(0)
	imgTitleBg:setTouchEnabled(true)
	m_lsv:pushBackCustomItem(layTitle)

	local function btnClicked( ... )
		curBtn:setFocused(false)
		local index = m_lsv:getCurSelectedIndex()
		if imgTitleBg:getTag() == 0 then
			local labelWord = createLabelWord(tbAnnounce, lsvSize)
			m_lsv:insertCustomItem(labelWord ,index + 1)
			imgTitleBg:setTag(1)

			btnOpen:setEnabled(true)
			btnClose:setEnabled(false)
			curBtn = btnOpen
		else
			local num = imgTitleBg:getTag()
			for i=1,num do
				m_lsv:removeItem(index + 1)
			end
			imgTitleBg:setTag(0)

			btnOpen:setEnabled(false)
			btnClose:setEnabled(true)
			curBtn = btnClose
		end
	end

	btnOpen:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			btnClicked()
		end
	end)

	btnClose:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			btnClicked()
		end
	end)

	imgTitleBg:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_MOVED or eventType == TOUCH_EVENT_BEGAN) then
			curBtn:setFocused(true)
		end
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			btnClicked()
		end
	end)

	if (num == 1) then
		btnClicked()
	end
end


local function init(...)

end


function destroy(...)
	package.loaded["AnnounceView"] = nil
end


function moduleName()
	return "AnnounceView"
end


function create(...)
	m_UIMain = g_fnLoadUI("ui/public_gonggao.json")

	m_btnEnter = m_fnGetWidget(m_UIMain, "BTN_ENTER")
	UIHelper.titleShadow(m_btnEnter, gi18n[4101])
	m_btnEnter:addTouchEventListener(function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			LayerManager.removeLayout()
		end
	end)
	m_layContent = m_fnGetWidget(m_UIMain, "LAY_CONTENT")
	m_lsv = m_fnGetWidget(m_UIMain, "LSV_CONTENT")

	m_layTitle = m_fnGetWidget(m_UIMain, "LAY_TITLE_1")
	m_imgTitleBG = m_fnGetWidget(m_UIMain, "img_bg1")

	m_layTitleCopy = m_layTitle:clone()

	m_lsv:removeAllItems()
	m_lsv:setTouchEnabled(true)
	m_lsv:setBounceEnabled(true)
	return m_UIMain
end

