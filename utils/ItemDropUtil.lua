-- Filename：	ItemDropUtil.lua
-- Author：		zhz
-- Date：		2013-9-25
-- Purpose：		物品掉落的处理信息和现实页面

module("ItemDropUtil" , package.seeall)
require "script/model/user/UserModel"
require "db/DB_Heroes"

local m_i18n = gi18n

-- 将后端传的 drop 表进行处理
--[[ 
'drop':array                                掉落信息
         {
             'item':array                            物品
             {
                 {
                     itemTemplateId => itemNum        物品模板id和数量
                 }
                 {
                     itemTemplateId => itemNum        物品模板id和数量
                 }
             }
             'treasFrag':array                        宝物碎片
             {
                 {
                     itemTemplateId => itemNum        物品模板id和数量
                 }
            }
             'silver':array                            银币数量
             {
                 index => $num
             }
             'soul':array                            将魂数量
             {
                 index => $num
             }
         }

         items= {
		item = {
			type = "", 
			name=,
			tid=,
			num=,
			}
			....
			


		}
         }
]]
-- 返回一个 可以直接使用 itemTableView 的表
require "db/DB_Heroes"
require "db/DB_Item_hero_fragment"
function getDropItem( drop )
	local items = {}
	logger:debug(" the drop is ;   ===== ")
	logger:debug(drop)
	-- drop 掉落表
	if ( not table.isEmpty(drop.silver)) then
		for k,v in  pairs(drop.silver) do
			local item = {}


			local item = {}
			item.type = "silver"
			item.num = v
			item.name = m_i18n[1520]
			item.quality = 2 -- 贝里默认2级，便于确定名称的颜色
			item.icon = ItemUtil.getSiliverIconByNum(v)
			table.insert(items, item)

		end
	end

	-- if ( drop.silver) then
	-- 	local item = {}
	-- 	item.type = "silver"
	-- 	item.num = drop.silver
	-- 	item.name = m_i18n[1520]
	-- 	item.quality = 4 -- 贝里默认4级，便于确定名称的颜色
	-- 	item.icon = ItemUtil.getSiliverIconByNum(drop.silver)
	-- 	table.insert(items, item)
	-- end
	if (drop.gold ) then
		local item = {}
		item.type = "gold"
		item.num = drop.gold
		item.name = m_i18n[2220]  -- "金币"
		item.quality = 5

		item.icon = ItemUtil.getGoldIconByNum(drop.gold)
		table.insert(items,item)
	end
	logger:debug(drop.item)
	if ( not table.isEmpty(drop.item)) then
		for k,v in pairs (drop.item) do
			if (type(v) == "table") then
				for k1,v1 in pairs(v) do
					local item = {}
					item.tid  = k1
					item.num = tonumber(v1)
					item.type = "item"
			 		local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
					item.name = itemInfo.name
					item.quality = itemInfo.quality
					item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
									function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
										if (eventType == TOUCH_EVENT_ENDED) then
											PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
										end
									end) 

					table.insert(items, item)
				end
			else
				local item = {}
				item.tid = k
				item.num = v
				item.type = "item"
				local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
				item.name = itemInfo.name
				item.quality = itemInfo.quality

				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
									end
								end) 
				table.insert(items,item)
			end
		end
	end
	if ( not table.isEmpty(drop.hero)) then
		for k ,v in pairs(drop.hero) do
			local item ={}
			item.tid = k
			item.num = v
			item.type = "hero"
			local hero = DB_Heroes.getDataById(item.tid)
			item.name =  hero.name
			item.quality = hero.quality

						item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,v,
							function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
								if (eventType == TOUCH_EVENT_ENDED) then
									PublicInfoCtrl.createItemInfoViewByTid(k, v)
								end
							end) 
			table.insert(items,item)
		end
	end
	if (not table.isEmpty(drop.treasFrag)) then -- 宝物碎片
		for k,v in pairs(drop.treasFrag) do
			if (type(v)=="table") then
				for k1,v1 in pairs(v) do

					local item = {}
					item.tid = k1
					item.num = v1
					item.type = "item"
					local treas = ItemUtil.getItemById(tonumber(item.tid))
					item.name = treas.name
					item.quality = treas.quality

					item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
									function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
										if (eventType == TOUCH_EVENT_ENDED) then
											PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
										end
									end) 
					table.insert(items,item)
				end
			else
				local item = {}
				item.tid = k
				item.num = v
				item.type = "item"
				local treas = ItemUtil.getItemById(tonumber(item.tid))
				item.name = treas.name
				item.quality = treas.quality

				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
									end
								end) 
				table.insert(items,item)
			end
		end
	end
	return items
