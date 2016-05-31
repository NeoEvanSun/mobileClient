-- Filename: main.lua
-- Author: fang
-- Date: 2013-05-17
-- Purpose: 

-- 全局变量，记录底包里的版本信息和外部更新目录下的版本信息
g_pkgVer = {}
g_resVer = {}

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	if (g_debug_mode) then -- 开发模式时才允许输出log
		print("----------------------------------------")
		print("LUA ERROR: " .. tostring(msg) .. "\n")
		print(debug.traceback())
		print("----------------------------------------")
	else
		loggerHttp:fatal(tostring(msg) .."\n"..debug.traceback()) -- zhangqi, 2015-03-30, 如果是线上包，将错误栈信息发送到loggerHttp指定的URL
	end
	
	if (not g_web_env.online) then -- zhangqi, 2015-03-16, 无论什么包连线下环境时允许弹出报错面板
		local debugString = tostring(msg) .. "\n" .. debug.traceback()
		debugString = "开始了错误:" .. debugString .. "错误结束了！"

		require "script/module/public/UIHelper"
		UIHelper.createDebugDlg(tostring(debugString))
	end
end

-- 设置全局的search path，进入游戏逻辑前只设置一次。外部更新目录优先
local function setSearchPath( ... )
	local fileUtil = CCFileUtils:sharedFileUtils()
	local writePath = fileUtil:getWritablePath()
	local resPath = writePath .. "fknpirate/Resources"
	local updateUI = resPath .. "/ui"

	BTUtil:insertToSearchPathBegin(resPath) -- 设置外部资源目录查找优先级最高，底包其次
	fileUtil:addSearchPath(updateUI) -- 外部ui第三，UI编辑器api加载资源需要"ui"的相对路径
	fileUtil:addSearchPath("ui") -- 底包ui最低
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)

	-- 读取底包里的 version 信息
	g_pkgVer = require "script/version"
	package.loaded["script/version"] = nil

	if (not BTUtil:isSimulator()) then
		setSearchPath() -- zhangqi, 2015-01-12, 如果不是模拟器运行才设置正式的资源路径
	end

	require "script/GameInit"
end

xpcall(main, __G__TRACKBACK__)
