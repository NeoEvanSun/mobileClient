-- FileName: GameInit.lua
-- Author: zhangqi
-- Date: 2014-09-10
-- Purpose: 游戏的真正入口
--[[TODO List]]

module("GameInit", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --

local function init(...)
	require "db/i18n"
	require "script/GlobalVars"
    require "script/module/login/LoginHelper"
	LoginHelper.initGame()

	-- zhangqi, 2015-03-31, 加入上次异常信息发送到web服务的处理
    -- ExceptionCollect 依赖 logger 和 LuaUtil，需要放在初始化后
	-- require "script/utils/ExceptionCollect"
	-- local expCollect = ExceptionCollect:getInstance()
	-- expCollect:checkLastException()
require "script/module/login/LoginCtrl"
	local loginModule = LoginCtrl.create();
	LayerManager.changeModule(loginModule, LoginCtrl.moduleName(), {}, true)
	-- require "platform/ShowLogoUI"
	-- ShowLogoUI.showLogoUI()   背景音乐
end
init()

function destroy(...)
	package.loaded["GameInit"] = nil
end
