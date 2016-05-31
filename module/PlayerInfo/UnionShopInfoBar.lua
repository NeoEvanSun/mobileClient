-- FileName: UnionShopInfoBar.lua
-- Author: zhangqi
-- Date: 2015-05-05
-- Purpose: 联盟商店玩家信息条UI
--[[TODO List]]

-- 模块局部变量 --
require "script/module/PlayerInfo/PlayerInfoBar"

UnionShopInfoBar = class("UnionShopInfoBar", PlayerInfoBar)

function UnionShopInfoBar:destroy( ... )
	logger:debug("UnionShopInfoBar:destroy")
end

function UnionShopInfoBar:init( ... )
	self.layMain = g_fnLoadUI("ui/union_info_fightforce.json")
	self.layMain:setTouchEnabled(false)
	
	self:update()
end

function UnionShopInfoBar:update( ... )
	local layMain = self.layMain

	local userInfo = self:updateInfo()

	layMain.TFD_ZHANDOULI:setText(self:updateFightNum())

	layMain.TFD_SILVER:setText(self:unitBelly(userInfo.silver_num))

	layMain.TFD_GOLD:setText(userInfo.gold_num)
end