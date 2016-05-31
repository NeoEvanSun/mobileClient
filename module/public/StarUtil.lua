-- Filename：	StarUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-8-8
-- Purpose：		star

module("StarUtil", package.seeall)


require "script/model/DataCache"
require "script/utils/LuaUtil"
require "script/model/user/UserModel"
require "script/model/utils/HeroUtil"
require "script/module/public/ItemUtil"


-- 收益类型
local reward_name_t = {"银币", "金币", "将魂", "耐力", "体力", "好感度", "经验"}

-- 获得名将的信息
function getStarInfoBySid( star_id )
	star_id = tonumber(star_id)
	local allStars = DataCache.getStarInfoFromCache()
	local starInfo = nil
	if(allStars and (not table.isEmpty( allStars.star_list)) )then
		for k,v in pairs(allStars.star_list) do
			if(star_id == tonumber(k))then
				starInfo = v
				break
			end
		end
	end
	return starInfo
end

-- 获得某个名将的星数
function getStarLevelBySid( star_id )
	local starInfo = getStarInfoBySid(star_id)
	local level = 0
	if( (not table.isEmpty(starInfo)) )then
		level = tonumber(starInfo.level)
	end

	return level
end

-- 计算等级当前经验和所需经验
function getExpProgress( totalExp, tmpl_id )
	totalExp = tonumber(totalExp)
	local needExp = 0
	local curLevelExp = 0

	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(tmpl_id))


	require "db/DB_Star_level"
	local tempData = DB_Star_level.getDataById(tonumber(starDesc.exp_id))

	local total_level_exp = 0

	for i=1, tempData.max_lv do
		total_level_exp = total_level_exp + tempData["exp_" .. i]
		if(totalExp<total_level_exp)then
			needExp = tempData["exp_" .. i]
			curLevelExp = totalExp - (total_level_exp - tempData["exp_" .. i])
			break
		end
	end

	return needExp, curLevelExp, tempData
end

-- 重新计算当前等级
function getLevelByTotalExp( totalExp, tmpl_id )
	totalExp = tonumber(totalExp)
	local curLevel = 0
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(tmpl_id))

	require "db/DB_Star_level"
	local tempData = DB_Star_level.getDataById(tonumber(starDesc.exp_id))

	local total_level_exp = 0

	for i=1, tempData.max_lv do
		total_level_exp = total_level_exp + tempData["exp_" .. i]
		if(totalExp<total_level_exp)then
			curLevel = i-1
			break
		end
		-- 如果满级了
		if(i == tempData.max_lv )then
			curLevel = tempData.max_lv
		end
	end

	return curLevel
end

-- 计算当前等级对应的所有经验
function getTotalExpByLevel( tmpl_id, c_lv )
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(tmpl_id))
	require "db/DB_Star_level"
	local tempData = DB_Star_level.getDataById(tonumber(starDesc.exp_id))
	local totalExp = 0
	for i=1, c_lv do
		totalExp = totalExp + tempData["exp_" .. i]
	end

	return totalExp
end

-- 获取某个名将加成显示属性
function getAttributeInfos(tmpl_id, cur_level)

	cur_level = tonumber(cur_level)

	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(tmpl_id))

	local temp_alibity =  string.split(string.gsub(starDesc.ability, " ", ""), ",")

	require "db/DB_Affix"
	local attr_infos_t = {}
	require "db/DB_Star_ability"
	for k, ablity_str in pairs(temp_alibity) do
		local temp_arr = string.split(ablity_str, "|")
		local temp_t = {}
		temp_t.id = tonumber(temp_arr[1])
		temp_t.openLv = tonumber(temp_arr[2])
		local ability_temp = DB_Star_ability.getDataById(tonumber(temp_arr[1]))
		if(ability_temp.attr)then
			local temp_display_info = {}
			local temp_att_arr = string.split(ability_temp.attr, "|")
			local affixDesc = DB_Affix.getDataById(tonumber(temp_att_arr[1]))
			temp_display_info.a_id 		= tonumber(temp_att_arr[1])
			temp_display_info.name 		= affixDesc.displayName
			temp_display_info.num 		= tonumber(temp_att_arr[2])
			temp_display_info.origin_num= tonumber(temp_att_arr[2])
			temp_display_info.lvLimited = tonumber(temp_arr[3]) or 1
			if(tonumber(temp_att_arr[1]) == 6 or tonumber(temp_att_arr[1]) == 7 or tonumber(temp_att_arr[1]) == 8)then
				temp_display_info.num = 1.0 * temp_display_info.num/100
			end
			if(tonumber(temp_arr[2])<=cur_level)then
				temp_display_info.is_highLight = true
			else
				temp_display_info.is_highLight = false
			end

			table.insert(attr_infos_t, temp_display_info)

		elseif(ability_temp.add_max_stamina) then
			local temp_display_info = {}
			temp_display_info.a_id 		= -1
			temp_display_info.name 		= "耐力上限"
			temp_display_info.num 		= tonumber(ability_temp.add_max_stamina)
			temp_display_info.lvLimited = tonumber(temp_arr[3]) or 1
			if(tonumber(temp_arr[2])<=cur_level)then
				temp_display_info.is_highLight = true
			else
				temp_display_info.is_highLight = false
			end
			table.insert(attr_infos_t, temp_display_info)
		end
	end
	return attr_infos_t
