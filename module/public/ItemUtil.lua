-- Filename：	ItemUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		物品Item

module("ItemUtil", package.seeall)


require "script/utils/LuaUtil"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"

require "db/DB_Item_arm"
require "db/DB_Item_treasure"
require "db/DB_Item_conch"
require "db/DB_Level_up_exp"
local m_dbArm = DB_Item_arm
local m_dbTreasure = DB_Item_treasure
local m_dbConch = DB_Item_conch
local _forwardDelegate = nil
local m_i18n = gi18n
local m_i18nString = gi18nString
local mSplit = string.split


local function addSignToIcon( icon, img_path )
	if (icon) then
		local imgShadow = ImageView:create()
	    imgShadow:loadTexture(img_path)
	    imgShadow:setPosition(ccp(-23, 23))
	    icon:addChild(imgShadow, 10,10)
	end
end

-- 添加物品图标左上角"碎"标记的坐标
function addSuiSignToWidget( widget )
	addSignToIcon(widget,"ui/tips_fragment_new.png")
end

function addSuiPianToWidget( widget )
	addSignToIcon(widget,"ui/tips_fragment.png")
end


--判断某个物品在背包中是否存在,道具背包
function getNumInBagByTid( tid )
	local propsInfo = DataCache.getRemoteBagInfo().props
	for gid, item in pairs(propsInfo) do
		local itemId = item.item_template_id
		if(tonumber(tid) == tonumber(itemId)) then
			local item_num = item.item_num
			return item_num
		end
	end
	return 0
end

-- 使用某个物品所获得的物品 i_id/i_num/isModifyCache <=> 物品templateid/个数/是否修改缓存
function getUseResultBy( i_id, i_num , isModifyCache)

	if(isModifyCache == nil) then
		isModifyCache = false
	end


	local useResult = nil
	local result = {}
	local result_text = ""
	require "db/DB_Item_direct"
	local i_data = DB_Item_direct.getDataById(i_id)

	if(i_data.coins and i_data.coins > 0) then
		result.coins = i_data.coins * i_num
		result_text = m_i18nString(1514, tostring(result.coins))  -- result_text  .. result.coins .. "贝里 "
	end
	if(i_data.golds and i_data.golds > 0) then
		result.golds = i_data.golds * i_num
		result_text = m_i18nString(1513, tostring(result.golds))  -- result_text  .. result.golds .. m_i18n[2220] -- 金币
	end
	if(i_data.energy and i_data.energy > 0) then
		result.energy = i_data.energy * i_num
		result_text = m_i18nString(1504, tostring(result.energy))  -- result_text  .. result.energy .. "体力 "
	end
	if(i_data.endurance and i_data.endurance > 0) then
		result.endurance = i_data.endurance * i_num
		result_text = m_i18nString(1503, tostring(result.endurance))  -- result_text  .. result.endurance .. "耐力 "
	end
	-- if(i_data.award_item_id and i_data.award_item_id > 0) then
	-- 	result.award_item_id = i_data.award_item_id
	-- 	local tempData = ItemUtil.getItemById(i_data.award_item_id)
	-- 	result_text = result_text  .. tempData.name .. " "
	-- 	tempData = nil
	-- end

	-- 英雄卡牌
	if(i_data.award_card_id) then

		local tempArr = mSplit(i_data.award_card_id , "|")

		result.award_card_id = tempArr[1]

		require "db/DB_Heroes"
		local tempData = DB_Heroes.getDataById(tonumber(tempArr[1]))
		result_text = m_i18nString(1516, tempData.name)  -- result_text  .. tempData.name .. " 卡牌"

		package.loaded["db/DB_Heroes"] = nil

	end
	if(i_data.add_challenge_times and i_data.add_challenge_times > 0) then
		result.add_challenge_times = i_data.add_challenge_times * i_num
		result_text = result_text  .. result.add_challenge_times .. "竞技场挑战次数 "
	end


	if ( result )then
		useResult = {}
		useResult.result = result
		useResult.result_text = result_text

		if(isModifyCache) then
			if (result.coins) then
				UserModel.addSilverNumber(result.coins)
			elseif(result.golds)then
				UserModel.addGoldNumber(result.golds)
			elseif(result.energy)then
				UserModel.addEnergyValue(result.energy)
			elseif(result.endurance)then
				UserModel.addStaminaNumber(result.endurance)
			end
		end
	end
	return useResult
end

-- 分男女 解析时装的字段
function getStringByFashionString( fashion_str )
	local t_fashion = splitFashionString(fashion_str)
	if(UserModel.getUserSex() == 1)then
		return t_fashion["20001"]
	else
		return t_fashion["20002"]
	end

end

function splitFashionString( fashion_str )
	local fashion_t = {}
	local f_t = mSplit(fashion_str, ",")
	for k,ff_t in pairs(f_t) do
		local s_t = mSplit(ff_t, "|")
		fashion_t[s_t[1]] = s_t[2]
	end

	return fashion_t
end

--[[desc: 根据template_id返回一个table，如果某个字段为true就表示这个类型
    tid: 物品的 template_id
    return: table, 不指定tid默认返回
    				{isDirect = false, isGift = false, isRandGift = false, isFeed = false, isNormal = false, isBook = false,
    				isStarGift = false, isShadow = false, isFragment = false, isArm = false, isTreasure = false,
    				isTreasureFragment = false, isConch = false, isDress = false,
    				}
—]]
function getItemTypeByTid( tid )
	local types = {isDirect = false, isGift = false, isRandGift = false, isFeed = false, isNormal = false,
		isBook = false, isStarGift = false, isShadow = false, isFragment = false, isArm = false,
		isTreasure = false, isTreasureFragment = false, isConch = false, isDress = false,
	}
	if (not tid) then
		return types
	end

	local i_id = tonumber(tid)
	if(i_id >= 10001 and i_id <= 20000) then -- 直接使用类：10001~30000
		types.isDirect = true
	elseif(i_id >= 20001 and i_id <= 30000) then -- 礼包类物品：
		types.isGift = true
	elseif(i_id >= 30001 and i_id <= 40000) then -- 随机礼包类：
		types.isRandGift = true
	elseif(i_id >= 50001 and i_id <= 60000) then -- 坐骑饲料类：50001~80000
		types.isFeed = true
	elseif(i_id >= 60001 and i_id <= 70000) then -- 普通物品
		types.isNormal = true
	elseif(i_id >= 200001 and i_id <= 300000) then -- 武将技能书：
		types.isBook = true
	elseif(i_id >= 40001 and i_id <= 50000) then -- 好感礼物类：100001~120000
		require "db/DB_Item_star_gift"
		types.isStarGift = true
	elseif(i_id >= 400001 and i_id <= 500000) then -- 武将碎片类：
		types.isShadow = true
	elseif(i_id >= 1000001 and i_id <= 5000000) then -- 装备碎片类：
		types.isFragment = true
	elseif(i_id >= 100001 and i_id <= 200000) then -- 装备类：
		types.isArm = true
	elseif(i_id >= 500001 and i_id <= 600000) then -- 宝物类：
		require "db/DB_Item_treasure"
		types.isTreasure = true
	elseif( i_id >= 5000001 and i_id <= 6000000 )then -- 宝物碎片
		types.isTreasureFragment = true
	elseif( i_id >= 70001 and i_id <= 80000 )then -- 空岛贝
		types.isConch = true
	elseif( i_id >= 80001 and i_id <= 90000 )then -- 时装
		types.isDress = true
	end
	return types
end


-- 通过ID获取某个物品的属性所有信息 i_id<=>item_template_id
--[[
modified by zhangqi, 2014-04-22, 给i_data增加两个属性
bgFullPath: 对应物品的品质背景图片路径
imgFullPath: 对应物品图片路径

modified by zhangqi, 2014-07-11, 给i_data增加一个属性
fnBagFull: 物品对应的背包满的检测方法
]]
local function fullWrapper( func ) -- 检查背包满的包装函数, 返回具体检查某个背包的方法, func 是具体检查某个背包满的函数
	return function ( show )
		logger:debug("fullWrapper")
		return func(show)
	end
end
function getItemById( i_id )
	i_id = tonumber(i_id)
	local i_data = nil
	if(i_id >= 10001 and i_id <= 20000) then -- 直接使用类：10001~30000
		require "db/DB_Item_direct"
		i_data = DB_Item_direct.getDataById(i_id)
		i_data.isDirect = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 20001 and i_id <= 30000) then -- 礼包类物品：
		require "db/DB_Item_gift"
		i_data = DB_Item_gift.getDataById(i_id)
		i_data.isGift = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 30001 and i_id <= 40000) then -- 随机礼包类：
		require "db/DB_Item_randgift"
		i_data = DB_Item_randgift.getDataById(i_id)
		i_data.isRandGift = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 50001 and i_id <= 60000) then -- 坐骑饲料类：50001~80000
		require "db/DB_Item_feed"
		i_data = DB_Item_feed.getDataById(i_id)
		i_data.isFeed = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 60001 and i_id <= 70000) then -- 普通物品
		require "db/DB_Item_normal"
		i_data = DB_Item_normal.getDataById(i_id)
		i_data.isNormal = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 40001 and i_id <= 50000) then -- 好感礼物类：100001~120000
		require "db/DB_Item_star_gift"
		i_data = DB_Item_star_gift.getDataById(i_id)
		i_data.isStarGift = true
		i_data.fnBagFull = fullWrapper(isPropBagFull)
	elseif(i_id >= 400001 and i_id <= 500000) then -- 武将碎片类：
		require "db/DB_Item_hero_fragment"
		i_data = DB_Item_hero_fragment.getDataById(i_id)
		i_data.isHeroFragment = true
		i_data.imgFullPath = "images/base/hero/head_icon/" .. i_data.icon_small
		i_data.fnBagFull = fullWrapper(isShadowBagFull)

		if (i_data.icon_big) then
			i_data.iconBigPath = "images/base/hero/body_img/" .. i_data.icon_big
		else
			i_data.iconBigPath = "images/base/hero/head_icon/" .. i_data.icon_small
		end
	elseif(i_id >= 1000001 and i_id <= 5000000) then -- 装备碎片类：
		require "db/DB_Item_fragment"
		i_data = DB_Item_fragment.getDataById(i_id)
		i_data.imgFullPath = "images/base/equip/small/" .. i_data.icon_small
		i_data.isFragment = true
		i_data.fnBagFull = fullWrapper(isArmFragBagFull)

		if (i_data.icon_big) then
			i_data.iconBigPath = "images/base/equip/big/" .. i_data.icon_big
		else
			i_data.iconBigPath = "images/base/equip/small/" .. i_data.icon_small
		end
	elseif(i_id >= 100001 and i_id <= 200000) then -- 装备类：
		require "db/DB_Item_arm"
		logger:debug(i_id)
		i_data = DB_Item_arm.getDataById(i_id)
		i_data.isArm = true
		i_data.desc = i_data.info
		i_data.imgFullPath = "images/base/equip/small/" .. i_data.icon_small
		i_data.fnBagFull = fullWrapper(isEquipBagFull)

		if (i_data.icon_big) then
			i_data.iconBigPath = "images/base/equip/big/" .. i_data.icon_big
		else
			i_data.iconBigPath = "images/base/equip/small/" .. i_data.icon_small
		end
	elseif(i_id >= 500001 and i_id <= 600000) then -- 宝物类：
		require "db/DB_Item_treasure"
		i_data = DB_Item_treasure.getDataById(i_id)
		i_data.isTreasure = true
		i_data.desc = i_data.info
		i_data.imgFullPath = "images/base/treas/small/" .. i_data.icon_small
		i_data.fnBagFull = fullWrapper(isTreasBagFull)

		if (i_data.icon_big) then
			i_data.iconBigPath = "images/base/treas/big/" .. i_data.icon_big
		else
			i_data.iconBigPath = "images/base/treas/small/" .. i_data.icon_small
		end
	elseif( i_id >= 5000001 and i_id <= 6000000 )then -- 宝物碎片
		require "db/DB_Item_treasure_fragment"
		i_data = DB_Item_treasure_fragment.getDataById(i_id)
		i_data.isTreasureFragment = true
		i_data.desc = i_data.info
		i_data.imgFullPath = "images/base/treas/small/" .. i_data.icon_small

		if (i_data.icon_big) then
			i_data.iconBigPath = "images/base/treas/big/" .. i_data.icon_big
		else
			i_data.iconBigPath = "images/base/treas/small/" .. i_data.icon_small
		end
	elseif( i_id >= 70001 and i_id <= 80000 )then -- 空岛贝
		require "db/DB_Item_conch"
		i_data = DB_Item_conch.getDataById(i_id)
		i_data.isConch = true
		i_data.desc = i_data.info
	elseif( i_id >= 80001 and i_id <= 90000 )then -- 时装
		require "db/DB_Item_dress"
		i_data = DB_Item_dress.getDataById(i_id)
		i_data.isDress = true
		i_data.desc = i_data.info
		i_data.imgFullPath = "images/base/fashion/small/" .. getStringByFashionString(i_data.icon_small)
	else
		logger:debug("item not found")
		return nil
	end

	i_data.imgFullPath = i_data.imgFullPath or ("images/base/props/" .. i_data.icon_small) -- 其他都是道具
	i_data.iconBigPath = i_data.iconBigPath or (i_data.icon_big and "images/base/props_big/" .. i_data.icon_big or "images/base/props/" .. i_data.icon_small) -- 其他都是道具

	i_data.bgFullPath = i_data.bgFullPath or ("images/base/potential/color_" .. i_data.quality .. ".png")
	i_data.borderFullPath = i_data.isHeroFragment and ("images/base/potential/officer_" .. i_data.quality .. ".png") or ("images/base/potential/equip_" .. i_data.quality .. ".png")

	return i_data
end

-- M_Type_Arm 		= 1 	-- 装备
-- M_Type_Prop 	= 2 	-- 道具
-- M_Type_Treas	= 3 	-- 宝物

-- -- 根据模板ID返回物品类型
-- function getItemTypeByTId( item_template_id )
-- 	local type_str = nil

-- 	if(item_template_id >= 100001 and item_template_id <= 200000) then
-- 		-- 装备类	：
-- 		type_str = M_Type_Arm
-- 	elseif(item_template_id >= 500001 and item_template_id <= 600000) then
-- 		-- 宝物
-- 		type_str = M_Type_Treas
-- 	else
-- 		-- 道具
-- 		type_str = M_Type_Prop
-- 	end

-- 	return type_str
-- end

-- 获取饲料
function getFeedInfos()
	local feedInfos = {}
	local allBagInfo = DataCache.getBagInfo()
	if(table.isEmpty( allBagInfo ) == false	) then
		for k, prop_info in pairs(allBagInfo.props) do
			if( tonumber(prop_info.item_template_id)>= 50001 and tonumber(prop_info.item_template_id)<60000 ) then
				table.insert(feedInfos, prop_info)
			end
		end
	end
	return feedInfos
end


