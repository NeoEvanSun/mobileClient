-- FileName: NewLoginCtrl.lua
-- Author: menghao
-- Date: 2014-07-10
-- Purpose: 登陆界面ctrl


module("NewLoginCtrl", package.seeall)


require "script/module/login/NewLoginView"
require "platform/Platform"

-- UI控件引用变量 --
local layMain

-- 模块局部变量 --
local m_ExpCollect = ExceptionCollect:getInstance()
local m_userDefault = CCUserDefault:sharedUserDefault()
local m_i18n = gi18n
local m_tbAllServerData
local m_selectServer
local tbEvent


local function init(...)

end


function destroy(...)
	package.loaded["NewLoginCtrl"] = nil
end


function moduleName()
	return "NewLoginCtrl"
end

local function fnRecentServerGroup( group )
	if (group) then
		m_userDefault:setStringForKey("recentServerGroup", group)
	else
		return m_userDefault:getStringForKey("recentServerGroup")
	end
end

local function copy2gServerInfo(tbInfo)
	for k, v in pairs(tbInfo or {}) do
		g_tbServerInfo[k] = v
	end
end

function setSelectServer( tbServerData )
	m_selectServer = tbServerData
	copy2gServerInfo(tbServerData)
	NewLoginView.upServerUI(tbServerData)
end


