-- Filename: 	HeroUtil.lua
-- Author: 		chengliang
-- Date: 		2013-07-15
-- Purpose: 	hero工具方法


module ("HeroUtil", package.seeall)

require "script/model/hero/HeroModel"
require "script/model/DataCache"
require "db/DB_Heroes"

-- zhangqi, 2015-01-23, 用遮罩裁剪的方式在矩形头像图标基础上创建一个圆形头像, 锚点在中心
-- 参数 image_path：图标文件的路径
--		sacle_factor: 需要缩放的比例，例如1.2
-- return: clipper, CCNode类型的圆形头像节点；stencilSize，头像的size
function createCircleAvatar( image_path, scale_factor )
	local clipper, stencilSize = UIHelper.addMaskForImage(image_path, "images/common/circle.png", scale_factor) -- 裁剪头像用的圆形图片
	return clipper, stencilSize
end


-- 根据hid获得英雄的相关信息 int
function getHeroInfoByHid( hid )
	local heroAllInfo = nil
	local allHeros = HeroModel.getAllHeroes()

	for t_hid, t_hero in pairs(allHeros) do

		if( tonumber(t_hid) ==  tonumber(hid)) then
			heroAllInfo = t_hero
			break
		end
	end
	heroAllInfo.localInfo = DB_Heroes.getDataById(tonumber(heroAllInfo.htid))

	return heroAllInfo
end

-- 根据htid获得英雄DB信息
function getHeroLocalInfoByHtid( htid )
	local dbhero = DB_Heroes.getDataById(htid)
	dbhero.quality = dbhero.potential
	return dbhero
end

-- zhangqi, 2015-02-26, 去主角后只需要取伙伴信息表中的name
function getHeroNameByHid( hid )
    local heroInfo = getHeroInfoByHid(hid)
    return heroInfo.localInfo.name
end

-- zhangqi, 2015-01-14, 根据hid获得伙伴当前可进阶的上限值
function getHeroTransferLimitByHid( hid )
	local heroInfo = getHeroInfoByHid(hid)
	if (not heroInfo) then
		return 0
	end

	local heroAdvanceId = heroInfo.localInfo.advanced_id
	if (not heroAdvanceId) then
		return 0
	end
	logger:debug("getHeroTransferLimitByHid, heroAdvanceId = %s", heroAdvanceId)
	local tbTrans = string.strsplit(heroAdvanceId, ",")
	logger:debug(tbTrans)

	local lastTransfNum = heroInfo.evolve_level
	require "db/DB_Hero_transfer"
	for i, str in ipairs(tbTrans) do
		local num, htid = string.match(str, "(%d+)|(%d+)")
		logger:debug("num = %d htid = %d", num, htid)

		local trans = DB_Hero_transfer.getDataById(htid)
		if (trans and trans.limit_lv > tonumber(heroInfo.level) ) then
			logger:debug("getHeroTransferLimitByHid-hid = %d, limit_lv = %d, hero.level = %d, i = %d", 
				hid, trans.limit_lv, tonumber(heroInfo.level), i)
			return lastTransfNum -- 进阶限制等级 > 伙伴当前等级 后，前一个限制等级对应的 num 才是进阶上限
		end
		lastTransfNum = tonumber(num) + 1 -- 2015-01-30， 因为num从0开始，所以需要+1表示上次进阶级数
	end

	return heroInfo.evolve_level -- 否则返回当前的进阶等级
end

-- 根据htid获得hero的头像 int (dressId,gender 可不传) genderId 1男，2女
function getHeroIconByHTID( htid, dressId, genderId )
	local heroInfo = getHeroLocalInfoByHtid(htid)
	local bgSprite = CCSprite:create("images/base/potential/color_" .. heroInfo.potential .. ".png")

	local headFile = getHeroIconImgByHTID( htid, dressId )

	local iconSprite = CCSprite:create(headFile)
	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))

	local iconBorder = CCSprite:create("images/base/potential/officer_" .. heroInfo.potential .. ".png")
	iconBorder:setAnchorPoint(ccp(0.5, 0.5))
	iconBorder:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))

	bgSprite:addChild(iconSprite)
	bgSprite:addChild(iconBorder)

	return bgSprite
end

