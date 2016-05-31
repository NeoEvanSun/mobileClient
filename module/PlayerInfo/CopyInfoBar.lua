-- FileName: CopyInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 副本模块玩家信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

CopyInfoBar = class("CopyInfoBar", PlayerInfoBar)

function CopyInfoBar:destroy( ... )
	logger:debug("CopyInfoBar:destroy")
end

function CopyInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/copy_jingyan.json")

	self:update()
end

function CopyInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	UIHelper.labelAddNewStroke(layMain.TFD_LV, self.m_i18nString(4366, userInfo.level), self.m_cStroke)

	self:setExp(layMain.LOAD_EXP_BAR, layMain.LABN_EXP_NUM, layMain.LABN_EXP_NUM3)

	UIHelper.labelAddNewStroke(layMain.TFD_POWER_TXT, self.m_i18n[1922], self.m_cStroke)
	layMain.LABN_POWER_NUM:setStringValue(userInfo.execution)
	layMain.LABN_POWER_NUM3:setStringValue(self.m_nPowerMax)

	local nPercent = intPercent(tonumber(userInfo.execution), self.m_nPowerMax)
	layMain.LOAD_POWER_BAR:setPercent((nPercent > 100) and 100 or nPercent)
end