-- 减少物品的个数    i_gid/i_num <=> 格子id/数量
function reduceItemByGid( i_gid, i_num, isForceDel )
	isForceDel = isForceDel or false
	i_gid = tonumber(i_gid)
	if(i_num == nil) then
		i_num = 1
	end
	local remoteBagInfo = DataCache.getRemoteBagInfo()
	local i_data_t = {}
	if (i_gid >= 2000001 and i_gid < 3000000 ) then
		-- 装备
		i_data_t = remoteBagInfo.arm
	elseif(i_gid >= 3000001 and i_gid < 4000000) then
		-- 道具
		i_data_t = remoteBagInfo.props
	elseif(i_gid >= 4000001 and i_gid < 5000000) then
		-- 武将碎片
		i_data_t = remoteBagInfo.heroFrag
	elseif(i_gid >= 5000001 and i_gid < 6000000) then
		-- 宝物
		i_data_t = remoteBagInfo.treas
	elseif(i_gid >= 6000001 and i_gid < 7000000)then
		-- 装备碎片
		i_data_t = remoteBagInfo.armFrag
	end

	if(not table.isEmpty(i_data_t))then
		-- 不是临时背包
		for r_gid, r_data in pairs(i_data_t) do
			if( tonumber(r_gid) == i_gid) then
				if(isForceDel == true)then
					--补充宝物和装备出售后 阵容红点的相关处理 by wangming 20150205
					if (i_gid >= 2000001 and i_gid < 3000000 ) then
						solveBagLackInfo(i_data_t[r_gid], 1)
					elseif(i_gid >= 5000001 and i_gid < 6000000) then
						solveBagLackInfo(i_data_t[r_gid], 2)
					end
					i_data_t[r_gid] = nil
				else
					if ( tonumber(r_data.item_num) <= i_num)then
						-- table.remove(i_data_t, r_gid)
						i_data_t[r_gid] = nil
					else
						i_data_t[r_gid].item_num = tonumber(r_data.item_num) - i_num
					end
				end
				if (i_gid >= 2000001 and i_gid < 3000000 ) then
					-- 装备

					remoteBagInfo.arm = i_data_t
				elseif(i_gid >= 3000001 and i_gid < 4000000) then
					-- 道具
					remoteBagInfo.props = i_data_t
				elseif(i_gid >= 4000001 and i_gid < 5000000) then
					-- 武将碎片
					remoteBagInfo.heroFrag = i_data_t
				elseif(i_gid >= 5000001 and i_gid < 6000000) then
					-- 宝物
					remoteBagInfo.treas = i_data_t
				elseif(i_gid >= 6000001 and i_gid < 7000000)then
					-- 装备碎片
					remoteBagInfo.armFrag = i_data_t
				end
				DataCache.setBagInfo(remoteBagInfo)
				break
			end
		end
	else
		-- 在临时背包
		local isFind = false
		if(not table.isEmpty(remoteBagInfo.arm))then
			-- 是不是装备
			for r_gid, r_data in pairs(remoteBagInfo.arm) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.arm[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.arm[r_gid] = nil
						else
							remoteBagInfo.arm[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.props))then
			-- 是不是道具
			for r_gid, r_data in pairs(remoteBagInfo.props) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.props[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.props[r_gid] = nil
						else
							remoteBagInfo.props[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.treas))then
			-- 是不是宝物
			for r_gid, r_data in pairs(remoteBagInfo.treas) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.treas[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.treas[r_gid] = nil
						else
							remoteBagInfo.treas[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.heroFrag))then
			-- 是不是武将碎片
			for r_gid, r_data in pairs(remoteBagInfo.heroFrag) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.heroFrag[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.heroFrag[r_gid] = nil
						else
							remoteBagInfo.heroFrag[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end

		if( isFind == false and not table.isEmpty(remoteBagInfo.armFrag))then
			-- 是不是装备碎片
			for r_gid, r_data in pairs(remoteBagInfo.armFrag) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.armFrag[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.armFrag[r_gid] = nil
						else
							remoteBagInfo.armFrag[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
	end
end
--[[
	获得装备的各种数值  为了提供战斗
-- 类型属性影射表
local _attributesMap = {
	{1, 11, "hp", "baseLife", "lifePL"},						
	{2, 12, "physical_attack", "basePhyAtt", "phyAttPL"},
	{3, 13, "magic_attack", "baseMagAtt", "magAttPL"},
	{4, 14, "physical_defend", "basePhyDef", "phyDefPL"},	
	{5, 15, "magic_defend", "baseMagDef", "magDefPL"},	
	{6, 16, "command", "XXXXXX", "XXXXXX"},
	{7, 17, "strength", "XXXXXX", "XXXXXX"},
	{8, 18, "intelligence", "XXXXXX", "XXXXXX"},
	{9, 19, "general_attack", "baseGenAtt", "genAttPL"},
	{10, 20, "talent_hp", "XXXXXX", "XXXXXX"},
	{11, 21, "talent_physical_attack", "XXXXXX", "XXXXXX"},
	{12, 22, "talent_magic_attack", "XXXXXX", "XXXXXX"},
	{13, 23, "talent_physical_defend", "XXXXXX", "XXXXXX"},
	{14, 24, "talent_magic_defend", "XXXXXX", "XXXXXX"},
}
	modified:zhangjunwu,计算战斗力用的
--]]
function getEquipValueByIID( i_id)
	i_id = tonumber(i_id)
	logger:debug(_tbequip)
	assert(i_id, "not found item_id:" .. i_id)

	local t_numerial = {}			 --zhangjunwu 2014-12-22 ,包括附魔的属性
	-- 获取装备数据
	local a_bagInfo = DataCache.getBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == i_id ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(i_id)

	end

	-- 别人身上的装备
	if(table.isEmpty(equipData))then
		logger:debug(_tbequip)
		equipData = _tbequip
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)
		end
	end
	-- 进行计算
	if( not table.isEmpty(equipData)) then
		require "db/DB_Item_arm"
		equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		--总属性=(基础值+等级*成长/100)*(1+附魔等级*附魔成长/10000)

		local equip_desc = equipData.itemDesc
		local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)
		local enchantLevel = tonumber(equipData.va_item_text.armEnchantLevel or 0)
		--附魔带来的属性
		local enchantFix = 1 + enchantLevel * (equip_desc.enchantAffix  or 0)/ 10000
		--附魔解锁带来的属性
		local enchantLockFix,enchantValueUnLocked = getEquipLockEnchantAffixBy(equipData)
		logger:debug(enchantValueUnLocked.hp)
		logger:debug(enchantFix)
		-- 生命值
		t_numerial.hp 		  = math.floor(math.floor(equip_desc.baseLife + forceLevel* equip_desc.lifePL/100) * enchantFix + 0.9999) + enchantValueUnLocked.hp
		-- 通用攻击
		-- t_numerial.gen_att	  = math.floor(equip_desc.baseGenAtt + forceLevel* equip_desc.genAttPL/100)
		-- 物攻
		t_numerial.physical_attack	 = math.floor(math.floor(equip_desc.basePhyAtt + forceLevel* equip_desc.phyAttPL/100) * enchantFix+ 0.9999) + enchantValueUnLocked.phy_att
		--	t_numerial.hp 		  = math.floor((equip_desc.baseLife + forceLevel* equip_desc.lifePL/100) * enchantFix)
		-- 魔攻
		t_numerial.magic_attack  = math.floor(math.floor(equip_desc.baseMagAtt + forceLevel* equip_desc.magAttPL/100) * enchantFix+ 0.9999) + enchantValueUnLocked.magic_att
		-- 物防
		t_numerial.physical_defend 	  = math.floor(math.floor(equip_desc.basePhyDef + forceLevel* equip_desc.phyDefPL/100) * enchantFix+ 0.9999) + enchantValueUnLocked.phy_def
		-- 魔防
		t_numerial.magic_defend  = math.floor(math.floor(equip_desc.baseMagDef + forceLevel* equip_desc.magDefPL/100) * enchantFix+ 0.9999) + enchantValueUnLocked.magic_def

	end
	return t_numerial
end
--[[
	获得装备的各种数值 
	parm	i_id<=>item_id
	return	t_numerial
			t_numerial.hp 		  
			t_numerial.phy_att	  
			t_numerial.magic_att 
			t_numerial.phy_def 	
			t_numerial.magic_def
	modified: zhangqi, 增加一个返回值，返回装备的详细信息
--]]
function getEquipNumerialByIID( i_id ,_tbequip)
	i_id = tonumber(i_id)
	logger:debug(_tbequip)
	assert(i_id, "not found item_id:" .. i_id)

	local t_numerial = {}			 --zhangjunwu 2014-12-22 ,包括附魔的属性
	local t_numerial_pl = {}
	local t_numerial_noEnchant = {}  --zhangjunwu 2014-12-22 ,不包括附魔的属性 --用于附魔模块的计算
	local t_numerial_enchantPL = {}
	local t_equip_score = 0
	-- 获取装备数据
	local a_bagInfo = DataCache.getBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == i_id ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(i_id)
		-- if( not table.isEmpty(equipData))then
		-- 	require "db/DB_Item_arm"
		-- 	equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		-- end
	end

	-- 别人身上的装备
	if(table.isEmpty(equipData))then
		logger:debug(_tbequip)
		equipData = _tbequip
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)
		end
	end
	-- 进行计算
	if( not table.isEmpty(equipData)) then
		require "db/DB_Item_arm"
		equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)
		--		 向下取整     整体向上取整
		--总属性= int[(基础值+等级*成长/100)] *(1+附魔等级*附魔成长/10000)

		local equip_desc = equipData.itemDesc
		local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)
		local enchantLevel = tonumber(equipData.va_item_text.armEnchantLevel or 0)
		--附魔带来的属性百分比
		local enchantPercent = 1 + enchantLevel * (equip_desc.enchantAffix  or 0)/ 10000
		--附魔解锁带来的属性
		local enchantLockFix,enchantValueUnLocked = getEquipLockEnchantAffixBy(equipData)
		-- 生命值
		t_numerial_noEnchant.hp 		  	= math.floor(equip_desc.baseLife + forceLevel* equip_desc.lifePL/100)
		-- 通用攻击
		-- 物攻
		t_numerial_noEnchant.phy_att	 	= math.floor(equip_desc.basePhyAtt + forceLevel* equip_desc.phyAttPL/100)
		t_numerial_noEnchant.hp 		  	= math.floor(equip_desc.baseLife + forceLevel* equip_desc.lifePL/100)
		-- 魔攻
		t_numerial_noEnchant.magic_att  	= math.floor(equip_desc.baseMagAtt + forceLevel* equip_desc.magAttPL/100)
		-- 物防
		t_numerial_noEnchant.phy_def 	  	= math.floor(equip_desc.basePhyDef + forceLevel* equip_desc.phyDefPL/100)
		-- 魔防
		t_numerial_noEnchant.magic_def  	= math.floor(equip_desc.baseMagDef + forceLevel* equip_desc.magDefPL/100)
		-- 生命值
		t_numerial.hp 		  				= math.floor(t_numerial_noEnchant.hp  * enchantPercent + 0.9999) + enchantValueUnLocked.hp
		-- 通用攻击
		-- 物攻
		t_numerial.phy_att	  				= math.floor(t_numerial_noEnchant.phy_att * enchantPercent+0.9999) + enchantValueUnLocked.phy_att
		--	t_numerial.hp 		  = math.floor((equip_desc.baseLife + forceLevel* equip_desc.lifePL/100) * enchantPercent)
		-- 魔攻
		t_numerial.magic_att 				= math.floor(t_numerial_noEnchant.magic_att * enchantPercent + 0.9999) + enchantValueUnLocked.magic_att
		-- 物防
		t_numerial.phy_def 	  				= math.floor(t_numerial_noEnchant.phy_def * enchantPercent + 0.9999) + enchantValueUnLocked.phy_def
		-- 魔防
		t_numerial.magic_def  				= math.floor(t_numerial_noEnchant.magic_def *  enchantPercent + 0.9999) + enchantValueUnLocked.magic_def
		t_numerial_pl.hp					= math.floor(equip_desc.lifePL/100)
		-- t_numerial_pl.gen_att	= math.floor(equip_desc.genAttPL/100)
		t_numerial_pl.phy_att				= math.floor(equip_desc.phyAttPL/100)
		t_numerial_pl.magic_att				= math.floor(equip_desc.magAttPL/100)
		t_numerial_pl.phy_def				= math.floor(equip_desc.phyDefPL/100)
		t_numerial_pl.magic_def				= math.floor(equip_desc.magDefPL/100)

		--附魔属性百分比
		local enchantAffixValue = (equip_desc.enchantAffix  or 0)
		if(t_numerial_pl.hp ~= 0)then
			t_numerial_enchantPL.hp						= math.floor(enchantAffixValue * enchantLevel/100)
		else
			t_numerial_enchantPL.hp	 = nil
		end		

		if(t_numerial_pl.phy_att ~= 0)then
			t_numerial_enchantPL.phy_att						= math.floor(enchantAffixValue * enchantLevel/100)
		else
			t_numerial_enchantPL.phy_att	 = nil
		end

		if(t_numerial_pl.magic_att ~= 0)then
			t_numerial_enchantPL.magic_att						= math.floor(enchantAffixValue * enchantLevel/100)
		else
			t_numerial_enchantPL.magic_att	 = nil
		end

		if(t_numerial_pl.phy_def ~= 0)then
			t_numerial_enchantPL.phy_def						= math.floor(enchantAffixValue * enchantLevel/100)
		else
			t_numerial_enchantPL.phy_def	 = nil
		end

		if(t_numerial_pl.magic_def ~= 0)then
			t_numerial_enchantPL.magic_def						= math.floor(enchantAffixValue * enchantLevel/100)
		else
			t_numerial_enchantPL.magic_def	 = nil
		end

		t_equip_score = equip_desc.base_score + forceLevel* equip_desc.grow_score
	end
	return t_numerial, t_numerial_pl, t_equip_score, equipData,t_numerial_enchantPL
end

-- zhangqi, 2015-02-26, 从伙伴身上获取指定item_id的空岛贝信息
function getConchFromHeroByItemId( itemId )
	local arrConchs = HeroUtil.getAllConchOnHeros()
	if ( not table.isEmpty(arrConchs)) then
		local nItemId = tonumber(itemId)
		for item_id, conch in pairs(arrConchs) do
			if (tonumber(item_id) == nItemId) then
				return conch
			end
		end
	end
	return nil
end

--[[
	zhangqi, 2015-02-26, 获得空岛贝的各种数值 
	parm	pItemId:item_id,
			bRemote:true, 从原始背包获取空岛贝信息;false, 从背包缓存数据获取；
			pConch:别人身上的空岛贝信息，外部获取后传入用于计算
	return	tbAttr:存放所有最终属性值的table，每个属性值是一个name和num组成的table
--]]
function getConchNumerialByItemId(pItemId, bRemote, pConch )
	-- 背包里获取指定item_id的空岛贝信息
	--[[
	1 = {
		item_template_id = "70102"
		item_num = "1"
		va_item_text = {
			level = "0"
			exp = "0"
			}	
		gid = "7000007"
		item_id = "1299196"
		item_time = "1424848245.000000"
		}
]]
	local nItemId = tonumber(pItemId)

	local tbBagInfo = bRemote and DataCache.getRemoteBagInfo() or DataCache.getBagInfo()

	local bagConch = nil
	for k, data in pairs(tbBagInfo.conch) do
		if( tonumber(data.item_id) == nItemId ) then
			bagConch = data
			break
		end
	end

	-- 如果为空则是伙伴已装备的
	if(not bagConch)then
		bagConch = getConchFromHeroByItemId(pItemId)
	end

	-- 别人身上的
	if(not bagConch )then
		logger:debug(pConch)
		bagConch = pConch
	end

	assert(bagConch, "getConchNumerialByItemId: " .. tostring(pItemId))

	local level = bagConch.va_item_text.level
	-- local exp = bagConch.va_item_text.exp

	-- 获取配置表信息
	local dbConch = bagConch.itemDesc
	if (not dbConch) then
		require "db/DB_Item_conch"
		dbConch = DB_Item_conch.getDataById(bagConch.item_template_id)
	end

	local baseAtt = string.strsplit(dbConch.baseAtt, "|")
	local growAtt = string.strsplit(dbConch.growAtt, "|")
	-- 属性配置表 return affixDesc, displayNum, realNum
	local dbAffixBase, displayNumBase, realNumBase = getAtrrNameAndNum( baseAtt[1], baseAtt[2] )
	local dbAffixGrow, displayNumGrow, realNumGrow = getAtrrNameAndNum( growAtt[1], growAtt[2] )

	-- 空岛贝属性1=空岛贝属性1基础值+空岛贝属性1成长值*（空岛贝等级）
	local attNum = tonumber(baseAtt[2]) + tonumber(growAtt[2]) * tonumber(level)
	local tbAttr = {}
	table.insert(tbAttr, {name = dbAffixBase.displayName, num = attNum})

	return tbAttr
