-- Filename: LuaCCLabel.lua
-- Author: fang
-- Date: 2013-08-02
-- Purpose: 该文件用于在lua中封装cocos2d-x中CCLabel对象

module ("LuaCCLabel", package.seeall)

-- 创建带label的label(这些labels都在一行中，水平方向)
-- sample: 武将系统，武将强化界面，"生命： 10000 +11000" (在HeroStrenthenLayer.lua中有使用例子)
function createHorizontalLabelHeelLabels(tLabels)
	-- 所创建label数组
	local tLabelObjs = {}
	local ccLabelFirstObj = nil
	local x = 0
	local y = 0

	for i=1, #tLabels do
		local v = tLabels[i]
		if ccLabelFirstObj == nil then
			ccLabelFirstObj = CCLabelTTF:create(v.text, g_sFontName, v.fontsize)
			x = ccLabelFirstObj:getContentSize().width
			if v.color then
				ccLabelFirstObj:setColor(v.color)
			end
			tLabelObjs[i] = ccLabelFirstObj
		else
			y = 0
			local obj = CCLabelTTF:create(v.text, g_sFontName, v.fontsize)
			if v.hOffset then
				x = x + v.hOffset
			end
			if v.vOffset then
				y = y + v.vOffset
			end
			obj:setPosition(ccp(x, y))
			obj:setAnchorPoint(ccp(0, 0))
			if v.color then
				obj:setColor(v.color)
			end
			ccLabelFirstObj:addChild(obj)
			x = x + obj:getContentSize().width
			tLabelObjs[i] = obj
		end
	end

	return tLabelObjs
end
-- 创建多行文本标签，程序自动判断是否需要换行
-- 该函数会被废弃掉
-- 请尽量调用createMultiLineLabel方法
function createMultiLineLabels(tLabel)
	local tData = {}
	local fontname = tLabel.fontname or g_sFontName
	local fontsize = tLabel.fontsize or 22
	local color = tLabel.color or ccc3(0x78, 0x25, 0)
	local alignment = tLabel.alignment or kCCTextAlignmentLeft
	local anchorPoint = tLabel.anchorPoint or ccp(0, 1)
	local width=tLabel.width or 470

	local ccLabelObj = CCLabelTTF:create(tLabel.text, fontname, fontsize)
	local size = ccLabelObj:getContentSize()

	local lines = math.ceil(size.width/width)
	local height = size.height * lines
	ccLabelObj = CCLabelTTF:create(tLabel.text, fontname, fontsize, CCSizeMake(width, height), alignment)
	if tLabel.position then
		ccLabelObj:setPosition(tLabel.position)
	end

	ccLabelObj:setColor(color)
	ccLabelObj:setAnchorPoint(anchorPoint)

	return ccLabelObj
end

-- 创建多行文本标签，程序自动判断是否需要换行
function createMultiLineLabel(tLabel)
    local tData = {}
    local fontname = tLabel.fontname or g_sFontName
    local fontsize = tLabel.fontsize or 22
    local color = tLabel.color or ccc3(0x78, 0x25, 0)
    local alignment = tLabel.alignment or kCCTextAlignmentLeft
    local anchorPoint = tLabel.anchorPoint or ccp(0, 1)
    local width=tLabel.width or 470
    -- 指定高度，若不指定则由系统计算出实际高度
    local height = tLabel.height or 0
    local cclObj = CCLabelTTF:create(tLabel.text, fontname, fontsize)
    local nRealWidth = cclObj:getContentSize().width
    if nRealWidth > width then
        cclObj = CCLabelTTF:create(tLabel.text, fontname, fontsize, CCSizeMake(width, height), alignment)
    end
    if tLabel.position then
        cclObj:setPosition(tLabel.position)
    end
    cclObj:setColor(color)
    cclObj:setAnchorPoint(anchorPoint)

    return cclObj
end

