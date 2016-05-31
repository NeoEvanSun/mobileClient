-- Filename: HeroModel.lua.
-- Author: fang.
-- Date: 2013-07-09
-- Purpose: 武将数据

module("HeroModel", package.seeall)



-- 所有英雄数据
local _allHeroes

-- 获得所有武将信息
function getAllHeroes()
	return _allHeroes
end
-- 设置所有武将信息
function setAllHeroes(heroes)
	_allHeroes = heroes
end

-- 通过hid获得英雄属性
function getHeroByHid(hid)
	return _allHeroes[tostring(hid)]
end
-- 获取所有英雄hids
function getAllHeroesHid()
	local hids = {}
	if _allHeroes == nil then
		return hids
	end
	for k, v in pairs(_allHeroes) do
		hids[#hids+1] = v.hid
	end

	return hids
end
-- 获得当前武将数量
function getHeroNumber()
	return table.count(_allHeroes)
end

-- 通过国家ID获取国家相应等级图标
-- cid -> 所属国家id
-- star_lv -> 星级
function getCiconByCidAndlevel(cid, star_lv)
	local countries = {"wind", "thunder", "water", "fire", "empty"}
	if (tonumber(cid) == 0 or countries[cid] == nil) then
		cid = 5
		return "images/hero/" .. countries[cid] .. "/" .. countries[cid] .. star_lv .. ".png"
			-- return "images/common/transparent.png"
	end
	return "images/hero/" .. countries[cid] .. "/" .. countries[cid] .. star_lv .. ".png"
end

-- 通过国家ID获取国家相应等级大图标（是大图标）
-- cid -> 所属国家id
-- star_lv -> 星级
function getLargeCiconByCidAndlevel(cid, star_lv)
	local countries = {"wind", "thunder", "water", "fire"}
	if (countries[cid] == nil) then
		return "images/common/transparent.png"
	end

	return "images/hero/" .. countries[cid] .. "/" .. countries[cid] .. star_lv .. ".png"
end

-- 删除某个英雄
-- hid -> 被删除的英雄hid
function deleteHeroByHid(hid)
	_allHeroes[tostring(hid)] = nil
end
-- 添加英雄
-- hid -> 被添加的英雄hid
function addHeroWithHid(hid, h_data)
	_allHeroes[tostring(hid)] = h_data
end
-- 根据英雄htid获得头像
function getHeroHeadIconByHtid(htid)
	require "db/DB_Heroes"
	local data = DB_Heroes.getDataById(htid)
	return "images/base/hero/head_icon/"..data.head_icon_id
end

-- 获取武将性别
-- return, 1男，2女
function getSex(htid)
	--zhangqi, 2015-01-09, 去主角修改, 默认返回男性别
	return 1
end

function getHeroModelId(htid)
	require "db/DB_Heroes"
	local model_id = DB_Heroes.getDataById(htid).model_id
	return model_id
end

-- 获取主角的武将信息方法
function getNecessaryHero( ... )
	if _allHeroes == nil then
		return
	end
	for k, v in pairs(_allHeroes) do
		local db_hero = DB_Heroes.getDataById(v.htid)
		if db_hero.model_id == 20001 or db_hero.model_id == 20002 then
			return v
		end
	end
end

-- 通过modelID判断影子是否已招募存在伙伴列表中，zhangqi, 2014-07-23
function isBuddy( htid )
	local nHtid = tonumber(htid)
	if(not nHtid) then
		return false
	end
	local pModelID = tonumber(getHeroModelId(nHtid))
	if(not pModelID) then
		for k, v in pairs(_allHeroes) do
			if (tonumber(v.htid) == nHtid) then
				return true
			end
		end
		return false
	end
	local pHtid = fnGetRealHaveHtidByModelID(pModelID)
	if(pHtid ~= 0) then
		return true
	end
	return false
end


-- 通过htid获得所有htid相同的当前武将列表
function getAllByHtid(tParam)
	local tArrHeroes = {}
	for k, v in pairs(_allHeroes) do
		if tonumber(v.htid) == tParam.htid then
			table.insert(tArrHeroes, v)
		end
	end
	return tArrHeroes
end

function getHidByHtid( htid )
	
	for k, v in pairs(_allHeroes) do
		if tonumber(v.htid) == htid then
			return tonumber(k)		 
		end
	end
	return 0
end

-- 通过武将hid修改武将的等级
function setHeroLevelByHid(pHid, pLevel)
	_allHeroes[tostring(pHid)].level = pLevel
end
--
function setMainHeroLevel(pLevel)
	UserModel.setUserLevel(pLevel)
end

-- add by chengliang
-- 修改hero身上装备的强化等级
function changeHeroEquipReinforceBy( hid, item_id, addLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == item_id) then
			local level = tonumber(arm_info.va_item_text.armReinforceLevel) + addLv
			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceLevel"] = tostring(level)
			break
		end
	end
end

-- add by chengliang
-- 设置hero身上装备的强化等级
function setHeroEquipReinforceLevelBy( hid, item_id, curLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == tonumber(item_id)) then
			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceLevel"] = tostring(curLv)
			break
		end
	end
end

-- add by zhangjunwu
-- 设置hero身上装备的附魔等级
function setHeroEquipEnchanteLevelBy( hid, item_id, curLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == tonumber(item_id)) then
			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armEnchantLevel"] = tostring(curLv)
			break
		end
	end
end

-- add by zhangjunwu
-- 设置hero身上装备的附魔经验
function setHeroEquipEnchantExplBy( hid, item_id, curLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == tonumber(item_id)) then
			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armEnchantExp"] = tostring(curLv)
			break
		end
	end
end

-- add by chengliang
-- 设置hero身上装备的强化费用
function setHeroEquipReinforceLevelCostBy( hid, item_id, curCost )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == tonumber(item_id)) then
			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(curCost)
			break
		end
	end

