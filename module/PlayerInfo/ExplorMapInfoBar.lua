-- FileName: ExplorInfoBar.lua
-- Author: liweidong
-- Date: 2015-05-06
-- Purpose: 探索模块玩家信息UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

ExplorMapInfoBar = class("ExplorMapInfoBar", PlayerInfoBar)

function ExplorMapInfoBar:destroy( ... )
	logger:debug("ExplorMapInfoBar:destroy")
end

function ExplorMapInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/explore_map_info.json")

	self:update()
end

function ExplorMapInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_BELLY:setText(self:unitBelly(userInfo.silver_num))
	-- layMain.TFD_BELLY:setText(userInfo.silver_num)

	layMain.TFD_GOLD_NUM:setText(userInfo.gold_num)

	UIHelper.labelAddNewStroke(layMain.TFD_LEVEL, self.m_i18nString(4366, userInfo.level), self.m_cStroke)

	self:setExpTFD(layMain.LOAD_EXP, layMain.TFD_EXP_NUM, layMain.TFD_EXP_NUM3)

end