-- 创建带label的label(这些labels都在一行中，垂直方向)
-- 垂直方向，这些label具有相同X坐标（支持Xoffset)
function createVerticalLabelHeelLabels(tLabels)
	-- 所创建label数组
	local tLabelObjs={}
	local ccLabelFirstObj=nil
	-- 设置默认颜色
	local color = ccc3(0, 0, 0)
	-- 设置默认字体大小
	local fontsize = 23
	-- 设置默认文字行间距
	local vOffset = 20
	local x=0
	local y=0

	for i=1, #tLabels do
		local v = tLabels[i]
		if ccLabelFirstObj == nil then
			fontsize = v.fontsize or fontsize
			ccLabelFirstObj = CCLabelTTF:create(v.text, g_sFontName, fontsize)
			y = ccLabelFirstObj:getContentSize().height
			color = v.color or color
			ccLabelFirstObj:setColor(color)
			tLabelObjs[i] = ccLabelFirstObj
		else
			x=0
			-- 字体大小
			fontsize = v.fontsize or fontsize
			local obj = CCLabelTTF:create(v.text, g_sFontName, fontsize)
			if v.hOffset then
				x = x + v.hOffset
			end
			-- 行间距
			vOffset = v.vOffset or vOffset
			y = y + vOffset
			obj:setPosition(ccp(x, y))
			obj:setAnchorPoint(ccp(0, 0))
			-- 颜色设定
			color = v.color or color
			obj:setColor(color)
			y = y + obj:getContentSize().height
			ccLabelFirstObj:addChild(obj)
			tLabelObjs[i] = obj
		end
	end

	return tLabelObjs
end

-- lua中创建CCRenderLabel对象
function createCCRenderLabel(tRenderLabel)
	-- CCRendLabel默认属性
	local text = tRenderLabel.text or "lack of text!"
	local fontsize = tRenderLabel.fontsize or 23
	local strokeSize = tRenderLabel.strokeSize or 1
	local color = tRenderLabel.color or ccc3(255, 255, 255)
	
	-- 创建CCRenderLabel对象
	local ccRenderLabelObj = CCRenderLabel:create(text, g_sFontName, fontsize, strokeSize, color, type_stroke)
	if tRenderLabel.sourceColor and tRenderLabel.targetColor then
		ccRenderLabelObj:setSourceAndTargetColor(tRenderLabel.sourceColor, tRenderLabel.targetColor)
	end
	-- 设置坐标
	if tRenderLabel.position then
		ccRenderLabelObj:setPosition(tRenderLabel.position)
	end
	-- 设置锚点
	if tRenderLabel.anchorPoint then
		ccRenderLabelObj:setAnchorPoint(tRenderLabel.anchorPoint)
	end
    
	return ccRenderLabelObj
end

-- lua中创建投影LABEL
function createShadowLabel(str,font,fontSize)
    
    font = font==nil and g_sFontName or font
    fontSize = fontSize==nil and 25 or fontSize
    
	local resultLabel = CCLabelTTF:create(str,font,fontSize)
    
    local shadowLabel = CCLabelTTF:create(str,font,fontSize)
    shadowLabel:setPosition(fontSize/10,-fontSize/10)
    shadowLabel:setAnchorPoint(ccp(0,0))
    shadowLabel:setColor(ccc3(11,11,11))
    resultLabel:addChild(shadowLabel,-1,1212)
    
	return resultLabel
end

-- 创建一个TTF标签, 返回该标签属性及对象
function createCCLabelTTF(tLabel)
	local tAttrLabel={}
	local ccLabelObj = CCLabelTTF:create(tLabel.text, g_sFontName, tLabel.fontsize)
	local position = tLabel.position or ccp(0, 0)

	if tLabel.yOffset then
		position.y = position.y + tLabel.yOffset
	end
	if tLabel.xOffset then
		position.x = position.x + tLabel.xOffset
	end
	if tLabel.anchorPoint then
		ccLabelObj:setAnchorPoint(tLabel.anchorPoint)
	end
	ccLabelObj:setPosition(position)
	if tLabel.color then
		ccLabelObj:setColor(tLabel.color)
	end

	tAttrLabel.size = ccLabelObj:getContentSize()
	tAttrLabel.obj = ccLabelObj


	return tAttrLabel
end

-- 创建渲染标签
function createCCRenderLabel(tLabel)
	

end

