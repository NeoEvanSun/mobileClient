-- FileName: RaiseFightModel.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("RaiseFightModel", package.seeall)

require "db/DB_Fight_up"
require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/model/user/UserModel"
require "script/module/switch/SwitchModel"
require "script/module/formation/FormationUtil"

-- UI控件引用变量 --

-- 模块局部变量 --
local m_pathRootImg = "images/fight/"
 -- m_tbGenData, 以提升类型(当前10种)为 index 保存计算每种提升类型当前值和上限值的function，还包括 "前往" 按钮的回调方法
local m_tbGenData = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {},}
local m_typeCount = 11
local m_tbSquad = DataCache.getSquad() -- 当前的阵型信息
local m_tbBench = DataCache.getBench() -- 当前替补的信息
local m_tbExtra = DataCache.getExtra() -- 小伙伴信息
local m_usrLv = UserModel.getHeroLevel() -- 玩家当前等级
local m_SQUAD_MAX = 5 -- 阵容最大上阵数

function destroy(...)
	package.loaded["script/module/main/RaiseFightModel"] = nil
	package.loaded["RaiseFightModel"] = nil
end

function moduleName()
    return "RaiseFightModel"
end

-- 切换到伙伴背包模块
local function gotoPartnerBag( ... )
	require "script/module/partner/MainPartner"
	local layPartner = MainPartner.create()
	if (layPartner) then
		LayerManager.changeModule(layPartner, MainPartner.moduleName(), {1, 3}, true)
		PlayerPanel.addForPublic()
	end
end
-- 切换到装备背包
local function gotoEquipBag( ... )
	require "script/module/equipment/MainEquipmentCtrl"
	local layEquipment = MainEquipmentCtrl.create()
	if layEquipment then
		LayerManager.changeModule(layEquipment, MainEquipmentCtrl.moduleName(), {1, 3}, true)
		PlayerPanel.addForPublic()
	end
end
-- 切换到宝物背包
local function gotoTreasBag( ... )
	require "script/module/bag/MainBagCtrl"
	LayerManager.changeModule(MainBagCtrl.create(2), MainBagCtrl.moduleName(), {1, 3}, true)
	PlayerPanel.addForPublic()
end
-- 切换到阵容
local function gotoFormation( nPageNum )
	logger:debug("gotoFormation-nPageNum = %d", nPageNum)
	require "script/module/formation/MainFormation"
	LayerManager.changeModule(MainFormation.create(nPageNum), MainFormation.moduleName(), {1,3}, true)
end

-- 提升类型cell的排序方法
-- 第一优先级为推荐指数，推荐指数越高，排位越靠前；第二优先级为提升度，提升度越小，排位越靠前；第三优先级根据战斗力提升途径id排序即可
local function sortRaise( item1, item2 )
	local bRet = false
	if (item1.recommend > item2.recommend) then
		bRet = true
	elseif (item1.recommend == item2.recommend) then 
		if (item1.curNum < item2.curNum) then
			bRet = true
		elseif (item1.curNum == item2.curNum) then
			if (item1.id < item2.id) then
				bRet = true
			end
		end
	end

	return bRet
end