end

-- zhangqi, 2015-01-14, 获取装备的最大附魔等级
-- tbEquip: 装备背包中的一个装备信息
function getMaxEnchatLevel(tbEquip)
	local dbEquipt = tbEquip.itemDesc or DB_Item_arm.getDataById(tbEquip.item_template_id) --表里配的最大附魔等级

	if (dbEquipt.canEnchant == 0) then -- 不能附魔
		return 0
	end

	local maxEnchantLV = dbEquipt.maxEnchantLV

    --modife zhangjunwu 2015-4-13 
	--装备当前的附魔等级上限 = min（最大附魔等级，int((装备强化等级/附魔等级间隔参数1） + 1）  * 附魔等级间隔参数2）
	local  enchantLVlimit = dbEquipt.enchantLVlimit or 0
	--强化等级
	local  pArmReinforceLevel = tbEquip.va_item_text.armReinforceLevel  or 0
	local  str1 = lua_string_split(enchantLVlimit, "|")
	local param1 = tonumber(str1[1])
	local param2 = tonumber(str1[2])
	if(tonumber(enchantLVlimit) ==  0) then
		return maxEnchantLV
	else
		local curMaxLv 	=  math.floor(pArmReinforceLevel  / param1 + 1) * param2
		logger:debug("表中最大附魔等级是:"  .. maxEnchantLV .. "计算的最发附魔等级是:" .. curMaxLv)
		return maxEnchantLV  >  curMaxLv and curMaxLv or maxEnchantLV
	end
end

-- zhangqi, 2015-01-14, 获取宝物的强化上限
function getMaxStrenthLevelOfTreas( tbTreas )
	if (not tbTreas.va_item_text.treasureLevel) then
		return 0
	end

	local dbTreas = tbTreas.itemDesc or DB_Item_treasure.getDataById(tbTreas.item_template_id)
	local curMaxLv = 0
	if (dbTreas.level_interval ~= 0) then
		curMaxLv = math.floor(UserModel.getHeroLevel() / dbTreas.level_interval)
		if (curMaxLv > dbTreas.level_limited) then
			curMaxLv = dbTreas.level_limited
		end
	end
	return curMaxLv
end

-- zhangqi, 2015-01-14, 获取宝物的精炼上限
function getMaxRefineLevelOfTreas( tbTreas )
	logger:debug("getMaxRefineLevelOfTreas")
	logger:debug(tbTreas)
	local dbTreas = tbTreas.itemDesc or DB_Item_treasure.getDataById(tbTreas.item_template_id)
	if (dbTreas.isUpgrade ~= 1) then
		return 0 -- 如果宝物不能精炼则返回0
	end
	logger:debug("%s 可以精炼", dbTreas.name)

	require "db/DB_Treasurerefine"
	local refineInfo = DB_Treasurerefine.getDataById(dbTreas.costId)
	logger:debug("refineInfo.max_upgrade_level = %d, refineInfo.refine_interval = %d", refineInfo.max_upgrade_level, refineInfo.refine_interval)
	local maxCfgLv = tonumber(refineInfo.max_upgrade_level)
	local curMaxLv = 0
	if (refineInfo.refine_interval ~= 0) then
		curMaxLv = math.floor(tonumber(tbTreas.va_item_text.treasureLevel) / refineInfo.refine_interval)
		if (curMaxLv > maxCfgLv) then
			curMaxLv = maxCfgLv
		end
	end
	return curMaxLv
end

--获得装备的附魔解锁属性
function getEquipLockEnchantAffixBy(equipData)
	--解锁属性
	local  addEnchantAffix = equipData.itemDesc.addEnchantAffix
	logger:debug(addEnchantAffix)

	local tbAffixInfo  = mSplit(addEnchantAffix,",") or {}

	local curEnchatLv = equipData.va_item_text.armEnchantLevel or 0
	logger:debug(curEnchatLv)
	-- 所有的解锁属性
	local ext_active = {}
	--已解锁的属性
	local unLockedAttrValue = { hp = 0, phy_att = 0 , magic_att = 0, phy_def = 0, magic_def = 0,}
	for k, str_act in pairs(tbAffixInfo) do
		local temp_act_arr = mSplit(str_act, "|")
		local t_ext_active = {}
		t_ext_active.openLv = tonumber(temp_act_arr[1])
		t_ext_active.attId 	= tonumber(temp_act_arr[2])
		t_ext_active.value = tonumber(temp_act_arr[3])
		t_ext_active.isOpen = tonumber(curEnchatLv) >= tonumber(temp_act_arr[1])
		if(t_ext_active.isOpen == true) then
			for k,v in pairs(g_LockAttrNameConfig) do
				if(t_ext_active.attId == tonumber(k)) then
					unLockedAttrValue[v] = t_ext_active.value
					break
				end
			end


		end
		table.insert(ext_active, t_ext_active)
	end
	logger:debug(ext_active)
	logger:debug(unLockedAttrValue)
	return ext_active ,unLockedAttrValue
end
--[[
	获得装备的各种数值 
	parm	i_id<=>item_id
	return	t_numerial
			t_numerial.hp 		  
			t_numerial.phy_att	  
			t_numerial.magic_att 
			t_numerial.phy_def 	
			t_numerial.magic_def
	modified: zhangjunwu, 增加一个返回值，返回装备的详细信息  本地背包还没有及时刷新的情况:
--]]
function getEquipNumerialByIIDFromRemoteBag( i_id ,_tbequip)
	i_id = tonumber(i_id)
	logger:debug(_tbequip)
	assert(i_id, "not found item_id:" .. i_id)

	local t_numerial = {}
	local t_numerial_pl = {}
	local t_equip_score = 0
	-- 获取装备数据
	local a_bagInfo = DataCache.getRemoteBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == i_id ) then
			equipData = s_data
			break
		end
	end



	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(i_id)
	end

	-- 别人身上的装备
	if(table.isEmpty(equipData))then
		logger:debug(_tbequip)
		equipData = _tbequip
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)
		end
	end
	-- 进行计算
	if( not table.isEmpty(equipData)) then
		require "db/DB_Item_arm"
		equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		local equip_desc = equipData.itemDesc
		local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)

		-- 生命值
		t_numerial.hp 		  = math.floor(equip_desc.baseLife + forceLevel* equip_desc.lifePL/100)
		-- 通用攻击
		-- t_numerial.gen_att	  = math.floor(equip_desc.baseGenAtt + forceLevel* equip_desc.genAttPL/100)
		-- 物攻
		t_numerial.phy_att	  = math.floor(equip_desc.basePhyAtt + forceLevel* equip_desc.phyAttPL/100)
		-- 魔攻
		t_numerial.magic_att  = math.floor(equip_desc.baseMagAtt + forceLevel* equip_desc.magAttPL/100)
		-- 物防
		t_numerial.phy_def 	  = math.floor(equip_desc.basePhyDef + forceLevel* equip_desc.phyDefPL/100)
		-- 魔防
		t_numerial.magic_def  = math.floor(equip_desc.baseMagDef + forceLevel* equip_desc.magDefPL/100)

		t_numerial_pl.hp		= math.floor(equip_desc.lifePL/100)
		-- t_numerial_pl.gen_att	= math.floor(equip_desc.genAttPL/100)
		t_numerial_pl.phy_att	= math.floor(equip_desc.phyAttPL/100)
		t_numerial_pl.magic_att	= math.floor(equip_desc.magAttPL/100)
		t_numerial_pl.phy_def	= math.floor(equip_desc.phyDefPL/100)
		t_numerial_pl.magic_def	= math.floor(equip_desc.magDefPL/100)

		logger:debug(equip_desc)
		logger:debug(equip_desc.base_score)
		t_equip_score = equip_desc.base_score + forceLevel* equip_desc.grow_score
	end
	return t_numerial, t_numerial_pl, t_equip_score, equipData
end
-- 获得前两条数据用于显示
function getTop2NumeralByIID( i_id )

	if(type(i_id) ~= "number") then
		logger:debug("getTop2NumeralByIID(), 参数必须是number")
		return
	end

	local t_numerial, t_numerial_pl, t_equip_score ,t_numerial_noEnchat = getEquipNumerialByIID(i_id)
	local f_data = 0
	local f_key  = nil
	local s_data = 0
	local s_key  = nil

	local TN_data = 0
	local TN_key  = nil
	for key, t_num in pairs(t_numerial) do
		if(f_data == nil) then
			f_key  = key
			f_data = t_num
		elseif( t_num > f_data ) then
			s_key  = f_key
			s_data = f_data
			f_key  = key
			f_data = t_num
		elseif( t_num > s_data) then
			s_key  = key
			s_data = t_num
		end
	end
	local tmplData = {}
	local tmplData_PL = {}
	local tmplData_NoEnchat = {}
	if (f_key) then
		tmplData[f_key] = f_data
		tmplData_PL[f_key] = t_numerial_pl[f_key]
		tmplData_NoEnchat[f_key] = t_numerial_noEnchat[f_key]
	end
	if (s_key) then
		tmplData[s_key] = s_data
		tmplData_PL[s_key] = t_numerial_pl[s_key]
		tmplData_NoEnchat[s_key] = t_numerial_noEnchat[s_key]
	end
	return tmplData, tmplData_PL, t_equip_score,tmplData_NoEnchat
end


--[[
	获得装备的各种数值  
	parm	tmpl_id<=>item_template_id
	return	t_numerial
			t_numerial.hp 		  
			t_numerial.phy_att	  
			t_numerial.magic_att 
			t_numerial.phy_def 	
			t_numerial.magic_def
--]]
function getEquipNumerialByTmplID( tmpl_id )
	if(type(tmpl_id) ~= "number") then
		logger:debug("参数必须是number")
		return
	end
	local t_numerial 	= {}
	local t_numerial_pl = {}
	local t_equip_score = 0
	-- 获取装备数据
	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(tmpl_id)


	-- 生命值
	t_numerial.hp 		  = equip_desc.baseLife
	-- 通用攻击
	-- t_numerial.gen_att	  = equip_desc.baseGenAtt
	-- 物攻
	t_numerial.phy_att	  = equip_desc.basePhyAtt
	-- 魔攻
	t_numerial.magic_att  = equip_desc.baseMagAtt
	-- 物防
	t_numerial.phy_def 	  = equip_desc.basePhyDef
	-- 魔防
	t_numerial.magic_def  = equip_desc.baseMagDef

	t_numerial_pl.hp		= math.floor(equip_desc.lifePL/100)
	-- t_numerial_pl.gen_att	= math.floor(equip_desc.genAttPL/100)
	t_numerial_pl.phy_att	= math.floor(equip_desc.phyAttPL/100)
	t_numerial_pl.magic_att	= math.floor(equip_desc.magAttPL/100)
	t_numerial_pl.phy_def	= math.floor(equip_desc.phyDefPL/100)
	t_numerial_pl.magic_def	= math.floor(equip_desc.magDefPL/100)

	t_equip_score = equip_desc.base_score



	return t_numerial, t_numerial_pl, t_equip_score
end

function getTop2NumeralByTmplID( tmpl_id )
	if(type(tmpl_id) ~= "number") then
		logger:debug("getTop2NumeralByIID(), 参数必须是number")
		return
	end

	local t_numerial, t_numerial_pl, t_equip_score = getEquipNumerialByTmplID(tmpl_id)
	local f_data = 0
	local f_key  = nil
	local s_data = 0
	local s_key  = nil
	for key, t_num in pairs(t_numerial) do
		if(f_data == 0) then
			f_key  = key
			f_data = t_num
		elseif( t_num > f_data ) then
			s_key  = f_key
			s_data = f_data
			f_key  = key
			f_data = t_num
		elseif( t_num > s_data) then
			s_key  = key
			s_data = t_num
		end
	end

	local tmplData = {}
	local tmplData_PL = {}
	if (f_key) then
		tmplData[f_key] = f_data
		tmplData_PL[f_key] = t_numerial_pl[f_key]
	end
	if (s_key) then
		tmplData[s_key] = s_data
		tmplData_PL[s_key] = t_numerial_pl[s_key]
	end

	return tmplData, tmplData_PL, t_equip_score
end


-- 根据item_id 获取缓存信息
function getItemInfoByItemId( i_id )
	i_id = tonumber(i_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_info = nil

	for g_id, item_data in pairs(allBagInfo.treas) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end

	for g_id, item_data in pairs(allBagInfo.arm) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end
	for g_id, item_data in pairs(allBagInfo.props) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end
	for g_id, item_data in pairs(allBagInfo.heroFrag) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end

	for g_id, item_data in pairs(allBagInfo.armFrag) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end

	if( table.isEmpty(allBagInfo.fightSoul) == false )then
		for g_id, item_data in pairs(allBagInfo.fightSoul) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end
	if(table.isEmpty(allBagInfo.dress) == false)then
		for g_id, item_data in pairs(allBagInfo.dress) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	return nil
end

-- 从hero身上获取装备xinxi
function getEquipInfoFromHeroByItemId( item_id )
	local equipInfo = nil
	local t_equips = HeroUtil.getEquipsOnHeros()

	if ( not table.isEmpty (t_equips)) then
		for t_item_id, t_equipInfo in pairs(t_equips) do
			if(item_id == tonumber(t_item_id)) then
				equipInfo = t_equipInfo
				break
			end
		end
	end

	return equipInfo
end

-- 从hero身上获取宝物信息
function getTreasInfoFromHeroByItemId( item_id )
	local treasInfo = nil
	local t_treas = HeroUtil.getTreasOnHeros()

	if ( not table.isEmpty (t_treas)) then
		for t_item_id, t_treasInfo in pairs(t_treas) do
			if(item_id == tonumber(t_item_id)) then
				treasInfo = t_treasInfo
				break
			end
		end
	end

	return treasInfo
end



--[[
	@desc	背包里面是否有该物品
	@para 	item_template_id
	@return bool true/false <=> 有/无
--]]
function isItemInBagBy( item_tid )
	local r_cacheData = DataCache.getRemoteBagInfo()
	local tempData = {}
	local isHas = false
	if( not table.isEmpty(r_cacheData))then
		if( item_tid >= 100001 and item_tid <= 200000 ) then
			-- 装备
			tempData = r_cacheData.arm

		elseif(item_tid >= 400001 and item_tid <= 500000) then
			-- 武将碎片
			tempData = r_cacheData.heroFrag
		else
			-- 物品
			tempData = r_cacheData.props
		end
		if( not table.isEmpty(tempData))then
			for k, item_info in pairs(tempData) do
				if(tonumber(item_tid) == tonumber(item_info.item_template_id) ) then
					isHas = true
					break
				end
			end
		end
	end
	return isHas
end

-- 道具格子回调
function openPropGridsCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		UserModel.addGoldNumber(-BagUtil.getNextOpenPropGridPrice())
		AnimationTip.showTip("购买成功，增加5个道具背包携带上限")
		DataCache.addGidNumBy( 2, 5 )
		if(MainScene.getOnRunningLayerSign() == "bagLayer")then
			BagLayer.createItemNumbersSprite()
		end
	end
end

-- 装备格子回调
function openArmGridsCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		UserModel.addGoldNumber(-BagUtil.getNextOpenArmGridPrice())
		AnimationTip.showTip("购买成功，增加5个装备背包携带上限")
		DataCache.addGidNumBy( 1, 5 )
		if(MainScene.getOnRunningLayerSign() == "bagLayer")then
			BagLayer.createItemNumbersSprite()
		end
	end
end

-- 宝物格子回调
function openTreasGridsCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		UserModel.addGoldNumber(-BagUtil.getNextOpenTreasGridPrice())
		AnimationTip.showTip("购买成功，增加5个宝物背包携带上限")
		DataCache.addGidNumBy( 3, 5 )
		if(MainScene.getOnRunningLayerSign() == "bagLayer")then
			BagLayer.createItemNumbersSprite()
		end
	end
end

-- 装备碎片
function openArmFragCallback( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		UserModel.addGoldNumber(-BagUtil.getNextOpenArmFragGridPrice())
		AnimationTip.showTip("购买成功，增加5个装备碎片背包携带上限")
		DataCache.addGidNumBy( 4, 5 )
		if(MainScene.getOnRunningLayerSign() == "bagLayer")then
			BagLayer.createItemNumbersSprite()
		end
	end
end

-- 开启宝物格子
function realOpenTreasGrid(isConfirm)
	if(isConfirm == true) then
		local args = Network.argsHandler(5, 3)
		RequestCenter.bag_openGridByGold(openTreasGridsCallback, args)
	end
end

-- 开启装备格子
function realOpenEquipGrid(isConfirm)
	if(isConfirm == true) then
		local args = Network.argsHandler(5, 1)
		RequestCenter.bag_openGridByGold(openArmGridsCallback, args)
	end
end

-- 开启道具格子
function realOpenPropsGrid(isConfirm)
	if(isConfirm == true)then
		local args = Network.argsHandler(5, 2)
		RequestCenter.bag_openGridByGold(openPropGridsCallback, args)
	end
end

-- 开启装备碎片格子
function realOpenArmFragGrid(isConfirm)
	if(isConfirm == true) then
		local args = Network.argsHandler(5, 4)
		RequestCenter.bag_openGridByGold(openArmFragCallback, args)
	end
end

-- 影子背包是否已满，2014-07-22, zhangqi
-- 影子背包不需要判断背包满，为了保持接口一致，始终返回false表示影子背包未满
function isShadowBagFull( isShowAlert )
	return false
end

-- 道具背包是否已满, 2014-07-07, zhangqi
function isPropBagFull(isShowAlert)
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
	local m_number = 0

	-- 携带数
	if( not table.isEmpty(allBagInfo))then
		-- 道具是否满了
		if(not table.isEmpty(allBagInfo.props)) then
			for k,v in pairs(allBagInfo.props) do
				m_number = m_number + 1
			end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.props)) then
			isFull = true
		end
	end

	if(isFull==true and isShowAlert==true)then
		-- [1427] = "您的道具背包数量已达上限，可以整理或扩充您的道具背包",
		--tbInfo: table, {text = "", btn = {{title = "", callback = func}, ...} }
		require "script/module/bag/MainBagCtrl"
		local tbInfo = {text = m_i18n[1427]}
		tbInfo.btn = {
			{
				title = m_i18n[1525],
				callback = 	function ( ... )
					MainBagCtrl.onExpand(1)
				end
			},
			{
				title = m_i18n[1526],
				callback = function ( ... )
					if (LayerManager.curModuleName() ~= "MainBagCtrl") then
						require "script/module/bag/MainBagCtrl"
						LayerManager.changeModule(MainBagCtrl.create(1), MainBagCtrl.moduleName(), {1, 3}, true)
						PlayerPanel.addForPublic()
						require "script/module/main/MainScene"
						MainScene.changeMenuCircle(6)
					else
						MainBagCtrl.touchTabWithIndex(1)
					end
				end
			}
		}

		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end


