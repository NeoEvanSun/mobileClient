-- Filename：	LevelUpUtil.lua
-- Author：		zhz
-- Date：		2013-08-15
-- Purpose：		升级的通用方法，level_up.lua
-- 增加经验值方法
module("LevelUpUtil",package.seeall)

--[[
	@desc	得到当前等级的经验 和 所需的经验
	@para 	id 		 : DB_Level_up_exp中的id，如宠物的id 为 3
			totalExp : 所有的经验
			level 	 : 当前的等级
	@return 当前等级下的经验 curExp 和 升级时所需需要的经验needExp
--]]
function getCurExp(  id ,totalExp,level)
	require "db/DB_Level_up_exp"
	local upExpData = DB_Level_up_exp.getDataById(tonumber(id))
	local lev= level+1
	local lv = "lv_".. lev
	local needExp = upExpData[lv]
	local curExp =0
	if(needExp == nil) then
		needExp =0
	end

	if(tonumber(level) == 0 ) then
		curExp = totalExp
	else
		for i = 1,level do
			local lv = "lv_" .. i
			totalExp= totalExp - upExpData[lv]
		end
		curExp = totalExp 
	end
	return curExp, needExp
end

-- 提供经验得到可以升到的级别
-- id: 升级经验表id
-- offerExp:提供的经验
function getLvByExp( id, offerExp)
	require "db/DB_Level_up_exp"
	local upExpData = DB_Level_up_exp.getDataById(tonumber(id))
	local curLv = 0
	local curExp = offerExp
	local needExp = 0
	while(true)do
		local nextLv = tonumber(curLv)+1
		needExp = upExpData["lv_".. nextLv]
		if(needExp ~= nil)then
			local subExp = tonumber(curExp) - tonumber(needExp)
			if(subExp >= 0)then
				curExp = subExp
				curLv = curLv + 1
			else
				break
			end
		else
			needExp = 0
			break
		end
	end
	return curLv,curExp,needExp
end

-- 解析升级表 add by Chengliang
function getNeedExpByIdAndLv( t_id, curLv )
	require "db/DB_Level_up_exp"
	local upExpData = DB_Level_up_exp.getDataById(tonumber(t_id))
	return upExpData["lv_"..curLv]
end

require "script/module/main/MainScene"