-- {id = number, icon_path = "", title_path = "", recommend = number, curNum = number, maxNum = number, fnBtnCallback = function}
function getRaiseLists( ... )
	local tbLists = {{}, {}, {}}
	for i, item in ipairs(m_tbGenData) do
		local db = DB_Fight_up.getDataById(i)
		local data = {id = i, icon_path = m_pathRootImg .. db.icon, title_path = m_pathRootImg .. db.title, recommend = db.index}
		data.curNum = m_tbGenData[i].cur()
		data.maxNum = m_tbGenData[i].max()
		data.fnBtnCallback = m_tbGenData[i].onClick

		-- 如果上限值不大于0，则表示此类型没有提升空间，百分比按 100 取值
		local percent = data.maxNum > 0 and math.floor(data.curNum/data.maxNum * 100 + 0.5) or 100
		percent = percent > 100 and 100 or percent

		data.percent = percent

		logger:debug("index = %d, curNum = %d, maxNum = %d, percent = %d%%", db.index, data.curNum, data.maxNum, percent)

		if (percent == 100) then -- 完美无瑕
			if (data.maxNum > 0) then
				table.insert(tbLists[3], data)
			end
		elseif (percent >= tonumber(db.percentage) ) then -- 有待提高
			table.insert(tbLists[2], data)
		else
			table.insert(tbLists[1], data) -- 急需提升
		end
	end
	logger:debug("RaiseFightModel-getRaiseLists")
	logger:debug(tbLists)

	for i, list in ipairs(tbLists) do
		if (not table.isEmpty(list) and (#list > 1) ) then
			table.sort(list, sortRaise)
		end
	end
	logger:debug("RaiseFightModel-after sort")
	logger:debug(tbLists)

	return tbLists
end

-- 1	伙伴强化	玩家当前阵容上所有伙伴的强化等级和/玩家当前阵容上所有伙伴的强化等级上限和
-- 例如：玩家上阵6个伙伴，每个伙伴强化到10级，当前每个伙伴最大可强化到20级，则提升度=(10*6)/(20*6)=50%	伙伴列表
local m_heroLv = 0 -- 强化等级
local m_heroLvMaxLv = 0 -- 强化等级上限，也就是玩家等级
local m_transLv = 0 -- 进阶等级
local m_transLvMax = 0 -- 进阶等级上限（受限于当前伙伴强化等级）
local m_openSquad = 0 -- 阵上可上阵数
local m_heroSquad = 0 -- 阵上伙伴数量
local m_openBench = 0 -- 替补可上阵数量
local m_heroBench = 0 -- 替补已上阵数量
local m_emptyBench = 2 -- 替补的空位，从0到2

local m_equipNum = 0 -- 阵上伙伴已穿装备数量
local m_equipStrenthLv = 0 -- 阵上伙伴已穿装备的强化等级总和
local m_equipMagicLv = 0 -- 阵上伙伴已穿装备的附魔等级总和
local m_equipMagicMaxLv = 0 -- 阵上伙伴已穿装备的附魔等级上限总和

local m_treasNum = 0 -- 阵上伙伴已穿宝物数量
local m_treasStrenthLv = 0 -- 阵上伙伴已穿宝物的强化等级总和
local m_treasStrenthMaxLv = 0 -- 阵上伙伴已穿宝物的强化等级上限总和
local m_treasEvolveLv = 0 -- 阵上伙伴已穿宝物的精炼等级总和
local m_treasEvolveMaxLv = 0 -- 阵上伙伴已穿宝物的精炼等级上限总和

-- local m_solderNum = 0 -- 玩家当前阵容上已达成的羁绊数量
-- local m_solderMax = 0 -- 玩家当前阵容上可达成的羁绊总量

local function getHeroesLevel( ... )
	logger:debug("getHeroesLevel")

	local tbSquad = {}
	table.hcopy(m_tbSquad, tbSquad) -- 2015-01-30, 直接修改m_tbSquad会修改DataCache的缓存，所以硬拷贝一份

	tbSquad["5"] = nil -- 当前阵容最大可上阵数改为5，key从"0"开始，所以要删除["5"]
	m_openSquad = FormationUtil.getFormationOpenedNum() -- 阵容已开启数

	
	m_openBench = 0
	for k, hid in pairs(m_tbBench) do
		local nHid = tonumber(hid)
		local idx = tonumber(k)

		if ( nHid ~= -1) then
			m_openBench = m_openBench + 1 -- 替补已开启数
			tbSquad[(k + m_SQUAD_MAX) .. ""] = hid -- 2015-01-29, 在当前阵容基础上加入替补信息，5是当前阵容最大可上阵数
			if (nHid == 0 and (idx < m_emptyBench) ) then
				m_emptyBench = idx
			end
		end
	end

	m_heroSquad, m_heroBench = 0, 0
	for k, hid in pairs(tbSquad) do
		local heroInfo = HeroModel.getHeroByHid(hid)
		
		if (heroInfo) then
			if (tonumber(k) < 5) then
				m_heroSquad = m_heroSquad + 1 -- 统计阵上伙伴数
			else
				m_heroBench = m_heroBench + 1 -- 统计替补伙伴数
			end
			local dbHero = DB_Heroes.getDataById(heroInfo.htid)
			m_heroLv = m_heroLv + tonumber(heroInfo.level)
			m_heroLvMaxLv = m_heroLvMaxLv + m_usrLv
			m_transLv = m_transLv + heroInfo.evolve_level
			if (dbHero.advanced_id) then
				m_transLvMax = m_transLvMax + HeroUtil.getHeroTransferLimitByHid(hid)
			end

			m_equipNum = m_equipNum + HeroUtil.getWearedEquipNumByHid(hid)
			m_equipStrenthLv = m_equipStrenthLv + HeroUtil.getWeardEquipStrenthLevelByHid(hid)
			m_equipMagicLv = m_equipMagicLv + HeroUtil.getWeardEquipMagicLevelByHid(hid)
			m_equipMagicMaxLv = m_equipMagicMaxLv + HeroUtil.getWeardEquipMagicMaxByHid(hid)

			m_treasNum = m_treasNum + HeroUtil.getWearedTreasNumByHid(hid)
			m_treasStrenthLv = m_treasStrenthLv + HeroUtil.getWearedTreasStrenthLevelByHid(hid)
			m_treasStrenthMaxLv = m_treasStrenthMaxLv + HeroUtil.getWearedTreasStrenthMaxByHid(hid)
			m_treasEvolveLv = m_treasEvolveLv + HeroUtil.getWearedTreasEvolveLevelByHid(hid)
			m_treasEvolveMaxLv = m_treasEvolveMaxLv + HeroUtil.getWearedTreasEvolveMaxByHid(hid)

			logger:debug("hid = %d, m_heroSquad = %d, m_heroLv = %d, m_heroLvMaxLv = %d, m_transLv = %d, m_transLvMax = %d",
					hid, m_heroSquad, m_heroLv, m_heroLvMaxLv, m_transLv, m_transLvMax or -1)

			logger:debug("hid = %d, m_equipNum = %d, m_equipStrenthLv = %d, m_equipMagicLv = %d, m_equipMagicMaxLv = %d",
					hid, m_equipNum, m_equipStrenthLv, m_equipMagicLv, m_equipMagicMaxLv or -1)

			logger:debug("hid = %d, m_treasNum = %d, m_treasStrenthLv = %d, m_treasStrenthMaxLv = %d, m_treasEvolveLv = %d, m_treasEvolveMaxLv = %d",
					hid, m_treasNum, m_treasStrenthLv, m_treasStrenthMaxLv, m_treasEvolveLv, m_treasEvolveMaxLv)
		end
	end	
end
getHeroesLevel() -- 先计算 玩家当前阵容上所有伙伴的强化等级和/玩家当前阵容上所有伙伴的强化等级上限和

-- m_solderMax, m_solderNum = FormationUtil.fnGetUnionActiveNum()

m_tbGenData[1].cur = function ( ... )
	return m_heroLv
end	
m_tbGenData[1].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchGeneralForge)) then
		return 0
	end
	return m_heroLvMaxLv
