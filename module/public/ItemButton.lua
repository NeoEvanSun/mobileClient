-- FileName: ItemButton.lua 
-- Author: zhaoqiangjun 
-- Date: 14-4-2 
-- Purpose: 根据物品模板id创建一个物品按钮 


module("ItemButton", package.seeall)

local textTeg = 100

local itemTemidButton
-- 物品的id
local _itemTemid
-- 是否为碎片
local isfrag
-- 物品数量
local item_num

local local_itemInfo

local function getItemInfo()

	local itemInfo
	local db
	local laitemTemid = tonumber(_itemTemid)
	--装备
	if (laitemTemid >= 101101 and laitemTemid <= 104423) then
		print("int arming")
		require "db/DB_Item_arm"
		-- print(type(db))
		itemInfo = DB_Item_arm.getDataById(laitemTemid)
	--礼包
	elseif (laitemTemid >= 10001 and laitemTemid <= 12013) then 
		require "db/DB_Item_direct"
		itemInfo = DB_Item_direct.getDataById(laitemTemid)
	--时装
	elseif (laitemTemid >= 80001 and laitemTemid <= 80002) then
		require "db/DB_Item_dress"
		itemInfo = DB_Item_dress.getDataById(laitemTemid)
	--宠物饲料
	elseif (laitemTemid >= 50001 and laitemTemid <= 50405) then 
		require "db/DB_Item_feed"
		itemInfo = DB_Item_feed.getDataById(laitemTemid)
	--战魂
	elseif (laitemTemid >= 70001 and laitemTemid <= 72003) then
		require "db/DB_Item_fightsoul"
		itemInfo = DB_Item_fightsoul.getDataById(laitemTemid)
	--装备碎片
	elseif (laitemTemid >= 1000001 and laitemTemid <= 1044235) then
		require "db/DB_Item_fragment"
		itemInfo = DB_Item_fragment.getDataById(laitemTemid)
	--礼物
	elseif (laitemTemid >= 20001 and laitemTemid <= 20001) then
		require "db/DB_Item_gift"
		itemInfo = DB_Item_gift.getDataById(laitemTemid)
	--武魂（英雄碎片）
	elseif (laitemTemid >= 410001 and laitemTemid <= 410196) then
		require "db/DB_Item_hero_fragment"
		itemInfo = DB_Item_hero_fragment.getDataById(laitemTemid)
	--普通物品
	elseif (laitemTemid >= 60001 and laitemTemid <= 60212) then
		require "db/DB_Item_normal"
		itemInfo = DB_Item_normal.getDataById(laitemTemid)
	--随机礼物
	elseif (laitemTemid >= 30001 and laitemTemid <= 30301) then
		require "db/DB_Item_randgift"
		itemInfo = DB_Item_randgift.getDataById(laitemTemid)
	--stargift
	elseif (laitemTemid >= 40001 and laitemTemid <= 40056) then
		require "db/DB_Item_star_gift"
		itemInfo = DB_Item_star_gift.getDataById(laitemTemid)
	--宝物
	elseif (laitemTemid >= 501010 and laitemTemid <= 502506) then
		require "db/DB_Item_treasure"
		itemInfo = DB_Item_treasure.getDataById(laitemTemid)
	--宝物碎片
	elseif (laitemTemid >= 5013011 and laitemTemid <= 5010106) then
		require "db/DB_Item_treasure_fragment"
		itemInfo = DB_Item_treasure_fragment.getDataById(laitemTemid)
	end
	--金币，贝里
	
	return itemInfo
end

local function loadImageWithButton()

	-- 需要根据itemtemplateId来判断物品的类型。
	local itemInfo = getItemInfo()
	local_itemInfo = itemInfo
	if itemTemidButton then
		itemTemidButton:loadTextureNormal("images/base/potential/props_" .. itemInfo.quality .. ".png")
		-- itemTemidButton:loadTextureNormal("images/base/equip/small/" .. itemInfo.icon_small)
		local itemImage = ImageView:create()
		if(itemInfo.id >= 10001 and itemInfo.id <= 12013) then
			print("images/base/props/" .. itemInfo.icon_small)
			itemImage:loadTexture("images/base/props/" .. itemInfo.icon_small)
		else
			itemImage:loadTexture("images/base/equip/small/" .. itemInfo.icon_small)
		end
		
		itemImage:setAnchorPoint(ccp(0.5, 0.5))
		itemImage:setPosition(ccp(0, 0))
		itemTemidButton:addChild(itemImage)

		local topItemImage = ImageView:create()
		topItemImage:setAnchorPoint(ccp(0, 1.0))
		topItemImage:loadTexture("images/base/potential/lv_" .. itemInfo.quality .. ".png")
		topItemImage:setPosition(ccp(-itemTemidButton:getContentSize().width/2, itemTemidButton:getContentSize().height/2))
		itemTemidButton:addChild(topItemImage)

		local itemText = TextField:create()
		itemText:setAnchorPoint(ccp(0.5, 0.5))
		itemText:setText("0")
		itemText:setTag(textTeg)
		itemText:setPosition(ccp(-itemTemidButton:getContentSize().width/2 + topItemImage:getContentSize().width/2,itemTemidButton:getContentSize().height/2 -topItemImage:getContentSize().height/2))
		itemTemidButton:addChild(itemText)
	else
		print("创建按钮失败")
	end
end

function setItemNumber(selectButton, _item_num)

	item_num = _item_num
	local item_Text = selectButton:getChildByTag(textTeg)
	-- print("item_num .. " tostring(item_num))
	item_Text:setText(tostring(item_num))
end
--入口函数

function createWithItemTempid(itemTemid)

	itemTemidButton = Button:create()
	--物品的东东。
	_itemTemid = itemTemid
	--为物品加上内容
	loadImageWithButton()

	return itemTemidButton,local_itemInfo
end