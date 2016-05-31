-- FileName: UserNameCtrl.lua
-- Author: menghao
-- Date: 2014-07-16
-- Purpose: 输入角色名ctrl


module("UserNameCtrl", package.seeall)


require "script/module/login/UserNameView"


-- UI控件引用变量 --


-- 模块局部变量 --


local function init(...)

end


function destroy(...)
	package.loaded["UserNameCtrl"] = nil
end


function moduleName()
	return "UserNameCtrl"
end


function create(isNanSelected)
	local layMain = UserNameView.create(isNanSelected)
	AudioHelper.playSceneMusic("denglu.mp3")
	return layMain
end

