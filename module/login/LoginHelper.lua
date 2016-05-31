-- FileName: LoginHelper.lua
-- Author: zhangqi
-- Date: 2014-09-07
-- Purpose: 登录和重连的相关逻辑方法
--[[TODO List]]

module("LoginHelper", package.seeall)

require "script/utils/ExceptionCollect"
require "platform/Platform"
require "script/network/RequestCenter"
-- 模块局部变量 --
local m_nBackTime = 0 -- 2015-04-20, zhangqi, 记录转入后台时的时间戳

local m_bReconnStatus = false -- 表示是否重连
local m_userDefault = CCUserDefault:sharedUserDefault()

local m_reconnCount = 0 -- 自动重连次数，初始为0, 最大为3

local m_ExpCollect = ExceptionCollect:getInstance()

local m_bReLoginStatus = false -- 2015-04-20, zhangqi, 表示不需要重新登陆, 给活动副本特殊需求用
function reloginState( bState )
	if (bState and type(bState) == "boolean") then
		m_bReLoginStatus = bState
	else
		return m_bReLoginStatus
	end
end

function isReconnect( ... )
	return m_bReconnStatus
end

-- 2014-12-29, 如果原地重连后发现新版本，则会返回登陆界面，此时需要把重连状态设置为false
function setReconnectStat( bStat )
	m_bReconnStatus = bStat
end

-- 本地读取或保存 uid 的值, 用于实现debug模式下免去每次都要输入的麻烦
function debugUID( uid )
	if (uid) then
		m_userDefault:setStringForKey("DEBUG_UID", uid)
		m_userDefault:flush()
	else
		return m_userDefault:getStringForKey("DEBUG_UID")
	end
end

-- 读取或设置自动重连次数
function reconnCount( nCount )
	if (nCount and nCount >= 0) then
		m_reconnCount = nCount
		logger:debug("LoginHelper:reconnCount = %d", m_reconnCount)
	else
		return m_reconnCount
	end
end

function netWorkFailed( bShowDlg )
	logger:debug("netWorkFailed")

	Network.m_status = g_network_disconnected -- zhangqi, 2015-01-14, 先修改断网状态，便于战斗结束后能及时显示断网提示

	-- zhangqi, 2014-11-25, 战斗动画开播后如果网络断开不弹提示面板，
	-- 避免原地重连更新了玩家信息导致战斗结束结算时重复增加经验值的问题
	if (BattleState.isOnPlayRecord() == true) then
		logger:debug("netWorkFailed in battle, return")
		return
	end

	-- Network.m_status = g_network_disconnected

	GlobalNotify.postNotify(GlobalNotify.NETWORK_FAILED) -- 发送断开通知

	LayerManager.removeLoading()

	logger:debug("bShowDlg = %s", tostring(bShowDlg))
	local function showFailedDlg( ... )
		logger:debug("show network failed dlg")

		if (LayerManager.networkDlgIsShow()) then
			return
		end

		-- 2015-04-20, zhangqi, 活动副本需求：如果在获取掉落物品信息后到领取前发生掉线，则弹出只有返回登陆按钮的面板
		if (reloginState()) then
			UIHelper.showNetworkDlg(nil, function ( ... )
				LayerManager.removeNetworkDlg()
			end, true, gi18n[4210]) -- true 模拟被抢号，只显示返回登陆按钮，但提示文字还是网络异常提示

			return
		end

		UIHelper.showNetworkDlg(nil, function ( ... )
			LayerManager.removeNetworkDlg()
		end, Network.m_bOtherLogin)
	end
	-- zhangqi, 2015-03-26, 尝试自动重连3次，每次间隔2秒；如果3次重连都失败才弹出断网提示面板
	if (bShowDlg == true) then -- 自动重连全部失败会显示断网提示
		LayerManager.removeLoginLoading()
		showFailedDlg()
	else -- 启动第一次自动重连
		if (Network.m_bOtherLogin or (LoginHelper.reconnCount() >= g_reconnMax)) then -- 如果是帐号别处登陆则直接显示提示
			LoginHelper.reconnCount(0)

			LayerManager.removeLoginLoading()
			showFailedDlg()
	else
		LayerManager.addLoginLoading("连接中……")

		local stopSchedule = nil
		stopSchedule = GlobalScheduler.scheduleFunc(function ( ... ) -- 2秒定时器到时启动重连
			stopSchedule() -- 停止定时器

			local count = LoginHelper.reconnCount()
			LoginHelper.reconnCount(count + 1)
			LoginHelper.reconnect()
		end, g_reconnInter)
	end
	end