end

-- add by chengliang
-- 修改hero身上装备的强化等级
function changeHeroEquipReinforceCostBy( hid, item_id, addCost )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( arm_info.item_id ) == item_id) then
			if(_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"])then
				_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(tonumber(arm_info.va_item_text.armReinforceLevel) + tonumber(addCost))
			else
				_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(addCost)
			end

			break
		end
	end
end

--add by zhaoqingjun
-- 修改武将身上的装备
function changeEquipFromHeroBy( hid, r_pos, equipInfo)
	logger:debug("hid:".. hid .."pos:".. r_pos)
	logger:debug(equipInfo)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( pos ) == tonumber(r_pos)) then
			_allHeroes[tostring(hid)].equip.arming[pos] = equipInfo[r_pos]
			break
		end
	end
end

-- add by chengliang
-- 卸下武将身上的装备
function removeEquipFromHeroBy( hid, r_pos)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		if(tonumber( pos ) == tonumber(r_pos)) then
			_allHeroes[tostring(hid)].equip.arming[pos] = "0"
			break
		end
	end
end
-- 检查武将(hid)是否装备了某个装备id(item_template_id)
function checkEquipStatus(pHid, pItid)
	local tArming = _allHeroes[tostring(pHid)].equip.arming
	for k, v in pairs(tArming) do
		if type(v) == "table" then
			if tonumber(v.item_template_id) == tonumber(pItid) then
				return true
			end
		end
	end

	return false
end

-- 检查武将(hid)是否装备了某个宝物(item_template_id)
function checkTreasureStatus(pHid, pItid)
	local tArming = _allHeroes[tostring(pHid)].equip.treasure
	for k, v in pairs(tArming) do
		if type(v) == "table" then
			if tonumber(v.item_template_id) == tonumber(pItid) then
				return true
			end
		end
	end

	return false
end

-- add by chengliang
-- 卸下武将身上的宝物
function removeTreasFromHeroBy( hid, r_pos)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.treasure) do
		if(tonumber( pos ) == tonumber(r_pos)) then
			_allHeroes[tostring(hid)].equip.treasure[pos] = nil
			break
		end
	end
end

-- 为指定hid的武将设置武魂数
function setHeroSoulByHid(pHid, pSoul)
	_allHeroes[tostring(pHid)].soul = pSoul
end

-- 通过武将hid增加进阶等级
function addEvolveLevelByHid(pHid, pAddedLevel)
	_allHeroes[tostring(pHid)].evolve_level = tonumber(_allHeroes[tostring(pHid)].evolve_level) + pAddedLevel
end

-- 通过武将hid修改其htid
function setHtidByHid(pHid, pHtid)
	_allHeroes[tostring(pHid)].htid = pHtid
end