end
m_tbGenData[1].onClick = function ( ... )
	gotoPartnerBag()
end
-- 2	伙伴进阶	玩家当前阵容上所有伙伴的进阶等级和/玩家当前阵容上所有伙伴的进阶等级上限和
-- 例如：玩家上阵6个伙伴，每个伙伴进阶到3级，当前每个伙伴最大可进阶到6级，则提升度=(3*6)/(6*6)=50%	伙伴列表
m_tbGenData[2].cur = function ( ... )
	return m_transLv
end
m_tbGenData[2].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchGeneralTransform)) then
		return 0
	end
	return m_transLvMax
end
m_tbGenData[2].onClick = function ( ... )
	gotoPartnerBag()
end
-- 3	上阵伙伴	玩家当前上阵伙伴的数量/玩家当前已开始的伙伴位置
-- 例如：玩家当前上了5个伙伴，已开启6个伙伴位置，则提升度=5/6=83%
-- 1. 2.如果所有开启阵位都有伙伴，则点击前往打开阵容即可
m_tbGenData[3].cur = function ( ... )
	return m_heroSquad + m_heroBench
end
m_tbGenData[3].max =  function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchFormation)) then
		return 0
	end
	return m_openSquad + m_openBench
end
m_tbGenData[3].onClick = function ( ... )
	-- local heroNum, openNum = m_tbGenData[3].cur(), m_tbGenData[3].max()
	-- local pageNum = heroNum < openNum and heroNum or nil -- 如果当前有未上伙伴的位置，则前往当前阵容未上伙伴的那个阵位；否则打开阵容即可
	-- gotoFormation(pageNum)
	local pageNum = nil
	if (m_heroSquad < m_openSquad) then
		pageNum = m_heroSquad
	elseif (m_heroBench < m_openBench) then
		pageNum = m_emptyBench + m_SQUAD_MAX
	end
	gotoFormation(pageNum)
end
-- 4	上阵小伙伴	玩家当前上阵小伙伴的数量/玩家当前已开始的小伙伴位置
-- 例如：玩家当前上了一个小伙伴，已开启两个小伙伴位置，则提升度=1/2=50%	阵容中的小伙伴位置
m_tbGenData[4].cur = function ( ... )
	local num = 0
	logger:debug(m_tbExtra)
	for k, v in pairs(m_tbExtra) do
		local flag = tostring(v)
		if (flag ~= "0" and flag ~= "-1") then
			num = num + 1
		end
	end
	return num
end
m_tbGenData[4].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchLitFmt)) then
		return 0
	end

	local num = 0
	for k, v in pairs(m_tbExtra) do
		if (tostring(v) ~= "-1") then
			num = num + 1
		end
	end
	return num
end
m_tbGenData[4].onClick = function ( ... )
	gotoFormation(100)