end

local tbBaseModule = {
	"script/module/public/class", -- 最基本的公用模块
	"db/i18n",
	"script/module/config/AudioHelper",
	"script/GlobalVars",
	"script/module/public/GlobalNotify", -- 2014-09-07
	"script/utils/LuaUtil",
	"script/utils/TimeUtil",
	"script/module/public/UIHelper",
	"script/fw/Util", -- 游戏框架中的模块
	"script/fw/Logger",
	"script/fw/EventDispatcher",
	"script/fw/Downloader",
	"script/fw/Updater",
	"script/app/Helper",
	"script/app/Application",
	"script/module/main/LayerManager", -- 层管理器
	"script/network/Network",
	--"script/battle/BattleState",
	"script/module/public/GlobalScheduler",
	"script/module/PlayerInfo/PlayerInfoBar", -- 玩家信息条基类
}
-- zhangqi, 重新加载所有的基础性模块
function reloadBaseModule( ... )
	for i, path in ipairs(tbBaseModule) do
		package.loaded[path] = false
		print("reloadBaseModule: path = ", path)
		require(path)
	end
end

-- 2015-04-07, zhangqi, 优化：去掉对path中模块名称的解析，只需判断 package.loaded[path] 的类型即可
function releaseLoadedModule( ... )
	for path, mod in pairs(package.loaded) do
		if (type(mod) == "boolean") then
			print("releaseLoadedModule: boolean = ", path)
			package.loaded[path] = false
		elseif (type(mod) == "table") then
			if (mod.destroy) then
				print("destroy mod = ", path)
				pcall(mod.destroy) -- zhangqi, 2014-10-16, 用pcall避免在某个destroy里调用前面已被释放了的模块导致报错
			end

			-- logger的模块table不能释放，避免其他未释放但正在使用logger的模块报错, 随后也能重新加载
			if (not string.find(path, "logging")) then
				print("releaseLoadedModule mod = ", path)
				package.loaded[path] = nil
			end
		end
	end
end

-- 2015-04-20, zhangqi, 游戏转入后台时的回调
-- 1.记录当前时间戳，用于切换前台后的时长判断，超过30分钟就自动返回选服列表
function appToBackgroundCallback( ... )
	logger:debug("app in Background")
	m_nBackTime = TimeUtil.getSvrTimeByOffset()
end

function appToForegroundCallback( ... )
	logger:debug("app in Foreground")
	local now = TimeUtil.getSvrTimeByOffset()
	if ( now - m_nBackTime > 1800 ) then -- 如果切入后台超过30分钟，自动切换到选服界面
		loginAgain()
	end

	-- 如果切入后台到回来跨过了0点，自动切换到选服界面
	if (TimeUtil.getDifferDay(m_nBackTime) > 0) then
		loginAgain()
	end
end


function initGame( ... )
	reloadBaseModule()

	-- 统一设置 log 输入的级别
	if (g_debug_mode) then
		logger:setLevel(logging.DEBUG)
		Logger.setLevel(Logger.kDebug)
	else
		print = function ( ... ) end -- 屏蔽内置的print输出
		logger:setLevel(logging.ERROR)
		Logger.setLevel(Logger.kInfo)
	end

	GlobalNotify.init() -- 初始化全局通知管理器
	LayerManager.init() -- 初始化层管理器，进一步加载资源更新UI

	GlobalNotify.addObserverForBackAndForegroud() -- 注册程序切入系统后台和切回前台的回调通知
	GlobalNotify.addObserverForBackground("LoginHelper.initGame", appToBackgroundCallback) -- 注册不删除的切入后台通知
	GlobalNotify.addObserverForForeground("LoginHelper.initGame", appToForegroundCallback)