-- 装备背包是否已满
function isEquipBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
	local m_number = 0

	-- 携带数
	if( not table.isEmpty(allBagInfo))then
		-- 装备是否满了
		if(not table.isEmpty(allBagInfo.arm)) then
			for k,v in pairs(allBagInfo.arm) do
				m_number = m_number + 1
			end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.arm)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		require "script/module/equipment/MainEquipmentCtrl"
		local tbInfo = {text = m_i18n[1608]}
		tbInfo.btn = {
			{
				title = m_i18n[1525], -- 扩充
				callback = 	function ( ... )
					MainEquipmentCtrl.onExpand(1)
				end
			},
			{
				title = m_i18n[1526], -- 整理背包
				callback = 	function ( ... )
					if (LayerManager.curModuleName() ~= "MainEquipmentCtrl") then
						local bag = MainEquipmentCtrl.create(1)
						LayerManager.changeModule(bag, MainEquipmentCtrl.moduleName(), {1, 3})
						PlayerPanel.addForPublic()
					else
						MainEquipmentCtrl.touchTabWithIndex(1)
					end
				end
			},
		-- {
		-- 	title = m_i18n[1654], -- 分解
		-- 	callback = 	function ( ... )
		-- 		require "script/module/resolve/MainResolveCtrl"
		-- 		local canEnter = SwitchModel.getSwitchOpenState( ksSwitchResolve ,true)
		-- 		if (canEnter) then
		-- 			local layResolve = MainResolveCtrl.create()
		-- 			if (layResolve)then
		-- 				LayerManager.changeModule(layResolve, MainResolveCtrl.moduleName(), {1,3}, true)
		-- 				PlayerPanel.addForPublic()
		-- 			end
		-- 		end
		-- 	end
		-- }
		}
		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end



-- 空岛贝背包是否已满
function isConchBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
	local m_number = 0

	-- 携带数
	if( not table.isEmpty(allBagInfo))then
		-- 装备是否满了
		if(not table.isEmpty(allBagInfo.conch)) then
			for k,v in pairs(allBagInfo.conch) do
				m_number = m_number + 1
			end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.conch)) then
			isFull = true
		end
	end
	if( isFull == true and isShowAlert == true)then
		require "script/module/conch/ConchBag/MainConchCtrl"
		local tbInfo = {text = m_i18n[5518]}
		tbInfo.btn = {
			{},
			{	title = m_i18n[1526], -- 整理背包
				callback = 	function ( ... )
					if (LayerManager.curModuleName() ~= "MainConchCtrl") then
						local bag = MainConchCtrl.create()
						LayerManager.changeModule(bag, MainConchCtrl.moduleName(), {1, 3})
						PlayerPanel.addForPublic()
					end
				end
			},
			{},
		}
		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end

-- 装备碎片背包是否已满, 2014-07-07, zhangqi
function isArmFragBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
	local m_number = 0

	-- 携带数
	if( not table.isEmpty(allBagInfo))then
		-- 装备是否满了
		if(not table.isEmpty(allBagInfo.armFrag)) then
			for k,v in pairs(allBagInfo.armFrag) do
				m_number = m_number + 1
			end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.armFrag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		-- [1610] = "您的时装背包数量已达上限，可以整理或扩充您的时装背包",
		-- [1609] = "您的装备碎片背包数量已达上限，可以整理或扩充您的装备碎片背包",
		require "script/module/equipment/MainEquipmentCtrl"
		local tbInfo = {text = m_i18n[1609]}
		tbInfo.btn = {
			{
				title = m_i18n[1525], -- 扩充
				callback = 	function ( ... )
					MainEquipmentCtrl.onExpand(2)
				end
			},
			{	title = m_i18n[1526], -- 整理背包
				callback = 	function ( ... )
					if (LayerManager.curModuleName() ~= "MainEquipmentCtrl") then
						local bag = MainEquipmentCtrl.create(2)
						LayerManager.changeModule(bag, MainEquipmentCtrl.moduleName(), {1, 3})
						PlayerPanel.addForPublic()
					else
						MainEquipmentCtrl.touchTabWithIndex(2)
					end
				end
			},
		}
		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end



-- 宝物背包是否已满, 2014-07-07, zhangqi
function isTreasBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
	local m_number = 0

	-- 携带数
	if( not table.isEmpty(allBagInfo))then
		-- 装备是否满了
		if(not table.isEmpty(allBagInfo.treas)) then
			for k,v in pairs(allBagInfo.treas) do
				m_number = m_number + 1
			end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.treas)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tbInfo = {text = m_i18n[1704]}
		tbInfo.btn = {
			{
				title = m_i18n[1525],
				callback = 	function ( ... )
					require "script/module/bag/MainBagCtrl"
					MainBagCtrl.onExpand(2)
				end
			},
			{
				title = m_i18n[1526],
				callback = 	function ( ... )
					if (LayerManager.curModuleName() ~= "MainBagCtrl") then
						require "script/module/bag/MainBagCtrl"
						LayerManager.changeModule(MainBagCtrl.create(2), MainBagCtrl.moduleName(), {1, 3}, true)
						PlayerPanel.addForPublic()
						require "script/module/main/MainScene"
						MainScene.changeMenuCircle(6)
					else
						MainBagCtrl.touchTabWithIndex(2)
					end
				end
			}
		}
		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end

-- 伙伴背包是否已满
function isPartnerFull(isShowAlert)
	local isFull = false
	-- 武将背包是否满了
	if( HeroModel.isLimitedCount() )then
		isFull = true
	end
	if(isFull==true and isShowAlert==true)then
		-- [1009] = "您的伙伴背包数量已达上限，可以整理或扩充您的伙伴背包",
		-- require "script/module/partner/PartnerPublicFull"
		-- LayerManager.addLayout(PartnerPublicFull.create())
		local tbInfo = {text = m_i18n[1009]}
		tbInfo.btn = {
			{},
			{
				title = m_i18n[1525],
				callback = 	function ( ... )
					require "script/module/partner/MainPartner"
					MainPartner.onBtnExpand()
				end
			},
			{}
		}
		UIHelper.showFullDlg(tbInfo)
	end
	return isFull
end

-- 根据一个物品template_id判断对应背包是否已满的方法，zhangqi, 2014-07-17
function bagIsFullWithTid( tid, isShowAlert )
	local fnIsFull = getItemById(tid).fnBagFull
	if (fnIsFull) then
		return fnIsFull(isShowAlert)
	end
	return false
end
-- 根据一组物品template_id判断某种背包是否已满的方法，zhangqi, 2014-07-17
function bagIsFullWithTids( tbTids, isShowAlert )
	for i, tid in ipairs(tbTids) do
		if (bagIsFullWithTid(tid, isShowAlert)) then
			return true
		end
	end
end

-- 背包是否已满 return bool 满/没满 <=> true/false  isPartnerFull: make by xianghuiZhang
function isBagFull(isShowAlert)
	local isFull = false
	isShowAlert = isShowAlert or true
	isFull = isPropBagFull(isShowAlert) or isPartnerFull(isShowAlert) or isEquipBagFull(isShowAlert) or isTreasBagFull(isShowAlert) or isArmFragBagFull(isShowAlert) or isConchBagFull(isShowAlert)
	return isFull
end
-- 背包是否已满不包括伙伴判断 return bool 满/没满 <=> true/false  isPartnerFull: make by xianghuiZhang
function isBagFullExPartner(isShowAlert)
	local isFull = false
	isShowAlert = isShowAlert or true
	isFull = isPropBagFull(isShowAlert) or isEquipBagFull(isShowAlert) or isTreasBagFull(isShowAlert) or isArmFragBagFull(isShowAlert)
	return isFull
end
-- 通过item_template_id 得到缓存匹配的第一条数据
function getCacheItemInfoBy( item_template_id )
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local cacheItemInfo = nil
	if( not table.isEmpty(allBagInfo)) then
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end

		if(item_info==nil and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end

		if(item_info==nil and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end
	end

	return cacheItemInfo
end

-- 通过item_template_id 得到背包中物品的个数
function getCacheItemNumBy( item_template_id )
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_num = 0
	if( not table.isEmpty(allBagInfo)) then
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end

		if(item_num<=0 and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end

		if(item_num<=0 and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end

		if(item_num<=0 and not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
	end

	return item_num
end

-- 获取装备评分 item_id
function getEquipScoreByItemId(item_id)
	if(type(item_id) ~= "number") then
		logger:debug("参数必须是number")
		return
	end

	-- 获取装备数据
	local a_bagInfo = DataCache.getBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == item_id ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(item_id)
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		end
	end

	local equip_desc = equipData.itemDesc
	local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)
	local t_equip_score = equip_desc.base_score + forceLevel* equip_desc.grow_score
	return t_equip_score
end

-- 获取装备评分 item_template_id
function getEquipScoreByItemTmplId(item_template_id)
	--
	if(type(item_template_id) ~= "number") then
		logger:debug("参数必须是number")
		return
	end

	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(item_template_id)

	return equip_desc.base_score
end


-- 获取名将好感礼物
function getAllStarGifts()
	local allStarGifts = {}

	for gid, prop_info in pairs(DataCache.getRemoteBagInfo().props) do
		if( tonumber(prop_info.item_template_id) >= 40001 and tonumber(prop_info.item_template_id) <= 50000) then
			prop_info.gid = gid
			table.insert(allStarGifts, prop_info)
		end
	end

	return allStarGifts
end

-- 获取武将身上的装备 无gid
function getEquipsOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	require "db/DB_Item_arm"
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.arming)) ) then
					for p, equipInfo in pairs(f_hero.equip.arming) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = DB_Item_arm.getDataById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	local bench = DataCache.getBench()
	if( not table.isEmpty(bench))then
		for k,f_hid in pairs(bench) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.arming)) ) then
					for p, equipInfo in pairs(f_hero.equip.arming) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = DB_Item_arm.getDataById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	table.sort( equipsInfo_t, BagUtil.equipSort )
	return equipsInfo_t
end

-- 获得上阵的宝物
function getTreasOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.treasure)) ) then
					for p, equipInfo in pairs(f_hero.equip.treasure) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = ItemUtil.getItemById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end

	local bench = DataCache.getBench()
	if( not table.isEmpty(bench))then
		for k,f_hid in pairs(bench) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.treasure)) ) then
					for p, equipInfo in pairs(f_hero.equip.treasure) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = ItemUtil.getItemById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	table.sort( equipsInfo_t, BagUtil.treasSort )
	return equipsInfo_t
end

-- 获得上阵的时装
function getDressOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.dress)) ) then
					for p, equipInfo in pairs(f_hero.equip.dress) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = ItemUtil.getItemById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	-- table.sort( equipsInfo_t, BagUtil.treasSort )
	return equipsInfo_t
end

-- 根据装备位置 筛选武将身上的装备 不查找的武将的hid
function getEquipsOnFormationByPos(equipPosition, d_hid)
	equipPosition = tonumber(equipPosition)
	local equipsInfo_t = getEquipsOnFormation()

	local p_equips = {}
	for k, equipInfo in pairs(equipsInfo_t) do
		if(d_hid and tonumber(equipInfo.equip_hid) == tonumber(d_hid) ) then

		elseif(tonumber(equipInfo.itemDesc.type) == equipPosition)then
			table.insert(p_equips, equipInfo)
		end
	end
	return p_equips
end

--根据伙伴的阵营得出伙伴所属阵营
function getGroupOfHeroByInfo( heroDBInfo )

	local country 		= heroDBInfo.country;
	local potential 	= heroDBInfo.potential;
	local countryStr = HeroModel.getCiconByCidAndlevel(country,potential)
	-- if (country == 1) then
	-- 	countryStr = countryStr .. "wind/wind" .. potential .. ".png"
	-- elseif (country == 2) then
	-- 	countryStr = countryStr .. "thunder/thunder" .. potential .. ".png"
	-- elseif (country == 3) then
	-- 	countryStr = countryStr .. "water/water" .. potential .. ".png"
	-- elseif (country == 4) then
	-- 	countryStr = countryStr .. "fire/fire" .. potential .. ".png"
	-- else
	-- 	countryStr = nil
	-- end
	return countryStr
end

--根据装备位置和hid得到装备信息
function getEquipsOnFormationByPosAndHid(equipPosition, d_hid)
	equipPosition = tonumber(equipPosition)
	local equipsInfo_t = getEquipsOnFormation()

	local p_equips = {}
	for k, equipInfo in pairs(equipsInfo_t) do
		if(d_hid and tonumber(equipInfo.equip_hid) == tonumber(d_hid) ) then
			if(tonumber(equipInfo.itemDesc.type) == equipPosition)then
				p_equips = equipInfo
			end
		end
	end
	return p_equips
