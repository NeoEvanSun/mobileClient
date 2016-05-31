-- FileName: GrabInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-29
-- Purpose: 夺宝模块玩家信息面板UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

GrabInfoBar = class("GrabInfoBar", PlayerInfoBar)

function GrabInfoBar:destroy( ... )
	logger:debug("GrabInfoBar:destroy")
end

function GrabInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/grab_num_info.json")
	self.layMain:setTouchEnabled(false)

	UIHelper.labelAddNewStroke(self.layMain.tfd_grab, self.m_i18n[2461], self.m_cStroke)

	self:update()
end

function GrabInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI_NUM:setText(self:updateFightNum())

	layMain.TFD_SILVER_NUM:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	require "script/module/grabTreasure/TreasureData"
	layMain.TFD_GRAB_NUM:setText(TreasureData.getSeizeNumStr())

end