end

-- true 表示是重连的版本检测，不会切换到启动时版本检测的背景
function initMainApp( bReconn )
	-- 进入更新检查模块
	local mainApp = Application.create()
	mainApp:init(bReconn)
end
function test_callback(cbFlag, dictData, bRet)
	LayerManager.addLayout(UIHelper.createCommonDlg(dictData .. bRet))
end
function connectAndLogin ( ... )
	BTEventDispatcher:getInstance():removeAll() -- 重置事件派发队列
	PackageHandler:setToken("0") -- 重置网络连接的 token

	local svrInfo = g_tbServerInfo

	if (g_debug_mode and g_no_web) then -- 如果web服务异常就用默认配置
		svrInfo = {host = g_host, port = g_port}
	end

	if (Network.connect(svrInfo.host, svrInfo.port)) then
	--	LayerManager.addLayout(UIHelper.createCommonDlg(svrInfo.host))
	 LayerManager.addLayout(UIHelper.createCommonDlg("" .. g_network_disconnected))
		local params = CCArray:create()
     	params:addObject(CCString:create("message:lizy test"))
     	RequestCenter.test(test_callback,params)
		-- 2013-03-11, 平台统计需求，从Web端获取到Pid后开始登录游戏服务器
		if (Platform.isPlatform()) then
			Platform.sendInformationToPlatform(Platform.kEnterGameServer)
		end

		-- logger:debug("socket connected, svrInfo.host: %s, svrInfo.port: %d", svrInfo.host, svrInfo.port)
		LayerManager.addLoginLoading()

		BTEventDispatcher:getInstance():addLuaHandler("failed", netWorkFailed, false) -- 注册网络断开的事件

		require "script/network/RequestCenter"
		--RequestCenter.re_OtherLogin() -- 注册账号在别处登陆的推送，zhangqi, 2015-01-05

		m_ExpCollect:start("connectAndLogin")
		local args = getLoginNetworkArgs()
		require "script/network/user/UserHandler"
		--Network.rpc(UserHandler.login, "user.login", "user.login", args, true)
	else
		netWorkFailed()
	end
end

function reLoginAfterPlatformLogin( ... )
	if (m_bReconnStatus == true) then
		loginGame()
	end
end

function loginGame ( ... )
	Network.m_status = g_network_connecting
	--LayerManager.addLayout(UIHelper.createCommonDlg(tostring(Network.m_status)))
	logger:debug("loginGame m_bReconnStatus = %s", tostring(m_bReconnStatus))
	logger:debug("loginGame m_reconnStatus = %s", tostring(g_network_connecting))

	if (Platform.isPlatform()) then
		local pid = Platform.getPid()
		if (not pid or pid == "") then
			LayerManager.addLayout(UIHelper.createCommonDlg("请先登陆账号"))
			return
		end

		if (Platform.isDebug()) then
			local serverInfo = g_tbServerInfo
			serverInfo.pid = pid
			loginInServer(serverInfo)
		else
			loginLogicServer(pid)
		end
	else
		g_web_env.online = false
		connectAndLogin()
	end
end

function enterGame( ... )
	Network.m_status = g_network_connected

	require "script/module/upgrade/MainUpgradeCtrl"
	GlobalNotify.addObserver(GlobalNotify.LEVEL_UP, MainUpgradeCtrl.create)

	-- zhangqi, 2014-12-30, 如果开启了阵容同时把判断阵容装备红点的方法注册到断线重连成功后的通知
	if (SwitchModel.getSwitchOpenState(ksSwitchFormation)) then
		require "script/module/public/ItemUtil"
		GlobalNotify.addObserver(GlobalNotify.RECONN_OK, ItemUtil.justiceBagInfo)
	end

	GlobalScheduler.schedule()

	require "script/module/copy/MainCopy"
	local bPassFirstEnt = MainCopy.isCrossFirstEntrance()
	logger:debug("有没有通过第一个副本: %s", tostring(bPassFirstEnt))

	m_ExpCollect:info("connectAndLogin", "enterGame bPassFirstEnt = " .. tostring(bPassFirstEnt))
	m_ExpCollect:finish("connectAndLogin")

	if (bPassFirstEnt) then
		require "script/module/main/MainScene"
		--MainScene.create()
		print("zhm")
	else
		require "script/module/login/NewGuyHelper"
		--NewGuyHelper.enterGuide()
	end

	LayerManager.removeLoginLoading()
	GlobalNotify.postNotify(GlobalNotify.RECONN_OK) -- 给连接成功的观察者发通知
