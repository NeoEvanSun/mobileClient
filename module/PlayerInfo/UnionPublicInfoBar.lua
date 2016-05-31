-- FileName: UnionPublicInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 联盟公用的玩家信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

UnionPublicInfoBar = class("UnionPublicInfoBar", PlayerInfoBar)

function UnionPublicInfoBar:destroy( ... )
	logger:debug("UnionPublicInfoBar:destroy")
end

function UnionPublicInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/union_easy_info.json")
	self.layMain:setTouchEnabled(false)
	
	self:update()
end

function UnionPublicInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	UIHelper.labelAddNewStroke(layMain.tfd_contribute, self.m_i18n[3707], self.m_cStroke)

	local guildInfo = GuildDataModel.getMineSigleGuildInfo()
	layMain.TFD_CONTRIBUTION:setText(guildInfo.contri_point)

	layMain.TFD_SILVER:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD:setText(userInfo.gold_num)
end