end

-- 根据装备位置 筛选武将身上的装备 不查找的武将的hid
function getTreasOnFormationByPos(equipPosition, d_hid)
	equipPosition = tonumber(equipPosition)
	local equipsInfo_t = getTreasOnFormation()

	local p_equips = {}
	for k, equipInfo in pairs(equipsInfo_t) do
		if(d_hid and tonumber(equipInfo.equip_hid) == tonumber(d_hid) ) then

		elseif(tonumber(equipInfo.itemDesc.type) == equipPosition)then
			table.insert(p_equips, equipInfo)
		end
	end
	return p_equips
end

-- zhangqi, 2015-02-27, 获得伙伴身上的空岛贝信息， hid的伙伴例外
function getConchOnFormationExeptHid( hid )
	local tbConchs = {}

	local conchOnHeros = HeroUtil.getAllConchOnHeros()
	if( not table.isEmpty(conchOnHeros))then
		for item_id, conch in pairs(conchOnHeros) do
			if ( tonumber(hid) ~= tonumber(conch.equip_hid) ) then
				table.insert(tbConchs, conch)
			end
		end
	end
	return tbConchs
end

-- liweidong, 2015-02-26, 获得伙伴身上的空岛贝信息， hid伙伴id
function getConchOnFormationHid( hid )
	local tbConchs = {}

	local conchOnHeros = HeroUtil.getAllConchOnHeros()
	if( not table.isEmpty(conchOnHeros))then
		for item_id, conch in pairs(conchOnHeros) do
			if ( tonumber(hid) == tonumber(conch.equip_hid) ) then
				table.insert(tbConchs, conch)
			end
		end
	end
	return tbConchs
end

-- 返回套装信息
function getSuitInfoByIds(item_template_id, hid)
	-- 获取装备数据
	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(item_template_id)

	if(equip_desc.jobLimit == nil )then
		return
	end

	-- 英雄身上的装备
	local equip_hero = {}
	if(hid and tonumber(hid)>0)then
		equip_hero = HeroUtil.getEquipsByHid(hid)
	end

	-- 获取套装数据
	require "db/DB_Suit"
	local suit_desc = DB_Suit.getDataById(equip_desc.jobLimit)
	-- 套装的各个装备
	local suit_equip_ids = mSplit(string.gsub(suit_desc.suit_items, " ", ""), "," )

	-- 已有的套装装备
	local equips_ids_status = {}
	local had_count = 0
	for k, tmpl_id in pairs(suit_equip_ids) do
		equips_ids_status[tmpl_id] = false
		if(tonumber(tmpl_id) == tonumber(item_template_id))then
			equips_ids_status[tmpl_id] = true
			had_count = had_count + 1
		else
			for k,t_equipInfo in pairs(equip_hero) do
				if(tonumber(tmpl_id) == tonumber(t_equipInfo.item_template_id) )then
					equips_ids_status[tmpl_id] = true
					had_count = had_count + 1
					break
				end
			end
		end
	end

	-- 每级激活的套装属性
	local suit_attr_infos = {}
	for i=1,suit_desc.max_lock do
		local attr_info = {}
		attr_info.lock_num = tonumber(suit_desc["lock_num" .. i])
		attr_info.astAttr  = {}
		attr_info.hadUnlock = false
		-- 是否解锁
		if(attr_info.lock_num <= had_count)then
			attr_info.hadUnlock = true
		end

		-- 相应属性
		local astAttr_temp = mSplit(string.gsub(suit_desc["astAttr" .. i], " ", ""), "," )
		for k,temp_str in pairs(astAttr_temp) do
			local t_arr = mSplit(temp_str, "|" )
			attr_info.astAttr[t_arr[1] .. ""] = t_arr[2]
		end
		table.insert(suit_attr_infos, attr_info)
	end

	local suit_name = suit_desc.name

	return equips_ids_status, suit_attr_infos, suit_name
end

function showFightSoulAttrChangeInfo( last_attr, cur_attr )
	local t_text = {}
	for l_attid, l_data in pairs(last_attr) do
		local addNum = 0
		for c_attid, c_data in pairs(cur_attr) do
			if( tonumber(l_attid) == tonumber(c_attid) )then
				addNum = tonumber(c_data.displayNum)
				cur_attr[c_attid] = nil
				break
			end
		end
		local o_text = {}
		o_text.txt = l_data.desc.displayName
		o_text.num = addNum - tonumber(l_data.displayNum)
		table.insert(t_text, o_text)
	end
	for c_attid,c_data in pairs(cur_attr) do
		local o_text = {}
		o_text.txt = c_data.desc.displayName
		o_text.num = c_data.displayNum
		table.insert(t_text, o_text)
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
end


-- 宝物的基本属性
function getTreasAttrByTmplId( tmpl_id )
	local treasInfo = getItemById(tmpl_id)

	-- 属性信息
	local attr_arr 	= {}
	for i=1,5 do
		local str_info = treasInfo["base_attr"..i]
		if(str_info ~= nil)then
			local tempArr = mSplit(str_info, "|")
			local tempArr_pl = mSplit(treasInfo["increase_attr"..i], "|")

			local attr_e 	= {}
			attr_e.attId 	= tonumber(tempArr[1])
			attr_e.base 	= tonumber(tempArr[2]) or 0 -- zhangqi, 2014-07-08, 加上默认0的处理，避免表数据配置失误
			attr_e.num 		= tonumber(tempArr[2]) or 0
			attr_e.pl 		= tonumber(tempArr_pl[2]) or 0
			table.insert(attr_arr, attr_e)
		end
	end

	-- 评分
	local score_t = {}
	score_t.base = treasInfo.base_score
	score_t.num  = treasInfo.base_score
	score_t.pl   = treasInfo.increase_score

	-- 解锁属性
	local ext_active = {}
	local active_arr_1 = mSplit(treasInfo.ext_active_arr, ",")
	for k, str_act in pairs(active_arr_1) do
		local temp_act_arr = mSplit(str_act, "|")
		local t_ext_active = {}
		t_ext_active.openLv = tonumber(temp_act_arr[1])
		t_ext_active.attId 	= tonumber(temp_act_arr[2])
		t_ext_active.num = tonumber(temp_act_arr[3])
		t_ext_active.isOpen = false
		table.insert(ext_active, t_ext_active)
	end
	local enhanceLv = 0
	return attr_arr, score_t, ext_active, enhanceLv, treasInfo
end

-- 宝物的属性
function getTreasAttrByItemId( item_id, treasData )
	item_id = tonumber(item_id)
	-- 获取宝物数据
	if(table.isEmpty(treasData))then
		local a_bagInfo = DataCache.getBagInfo() -- zhangqi, 2014-07-23, 把背包信息获取放到条件分支内部，避免每次函数调用都会执行（一次260ms左右）
		for k,s_data in pairs(a_bagInfo.treas) do
			if( tonumber(s_data.item_id) == item_id ) then
				treasData = s_data
				break
			end
		end

		-- 如果为空则是武将身上的宝物
		if(table.isEmpty(treasData))then
			treasData = getTreasInfoFromHeroByItemId(item_id)
			if( not table.isEmpty(treasData))then
				treasData.itemDesc = getItemById(treasData.item_template_id)
			end
		end
	end

	local attr_arr, score_t, ext_active = getTreasAttrByTmplId(treasData.item_template_id)
	local enhanceLv = tonumber(treasData.va_item_text.treasureLevel)
	if(enhanceLv and enhanceLv>0)then
		-- 计算属性信息
		for key, v in pairs(attr_arr) do
			attr_arr[key].num = v.base + v.pl * enhanceLv
		end
		-- 计算评分
		score_t.num = score_t.base+score_t.pl*enhanceLv
		-- 计算解锁属性
		for k,v in pairs(ext_active) do
			if(enhanceLv >= v.openLv)then
				ext_active[k].isOpen = true
			end
		end
	end
	return attr_arr, score_t, ext_active, enhanceLv, treasData
end

-- 物品属性的名称和数值的显示
function getAtrrNameAndNum( attrId, num )
	require "db/DB_Affix"
	local affixDesc = DB_Affix.getDataById(tonumber(attrId))
	num = tonumber(num)
	local realNum = num
	local displayNum = num
	if(affixDesc.type == 1)then
		displayNum = num
	elseif(affixDesc.type == 2)then
		displayNum = num / 100
		if(displayNum > math.floor(displayNum))then
			displayNum = string.format("%.1f", displayNum)
		end
	elseif(affixDesc.type == 3)then
		displayNum = num / 100
		if(displayNum > math.floor(displayNum))then
			displayNum = string.format("%.1f", displayNum)
		end

		displayNum = displayNum .. "%"
	end

	return affixDesc, displayNum, realNum
end

-- 解析宝物字符串数组
function parseAttrStringToArr( attr_str )
	local parse_arr_1 = mSplit(attr_str, ",")
	local parse_arr_2 = {}
	for k, sub_parse_str in pairs(parse_arr_1) do
		local sub_parse_arr = mSplit(sub_parse_str, "|")
		table.insert(parse_arr_2, sub_parse_arr)
	end

	-- 排序
	local function keySort ( data_1, data_2 )
		return tonumber(data_1[1]) < tonumber(data_2[1])
	end
	table.sort( parse_arr_2, keySort )

	return parse_arr_2
end

-- 根据宝物的总经验 计算出宝物的当前等级、当前等级经验、当前等级升级所需总经验
function getTreasExpAndLevelInfo( item_template_id, totalExp )
	local tresInfo = getItemById(item_template_id)

	local parse_arr_2 = parseAttrStringToArr( tresInfo.total_upgrade_exp )

	local curLevel 			= 0 -- 当前等级
	local curLevelExp 		= 0 -- 当前等级经验
	local curLevelLimiteExp = 0 -- 当前等级经验上限

	local temp_exp_add = 0
	for k, exp_lv_arr in pairs(parse_arr_2) do
		temp_exp_add = temp_exp_add + exp_lv_arr[2]
		if(totalExp < temp_exp_add)then
			curLevel 			= tonumber(exp_lv_arr[1])
			curLevelLimiteExp 	= tonumber(exp_lv_arr[2])
			curLevelExp 		= curLevelLimiteExp - (tonumber(temp_exp_add) - totalExp)

			break
		elseif(totalExp == temp_exp_add)then
			curLevel 			= tonumber(exp_lv_arr[1]) + 1
			curLevelExp 		= 0
			curLevelLimiteExp 	= tonumber(parse_arr_2[k+1][2])
			break
		end
	end
	return curLevel, curLevelExp, curLevelLimiteExp
end

-- 计算某个等级 每单位经验所需要的 花费
function getSilverPerExpByLevel( item_template_id, level )
	level = tonumber(level)
	local tresInfo = getItemById(item_template_id)
	local sliverPer = 0
	local sliverPerExpArr = parseAttrStringToArr( tresInfo.upgrade_cost_arr )
	for k,v in pairs(sliverPerExpArr) do
		if(tonumber(v[1]) == level )then
			sliverPer = tonumber(v[2])
			break
		end
	end

	return sliverPer
end

-- 计算某个等级所需的全部经验
function getExpForLevelUp(item_template_id, level)
	local tresInfo = getItemById(item_template_id)
	local needExp = 0
	local parse_exp_arr = parseAttrStringToArr( tresInfo.total_upgrade_exp )
	for k,v in pairs(parse_exp_arr) do
		if(tonumber(v[1]) == level )then
			needExp = tonumber(v[2])
			break
		end
	end

	return needExp
end

-- 计算经验到从s_exp到e_exp需要的金币数
function getTreasCostToAddExp( item_template_id, s_exp, e_exp )
	logger:debug(" s_exp = " .. s_exp .. " e_exp = " .. e_exp)
	local slilverNum = 0
	local s_level, s_levelExp, s_levelLimiteExp = getTreasExpAndLevelInfo(item_template_id, s_exp)
	local e_level, e_levelExp, e_levelLimiteExp = getTreasExpAndLevelInfo(item_template_id, e_exp)

	if(s_level == e_level)then
		-- 没升级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (e_exp - s_exp)
	elseif(e_level-s_level == 1)then
		-- 只升了1级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (s_levelLimiteExp - s_levelExp)
		sliverNum = sliverNum + getSilverPerExpByLevel( item_template_id, e_level ) * e_levelExp
	elseif((e_level-s_level) >= 1)then
		-- 升了不止1级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (s_levelLimiteExp - s_levelExp)
		sliverNum = sliverNum + getSilverPerExpByLevel( item_template_id, e_level ) * e_levelExp

		for i_lv=s_level+1, e_level-1 do
			sliverNum = sliverNum + getExpForLevelUp(item_template_id, i_lv)*getSilverPerExpByLevel( item_template_id, i_lv )
		end
	end

	return sliverNum
end

-- 某个等级的基础经验
function getBaseExpBy( item_template_id, level )
	-- level = tonumber(level)
	local tresInfo = getItemById(item_template_id)
	-- local baseExp = 0

	-- local parse_exp_arr = parseAttrStringToArr( tresInfo.base_exp_arr )

	-- for k,v in pairs(parse_exp_arr) do

	-- 	if(tonumber(v[1]) == level )then
	-- 		baseExp = tonumber(v[2])
	-- 		break
	-- 	end
	-- end

	return tonumber(tresInfo.base_exp_arr)
end

--判断是否为经验金银书马
function isGoldOrSilverTreas(itemTid)
	if tonumber(itemTid) == 501001 then
		return true
	elseif tonumber(itemTid) == 501002 then
		return true
	elseif tonumber(itemTid) == 502001 then
		return true
	elseif tonumber(itemTid) == 502002 then
		return true
	else
		return false
	end
end



