-- FileName: UpdateView.lua
-- Author: zhangqi
-- Date: 2014-08-02
-- Purpose: 资源更新控制模块
--[[TODO List]]
--[[ modified
2015-04-17, 给主画布加上onExit回调方法，释放所有控件引用变量，用于在updateProcess和showUnzipText方法中作为判断条件不刷新UI
]]

-- 模块局部变量 --
local m_i18n = gi18n
local m_i18nString = gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

UpdateView = class("UpdateView")

function UpdateView:ctor()
	self.mLayoutMain = g_fnLoadUI("ui/regist_update.json")

	local function onExit()
		self:destroy()
	end

	UIHelper.registExitAndEnterCall(tolua.cast(self.mLayoutMain, "CCNode"), onExit)
end

function UpdateView:moduleName( ... )
	return "UpdateView"
end

function UpdateView:destroy( ... )
	logger:debug("UpdateView.destroy")
	-- package.loaded["script/module/update/UpdateView"] = nil

	self.mLayoutMain = nil
	self.mLabPercent = nil -- 进度百分比数字
-- local mLoadBar -- 进度
	self.mImgBall = nil -- 进度条上的球图标
	self.mLabByte = nil -- 当前已下载的字节数

	self.m_ccpBall = nil -- 进度船的坐标百分比
	self.m_ccpBallX = nil -- 进度船x坐标百分比
	self.m_szBall = nil -- 进度船的size
	self.m_percentBall = nil -- 进度船实际滑过长度占进度条总长的百分比，用于根据下载百分比换算船当前的坐标百分比
	self.m_ballPercent = nil -- 每次下载回调时进度船的坐标百分比
end

-- UI控件引用变量 --
-- local self.mLayoutMain
-- local self.mLabPercent -- 进度百分比数字
-- -- local mLoadBar -- 进度
-- local self.mImgBall -- 进度条上的球图标
-- local self.mLabByte -- 当前已下载的字节数

-- local self.m_ccpBall -- 进度船的坐标百分比
-- local self.m_ccpBallX -- 进度船x坐标百分比
-- local self.m_szBall -- 进度船的size
-- local self.m_percentBall -- 进度船实际滑过长度占进度条总长的百分比，用于根据下载百分比换算船当前的坐标百分比
-- local self.m_ballPercent -- 每次下载回调时进度船的坐标百分比

function UpdateView:create(...)
	-- self.mLayoutMain = g_fnLoadUI("ui/regist_update.json")

	local imgCloud = m_fnGetWidget(self.mLayoutMain, "img_cloud")
	imgCloud:setScale(g_fScaleX)

	local imgMap = m_fnGetWidget(self.mLayoutMain, "IMG_MAP")

	local imgBG = m_fnGetWidget(self.mLayoutMain, "img_bg")
	local imgLoadBG = m_fnGetWidget(self.mLayoutMain, "img_load_bg")
	local imgMB = m_fnGetWidget(self.mLayoutMain, "IMG_MENGBAN")
	imgBG:setScale(g_fScaleX)
	imgLoadBG:setScale(g_fScaleX)
	imgMB:setScale(g_fScaleX)

	-- mLoadBar = m_fnGetWidget(self.mLayoutMain, "LOAD_BAR") -- 进度条
	-- mLoadBar:setPercent(0)
	-- m_szLoadBar = mLoadBar:getSize()
	self.mImgBall = m_fnGetWidget(self.mLayoutMain, "IMG_PROGRESS_BALL") -- 进度条上的球图标
	self.m_szBall = self.mImgBall:getSize()

	self.m_ccpBall = self.mImgBall:getPositionPercent()
	self.m_ccpBallX = self.m_ccpBall.x
	self.m_percentBall = 1 -- - (self.m_szBall.width/m_szLoadBar.width)

	self.mLabPercent = m_fnGetWidget(self.mImgBall, "TFD_PERCENT") -- 球图标上的气泡的百分比数字
	self.mLabPercent:setText("0%")

	self.mLabByte = m_fnGetWidget(self.mLayoutMain, "TFD_BYTE") -- 进度条下的已下载字节数
	UIHelper.labelShadow(self.mLabByte, CCSizeMake(3, -3))
	self.mLabByte:setEnabled(false)

	return self.mLayoutMain
end

function UpdateView:updateProcess(totalSize, downloadedSize, nPercent )
	if (not self.mLabByte) then
		return
	end

	if (not self.mLabByte:isEnabled()) then
		self.mLabByte:setEnabled(true)
	end
	self.mLabByte:setText(m_i18nString(4205, downloadedSize, totalSize))

	-- mLoadBar:setPercent((nPercent > 100) and 100 or nPercent)

	self.mLabPercent:setText(string.format("%d%%", nPercent))
	self.m_ballPercent = (nPercent/100 * self.m_percentBall + self.m_ccpBallX)
	logger:debug("self.m_ccpBall.x = %f, self.m_percentBall = %f, nPercent = %f, self.m_ballPercent = %f",
		self.m_ccpBallX, self.m_percentBall, nPercent, self.m_ballPercent)
	self.mImgBall:setPositionPercent(ccp(self.m_ballPercent, self.m_ccpBall.y))
end

function UpdateView:showUnzipText( ... )
	if (not self.mLabByte) then
		return
	end

	self.mLabByte:setText(m_i18n[4206])
	-- mLoadBar:setPercent(100)

	logger:debug("self.m_ccpBall.x = %f, self.m_ballPercent = %f", self.m_ccpBallX, self.m_ballPercent)
	self.mImgBall:setPositionPercent(ccp(self.m_ballPercent, self.m_ccpBall.y))
end