end

-- 2015-03-11, zhangqi, 注销平台帐号的重新登陆，不释放已加载模块，以便Platform保留相关状态
function platformLogout( ... )
	GlobalScheduler.destroy()

	local curScene = CCDirector:sharedDirector():getRunningScene()
	curScene:removeAllChildrenWithCleanup(true) -- 删除当前场景的所有子节点
	CCTextureCache:sharedTextureCache():removeUnusedTextures() -- 清除所有不用的纹理资源

	m_bReconnStatus = false

	initGame()

	-- 进入更新检查模块
	initMainApp()
end

-- 重新登录，会重新走版本检测流程和平台sdk登录流程
function loginAgain()
	releaseLoadedModule() -- zhangqi, 2014-09-03, 释放所有已加载的模块，保证重新登录可以加载新的代码

	local curScene = CCDirector:sharedDirector():getRunningScene()
	curScene:removeAllChildrenWithCleanup(true) -- 删除当前场景的所有子节点
	CCTextureCache:sharedTextureCache():removeUnusedTextures() -- 清除所有不用的纹理资源

	m_bReconnStatus = false

	initGame()

	-- 进入更新检查模块
	initMainApp()
end

-- 原地重连
function reconnect( ... )
	m_bReconnStatus = true

	-- 进入更新检查模块
	initMainApp(true) -- true 表示是重连的版本检测，不会切换到启动时版本检测的背景
end

function startPreRequest( ... )
	logger:debug("LoginHelper.startPreRequest")

	-- 在取得功能节点之后获得武将战斗力信息
	local function getAlHeroesInfoAndSetFightforce( callback )
		require "script/network/RequestCenter"
		RequestCenter.hero_getAllHeroes(function ( cbFlag, dictData, bRet )
			-- 处理获取所有英雄回调
			print("haha Request allHeroInfo bRet: ", bRet, "  cbFlag: ", cbFlag)
			logger:debug(dictData)
			m_ExpCollect:info("connectAndLogin", "startPreRequest allHeroInfo bRet = " .. tostring(bRet) .. " cbFlag = " .. cbFlag)

			if (bRet == true and cbFlag == "hero.getAllHeroes") then
				require "script/model/hero/HeroModel"
				HeroModel.setAllHeroes(dictData.ret)
				UserModel.setInfoChanged(true)
				UserModel.updateFightValue() -- 然后更新战斗力数值
				if (callback) then
					callback()
				end
			end
		end)
	end

	-- menghao 1027 为了创建角色处断线重连后能进入游戏
	if (m_bReconnStatus and (not UserHandler.isNewUser)) then -- 如果是重新连接，则不重新拉取所有数据，避免依赖断线前状态的UI刷新处理混乱
		UserHandler.isNewUser = false -- menghao 同时要把这个置为false
		logger:debug("LoginHelper.startPreRequest: not do PreRequest")
		require "script/network/PreRequest"
		PreRequest.registerAllPushMessageHandler() -- 重新注册所有推送消息处理

		function endOfReconnect ( ... )
			m_bReconnStatus = false
			Network.m_status = g_network_connected
			reconnCount(0) -- 重置自动重连次数
			LayerManager.removeLoginLoading()
			GlobalNotify.postNotify(GlobalNotify.RECONN_OK) -- 给连接成功的观察者发通知
		end

		if (LayerManager.isInBattle()) then -- 如果是战斗场景中重连，需要先调后端接口重置战斗状态
			logger:debug("reconnect In Battle")
			require "script/network/RequestCenter"
			RequestCenter.ncopy_getAtkInfoOnEnterGame(function ( ... )
				getAlHeroesInfoAndSetFightforce(endOfReconnect) -- 拉取所有伙伴信息，更新客户端战斗力数值
			end, nil)
		else
			getAlHeroesInfoAndSetFightforce(endOfReconnect) -- 拉取所有伙伴信息，更新客户端战斗力数值
		end

		return
	end

	---------- 开始拉数据 -------
	require "script/network/PreRequest"
	UserHandler.isNewUser = false -- menghao 同时要把这个置为false
	PreRequest.startPreRequest(function ( ... )
		getAlHeroesInfoAndSetFightforce(enterGame)
	end)
