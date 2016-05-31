-- FileName: SkyPieaInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-29
-- Purpose: 神秘空岛模块玩家信息面板UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

SkyPieaInfoBar = class("SkyPieaInfoBar", PlayerInfoBar)

function SkyPieaInfoBar:destroy( ... )
	logger:debug("SkyPieaInfoBar:destroy")
end

function SkyPieaInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/air_easy_info.json")
	self.layMain:setTouchEnabled(false)

	UIHelper.labelAddNewStroke(self.layMain.tfd_sky_txt, self.m_i18n[5414], self.m_cStroke)

	self:update()
end

function SkyPieaInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	layMain.TFD_SILVER_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	layMain.TFD_SKY_NUM:setText(UserModel.getSkyPieaBellyNum())
end