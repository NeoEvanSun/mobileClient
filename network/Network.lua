-- Filename: Network.lua
-- Author: fang
-- Date: 2013-05-28
-- Purpose: 该文件用于网络调用相关模块公用处理函数

module ("Network", package.seeall)

require "script/utils/LuaUtil"

local tm_cbFuncs = {}
local re_cbFuncs = {}
local no_loading_cbFunc = {}
local m_bShowLoading = false

m_bOtherLogin = false -- 是否帐号在别处登陆导致连接断开, zhangqi, 2015-01-05
m_status = g_network_disconnected   -- 网络状态：初始化为“断开”

m_lastRpcFlag = "" -- 最近发出的rpc的自定义名称
m_tbRpcBack = {} -- zhangqi, 2015-03-17, 记录一个rpc请求是否收到返回；发出请求记为 true, 收到返回记为nil

-- lua层主动调用网络连接接口
-- phost: 服务器hostname或ip
-- pport: 服务器端口
function connect (phost, pport)
	m_bOtherLogin = false -- 重置

	local dhost = phost or g_host
	local dport = pport or g_port

	local client = BTNetClient:getInstance()
	logger:debug("dhost = %s, dport = %d", dhost, dport)
	if (not client:connectWithAddr(dhost, dport)) then
		logger:debug("The network is unavailable.")
		return false
	end
	logger:debug("The network is available.")
	return true
end

-- zhangqi, 2015-03-11, 断开所有socket连接
function disconnect( ... )
	logger:debug("Network.disConnect game server")
	local client = BTNetClient:getInstance()
	client:disConnect()
end

-- 推送
function re_rpc( cbFunc, cbFlag, rpcName )
	local disp = BTEventDispatcher:getInstance()
	disp:addLuaHandler(cbFlag, re_networkHandler, false)
	re_cbFuncs[cbFlag] = cbFunc
end
-- 删除 推送
function remove_re_rpc( cbFlag )
	re_cbFuncs[cbFlag] = nil
end


function re_networkHandler(cbFlag, dictData, bRet)
	if not bRet then
		-- 先调错误页面
		logger:debug ("Warning re_networkHandler, you need add ErrorPage showing here.")
	end
	-- 把网络结果传给UI
	if (re_cbFuncs[cbFlag] == nil) then
		return
	end
	re_cbFuncs[cbFlag](cbFlag, dictData, bRet)
end

----------------------------------------------- 无LoadingUI add by chengliang ----------------------------------------
--
function no_loading_rpc( cbFunc, cbFlag, rpcName, args )
	local disp = BTEventDispatcher:getInstance()
	disp:addLuaHandler(cbFlag, no_loading_networkHandler, false)
	disp:callRPC(cbFlag, rpcName, args)
	no_loading_cbFunc[cbFlag] = cbFunc
end
-- 删除
function remove_no_loading_rpc( cbFlag )
	no_loading_cbFunc[cbFlag] = nil
end

-- 网络返回参数处理
function no_loading_networkHandler(cbFlag, dictData, bRet)
	if not bRet and g_debug_mode then -- 调试模式先调错误页面
		require "script/module/public/UIHelper"
		LayerManager.addLayout(UIHelper.createCommonDlg(dictData.err, nil, nil, 1))
	end

	-- 把网络结果传给UI
	if (no_loading_cbFunc[cbFlag] == nil) then
		return
	end
	no_loading_cbFunc[cbFlag](cbFlag, dictData, bRet)
	no_loading_cbFunc[cbFlag] = nil
end

----------------------------------------------- 正常请求 有LoadingUI ----------------------------------------
function fnRpcDebug(cbFunc)
	BTEventDispatcher:getInstance():addLuaHandler("failed", cbFunc, false)
	local cbFlag = "user.closeMe"
	local rpcName = "user.closeMe"
	local args = CCArray:createWithObject(CCString:create("fnRpcDebug"));

	local disp = BTEventDispatcher:getInstance()

	disp:addLuaHandler(cbFlag, cbFunc, true)
	disp:callRPC(cbFlag, rpcName, nil)