-- 获取5个potential星级一下的宝物ids, (不包括 dup_arr 中的 item_id)
function getTreasIdsByCondition( potential, self_item_id, materialsArr, treas_type)
	potential = potential or 3
	materialsArr = materialsArr or {}
	local bagCache = DataCache.getBagInfo()
	local treas_cache = bagCache.treas

	if( not table.isEmpty(treas_cache) and #materialsArr<5)then

		for k,v in pairs(treas_cache) do
			-- 条件判断更改 by 张梓航
			-- 去除 白鹤 和 黑云
			if( (tonumber(treas_type) == tonumber(v.itemDesc.type)) and tonumber(v.item_template_id)~=501301 and tonumber(v.item_template_id)~=501302 and ((tonumber(v.itemDesc.quality) <= potential) or isGoldOrSilverTreas(v.item_template_id))) then
				local isInDupArr = false

				for k,d_item_id in pairs(materialsArr) do
					if(tonumber(v.item_id) == tonumber(d_item_id) )then
						isInDupArr = true
						break
					end
				end
				if(tonumber(v.item_id) == tonumber(self_item_id))then
					isInDupArr = true
				end
				if(isInDupArr == false)then

					table.insert(materialsArr, tonumber(v.item_id))
					if(#materialsArr>=5)then
						break
					end
				end
			end
		end
	end
	return materialsArr
end

--[[desc:zhaoqiangjun, 根据template_id创建一个物品Button，并且在左上角显示等级
    nTemplateId: 物品模板id
    fnOnTouch: 按钮事件回调，原型：function func(sender, eventType), 可以为nil
    return: 1, Button对象 2, 物品信息 3, 类型（1arm,2trea,3conch）
—]]
function createBtnByTemplateIdWithLevel( itemInfo, fnOnTouch , type)

	local nTemplateId	= itemInfo.item_template_id
	local tbItem 		= assert(getItemById(tonumber(nTemplateId)), "createBtnByTemplateIdWithLevel--not found id: " .. nTemplateId)
	logger:debug(tbItem)
	logger:debug(itemInfo)
	local itemBtn		= createBtnByItem(tbItem, fnOnTouch)

	local topItemImage = ImageView:create()
	topItemImage:setAnchorPoint(ccp(0, 1.0))
	topItemImage:loadTexture("images/base/potential/lv_" .. tbItem.quality .. ".png")
	topItemImage:setPosition(ccp(-itemBtn:getContentSize().width/2, itemBtn:getContentSize().height/2))
	itemBtn:addChild(topItemImage)

	local pLevel = 0
	if(type == 1) then
		pLevel = itemInfo.va_item_text.armReinforceLevel
	elseif(type == 2) then
		pLevel = itemInfo.va_item_text.treasureLevel
	elseif(type == 3) then
		pLevel = itemInfo.va_item_text.level
	end

	logger:debug("装备名:" .. tbItem.name)
	logger:debug("等级:" .. pLevel)

	local numLabel = LabelAtlas:create()
	numLabel:setProperty(tostring(pLevel),"ui/progress_num.png",13,19,"0")
	numLabel:setAnchorPoint(ccp(0.5, 0.5))
	numLabel:setPosition(ccp(topItemImage:getContentSize().width/4, - topItemImage:getContentSize().height/6 + 2))
	topItemImage:addChild(numLabel)

	return itemBtn,tbItem
end

--[[desc:huxiaozhou 根据template_id,number创建一个物品Button
    nTemplateId: 物品模板id
    num:物品数量
    fnOnTouch: 按钮事件回调，原型：function func(sender, eventType), 可以为nil
    return: 1 带显示数量Button对象 2，物品信息
—]]
function createBtnByTemplateIdAndNumber( nTemplateId,num,fnOnTouch)
	local tbItem = assert(getItemById(tonumber(nTemplateId)), "createBtnByTemplateId--not found id: " .. nTemplateId)
	logger:debug(tbItem)

	return createBtnByItemAndNum(tbItem,num, fnOnTouch), tbItem
end

-- addby huxiaozhou
function createBtnByItemAndNum( tbItem,number,fnOnTouch )
	local btnItem = createBtnByItem(tbItem, fnOnTouch)	--modified by zhaoqiangjun
	btnItem:addChild(createLabn({num = number, pos = ccp(btnItem:getContentSize().width*.4,
		-btnItem:getContentSize().height*.32)}))
	return btnItem
end

-- zhangqi, 创建并返回一个数字标签控件, 每个参数都有默认值，默认给图标做角标用
-- tbArgs {num:显示的数字, file:数字图片, width:数字宽度, height:数字高度, start:起始的数字, anchor:锚点坐标, pos:控件的坐标}
function createLabn( tbArgs )
	local labnNum = LabelAtlas:create()
	labnNum:setProperty(tostring(tbArgs.num or 1), tbArgs.file or "images/item/item_icon_num.png",
		tbArgs.width or 13, tbArgs.height or 18, tostring(tbArgs.start or 0))
	labnNum:setAnchorPoint(tbArgs.anchor or ccp(1,0.5))
	labnNum:setPosition(tbArgs.pos or ccp(0, 0))
	return labnNum
end

--[[desc: zhangqi, 根据template_id创建一个物品Button
    nTemplateId: 物品模板id
    fnOnTouch: 按钮事件回调，原型：function func(sender, eventType), 可以为nil
    tbPicSwithContr {hideShadowContr:传true，控制button左上角是否显示影子图片，不传默认显示,
    				hideArticleContr:传true，控制装备和宝物button左上角是否显示碎片图片，不传默认显示}   -- add by lizy
    return: 1, Button对象 2, 物品信息
—]]
function createBtnByTemplateId( nTemplateId, fnOnTouch,tbPicSwithContr )
	local tbItem = assert(getItemById(tonumber(nTemplateId)), "createBtnByTemplateId--not found id: " .. nTemplateId)
	logger:debug(tbItem)

	return createBtnByItem(tbItem, fnOnTouch,tbPicSwithContr), tbItem
end

function createBtnByItem( tbItem, fnOnTouch ,tbPicSwithContr)

	local btnItem = Button:create()
	logger:debug("tid = %d, bg full path : %s", tbItem.id, tbItem.bgFullPath)

	btnItem:loadTextures(tbItem.bgFullPath, tbItem.bgFullPath, nil) -- 用品质边框初始化按钮
	local imgItem = ImageView:create()
	imgItem:loadTexture(tbItem.imgFullPath)
	btnItem:addChild(imgItem) -- 加载物品图标, 附加到Button上
	imgItem:setTag(1)
	imgItem:setName("imgIcon")

	local imgBorder = ImageView:create()
	imgBorder:loadTexture(tbItem.borderFullPath)
	btnItem:addChild(imgBorder) 
	
	btnItem:setTouchEnabled(false) -- 默认没有交互性
	if (fnOnTouch) then
		btnItem:addTouchEventListener(fnOnTouch)
		btnItem:setTouchEnabled(true) -- 如果指定回调方法则设置可交互
	end

	-- menghao 如果是影子加上影子标识
	if (tbPicSwithContr == nil or tbPicSwithContr.hideShadowContr == nil) then
		if (tbItem.isHeroFragment == true) then
			addSuiSignToWidget(btnItem)
		end
	end
	-- lizy 如果是装备或者宝物碎片加上碎片标识
	if tbPicSwithContr == nil or tbPicSwithContr.hideArticleContr == nil  then
		if (tbItem.isTreasureFragment == true or tbItem.isFragment == true) then
			addSuiSignToWidget(btnItem)
		end
	end
	-- zhangqi, 2014-10-22, 添加高光
	local imgLight = ImageView:create()
	imgLight:loadTexture("images/base/potential/props_light.png")
	btnItem:addChild(imgLight)

	--add by zhaoqiangjun  添加套装的亮闪闪的框。
	if (tbItem.quality and tbItem.jobLimit and tonumber(tbItem.jobLimit) > 0) then

		require "script/module/public/EffectHelper"
		local effect = EffLightCircle:new(tbItem.quality)
		-- if tbItem.quality == 2 then
		-- 	effect:Armature():setPosition(ccp(-2.5, -2.5))
		-- elseif tbItem.quality == 3 then
		-- 	effect:Armature():setPosition(ccp(-2.5, -2.5))--绿色品质
		-- elseif tbItem.quality == 4 then
		-- 	effect:Armature():setPosition(ccp(-3.5, -0.5))--蓝色品质
		-- end
		btnItem:addNode(effect:Armature(), 1, 100)
	end

	return btnItem
end


local function createDirectItem( tbArgs )
	local potentialImgV= ImageView:create()
	potentialImgV:loadTexture(string.format("images/base/potential/color_%d.png", tbArgs.quality))
	local iconImgV  = ImageView:create()
	iconImgV:loadTexture("images/base/props/" .. tbArgs.iconFile)
	local icomBorder = ImageView:create()
	icomBorder:loadTexture(string.format("images/base/potential/equip_%d.png", tbArgs.quality))

	if(tbArgs.number) then
		iconImgV:addChild(createLabn({num = tbArgs.number, pos = ccp(iconImgV:getContentSize().width*.47,
			-iconImgV:getContentSize().height*.37)}))
	end
	iconImgV:setTag(1)
	potentialImgV:addChild(iconImgV)
	potentialImgV:addChild(icomBorder)  

	return potentialImgV
end
--[[desc:huxiaozhou 创建一个带数目的贝里图标
    arg1: 贝里数量
    return: imgview  
—]]
function getSiliverIconByNum(number)
	return createDirectItem({quality = 2, iconFile = "beili_da.png", number = number})
end
--[[desc:huxiaozhou 创建一个带数目的金币图标
    arg1: 金币数量
    return: imgview  
—]]
function getGoldIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "jinbi_zhong.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的空岛币图标
    arg1:空岛币
    return: imgview  
—]]
function getSkyBellyIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "air_coin.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的经验石图标
    arg1:将魂数量
    return: imgview  
—]]
function getSoulIconByNum(number)
	return createDirectItem({quality = 4, iconFile = "jingyanshi.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的声望图标
    arg1:声望数量
    return: imgview  
—]]
function getPrestigeIconByNum(number)
	return createDirectItem({quality = 3, iconFile = "shengwang.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的海魂图标
    arg1:海魂数量
    return: imgview  
—]]
function getJewelIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "sea_soul_big.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的小体力图标
    arg1:体力数量数量
    return: imgview  
—]]
function getSmallPhyIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "tili_xiao.png", number = number})
end

--[[desc:huxiaozhou 创建一个带数目的小耐力图标
    arg1:耐力数量
    return: imgview  
—]]
function getStaminaIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "naili_xiao.png", number = number})
end

--[[desc:liweidong 创建一个带数目的小经验图标
    arg1:耐力数量
    return: imgview  
—]]
function getExpIconByNum(number)
	return createDirectItem({quality = 5, iconFile = "exp_icon.png", number = number})
end

--[[desc: 根据配置的奖励字符串，创建对应的图标并返回
    sReward: 配置表中单个奖励的字符串，例如："1|0|1000", 表示奖励贝里1000
    return: 1, imageView控件(显示奖励物品); 2, string(物品的名称) 
—]]
function createIconByRewardString( sReward )
	local tbRward = string.strsplit(sReward, "|")
	Logger.debug("createIconByRewardString-tbRward = %s", tbRward)

	local curLevel = tonumber(UserModel.getHeroLevel()) -- 获取玩家当前等级
	local tbRewardIcon = {
		["1"] = getSiliverIconByNum, ["2"] = getSoulIconByNum, ["3"] = getGoldIconByNum, ["4"] = getSmallPhyIconByNum,
		["5"] = getStaminaIconByNum, ["7"] = function (number, tid) return createBtnByTemplateIdAndNumber(tid, number) end,
		["8"] = function (number) return getSiliverIconByNum(curLevel*number) end,
		["9"] = function (number) return getExpIconByNum(curLevel*number) end,
		["11"] = getJewelIconByNum, ["12"] = getPrestigeIconByNum, ["14"] = function (number, tid) return createBtnByTemplateIdAndNumber(tid, number) end,
	}
	local tbRewardName = {
		["1"] = m_i18n[1520], ["2"] = m_i18n[1087], ["3"] = m_i18n[2220], ["4"] = m_i18n[1922],
		["5"] = m_i18n[1923], ["7"] = m_i18n[1402], -- 道具
		["8"] = m_i18n[1520], ["9"] = m_i18n[1975], ["11"] = m_i18n[2082], ["12"] = m_i18n[1921], ["14"] = m_i18n[1402], -- 道具
	}
	local imgIcon, sName = nil, ""
	if (tbRward) then
		local tbArgs = {}
		local item = nil
		local rewType, rewTid, rewNum = tbRward[1], tbRward[2], tonumber(tbRward[3])
		imgIcon, item = tbRewardIcon[rewType](rewNum, rewTid)
		sName = item and item.name or tbRewardName[rewType]
	end

	return (imgIcon or ImageView:create()), sName
end

--[[desc: zhangqi, 根据template_id创建一个基于CCMenu的按钮
    nTemplateId: 物品模板id
    fnTouchHandler: 按钮事件回调方法，原型：function func(sender), 可以为nil
    return: 1, CCMenu, getContentSize可以获取按钮的实际size 2, 物品信息
—]]
function createCellBtnByTemplateId( nTemplateId, fnTouchHandler )
	local tbItem = assert(getItemById(tonumber(nTemplateId)), "createBtnByTemplateId--not found id: " .. nTemplateId)
	logger:debug(tbItem)

	return createCellBtnByItem(tbItem, fnTouchHandler), tbItem
end

--[[desc: zhangqi, 根据物品信息创建一个基于CCMenu的按钮
    tbItem: 物品信息
    fnTouchHandler: 
    return: CCMenu, getContentSize可以获取按钮的实际size
—]]
function createCellBtnByItem( tbItem, fnTouchHandler )
	logger:debug("tid = %d, bg full path : %s", tbItem.id, tbItem.bgFullPath)
	local btnItem = CCMenuItemImage:create(tbItem.bgFullPath, tbItem.bgFullPath)
	if (fnTouchHandler and type(fnTouchHandler) == "function") then
		btnItem:registerScriptTapHandler(fnTouchHandler)
	end

	local szBtn = btnItem:getContentSize()
	local imgItem = ImageView:create()
	imgItem:loadTexture(tbItem.imgFullPath)
	imgItem:setPosition(ccp(szBtn.width/2, szBtn.height/2))
	btnItem:addChild(imgItem) -- 加载物品图标, 附加到 MenuItem 上

	local menu = CCScrollMenu:create()
	menu:addChild(btnItem)
	menu:setContentSize(szBtn)

	return menu
end

-- 返回装备的子类型对应数值
function getEquipSubTypeTable( ... )
	return { WEAPON = 1, CLOTHE = 2, HAT = 3, NECKLACE = 4, EXP = 5}
end

-- 类型对应名称
local name_text_arr = {
	{"武器", "衣服", "帽子", "项链", "经验"},
	"",
	"道具",
	"道具", -- 食品先默认道具
	"碎片",
	"道具",
	"武魂",
	"道具",
	"礼物",
	"道具",
	{"战马", "兵书"}, -- 宝物
	"碎片",
	{"战魂",}, -- 空岛贝
	"道具", -- 时装先默认道具
}
--[[desc: 指定物品信息，返回一个物品的印章文本
    tbItem: 物品信息
    return: string
—]]
function getSealByItem( tbItem )
	local name_text = "道具"

	if(tbItem.item_type == 1 or tbItem.item_type == 11)then
		local t_name_text = name_text_arr[tbItem.item_type]
		name_text = t_name_text[tbItem.type]
	else
		name_text = name_text_arr[tbItem.item_type]
	end

	return name_text
end
-- 根据物品类型和子类型返回类型文本
function getSealBySubtype( nType, nSubType )
	local ret, seal = name_text_arr[nType], "道具"
	if (type(ret) == "table") then
		return (ret[nSubType] or seal)
	else
		return (ret or seal)
	end
end

local tbTreasure = {} -- 01234  对应 经验、魔防、攻击、生命、物防
tbTreasure[0] = "item_type_treasure.png"
tbTreasure[1] = "item_type_wind.png"
tbTreasure[2] = "item_type_thunder.png"
tbTreasure[3] = "item_type_water.png"
tbTreasure[4] = "item_type_fire.png"

local tbConch = {} -- 空岛贝类型标签
tbConch[1] = "item_type_attack.png" -- "【专攻】"
tbConch[2] = "item_type_attack.png" -- "【专攻】"
tbConch[3] = "item_type_treat.png" 	-- "【治疗】"
tbConch[4] = "item_type_treat.png"	-- "【治疗】"
tbConch[5] = "item_type_fire.png"	-- "【物防】"
tbConch[6] = "item_type_wind.png"	-- "【魔防】"
tbConch[7] = "item_type_water.png"	-- "【生命】"
tbConch[8] = "item_type_final.png"	-- "【终伤】"
tbConch[9] = "item_type_final.png"	-- "【终伤】"
tbConch[10] = "item_type_element.png"	-- "【元素】"
tbConch[11] = "item_type_element.png"	-- "【元素】"
tbConch[12] = "item_type_element.png"	-- "【元素】"
tbConch[13] = "item_type_element.png"	-- "【元素】"
tbConch[14] = "item_type_treasure.png"	-- "【元素】"

local tbEquip = {} -- 装备类型标签
tbEquip[1] = "item_type_weapon.png"
tbEquip[2] = "item_type_armor.png"
tbEquip[3] = "item_type_helmet.png"
tbEquip[4] = "item_type_necklace.png"
tbEquip[5] = "item_type_treasure.png" -- 2015-04-16, zhangqi, 新增经验装备

