-- FileName: ShowNotice.lua 
-- Author: xianghuiZhang 
-- Date: 14-4-11
-- Purpose: show notification at screen center

module("ShowNotice", package.seeall)

local jsonNotice = "n_ui/show_tip_1.json"
local tbNotice = {} --显示提示集合

local m_TipZorder = 51000 -- 弹出提示信息的初始Zorder

local function ActionSequenceCallback( node )
	if (#tbNotice > 0) then
		local reWidget = tbNotice[1]
		reWidget:removeFromParentAndCleanup(true)
		print("node:getTag()"..node:getTag())
		table.remove(tbNotice,1)
	end
end

local function fnAddRunScene( widget )
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(widget,m_TipZorder)
	table.insert( tbNotice, widget )

	local function bugMe(node)
        node:stopAllActions()
    end

	local array = CCArray:create()
    array:addObject(CCMoveBy:create(1.0, ccp(0,100)))
    array:addObject(CCCallFuncN:create(ActionSequenceCallback))
    local action = CCSequence:create(array)
    widget:runAction(action)
end

function showShellInfo( strText )
	local showItemLayer = g_fnLoadUI(jsonNotice)
	if (showItemLayer and strText ~= nil) then
		local showText = g_fnGetWidgetByName(showItemLayer, "TFD_TIP", "Label")
		if(showText) then
			-- local img_frame = g_fnGetWidgetByName(showItemLayer, "img_frame")
			-- local frameSize = img_frame:getVirtualRenderer():getContentSize()
			-- showText:ignoreContentAdaptWithSize(false)
			-- showText:setSize(CCSizeMake(frameSize.width,frameSize.height))
			-- showText:setTextHorizontalAlignment(kCCTextAlignmentCenter)
			-- showText:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)
			showText:setText(strText)
			-- showText:setFontSize(g_FontInfo.size)
			fnAddRunScene(showItemLayer)
		end
	end
end