end


-- 单个名将的属性加成  
function getStarAddNumBy( h_tid)

	local allStarInfoArr = DataCache.getStarArr()

	local cur_level = 0
	local star_info = {}
	for k,v in pairs(allStarInfoArr) do
		if(tonumber(v.star_tid) == tonumber(h_tid) ) then
			star_info = v
			break
		end
	end

	local t_ability = {}

	if( not table.isEmpty( star_info ) )then
		local attr_infos_t = getAttributeInfos(h_tid, tonumber(star_info.level))
		for k,temp_display_info in pairs(attr_infos_t) do
			if( temp_display_info.is_highLight == true and temp_display_info.a_id>0)then
				if(t_ability[temp_display_info.a_id] == nil)then
					t_ability[temp_display_info.a_id] = temp_display_info.origin_num
				else
					t_ability[temp_display_info.a_id] = temp_display_info.origin_num + t_ability[temp_display_info.a_id]
				end
				
			end
		end
	end

	return t_ability
end

-- 获取某个名将喜欢的礼物
function getStarGiftByStarTmplId( star_tmple_id )	
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(star_tmple_id))


	local love_gift = string.split(starDesc.favorGift, ",")
	local allGifts = ItemUtil.getAllStarGifts()

	local love_gift_bag = {}

	for k,giftid in pairs(love_gift) do
		local tempGift = {}
		tempGift.item_template_id = "" .. giftid
		tempGift.item_num = "" .. 0
		for k, gift_c in pairs(allGifts) do
			if(tonumber(giftid) == tonumber(gift_c.item_template_id)) then
				tempGift = gift_c
				break
			end
		end
		table.insert( love_gift_bag, tempGift )
	end
	
	return love_gift_bag
end

-- 获取某个名将的动作 下棋\睡觉等
function getStarActInfosBy(star_tmple_id, star_level)

	-- 查找名将的信息
	require "db/DB_Star"
	local starDesc = DB_Star.getDataById(tonumber(star_tmple_id))



	local act_ids = string.split(starDesc.favorAct, ",")
	
	require "db/DB_Star_act"
	local act_info_t = {}
	
	for k,id_str in pairs(act_ids) do
		local starAct = DB_Star_act.getDataById(tonumber(id_str))

		local temp_act = {}
		local prize_arr = string.split(starAct.prizeNum, ",")
		for k, prize in pairs(prize_arr) do
			local temp_arr = string.split(prize, "|")
			if(tonumber(star_level) == tonumber(temp_arr[2])) then
				temp_act.prizeNum = tonumber(temp_arr[1])
				break
			end
		end

		temp_act.actid 			= tonumber(id_str)
		temp_act.btnName 		= starAct.name
		temp_act.stamina 		= starAct.enduranceBase
		temp_act.prizeType 		= starAct.prizeType
		temp_act.texts			= {starAct.text_1, starAct.text_2, starAct.text_3}
		temp_act.reward_name 	= reward_name_t[tonumber(starAct.prizeType)]

		table.insert(act_info_t,temp_act)
	end
	
	return act_info_t
end


-- 获得某个国家的所有名将
function getStarListByCountry( country_id)
	local t_star = {}
	local starListArr = DataCache.getStarArr()
	local levels = 0

	require "db/DB_Star"
	-- for i=1,10 do -- debug 用
		if( not table.isEmpty(starListArr))then
			for k, star_info in pairs(starListArr) do
				local starDesc = DB_Star.getDataById(tonumber(star_info.star_tid))
				if(starDesc.country == tonumber(country_id))then
					table.insert(t_star, star_info)
				end
				levels = levels + star_info.level
			end
		end
	-- end


	return t_star, levels
end

-- 所有名将的个数
function getAllStarsNumber( )
	local starListArr = DataCache.getStarArr()
	local t_num = 0
	if( not table.isEmpty(starListArr))then
		t_num = #starListArr
	end
	return t_num