function showFloatText( tipText ,frontName, colors, time )
	local color = colors  or { red = 0xff, green=0xf6 , blue =0x00 }
	local timeInterval = time or 1

	if(frontName == nil) then
		frontName = g_sFontPangWa
	end
	
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	local tipNode = CCNode:create()
	-- tipNode:setScale(MainScene.elementScale)
	-- tipNode:setContentSize(CCSizeMake(g_winSize.width*0.8,g_winSize.height*0.2))
	-- tipNode:setPosition(ccp(runningScene:getContentSize().width*0.5 , runningScene:getContentSize().height*0.6))
	-- tipNode:setScale(g_fScaleX)
	runningScene:addChild(tipNode,2013)

	-- 描述 --CCLabelTTF:create(tipText, g_sFontPangWa, 34, CCSizeMake(315, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	local descLabel =  CCLabelTTF:create( tipText , g_sFontPangWa, 45)-- 2, ccc3(0x00, 0x00, 0x00), type_stroke)--, CCSizeMake(315*g_fScaleX,190*g_fScaleX),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	descLabel:setScale(g_fScaleX)
	descLabel:setColor(ccc3(color.red,color.green,color.blue))
	descLabel:setAnchorPoint(ccp(0.5, 0))
	local width = (runningScene:getContentSize().width)/2 
	descLabel:setPosition(ccp(width, runningScene:getContentSize().height*0.6))
	descLabel:setAnchorPoint(ccp(0.5,0))
	tipNode:addChild(descLabel)

	local actionArr = CCArray:create()
	descLabel:runAction(CCFadeOut:create(1))
	actionArr:addObject(CCFadeOut:create(1))
	actionArr:addObject(CCCallFuncN:create(endCallback))

	tipNode:runAction(CCSequence:create(actionArr))
end

function endCallback( tipNode )

	tipNode:removeFromParentAndCleanup(true)
	tipNode = nil
end 


-- fly 的文字

local function animatedEndAction( tipNode)

	tipNode:removeFromParentAndCleanup(true)
	tipNode = nil
	
end

function flyText( tipText ,frontName, colors, time,size)
	local color = colors or { red = 0x76, green=0xfc , blue =0x06 }

	local timeInterval = time or 0.8
	frontName = frontName or g_sFontPangWa
	size= size or 45

	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local tipNode = CCNode:create()
	runningScene:addChild(tipNode,2013)

	local delayTime = 0.7

	for i=1,#tipText do
		
		local descLabel = CCLabelTTF:create(tipText[i]  , g_sFontPangWa, 45)--, 1,ccc3(0x00,0x00,0x00), type_stroke)
		descLabel:setColor(ccc3(color.red,color.green,color.blue))
		descLabel:setScale(g_fScaleX)
		descLabel:setAnchorPoint(ccp(0.5, 1))
		local width = (runningScene:getContentSize().width )/2 -- +20
		descLabel:setPosition(ccp(width, runningScene:getContentSize().height*0.5))
		descLabel:setVisible(false)
		tipNode:addChild(descLabel)

		local nextMoveToP = ccp(width, runningScene:getContentSize().height*0.7)

		local actionArr = CCArray:create()
		
		actionArr:addObject(CCDelayTime:create(delayTime)) 
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			descLabel:setVisible(true)
		end))
		-- CCEaseOut:create(CCMoveTo:create(1.3, nextMoveToP),2)
		-- CCMoveTo:create(timeInterval, nextMoveToP
		actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1.3,nextMoveToP),2))
		actionArr:addObject(CCFadeOut:create(0.2))
		actionArr:addObject(CCCallFuncN:create(animatedEndAction))
		descLabel:runAction(CCSequence:create(actionArr))
		delayTime = delayTime + 0.3
	end

end


-- 改自animation 的效果图
local function fnEndCallback( tipSprite )
	tipSprite:removeFromParentAndCleanup(true)
	tipSprite = nil
end 

function showTip(tipText)
	local fullRect = CCRectMake(0,0,58,58)
	local insetRect = CCRectMake(20,20,18,18)

	local hSpace=30
	local vSpace=40
	local nWidth=510

	-- 描述
	local tLabel = {
		text=tipText, fontsize=28, color=ccc3(255, 255, 255), width=nWidth-hSpace, alignment=kCCTextAlignmentCenter, 
	}
	require "script/libs/LuaCCLabel"
	local descLabel = LuaCCLabel.createMultiLineLabels(tLabel)
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	--提示背景
	local tipSprite = CCScale9Sprite:create("images/tip/animate_tip_bg.png", fullRect, insetRect)

	local nHeight=descLabel:getContentSize().height + vSpace
	descLabel:setPosition(hSpace/2, nHeight-vSpace/2)

	tipSprite:setPreferredSize(CCSizeMake(nWidth, nHeight))
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
	-- btnFrameSp:setScale(bgLayer:getBgScale()/bgLayer:getElementScale())
	runningScene:addChild(tipSprite,2000)
	-- tipSprite:setCascadeOpacityEnabled(true)
	tipSprite:setScale(g_fScaleX)	
	tipSprite:addChild(descLabel)

	local nextMoveToP = ccp(runningScene:getContentSize().width/2, runningScene:getContentSize().height*0.75)

	local actionArr = CCArray:create()
	descLabel:runAction(CCFadeOut:create(4.0))
	actionArr:addObject(CCMoveTo:create(2, nextMoveToP))
	actionArr:addObject(CCFadeOut:create(2.0))
	
	actionArr:addObject(CCCallFuncN:create(fnEndCallback))

	tipSprite:runAction(CCSequence:create(actionArr))