-- 判断当前武将数量是否已达上限
-- out: true表示武将数量已达上限，false表示未达上限
function isLimitedCount()
	local nCount = table.count(_allHeroes)
	if nCount >= UserModel.getHeroLimit() then
		return true
	end

	return false
end

-- 交换两个武将的装备信息  -- 程亮
function exchangeEquipInfo( f_hid, s_hid )
	if(f_hid == nil or s_hid == nil) then
		return
	end
	f_hid = tonumber(f_hid)
	s_hid = tonumber(s_hid)

	local f_equipInfo = _allHeroes["" .. f_hid].equip
	_allHeroes["" .. f_hid].equip = _allHeroes["" .. s_hid].equip
	_allHeroes["" .. s_hid].equip = f_equipInfo
end

-- 获得当前所有武将的国家分类数量
-- return. tHeroNumByCountry = {wei=18, shu=56, wu=98, qun=99}
function getHeroNumByCountry( ... )
	require "db/DB_Heroes"
	local nWei=0
	local nShu=0
	local nWu=0
	local nQun=0
	if _allHeroes then
		for k, v in pairs(_allHeroes) do
			local db_hero = DB_Heroes.getDataById(v.htid)
			local countryId = db_hero.country
			if countryId == 1 then
				nWei = nWei + 1
			elseif countryId == 2 then
				nShu = nShu + 1
			elseif countryId == 3 then
				nWu = nWu + 1
			else
				nQun = nQun + 1
			end
		end
	end
	local tHeroNumByCountry = {}
	tHeroNumByCountry.wei = nWei
	tHeroNumByCountry.shu = nShu
	tHeroNumByCountry.wu = nWu
	tHeroNumByCountry.qun = nQun

	return tHeroNumByCountry
end

-- 通过武将的htid和进阶次数计算出该武将的等级上限
-- params: pHtid: 武将的htid, pEvolveLevel: 该武将的进阶等级
-- return: 武将等级上限
function getHeroLimitLevel(pHtid, pEvolveLevel)
	local nLimitLevel = 0
	local nEvolveLevel = pEvolveLevel or 0
	local db_hero = DB_Heroes.getDataById(pHtid)
	if db_hero then
		nLimitLevel = db_hero.strength_limit_lv + tonumber(nEvolveLevel)*db_hero.strength_interval_lv
	end

	return nLimitLevel
end

-- 修改武将身上的装备等级
function addArmLevelOnHerosBy( hid, pos, addLv )
	local enhanceLv = tonumber(_allHeroes["" .. hid].equip.arming["" .. pos].va_item_text.armReinforceLevel) + tonumber(addLv)
	_allHeroes["" .. hid].equip.arming["" .. pos].va_item_text.armReinforceLevel = enhanceLv
end

-- 修改武将身上的宝物等级
function addTreasLevelOnHerosBy( hid, pos, addLv, totalExp )
	local enhanceLv = tonumber(_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureLevel) + tonumber(addLv)
	_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureLevel = enhanceLv
	_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureExp = totalExp
end

-- 修改武将身上的战魂等级
function addFSLevelOnHerosBy( hid, pos, cruLv, totalExp )
	_allHeroes["" .. hid].equip.fightSoul["" .. pos].va_item_text.fsLevel = cruLv
	_allHeroes["" .. hid].equip.fightSoul["" .. pos].va_item_text.fsExp = totalExp
end

-- 通过item_template_id获取武魂当前数量和需要的数量
-- return. {item_num=物品实际数量, need_num=物品需要的数量}
function getNumByItemTemplateId(pItemTemplateId)
	local tRetValue = {item_num=0, need_num=0}

	local tHeroFrag = DataCache.getHeroFragFromBag()
	if not tHeroFrag then
		return tRetValue
	end

	for k,v in pairs(tHeroFrag) do
		if tonumber(v.item_template_id) == tonumber(pItemTemplateId) then
			tRetValue.item_num = tonumber(v.item_num)
			break
		end
	end
	if tRetValue.item_num > 0 then
		require "db/DB_Item_hero_fragment"
		local heroFragment = DB_Item_hero_fragment.getDataById(pItemTemplateId)
		tRetValue.need_num = heroFragment.need_part_num
	end

	return tRetValue
end


