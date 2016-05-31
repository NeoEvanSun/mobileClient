
require "script/module/public/class"
require "script/module/login/CheckVersion"
---
local m_i18n = gi18n
local m_i18nString = gi18nString
local m_fnGetWidget = g_fnGetWidgetByName
local m_ExpCollect = ExceptionCollect:getInstance()

-- 主应用类
-- @type Application
Application = class("Application")

---
-- 基础实例对象
local mInstance = nil

---
-- 获取共享的Application
-- @function [parent=#Application] sharedApplication
-- @return #Application
function Application:sharedApplication()
	if mInstance == nil then
		mInstance = Application.create()
	end
	return mInstance
end

---
-- 创建一个对象
-- @function [parent=#Application] create
-- @return #Application
function Application.create()
	local application = Application.new()

	application.mUpdating = false

	return application
end

function Application:getLastedVersion( ... )
	Logger.debug("g_pkgVer.package:%s, script:%s;", g_pkgVer.package, g_pkgVer.script)
	self.mPkgVersion, self.mResVersion = g_pkgVer.package, g_pkgVer.script

	m_ExpCollect:start("getLastedVersion", 
		string.format("pid = %s, pkgVer = %s, scriptVer = %s", tostring(Platform.getPid() or 0), self.mPkgVersion, self.mResVersion))

	-- 读取外部资源包里的 version 信息
	local resPath = string.format("%s%s/%s", g_ResPath, g_ProjName, g_ResRoot) -- ../fknpirate/Resources
	local function readResVersion( ... )
		local ver = require(resPath .. "/script/version")
		package.loaded[resPath .. "/script/version"] = nil -- 释放已经require的同名模块，避免不退出游戏检测更新时不能重新加载
		return ver
	end
	local stat = nil
	stat, g_resVer = pcall(readResVersion) -- 外部资源包可能不存在，用pcall保证程序不崩溃

	if (stat) then
		Logger.debug("g_resVer.package:%s, script:%s", g_resVer.package, g_resVer.script)

		if (not Helper.compareVersion(g_pkgVer.package, g_resVer.package)) then -- 底包大版本号 <= 外部更新大版本号
			self.mPkgVersion, self.mResVersion = g_resVer.package, g_resVer.script
		else
			if (not Helper.compareVersion(g_pkgVer.script, g_resVer.script)) then -- 底包资源版本号 <= 外部更新资源版本号
				-- 删除外部更新目录下script版本号低于底包script的文件
				package.loaded[g_ExtUpdateHistory] = nil
				local statH, upHistory = pcall(function () return require(g_ExtUpdateHistory) end)
				if (statH) then
					local rmFiles = {}
					local projPath = g_ResPath .. g_ProjName .. "/"
					for filePath, ver in pairs(upHistory) do
						-- 外部更新目录下script版本号 <= 底包script版本号的文件会被删除，避免错误引用
						if (not Helper.compareVersion(ver, g_pkgVer.script)) then
							Logger.debug("getLastedVersion-remove: %s", projPath .. filePath)
							Util.removeDir(projPath .. filePath)
							table.insert(rmFiles, filePath)
						end
					end

					-- 从历史更新列表中删除被删除的文件记录并写回
					for _, filePath in ipairs(rmFiles) do
						upHistory[filePath] = nil
					end
					Helper.saveUpdateHistory(upHistory)

					Helper.saveVersion(g_pkgVer.package, g_resVer.script) -- 将外部更新的大版本号改成和底包相同, 避免下次检查仍进入这个条件分支
					self.mPkgVersion, self.mResVersion = g_pkgVer.package, g_resVer.script
				end
			else
				-- 把外部更新目录删除
				Logger.debug("getLastedVersion-removeDir: %s", g_ResPath .. g_ProjName)
				Util.removeDir(g_ResPath .. g_ProjName) -- ../fknpirate
			end
		end
	else
		Logger.debug("can not found version.lua in update path")
	end

	Logger.debug(string.format("getLastedVersion--self.mPkgVersion:%s, mResVersion:%s", self.mPkgVersion, self.mResVersion))

	m_ExpCollect:finish("getLastedVersion")
end

---
-- 初始化方法
-- @function [parent=#Application] init
-- @param self
function Application:init(bReconnect)
	self.mDownloadUrl = ""
	self.mPkgInfo = nil
	self.mDownloadIdx = 0
	self.mCoDownload = nil
	self.bReconnect = bReconnect or false
	-- self.mUpdated = false

	-- 读取当前的底包和资源包版本号
	logger:debug("Application:init")
	self:getLastedVersion()
	Helper.setVersion(self.mPkgVersion, self.mResVersion)

	if (self.bReconnect) then
		self:checkVersion()
	else
		-- 显示公司logo，安卓上也有需求
		local imgLogo = ImageView:create()
		imgLogo:loadTexture("images/login/logo.png")
		imgLogo:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
		imgLogo:setScale(g_fScaleX) -- 优先屏宽放大
		local layBg = Layout:create()
		layBg:addChild(imgLogo)

		-- 显示资源更新的UI和检查中的提示, zhangqi
	

		local strVersion = string.format("package:%s  res:%s", self.mPkgVersion, self.mResVersion)
		self.mLabelProgress = UIHelper.createUILabel(strVersion, nil, g_FontInfo.size, ccc3(0x00, 0x00, 0x00))
		self.mLabelProgress:setAnchorPoint(ccp(0, 0))
		self.mLabelProgress:setPosition(ccp(10, 10))
		layBg:addChild(self.mLabelProgress)

		LayerManager.changeModule( layBg, "LogoSecond", {}, true)

		-- 暂停1秒发送检查请求
		performWithDelay(tolua.cast(layBg, "CCNode"),
						function () 
							self:checkVersion()
					 	end, 1)
	end
end

---
-- 检查新版本
-- @function [parent=#Application] checkVersion
-- @param self
function Application:checkVersion()
		self:onGetVersion()
	-- -- 读取平台相关信息，组合实际的更新检测请求URL
	-- require "platform/Platform"
	-- local chkUrl = Platform.getCheckVersionUrl( self.mPkgVersion, self.mResVersion )  
	-- logger:debug("version chkUrl:%s", chkUrl)

	-- local request = LuaHttpRequest:newRequest()
	-- request:setRequestType(CCHttpRequest.kHttpGet)
	-- request:setTimeoutForConnect(g_HttpConnTimeout)
	-- request:setUrl(chkUrl)

	-- request:setResponseScriptFunc(function(...)
	-- 	self:onGetVersion(...)
	-- end)

	-- m_ExpCollect:start("checkVersion", string.format("pid = %s chkUrl = %s", tostring(Platform.getPid() or 0), chkUrl))

	-- local httpClient = CCHttpClient:getInstance()
	-- httpClient:send(request)
	-- request:release()
end

-- zhangqi, 2015-01-19, 是否更新的条件改为由参数直接传入，避免可能因为异步调用导致的条件错误等诡异问题
function Application:jumpToLogin( bUpdated )
	-- m_ExpCollect:finish("checkVersion")

	-- 切换到登录页面，zhm
	require "script/module/login/LoginCtrl"
	local loginModule = LoginCtrl.create();
	LayerManager.changeModule(loginModule, LoginCtrl.moduleName(), {}, true)

	-- if (self.bReconnect and (not bUpdated) ) then
	-- 	if (Platform.isPlatform()) then
	-- 		Platform.login()
	-- 	else
	-- 		logger:debug("jumpToLogin: LoginHelper.connectAndLogin")
	-- 		LoginHelper.connectAndLogin()
	-- 	end
	-- else
	-- 	LoginHelper.setReconnectStat(false) -- zhangqi, 2015-01-05, 避免断线重连的更新后无法进入游戏
	-- 	require "script/module/login/NewLoginCtrl"
	-- 	NewLoginCtrl.create()

	-- 	-- zhangqi, 2015-02-10, 以最后一个更新包的 forceExit 为准决定本次更新完成后是否需要强制退出重进游戏
	-- 	if (self.mPkgInfo and self.mPkgInfo[#self.mPkgInfo].forceExit == 1) then
	-- 		local sPrompt = "更新完成，请点确认退出游戏重进！"
	-- 		local alert = UIHelper.createCommonDlg( sPrompt, nil, Helper.onExitGame(), 1, Helper.exitGameCallback() )
	-- 		LayerManager.addSwitchDlg(alert)
	-- 		return
	-- 	end
	-- end
	-- self.bReconnect = false
	-- self.mUpdated = false
end

---
-- @function [parent=#Application] onGetVersion
-- @param self
-- @param CCHttpClient#CCHttpClient client
-- @param LuaHttpResponse#LuaHttpResponse response
function Application:onGetVersion(client, response)
	logger:debug("Application:onGetVersion")
	--self:jumpToLogin() -- 直接进入登录界面

	-- local stat, version_info = CheckVersion.getCheckStat(client, response)

	-- if (stat == CheckVersion.Code_Update_None) then -- 无任何更新
	-- 	self:jumpToLogin() -- 直接进入登录界面
	-- elseif (stat == CheckVersion.Code_Update_Base) then -- 底包更新
	-- 	m_ExpCollect:finish("checkVersion")

	-- 	local sPrompt = "游戏更新了，按确认去下载\n关闭退出游戏"
	-- 	local alert = UIHelper.createCommonDlg( sPrompt, nil,
	-- 		Helper.openExplore(version_info.base.package.packageUrl),
	-- 		1, Helper.exitGameCallback())
	-- 	LayerManager.addLayout(alert)
	-- elseif (stat == CheckVersion.Code_Update_Script) then -- 脚本更新
	-- 	m_ExpCollect:info("checkVersion", "onGetVersion: script updating")

	-- 	-- 删除可能存在的对话、功能开启、新手引导层
	-- 	LayerManager.removeTalkLayer()
	-- 	LayerManager.removeSwitchDlg()
	-- 	LayerManager.removeGuideLayer()

	-- 	require "script/module/update/UpdateView"
	-- 	self.instanceView = UpdateView:new()
	-- 	self.updateView = self.instanceView:create()
	-- 	LayerManager.changeModule( self.updateView, self.instanceView:moduleName(), {}, true)
		
	-- 	self.mPkgInfo = version_info.script

	-- 	-- 计算所有更新包的总大小，单位KB
	-- 	local totalSize = 0
	-- 	for i, pkg in ipairs(self.mPkgInfo) do
	-- 		totalSize = totalSize + pkg.total_size
	-- 	end
	-- 	totalSize = totalSize/1024 -- KB
	-- 	self.mTotalSize = totalSize

	-- 	-- 新的更新提示面板
	-- 	local layPrompt = g_fnLoadUI("ui/regist_update_tip.json")
	-- 	local labTotal = m_fnGetWidget(layPrompt, "TFD_FORCE_2")
	-- 	labTotal:setText(string.format("%.2fKB", totalSize))

	-- 	local i18nText1 = m_fnGetWidget(layPrompt, "TFD_FORCE_1")
	-- 	local i18nText3 = m_fnGetWidget(layPrompt, "TFD_FORCE_3")

	-- 	local btnUpdate = m_fnGetWidget(layPrompt, "BTN_UPDATE")
	-- 	UIHelper.titleShadow(btnUpdate, m_i18n[4201])
	-- 	btnUpdate:addTouchEventListener(function ( sender, eventType )
	-- 		if (eventType == TOUCH_EVENT_ENDED) then
	-- 			 -- 2015-03-05, 点更新按钮后先释放全局定时器，避免更新完成后释放所有被加载模块时因为先后顺序问题可能导致的变量引用错误
	-- 			GlobalScheduler.destroy()

	-- 			self.mUpdater = Updater.create()
	-- 			self.mUpdater:addListener(self)

	-- 			self.mDownloadUrl = Platform.getDownloadHost()
	-- 			m_ExpCollect:info("checkVersion", "DownloadUrl:" .. self.mDownloadUrl)

	-- 			self.mDownloadIdx = 1 -- 当前正在下载的文件索引
	-- 			self:donwloadOnce(self.mDownloadIdx)
	-- 			LayerManager.removeLayout() -- 关闭提示框
	-- 		end
	-- 	end)

	-- 	local btnClose = m_fnGetWidget(layPrompt, "BTN_CLOSE")
	-- 	if (self.mPkgInfo[1].forceUpdate == 0) then -- 以第一个更新包的 forceUpdate 为准决定本次所有更新是否需要强制下载
	-- 		UIHelper.titleShadow(btnClose, m_i18n[4101])
	-- 		btnClose:addTouchEventListener(function ( sender, eventType )
	-- 			if (eventType == TOUCH_EVENT_ENDED) then
	-- 				self:jumpToLogin() -- 非强制更新，直接进入登录界面
	-- 			end
	-- 		end)
	-- 	else
	-- 		UIHelper.titleShadow(btnClose, m_i18n[4202])
	-- 		btnClose:addTouchEventListener(Helper.onExitGame("checkVersion")) -- 2015-03-31
	-- 	end

	-- 	LayerManager.addLayout(layPrompt)
	-- elseif (stat == CheckVersion.Code_NetWork_Error) then -- 网络请求出错
	-- 	m_ExpCollect:info("checkVersion", string.format("stat = %d versionInfo = %s", stat, version_info))

	-- 	if (self.bReconnect) then
	-- 		-- zhangqi, 2015-03-26, 如果是自动重连，则在3次连接失败前继续尝试
	-- 		logger:debug("Appliction:reconnCount = %d", LoginHelper.reconnCount())
	-- 		if (LoginHelper.reconnCount() < g_reconnMax) then
	-- 			local stopSchedule = nil
	-- 			stopSchedule = GlobalScheduler.scheduleFunc(function ( ... ) -- 2秒定时器到时启动重连
	-- 				stopSchedule() -- 停止定时器

	-- 				local count = LoginHelper.reconnCount()
	-- 				LoginHelper.reconnCount(count + 1)
	-- 				logger:debug("Appliction:reconnCount2 = %d", LoginHelper.reconnCount())
	-- 				LoginHelper.reconnect()
	-- 			end, g_reconnInter)
	-- 		else
	-- 			LoginHelper.reconnCount(0) -- 重置自动重连计数
	-- 			LoginHelper.netWorkFailed(true) -- true表示显示断网面板
	-- 		end
	-- 	else
	-- 		local alert = UIHelper.createVersionCheckFailed(m_i18n[1987], m_i18n[1985], function ( ... )
	-- 			if (g_debug_mode and g_no_web) then -- 如果web服务异常直接进入登录界面
	-- 				LayerManager.removeNetworkDlg()
	-- 				self:jumpToLogin()
	-- 				return
	-- 			end

	-- 			LayerManager.removeNetworkDlg()

	-- 			m_ExpCollect:finish("checkVersion")
	-- 			self:checkVersion()
	-- 		end)
	-- 		LayerManager.addNetworkDlg(alert)
	-- 	end
	-- else -- Web端返回数据格式错误或没查到请求的版本号
		self:jumpToLogin() -- 直接进入登录界面
	--end -- end for if (stat == CheckVersion.Code_Update_None) then -- 无任何更新
end

function Application:donwloadOnce(fileIndex)
    local pkg = self.mPkgInfo[fileIndex]
    self.mUpdating = true
    self.mUpdateVersion = pkg.tar_version
    local pkgUrl = string.format("%s/%s/%s/%s.zip", self.mDownloadUrl, pkg.updateType, pkg.path, pkg.tar_version)
    require "platform/Platform"
    if (Platform.isPlatform() and (not g_debug_mode)) then -- 从 http://static.zuiyouxi.com/fkpirate/script/ios/1.0.1.zip 下载
        pkgUrl = string.format("%s/%s/%s/%s.zip", self.mDownloadUrl, pkg.updateType, pkg.os, pkg.file)
    else
        pkgUrl = string.format("%s/%s/%s/%s.zip", self.mDownloadUrl, pkg.updateType, "pirate_test", pkg.file) 
    end
    logger:debug("donwloadOnce, pkgUrl: %s", pkgUrl)

    m_ExpCollect:info("checkVersion", "donwloadOnce: pkgUrl = " .. pkgUrl)

    -- 计算本次下载大概需要的时间   
    local maxDownloadTime = math.ceil(tonumber(pkg.total_size)/g_HttpRateRef)
    logger:debug("maxDownloadTime = %d", maxDownloadTime)
    if (maxDownloadTime < g_HttpReadTimeout) then
        maxDownloadTime = g_HttpReadTimeout
    end

    -- 启动一个更新器
    self.mUpdater:start(pkgUrl, pkg.file .. ".zip", pkg.file, maxDownloadTime) -- url, save_name, md5
end

function Application:onProgress(event)
	local curDownloaded = self.mPkgInfo[self.mDownloadIdx].total_size/1024 * event.percent / 100 -- 当前包已下载的字节数 KB
	local downloaded = 0 -- 之前已下载的所有包的字节数 KB
	for i = 1, self.mDownloadIdx - 1 do
		downloaded = downloaded + self.mPkgInfo[i].total_size
	end
	downloaded = downloaded/1024

	logger:debug("self.mDownloadIdx = %d", self.mDownloadIdx)
	logger:debug("self.mPkgInfo[self.mDownloadIdx].total_size = %d, kb = %d", self.mPkgInfo[self.mDownloadIdx].total_size, self.mPkgInfo[self.mDownloadIdx].total_size/1024)
	logger:debug("event.percent = %d, curDownloaded = %f", event.percent, curDownloaded)
	logger:debug("downloaded = %f", downloaded)

	self.curSize = math.ceil(downloaded + curDownloaded) -- 当前已下载的总字节数
	self.totalPercent = self.curSize/self.mTotalSize * 100
	logger:debug("self.curSize = %f, self.mTotalSize = %d, self.totalPercent = %d", self.curSize, self.mTotalSize, self.totalPercent)
	
	if (event.complete) then
		self.instanceView:updateProcess(self.mTotalSize, self.curSize, self.totalPercent)
		self.instanceView:showUnzipText()

		m_ExpCollect:info("checkVersion", "update complete")

		-- zhangqi, 2015-04-23, 把下载完成切换到登陆界面的处理放在 instanceView:updateProcess 之后，
		-- 避免在onFinished中切换会有几率导致莫名其妙的 instanceView:updateProcess 找不到控件对象 self 的报错
		performWithDelay(
			tolua.cast(LayerManager.getRootLayout(), "CCNode"),
			function ( ... )
				-- zhangqi, 2014-12-27, 清理 CCFileUtils 的路径缓存，避免重新加载文件时加载了非预期的缓存路径中的文件
				CCFileUtils:sharedFileUtils():purgeCachedEntries()
				
				-- 因为后面LayerManager.init会清除scene上所有节点，为了避免加载选服界面之前的黑屏（创建选服UI的时间间隔）
				-- 必须再把更新界面保持一会儿
				self.updateView:retain()
				if (self.updateView:getParent()) then
					self.updateView:removeFromParentAndCleanup(true)
				end
				local layTemp = Layout:create()
				layTemp:addChild(self.updateView)
				self.updateView:release()

				require "script/module/login/LoginHelper"
				LoginHelper.releaseLoadedModule()

				LoginHelper.reloadBaseModule() -- reload base module
				
				GlobalNotify.init()
				LayerManager.init()

				-- LayerManager 重新初始完再把更新界面显示出来，最后change到选服界面时会自动删除更新界面
				LayerManager.addLayoutNoScale(layTemp)
--self:jumpToLogin(true)
				self:jumpToLogin()
			end, 
			0.5 -- 延时0.5秒进入登录界面，留时间看清下载成功正在解压的文字
		) 
	else
		logger:debug("self.curSize1 = %f", self.curSize)
		self.instanceView:updateProcess(self.mTotalSize, self.curSize, self.totalPercent)
	end
end

function Application:onFinished(event)
	self.mUpdating = false
	if event.err ~= "ok" then
		logger:debug("更新第%d个包错误，按确认重试，取消退出游戏", self.mDownloadIdx)
		logger:debug(event.err)

		local alert = UIHelper.createCommonDlg("更新错误，按确认重试，取消退出游戏", nil,
			function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					if (self.mDownloadIdx <= #self.mPkgInfo) then
						self:donwloadOnce(self.mDownloadIdx)
					else
						logger:debug("DownloadIdx:%d > #self.mPkgInfo:%d", self.mDownloadIdx, #self.mPkgInfo)
					end
				end
			end, 2, Helper.exitGameCallback())
		LayerManager.addLayout(alert)
	else
		Helper.saveVersion(self.mPkgVersion, self.mUpdateVersion) -- 保存本次更新的版本
		Helper.UpdateHistory() -- 刷新本地的历史更新列表

		m_ExpCollect:info("checkVersion", "donwloadOnce ok: " .. self.mDownloadIdx)
		self.mDownloadIdx = self.mDownloadIdx + 1
		if (self.mDownloadIdx <= #self.mPkgInfo) then
			self:donwloadOnce(self.mDownloadIdx)
			Logger.debug("正在更新 %d/%d 包", self.mDownloadIdx, #self.mPkgInfo)
			-- UpdateView.updateProcess(self.mDownloadIdx, #self.mPkgInfo, 0)
			logger:debug("self.curSize2 = %d", self.curSize)
			self.instanceView:updateProcess(self.mTotalSize, self.curSize, self.totalPercent)
		else
			Logger.debug("更新完成, 进入登录UI")
			-- zhangqi, 2015-04-23, 为了避免onProgress中百分比检查的误差，手工指定必然可以切换到登陆界面的条件
			self.mDownloadIdx = self.mDownloadIdx - 1
			local event = {complete = true, percent = 100}
			self:onProgress(event)
		end
	end
end

---
-- @function [parent=#Application] start
-- @param self
function Application:start()
	-- 显示欢迎画面
	local scene = CCDirector:sharedDirector():getRunningScene()
	if scene == nil then
		scene = CCScene:create()
		CCDirector:sharedDirector():runWithScene(scene)
	else
		scene:removeAllChildrenWithCleanup(true)
	end

	local sprite = CCSprite:create("Default.png")
	sprite:setAnchorPoint(0, 0)
	sprite:setPosition(0, 0)
	scene:addChild(sprite)

	performWithDelay(scene, function(...)
		self:init()
	end, 0.001)

	performWithDelay(scene, function(...)
		Logger.debug("change layer now")
		local data = {"测试1","测试2"}
		local layer = MainLayer.create(data)
		self:changeLayer(layer)
	end, 1)

	CodeCoverage.sharedCodeCoverage():start()
	MemoryMonitor.sharedMonitor():addListener(self)
end

---
-- @function [parent=#Application] changeLayer
-- @param self
-- @param CCLayer#CCLayer layer
function Application:changeLayer(layer)
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:removeAllChildrenWithCleanup(true)
	scene:addChild(layer)
end

function Application:onLowMemory()
	CCDirector:sharedDirector():purgeCachedData()
end