end


------------------------ 三国的老代码 ------------------------------
-- local _bNotOvertureStatus = false

function getLoginNetworkArgs( ... )
	local args
	if ( Platform.isPlatform()) then
		local userDic = CCDictionary:create()
		for k,v in pairs(_tPlatformUserTable) do
			userDic:setObject(CCString:create(tostring(v)),k)
		end
		args = CCArray:create()
		args:addObject(userDic)
	else
		local debugPid = debugUID()
		args = CCArray:createWithObject(CCInteger:create(tonumber(debugPid)))
	end
	local sKeyValue = "publish=" .. Helper.pkgVer .. ", script=" .. Helper.resVer .. ", pl="..Platform.getPlatformFlag()
	args:addObject(CCString:create(sKeyValue))

	m_ExpCollect:info("connectAndLogin", "sKeyValue = " .. sKeyValue)

	return args
end

-- 网络参数 CCArray类型
function loginInServer( user_table )
	logger:debug("LoginHelper.loginInServer")
	_tPlatformUserTable = user_table
	logger:debug(user_table)

	-- 如果 web 端返回的数据里有 online_state 为 0，则为线下环境, g_web_env.online = false
	g_web_env.online = not (user_table.online_state and (user_table.online_state == 0))

	connectAndLogin()
end

--登陆逻辑服务器
function loginLogicServer( pid )
	-- 从服务器拉去登陆数据
	pid = pid or Platform.getPid()
	local url = Platform.getGameServerInfoUrl(pid)
	logger:debug("getHash request url:" .. url)
	LayerManager.addLoading()

	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setUrl(url)
	request:setResponseScriptFunc(loginGameResult)

	m_ExpCollect:start("loginLogicServer", "getHash url = " .. url)
	CCHttpClient:getInstance():send(request)
	request:release()
end
function loginGameResult( sender, res )
	LayerManager.removeLoading()

	if(res:getResponseCode()~=200)then
		m_ExpCollect:info("loginLogicServer", "responseCode = " .. tostring(res:getResponseCode()))
		LayerManager.addLayout(UIHelper.createCommonDlg("请先登陆账号"))
		return
	end

	m_ExpCollect:finish("loginLogicServer")

	local loginJsonString = res:getResponseData()
	logger:debug("loginJsonString:" .. loginJsonString)
	local cjson = require "cjson"
	local loginInfo = cjson.decode(loginJsonString)
	Platform.sendUuid("getHash","after")
	loginInServer( loginInfo )
end

local function fnHanlderOfServer( ... )
	loginAgain()
end

local function eventOfServer( sender, eventType )
	if (eventType == TOUCH_EVENT_ENDED) then
		fnHanlderOfServer()
	end
end

-- 服务器与平台链接无效了
function fnServerIsTimeout( ... )
	LayerManager.addLayout(UIHelper.createCommonDlg("连接超时，请重新登陆", nil, eventOfServer, 1, fnHanlderOfServer))
end
-- 服务器已满
function fnServerIsFull( ... )
	LayerManager.addLayout(UIHelper.createCommonDlg("该服玩家已爆满，请选择其它服继续游戏", nil, eventOfServer, 1, fnHanlderOfServer))
end
-- 游戏帐号被禁用
local m_bAccountIsBanned = false
function fnIsBanned(pBanInfo)
	m_bAccountIsBanned = true
	if (pBanInfo and pBanInfo.msg) then
		LayerManager.addLayout(UIHelper.createCommonDlg(pBanInfo.msg, nil, eventOfServer, 1, fnHanlderOfServer))
	end
end