end

local function NodeEndCallback( nodeContent)
	
	nodeContent:removeFromParentAndCleanup(true)
	nodeContent = nil
end


-- 主要是为了宠物升级文字使用, 多列文字
function showScaleTxt(node_table)
	
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local width = 0 
	local height =0 
	for k,v in pairs(node_table) do
		width = v:getContentSize().width
		height = height -  v:getContentSize().height
	end

	local nodeContent = CCNode:create()
	nodeContent:setContentSize(CCSizeMake(width, height))
	setAdaptNode(nodeContent)

	local tempHeight = 0
	for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0.5, 0))
        v:setPosition(0.5*width,tempHeight)
        nodeContent:addChild(v)
        tempHeight = tempHeight - v:getContentSize().height
    end
    runningScene:addChild(nodeContent)
    -- return nodeContent
    local actionArr = CCArray:create()
	--descLabel:runAction(CCFadeOut:create(1))
	actionArr:addObject(CCScaleBy:create(0.1,0.5))
	actionArr:addObject(CCFadeOut:create(1))
	actionArr:addObject(CCCallFuncN:create(NodeEndCallback))
	nodeContent:runAction(CCSequence:create(actionArr))

    nodeContent:setPosition(ccp(runningScene:getContentSize().width/2 , runningScene:getContentSize().height/2))
    nodeContent:setAnchorPoint(ccp(0.5,0.5))
end 

-- 修改缩放的文字
-- {txt=" 全体", num=2, color=ccc3(0x23,0x24,0x34), fontsize= 45 }, 
-- {txt=" 全体", num=-2, color=ccc3(0x24,0x45,0x53)},
function showScaleTip( )
	local runningScene = CCDirector:sharedDirector():getRunningScene()

	local fontname=g_sFontPangWa
	local fontsize= 150
	local color =  ccc3(0x76,0xfc,0x06)

	local alertContent = {}
	alertContent[1] = CCLabelTTF:create("全体", fontname, fontsize)--, 2, ccc3(0,0,0), type_stroke)
	alertContent[1]:setColor(color)
	alertContent[2] = CCLabelTTF:create("玩么",fontname,fontsize)--,2, ccc3(0,0,0), type_stroke)
	alertContent[2]:setColor(color)

	local descNode =  createVerticalNode(alertContent) -- BaseUI.createHorizontalNode(alertContent) --BaseUI.createHorizontalNode(alertContent)
	descNode:setScale(MainScene.elementScale)
	descNode:setAnchorPoint(ccp(0.5,0))
	descNode:setPosition(ccp(runningScene:getContentSize().width*0.5,runningScene:getContentSize().height*0.6))
	runningScene:addChild(descNode,20213)


	 local actionArr = CCArray:create()
	actionArr:addObject(CCScaleBy:create(0.1,0.5))
	actionArr:addObject(CCFadeOut:create(1))
	actionArr:addObject(CCCallFuncN:create(function ( ... )
		descNode:removeFromParentAndCleanup(true)
		descNode = nil
	end))
	descNode:runAction(CCSequence:create(actionArr))

	print("+======================== ============ ========= ===")
end



function createVerticalNode( node_table)
    local width = 0 
	local height =0 
	for k,v in pairs(node_table) do
		width = v:getContentSize().width
		height = height -  v:getContentSize().height
	end

	local nodeContent = CCNode:create()
	nodeContent:setContentSize(CCSizeMake(width, height))

	local tempHeight = 0
	for k,v in pairs(node_table) do
        v:setAnchorPoint(ccp(0.5, 0))
        v:setPosition(0.5*width,tempHeight)
        nodeContent:addChild(v)
        tempHeight = tempHeight - v:getContentSize().height
    end
   return nodeContent
end