end

-- 所有名将的加成总和
function getTotalStarAttr(  )
	local starListArr = DataCache.getStarArr()
	local t_ability = {}
	local all_levels = 0
	if( not table.isEmpty(starListArr)) then
		require "db/DB_Star"
		require "db/DB_Star_ability"
		
		for k, star_info in pairs(starListArr) do
			all_levels = all_levels + tonumber(star_info.level)

			local starDesc = DB_Star.getDataById(tonumber(star_info.star_tid))
			local temp_alibity =  string.split(string.gsub(starDesc.ability, " ", ""), ",")
			
			for k, ablity_str in pairs(temp_alibity) do
				local temp_arr = string.split(ablity_str, "|")
				
				local a_openLv = tonumber(temp_arr[2])
				if( tonumber( star_info.level ) >=  a_openLv ) then
					local ability_temp 	= DB_Star_ability.getDataById(tonumber(temp_arr[1]))
					if(ability_temp.attr)then
						local temp_att_arr 	= string.split(ability_temp.attr, "|")
						local ability_id 	= tonumber(temp_att_arr[1])
						local add_num = tonumber(temp_att_arr[2])
						if (t_ability[ ability_id ]) then
							t_ability[ ability_id ] = t_ability[ ability_id ] + add_num
						else
							t_ability[ ability_id ] = add_num
						end
					end
				end
			end	
		end
	end
	return t_ability, all_levels
end

-- 所有名将总心数
function getTotalStarLevels()
	local all_levels = 0
	local starListArr = DataCache.getStarArr()
	if( not table.isEmpty(starListArr)) then
		
		for k, star_info in pairs(starListArr) do
			all_levels = all_levels + tonumber(star_info.level)
		end
	end

	return all_levels
end

-- 单个名将加成属性 给fang用
function getSingleStarAddAbilityBy(h_tid )
	return getStarAddNumBy(h_tid)
end

-- 名将成就全体加成的值 给fang用
function getStarValueForSumFight()
	local achieve_data = {}
	local achieveData_arr = getStarAchieveDBData()

	local all_levels = getTotalStarLevels()
	for k,achieve_info in pairs(achieveData_arr) do
		if( tonumber(achieve_info.completeArray)<= all_levels) then
			local achieve_arr = parseStarAchieveAttr(achieve_info.attrIds)
			for k, temp_achieve in pairs(achieve_arr) do
				if(achieve_data[tonumber(temp_achieve[1])] == nil )then
					achieve_data[tonumber(temp_achieve[1])] = tonumber(temp_achieve[2])
				else
					achieve_data[tonumber(temp_achieve[1])] = tonumber(temp_achieve[2]) + achieve_data[tonumber(temp_achieve[1])]
				end
			end
			
		end
	end

	return achieve_data
	
end
 
-- 所有名将加成的总和 显示用
function getTotalStarAttrForDisplay()
	local displayInfo = {}
	local all_levels = 0
	local starListArr = DataCache.getStarArr()
	local allStars = 0

	if( not table.isEmpty(starListArr)) then

		allStars = #starListArr
		require "db/DB_Star"
		require "db/DB_Star_ability"
		local t_ability, temp_all_levels = getTotalStarAttr()
		all_levels = temp_all_levels
		-- 转换
		if( not table.isEmpty(t_ability)) then
			require "db/DB_Affix"
			for a_id, t_num in pairs(t_ability) do
				local affixDesc = DB_Affix.getDataById(tonumber(a_id))
				local tempDisplay = {}
				tempDisplay.name = affixDesc.displayName
				tempDisplay.num  = t_num
				table.insert(displayInfo, tempDisplay)
			end
		end
	end

	return displayInfo, all_levels, allStars
end


-- 武将总心数增加的数值
function getTotalStarsAddValue( totalLevels )
	require "db/DB_Star_all"
	local star_all = DB_Star_all.getDataById(1)


	local value_t = {}

	local rateArr = string.split(star_all.attrRate, ",")
	for k, tempRate in pairs(rateArr) do
		local temp_arr = string.split(tempRate, "|")
		value_t[tonumber(temp_arr[2])] = tonumber(temp_arr[1])
	end

	local all_keys = table.allKeys(value_t)
	
	local function sortFunc ( key_1, key_2 )
	   	return key_1 < key_2
	end
	table.sort( all_keys, sortFunc )

	local nextLevels = 0
	local curAdd = 0
	local nextAdd = 0
	for index, levels in pairs(all_keys) do
		if(totalLevels < levels) then
			nextLevels = levels
			nextAdd = value_t[levels]
			if(index>1) then
				curAdd = value_t[all_keys[index-1]]
			end
			break
		end
	end

	return curAdd, nextLevels, nextAdd