end

--liweidong 天降宝物掉落物品解析
function getDropTreasureItem( drop )
	local items = {}
	logger:debug(" the drop is ;   ===== ")
	logger:debug(drop)
	
	if ( drop.silver) then
		local item = {}
		item.type = "silver"
		item.num = drop.silver
		item.name = m_i18n[1520]
		item.quality = 4 -- 贝里默认4级，便于确定名称的颜色
		item.icon = ItemUtil.getSiliverIconByNum(drop.silver)
		table.insert(items, item)
	end
	if (drop.gold ) then
		local item = {}
		item.type = "gold"
		item.num = drop.gold
		item.name = m_i18n[2220]  -- "金币"
		item.quality = 5

		item.icon = ItemUtil.getGoldIconByNum(drop.gold)
		table.insert(items,item)
	end
	logger:debug(drop.item)
	if ( not table.isEmpty(drop.item)) then
		logger:debug("item drop list=========")
		for k,v in  pairs (drop.item) do
			logger:debug("item drop list=========1111111")
			local item = {}
			item.tid  = k
			item.num = tonumber(v)
			item.type = "item"
	 		local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
			item.name = itemInfo.name
			item.quality = itemInfo.quality
			item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
							function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
								if (eventType == TOUCH_EVENT_ENDED) then
									PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
								end
							end) 

			table.insert(items, item)
		end
	end
	if ( not table.isEmpty(drop.hero)) then
		for k ,v in pairs(drop.hero) do
			local item ={}
			item.tid = k
			item.num = v
			item.type = "hero"
			local hero = DB_Heroes.getDataById(item.tid)
			item.name =  hero.name
			item.quality = hero.quality

						item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,v,
							function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
								if (eventType == TOUCH_EVENT_ENDED) then
									PublicInfoCtrl.createItemInfoViewByTid(k, v)
								end
							end) 
			table.insert(items,item)
		end
	end
	if (not table.isEmpty(drop.treasFrag)) then -- 宝物碎片
		for k,v in pairs(drop.treasFrag) do
			local item = {}
			item.tid = k
			item.num = v
			item.type = "item"
			local treas = ItemUtil.getItemById(tonumber(item.tid))
			item.name = treas.name
			item.quality = treas.quality

			item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
							function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
								if (eventType == TOUCH_EVENT_ENDED) then
									PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
								end
							end) 
			table.insert(items,item)
		end
	end
	return items
end
--modife zhangjunwu 2014-9-2   返回一个 可以直接使用 itemTableView 的表(仅限于开箱子)
function getBuyBoxDropItem( drop )
	local items = {}
	logger:debug(" the drop is ;   ===== ")
	logger:debug(drop)
	-- drop 掉落表
	if ( not table.isEmpty(drop.silver)) then
		for k,v in  pairs(drop.silver) do
			local item = {}


			local item = {}
			item.type = "silver"
			item.num = v
			item.name = m_i18n[1520]
			item.quality = 4 -- 贝里默认4级，便于确定名称的颜色
			item.icon = ItemUtil.getSiliverIconByNum(v)
			table.insert(items, item)

		end
	end

	if (drop.gold ) then

		for i=1,drop.gold do
			local item = {}
			item.type = "gold"
			item.num = drop.gold
			item.name = m_i18n[2220]  -- "金币"
			item.quality = 5

			item.icon = ItemUtil.getGoldIconByNum(drop.gold)
			table.insert(items,item)
		end

	end
	if ( not table.isEmpty(drop.item)) then
		for k,v in  pairs(drop.item) do
			for i=1,tonumber(v) do
				local item = {}
				item.tid  = k
				item.num = 1
				item.type = "item"
		 		local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
				item.name = itemInfo.name
				item.quality = itemInfo.quality
				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,1,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(k, 1)
									end
								end) 

				table.insert(items, item)
			end
		end
	end
	if ( not table.isEmpty(drop.hero)) then
		for k ,v in pairs(drop.hero) do
			for i=1,tonumber(v) do
				local item ={}
				item.tid = k
				item.num = 1
				item.type = "hero"
				local hero = DB_Heroes.getDataById(item.tid)
				item.name =  hero.name
				item.quality = hero.quality

							item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,1,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(k, 1)
									end
								end) 
				table.insert(items,item)
			end
		end
	end
	if (not table.isEmpty(drop.treasFrag)) then -- 宝物碎片
		for k,v in pairs(drop.treasFrag) do
			for i=1,tonumber(v) do
				local item = {}
				item.tid = k
				item.num = 1
				item.type = "item"
				local treas = ItemUtil.getItemById(tonumber(item.tid))
				item.name = treas.name
				item.quality = treas.quality

				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,1,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(k, 1)
									end
								end) 
				table.insert(items,item)
			end

		end
	end
	return items