end
-- 5	装备穿戴	玩家当前阵容上所有伙伴穿戴的所有装备数量/玩家当前阵容上所有伙伴可穿戴的装备位置
-- 例如：玩家当前阵容上所有伙伴共穿戴8件装备，上阵伙伴数量为6个，每个伙伴可穿戴装备位置都是4个，则提升度=8/（6*4）=33%	阵容
m_tbGenData[5].cur = function ( ... )
	return m_equipNum
end
m_tbGenData[5].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchWeaponForge)) then
		return 0
	end
	return (m_heroSquad + m_heroBench) * g_EquipCount
end
m_tbGenData[5].onClick = function ( ... )
	gotoFormation(0)
end
-- 6	装备强化	玩家当前穿戴的所有装备的强化等级和/玩家当前穿戴的所有装备的强化等级上限和
-- 例如：所有伙伴共穿戴8件装备，每件装备都强化到15级，当前装备强化上限为20级，则提升度=（8*15）/（8*20）=75%	装备列表
m_tbGenData[6].cur = function ( ... )
	return m_equipStrenthLv
end
m_tbGenData[6].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchWeaponForge)) then
		return 0
	end
	return m_equipNum * (m_usrLv * 2) -- 装备强化等级上限为: 玩家等级*2
end
m_tbGenData[6].onClick = function ( ... )
	gotoEquipBag()
end
-- 7	装备附魔	玩家当前穿戴的所有装备的附魔等级和/玩家当前穿戴的所有装备的附魔等级上限和
-- 例如：所有伙伴共穿戴8件装备，每件装备都附魔到15级，当前装备附魔上限为20级，则提升度=（8*15）/（8*20）=75%	装备列表
m_tbGenData[7].cur = function ( ... )
	return m_equipMagicLv
end
m_tbGenData[7].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchEquipFixed)) then
		return 0
	end
	return m_equipMagicMaxLv
end
m_tbGenData[7].onClick = function ( ... )
	gotoEquipBag()
end
-- 8	宝物穿戴	玩家当前穿戴的所有宝物数量/玩家当前阵容上的宝物位置
-- 例如：玩家当前共穿戴8件宝物，上阵伙伴数量为6个，则提升度=8/（6*4）=33%	阵容
m_tbGenData[8].cur = function ( ... )
	return m_treasNum
end
m_tbGenData[8].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchTreasure)) then
		return 0
	end
	return (m_heroSquad + m_heroBench) * g_TreasCount
end
m_tbGenData[8].onClick = function ( ... )
	gotoFormation(0)
end
-- 9	宝物强化	玩家当前穿戴的所有宝物的强化等级和/玩家当前穿戴的所有宝物的强化等级上限和
-- 例如：所有伙伴共穿戴8件宝物，每件宝物都强化到15级，当前宝物强化上限为20级，则提升度=（8*15）/（8*20）=75%	宝物列表
m_tbGenData[9].cur = function ( ... )
	return m_treasStrenthLv
end
m_tbGenData[9].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchTreasureForge)) then
		return 0 -- 如果宝物强化未开启则返回0
	end
	return m_treasStrenthMaxLv
end
m_tbGenData[9].onClick = function ( ... )
	gotoTreasBag()
end
-- 10	宝物精炼	玩家当前穿戴的所有宝物的精炼等级和/玩家当前穿戴的所有宝物的精炼等级上限和
-- 例如：所有伙伴共穿戴8件宝物，每件宝物都精炼到15级，当前宝物精炼上限为20级，则提升度=（8*15）/（8*20）=75%	宝物列表
m_tbGenData[10].cur = function ( ... )
	return m_treasEvolveLv
end
m_tbGenData[10].max = function ( ... )
	if(not SwitchModel.getSwitchOpenState(ksSwitchTreasureFixed)) then
		return 0 -- 如果宝物精炼未开启则返回0
	end
	return m_treasEvolveMaxLv
end
m_tbGenData[10].onClick = function ( ... )
	gotoTreasBag()
end
-- 11	羁绊搭配	玩家当前阵容上已达成的羁绊数量/玩家当前阵容上伙伴的羁绊数量和，TODO: 可能需要同时加上替补的羁绊
-- 例如：玩家上阵六个伙伴，每个伙伴有5个羁绊，当前共达成10个羁绊，则提升度=10/（5*6）=33%
-- m_tbGenData[11].cur = function ( ... )
-- 	return m_solderNum
-- end
-- m_tbGenData[11].max = function ( ... )
-- 	if(not SwitchModel.getSwitchOpenState(ksSwitchFormation)) then
-- 		return 0
-- 	end
-- 	return m_solderMax
-- end
-- m_tbGenData[11].onClick = function ( ... )
-- 	gotoFormation(101)
-- end