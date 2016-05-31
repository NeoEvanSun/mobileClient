-- FileName: UpdateLayer.lua
-- Author: zhangqi
-- Date: 2014-06-13
-- Purpose: 启动游戏后的资源更新检查界面
--[[TODO List]]

module("UpdateLayer", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --

local function init(...)

end

function destroy(...)
	package.loaded["UpdateLayer"] = nil
end

function moduleName()
    return "UpdateLayer"
end

function create(...)

end


require "script/GlobalVars"
require "script/module/main/LayerManager"
require "script/module/public/class"

UpdateLayer = class("UpdateLayer")


function UpdateLayer:init()
	-- load UI
	local layMain = Layout:create()
	LayerManager:changeModule(layMain)
	--
end