-- Filename：	ActivityConfig.lua
-- Author：		lichenyang
-- Date：		2011-1-8
-- Purpose：		活动配置

module("ActivityConfig" , package.seeall)


--[[
	@des:取数据（eg:消费累积）
	--读取消费累积的第一行
	ActivityConfig.ConfigCache.spend.data[1].des
	ActivityConfig.ConfigCache.spend.start_time			--开启时间
	ActivityConfig.ConfigCache.spend.end_time			--关闭时间
	ActivityConfig.ConfigCache.spend.need_open_time		--需要开启时间
--]]
ConfigCache 	= 	{}



keyConfig 		= 	{}
--消费累积
keyConfig.spend 			= {
	"id","des","expenseGold","reward"
}

--竞技场双倍奖励
keyConfig.arenaDoubleReward = {
	
}

--活动卡包
keyConfig.heroShop 			= {
	"id","icon","des","freeScore","goldScore","goldCost","freeCd","rewardId","freeTimeNum","tmp0","tavernId","showHeros","coseTime","first_reward_text","second_reward_text","third_reward_text","fourth_reward_text",
}

--活动卡包奖励
keyConfig.heroShopReward 	= {
	"id","tep0","scoreReward1","tmp1","scoreReward2","tmp2","scoreReward3","tmp3","scoreReward4","tmp4","scoreReward5","num","tmp5","rankingReward1","tmp6","tmp7","rankingReward2","tmp8","tmp9","rankingReward3","tmp10","tmp11","rankingReward4","tmp12","tmp13","rankingReward5","tmp14",
}

--挖宝活动配置
keyConfig.robTomb			= {
	"id","icon","des","showItems1","showItems2","showItems3","showItems4","showItems5","GoldCost","levelLimit","freeDropId","goldDropId","changeTimes","changeDropId","onceDrop"
}

-- 春节礼包活动配置
keyConfig.signActivity      = {
	"id", "des", "icon", "accumulateDay", "reward"
}

-- 充值回馈
keyConfig.topupFund			= {
	"id","des","expenseGold","reward"
}

function getDataByKey(key )
	return ActivityConfig.ConfigCache[tostring(key)]
end