--创建富文本节点
local function createRichTextNode(nodeInfo)
    local font = nodeInfo.font or g_sFontName
    local fontSize = nodeInfo.fontSize or 21
    local color = nodeInfo.color or ccc3(255,255,255)
    local content = nodeInfo.content or ""
    local tag = nodeInfo.tag or 1
    
    local resultNode
    if(nodeInfo.ntype=="label")then
        resultNode = CCLabelTTF:create(tostring(content),font,fontSize)
        resultNode:setColor(color)
        resultNode:setTag(tag)
        resultNode:setAnchorPoint(ccp(0,0))
    elseif(nodeInfo.ntype=="strokeLabel")then
        local strokeSize = nodeInfo.strokeSize or fontSize/15
        local strokeColor = nodeInfo.strokeColor or ccc3(22,22,22)
        
        resultNode = CCRenderLabel:create(tostring(content), font, fontSize, strokeSize, strokeColor, type_stroke)
        resultNode:setColor(color)
        resultNode:setTag(tag)
    else
        resultNode = CCMenuItemFont:create(tostring(content))
        resultNode:setFontNameObj(font)
        resultNode:setFontSizeObj(fontSize)
        resultNode:setAnchorPoint(ccp(0,0))
        resultNode:setColor(color)
        resultNode:setTag(tag)
        --print("nodeInfo.tapFunc:",type(nodeInfo.tapFunc))
        if(nodeInfo.tapFunc~=nil)then
            --print("nodeInfo.tapFunc~=nil")
            resultNode:registerScriptTapHandler(nodeInfo.tapFunc)
        end
    end
    
    return resultNode
end

