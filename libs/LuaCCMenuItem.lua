-- Filename: LuaCCMenuItem.lua
-- Author: fang
-- Date: 2013-08-05
-- Purpose: 该文件用于: 在Lua中创建CCMenuItem元素

module("LuaCCMenuItem", package.seeall)


function createMenuItemOfRenderLabelOnSprite(tSprite, tLabel)
	-- 检查sprite数据传入参数有效性
	local normalImage = tSprite.normal
	local selectedImage = tSprite.selected
	local disabledImage = tSprite.disabled or tSprite.normal
	if not (normalImage and selectedImage) then
		return nil
	end
	local normalSprite = CCSprite:create(normalImage)
	local selectedSprite = CCSprite:create(selectedImage)
	local disabledSprite = BTGraySprite:create(disabledImage)
	-- 创建MenuItem
	local ccMenuItemObj = CCMenuItemSprite:create(normalSprite, selectedSprite, disabledSprite)
	if tSprite.position then
		ccMenuItemObj:setPosition(tSprite.position)
	end
	if tSprite.anchorPoint then
		ccMenuItemObj:setAnchorPoint(tSprite.anchorPoint)
	end
	-- 设置默认初始状态
	if tSprite.focus then
		ccMenuItemObj:selected()
	end
	local itemSize = normalSprite:getContentSize()
	local text = tLabel.text or "lack of text!"
	local fontsize = tLabel.fontsize or 23
	local fontname = tLabel.fontname or g_sFontPangWa
	local strokeSize = tLabel.strokeSize or 1
	local color = tLabel.color or ccc3(0xfe, 0xdb, 0x1c)
	local strokeColor = tLabel.strokeColor or ccc3(0x00, 0, 0x00)

	local x=ccMenuItemObj:getContentSize().width/2
	local y=ccMenuItemObj:getContentSize().height/2
	if tLabel.xOffset then
		x = x + tLabel.xOffset
	end
	if tLabel.yOffset then
		y = y + tLabel.yOffset
	end
    local normalLabel = CCRenderLabel:create(text, fontname, fontsize, strokeSize, strokeColor, type_stroke)
    normalLabel:setColor(color)
    normalLabel:setPosition(ccp(x, y))
    normalLabel:setAnchorPoint(ccp(0.5, 0.5))
    normalSprite:addChild(normalLabel,1, 1001) 
    local selectedLabel = CCRenderLabel:create(text, fontname, fontsize, strokeSize, strokeColor, type_stroke)
    selectedLabel:setColor(color)
    selectedLabel:setPosition(ccp(x, y))
    selectedLabel:setAnchorPoint(ccp(0.5, 0.5))
    selectedSprite:addChild(selectedLabel,1, 1002) 
    local disableLabel = CCRenderLabel:create(text, fontname, fontsize, strokeSize, strokeColor, type_stroke)
    disableLabel:setColor(color)
    disableLabel:setPosition(ccp(x, y))
    disableLabel:setAnchorPoint(ccp(0.5, 0.5))
    disabledSprite:addChild(disableLabel,1, 1003)
	return ccMenuItemObj
end

-- 创建带文字的精灵MenuItem
function createMenuItemOfLabelOnSprite(tSprite, tLabel)
	-- 检查sprite数据传入参数有效性
	local normalImage = tSprite.normal
	local selectedImage = tSprite.selected
	local disabledImage = tSprite.disabled or tSprite.normal
	if not (normalImage and selectedImage) then
		return nil
	end
	local normalSprite = CCSprite:create(normalImage)
	local selectedSprite = CCSprite:create(selectedImage)
	local disabledSprite = BTGraySprite:create(disabledImage)
	-- 创建MenuItem
	local ccMenuItemObj = CCMenuItemSprite:create(normalSprite, selectedSprite, disabledSprite)
	if tSprite.position then
		ccMenuItemObj:setPosition(tSprite.position)
	end
	if tSprite.anchorPoint then
		ccMenuItemObj:setAnchorPoint(tSprite.anchorPoint)
	end
	-- 设置默认初始状态
	if tSprite.focus then
		ccMenuItemObj:selected()
	end
	local itemSize = normalSprite:getContentSize()
	local text = tLabel.text or "lack of text!"
	local nFontsize = tLabel.nFontsize or 23
	local sFontsize = tLabel.sFontsize or nFontsize
	local dFontsize = tLabel.dFontsize or nFontsize
	local fontname = tLabel.fontname or g_sFontPangWa
	local nColor = tLabel.nColor or ccc3(255, 255 ,255)
	local sColor = tLabel.sColor or nColor
	local dColor = tLabel.dColor or nColor

	local x = tLabel.xOffset or 0
	x = x + itemSize.width/2
	local y = tLabel.yOffset or 0
	y = y + itemSize.height/2

    local normalLabel = CCLabelTTF:create(text, fontname, nFontsize)
    normalLabel:setColor(nColor)
    normalLabel:setPosition(ccp(x, y))
    normalLabel:setAnchorPoint(ccp(0.5, 0.5))
    normalSprite:addChild(normalLabel, 1, 1001)
    
    local selectedLabel = CCLabelTTF:create(text, fontname, sFontsize)
    selectedLabel:setColor(sColor)
    selectedLabel:setPosition(ccp(x, y))
    selectedLabel:setAnchorPoint(ccp(0.5, 0.5))
    selectedSprite:addChild(selectedLabel,1, 1002)
    
    local disableLabel = CCLabelTTF:create(text, fontname, dFontsize)
    disableLabel:setColor(dColor)
    disableLabel:setPosition(ccp(x, y))
    disableLabel:setAnchorPoint(ccp(0.5, 0.5))
    disabledSprite:addChild(disableLabel,1, 1003)


	return ccMenuItemObj
end

-- 描边字标签 @author chengliang
function createMenuItemOfRender( image_n, image_h, rect_full_n, rect_inset_n, rect_full_h, rect_inset_h, btn_size_n, btn_size_h, text, text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
	
	-- normalSprite
	local sprite_n = CCScale9Sprite:create(image_n, rect_full_n, rect_inset_n)
	sprite_n:setPreferredSize(btn_size_n)
	-- normalLabel
    local label_n = CCRenderLabel:create(text , font, font_size, stroke_size, strokeCor_n, type_stroke)
    label_n:setColor(text_color_n)
    label_n:setPosition( ccp((btn_size_n.width - label_n:getContentSize().width)/2, btn_size_n.height -(btn_size_n.height - label_n:getContentSize().height)/2 ))
    sprite_n:addChild(label_n)

    -- highLightedSprite
	local sprite_h = CCScale9Sprite:create(image_h, rect_full_h, rect_inset_h)
	sprite_h:setPreferredSize(btn_size_h)
	-- highLightedLabel
    local label_h = CCRenderLabel:create(text , font, font_size, stroke_size, strokeCor_h, type_stroke)
    label_h:setColor(text_color_h)
    label_h:setPosition( ccp((btn_size_h.width - label_h:getContentSize().width)/2, btn_size_h.height - (btn_size_h.height - label_h:getContentSize().height)/2 ))
    sprite_h:addChild(label_h)

    -- 创建按钮
    local menuItem = CCMenuItemSprite:create(sprite_n, sprite_h)

    return menuItem
end


-- 释放LuaCCMenuItem模块相关资源  
function release()
	LuaCCMenuItem = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/LuaCCMenuItem")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end