-- 根据htid获得hero的圆形头像，仅用于用户信息面板
function getYuanHeroIconByHTID( htid, dressId )
	-- local imgName = ""
	-- if(dressId and tonumber(dressId)>0)then
	-- 	-- 如果有时装
	-- 	require "db/DB_Item_dress"
	-- 	local dressInfo = DB_Item_dress.getDataById(dressId)
	-- 	genderId = HeroModel.getSex(htid)
	-- 	imgName =  getStringByFashionString(dressInfo.changeHeadIcon, genderId)
	-- else
	-- 	-- 没有时装
	-- 	require "db/DB_Heroes"
	-- 	local heroInfo = DB_Heroes.getDataById(htid)
	-- 	print("getYuanHeroIconByHTID htid:", htid)
	-- 	if (tonumber(heroInfo.model_id) == 20001) then -- 男主
	-- 		imgName = "images/base/hero/head_icon/yuan_nanzhu.png"
	-- 	else
	-- 		imgName = "images/base/hero/head_icon/yuan_nvzhu.png"
	-- 	end
	-- end

	-- return imgName
	return getHeroIconImgByHTID(htid, dressId)
end

-- 根据htid获得hero的头像 int
function getHeroIconImgByHTID( htid, dressId )
	local imgName = ""
	if(dressId and tonumber(dressId)>0)then
		-- 如果有时装
		require "db/DB_Item_dress"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		genderId = HeroModel.getSex(htid)
		imgName =  getStringByFashionString(dressInfo.changeHeadIcon, genderId)
	else
		-- 没有时装
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		imgName =  heroInfo.head_icon_id
	end
	logger:debug(imgName)
	return "images/base/hero/head_icon/" .. imgName
end

--[[desc: zhangqi, 创建一个hero头像的Button控件
    htid: hero id
    dressId: 时装 id
   	fnBtnEvent: 按钮回调事件
    return: 1, Button 2, hero 的配置表信息
—]]
function createHeroIconBtnByHtid( htid, dressId, fnBtnEvent, number)
	local heroInfo = getHeroLocalInfoByHtid(htid)
	local bgFile = "images/base/potential/color_" .. heroInfo.potential .. ".png"
	local btnIcon = Button:create()
	btnIcon:loadTextures(bgFile, bgFile, nil) -- 用品质边框初始化按钮

	local imgIcon = ImageView:create()
	imgIcon:loadTexture(getHeroIconImgByHTID(htid, dressId))
	btnIcon:addChild(imgIcon)

	local imgBorder = ImageView:create()
	imgBorder:loadTexture("images/base/potential/officer_" .. heroInfo.potential .. ".png")
	btnIcon:addChild(imgBorder)

	local imgLight = ImageView:create()
	imgLight:loadTexture("images/base/potential/officer_light.png")
	btnIcon:addChild(imgLight)

	if (fnBtnEvent) then
		btnIcon:addTouchEventListener(fnBtnEvent)
	else
		btnIcon:setTouchEnabled(false)
	end
	if(number~=nil) then
		local ttfItemName = UIHelper.createStrokeTTF( "" .. number, ccc3(0,255,0), nil, true)
		ttfItemName:setPosition(ccp(btnIcon:getContentSize().width*.45,-btnIcon:getContentSize().height*.35))
		btnIcon:addNode(ttfItemName)
		ttfItemName:setAnchorPoint(ccp(1,0.5))
	end

	return btnIcon, heroInfo
end


--[[desc: huxiaozhou, 创建一个NPC hero头像的Button控件
    _htid: hero id
   	fnBtnEvent: 按钮回调事件
    return: 1, Button
—]]
function createNPCHeroIconBtnByHtid( _htid , fnBtnEvent)
	require "db/DB_Monsters"
	local htid = DB_Monsters.getDataById(_htid).htid
	-- 根据htid查找DB_Monsters_tmpl表得到icon
	require "db/DB_Monsters_tmpl"
	local heroData = DB_Monsters_tmpl.getDataById(htid)
	local icon ="images/base/hero/head_icon/" .. heroData.head_icon_id
	-- local quality_bg ="images/hero/quality/"..heroData.star_lv .. ".png"
	local quality_bg =  "images/base/potential/color_" .. heroData.star_lv .. ".png"
	local btnIcon = Button:create()
	btnIcon:loadTextures(quality_bg, quality_bg, nil) -- 用品质边框初始化按钮
	if (fnBtnEvent) then
		btnIcon:addTouchEventListener(fnBtnEvent)
	else
		btnIcon:setTouchEnabled(false)
	end

	local imgIcon = ImageView:create()
	imgIcon:loadTexture(icon)
	btnIcon:addChild(imgIcon)

	local imgBor = ImageView:create()
	imgBor:loadTexture("images/base/potential/officer_" .. heroData.star_lv .. ".png")
	btnIcon:addChild(imgBor)

	return btnIcon
