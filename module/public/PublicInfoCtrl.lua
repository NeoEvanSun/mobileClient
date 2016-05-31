-- FileName: PublicInfoCtrl.lua
-- Author: huxiaozhou
-- Date: 2014-05-21
-- Purpose: function description of module
--[[TODO List]]
-- 显示商店，兑换中心中 各种物品信息面板 比如说装备信息面板，

module("PublicInfoCtrl", package.seeall)

require "script/module/public/UIHelper"
require "script/module/public/ItemUtil"

-- 模块局部变量 --
local m_tid 


local function init(...)
	m_tid = nil
end

function destroy(...)
	package.loaded["PublicInfoCtrl"] = nil
end

function moduleName()
    return "PublicInfoCtrl"
end

function create( )

end

function createItemInfoViewByTid( _tid, num)
	AudioHelper.playInfoEffect()

	m_tid = _tid
	local tbItemInfo = ItemUtil.getItemById(m_tid) -- 通过ID获取某个物品的属性所有信息 
	if (tbItemInfo ~= nil) then
		if (tbItemInfo.isDirect == true) then	 	-- 直接使用类
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isGift == true) then		-- 礼包类物品：
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isRandGift == true) then -- 随机礼包类：
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isFeed == true) then 	-- 坐骑饲料类：50001~80000
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isNormal == true) then   -- 普通物品：
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isBook == true) then     -- 武将技能书：

		elseif (tbItemInfo.isStarGift == true) then 	-- 好感礼物类：100001~120000
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo,num))
		elseif (tbItemInfo.isHeroFragment == true) then -- 伙伴碎片
			require "script/module/partner/PartnerInformation"

			-- modified by yucong
			--local tArgs={selectedHeroes=tbItemInfo}
			local tArgs = {}
			table.hcopy({selectedHeroes=tbItemInfo}, tArgs)
			logger:debug(tbItemInfo)  
        	--LayerManager.addLayoutNoScale(PartnerInformation.create(tArgs,4)) --所选择武将信息
        	local layer = PartnerInformation.create(tArgs,4)     --所选择武将信息
	        if (layer) then
	          LayerManager.addLayoutNoScale(layer)
	          PartnerInformation.initScvHeight()
	          -- 如果当前模块是MainShip, 需要隐藏主页的跑马灯，显示黑色背景的跑马灯
	        end 
		elseif (tbItemInfo.isTreasureFragment == true) then -- 宝物碎片
			require "script/module/treasure/treaInfoCtrl"
			LayerManager.addLayoutNoScale(treaInfoCtrl.create(tbItemInfo.treasureId,treaInfoModel.ccs.layFromOtherType))
		elseif (tbItemInfo.isTreasure == true) then -- 宝物类：
			require "script/module/treasure/treaInfoCtrl"
			LayerManager.addLayoutNoScale(treaInfoCtrl.create(_tid,treaInfoModel.ccs.layFromOtherType))
		elseif (tbItemInfo.isConch == true) then  -- 空岛贝
			require "script/module/conch/ConchStrength/SkyPieaInfoCtrl"
			LayerManager.addLayout(SkyPieaInfoCtrl.createForConchItemInfo(tbItemInfo))
		elseif (tbItemInfo.isDress == true) then 	-- 时装
			LayerManager.addLayout(UIHelper.createItemInfoDlg(tbItemInfo))
		elseif (tbItemInfo.isFragment == true) then	-- 物品碎片类：
			require "script/module/equipment/EquipInfoCtrl"
			EquipInfoCtrl.createForShopFragEquip(tbItemInfo)
		elseif (tbItemInfo.isArm == true) then  	-- 装备类：
			require "script/module/equipment/EquipInfoCtrl"
			EquipInfoCtrl.createForShopEquip(tbItemInfo)
		end
	end
end

function createHeroInfoView(_htid)
	require "script/model/utils/HeroUtil"
	require "script/module/partner/PartnerInformation"
	
	local heroInfo =HeroUtil.getHeroLocalInfoByHtid(_htid)
	local tArgs={selectedHeroes=heroInfo}
        local layer = PartnerInformation.create(tArgs,6)     --所选择武将信息
        if (layer) then
            LayerManager.addLayoutNoScale(layer)
            PartnerInformation.initScvHeight()
        end
end


