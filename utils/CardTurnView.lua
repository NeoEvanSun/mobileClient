--Filename:CardTurnView.lua
--Author：zhz
--Date：2013-11-16
--Purpose:创建卡牌翻转效果


-- module("CardTurnView", package.seeall)


CardTurnView = class("CardTurnView", function ()
	local nodeContent = Widget:create()
	return nodeContent
end)

CardTurnView.__index = CardTurnView

CardTurnView.kInAngleZ   =  270  		--//里面卡牌的起始Z轴角度
CardTurnView.kInDeltaZ   =  90   		--//里面卡牌旋转的Z轴角度差
CardTurnView.kOutAngleZ  = 0  			--//封面卡牌的起始Z轴角度
CardTurnView.kOutDeltaZ  = 90   		--//封面卡牌旋转的Z轴角度差

CardTurnView.m_isOpened = nil
CardTurnView.inCard = nil
CardTurnView.outCard =nil


-- 创建翻牌node
function CardTurnView:create( inCard, outCard )--, callBack)
	local cardNode = CardTurnView:new()

	cardNode.m_isOpened = false

	-- 里面的图片
	cardNode.inCard = inCard
	cardNode.inCard:setPosition(ccp(0,0))
	cardNode.inCard:setVisible(false)
	cardNode.inCard:setAnchorPoint(ccp(0.5,0.5))
	cardNode:addChild(cardNode.inCard)

	-- 外面的图片
	cardNode.outCard =  outCard
	print("outCard 2 is : ", outCard)
	cardNode.outCard:setPosition(ccp(0,0))
	cardNode.outCard:setAnchorPoint(ccp(0.5,0.5))
	cardNode:addChild(cardNode.outCard)

	return cardNode
end


-- 打开卡牌的函数
function CardTurnView:openCard( duration, callback)
	local duration =  duration or 0.5

	local action1 = CCOrbitCamera:create(duration, 1, 0, 180, -90, 0, 0)
	local action2 = CCCallFunc:create(function ( ... )
		self.inCard:setVisible(true)

		local actionArr1 = CCArray:create()
		actionArr1:addObject(CCOrbitCamera:create(duration, 1, 0, 90, -90, 0, 0))
		actionArr1:addObject(CCCallFunc:create(function ( ... )
			if (callback) then
				callback()
			end
		end))
		self.inCard:runAction(CCSequence:create(actionArr1))

		local actionArr2 = CCArray:create()
		actionArr2:addObject(CCCallFunc:create(function ( ... )
			self.outCard:setVisible(false)
		end))
		self.outCard:runAction(CCSequence:create(actionArr2))
	end)

	local acitonArray = CCArray:create()
	acitonArray:addObject(action1)
	acitonArray:addObject(action2)

	self.outCard:runAction(CCSequence:create(acitonArray))
end