end

-- 英雄的全身像图片地址 (dressId,gender 可不传) genderId 1男，2女
function getHeroBodyImgByHTID( htid, dressId, genderId )

	local imgName = ""
	if(dressId and tonumber(dressId)>0)then
		-- 如果有时装
		require "db/DB_Item_dress"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		genderId = HeroModel.getSex(htid)
		imgName =  getStringByFashionString(dressInfo.changeBodyImg, genderId)
	else
		-- 没有时装
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(htid)
		imgName =  heroInfo.body_img_id
	end

	return "images/base/hero/body_img/" .. imgName
end

-- 英雄的全身像图片地址 (dressId,gender 可不传) genderId 1男，2女
function getHeroBodySpriteByHTID( htid, dressId, genderId )
	local iconFile =  getHeroBodyImgByHTID( htid, dressId, genderId )

	return CCSprite:create(iconFile)
end

-- 分男女 解析时装的字段
function getStringByFashionString( fashion_str, genderId)
	genderId = tonumber(genderId)
	local t_fashion = splitFashionString(fashion_str)
	if(genderId == 1)then
		return t_fashion["20001"]
	else
		return t_fashion["20002"]
	end

end

--
function splitFashionString( fashion_str )
	local fashion_t = {}
	local f_t = string.split(fashion_str, ",")
	for k,ff_t in pairs(f_t) do
		local s_t = string.split(ff_t, "|")
		fashion_t[s_t[1]] = s_t[2]
	end

	return fashion_t
end


-- 根据htid获得hero的半身像 int
-- 金城确认无半身像，返回全身像 2013.08.14
-- k 2013.8.2
function getHeroHalfLenImageStringByHTID( htid )
	require "db/DB_Heroes"
	local heroInfo = DB_Heroes.getDataById(htid)


	if(heroInfo==nil)then
		print("无此武将信息！")
		return nil
	end
	---[[
	if(heroInfo.body_img_id==nil)then
		print("此武将无半身像信息！")
		return nil
	end
	--]]
	--暂无半身资源，使用全身资源
	--local str = "images/base/hero/body_img/" .. heroInfo.body_img_id
	local str = "images/base/hero/body_img/" .. heroInfo.body_img_id

	return str
end

-- 按强化等级由高到低排序
local function fnCompareWithLevel(h1, h2)
	return h1.level > h2.level
end
-- 按进阶次数排序
local function fnCompareWithEvolveLevel(h1, h2)
	if tonumber(h1.evolve_level) == tonumber(h2.evolve_level) then
		return fnCompareWithLevel(h1, h2)
	else
		return tonumber(h1.evolve_level) > tonumber(h2.evolve_level)
	end
end
-- 按星级高低排序
local function fnCompareWithStarLevel(h1, h2)
	if h1.star_lv == h2.star_lv then
		return fnCompareWithEvolveLevel(h1, h2)
	else
		return h1.star_lv > h2.star_lv
	end
end

-- 将领的排序
function heroSort( hero_1, hero_2 )
	--yangna 2015.1.24   去script/ui 修改
	-- local isPre = false
	-- if(hero_1.heroDesc.potential>hero_2.heroDesc.potential) then
	-- 	isPre = true
	-- elseif(hero_1.heroDesc.potential==hero_2.heroDesc.potential)then
	-- 	require "script/ui/hero/HeroPublicLua"
	-- 	local h1 = HeroPublicLua.getHeroDataByHid02(hero_1.hid)
	-- 	local h2 = HeroPublicLua.getHeroDataByHid02(hero_2.hid)

	-- 	-- if(hero_1.fightDict.vitalStat > hero_2.fightDict.vitalStat)then
	-- 	-- 	isPre = true
	-- 	-- end
	-- 	isPre = fnCompareWithEvolveLevel(h1, h2)
	-- end
	-- return isPre
end

-- 是否有相同将领已经在小伙伴阵上
local function isHadSameTemplateOnLittleFriend(h_id)
	local isOn = false
	h_id = tonumber(h_id)
	local heroInfo = getHeroInfoByHid(h_id)
	local formationInfo = DataCache.getExtra()
	local onNum = 0
	if (formationInfo ~= nil) then
		for k,v in pairs(formationInfo) do
			if(tonumber(v)>0)then
				local t_heroInfo = getHeroInfoByHid(v)
				if(tonumber(t_heroInfo.htid) == tonumber(heroInfo.htid))then
					isOn = true
					break
				end
			end
		end
	end
	return isOn
