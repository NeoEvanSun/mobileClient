-- FileName: ZyxCtrl.lua
-- Author: zhangqi
-- Date: 2014-11-03
-- Purpose: 登陆最游戏平台的主控
--[[TODO List]]

module("ZyxCtrl", package.seeall)

require "script/module/login/ZyxView"
require "script/module/public/ShowNotice"

-- UI控件引用变量 --

-- 模块局部变量 --
local m_ExpCollect = ExceptionCollect:getInstance()
local m_fnGetWidget = g_fnGetWidgetByName
local m_i18n = gi18n
local m_userDefault = g_UserDefault
local m_config = Platform.getConfig()

local m_Code_NetWork_Error 		= 0 	-- 网络请求出错
local m_Code_WebClient_Error	= -1 	-- Web端出错，返回参数格式不对
local m_Code_Unkown_ErrorId 	= -3 	-- Web端的返回ErrorId 未知
local _isAutoEnterGame = false
local m_Code_Request = 0 -- 表示请求类型: 登陆 1，注册 2，修改密码 3，试玩 4，绑定新帐号 5，绑定老账号 6，解除绑定 7

local m_usrKeyPre = "zyx_user_"
local m_pwdKeyPre = "zyx_pwd_"
local m_pwdHolder = "999"  -- 绑定过帐号的游客登陆由于拿不到账户密码，用3位的占位密码标识是绑定过帐号的游客登陆
local m_reqType = {LOGIN = 1, REGISTE = 2, CHGPWD = 3, GUEST = 4, BIND_NEW = 5, BIND_OLD = 6, UNBIND = 7}
-- 异常收集的actionName, 和 m_reqType 对应
local m_actionName = {"LOGIN", "REGISTE", "CHGPWD", "GUEST", "BIND_NEW", "BIND_OLD", "UNBIND"}

local m_errInfo = {
	["1001"] = m_i18n[1986],
	["1002"] = m_i18n[4737],
	["1003"] = m_i18n[4734],
	["1004"] = "参数错误",
	["1005"] = m_i18n[4737],
	["1006"] = m_i18n[4744],
	["1007"] = m_i18n[4745],
	["1008"] = m_i18n[4738],
	["1009"] = m_i18n[4722],
	["1010"] = m_i18n[4737],
	["1011"] = m_i18n[4743],
	["1012"] = m_i18n[4727],
	["1013"] = m_i18n[4742],
	["1014"] = m_i18n[4741],
	["1015"] = m_i18n[4740],
	["1016"] = m_i18n[4734],
	["1017"] = m_i18n[4726],
	["1018"] = m_i18n[4722],
	["1019"] = m_i18n[4748] .. "\n" .. m_i18n[4749]
}

local function init(...)

end

function destroy(...)
	package.loaded["ZyxCtrl"] = nil
end

function moduleName()
	return "ZyxCtrl"
end