end




-- 处理奇遇事件 神秘宝箱，奇遇宝箱返回奖励
 -- {
 --         'silver':int
 --         'jewel':int
 --         'prestige':int
 --         'gold':int
 --         'execution':int
 --         'stamina':int
 --         'exp':int
 --         'hero':array
 --         {
 --             $hid => $htid
 --         }
 --         'heroFrag':array
 --         {
 --             $itemTplId => $itemnum
 --         }
 --         'item':array
 --         {
 --             $itemTplId => $itemNum
 --         }
 --         'treasureFrag':array
 --         {
 --             $itemTplId => $itemNum
 --         }
 -- }

 --[[
	@desc: yangna 用于奇遇事件返回奖励解析
    @param 	drop掉落数据
    @param 	save  type: bool true or false 
    @return: items  type:table
—]]
function getAdvDropItem( drop ,save)
	local items = {}
	logger:debug(" the drop is ;   ===== ")
	logger:debug(drop)
	-- drop 掉落表
	if ( drop.silver) then
		local item = {}
		item.type = "silver"
		item.num = drop.silver
		item.name = m_i18n[1520]
		item.quality = 4 -- 贝里默认4级，便于确定名称的颜色
		item.icon = ItemUtil.getSiliverIconByNum(drop.silver)
		table.insert(items, item)

	    if save == true then
	    	UserModel.addSilverNumber(tonumber(drop.silver))
	    end
	end

	-- 海魂
	if (drop.jewel) then 
	    local item ={}
	    item.type = "jewel"
      	item.num = drop.jewel
      	item.icon = ItemUtil.getJewelIconByNum(drop.jewel)
        item.name = m_i18n[2082] --"魂玉"
        item.quality = 5
        table.insert(tbRewardsData, item)

        if save == true then
	    	UserModel.addJewelNum(drop.jewel)
	    end
	end 

	-- 声望
	if (drop.prestige) then 
		local item = {}
        item.type = "prestige"
        item.num  = drop.prestige
        item.quality = 3
        item.name= m_i18n[2210]
        item.icon = ItemUtil.getPrestigeIconByNum(drop.prestige)
        table.insert(tbRewardsData, item)

        if save == true then
        	UserModel.addPrestigeNum(tonumber(drop.prestige))
        end
	end 

	if (drop.gold ) then
		local item = {}
		item.type = "gold"
		item.num = drop.gold
		item.name = m_i18n[2220]  -- "金币"
		item.quality = 5
		item.icon = ItemUtil.getGoldIconByNum(drop.gold)
		table.insert(items,item)

        if save == true then
        	UserModel.addGoldNumber(tonumber(drop.gold))
        end
	end

	-- 体力
	if (drop.execution) then 
		local item = {}
		item.num = drop.execution
		item.type = "execution"
		item.quality = 5
      	item.icon =  ItemUtil.getSmallPhyIconByNum(drop.execution)
        item.name = m_i18n[1922] --"体力"
        table.insert(tbRewardsData, item)

    	if(save == true) then -- 增加体力
			UserModel.addEnergyValue(tonumber(drop.execution))
		end
	end 
	-- 耐力
	if (drop.stamina) then 
		local item = {}
		item.num = drop.stamina
		item.type = "stamina"
		item.quality = 5
      	item.icon = ItemUtil.getStaminaIconByNum(drop.stamina)
        item.name = m_i18n[1923]--"耐力"
        table.insert(tbRewardsData, item)

        if(save == true) then -- 增加耐力
			UserModel.addStaminaNumber(tonumber(drop.stamina))
		end
	end 

	if (drop.exp) then 
		local item = {}
		item.num = drop.exp
		item.type = "exp"
		item.quality = 5
      	item.icon = ItemUtil.getExpIconByNum(drop.exp)
        item.name = m_i18n[1975]--"经验"
        table.insert(tbRewardsData, item)
	end 


	if ( not table.isEmpty(drop.hero)) then
		for k ,v in pairs(drop.hero) do
			local item ={}
			item.tid = k
			item.num = v
			item.type = "hero"
			local hero = DB_Heroes.getDataById(item.tid)
			item.name =  hero.name
			item.quality = hero.quality

						item.icon = ItemUtil.createBtnByTemplateIdAndNumber(k,v,
							function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
								if (eventType == TOUCH_EVENT_ENDED) then
									PublicInfoCtrl.createItemInfoViewByTid(k, v)
								end
							end) 
			table.insert(items,item)
		end
	end

	if (not table.isEmpty(drop.heroFrag)) then 
	end 
	

	if ( not table.isEmpty(drop.item)) then
		for k,v in pairs (drop.item) do
			if (type(v) == "table") then
				for k1,v1 in pairs(v) do
					local item = {}
					item.tid  = k1
					item.num = tonumber(v1)
					item.type = "item"
			 		local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
					item.name = itemInfo.name
					item.quality = itemInfo.quality
					item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
									function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
										if (eventType == TOUCH_EVENT_ENDED) then
											PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
										end
									end) 

					table.insert(items, item)
				end
			else
				local item = {}
				item.tid = k
				item.num = v
				item.type = "item"
				local itemInfo = ItemUtil.getItemById(tonumber(item.tid))
				item.name = itemInfo.name
				item.quality = itemInfo.quality

				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
									end
								end) 
				table.insert(items,item)
			end
		end
	end

	if (not table.isEmpty(drop.treasureFrag)) then -- 宝物碎片
		for k,v in pairs(drop.treasureFrag) do
			if (type(v)=="table") then
				for k1,v1 in pairs(v) do

					local item = {}
					item.tid = k1
					item.num = v1
					item.type = "item"
					local treas = ItemUtil.getItemById(tonumber(item.tid))
					item.name = treas.name
					item.quality = treas.quality

					item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
									function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
										if (eventType == TOUCH_EVENT_ENDED) then
											PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
										end
									end) 
					table.insert(items,item)
				end
			else
				local item = {}
				item.tid = k
				item.num = v
				item.type = "item"
				local treas = ItemUtil.getItemById(tonumber(item.tid))
				item.name = treas.name
				item.quality = treas.quality

				item.icon = ItemUtil.createBtnByTemplateIdAndNumber(item.tid,item.num,
								function ( sender, eventType )  -- 道具图标按钮事件，弹出道具信息框
									if (eventType == TOUCH_EVENT_ENDED) then
										PublicInfoCtrl.createItemInfoViewByTid(item.tid,item.num)
									end
								end) 
				table.insert(items,item)
			end
		end
	end
	return items
