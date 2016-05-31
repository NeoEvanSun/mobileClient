-- FileName: ACopyInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 活动副本模块玩家信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

ACopyInfoBar = class("ACopyInfoBar", PlayerInfoBar)

function ACopyInfoBar:destroy( ... )
	logger:debug("ACopyInfoBar:destroy")
end

function ACopyInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/public_power.json")

	self:update()
end

function ACopyInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	layMain.TFD_SILVER_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(self.layMain.TFD_POWER_TXT, self.m_i18n[1922], self.m_cStroke)
	layMain.TFD_PHYSICAL:setText(userInfo.execution .. "/" .. self.m_nPowerMax)
end
