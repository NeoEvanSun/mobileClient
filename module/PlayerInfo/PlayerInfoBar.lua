-- FileName: PlayerInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-14
-- Purpose: 各种信息条的基类
--[[TODO List]]

local currentBar = nil -- 保存当前信息条对象的引用

-- 调用当前信息条对象的update方法刷新UI显示，主要用于 UserModel 里
function updateInfoBar( ... )
	if (currentBar) then
		currentBar:update()
	end
end

-- ***************************  信息条基类  ***************************

PlayerInfoBar = class("PlayerInfoBar")

function PlayerInfoBar:ctor( ... )
	self.m_nPowerMax = g_maxEnergyNum -- 体力值上限
	self.m_nStaminaMax = UserModel.getMaxStaminaNumber() -- 耐力上限

	self.m_i18n = gi18n
	self.m_i18nString = gi18nString
	self.m_fnGetWidget = g_fnGetWidgetByName

	self.m_cStrok = ccc3(0x28, 0x00, 0x00)
end

function PlayerInfoBar:updateInfo()
	self.m_tbUserInfo = UserModel.getUserInfo()
	return self.m_tbUserInfo
end

function PlayerInfoBar:updateFightNum( ... )
	UserModel.updateFightValue() -- 刷新战斗力
	return UserModel.getFightForceValue()
end

function PlayerInfoBar:create( ... )
	self:init()

	currentBar = self

	local function onExit()
		currentBar = nil
		self:destroy()
	end
	UIHelper.registExitAndEnterCall(tolua.cast(self.layMain, "CCNode"), onExit)

	-- return self.layMain
	layRoot = LayerManager.getRootLayout()
	layRoot:addChild(self.layMain, 2, 2)
end

function PlayerInfoBar:setExp( loadExp, labnMem, labnDomi, isLab )
	if (UserModel.hasReachedMaxLevel()) then -- 经验达到满级
		labnMem:setEnabled(false)
		labnDomi:setEnabled(false)
		loadExp:setPercent(100)
		return
	else
		local imgMax = self.m_fnGetWidget(self.layMain, "IMG_MAX")
		imgMax:setEnabled(false)
	end

	require "db/DB_Level_up_exp"
	local tUpExp = DB_Level_up_exp.getDataById(2)
	local nLevelUpExp = tUpExp["lv_"..(tonumber(self.m_tbUserInfo.level)+1)] -- 下一等级需要的经验值
	local nExpNum = tonumber(self.m_tbUserInfo.exp_num) -- 当前的经验值

	if (isLab) then -- 是 Label
		labnMem:setText(nExpNum)
		labnDomi:setText(nLevelUpExp)
	else
		labnMem:setStringValue(nExpNum)
		labnDomi:setStringValue(nLevelUpExp)
	end

	local nPercent = intPercent(nExpNum, nLevelUpExp)
	loadExp:setPercent((nPercent > 100) and 100 or nPercent)
end

function PlayerInfoBar:setExpTFD( loadExp, labMem, labDomi )
	self:setExp(loadExp, labMem, labDomi, true)
end

function PlayerInfoBar:unitBelly( belly )
	return UIHelper.getBellyStringAndUnit(belly)
end

-- *************************** 必须实现方法 ***************************

function PlayerInfoBar:destroy( ... )
	logger:debug("PlayerInfoBar:destroy")
end

-- 其他子类需要保留Init
function PlayerInfoBar:init( ... )

end

function PlayerInfoBar:update( ... )

end
