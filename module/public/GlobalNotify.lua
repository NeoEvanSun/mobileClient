-- FileName: GlobalNotify.lua
-- Author: zhangqi
-- Date: 2014-05-18
-- Purpose: 参考何超在英灵项目里的实现，创建一个全局的通知中心, 类似 cocos2d-x 的 CCNotificationCenter
--          提供注册、删除， 触发通知的方法
--[[ChangList List
2014-09-07, 增加一个事件可以注册多个监听者的处理
]]

module("GlobalNotify", package.seeall)

-- 模块全局变量，供外部访问 --
LEVEL_UP = "LEVEL_UP" -- 玩家升级

BEGIN_BATTLE = "BEGIN_BATTLE" --开始战斗
END_BATTLE = "END_BATTLE" -- 战斗结束

BEGIN_EXPLORE = "BEGIN_EXPLORE" -- 开始探索
END_EXPLORE = "END_EXPLORE"  -- 结束探索

RECONN_OK = "RECONN_OK" -- 原地重连成功
RECONN_FAILED = "RECONN_FAILED" -- 连接失败

NETWORK_FAILED = "NETWORK_FAILED" -- 与游戏服断开连接


-- CCNotificationCenter 相关
m_ccNc = CCNotificationCenter:sharedNotificationCenter()
NC_BACKGROUND = "applicationDidEnterBackground" -- 游戏被切到后台的事件通知注册名称
NC_FOREGROUND = "applicationWillEnterForeground" -- 游戏被切到前台的事件通知注册名称
m_NcObserver = {} -- 由于注册的回调中要被外部访问，所以不能定义为local


-- 模块局部变量 --
local m_tbNotifyList
local m_tbKept

local tbEventType = { LEVEL_UP, BEGIN_BATTLE, END_BATTLE, RECONN_OK, RECONN_FAILED, NETWORK_FAILED,}

function init(...)
	m_tbNotifyList = {}
	for _, eventName in ipairs(tbEventType) do
		m_tbNotifyList[eventName] = {}
	end

	m_tbKept = {}

	m_NcObserver[NC_BACKGROUND] = {}
	m_NcObserver[NC_FOREGROUND] = {}
end

function destroy(...)
	m_NcObserver = nil
	m_tbNotifyList = nil
	m_tbKept = nil
	package.loaded["GlobalNotify"] = nil
end

function moduleName()
	return "GlobalNotify"
end

--注册一个通知
--[[desc: zhangqi, 20140518, 添加一个全局的通知回调
    sObsvName: 通知名称
    fnCallback: 回调的函数
    bOnce: 是否只通知 1次, 如果为nil始终保留；true, 被调用一次后从通知列表中删除
    return: 是否有返回值，返回值说明
—]]
function addObserver(sEventName, fnCallback, bOnce, sObsvName )
	logger:debug("addObserver: %s - %s", sEventName, sObsvName)
	-- assert(m_tbNotifyList[sEventName], "eventName not exist")
	assert(type(fnCallback) == "function", "observer callback must a function")

	if (not m_tbNotifyList[sEventName]) then
		m_tbNotifyList[sEventName] = {}
	end

	local obsvrName = sObsvName or (sEventName .. table.count(m_tbNotifyList[sEventName]))
	m_tbNotifyList[sEventName][obsvrName] = fnCallback
	m_tbKept[fnCallback] = bOnce
end

--解除注册
function removeObserver( sEventName, sObsvName)
	if (m_tbNotifyList and m_tbNotifyList[sEventName]) then
		local func = m_tbNotifyList[sEventName][sObsvName]
		if (func) then
			m_tbKept[func] = nil
			m_tbNotifyList[sEventName][sObsvName] = nil
		end
	end
end

-- 触发注册的通知事件, 可以传递任意参数给注册的回调函数
function postNotify( sEventName, ... )
	logger:debug("postNotify")
	if (not m_tbNotifyList[sEventName]) then
		logger:debug("not found evnet %s", sEventName)
		logger:debug(m_tbNotifyList)
		return
	end

	for name, func in pairs(m_tbNotifyList[sEventName]) do
		if (func and type(func) == "function") then
			func(...)
			if (m_tbKept[func]) then
				m_tbKept[func] = nil
				m_tbNotifyList[sEventName][name] = nil
			end
		end
	end
end

-- 注册一个通知到 CCNotificationCenter
-- return: unregister 这个通知的方法
function addObserverToNotificationCenter( sObsvName, fnCallback )
	local obj = CCNode:create()
	obj:retain()

	m_ccNc:registerScriptObserver(obj, fnCallback, sObsvName)
	return function ( ... )
		logger:debug("CCNotificationCenter:unregister: %s", sObsvName)
		m_ccNc:unregisterScriptObserver(obj, sObsvName)
		obj:release()
	end
end

-- 给注册到CCNotificationCenter的某个observer发通知，sObsvName 为 observer 名称
function notifyNcObserver( sObsvName )
	return function ( ... )
		for obsName, func in pairs(m_NcObserver[sObsvName] or {}) do
			if (type(func) == "function") then
				logger:debug("notifyNcObserver: " .. sObsvName .. "-" .. obsName)
				func()
			end
		end
	end
end

-- 注册app切入后台和切回前台的通知到CCNotificationCenter
function addObserverForBackAndForegroud( ... )
	addObserverToNotificationCenter(NC_BACKGROUND, notifyNcObserver(NC_BACKGROUND))
	addObserverToNotificationCenter(NC_FOREGROUND, notifyNcObserver(NC_FOREGROUND))
end

-- 注册程序切换到后台的通知回调
function addObserverForBackground( sObsvName, fnCallback )
	m_NcObserver[NC_BACKGROUND][sObsvName] = fnCallback
	return function ( ... )
		m_NcObserver[NC_BACKGROUND][sObsvName] = nil
	end
end

-- 注册程序切换到前台的通知回调
function addObserverForForeground( sObsvName, fnCallback )
	m_NcObserver[NC_FOREGROUND][sObsvName] = fnCallback
	return function ( ... )
		m_NcObserver[NC_FOREGROUND][sObsvName] = nil
	end
end

		