function flyEndCallback( tipNode )

	tipNode:removeFromParentAndCleanup(true)
	tipNode = nil
end

-- function: showFlyText, 
-- example: 
-- tParam ={ 
-- 	{txt=" 全体", num=2, displayNumType=1, color=ccc3(0x23,0x24,0x34), fontsize= 45 }, 
-- 	{txt=" 全体", num=-2, displayNumType=1, color=ccc3(0x24,0x45,0x53)},
-- }
require "script/utils/BaseUI"
function showFlyText(tParam, callbackFunc, showpoint )
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	local tipNode = CCNode:create()
	runningScene:addChild(tipNode,999999999)
	local pWorldSize = runningScene:getContentSize()
	local pShowPoint = showpoint or ccp(pWorldSize.width*0.5,pWorldSize.height*0.5)
	local fontname 			= g_sFontPangWa
	local fontsize			= 45
	local displayNumType 	= 1 --显示形式  是否除以100/%百分比显示等   add by chengliang
	local colorPlus 		= ccc3(0x76,0xfc,0x06) -- { red = 0x76, green=0xfc , blue =0x06 }
	local colorMinus 		= ccc3(0xff,0x0,0x0)  -- red = 0x76, green=0xfc , blue =0x06
	local color
	local delayTime = 0.3
	for i=1, #tParam do
		fontname 		= tParam[i].fontname or fontname
		fontsize 		= tParam[i].fontsize or fontsize
		displayNumType 	= tParam[i].displayNumType or 1
		if(tonumber(tParam[i].num)>=0 ) then
			color=tParam[i].color or colorPlus
			tParam[i].txt= tParam[i].txt .. "+"
		else
			color=tParam[i].color or colorMinus
		end

		-- add by chengliang
		local displayNum = tParam[i].num
		if(tonumber(displayNumType) == 1)then
	    	displayNum = tParam[i].num
	    elseif(tonumber(displayNumType) == 2)then
			displayNum = tParam[i].num / 100
		elseif(tonumber(displayNumType) == 3)then
			displayNum = tParam[i].num / 100 .. "%"
	    end
		-- 文字 
		local alertContent = {}
		-- alertContent[1] = CCLabelTTF:create(tParam[i].txt .. displayNum , fontname, fontsize)--, 2, ccc3(0,0,0), type_stroke)
		alertContent[1] = UIHelper.createStrokeTTF(tParam[i].txt .. displayNum,ccc3(255,255,255),nil,nil,45,g_sFontPangWa)
		alertContent[1]:setColor(color)
		
		local descNode = alertContent[1] --BaseUI.createHorizontalNode(alertContent)
		-- descNode:setScale( MainScene.elementScale)
		descNode:setAnchorPoint(ccp(0.5,0.5))
		descNode:setPosition(pShowPoint)
		descNode:setVisible(false)
		tipNode:addChild(descNode)

		local nextMoveToP = ccp(pShowPoint.x, pShowPoint.y + pWorldSize.height*0.18)

		local actionArr = CCArray:create()
		actionArr:addObject(CCDelayTime:create(delayTime))
		--actionArr:addObject(CCFadeIn()) 
		actionArr:addObject(CCCallFuncN:create(function ( ... )
			descNode:setVisible(true)
		end))
		actionArr:addObject(CCEaseOut:create(CCMoveTo:create(1.3, nextMoveToP),2))
		--actionArr:addObject(CCDelayTime:create(0.2))
		actionArr:addObject(CCFadeOut:create(0.2))
		actionArr:addObject(CCCallFuncN:create(flyEndCallback))

		if(i==#tParam and callbackFunc ) then
			--actionArr:addObject(CCDelayTime:create(0.5))
			actionArr:addObject(CCCallFuncN:create(function ( ... )
				callbackFunc()
			end))
		end
		descNode:runAction(CCSequence:create(actionArr))

		delayTime = delayTime + 0.3
	end

end