local tbSealImg = {
	tbEquip, -- 装备
	"",
	"item_type_item.png",
	"item_type_item.png", -- 食品先默认道具
	"item_type_fragment.png",
	"item_type_item.png",
	"item_type_shadow.png",
	"item_type_item.png",
	"item_type_gift.png",
	"item_type_item.png",
	tbTreasure, -- 宝物
	"item_type_fragment.png",
	tbConch, -- 空岛贝
	"item_type_item.png", -- 时装先默认道具
}

-- 背包cell背景图片
local tbZhuShuImg = {
	"ui/bag_cell_1_bg.png",
	"ui/bag_cell_txt_1_bg.png", 
	"images/common/cell/bag_cell_2_bg.png", 
	"images/common/cell/bag_cell_txt_2_bg.png", 

}

-- -- 12340  对应 魔防、物攻、生命、物防、通用 
local tbTreasureTypes = {
	m_i18n[1126],
	m_i18n[1123],
	m_i18n[1124],
	m_i18n[1125],  
	m_i18n[1121], 
}

-- 找出推荐专属宝物的Cell背景图片 和 宝物类型描述的背景图片
function getCellBgByItem( tbItem )
	local itemImg = tbZhuShuImg[tbItem.item_type] 
	return itemImg

end


-- -- 01234  对应 魔防、物攻、生命、物防 默认 通用
function getSealStringByItem( tbItem )
	local tfdTreasureType = m_i18n[1121]
	local treasureType = tbTreasureTypes[tonumber(tbItem.type)] or tfdTreasureType
	return treasureType
end

function getSealFileByItem( tbItem )
	local itemImg = "item_type_item.png"
	local sImg = tbSealImg[tbItem.item_type] or itemImg 

	if (type(sImg) == "table") then
		sImg = sImg[tbItem.type] or itemImg
	end

	return "images/base/potential/" .. sImg
end

-- ******************** 文字版 物品子类型 **************************
-- 装备类型标签, 2015-04-30
local tbTreasureType = {1126, 1123, 1124, 1125} -- 01234  对应 经验、魔防、攻击、生命、物防
tbTreasureType[0] = 1122                                                                                          
local tbEquipType = {1129, 1144, 1131, 1130, 1122,}                                                               
local tbConchType = {1133, 1133, 1134, 1134, 1125, 1126, 1124, 1135, 1135, 1140, 1140, 1140, 1140, 1140} -- 空岛贝
local tbSignText = {tbEquipType, "", 1136, 1136, -- 食品先默认道具                                                
                    1137, 1136, 1138, 1137, 1139, 1136,                                                           
                    tbTreasureType, 1137, tbConchType, 1136, } -- 最后一个时装先默认道具

function getSignTextByItem( tbItem )
	local default = 1121
	local i18nId = tbSignText[tbItem.item_type] or default 

	if (type(i18nId) == "table") then
		i18nId = i18nId[tbItem.type] or default
	end

	if (type(i18nId) == "number") then
		return m_i18n[i18nId]
	elseif (type(i18nId) == "string") then
		return i18nId
	end

	return default
end

--得到礼包物品数据, zhangqi, 2014-04-26, move from UseItemLayer.lua
function getGiftInfo( item_template_id )
	require "script/module/public/ItemUtil"
	local itemTableInfo = ItemUtil.getItemById(tonumber(item_template_id))
	local awardItemIds 	= mSplit(itemTableInfo.award_item_id, ",")

	local items = {}
	for k,v in pairs(awardItemIds) do
		local tempStrTable = mSplit(v, "|")
		local item = {}
		item.tid  = tempStrTable[1]
		item.num = tempStrTable[2]
		item.type = "item"
		item.name = ItemUtil.getItemById(tonumber(item.tid)).name -- zhangqi, 增加物品名称
		logger:debug(item)
		table.insert(items, item)
	end
	if(itemTableInfo.coins ~= nil) then
		local item = {}
		item.type = "silver"
		item.num  = itemTableInfo.coins
		table.insert(items, item)
	end
	if(itemTableInfo.gold ~= nil) then
		local item = {}
		item.type = "gold"
		item.num = itemTableInfo.golds
	end

	return items
end

--[[desc: zhangqi, 2014-07-16
    tbGift: table, 物品信息，最少包含一个 type 字段, 可以是 getGiftInfo() 返回的array中的一个元素
    return: table, {item = tbItem, icon = btnIcon, sign = signPath}， 用来构造一个礼物的cell
    		item: table, 对应的物品配置表信息，贝里和金币还有经验石只有：名称，品质，图标Button，描述
    		icon: Button，物品图标按钮
    		sign: string, 物品类型图标的资源路径
—]]
function getGiftData( tbGift )
	local tbItem = {}
	local btnIcon  -- 物品图标
	local signPath = "images/base/potential/item_type_item.png" -- 印章图片路径, 默认是道具类型
	if (tbGift.type == "item") then
		tbItem = ItemUtil.getItemById(tbGift.tid)
		btnIcon = ItemUtil.createBtnByItem(tbItem)
		assert(btnIcon, "UIHelper.createDropItemDlg by item.tid: " .. tbGift.tid)
		signPath = ItemUtil.getSealFileByItem(tbItem)
	elseif (tbGift.type == "hero") then
		btnIcon, tbItem = HeroUtil.createHeroIconBtnByHtid(tbGift.tid)
		assert(btnIcon, "UIHelper.createDropItemDlg by hero.tid: " .. tbGift.tid)
		signPath = ItemUtil.getSealFileByItem(tbItem)
		-- zhangqi, 2015-01-10, 去经验石
		-- elseif (tbGift.type == "soul") then -- zhangqi, 20160626, 后端返回掉落会有soul（经验石）的类型，在这里加上处理
		-- 	tbItem.name = m_i18n[1087]
		-- 	tbItem.quality = 4
		-- 	btnIcon = ImageView:create()
		-- 	btnIcon:loadTexture("images/base/potential/props_4.png")
		-- 	local img = ImageView:create()
		-- 	img:loadTexture("images/base/props/jingyanshi.png")
		-- 	btnIcon:addChild(img)
		-- 	tbItem.desc = m_i18n[1519]
	elseif (tbGift.type == "silver") then -- 贝里
		tbItem.name = m_i18n[1520]
		tbItem.quality = 4
		btnIcon = ImageView:create()
		btnIcon:loadTexture("images/base/potential/color_4.png")
		local img = ImageView:create()
		img:loadTexture("images/base/props/beili_da.png")
		btnIcon:addChild(img)
		local img2 = ImageView:create()
		img2:loadTexture("images/base/potential/equip_4.png")
		btnIcon:addChild(img2)
		tbItem.desc = m_i18n[1517]
		-- imgSeal:removeFromParent()
	elseif (tbGift.type == "gold") then -- 金币
		tbItem.name = m_i18n[2220]
		tbItem.quality = 5
		btnIcon = ImageView:create()
		btnIcon:loadTexture("images/base/potential/color_5.png")
		local img = ImageView:create()
		img:loadTexture("images/base/props/jinbi_zhong.png")
		btnIcon:addChild(img)
		local img2 = ImageView:create()
		img2:loadTexture("images/base/potential/equip_5.png")
		btnIcon:addChild(img2)
		tbItem.desc = m_i18n[1518]
	end

	return {item = tbItem, icon = btnIcon, sign = signPath, num = tbGift.num or 1}
end

-- 根据装备id获取穿戴该装备的伙伴名称，未装备是空字符串
function getOwnerByEquipId( eid )
	local strOwner = ""
	if (eid and tonumber(eid) > 0) then
		local localHero = HeroUtil.getHeroInfoByHid(eid)
		local heroName = localHero.localInfo.name
		-- zhangqi, 2015-01-09, 去主角修改
		-- if(HeroModel.isNecessaryHeroByHid(eid)) then
		-- 	heroName = UserModel.getUserName()
		-- end
		strOwner = heroName
	end
	return strOwner
end

-- 根据属性值返回各项数值>0的属性名称和值组成的字符串，每种属性占一行
function createAttrString( tbAttrNum )
	local descString = ""
	for key,v_num in pairs(tbAttrNum) do
		if (tonumber(v_num) > 0) then
			if (key == "hp") then
				descString = m_i18n[1068]
			elseif (key == "gen_att") then
				descString = m_i18n[1069]
			elseif(key == "phy_att"  )then
				descString = m_i18n[1069]
			elseif(key == "magic_att")then
				descString = m_i18n[1070]
			elseif(key == "phy_def"  )then
				descString = m_i18n[1071]
			elseif(key == "magic_def")then
				descString = m_i18n[1072]
			end

			descString = descString .." +" .. v_num .. "\n"
		end
	end
	return descString
