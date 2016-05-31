-- Filename: LuaCCSprite.lua
-- Author: fang
-- Date: 2013-08-02
-- Purpose: 该文件用于在lua中封装cocos2d-x中CCSprite及CCScale9Sprite对象

module("LuaCCSprite", package.seeall)


-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithRenderLabel(bgfile, tLabel)
	local ccSprite = CCSprite:create(bgfile)
	local spriteSize = ccSprite:getContentSize()
	local ccLabel = CCRenderLabel:create(tLabel.text, g_sFontName, tLabel.fontsize, tLabel.stroke_size, tLabel.stroke_color, type_stroke)
	ccLabel:setSourceAndTargetColor(tLabel.sourceColor, tLabel.targetColor)

	local x = spriteSize.width/2
	local y = spriteSize.height/2
	if tLabel.vOffset then
		y = y + tLabel.vOffset
	end
	if tLabel.hOffset then
		x = x + tLabel.hOffset
	end

	ccLabel:setPosition(ccp(x, y))
	if tLabel.tag then
		ccSprite:addChild(ccLabel, 0, tLabel.tag)
	else
		ccSprite:addChild(ccLabel)
	end
	-- 真奇怪！应该是CCRenderLabel类有bug，否则不该是ccp(1, 0)
	if tLabel.anchorPoint then
		ccLabel:setAnchorPoint(tLabel.anchorPoint)
	end
	return ccSprite
end
-- 创建带标题的图片（标题在图片的中心）
function createSpriteWithLabel(bgfile, tLabel)
	local ccSprite = CCSprite:create(bgfile)
	local spriteSize = ccSprite:getContentSize()
	local fontname = tLabel.fontname or g_sFontName
	local ccLabel = CCLabelTTF:create (tLabel.text, fontname, tLabel.fontsize)
	if (tLabel.color) then
		ccLabel:setColor(tLabel.color)
	end
	ccLabel:setAnchorPoint(ccp(0.5, 0.5))
	local x = spriteSize.width/2
	local y = spriteSize.height/2
	if tLabel.vOffset then
		y = y + tLabel.vOffset
	end
	if tLabel.hOffset then
		x = x + tLabel.hOffset
	end

	ccLabel:setPosition(ccp(x, y))
	if (tLabel.tag) then
		ccSprite:addChild(ccLabel, 0, tLabel.tag)
	else
		ccSprite:addChild(ccLabel)
	end

	return ccSprite
end

-- 创建统一标题栏（上面带有菜单按钮）
-- in: tParam, 输入参数，应该是个数组
-- out: 返回一个CCSprite对象。该对象上包含着menu(tag为10001)，
-- menu中包含着CCMenuItem对象数组(默认tag以1001为起始值，如果参数中带有tag的话则以参数为准)
function createTitleBar(tParam)
	local fullRect = CCRectMake(0,0,58,99)
	local insetRect = CCRectMake(20,20,18,59)
	--标题背景
	local cs9Bg = CCScale9Sprite:create("images/common/menubg.png", fullRect, insetRect)
	cs9Bg:setPreferredSize(CCSizeMake(640, 108))
	
	local menu = CCMenu:create()
	menu:setPosition(ccp(10, 10))
	cs9Bg:addChild(menu, 0, 10001)
	for i=1, #tParam do
		local item=tParam[i]
		-- 普通文本以默认
		local nFontsize = item.nFontsize or 36
		local nColor = item.nColor or ccc3(0xff, 0xe4, 0)
		local pFontname = item.fontname or g_sFontPangWa
		local vOffset = item.vOffset or -4
		local tNormalLabel = {text=item.text, color=nColor, fontsize=nFontsize, fontname=pFontname, vOffset=vOffset}
		local sNormalImage = item.normalN or "images/active/rob/btn_title_n.png"
		local csNormal = createSpriteWithLabel(sNormalImage, tNormalLabel)
		
		local hFontsize = item.hFontsize or 30
		local hColor = item.hColor or ccc3(0x48, 0x85, 0xb5)
		local tHighlightedLabel = {text=item.text, color=hColor, fontsize=hFontsize, fontname=pFontname, vOffset=vOffset}
		local sHighlightedImage = item.normalH or "images/active/rob/btn_title_h.png"
		local csHighlighted = createSpriteWithLabel(sHighlightedImage, tHighlightedLabel)
		local nTagOfItem = item.tag or 1000+i
		local cmis = CCMenuItemSprite:create(csNormal, csHighlighted)
		local x=item.x or 0
		local y=item.y or 0
		cmis:setPosition(x, y)
		if item.handler then
			cmis:registerScriptTapHandler(item.handler)
		end
		menu:addChild(cmis, 0, nTagOfItem)
	end

	return cs9Bg
end

-- 释放模块占用资源
function release()
	LuaCCSprite = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/LuaCCSprite")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end