end

-- zhangqi, 2015-03-18, 返回最近一次rpc调用是否返回：true, 已返回；false, 未收到返回
function lastRpcBack( ... )
	return (not m_tbRpcBack[m_lastRpcFlag])
end

--调用网络接口
--cbFunc: 回调的方法 type->lua function
--cbFlag: 回调的标识名称, 用于区别其他回调 type->string
--rpcName: 调用后端函数的名称 type->string
--args: 调用函数需要的参数  type->CCArray
--autoRelease: 调用完成后是否删除此回调方法
--return:无
function rpc(cbFunc, cbFlag, rpcName, args, autoRelease)
	m_lastRpcFlag = cbFlag
	m_tbRpcBack[cbFlag] = true -- 2015-03-17, 发出请求

	local disp = BTEventDispatcher:getInstance()

	disp:addLuaHandler(cbFlag, networkHandler, autoRelease)
	disp:callRPC(cbFlag, rpcName, args)

	tm_cbFuncs[cbFlag] = cbFunc

	if (not m_bShowLoading) then
		LayerManager.addLoading() -- zhangqi, 2014-05-12, 显示网络请求Loading
		m_bShowLoading = true
	end
end
-- 网络统一接口
function networkHandler(cbFlag, dictData, bRet)
	m_tbRpcBack[cbFlag] = nil -- 2015-03-17, 收到返回

	-- logger:debug("networkHandler, m_lastRpcFlag = %s", m_lastRpcFlag)
	-- logger:debug(m_tbRpcBack)

	-- zhangqi, 2014-05-13, 如果不是后端推送的网络消息，从uiLayer上删除发请求时加载的Loading面板
	-- zhangqi, 2014-06-03, 必须将 . 用 / 转义，否则会匹配类似 reward 之类的 callback name
	if (m_bShowLoading and ( not (string.find(cbFlag, "re/.") == 1))) then
		LayerManager.removeLoading()
		m_bShowLoading = false
	end

	if (not bRet and g_debug_mode) then -- 调试模式先调错误页面
		-- zhangqi, 2015-04-24, DEBUG模式把错误返回传给回调方便Log查看和其他特殊处理
		tm_cbFuncs[cbFlag](cbFlag, dictData, bRet)
		tm_cbFuncs[cbFlag] = nil

		error(Util.tableToString(dictData))
	end

	-- 把网络结果传给UI
	if (tm_cbFuncs[cbFlag] == nil) then
		return
	end

	tm_cbFuncs[cbFlag](cbFlag, dictData, bRet)
	tm_cbFuncs[cbFlag] = nil
end
-- 网络参数统一处理接口
function argsHandler(...)
	local args = CCArray:create()
	for k, v in ipairs({...}) do
		if (type(v) == "number") then
			args:addObject(CCInteger:create(v))
		elseif(type(v) == "string") then
			args:addObject(CCString:create(v))
		elseif(type(v) == "table") then
			args:addObject(argsHandler(v))
		else
			logger:debug("Error: unexpected type.")
		end
	end
	return args
end

-- 上面的函数在处理参数为table类型时出现溢出的bug
function argsHandlerOfTable(tParams)
	if (table.isEmpty(tParams)) then
		return nil
	end
	logger:debug({argsHandlerOfTableArgs = tParams})

	local args = CCArray:create()
	for k, v in pairs(tParams) do
		if (type(v) == "number") then
			args:addObject(CCInteger:create(v))
		elseif(type(v) == "string") then
			args:addObject(CCString:create(v))
		elseif(type(v) == "table") then
			args:addObject(argsHandlerOfTable(v))
		else
			logger:debug("Error: unexpected type.")
		end
	end
	return args
end





