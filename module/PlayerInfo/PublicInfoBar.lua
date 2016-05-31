-- FileName: PublicInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-29
-- Purpose: 多个模块公用玩家信息面板UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

PublicInfoBar = class("PublicInfoBar", PlayerInfoBar)

function PublicInfoBar:destroy( ... )
	logger:debug("PublicInfoBar:destroy")
end

function PublicInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/public_easy_information.json")

	self:update()
end

function PublicInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_INFORMATION_BELLY_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_INFORMATION_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(self.layMain.TFD_LEVEL, self.m_i18nString(4366, userInfo.level), self.m_cStroke)

	layMain.LABN_VIP_LEVEL:setStringValue(userInfo.vip)

	self:setExpTFD(layMain.LOAD_EXP, layMain.TFD_EXP_NUM, layMain.TFD_EXP_NUM3)
end