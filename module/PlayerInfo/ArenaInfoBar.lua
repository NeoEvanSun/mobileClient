-- FileName: ArenaInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 竞技场玩家信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

ArenaInfoBar = class("ArenaInfoBar", PlayerInfoBar)

function ArenaInfoBar:destroy( ... )
	logger:debug("ArenaInfoBar:destroy")
end

function ArenaInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/arena_info.json")
	self.layMain:setTouchEnabled(false)

	self:update()
end

function ArenaInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	layMain.TFD_SILVER_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(layMain.TFD_PRESTIGE_TXT, self.m_i18n[1921], self.m_cStroke)
	layMain.TFD_PRESTAGE_0_1:setText(userInfo.prestige_num)
end