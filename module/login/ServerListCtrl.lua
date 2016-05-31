-- FileName: ServerListCtrl.lua
-- Author: menghao
-- Date: 2014-07-10
-- Purpose: 服务器列表ctrl


module("ServerListCtrl", package.seeall)


require "script/module/login/ServerListView"


-- UI控件引用变量 --


-- 模块局部变量 --


local function init(...)

end


function destroy(...)
	package.loaded["ServerListCtrl"] = nil
end


function moduleName()
	return "ServerListCtrl"
end


function create(tbAllServerData, recentServerList)
	local layMain = ServerListView.create(tbAllServerData, recentServerList)
	return layMain
end