-- 长度检查
function stringLenthVerify( strText, minLen, maxLen )
	return strText and (#strText >= minLen and #strText <= maxLen) or false
end

-- 帐号检查
function zyxAccountVerify( sAccount )
	local other = string.find(sAccount, "[^%w_]") -- 最游戏帐号只允许是 数字、字母、_, 结果返回nil表示没有特殊字符
	local validLen = stringLenthVerify(sAccount, 1, 16)
	return (not other) and validLen
end

-- 密码检查
function zyxPwdVerify( sPwd )
	return stringLenthVerify(sPwd, 4, 14)
end

-- 邮件检查
function zyxEmailVerify( sEmail )
	local validLen = stringLenthVerify(sEmail, 0, 50)
	if (#sEmail > 0) then
		return validLen and string.find(sEmail, "^[%w-_.]+@[%w-_.]+$")
	end
	return validLen
end

local function zyxAlert( sInfo )
	local tbArgs = {strText = sInfo, nBtn = 1}
	LayerManager.addLayout(UIHelper.createCommonDlgNew(tbArgs))
end
-- 解除绑定处理
local function onUnbindResponse( tbData )
	if (tbData.eno == "0") then
		writeAllLogin({}) -- 删除所有本地登陆记录
		m_config.loginState(m_config.kLoginsStateNotLogin) -- 修改成未登陆状态
		m_userDefault:flush()
		LoginHelper.loginAgain() -- 返回登陆
	else
		zyxAlert(tbData.enstr or "要解除的绑定不存在")
	end
end

local function saveLoginInfoToLocal( uid, tbLogin, okTX )
	LayerManager.removeLayoutByName( ZyxView.m_dlgName ) -- 2014-12-04, 指定名称只删除主登陆面板

	saveAndLogin( uid, tbLogin)

	if(okTX)then
		PlatformUtil.showAlert(okTX, nil)
	else
		--广告需求
		local adurl = config.getADUrl(uid)
		logger:debug("adurl %s",adurl)
		local requestAD = LuaHttpRequest:newRequest()
		requestAD:setRequestType(CCHttpRequest.kHttpGet)
		requestAD:setTimeoutForConnect(g_HttpConnTimeout)
		requestAD:setUrl(adurl)
		requestAD:setResponseScriptFunc(function() m_ExpCollect:finish("adurl") end)

		m_ExpCollect:start("adurl", "adurl = " .. adurl)

		local httpClientAD = CCHttpClient:getInstance()
		httpClientAD:send(requestAD)
		requestAD:release()
	end
end
-- 登陆处理
local function onLoginResponse(tbData)
	local codeRequest = m_Code_Request -- 缓存请求类型区别是否绑定的提示来自登陆还是注册
	m_Code_Request = 0 -- 重置请求类型
	if (tbData.eno == "0") then -- ok
		m_ExpCollect:finish(m_actionName[codeRequest])

		-- 2013-03-11, 平台统计需求， 最游戏平台新账号注册
		if (Platform.isPlatform() and (codeRequest == m_reqType.REGISTE)) then
			Platform.sendInformationToPlatform(Platform.kNewPlatformAccount)
		end

		m_config.bindUser((tonumber(tbData.isBindUser) == 1)) -- isBindUser == 1 表示已绑定设备号
		saveLoginInfoToLocal(tbData.uid, tbData.login, tbData.ok)
		ZyxView.resetAllInputText() -- 重置缓存的所有文本框内容
		LoginHelper.reLoginAfterPlatformLogin()
		return
	elseif (tbData.eno == "1019") then -- 2014-12-08, 询问用户是否绑定当前帐号
		m_ExpCollect:finish(m_actionName[codeRequest])

		local uName, uPwd = "", ""
		if (tbData.login and tbData.login.account) then
			uName = tbData.login.account
			uPwd = tbData.login.pwd
		end
		local tbLogin = {account = uName, pwd = uPwd}
		local tbArgs = {strText = string.format(m_errInfo[tbData.eno], uName, uName), nBtn = 1}
		tbArgs.fnConfirmEvent = function ( sender, eventType ) -- 确定绑定
			if (eventType == TOUCH_EVENT_ENDED) then
				LayerManager.removeLayout() -- 删除确定绑定面板
				if (codeRequest == m_reqType.LOGIN) then
					logger:debug("ZyxCtrl onBindOldRequest")
					onGuestBindOld(tbLogin) -- 老账号绑定请求
				elseif (codeRequest == m_reqType.REGISTE) then
					logger:debug("ZyxCtrl onBindNew")
					onGuestRegist(tbLogin) -- 绑定新账户
				end
		end
		end
		tbArgs.fnCloseCallback = function ( ... ) -- 不绑定
			if (codeRequest == m_reqType.LOGIN) then
				logger:debug("ZyxCtrl onLoginNoBind")
				onLoginNoBind(tbLogin)
		elseif (codeRequest == m_reqType.REGISTE) then
			logger:debug("ZyxCtrl onRegistNoBind")
			onRegistNoBind(tbLogin)
		end
		end
		if (LoginHelper.isReconnect()) then
			tbArgs.fnCloseCallback() -- 如果是重连，不显示是否绑定的提示，直接不绑定登陆
		else
			LayerManager.addLayout(UIHelper.createCommonDlgNew(tbArgs)) -- 封测包临时去掉绑定有礼的提示框
		end
		return
	end
	m_ExpCollect:info(m_actionName[codeRequest], "errorInfo: " .. (m_errInfo[tbData.eno] or tbData.estr))
	zyxAlert(m_errInfo[tbData.eno] or tbData.estr)
end
-- 注册处理
local function onRegistResponse( tbData )
	onLoginResponse(tbData)
end
-- 修改密码处理
local function onChangePwdResponse( tbData )
	onLoginResponse(tbData)
end
-- 游客登陆处理
local function onGuestLoginResponse( tbData )
	if (tbData.username) then -- 有用户名，是绑定过帐号的游客登陆——即最游戏账号登陆
		tbData.login.account = tbData.username
		tbData.login.pwd = m_pwdHolder -- 用3位的占位密码保证和4位以上的正式密码不会冲突
		tbData.login.udid = nil
	end
	m_config.bindUser((tonumber(tbData.isBindUser) == 1)) -- isBindUser == 1 表示已绑定设备号
	onLoginResponse(tbData)
end
-- 绑定新账号
local function onBindNewResponse( tbData )
	if (tbData.eno == "0") then -- ok
		m_config.bindUser(true)
		ShowNotice.showShellInfo(m_i18n[4735]) -- "绑定账号成功"
	end
	onLoginResponse(tbData)
end
-- 绑定老账号
local function onBindOldResponse( tbData )
	if (tbData.eno == "0") then -- ok
		m_config.bindUser(true)
		ShowNotice.showShellInfo(m_i18n[4735])
	end
	onLoginResponse(tbData)
end
function paserResponse( client, response, tbLogin, errorTX, okTX)
	local JsonString = response:getResponseData()
	local retCode = response:getResponseCode()
	logger:debug("JsonString %s",JsonString )
	local statusCode = m_Code_NetWork_Error
	local resValue = nil

	if (retCode ~= 200) then -- -- http 返回错误
		m_ExpCollect:info(m_actionName[m_Code_Request],
			string.format("RequestType = %s, retCode = %s, retData = %s", tostring(m_Code_Request), tostring(retCode), JsonString))

	m_Code_Request = 0
	statusCode = m_Code_NetWork_Error
	logger:debug("retCode: %d", retCode)
	PlatformUtil.showAlert(errorTX, nil)
	elseif (type(JsonString) == "string" and #JsonString > 0) then
		local cjson = require "cjson"
		resValue = cjson.decode(JsonString)
		logger:debug("paserResponse")
		logger:debug(resValue)

		m_ExpCollect:info(m_actionName[m_Code_Request], "JsonString = " .. JsonString)

		local tbData = {eno = tostring(resValue.errornu), estr = resValue.errordesc,
			newuser = resValue.newuser, username = resValue.username, isBindUser = resValue.isBindUser,
			uid = resValue.uid, login = tbLogin, ok = okTX}
		logger:debug("m_Code_Request = %d", m_Code_Request)
		logger:debug(tbData)

		if (m_Code_Request == m_reqType.LOGIN) then  -- 登陆
			onLoginResponse(tbData)
		elseif (m_Code_Request == m_reqType.REGISTE) then -- 注册
			onRegistResponse(tbData)
		elseif (m_Code_Request == m_reqType.CHGPWD) then -- 修改密码
			onChangePwdResponse(tbData)
		elseif (m_Code_Request == m_reqType.GUEST) then -- 游客登陆
			onGuestLoginResponse(tbData)
		elseif (m_Code_Request == m_reqType.BIND_NEW) then -- 绑定新帐号
			onBindNewResponse(tbData)
		elseif (m_Code_Request == m_reqType.BIND_OLD) then -- 绑定老账号
			onBindOldResponse(tbData)
		elseif (m_Code_Request == m_reqType.UNBIND) then -- 解除绑定，线下测试用
			onUnbindResponse(tbData)
		end
	end
end

-- 账号登陆时否定绑定手机的回调
function onLoginNoBind( tbLogin )
	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	-- 登陆请求URL
	if (tbLogin.account == "" or tbLogin.pwd == "") then
		local logins = getLoginRecord()
		local login = logins[1]
		tbLogin.account = login.account
		tbLogin.pwd = login.pwd
	end
	local loginUrl = m_config.getLoginNoBindUrl(tbLogin.account, tbLogin.pwd)
	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(loginUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4724] -- "登陆失败"
		paserResponse(client, response, tbLogin, errorTX )
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.LOGIN

	m_ExpCollect:start(m_actionName[m_Code_Request], "loginUrl = " .. loginUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 登陆按钮回调
function onLogin(tbLogin)
	if (tbLogin.pwd == m_pwdHolder) then -- 如果是绑定过帐号的游客登陆，走游客试玩的请求
		m_Code_Request = m_reqType.GUEST
		onGuestLogin()
		return true
	end

	if (tbLogin.account == "" or tbLogin.pwd == "") then
		zyxAlert(m_i18n[4718])
		return false
	end

	-- if (not zyxAccountVerify(tbLogin.account) or not zyxPwdVerify(tbLogin.pwd)) then
	--     local alert = UIHelper.createCommonDlg("登陆信息格式有误，请重新输入" )
	--     LayerManager.addLayout(alert)
	--     return false
	-- end

	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	-- 登陆请求URL
	local loginUrl = m_config.getLoginUrl(tbLogin.account, tbLogin.pwd)
	-- local loginUrl = m_config.getLoginUrl(CCCrypto:desEncrypt(tbLogin.account), CCCrypto:desEncrypt(tbLogin.pwd))
	logger:debug("loginUrl:%s", loginUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(loginUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4724] -- "登陆失败"
		paserResponse(client, response, tbLogin, errorTX )
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.LOGIN

	m_ExpCollect:start(m_actionName[m_Code_Request], "loginUrl = " .. loginUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()

	return true
end

local function registVerify( tbLogin )
	if (tbLogin.account == "" or tbLogin.pwd == "" or tbLogin.pwdConfirm == "") then
		zyxAlert(m_i18n[4718])
		return
	end

	if ( (not zyxAccountVerify(tbLogin.account)) or (not zyxPwdVerify(tbLogin.pwd))
		or (not zyxEmailVerify(tbLogin.email)) ) then
		zyxAlert(m_i18n[4729])
		return false
	end

	if (tbLogin.pwd ~= tbLogin.pwdConfirm) then
		logger:debug("sPwd = %s, confirm = %s", tbLogin.pwd, tbLogin.pwdConfirm)
		zyxAlert(m_i18n[4722]) -- "密码填写错误"
		return false
	end
	return true
end

-- 注册帐号后否定绑定手机的回调
function onRegistNoBind(tbLogin )
	LayerManager.addUILoading() -- 添加屏蔽层

	local registUrl = m_config.getRegisterNoBindUrl(tbLogin.account, tbLogin.pwd, tbLogin.email)
	logger:debug("registUrl:%s", registUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(registUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4726] -- "注册失败"
		paserResponse(client, response, tbLogin, errorTX )
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.REGISTE

	m_ExpCollect:start(m_actionName[m_Code_Request], "registUrl = " .. registUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 注册按钮回调
function onRegist(tbLogin)
	if (not registVerify(tbLogin)) then
		return
	end

	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	local registUrl = m_config.getRegisterUrl(tbLogin.account, tbLogin.pwd, tbLogin.email)
	logger:debug("registUrl:%s", registUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(registUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4726] -- "注册失败"
		paserResponse(client, response, tbLogin, errorTX )
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.REGISTE

	m_ExpCollect:start(m_actionName[m_Code_Request], "registUrl = " .. registUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 修改密码按钮回调
function onChangePW(tbLogin)
	if (tbLogin.account == "" or tbLogin.pwd == "" or tbLogin.newPwd == "" or tbLogin.pwdConfirm == "") then
		zyxAlert(m_i18n[4718])
		return
	end

	if (not zyxPwdVerify(tbLogin.pwd) or not zyxPwdVerify(tbLogin.newPwd) or not zyxPwdVerify(tbLogin.pwdConfirm)) then
		zyxAlert(m_i18n[4729])
		return
	end
	if (tbLogin.newPwd ~= tbLogin.pwdConfirm) then
		zyxAlert(m_i18n[4722])
		return
	end

	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	local changePWUrl = m_config.getChangePasswordUrl(tbLogin.account, tbLogin.pwd, tbLogin.newPwd)
	logger:debug("changePWUrl:%s", changePWUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(changePWUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4727] --"修改失败"
		local okTX = m_i18n[4728] -- "修改成功"
		local tbNewLogin = {account = tbLogin.account, pwd = tbLogin.newPwd}
		paserResponse(client, response, tbNewLogin, errorTX, okTX)
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.CHGPWD

	m_ExpCollect:start(m_actionName[m_Code_Request], "changePWUrl = " .. changePWUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 游客试玩按钮回调
function onGuestLogin(isAutoEnterGame)
	_isAutoEnterGame = isAutoEnterGame or false
	LayerManager.addUILoading() -- 添加屏蔽层

	local loginUrl = m_config.getGuestLoginUrl()
	logger:debug("GuestLoginUrl:%s", loginUrl)

	m_ExpCollect:start("onGuestLogin", "GuestLoginUrl = " .. loginUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(loginUrl)

	local function onResponse( client, response )
		m_ExpCollect:info("onGuestLogin", "onGuestLogin:responseCode = " .. tostring(response:getResponseCode()))
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4724] -- "登陆失败"
		local tbLogin = {udid = true}
		paserResponse(client, response, tbLogin, errorTX )
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.GUEST

	m_ExpCollect:start(m_actionName[m_Code_Request], "loginUrl = " .. loginUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 绑定注册按钮回调
function onGuestRegist(tbLogin)
	if (not registVerify(tbLogin)) then
		return
	end

	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	local registUrl = m_config.getGuestRegisterUrl(tbLogin.account, tbLogin.pwd, tbLogin.email)
	logger:debug("GuestRegisterUrl:%s", registUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(registUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4726] --"注册失败"
		paserResponse(client, response, tbLogin, errorTX)
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.BIND_NEW

	m_ExpCollect:start(m_actionName[m_Code_Request], "registUrl = " .. registUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 绑定老账号按钮回调
function onGuestBindOld(tbLogin)
	logger:debug("onGuestBindOld")
	logger:debug(tbLogin)
	if (tbLogin.account == "" or tbLogin.pwd == "") then
		zyxAlert(m_i18n[4718])
		return
	end

	_isAutoEnterGame = tbLogin.bAutoLogin or false
	LayerManager.addUILoading() -- 添加屏蔽层

	local registUrl = m_config.getGuestBindOldUrl(tbLogin)
	logger:debug("getGuestBindOldUrl:%s", registUrl)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(registUrl)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = m_i18n[4739] --"绑定失败"
		paserResponse(client, response, tbLogin, errorTX)
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.BIND_OLD

	m_ExpCollect:start(m_actionName[m_Code_Request], "registUrl = " .. registUrl)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

-- 解除绑定按钮测试用
function onUnBind( ... )
	LayerManager.addUILoading() -- 添加屏蔽层

	local url = m_config.getRemoveBindUrl()
	logger:debug("getRemoveBindUrl:%s", url)

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setTimeoutForConnect(g_HttpConnTimeout)
	request:setUrl(url)

	local function onResponse( client, response )
		LayerManager.begainRemoveUILoading() -- 请求返回删除屏蔽层

		local errorTX = "解除绑定失败"
		paserResponse(client, response, nil, errorTX)
	end

	request:setResponseScriptFunc(function(...)
		onResponse(...)
	end)

	m_Code_Request = m_reqType.UNBIND

	m_ExpCollect:start(m_actionName[m_Code_Request], "unbindUrl = " .. url)

	local httpClient = CCHttpClient:getInstance()
	httpClient:send(request)
	request:release()
end

function saveAndLogin( uid, tbLogin)
	logger:debug("saveAndLogin")
	logger:debug(tbLogin)

	Platform.setPid(uid)

	-- 保存登陆类型
	local loginStat = tbLogin.udid and m_config.kLoginsStateUDIDLogin or m_config.kLoginsStateZYXLogin
	m_config.loginState(loginStat)
	m_userDefault:flush()

	if (tbLogin.udid) then
		-- 登陆成功, 设置显示账户名称的按钮
		if (LayerManager.curModuleName() == "NewLoginView") then
			require "script/module/login/NewLoginView"
			NewLoginView.updateAccount(tbLogin) -- 如果当前模块是在选服界面才刷新帐号信息，避免找不到控件报错
		end
		return -- 如果是非绑定账号的游客登陆，不用保存登陆记录
	end

	m_config.zyxUser(true) -- 最游戏账号登陆

	setLastRecord(tbLogin)

	-- 登陆成功, 设置显示账户名称的按钮
	if (LayerManager.curModuleName() == "NewLoginView") then
		require "script/module/login/NewLoginView"
		NewLoginView.updateAccount(tbLogin) -- 如果当前模块是在选服界面才刷新帐号信息，避免找不到控件报错
	end

	if(type(config.setLoginInfo) == "function")then
		config.setLoginInfo(xmlTable)
	end

	if(_isAutoEnterGame)then
		if(not Platform.isDebug())then
			LoginHelper.loginLogicServer(uid)
		else
			local serverInfo = ServerList.getLastLoginServer()
			serverInfo.pid = uid
			print("login arg")
			print_t(serverInfo)
			LoginHelper.loginInServer(serverInfo)
		end
	end

	Platform.setCrashInfo()
end

function create( tbLogin )
	local tbData = {}

	tbData.account = tbLogin.account
	tbData.pwd = tbLogin.pwd

	tbData.enableInput = true -- 默认可以编辑面板上的文本框
	tbData.guest = tbLogin.guest -- 是否游客
	tbData.logined = tbLogin.logined -- 是否已登陆

	if (tbLogin.guest) then
		tbData.guest = tbLogin.guest
		if (tbLogin.logined) then -- 如果是游客且已登录，只显示"绑定账号"按钮
			tbData.eventBind = function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					logger:debug("onBind")
					LayerManager.removeLayout()

					local tbBinding = {} -- 绑定帐号界面需要的参数
					tbBinding.eventConfirm = function ( sender, eventType )
						if (eventType == TOUCH_EVENT_ENDED) then
							logger:debug("confirm binding")
						end
					end

					local layBind = ZyxView.showBinding(tbBinding)
					-- LayerManager.addLayout(layBind)
				end
			end
			tbData.enableInput = false
		else -- 如果是游客未登陆显示"试玩"
			tbData.eventTry = function ( ... )
				logger:debug("onTry")
				LayerManager.removeLayout()

				onGuestLogin()
			end
		end
	else
		tbData.eventChangePwd = function ( sender, eventType )
			if (eventType == TOUCH_EVENT_ENDED) then
				logger:debug("onChangePassword")
				LayerManager.removeLayout()

				local tbChgPwd = {} -- 修改密码界面需要的参数
				tbChgPwd.eventConfirm = function ( sender, eventType )
					if (eventType == TOUCH_EVENT_ENDED) then
						logger:debug("confirm ChangePassword")
					end
				end

				local layChangePwd = ZyxView.showChangePwd(tbChgPwd)
				-- LayerManager.addLayout(layChangePwd)
			end
		end
	end

	tbData.eventRegist = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			logger:debug("onRegist")
			LayerManager.removeLayout()

			local tbRegist = {} -- 注册界面需要的参数
			tbRegist.eventConfirm = function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					logger:debug("first confirm register")
					local allInput = ZyxView.getAllInputText()
					logger:debug("NewLoginView eventRegist")
					logger:debug(allInput)

					onRegist(allInput)
				end
			end

			local layRegist = ZyxView.showRegister(tbRegist)
			-- LayerManager.addLayout(layRegist)
		end
	end

	tbData.eventLogin = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			logger:debug("onLogin")
			-- LayerManager.removeLayout()
			-- 获取文本框的内容
			local allInput = ZyxView.getAllInputText()
			logger:debug("ZyxCtrl.onLogin ZyxView.getAllInputText()")
			logger:debug(allInput)
			onLogin(allInput) -- 2015-02-13
		end
	end

	local dlgLogin = ZyxView.showLogin(tbData)
	-- LayerManager.addLayout(dlgLogin)
end

function getLoginRecord( ... )
	local all = {}

	for i = 1, 5 do
		local uname = m_userDefault:getStringForKey(m_usrKeyPre .. i)
		if (uname == "") then
			break
		end
		all[i] = {}
		all[i].account = CCCrypto:desDecrypt(uname) -- 读出后解密
		all[i].pwd = CCCrypto:desDecrypt(m_userDefault:getStringForKey(m_pwdKeyPre .. i))
	end

	return all
end

function deleteLoginRecord( nIdx )
	local all = getLoginRecord()
	logger:debug("deleteLoginRecord before delete: %d", nIdx)
	logger:debug(all)
	if (not table.isEmpty(all)) then
		table.remove(all, nIdx)
		logger:debug("deleteLoginRecord after delete")
		logger:debug(all)
		writeAllLogin(all)
	end
end

function setLastRecord(tbLogin)
	local all = getLoginRecord()
	logger:debug("setLastRecord1")
	logger:debug(all)
	logger:debug(tbLogin)

	if (all[1] and all[1].account == tbLogin.account) then
		logger:debug("setLastRecord2")
		if (all[1].pwd == tbLogin.pwd) then
			return -- 要设置的账户是最近一次登陆，且密码也一样直接返回
		else
			all[1].account, all[1].pwd = tbLogin.account, tbLogin.pwd  -- 如果修改了密码则重新写入本地
			logger:debug("setLastRecord3")
			logger:debug(all)
			writeAllLogin(all)
			return
		end
	end

	-- 查找要设置的账户是否已在记录中
	local idx, bFound = 1, false
	for i, v in ipairs(all) do
		if (v.account == tbLogin.account) then
			idx, bFound = i, true
			break
		end
	end

	local newRec, newAll = {account = tbLogin.account, pwd = tbLogin.pwd}, all
	if (not bFound) then -- 是一个新账户，删除最后一个，插入第一个
		if(#all == 5)then
			table.remove(all, #all)
	end
	table.insert(all, 1, newRec)
	else
		if (idx ~= 1) then
			table.remove(newAll, idx)
			table.insert(newAll, 1, newRec)
		end
	end

	logger:debug("setLastRecord4")
	writeAllLogin(newAll)
end

function writeAllLogin( tbData )
	logger:debug("writeAllLogin")
	logger:debug(tbData)

	for i = 1, 5 do
		if (tbData[i]) then
			logger:debug("writeAllLogin: %s, %s", tbData[i].account, tbData[i].pwd)
			local encUser = CCCrypto:desEncrypt(tbData[i].account)
			local encPwd = CCCrypto:desEncrypt(tbData[i].pwd)
			m_userDefault:setStringForKey(m_usrKeyPre .. i, encUser) -- 写入前加密
			m_userDefault:setStringForKey(m_pwdKeyPre .. i, encPwd)
			logger:debug("i = %d, usr = %s, pwd = %s", i, tbData[i].account, tbData[i].pwd)
			m_userDefault:flush()
		else
			m_userDefault:setStringForKey(m_usrKeyPre .. i, "")
			m_userDefault:setStringForKey(m_pwdKeyPre .. i, "")
			m_userDefault:flush()
		end
	end
end

function autoLogin( ... )
	local logins = getLoginRecord()
	local tbLogin = logins[1]
	if (tbLogin) then
		if (tbLogin.account and tbLogin.pwd ) then
			-- tbLogin.bAutoLogin = true
			logger:debug(tbLogin)
			onLogin(tbLogin) -- 2015-02-13
		else
			onGuestLogin() -- 如果本地登陆记录有问题，则先按游客绑定的账户去登陆
		end
	else
		onGuestLogin() -- 如果本地登陆记录有问题，则先按游客绑定的账户去登陆
	end
end
