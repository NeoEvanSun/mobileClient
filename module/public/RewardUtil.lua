-- FileName: RewardUtil.lua
-- Author: huxiaozhou
-- Date: 2015-01-08
-- Purpose: 处理奖励  根据表配置得到展示物品的数据 奖励的17个类型 其中一部分已经弃用的没有实现
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--         		佛祖保佑  需求不变  
--		   		不怕出bug  最恨改需求
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-- /


module("RewardUtil", package.seeall)

local m_i18n = gi18n
local m_i18nString = gi18nString

-- 适用于显示奖励物品列表 1|0|1000
-- 分解表中物品字符串数据
local function parseGoodsStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodTab = string.split(goodsStr, ",")
    for k,v in pairs(goodTab) do
        local data = {}
        local tab = string.split(v, "|")
        if(not table.isEmpty(tab)) then
            data.type = tab[1]
            data.id   = tab[2]
            data.num  = tab[3]
            table.insert(goodsData,data)
        end
    end
    return goodsData
end

--根据表配置得到展示物品的数据 奖励的17个类型
-- rewardDataStr 表配置奖励 1|0|1000
function getItemsDataByStr( rewardDataStr )
	assert(rewardDataStr ~= nil, "奖励字符串不能为空")
    logger:debug("wm----getItemsDataByStr")
    logger:debug(rewardDataStr)
    local goodsData = parseGoodsStr(rewardDataStr)
    return getItemsDataByTb(goodsData)
end

function getItemsDataByTb( rewardDatasTB )
    logger:debug("wm----getItemsDataByTb")
    logger:debug(rewardDatasTB)
    local goodsData = rewardDatasTB or {}
    local itemData ={}
    for k,v in pairs(goodsData) do
        local tab = {}
        if( tonumber(v.type) == 1 ) then
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[1520]
        elseif(tonumber(v.type) == 2 ) then
            -- 将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[3202]
       elseif(tonumber(v.type) == 3 ) then
            -- 金币
            tab.type = "gold"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[2220]
        elseif(tonumber(v.type) == 4 ) then
            -- 体力(wu)
            tab.type = "execution"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[1304]
        elseif(tonumber(v.type) == 5 ) then
            -- 耐力(wu)
            tab.type = "stamina"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[1359]
        elseif(tonumber(v.type) == 7 ) then
            -- 多个物品(wu)
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= ItemUtil.getItemById(v.id).name
        elseif( tonumber(v.type) == 8 ) then -- 等级 * belly
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)*UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[1520]
        elseif(tonumber(v.type) == 11 ) then
            -- 魂玉
            tab.type = "jewel"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[2082]
        elseif(tonumber(v.type) == 12 ) then
            -- 声望
            tab.type = "prestige"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= m_i18n[1921]
        elseif(tonumber(v.type) == 14 ) then
            -- 宝物碎片
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= ItemUtil.getItemById(v.id).name
        elseif (tonumber(v.type) == 18) then
            -- 空岛币处理
            tab.type = "sky"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = m_i18n[5414]
        else
            logger:debug("此类型不存在  type = ",tonumber(v.type))
            error(string.format("根据协议 不存在此奖励类型: %s",v.type))
        end
        -- 存入数组
        if(table.isEmpty(tab) == false) then
        	table.insert(itemData,tab)
        end
    end
    return  itemData
end

--[[
	@desc: 获取解析后的奖励列表
    @param 	rewardDataStr  type: string 表配置奖励 1|0|1000
    @param 	bSave  type: bool true or false
    @return: tbRewardsData  type:table
—]]
function parseRewards( rewardDataStr , bSave)
    logger:debug("rewardDataStr = %s", rewardDataStr)
	local save = bSave or false
	local tbReward = getItemsDataByStr(rewardDataStr) or {}
    return parseRewardsByTb(tbReward , save)
end