end

-- 获得空闲的将领
function getFreeHerosInfo( )
	local freeHerosInfo = {}
	local allHeros = HeroModel.getAllHeroes()
	local formationInfos = DataCache.getFormationInfo()
	--require "script/ui/hero/HeroFightForce"
	for t_hid, t_hero in pairs(allHeros) do
		local isFree = true
		for k,  f_hid in pairs(formationInfos) do
			if( tonumber(t_hid) ==  tonumber(f_hid)) then
				isFree = false
				break
			end
		end

		-- changed by zhang zihang
		if(isFree)then
			isFree = not(isHadSameTemplateOnLittleFriend( tonumber(t_hid) ))
		end

		if(isFree)then
			require "db/DB_Heroes"
			t_hero.heroDesc = DB_Heroes.getDataById(t_hero.htid)
			--			t_hero.fightDict = HeroFightForce.getAllForceValuesByHid(t_hero.hid)
			table.insert(freeHerosInfo, t_hero)
		end
	end
	table.sort( freeHerosInfo, heroSort )

	return freeHerosInfo
end

-- 获得武将身上的装备信息
function getEquipsOnHeros()
	local equipsOnHeros = {}
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		for equip_pos, equipInfo in pairs(t_hero.equip.arming) do
			if( not table.isEmpty(equipInfo) ) then
				equipInfo.pos = equip_pos
				equipInfo.hid = t_hid
				equipInfo.equip_hid = t_hid
				equipsOnHeros[equipInfo.item_id] = equipInfo
			end
		end
	end

	return equipsOnHeros
end

-- 获得某个武将身上的装备
function getEquipsByHid( hid )
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		if(tonumber(t_hid) == tonumber(hid))then
			logger:debug("getEquipsByHid")
			logger:debug(t_hero.equip.arming)
			return t_hero.equip.arming
		end
	end
	return nil
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已穿装备数量
function getWearedEquipNumByHid( hid )
	local count = 0
	for k, equip in pairs(getEquipsByHid(hid) or {}) do
		if (type(equip) == "table") then
			count = count + 1
		end
	end
	return count
end

-- zhangqi, 2015-01-14, 根据hid和属性名获取某个伙伴已穿装备的某个属性值
function getWeardEquipAttrByHid( hid, sFieldName )
	logger:debug("getWeardEquipAttrByHid")
	local value = 0
	for k, equip in pairs(getEquipsByHid(hid) or {}) do
		if (type(equip) == "table") then
			logger:debug(equip)
			value = value + tonumber(equip.va_item_text[sFieldName] or 0)
			logger:debug("%s:value = %d", sFieldName, value)
		end
	end
	return value
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已穿装备的强化等级
function getWeardEquipStrenthLevelByHid( hid )
	logger:debug("getWeardEquipStrenthLevelByHid")
	return getWeardEquipAttrByHid(hid, "armReinforceLevel")
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已穿装备的附魔等级
function getWeardEquipMagicLevelByHid( hid )
	logger:debug("getWeardEquipMagicLevelByHid")
	return getWeardEquipAttrByHid(hid, "armEnchantLevel")
end
function getWeardEquipMagicMaxByHid( hid )
	logger:debug("getWeardEquipMagicMaxByHid")
	local value = 0
	for k, equip in pairs(getEquipsByHid(hid) or {}) do
		if (type(equip) == "table") then
			logger:debug(equip)
			value = value + ItemUtil.getMaxEnchatLevel(equip)
		end
	end
	return value
end

-- 返回某个武将身上的装备的item_template_id的array，zhangqi, 2014-07-11
function getTemplateIdOfEquipByHid( hid )
	local tbEquips = getEquipsByHid(hid)
	local itemIds = {}
	for k, v in pairs(tbEquips or {}) do
		table.insert(itemIds, v.item_template_id)
	end
	return itemIds
end

-- add by chengliang, 获得武将身上的所有宝物
function getTreasOnHeros()
	local treasOnHeros = {}
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		for treas_pos, treasInfo in pairs(t_hero.equip.treasure) do
			if( not table.isEmpty(treasInfo) ) then
				treasInfo.pos = treas_pos
				treasInfo.hid = t_hid
				treasInfo.equip_hid = t_hid
				treasOnHeros[treasInfo.item_id] = treasInfo
			end
		end
	end
	return treasOnHeros
end