function setHeroFixedPotentiality( item_id ,potentiality_info )
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.arming) do
			if(tonumber(vh) ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armFixedPotence = potentiality_info
					logger:debug("正在设置")
					break
				end
			end
		end
	end
end

function setHeroPotentiality( item_id)
	logger:debug("setHeroPotentiality = " .. item_id)
	logger:debug(potentiality_info)
	logger:debug("开始设置")
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.arming) do
			if(tonumber(vh)  ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armPotence = vh.va_item_text.armFixedPotence
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armFixedPotence = nil
					logger:debug("正在设置")
					break
				end
			end
		end
	end
	logger:debug("设置结束")
	logger:debug(_allHeroes)
end

--[[
	@设置宝物精炼等级
--]]
function setTreasureEvolveLevel( item_id, evolve_level )
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.treasure) do
			if(tonumber(vh)  ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.treasure[tostring(kh)].va_item_text.treasureEvolve = evolve_level
					break
				end
			end
		end
	end
end

--[[
	@des 	:	获取伙伴天赋图标
	@params	:	cacheName 传入评级
	@return :	返回图标sprite
--]]
function fnGetTalentFrame( cacheName )
	local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
	cache:addSpriteFramesWithFile("images/base/hero/talentLevel/talentLevel.plist", "images/base/hero/talentLevel/talentLevel.png")
	return CCSprite:createWithSpriteFrame(cache:spriteFrameByName(cacheName..".png"))
end

function fnGetHaveHtidByModelID( modelID )
	local haveHtid,showHtid = fnGetRealHaveHtidByModelID(modelID)
	if(haveHtid == 0) then
		haveHtid = showHtid
	end
	return haveHtid
end

--根据modelid 取出背包里有的htid
function fnGetRealHaveHtidByModelID( modelID )
	local haveHtid = 0
	local showHtid = 0
	local pModelID = tonumber(modelID)
	if(not pModelID) then
		return haveHtid, showHtid
	end
	require "db/DB_Hero_model_id"
	local pDBModel = DB_Hero_model_id
	local pDB = pDBModel.getDataById(pModelID)
	if(not pDB) then
		return haveHtid, showHtid
	end
	showHtid = tonumber(pDB.recommend_htid)
	-- require "script/utils/LuaUtil"
	local phtids = string.split(pDB.htids,"|")
	if(table.count(phtids) > 0) then
		local pHeroInfo = nil
		for pkey,phero in pairs(_allHeroes) do
			local pHtid1 = tonumber(phero.htid) or -1
			for k,v in pairs(phtids) do
				local pHtid2 = tonumber(v) or 0
				if(pHtid1 == pHtid2) then
					haveHtid = pHtid2
					return haveHtid
				end
			end
		end
	end
	return haveHtid, showHtid
end

local m_i18n = gi18n

-- 1 wugong.png 物攻型 [1814]
-- 2 mogong.png 魔攻型 [1815]
-- 3 fangyu.png 防御型 [1828]
-- 4 gedang.png 格挡型 [1825]
-- 5 kongzhi.png 控制型 [1827]
-- 6 shanbi.png 闪避型 [1824]
-- 7 guwu.png 鼓舞型 [1826]
-- 8 zhiliao.png 治疗型 [1816]
-- 9 jingyan.png 经验型 [1822]
local mHeroTypeString = {m_i18n[1814],m_i18n[1815],m_i18n[1828],m_i18n[1825]
					,m_i18n[1827],m_i18n[1824],m_i18n[1826],m_i18n[1816],m_i18n[1822]}
local mHeroTypePng = {"wugong","mogong","fangyu","gedang"
					,"kongzhi","shanbi","guwu","zhiliao","jingyan"}
local mHeroTypeColor = {ccc3( 0xf0, 0x68, 0x00),ccc3( 0x00, 0x8a, 0xff),ccc3( 0x01, 0x9a, 0x5b)
					,ccc3( 0xda, 0xb4, 0x00),ccc3( 0xde, 0x1b, 0x00),ccc3( 0x22, 0xd5, 0xb4)
					,ccc3( 0xd9, 0x2b, 0xba),ccc3( 0x57, 0xb2, 0x07),ccc3( 0xe1, 0x9e, 0x03),}


function fnGetHeroTypeInfo( type )
	local ptype = tonumber(type) or 1
	local pTabel = {string = mHeroTypeString[ptype],
					png = mHeroTypePng[ptype],
					color = mHeroTypeColor[ptype],}

	return pTabel
end
