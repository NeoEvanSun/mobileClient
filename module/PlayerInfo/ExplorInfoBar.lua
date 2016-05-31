-- FileName: ExplorInfoBar.lua
-- Author: zhangqi
-- Date: 2015-04-29
-- Purpose: 探索模块玩家信息UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

ExplorInfoBar = class("ExplorInfoBar", PlayerInfoBar)

function ExplorInfoBar:destroy( ... )
	logger:debug("ExplorInfoBar:destroy")
end

function ExplorInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/easy_info_exp.json")

	self:update()
end

function ExplorInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_BELLY:setText(self:unitBelly(userInfo.silver_num))
	-- layMain.TFD_BELLY:setText(userInfo.silver_num)

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(layMain.TFD_LEVEL, self.m_i18nString(4366, userInfo.level), self.m_cStroke)

	self:setExpTFD(layMain.LOAD_EXP, layMain.TFD_EXP_NUM, layMain.TFD_EXP_NUM3)

end
