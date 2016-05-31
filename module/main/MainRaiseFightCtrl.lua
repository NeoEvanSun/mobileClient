-- FileName: MainRaiseFightCtrl.lua
-- Author: zhangqi
-- Date: 2015-01-13
-- Purpose: 提升战斗里的主控模块
--[[TODO List]]

module("MainRaiseFightCtrl", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --

local function init(...)

end

function destroy(...)
	RaiseFightModel.destroy()
	package.loaded["MainRaiseFightCtrl"] = nil
end

function moduleName()
    return "MainRaiseFightCtrl"
end

function create(...)
	require "script/module/main/RaiseFightModel"
	local lists = RaiseFightModel.getRaiseLists()

	require "script/module/main/RaiseFightView"
	local fightView = RaiseFightView:new()
	local layView = fightView:create({raiseList = lists})
	LayerManager.changeModule(layView, MainRaiseFightCtrl.moduleName(), {1, 3}, true)
	PlayerPanel.addForPublic()
end