-- 获取默认选择的服务器
function getSelectServerInfo( ... )
	if (m_selectServer) then
		return m_selectServer
	else
		local last = getLastLoginServer()
		if(last) then
			return last
		elseif (m_tbAllServerData) then
			return m_tbAllServerData[#m_tbAllServerData]
		else
			return nil
		end
	end
end


-- 获取最近选择的服务器
function getRecentServerList()
	local recentGroup = fnRecentServerGroup()
	if(recentGroup == nil or recentGroup == "") then
		return nil
	else
		local recentGroupTable = string.split(recentGroup, ",")
		local recentServer = {}
		for k1,groupId in pairs(recentGroupTable) do
			for k2,v in pairs(m_tbAllServerData) do
				if(v.group and v.group == groupId) then
					table.insert(recentServer, v)
				end
			end
		end
		return recentServer
	end
end


-- 添加一个最近选择的服务器
function addRecentServerGroup(server_group)
	local recentGroup = fnRecentServerGroup()
	if(recentGroup == nil or recentGroup == "") then
		--第一次添加
		fnRecentServerGroup(server_group)
		m_userDefault:flush()
	else
		local recentGroupTable = string.split(recentGroup, ",")
		for k,v in pairs(recentGroupTable) do
			if(server_group == v) then
				return
			end
		end
		fnRecentServerGroup(recentGroup .. "," .. server_group)
		m_userDefault:flush()
	end
end


function getLastLoginServer( )
	if(m_tbAllServerData == nil) then
		return nil
	end

	local lastLoginGroup = Platform.getLastLoginGroup()
	logger:debug("NewLoginCtrl-getLastLoginServer:lastLoginGroup = %s", lastLoginGroup)

	for k,v in pairs(m_tbAllServerData) do
		if(lastLoginGroup == v.group) then
			logger:debug("return v = %s", v)
			return v
		end
	end
	return nil
end


local function getList( sender, res )
	if(res:getResponseCode()==200)then
		m_ExpCollect:finish("askServerList")

		local cjson = require "cjson"
		local results = cjson.decode(res:getResponseData())
		Logger.debug("getList-jsonResults = %s", results)


		-- zhangqi, 2014-12-15, web端返回的root.item是一个字典，需要按key降序排序后转成一个array型的table
		m_tbAllServerData = {}
		local allServerKey = table.allKeys(results.root.item)
		table.sort(allServerKey, function ( a, b )
			return tonumber(a) > tonumber(b)
		end)
		for _, key in ipairs(allServerKey) do
			table.insert(m_tbAllServerData,results.root.item[key])
		end
		Logger.debug("getList-m_tbAllServerData = %s", m_tbAllServerData)

		m_selectServer = getSelectServerInfo()
		copy2gServerInfo(m_selectServer)

		layMain = NewLoginView.create( tbEvent, m_selectServer )
		LayerManager.changeModule( layMain, NewLoginView.moduleName(), {}, true)

		-- 如果有进入游戏公告则显示
		local tbNotices = results.root.notice
		if (tbNotices and tbNotices.open and tonumber(tbNotices.open) > 0) then
			require "script/module/login/LoginNoticeView"
			local layNotice = LoginNoticeView.create()
			LayerManager.addLayout(layNotice)

			local strDesc = tbNotices.desc
			local tbOneOld = string.split(strDesc, "|")
			local tbInfo = {}

			tbInfo.colorT = string.split(tbOneOld[1], ",")
			tbInfo.colorW = string.split(tbOneOld[3], ",")
			tbInfo.title = tbOneOld[2]
			tbInfo.word = tbOneOld[4]

			LoginNoticeView.addAnnounce(tbInfo)
		end

		if( Platform.isPlatform() ) then
			logger:debug("NewLoginCtrl.getList: Platform.login")
			Platform.login()
		end
	else
		m_ExpCollect:info("askServerList", "responseCode = " .. tostring(res:getResponseCode()))
		local alert = UIHelper.createVersionCheckFailed(m_i18n[1987], m_i18n[1985], function ( ... )
			LayerManager.removeNetworkDlg()
			LoginHelper.loginAgain() -- 服务器列表拉取错误提示重试就重头执行登陆流程
		end)
		LayerManager.addNetworkDlg(alert)
	end

end


local function askServerList( ... )
	local url = Platform.getServerListUrl()
	m_ExpCollect:start("askServerList", "url = " .. url)
	local request = LuaHttpRequest:newRequest()
	request:setRequestType(CCHttpRequest.kHttpGet)
	request:setUrl(url)
	request:setResponseScriptFunc(getList)
	CCHttpClient:getInstance():send(request)
	request:release()
end

function beginLoginGame( ... )
	local pid = Platform.getPid()
	if (pid and pid ~= "") then
		Platform.setLastLoginGroup(m_selectServer.group)
		m_userDefault:flush()
		addRecentServerGroup(m_selectServer.group)

		LoginHelper.loginGame()
	else
		if (Platform.isLogin()) then -- 如果平台账户已登录，可能pid信息还没从web端返回，提示重试
			local tbArgs = {strText = m_i18n[2829], nBtn = 2}
			LayerManager.addLayout(UIHelper.createCommonDlgNew(tbArgs))
		else
			Platform.login() -- 平台帐号没有登陆
		end
	end
end
--提前加载一些资源 liweidong
function beginLoadRecource()
	local temp = g_fnLoadUI("ui/home_menu.json")
	temp = g_fnLoadUI("ui/home_information.json")
	temp = g_fnLoadUI("ui/home_new_pmd.json")
	temp = g_fnLoadUI("ui/home_main.json")
	temp = g_fnLoadUI("ui/public_gonggao.json")

	local aniBird = UIHelper.createArmatureNode({
		filePath = "images/effect/home/zhujiemian_niao.ExportJson",
		animationName = "zhujiemian_niao",
	})
	
	--船动画
	local file_Path = "images/effect/home/zhujiemian_ship.ExportJson"
	local animation_Name = "zhujiemian_ship"
	local aniShip = UIHelper.createArmatureNode({
		filePath = file_Path,
	})
	file_Path = "images/effect/home/zhujiemian_ship2.ExportJson"
	local aniShip = UIHelper.createArmatureNode({
		filePath = file_Path,
	})
	
	require "script/module/upgrade/MainUpgradeCtrl"
	require "script/module/public/ItemUtil"
	require "script/module/copy/MainCopy"
	require "script/module/main/MainScene"

	require "script/network/PreRequest"
	require "script/network/RequestCenter"
	require "script/model/hero/HeroModel"
	require "script/network/user/UserHandler"

	require "script/model/user/UserModel"
	require "script/module/login/NewGuyHelper"
	require "script/module/login/UserNameCtrl"

	require "script/network/Network"
	require "script/utils/LuaUtil"

	require "script/module/main/TopBar"
	require "script/utils/NotificationUtil"
	require "script/module/guide/GuideModel"
	require "script/module/guide/GuideCtrl"
	require "script/module/guide/GuideTreasView"
	require "script/module/switch/SwitchModel"

	require "script/module/copy/ExplorMainCtrl"
	require "script/module/astrology/MainAstrologyModel"

	require "script/module/grabTreasure/TreasureData"
	require "script/module/rewardCenter/RewardCenterModel"
	require "script/module/achieve/AchieveModel"
	require "script/module/dailyTask/MainDailyTaskData"
	require "script/module/levelReward/LevelRewardCtrl"
	require "script/module/wonderfulActivity/supply/SupplyModel"
	require "script/module/wonderfulActivity/mysteryCastle/MysteryCastleData"
	require "script/model/utils/ActivityConfigUtil"
	require "script/model/utils/ActivityConfig"
	require "script/module/WorldBoss/WorldBossModel"
	require "script/module/friends/staminaFdsCtrl"
	require "script/module/friends/MainFdsCtrl"
	require "script/module/friends/FriendsApplyCtrl"
	require "script/model/DataCache"
	require "db/DB_Online_reward"
	-- require "script/module/partner/HeroFightUtil"
	require "script/module/login/LoginHelper"
end

function create(...)
	-- 2013-03-11, 平台统计需求，进入选服主页面
	if (Platform.isPlatform()) then
		Platform.sendInformationToPlatform(Platform.kComeInMainLayer)
	end

	AudioHelper.initAudioInfo()
	AudioHelper.playSceneMusic("denglu.mp3")

	tbEvent = {}

	tbEvent.onChoose = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			require "script/module/login/ServerListCtrl"
			local recentServerList = getRecentServerList()
			LayerManager.addLayout(ServerListCtrl.create(m_tbAllServerData, recentServerList))
		end
	end

	tbEvent.onLogin = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playEnter()
			print("begin clock0:" ..(os.clock()))
			-- 如果web服务异常就跳过直接显示登陆界面
			if (g_debug_mode and g_no_web) then
				local testPid = NewLoginView.getText()
				if (tonumber(testPid) == nil or testPid == "") then
					LayerManager.addLayout(UIHelper.createCommonDlg("必须输入数字的pid号才能进入游戏"))
					return
				end
				LoginHelper.debugUID(testPid)
				LoginHelper.loginGame()
				return
			end

			copy2gServerInfo(m_selectServer) -- 复制选中服的信息到全局变量

			if (Platform.isPlatform()) then
				beginLoginGame()
			else
				local group = m_selectServer.group
				-- local group = g_debug_mode and "-- 策划服" or m_selectServer.group
				Platform.setLastLoginGroup(group)
				m_userDefault:flush()
				addRecentServerGroup(group)

				local testPid = NewLoginView.getText()
				if (tonumber(testPid) == nil or testPid == "") then
					LayerManager.addLayout(UIHelper.createCommonDlg("必须输入数字的pid号才能进入游戏"))
					return
				end
				LoginHelper.debugUID(testPid)
				LoginHelper.loginGame()
			end
		end
	end

	if (g_debug_mode) then
		if (g_no_web) then
			layMain = NewLoginView.create( tbEvent, {hot = 1, name = "-- 策划服"} )
			LayerManager.changeModule( layMain, NewLoginView.moduleName(), {}, true)
		else
			askServerList()
		end
	else
		askServerList()
	end
	-- beginLoadRecource()
	-- performWithDelay(layMain,beginLoadRecource,0.01) --liweidong
end

