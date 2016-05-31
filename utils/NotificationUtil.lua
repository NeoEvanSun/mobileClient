--Filename:	NotificationUtil.lua
--Author:	chengliang
--Date:		2013/12/17
--Purpose:	通知的相关方法

module ("NotificationUtil", package.seeall)

require "script/utils/TimeUtil"

------------ 吃烧鸡 -----------------
local kChickenEnergy_key_noon 		= "chicken_energy_key_noon"			-- 中午吃鸡腿
local kChickenEnergy_key_evening 	= "chicken_energy_key_evening"		-- 晚上吃鸡腿

local chickenEnergy_body			= gi18n[3002] 	-- 通知文本

-- if(BTUtil:isAppStore() == true ) then
-- 	chickenEnergy_body = "主公，貂蝉为您备好了吮指原味鸡和黄金脆皮鸡，谁去谁留，由你决定！"
-- end


-- 中午吃鸡腿
function addChickenEnergyNotification_noon()
    -- zhangqi, 2015-01-20, 改为取相对于服务器时区的11:59:00
    local noonTimeInterval = TimeUtil.getSvrIntervalByTime(115900)
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>noonTimeInterval)then
	 	fireTimeInterval = noonTimeInterval + 3600 * 24
	else
		fireTimeInterval = noonTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kChickenEnergy_key_noon, chickenEnergy_body, fireTimeInterval, kCFCalendarUnitDay_BT)
end

-- 晚上吃鸡腿
function addChickenEnergyNotification_evening()
	-- zhangqi, 2015-01-20, 改为取相对于服务器时区的17:59:00
    local eveningTimeInterval = TimeUtil.getSvrIntervalByTime(175900) 	
	local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	local fireTimeInterval = 0
	if(curTimeInterval>eveningTimeInterval)then
	 	fireTimeInterval = eveningTimeInterval + 3600 * 24
	else
		fireTimeInterval = eveningTimeInterval
	end
	NotificationManager:addLocalNotificationBy(kChickenEnergy_key_evening, chickenEnergy_body, fireTimeInterval, kCFCalendarUnitDay_BT)
end


--------------------------- 体力回复满 -------------------------
local kEnergyRestoreFull_key = "key_energy_restore_full" 			-- 体力回复满
local energy_restore_full_body = "主公，您的体力已经恢复满了，快来继续征战天下吧！"

-- 体力恢复满通知
function addRestoreEnergyNotification()
	local rest_time = UserModel.getEnergyFullTime()
	if(rest_time <= 0)then
		-- 取消 通知
		NotificationManager:cancelLocalNotificationBy(kEnergyRestoreFull_key)
	else
		local fireTimeInterval = BTUtil:getSvrTimeInterval()+rest_time
		-- NotificationManager:addLocalNotificationBy(kEnergyRestoreFull_key, energy_restore_full_body, fireTimeInterval, 0)
	end
end


------------------------- 长时间未登录通知 --------------------
local kLongTimeNoSee_key = "key_long_time_no_see"
local body_longTimeNoSee = "主公，貂蝉看您许久未来心灰意冷正要骑上赤兔而去，快拦住她吧！"

-- 长时间未登录通知
function addLongTimeNoSeeNotification()
	local longTime = 3600*24*3
	local fireTimeInterval = BTUtil:getSvrTimeInterval()+longTime
	-- NotificationManager:addLocalNotificationBy(kLongTimeNoSee_key, body_longTimeNoSee, fireTimeInterval, kCFCalendarUnitDay_BT)
end


------------------------- 世界boss开始通知 ----------------------
local kWorldBossStart_key = "key_start_world_boss"
local body_worldBossStart = "传说，龙珠蛋碎一刻会爆声望，良心活动“进击的魔神”怪傻钱多，主公速来吧！"

-- 世界boss开始通知
-- function addWorldBossStartNotification()
	--2015.1.24  yangna  script/ui

	-- require "db/DB_Worldboss"
	-- require "script/ui/boss/BossData"
	-- local startTimeInterval = TimeUtil.getSvrIntervalByTime(DB_Worldboss.getDataById(1).dayBeginTime+BossData.getBossTimeOffset()) 	
	-- local curTimeInterval = TimeUtil.getSvrTimeByOffset()
	-- local fireTimeInterval = 0
	-- if(curTimeInterval>=startTimeInterval)then
	--  	fireTimeInterval = startTimeInterval + 3600 * 24
	-- else
	-- 	fireTimeInterval = startTimeInterval
	-- end
	-- NotificationManager:addLocalNotificationBy(kWorldBossStart_key, body_worldBossStart, fireTimeInterval, kCFCalendarUnitDay_BT)

-- end








