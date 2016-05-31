-- FileName: ActivityInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 活动列表模块信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

ActivityInfoBar = class("ActivityInfoBar", PlayerInfoBar)

function ActivityInfoBar:destroy( ... )
	logger:debug("ActivityInfoBar:destroy")
end

function ActivityInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/public_stamina.json")

	self:update()
end

function ActivityInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	layMain.TFD_SILVER_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(self.layMain.TFD_STAMINA_TXT, self.m_i18n[1923], self.m_cStroke)
	layMain.TFD_STAMINA:setText(userInfo.stamina .. "/" .. self.m_nStaminaMax)
end