end

-- zhangqi, 2014-08-14, 从UseItemLayer.lua 中复制而来稍加修改
-- 用于开宝箱直接得到贝里，金币，经验石，经验后更新本地缓存, 以致刷新角色信息UI
function refreshUserInfo( items, exp)
	for i, item in ipairs(items) do
		if(item.type == "silver" ) then
			UserModel.addSilverNumber(item.num)
		-- elseif(item.type == "soul") then -- zhangqi, 2015-01-10, 去经验石
		-- 	UserModel.addSoulNum(item.num)
		elseif(item.type == "gold") then
			UserModel.addGoldNumber(item.num)
		end
	end
	if (exp and tonumber(exp) > 0) then
		UserModel.addExpValue(tonumber(exp),"useitem")
	end
end


local _ksTipTag = 101

function getTipSpriteByNum( num  )

	_tipSprite= CCSprite:create("images/common/tip_2.png")
	local numLabel = CCLabelTTF:create( tostring(num) , g_sFontName, 20)
	numLabel:setPosition(ccp(_tipSprite:getContentSize().width/2,_tipSprite:getContentSize().height/2))
	numLabel:setAnchorPoint(ccp(0.5,0.5))
	_tipSprite:addChild(numLabel,1,_ksTipTag)

	return _tipSprite
end

function refreshNum( sprite ,num )
	if( tonumber(num) <=0 ) then
		sprite:setVisible(false)
	else 	
		local numLabel= tolua.cast(sprite:getChildByTag(_ksTipTag), "CCLabelTTF") 
		numLabel:setString("" .. num)
	end
end