end

-- 是否能够进入 名仕
function isCanEnterStar( )
	local isIn = false

	local starCache = DataCache.getStarArr()
	if(#starCache >0) then
		isIn = true
	end

	return isIn
end


-- 获取缓存新star的id和国家
function getNewStarInfos()
	local star_id_infos = {}
	local star_ids = readNewStar()
	local star_cache_arr = DataCache.getStarArr()
	if( not table.isEmpty(star_ids)  and not table.isEmpty(star_cache_arr)) then
		require "db/DB_Star"
		for k,star_id in pairs(star_ids) do
			for k,star_info in pairs(star_cache_arr) do

				if (tonumber(star_id) == tonumber(star_info.star_id)) then
					local starDesc = DB_Star.getDataById(tonumber(star_info.star_tid))
					if(star_id_infos[starDesc.country] == nil )then
						star_id_infos[starDesc.country] = {}
					end
					star_id_infos[starDesc.country][tonumber(star_id)] = starDesc.country

					break
				end
			end
		end
		
	end
	return star_id_infos
end


-- 名将升级的暴击概率
function calStarUpgradeRateBy( star_info )
	local rate = 0
	require "db/DB_Star"
	local star_desc = DB_Star.getDataById(star_info.star_tid)

	require "db/DB_Star_ratio"
	local star_ratio = DB_Star_ratio.getDataById(star_desc.exp_id)
	

	local needExp, levelExp, starLevelDesc = StarUtil.getExpProgress( tonumber(star_info.total_exp), tonumber(star_info.star_tid) )

	require "db/DB_Star_all"
	local star_all = DB_Star_all.getDataById(1)
	if((tonumber(star_info.level)+1) <= tonumber(starLevelDesc.max_lv))then
		rate = star_ratio["ratio_" .. (tonumber(star_info.level)+1)]*(star_all.giftRatio1 + levelExp/needExp * star_all.giftRatio2 )/10000/10000 
	end
	if(rate >1 )then
		rate = 1
	end
	return rate
end

------------- 本地缓存新加的 star ----------------
local tnew_stars_num_key = UserModel.getUserUid() .. "_new_stars_num" 
local pre_new_star_id = UserModel.getUserUid() .. "_new_star_id"

-- 存储新加的star
function saveNewStarId(star_id)
	local new_star_ids = readNewStar()
	CCUserDefault:sharedUserDefault():setIntegerForKey(pre_new_star_id .. "_" .. (#new_star_ids + 1), tonumber(star_id))
	CCUserDefault:sharedUserDefault():setIntegerForKey(tnew_stars_num_key, (#new_star_ids + 1))
end

-- 读取新star的所有id
function readNewStar()
	local new_star_ids = {}
	local new_stars_num = CCUserDefault:sharedUserDefault():getIntegerForKey(tnew_stars_num_key)
	if(new_stars_num and new_stars_num>0)then
		for i=1,new_stars_num do
			table.insert(new_star_ids, CCUserDefault:sharedUserDefault():getIntegerForKey(pre_new_star_id .. "_" .. i))
		end
	end
	return new_star_ids
end

-- 删除star
function deleteNewStarBy( star_id )
	local new_star_ids = readNewStar()
	local c_new_star_ids = {}
	for i, c_star_id in pairs(new_star_ids) do
		if(star_id ~= c_star_id)then
			table.insert(c_new_star_ids,c_star_id) 
		end
	end
	for k, temp_star_id in pairs(c_new_star_ids) do
		CCUserDefault:sharedUserDefault():setIntegerForKey(pre_new_star_id .. "_" .. k, tonumber(temp_star_id))
	end

	CCUserDefault:sharedUserDefault():setIntegerForKey(tnew_stars_num_key, (#c_new_star_ids))
end

-- 最后一个操作的名将id
local pre_new_star_id = UserModel.getUserUid() .. "_last_operated_star_id"

function getLastOperatedStarId( )
	return CCUserDefault:sharedUserDefault():getIntegerForKey(pre_new_star_id)
end
function setLastOperatedStarId( star_id )
	CCUserDefault:sharedUserDefault():setIntegerForKey(pre_new_star_id, tonumber(star_id))
end

-- 解析成就
function parseStarAchieveAttr( attrIds )
	local temp_att_arr = string.split(attrIds, ",")
	local attr_arr = {}
	for k,attr_str in pairs(temp_att_arr) do
		local temp_attr_str = string.split(attr_str, "|")
		table.insert(attr_arr, temp_attr_str)
	end
	return attr_arr
end

-- 解析成就成string
function getStringAchieveAttr( attrIds )
	
	local text_str = ""
	if(attrIds)then
		local attr_arr = parseStarAchieveAttr(attrIds)
		for k,t_attr in pairs(attr_arr) do
			local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(t_attr[1], t_attr[2])
			text_str = text_str .. "  " .. affixDesc.sigleName .. " +" .. displayNum
		end
	end
	return text_str
end

-- 解析成就成string
function getStringAchieveAttrBy( achieveData )
	local text_str = ""
	if(not table.isEmpty(achieveData) )then
		if(achieveData.attrIds)then
			text_str = getStringAchieveAttr( achieveData.attrIds )
		end
		if(achieveData.add_max_stamina)then
			text_str = text_str .. " 耐力上限 +" .. achieveData.add_max_stamina
		end
	end

	return text_str
end


-- 某个总心数 激活 的成就
function getOneStarAchieveBy( allStars, add_lv )
	local cur_achieve_text = {}
	local achieveData_arr = getStarAchieveDBData()

	local m_achieveData = {}
	for k, achieveData in pairs(achieveData_arr) do
		if(tonumber(achieveData.completeArray) == allStars or (tonumber(achieveData.completeArray) > (allStars - add_lv) and tonumber(achieveData.completeArray) < allStars) )then
			m_achieveData = achieveData
			break
		end
	end
	if(not table.isEmpty(m_achieveData) and m_achieveData.attrIds)then
		local attr_arr = parseStarAchieveAttr(m_achieveData.attrIds)
		for k,t_attr in pairs(attr_arr) do
			local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(t_attr[1], t_attr[2])
			affixDesc.realNum = realNum

			table.insert(cur_achieve_text, affixDesc)
		end
	end
	if(not table.isEmpty(m_achieveData) and m_achieveData.add_max_stamina)then
		local affixDesc = {}
		affixDesc.realNum = m_achieveData.add_max_stamina
		table.insert(cur_achieve_text, affixDesc)
	end
	return cur_achieve_text, m_achieveData
end



-- 获得 所有名将配置
function getStarAchieveDBData()
	local function keySort ( data_1, data_2 )
	   	return tonumber(data_1.id) > tonumber(data_2.id)
	end
	
	require "db/DB_Achieve"
	local achieveData_t = DB_Achieve.Achieve
	local achieveData_arr = {}
	for k,achieveData in pairs(achieveData_t) do
		table.insert(achieveData_arr, DB_Achieve.getDataById(achieveData[1]))
	end
	table.sort( achieveData_arr, keySort )

	return achieveData_arr
end

-- 获得 名将成就的icon
function getStarAchieveIconSprite( achieveData, isGray )
	local borderName 	= "images/star/achieve_border.png"
	local potentialName = "images/base/potential/props_" .. achieveData.potential .. ".png"
	local iconName 		= "images/base/star/" .. achieveData.icon

	local borderSprite 		= nil 	-- 最外框
	local potentialSprite 	= nil	-- 品质框
	local iconSprite 		= nil	-- Icon
	local numColor 			= nil 	-- 数字颜色 
	if(isGray)then
		borderSprite 	= BTGraySprite:create(borderName)
		potentialSprite = BTGraySprite:create(potentialName)
		iconSprite 		= BTGraySprite:create(iconName)
		numColor		= ccc3(0xca, 0xca, 0xca)
	else
		borderSprite 	= CCSprite:create(borderName)
		potentialSprite = CCSprite:create(potentialName)
		iconSprite 		= CCSprite:create(iconName)
		numColor		= ccc3(0x00, 0xff, 0x18)
	end

	potentialSprite:setAnchorPoint(ccp(0.5,0.5))
	potentialSprite:setPosition(ccp(borderSprite:getContentSize().width*0.5, borderSprite:getContentSize().height*0.5))
	borderSprite:addChild(potentialSprite)

	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
	potentialSprite:addChild(iconSprite)

	-- 心数
	
	local starNumLabel = nil
	if(tonumber(achieveData.completeArray) == 1)then
		starNumLabel = CCLabelTTF:create(achieveData.completeArray, g_sFontName, 25)
	else
		starNumLabel = CCRenderLabel:create(achieveData.completeArray, g_sFontName, 25, 1, ccc3(0, 0, 0), type_stroke)
	end
	starNumLabel:setColor(numColor)
    starNumLabel:setAnchorPoint(ccp(1, 0))
    starNumLabel:setPosition(ccp(potentialSprite:getContentSize().width*0.9, potentialSprite:getContentSize().height*0.05))
    potentialSprite:addChild(starNumLabel)

	return borderSprite
end