-- add by chengliang, 获得某个武将身上的宝物
function getTreasByHid( hid )
	logger:debug("getTreasByHid")
	local allHeros = HeroModel.getAllHeroes()
	for t_hid, t_hero in pairs(allHeros) do
		if(tonumber(t_hid) == tonumber(hid))then
			logger:debug(t_hero.equip.treasure)
			return t_hero.equip.treasure
		end
	end
	return nil
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已装备宝物数量
function getWearedTreasNumByHid( hid )
	local count = 0
	for k, treas in pairs(getTreasByHid(hid) or {}) do
		if (type(treas) == "table") then
			count = count + 1
		end
	end
	return count
end

-- zhangqi, 2015-01-14, 根据hid和属性名获取某个伙伴已穿宝物的某个属性值
function getWearedTreasAttrByHid( hid, sFieldName )
	logger:debug("getWearedTreasAttrByHid")
	local value = 0
	for k, treas in pairs(getTreasByHid(hid) or {}) do
		if (type(treas) == "table") then
			logger:debug(treas)
			value = value + tonumber(treas.va_item_text[sFieldName] or 0)
			logger:debug("value = %d", value)
		end
	end
	return value
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已穿宝物的强化等级
function getWearedTreasStrenthLevelByHid( hid )
	logger:debug("getWearedTreasStrenthLevelByHid")
	return getWearedTreasAttrByHid(hid, "treasureLevel")
end
function getWearedTreasStrenthMaxByHid( hid ) -- 根据hid获取某个伙伴已穿宝物的强化等级上限
	local value = 0
	for k, treas in pairs(getTreasByHid(hid) or {}) do
		if (type(treas) == "table") then
			logger:debug(treas)
			value = value + ItemUtil.getMaxStrenthLevelOfTreas(treas)
		end
	end
	return value
end

-- zhangqi, 2015-01-14, 根据hid获取某个伙伴已穿宝物的精炼等级
function getWearedTreasEvolveLevelByHid( hid )
	logger:debug("getWearedTreasEvolveLevelByHid")
	return getWearedTreasAttrByHid(hid, "treasureEvolve")
end
function getWearedTreasEvolveMaxByHid( hid ) -- 根据hid获取某个伙伴已穿宝物的精炼等级上限
	local value = 0
	for k, treas in pairs(getTreasByHid(hid) or {}) do
		if (type(treas) == "table") then
			logger:debug(treas)
			value = value + ItemUtil.getMaxRefineLevelOfTreas(treas)
		end
	end
	logger:debug("getWearedTreasEvolveMaxByHid, hid = %d, value = %d", hid, value)
	return value
end

-- zhangqi, 2015-02-26, 获得所有伙伴身上的空岛贝
function getAllConchOnHeros()
	local allConch = {}

	local function insertConch( heros, tbConchs )
		for _, hid in pairs(heros) do
			if( tonumber(hid) > 0 )then
				local conch = getConchByHid( hid )
				if(not table.isEmpty(conch))then
					for k,v in pairs(conch) do
						tbConchs[k] = v
						tbConchs[k].itemDesc = ItemUtil.getItemById(v.item_template_id)
						tbConchs[k].itemDesc.desc = tbConchs[k].itemDesc.info
					end
				end
			end
		end
	end
	-- 阵容上伙伴
	local formation = DataCache.getFormationInfo()
	insertConch(formation, allConch)
	-- 替补伙伴
	local bench = DataCache.getBench()
	insertConch(bench, allConch)

	return allConch
end

-- zhangqi, 2015-02-26, 获得某个伙伴身上的空岛贝
function getConchByHid( hid )
	local tbConchs = {}
	local allHeros = HeroModel.getAllHeroes()
	if( (not table.isEmpty(allHeros["" .. hid].equip)) and   (not table.isEmpty(allHeros["" .. hid].equip.conch)) )then
		local conchs = allHeros["" .. hid].equip.conch
		for pos, conch in pairs(conchs) do
			if (type(conch) == "table") then -- 开放但是没有装备空岛贝的pos是用字符串"0"表示
				conch.hid = hid
				conch.equip_hid = hid
				conch.pos = pos
				tbConchs[conch.item_id] = conch
			end
		end
	end
	return tbConchs
end

-- 计算某个htid的武将有多少个
function getHeroNumByHtid( h_tid )
	h_tid = tonumber(h_tid)
	local allHeros = HeroModel.getAllHeroes()
	local number = 0

	for k,v in pairs(allHeros) do
		if(tonumber(v.htid) == h_tid)then
			number = number + 1
		end
	end

	return number
end

