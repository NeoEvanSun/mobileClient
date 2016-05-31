-- FileName: GlobalScheduler.lua
-- Author: zhangqi
-- Date: 2015-01-24
-- Purpose: 
-- 		唯一的全局定时调度器，调度间隔 1 秒；
--		允许其他模块根据一个name注册回调方法，如果name已存在则不能重复注册；
--		所有注册的回调方法默认按注册的先后顺序执行，也可以根据name注销这些方法
--[[TODO List]]

module("GlobalScheduler", package.seeall)


-- 模块局部变量 --
local m_scheduler = CCDirector:sharedDirector():getScheduler()
local m_fnUnScheduler = nil -- 停止全局定时器的方法
local m_tbCallbacks = {} -- 保存注册的回调方法

local m_bossBegin = 0 -- boss的即将开启时间戳
local m_bossEnd = 0 -- boss的结束时间戳
-- local mWorldBossModel = WorldBossModel


--- 检测 竞技场 是否到发奖时间
local function checkArenaSendReward( ... )
	if (SwitchModel.getSwitchOpenState(ksSwitchArena,false)) then
		if (TimeUtil.getIntervalByTime(220000) == TimeUtil.getSvrTimeByOffset()) then --BTUtil:getSvrTimeInterval()) then
			-- 到期拉去竞技场奖励
			local time = math.random(1,5*60) -- 5分钟内随机一个时间点
			logger:debug("time == " .. time)

			-- local arenaScheduleId = nil
			local fnUnSchedule = nil
			local function updateArena ( )
				logger:debug("timeDown == " .. time)
				if (time<=0) then
					RequestCenter.arena_sendRankReward()
					fnUnSchedule()
				end
				time = time - 1
			end
			fnUnSchedule = scheduleFunc(updateArena)
		end
	end
end

--到00:00:00副本中据点的攻打次数需要重置，连战cd需要重置240000
local function resetCopyAttackCount ( ... )
	if (curServerTime == TimeUtil.getSvrIntervalByTime(240000)) then
		-- 普通副本
		local function preGetNormalCopyCallback( cbFlag, dictData, bRet )
			if(bRet)then
				logger:debug("preGetNormalCopyCallback")
				DataCache.setNormalCopyData( dictData.ret )
				require "script/module/copy/battleMonster"
				battleMonster.resetNightConfig()
			end
		end
		RequestCenter.getLastNormalCopyList(preGetNormalCopyCallback)
	end
end
--到0点重置用户所有基本数据和UI显示 liweidong
local function resetCommonUserData()
	if (UserModel.createTimeMarkBySvrTime()==UserModel.getCurDataTimeMark()) then --数据标识一样，不需要重置数据
		return
	end
	--重新设置数据日期标识
	UserModel.setCurDataTimeMark()

	--每一个模块留一个方法供调用，方法实现数据重置和相应UI刷新
	--重置活动副本数据和ui显示
	require "script/module/copyActivity/MainCopyModel"
	MainCopyModel.resetAcopyData()
	--重置副本
	require "script/module/copy/MainCopy"
	MainCopy.resetCopyData()
	
	require "script/module/registration/MainRegistrationCtrl"
	MainRegistrationCtrl.resetView()
	require "script/module/achieve/MainAchieveCtrl"
	MainAchieveCtrl.resetView()	
	--占卜屋重置数据
	require "script/module/astrology/MainAstrologyModel"
	MainAstrologyModel.resetView()	
	--开服礼包重置数据
	require "script/module/accSignReward/MainAccSignView"
	MainAccSignView.fnFreshListView()

	-- 我的好友数据重置
	require "script/module/friends/MainFdsCtrl"
	MainFdsCtrl.refreashView()
end

function init(...)
	addCallback("checkArenaSendReward", checkArenaSendReward)
	addCallback("resetCopyAttackCount", resetCopyAttackCount)
	
	addCallback("resetCommonUserData", resetCommonUserData) --liweidong 12点重置所有数据
end

-- 开始调度
function schedule(...)
	if (m_fnUnScheduler) then
		return
	end

	init()

	m_fnUnScheduler = scheduleFunc(function ( ... )		
		for name, func in pairs(m_tbCallbacks) do
			if (type(func) == "function") then
				-- logger:debug("GlobalScheduler:do:%s", name)
				func()
			end
		end
	end)
end

-- 注册一个全局调度回调
-- sName, 字符串, 回调名字; fnCallback, 回调方法;
function addCallback( sName, fnCallback )
	if (m_tbCallbacks[sName]) then
		logger:debug("GlobalScheduler-addCallback: %s is exist", sName)
		return
	end
	m_tbCallbacks[sName] = fnCallback
	logger:debug("GlobalScheduler-addCallback: sName = %s", sName)
end

-- 注销一个全局调度回调
-- sName, 字符串, 回调名字;
function removeCallback( sName )
	m_tbCallbacks[sName] = nil
end

-- 启动一个定时调度器，
-- 参数：fnFunc, 回调方法；nInterval，调度间隔，默认1秒; 
--		bPaused, 为true则不会立即执行，直到调用了resume相关方法，默认为false, 立即开始计时
-- return: 注销改调度器的方法
function scheduleFunc( fnFunc, nInterval, bPaused )
	local schedulId = m_scheduler:scheduleScriptFunc(fnFunc, nInterval or 1, bPaused or false)
	logger:debug("scheduleFunc-id = %d", schedulId)
	return function ( ... )
		if (schedulId ~= 0) then
			logger:debug("scheduleFunc stop schedule, id = %d", schedulId)
			m_scheduler:unscheduleScriptEntry(schedulId)
		end
	end
end


function destroy(...)
	logger:debug("GlobalScheduler-destroy")
	if (m_fnUnScheduler) then
		m_fnUnScheduler()
		logger:debug("GlobalScheduler-unscheduled")
		m_fnUnScheduler = nil
	end

	m_tbCallbacks = nil

	package.loaded["GlobalScheduler"] = nil
	package.loaded["script/module/public/GlobalScheduler"] = nil
end

function moduleName()
    return "GlobalScheduler"
end
