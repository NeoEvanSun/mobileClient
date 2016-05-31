-- FileName: PartnerInfoBar.lua
-- Author: liweidong
-- Date: 2015-05-14
-- Purpose: 多个模块公用玩家信息面板UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

PartnerInfoBar = class("PartnerInfoBar", PlayerInfoBar)

function PartnerInfoBar:destroy( ... )
	logger:debug("PartnerInfoBar:destroy")
end

function PartnerInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/public_info_fight.json")

	self:update()
end

function PartnerInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_INFORMATION_BELLY_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_INFORMATION_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(self.layMain.TFD_LEVEL, self.m_i18nString(4366, userInfo.level), self.m_cStroke)

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	self:setExpTFD(layMain.LOAD_EXP, layMain.TFD_EXP_NUM, layMain.TFD_EXP_NUM3)
end