end
--重新计算装备的附魔等级
function setEquipEnchantLevel( euip_id )
	logger:debug(euip_id)
	-- 获取装备数据
	local a_bagInfo = DataCache.getRemoteBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == tonumber(euip_id) ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(tonumber(euip_id))
	end

	logger:debug(equipData)
	equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

	local nCanFix  = equipData.itemDesc.canEnchant
	logger:debug("次装备是否可以附魔 1为可以附魔：")
	logger:debug(nCanFix)
	if(tonumber(nCanFix) ~=  1) then
		return
	end

	local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)
	local enchantLevel = tonumber(equipData.va_item_text.armEnchantLevel or 0)
	local enchantExp = tonumber(equipData.va_item_text.armEnchantExp or 0)

	local curMaxLv = 0
	--表里配的最大附魔等级
	local maxEnchantLV  	= equipData.itemDesc.maxEnchantLV
	logger:debug("强化等级是：" .. equipData.va_item_text.armReinforceLevel or 0)
	--装备当前的附魔等级上限 (装备强化等级/附魔等级间隔））

	local  enchantLVlimit = equipData.itemDesc.enchantLVlimit or 0
	--强化等级
	local  pArmReinforceLevel = equipData.va_item_text.armReinforceLevel  or 0
	local  str1 = lua_string_split(enchantLVlimit, "|")
	local param1 = tonumber(str1[1])
	local param2 = tonumber(str1[2])
	if(tonumber(enchantLVlimit) ==  0) then
	    curMaxLv =  maxEnchantLV
	else
	     curMaxLv  =  math.floor(pArmReinforceLevel  / param1 + 1) * param2
	end 

	logger:debug("表中最大附魔等级是:"  .. maxEnchantLV .. "计算的最发附魔等级是:" .. curMaxLv)

	local levelIndex = 0
	local requirExp = 0
	local curEnchantLevel = 0
	for i = 1, maxEnchantLV do

		local expId		  = equipData.itemDesc.expId
		
		local dbExp  = DB_Level_up_exp.getDataById(tonumber(expId))
		local s_lv = "lv_" .. i

		local exp =  tonumber(dbExp[s_lv])

		requirExp =  requirExp + exp

		logger:debug(requirExp)
		if(requirExp > enchantExp) then
			break
		end
		levelIndex = levelIndex + 1
	end
	logger:debug("经验提供的附魔可以达到的等级是:")
	logger:debug(levelIndex)

	if(curMaxLv >= levelIndex) then
		curEnchantLevel = levelIndex
	elseif(curMaxLv< levelIndex) then
		curEnchantLevel = curMaxLv
	end

	--更新本地数据
	local isFreeEquip = DataCache.setArmEnchantLevelBy(equipData.item_id, curEnchantLevel)
	if(isFreeEquip == false)then
		local hid  = equipData.hid
		HeroModel.setHeroEquipEnchanteLevelBy(hid, equipData.item_id, curEnchantLevel)
		UserModel.setInfoChanged(true) -- zhangqi, 2014-12-13, 阵上伙伴的装备强化成功后标记需要刷新战斗力
	end
end




-----------------------装备阵容红点相关-----------------------
-----------------------add By WangMing-----------------------
--装备、宝物、空岛贝背包按照位置区分
--装备
local armPos = {{},{},{},{}}
--宝物
local treaPos = {{},{},{},{}}
--空岛贝
local conchTypes = {{},{},{},{},
	{},{},{},{},
	{},{},{},{},
	{},{},}

--装备、宝物、空岛贝 人物红点
local heroRedTips = {false,false,false,false,false,false,false,false,}

--排序方法,仅仅按照品级排序
local function scoreSort( item1, item2 )
	local mscore1 = tonumber(item1.score) or 0
	local mscore2 = tonumber(item2.score) or 0
	return mscore1 > mscore2
end

-- itemInfo,是背包信息，itemType是背包类型1 装备，2 宝物， 3 空岛贝
local function fnGetItemDict( itemInfo, itemType)
	if(not itemInfo) then
		return nil
	end
	local pItemType = tonumber(itemType) or 0
	local itemDict = itemInfo.itemDesc or nil
	if(not itemDict) then
		local pDb = nil
		if(pItemType == 1) then
			pDb = m_dbArm
		elseif(pItemType == 2) then
			pDb = m_dbTreasure
		elseif(pItemType == 3) then
			pDb = m_dbConch
		end
		local mtid = itemInfo.item_template_id
		if(pDb and mtid) then
			itemDict = pDb.getDataById(mtid)
		end
	end

	return itemDict
end

-- 获取背包中制定类型的数据
-- mtype item的类型信息 itemType是背包类型1 装备，2 宝物， 3 空岛贝
local function fnGetTabelByType( mtype ,itemType )
	local pNum = tonumber(mtype) or 0
	local pItemType = tonumber(itemType) or 0
	local tabItem = nil
	if(pItemType == 1) then
		if(pNum > 0 and pNum < 5) then
			tabItem = armPos[pNum]
		end
	elseif(pItemType == 2)then
		if(pNum > 0 and pNum < 5) then
			tabItem = treaPos[pNum]
		end
	elseif(pItemType == 3)then
		tabItem = conchTypes[pNum] or {}
	end
	return tabItem
end

--处理背包信息
function solveTheBag( bagInfo )
	armPos = {{},{},{},{}}
	--宝物
	treaPos = {{},{},{},{}}
	--空岛贝
	conchTypes = {{},{},{},{},
		{},{},{},{},
		{},{},{},{},
		{},{},}
	--每个背包都要判空，只需要获取装备和宝物的背包
	if(bagInfo)then

		--装备
		local armBag = bagInfo.arm
		if(not table.isEmpty(armBag)) then
			for mgid, m_arm in pairs(armBag) do
				local tempItem = {mid=0,score=0}
				tempItem.mid = m_arm.item_id
				local itemDict= fnGetItemDict(m_arm, 1)
				local mpos = itemDict.type
				tempItem.score = itemDict.base_score
				--根据不同物品的位置信息，放到不同的背包里面
				local pNum = tonumber(mpos) or 0
				if(pNum > 0 and pNum < 5) then
					table.insert(armPos[pNum], tempItem)
				end
			end
		end
		--宝物
		local treaBag 	= bagInfo.treas
		if(not table.isEmpty(treaBag)) then
			for mgid, m_arm in pairs(treaBag) do
				local tempItem = {mid=0,tid=0,score=0,lv=0}
				tempItem.mid = m_arm.item_id
				local pLv = tonumber(m_arm.va_item_text.treasureLevel)
				tempItem.lv = pLv or 0
				local pID = tonumber(m_arm.item_template_id)
				tempItem.tid = pID or 0
				local itemDict = fnGetItemDict(m_arm, 2)
				local mpos = itemDict.type
				tempItem.score = itemDict.base_score
				--根据不同物品的位置信息，放到不同的背包里面
				local pNum = tonumber(mpos) or 0
				if(pNum > 0 and pNum < 5) then
					--判断是否是宝物精华
					if (itemDict.is_refine_item ~= 1) then
						table.insert(treaPos[pNum], tempItem)
					end
				end
			end
		end
		
		local conchBag 	= bagInfo.conch
		if(not table.isEmpty(conchBag)) then
			for mgid, m_arm in pairs(conchBag) do
				local tempItem = {mid=0,score=0}
				tempItem.mid = m_arm.item_id
				local itemDict = fnGetItemDict(m_arm, 3)
				local mpos = itemDict.type
				tempItem.score = itemDict.scorce
				--根据不同物品的位置信息，放到不同的背包里面
				local pNum = tonumber(mpos) or 0
				if(not conchTypes[pNum]) then
					conchTypes[pNum] = {}
				end
				table.insert(conchTypes[pNum], tempItem)
			end
		end
	end
	-- logger:debug("armBagInfo--------------->")
	for k,v in pairs(armPos) do
		if(table.count(v) > 1) then
			table.sort(v, scoreSort)
		end
	end
	for k,v in pairs(treaPos) do
		if(table.count(v) > 1) then
			table.sort(v, scoreSort)
		end
	end
	for k,v in pairs(conchTypes) do
		if(table.count(v) > 1) then
			table.sort(v, scoreSort)
		end
	end
end

--判断物品是否已经存在了
local function justiceItemExit( itemInfo, itemType )
	if(not table.isEmpty(itemInfo)) then
		local tempItem = {}
		local mtid = itemInfo.item_template_id
		local itemDict = fnGetItemDict(itemInfo, itemType)
		local tempid = itemInfo.item_id
		local mtype = itemDict.type

		local tabItem = fnGetTabelByType(mtype, itemType)
		local itemnum = table.count(tabItem)
		for i = 1 , itemnum do
			local item = tabItem[tonumber(i)]
			local mmid = item.mid
			if tonumber(tempid) == tonumber(mmid) then
				return true
			end
		end
	end
	return false
end

--处理背包推送时候添加的物品,itemInfo,是背包信息，itemType是背包类型1 装备，2 宝物， 3 空岛贝
function pushitemCallback( itemInfo, itemType )
	-- logger:debug("pushitemCallback:")
	-- logger:debug(itemInfo)
	if(not table.isEmpty(itemInfo)) then
		local exit = justiceItemExit(itemInfo, itemType)
		if exit then
			--如果物品已经存在就直接可以结束
			-- logger:debug("wm----itemInfo exit")
			return
		end

		local tempItem = {mid=0,score=0,tid=0,lv=0}
		local mtid = tonumber(itemInfo.item_template_id) or 0
		local itemDict = fnGetItemDict(itemInfo, itemType)
		--
		tempItem.mid 	= itemInfo.item_id
		tempItem.score 	= itemDict.base_score or itemDict.scorce
		tempItem.tid    = mtid
		local pLv = tonumber(itemInfo.va_item_text.treasureLevel)
		tempItem.lv = pLv or 0
		local mtype  	= itemDict.type
		local mscore 	= tempItem.score
		local tabItem = fnGetTabelByType(mtype, itemType)
		local itemnum 	= table.count(tabItem)
		local pos = 1
		for i = 0 , itemnum-1 do
			local pNum = itemnum-i
			local item = tabItem[tonumber(pNum)]
			local score = item.score
			if tonumber(mscore) < tonumber(score) then
				pos = pNum + 1
			end
		end
		if tabItem then
			--宝物精华不显示红点
			if (itemDict.is_refine_item ~= 1) then
				table.insert(tabItem,pos,tempItem)
			end
		end
	end
end

--处理背包推送回来为空的情况,itemType是背包类型1 装备，2 宝物，3 宝物
function solveBagLackInfo( itemInfo, itemType )
	-- logger:debug("solveBagLackInfo:")

	local mtid = itemInfo.item_template_id
	local itemDict = fnGetItemDict(itemInfo, itemType)
	local mtype = tonumber(itemDict.type)
	local tabItem = fnGetTabelByType(mtype, itemType)
	if (not tabItem) then
		return
	end
	local mid = itemInfo.item_id
	for pos,mitemInfo in ipairs(tabItem) do
		local mtbid = mitemInfo.mid
		if tonumber(mtbid) == tonumber(mid) then
			table.remove(tabItem, pos)
		end
	end
end

local function judgeShowByHid( sq_hid, pOpenConchPos, pOpenTreaPos, onlyID, uniconIDs)
	local pShowRed = false
	if(not sq_hid or tonumber(sq_hid) <= 0 ) then
		return pShowRed
	end
	local heroInfo = HeroModel.getHeroByHid(sq_hid)
	if(not heroInfo) then
		return pShowRed
	end
	local mOpenConchPos = tonumber(pOpenConchPos) or -1
	local mOpenTreaPos = tonumber(pOpenTreaPos) or -1

	if(mOpenConchPos < 0 or mOpenTreaPos < 0) then
		require "script/module/formation/FormationUtil"
		local mFUtil = FormationUtil
		local p1 , p2 = mFUtil.getTreasureAndConchOpenPos()
		mOpenConchPos = tonumber(p1) or 0
		mOpenTreaPos = tonumber(p2) or 0
	end

	local arm 	= heroInfo.equip.arming or {}
	local trea 	= heroInfo.equip.treasure or {}
	local conc  = heroInfo.equip.conch or {}
	for apos,ainfo in pairs(arm) do
		pShowRed = justiceEquipOrTreasureInfo(ainfo, apos, 1)
		if(pShowRed) then
			return pShowRed
		end
	end
	for apos = 1, 4 do
		if(apos <= mOpenTreaPos) then
			local pTrea = trea[tostring(apos)]
			-- pShowRed = justiceEquipOrTreasureInfo(pTrea, apos, 2)
			pShowRed = justiceTreaInfo(pTrea, trea, onlyID, uniconIDs)
			if(pShowRed) then
				return pShowRed
			end
		end
	end
	for apos = 1, 6 do
		if(apos <= mOpenConchPos) then
			local pConch = conc[tostring(apos)]
			pShowRed = justiceConchInfo(pConch, conc)
			if(pShowRed) then
				return pShowRed
			end
		end
	end
	return pShowRed
end

function fnGetHeroRedTips( ... )
	return heroRedTips
end

function fnUpdateOneHeroRedByPos( pos )
	local mCache = DataCache
	local gPos = tonumber(pos) or -1
	if(gPos == -1) then
		return
	end

	require "script/module/formation/FormationUtil"
	local mFUtil = FormationUtil
	local pOpenConchPos, pOpenTreaPos =	mFUtil.getTreasureAndConchOpenPos()

	if(gPos < 5) then
		local mSquad = mCache.getSquad()
		if(table.isEmpty(mSquad)) then
			return
		end
		for ppos,sq_hid in pairs(mSquad) do
			local pNum = tonumber(ppos) or 0
			if(pNum == gPos) then
				local pOnly, pUnion = mFUtil.fnGetOnlyAndUniconTrea(sq_hid)
				pNum = pNum + 1
				heroRedTips[pNum] = judgeShowByHid(sq_hid, pOpenConchPos, pOpenTreaPos, pOnly, pUnion) or false
			end
		end
	else
		local mBench = mCache.getBench()
		if(table.isEmpty(mBench)) then
			return
		end
		gPos = gPos - 5
		for ppos,sq_hid in pairs(mBench) do
			local pNum = tonumber(ppos) or 0
			if(pNum == gPos) then
				local pOnly, pUnion = mFUtil.fnGetOnlyAndUniconTrea(sq_hid)
				pNum = pNum + 6
				heroRedTips[pNum] = judgeShowByHid(sq_hid, pOpenConchPos, pOpenTreaPos, pOnly, pUnion) or false
			end
		end
	end

	require "script/module/formation/MainFormation"
	local mMainFormation = MainFormation
	mMainFormation.fnUpdateHeadTips(heroRedTips)
end

--判定阵容按钮是否需要显示红点
function justiceBagInfo( ... )
	-- logger:debug("justiceBagInfo")
	-- local isShowRed = false
	-- classfyHeroEquip() --将武将身上的装备进行分类

	heroRedTips = {false,false,false,false,false,false,false,false,}
	-- 阵容显示红点
	require "script/module/main/MainScene"
	local mMainScene = MainScene

	local mCache = DataCache
	local mSquad = mCache.getSquad()
	local mBench = mCache.getBench()
	require "script/module/formation/FormationUtil"
	local mFUtil = FormationUtil
	local pOpenConchPos, pOpenTreaPos =	mFUtil.getTreasureAndConchOpenPos()
	-- local pOpenConchPos = tonumber(mFUtil.getConchOpenPos()) or 0
	-- local openTreasureLvArr = mFUtil.getTreasureOpenLvInfo()
	local pShowRed = false
	local pNum = 0
	if(not table.isEmpty(mSquad)) then
		for pos,sq_hid in pairs(mSquad) do
			local pOnly, pUnion = mFUtil.fnGetOnlyAndUniconTrea(sq_hid)
			pNum = tonumber(pos) or 0
			pNum = pNum + 1
			heroRedTips[pNum] = judgeShowByHid(sq_hid, pOpenConchPos, pOpenTreaPos, pOnly, pUnion) or false
			if(heroRedTips[pNum]) then
				pShowRed = true
			end
		end
	end
	if(not table.isEmpty(mBench)) then
		for pos,sq_hid in pairs(mBench) do
			local pOnly, pUnion = mFUtil.fnGetOnlyAndUniconTrea(sq_hid)
			pNum = tonumber(pos) or 0
			pNum = pNum + 6
			heroRedTips[pNum] = judgeShowByHid(sq_hid, pOpenConchPos, pOpenTreaPos, pOnly, pUnion) or false
			if(heroRedTips[pNum]) then
				pShowRed = true
			end
		end
	end

	mMainScene.updateFormTip(pShowRed)

	require "script/module/formation/MainFormation"
	local mMainFormation = MainFormation
	mMainFormation.fnUpdateHeadTips(heroRedTips)

end

--获取人物身上空岛贝的类型数组
local function fnGetAllConchTypesOnHero( conchTable )
	local pTypes = {0,0,0,0,0,0}
	if(table.isEmpty(conchTable)) then
		return pTypes
	end
	for k,v in pairs(conchTable) do
		if(tonumber(v) ~= 0) then
			local pDB = fnGetItemDict(v , 3)
			local pType = tonumber(pDB.type) or 0
			pTypes[tonumber(k)] = pType
		end
	end
	return pTypes
end

--获取人物身上宝物的类型数组
local function fnGetAllTreaTypesOnHero( treaTable )
	local pTypes = {0,0,0,0}
	if(table.isEmpty(treaTable)) then
		return pTypes
	end
	for k,v in pairs(treaTable) do
		if(tonumber(v) ~= 0) then
			local pDB = fnGetItemDict(v , 2)
			local pType = tonumber(pDB.type) or 0
			pTypes[tonumber(k)] = pType
		end
	end
	return pTypes
end

--判断身上有没有某一type的物品
local function justiceHaveType(pTypes, mtype )
	local p_type = tonumber(mtype)
	for k,v in pairs(pTypes or {}) do
		local pNum = tonumber(v)
		if(pNum ~= 0 and pNum == p_type) then
			return true
		end
	end
	return false
end

--判断是否为经验空岛贝
function fnIsExpConchType( type )
	return tonumber(type) == 14
end

-- 判断宝物的红点显示状态
function justiceTreaInfo( treaInfo, treaTable, onlyID, uniconIDs)
	--logger:debug(treaTable)
	local isShowRed = false
	local pTypes = fnGetAllTreaTypesOnHero(treaTable)
	-- 已装备宝物的数量
	local treaNum = #treaTable
	if(not treaInfo or tonumber(treaInfo) == 0) then
		
		for k,v in pairs(treaPos) do
			-- if(not fnIsExpConchType(k)) then
			local pHave = justiceHaveType(pTypes,k)
			if(not pHave and table.count(v) > 0) then
				isShowRed = true
				break
			end
			-- end
		end
		return isShowRed
	end
	local pDb = fnGetItemDict(treaInfo, 2)
	local pType = tonumber(pDb.type) or 0

	-- modified by yucong 不再对宝物进行位置的区分，统一获取全部宝物，避免宝物羁绊红点不显示的情况
	--local tabItem = fnGetTabelByType(pType, 2)
	local tabItem = {}
	-- 宝物装备满时，只判断当前类型的宝物，否则，判断所有没装备类型的宝物
	if (treaNum == 4) then
		tabItem = fnGetTabelByType(pType, 2)
	else
		local index = 1
		for k, typeSet in pairs(treaPos) do
			for k1, v in pairs(typeSet) do
				if (k == pType or justiceHaveType(pTypes,k) == false) then
					tabItem[index] = v
					index = index + 1
				end
			end
		end
	end

	if(table.isEmpty(tabItem)) then
		return isShowRed
	end

	-- 判断专属
	mOnlyID = tonumber(onlyID) or 0
	local pid = tonumber(treaInfo.item_template_id) or -1
	if(pid == mOnlyID) then
		return isShowRed
	end
	-- 判断羁绊
	mUniconID = uniconIDs or {}
	for k,v in pairs(mUniconID) do
		if(pid == tonumber(v)) then
			return isShowRed
		end
	end
	
	local mscore = tonumber(pDb.base_score) or 0
	local mLv = tonumber(treaInfo.va_item_text.treasureLevel) or 0
	for apos,abaginfo in ipairs(tabItem) do
		local pID = tonumber(abaginfo.tid)
		if(tonumber(pDb.id) ~= pID) then
			if(pID == mOnlyID) then
				isShowRed = true
				break
			end
			for k,v in pairs(mUniconID) do
				if(pID == tonumber(v)) then
					isShowRed = true
					break
				end
			end
		end
		local armscore = tonumber(abaginfo.score) or 0
		local armlv = tonumber(abaginfo.lv) or 0
		if(mscore < armscore) then
			isShowRed = true
			break
		elseif(mscore == armscore and mLv < armlv) then
			isShowRed = true
			break
		end
	end

	return isShowRed
end

--判断单一的空岛贝是不是最好的
function justiceConchInfo( conchInfo, conchTable)
	local isShowRed = false
	if(not conchInfo or tonumber(conchInfo) == 0) then
		local pTypes = fnGetAllConchTypesOnHero(conchTable)
		for k,v in pairs(conchTypes) do
			if(not fnIsExpConchType(k)) then
				local pHave = justiceHaveType(pTypes,k)
				if(not pHave and table.count(v) > 0) then
					isShowRed = true
					break
				end
			end
		end
		return isShowRed
	end

	local pDb = fnGetItemDict(conchInfo, 3)
	local pType = tonumber(pDb.type) or 0
	local tabItem = fnGetTabelByType(pType, 3)
	if(table.isEmpty(tabItem)) then
		return isShowRed
	end
	local mscore = tonumber(pDb.scorce) or 0

	for apos,abaginfo in ipairs(tabItem) do
		local armscore = tonumber(abaginfo.score) or 0
		if(mscore < armscore) then
			isShowRed = true
			break
		end
	end

	return isShowRed
end

--判断单一的装备是不是最好的 , itemType是背包类型1 装备，2 宝物
function justiceEquipOrTreasureInfo( itemInfo, mtype, itemType)
	local isShowRed = false
	local pItemType = tonumber(itemType) or 0
	--获取背包中所有的装备或者宝物
	local tabItem = fnGetTabelByType(mtype, pItemType)
	--没有其他的则不予显示
	if(table.isEmpty(tabItem)) then
		return isShowRed
	end 
	
	--最好装备或者宝物的权值
	local mscore = 0
	if(not itemInfo or tonumber(itemInfo) == 0) then
		mscore = 0
	else
		local pDb = fnGetItemDict(itemInfo, pItemType)
		mscore = tonumber(pDb.base_score) or 0
		--宝物精华不显示红点
		if (pDb.is_refine_item == 1 and itemType == 2) then
			mscore = 0
		end
	end
	
	--选出是否存在权值更大的装备
	for apos,abaginfo in ipairs(tabItem) do
		local pscore = tonumber(abaginfo.score) or 0
		if(mscore < pscore) then
			isShowRed = true
			break
		end
	end

	return isShowRed
end