--使用LUA TABLE创建富文本，非字符串……
--richTextInfo包含width,priority和节点信息数组
--节点信息内包含:ntype,content,color,fontSize,font,tag,tapFunc,strokeSize,strokeColor
--可使用ntype:label,strokeLabel,button
--注意,button长度请不要超过限定宽度
--[[
--sample:
require "script/libs/LuaCCLabel"
local richTextInfo = {}
richTextInfo.width = 400
richTextInfo[1] = {content="长度测试一二三四五六长度测试一二三四五六长度测试一二三四五六",ntype="label",color=ccc3(0,222,0)}
richTextInfo[2] = {content="测试按键测试按键测试按键",ntype="button",color=ccc3(0,111,255),tapFunc=showDesc}
richTextInfo[3] = {content="长度测试一二三四五六长度测试一二三四五六长度测试一二三四五六",ntype="label",color=ccc3(255,111,111)}
richTextInfo[4] = {content="测试按键",ntype="button",color=ccc3(0,111,255),tapFunc=showDesc}
local richTextLayer = LuaCCLabel.createRichText(richTextInfo)
--]]
function createRichText(richTextInfo)
    local limitWidth = richTextInfo.width or 640
    local priority = richTextInfo.priority or -128
    local rowHeights ={}
    local rowElements = {}
    
    local currentRowNumber = 1
    local currentRowWidth = 0
    
    local result = CCLayer:create()
    --local result = CCLayerColor:create(ccc4(111,111,111,166))
    result:retain()
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:setTouchPriority(priority)
    result:addChild(menu)
    
    for i=1,#richTextInfo do
        local nodeInfo = richTextInfo[i]
        --print("node content:",nodeInfo.content)
        local myNode = createRichTextNode(nodeInfo)
        --print("node width:",myNode:getContentSize().width)
        myNode:setAnchorPoint(ccp(0,0))
        if(myNode:getContentSize().width+currentRowWidth<=limitWidth)then
            if(nodeInfo.ntype=="button")then
                menu:addChild(myNode)
                local tag = nodeInfo.tag or 1
                myNode:setTag(tag)
                myNode:setAnchorPoint(ccp(0.5,0))
                myNode:setPositionX(currentRowWidth+myNode:getContentSize().width*0.5)
            else
                result:addChild(myNode)
                myNode:setPositionX(currentRowWidth)
            end
            
            if(rowElements[currentRowNumber]==nil)then
                rowElements[currentRowNumber] = {}
            end
            rowElements[currentRowNumber][#rowElements[currentRowNumber]+1] = myNode
            currentRowWidth = currentRowWidth + myNode:getContentSize().width
            if(rowHeights[currentRowNumber] == nil)then
                rowHeights[currentRowNumber] = 0
            end
            rowHeights[currentRowNumber] = rowHeights[currentRowNumber]>myNode:getContentSize().height and rowHeights[currentRowNumber] or myNode:getContentSize().height
        else
            if(nodeInfo.ntype=="button")then
                currentRowNumber = currentRowNumber+1
                currentRowWidth = myNode:getContentSize().width
                menu:addChild(myNode)
                --myNode:setPositionX(0)
                myNode:setAnchorPoint(ccp(0.5,0))
                myNode:setPositionX(myNode:getContentSize().width*0.5)
                
                if(rowElements[currentRowNumber]==nil)then
                    rowElements[currentRowNumber] = {}
                end
                rowElements[currentRowNumber][#rowElements[currentRowNumber]+1] = myNode
                if(rowHeights[currentRowNumber] == nil)then
                    rowHeights[currentRowNumber] = 0
                end
                rowHeights[currentRowNumber] = rowHeights[currentRowNumber]>myNode:getContentSize().height and rowHeights[currentRowNumber] or myNode:getContentSize().height
            else
                --print("================currentRowWidth out label==================")
                local fontSize = nodeInfo.fontSize or 21
                local content = nodeInfo.content or ""
                local font = nodeInfo.font or g_sFontName
                local color = nodeInfo.color or ccc3(255,255,255)
                
                local leftWidth = limitWidth - currentRowWidth
                local isEnd = false
                local startIndex = 1
                --print("mylabel:",CCLabelTTF:create(string.sub(content,1,2),font,fontSize):getContentSize().width,leftWidth)
                --[[
                if(CCLabelTTF:create(string.sub(content,1,3),font,fontSize):getContentSize().width>leftWidth)then
                    leftWidth = limitWidth
                    currentRowWidth = 0
                    currentRowNumber = currentRowNumber+1
                end
                 --]]
                
                --print("string.sub(content,startIndex,#content)",string.sub(content,startIndex,#content))
                while(isEnd==false)do
                    local leftLabel = CCLabelTTF:create(string.sub(content,startIndex,#content),font,fontSize)
                    --print("string.sub(content,startIndex,#content)",string.sub(content,startIndex,#content))
                    --print("leftLabel:",leftLabel:getContentSize().width,leftWidth)
                    if(leftLabel:getContentSize().width<=leftWidth)then
                        rowElements[currentRowNumber] = rowElements[currentRowNumber]==nil and {} or rowElements[currentRowNumber]
                        rowElements[currentRowNumber][#rowElements[currentRowNumber]+1]  = leftLabel
                        leftLabel:setAnchorPoint(ccp(0,0))
                        leftLabel:setPositionX(0)
                        result:addChild(leftLabel)
                        leftLabel:setColor(color)
                        
                        rowHeights[currentRowNumber] = fontSize
                        currentRowWidth = leftLabel:getContentSize().width
                        --print("currentRowWidth",currentRowWidth)
                        isEnd = true
                    else
                        --for a=startIndex,#content  do
                        local a = startIndex
                        while(a<=#content)do
                            --print("string.byte(content,a)",string.byte(content,a))
                            local backNumber = 1
                            if(string.byte(content,a)>0x7f)then
                                a = a+2
                                backNumber = 3
                            end
                            --print("startIndex",a)
                            --print("string.sub(content,startIndex,#content)",string.sub(content,startIndex,a))
                            leftLabel = CCLabelTTF:create(string.sub(content,startIndex,a),font,fontSize)
                            if(leftLabel:getContentSize().width>leftWidth)then
                                --print("startIndex,a",startIndex,a)
                                --print("turn")
                                a = a - backNumber

                                --[[
                                for l=1,5 do
                                    leftLabel = CCLabelTTF:create(string.sub(content,startIndex,a-l),font,fontSize)
                                    print("leftLabel width:",leftLabel:getContentSize().width)
                                    if(leftLabel:getContentSize().width>0)then
                                        backNumber = l
                                        break
                                    end
                                end
                                --]]
                                if(startIndex>=a-backNumber)then
                                    leftWidth = limitWidth
                                    currentRowWidth = 0
                                    currentRowNumber = currentRowNumber+1
                                    break
                                end
                                
                                leftLabel = CCLabelTTF:create(string.sub(content,startIndex,a),font,fontSize)
                                
                                leftLabel:setColor(color)
                                rowElements[currentRowNumber] = rowElements[currentRowNumber]==nil and {} or rowElements[currentRowNumber]
                                rowElements[currentRowNumber][#rowElements[currentRowNumber]+1]  = leftLabel
                                leftLabel:setAnchorPoint(ccp(0,0))
                                leftLabel:setPositionX(currentRowWidth)
                                result:addChild(leftLabel)
                                
                                rowHeights[currentRowNumber] = rowHeights[currentRowNumber]==nil and 0 or rowHeights[currentRowNumber]
                                rowHeights[currentRowNumber] = rowHeights[currentRowNumber]>fontSize and rowHeights[currentRowNumber] or fontSize
                                currentRowWidth = 0
                                --print("richtext backNumber:",backNumber,a,string.sub(content,startIndex,a-backNumber))
                                startIndex = a+1
                                break
                            end
                            a = a+1
                        end
                        
                        --print("do next")
                        leftWidth = limitWidth
                        currentRowNumber = currentRowNumber + 1
                    end
                    --isEnd = true
                end
                
                --[[
                 local leftWidth = limitWidth - currentRowWidth
                 local totalWidth = myNode:getContentSize().width
                 --new way
                 local blankLength = 0
                 local blankString = ""
                 --print("before blankLength,currentRowWidth:",blankLength,currentRowWidth)
                 while blankLength<currentRowWidth do
                 --print("blankLength,currentRowWidth:",blankLength,currentRowWidth)
                 blankString = " " .. blankString
                 local tempLabel = CCLabelTTF:create(blankString,font,fontSize)
                 --print("tempLabel:",tempLabel:getContentSize().width)
                 blankLength = tempLabel:getContentSize().width
                 end
                 content = blankString .. content
                 --创建新label
                 nodeInfo.text = content
                 nodeInfo.fontname = font
                 nodeInfo.fontsize = fontSize
                 nodeInfo.width = limitWidth
                 --local newNode = createRichTextNode(nodeInfo)
                 local newNode = createMultiLineLabels(nodeInfo)
                 newNode:setAnchorPoint(ccp(0,0))
                 newNode:setPositionX(0)
                 
                 result:addChild(newNode)
                 local tag = nodeInfo.tag or 1
                 newNode:setTag(tag)
                 
                 currentRowNumber = currentRowNumber+1
                 currentRowWidth = (myNode:getContentSize().width+currentRowWidth+newNode:getContentSize().height-nodeInfo.fontsize)%limitWidth
                 if(rowElements[currentRowNumber]==nil)then
                 rowElements[currentRowNumber] = {}
                 end
                 rowElements[currentRowNumber][#rowElements[currentRowNumber]+1] = newNode
                 if(rowHeights[currentRowNumber] == nil)then
                 rowHeights[currentRowNumber] = 0
                 end
                 rowHeights[currentRowNumber] = newNode:getContentSize().height - (rowHeights[currentRowNumber-1]==nil and 0 or myNode:getContentSize().height)
                 --]]
                
                --[[
                 local currentCharIndex = 1
                 
                 while(totalWidth>0) do
                 if(totalWidth>leftWidth)then
                 local subContent = string.sub(,(leftWidth/fontSize),)
                 else
                 end
                 end
                 --]]
            end
        end
        
        local tag = nodeInfo.tag or 1
        myNode:setTag(tag)
    end
    ---[[
    local totalHeight = 0
    for i=1,currentRowNumber do
        if(rowElements[i]~=nil and #rowElements[i]>0 and rowHeights[i]~=nil)then
--            print("totalHeight,rowHeights[i]",totalHeight,rowHeights[i])
            totalHeight = totalHeight + rowHeights[i]
            for j=1,#rowElements[i] do
                local labela = tolua.cast(rowElements[i][j],"CCLabelTTF")
                if(labela~=nil)then
                    --print("rowElements[i][j]:",labela:getString())
                end
                rowElements[i][j]:setPositionY(-totalHeight)
            end
        end
    end
    --]]
    
    result:setContentSize(CCSizeMake(limitWidth,totalHeight))
    result:release()
    return result
end

-- 释放LuaCCLabel模块相关资源
function release()
	LuaCCLabel = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/LuaCCLabel")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end