function parseRewardsByTb( rewardDataTb , bSave)
    local save = bSave or false
    local tbReward = rewardDataTb or {}
	local tbRewardsData = {}
	for _,v in pairs(tbReward) do
		--金币图标
        if(v.type == "gold") then
            local goldInfo = {}
            goldInfo.name =  m_i18n[2220]-- "金币"
            local imgGold = ItemUtil.getGoldIconByNum(v.num)
            goldInfo.icon = imgGold
            goldInfo.quality = 5
            table.insert(tbRewardsData, goldInfo)
            
            if save == true then
            	UserModel.addGoldNumber(tonumber(v.num))
            end

        end
		--贝里图标
        if(v.type == "silver") then
            local silverInfo ={}
            local imgSilver = ItemUtil.getSiliverIconByNum(v.num)
            silverInfo.icon = imgSilver
            silverInfo.quality = 2
            silverInfo.name = m_i18n[1520] -- "贝里" 
            table.insert(tbRewardsData, silverInfo)

            if save == true then
            	UserModel.addSilverNumber(tonumber(v.num))
            end
        end
		--空岛币图标
    
        if (v.type == "sky") then
            local skyInfo ={}
            local imgSky = ItemUtil.getSkyBellyIconByNum(v.num)
            skyInfo.icon = imgSky
            skyInfo.quality = 4
            skyInfo.name = "空岛币" -- "贝里" 
            table.insert(tbRewardsData, skyInfo)

            if save == true then
                UserModel.addSkyPieaBellyNum(tonumber(v.num))
            end
        end
        -- 声望图标
        if(v.type == "prestige") then
        	local prestigeInfo ={}
            local imgPrestige = ItemUtil.getPrestigeIconByNum(v.num)
            prestigeInfo.icon = imgPrestige
            prestigeInfo.name = m_i18n[1921] --"声望"
            prestigeInfo.quality = 3
            table.insert(tbRewardsData, prestigeInfo)
            if save == true then
            	UserModel.addPrestigeNum(tonumber(v.num))
            end
        end
        -- 海魂
        if(v.type == "jewel") then
        	local jewelInfo ={}
          	local imgJewel = ItemUtil.getJewelIconByNum(v.num)
          	jewelInfo.icon = imgJewel
            jewelInfo.name = m_i18n[2082] --"魂玉"
            jewelInfo.quality = 5
            table.insert(tbRewardsData, jewelInfo)
            if save == true then
            	UserModel.addJewelNum(v.num)
            end
        end
        --物品
        if(v.type == "item" ) then
			local rewardItem = {}
			--查询物品信息	
			local itemTableInfo = ItemUtil.getItemById(tonumber(v.tid))
			local btnIcon = ItemUtil.createBtnByTemplateIdAndNumber(itemTableInfo.id,v.num,function ( sender,eventType )
											if (eventType == TOUCH_EVENT_ENDED) then
												PublicInfoCtrl.createItemInfoViewByTid(itemTableInfo.id,v.num)
											end
			end)

			rewardItem.icon = btnIcon
			rewardItem.name = itemTableInfo.name
			rewardItem.quality = itemTableInfo.quality
			table.insert(tbRewardsData,rewardItem)
		end


		 --奖励 体力
		if(v.type == "execution") then
			local executionInfo = {}
			local imgExecution = ItemUtil.getSmallPhyIconByNum(v.num)
          	executionInfo.icon = imgExecution
            executionInfo.name = m_i18n[1922] --"体力"
            table.insert(tbRewardsData, executionInfo)


			if(save == true) then -- 增加体力
				UserModel.addEnergyValue(tonumber(v.num))
			end

		end

		-- --  奖励耐力
		if(v.type == "stamina") then
			local staminaInfo = {}
			local imgStamina = ItemUtil.getStaminaIconByNum(v.num)
          	staminaInfo.icon = imgStamina
            staminaInfo.name = m_i18n[1923]--"耐力"
            table.insert(tbRewardsData, staminaInfo)
            if(save == true) then -- 增加耐力
				UserModel.addStaminaNumber(tonumber(v.num))
			end
		end
	end
	return tbRewardsData	
end
