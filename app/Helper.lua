---
-- @type Helper
Helper = {}

Helper.pkgVer = "1.0.0"
Helper.resVer = "1.0.0"
---
-- 将string分隔成数组
-- @function [parent=#Helper] splitBy
-- @param #string s
-- @param #string pattern
-- @return #table
function Helper.splitBy(s, pattern)
	local ret = {}
	for token in string.gmatch(s,pattern)do
		ret[#ret+1] = token
	end

	return ret
end

---
-- 比较两个版本的大小
-- @function [parent=#Helper] compareVersion
-- @param #string v1
-- @param #string v2
-- @return #boolean true表示v1比v2大
-- bug fix, zhangqi, 2015-03-19, 避免因传入参数前后顺序不同导致的误判，原方法判断("3.1.0", "3.0.8"):true 和 ("3.0.8", "3.1.0"):true 
function Helper.compareVersion(v1, v2)
	v1 = Helper.splitBy(v1, "[^%.]+")
	v2 = Helper.splitBy(v2, "[^%.]+")
	if #v1 ~= #v2 then
		Logger.fatal("version1:%s, version2:%s not same type", v1, v2)
		return nil
	end

	for i = 1, #v1 do
		if tonumber(v1[i]) > tonumber(v2[i]) then
			return true
		elseif tonumber(v1[i]) < tonumber(v2[i]) then -- 2015-03-19，bug fix
			return false
		end
	end

	return false
end

function Helper.UpdateHistory( ... )
	-- 读历史更新列表
	package.loaded[g_ExtUpdateHistory] = nil
	local statH, upHistory = pcall(function () return require(g_ExtUpdateHistory) end) -- 保护模式读取外部的更新历史列表

	-- 读本次更新列表
	local fileCurrent = string.format("%s%s/%s/UpdateLists", g_ResPath, g_ProjName, g_ResRoot)
	package.loaded[fileCurrent] = nil -- 如果一次更新多个包，则每次require前都需要显示的释放一下，否则无法正确加载
	local statCur, upCurrent = pcall(function () return require(fileCurrent) end)
	if (not statCur) then
		Logger.warning("update %s.lua error", fileCurrent)
		return false
	end
	Logger.debug("saveUpdateHistory upCurrent = %s", upCurrent)

	if (not statH) then -- 如果更新历史列表不存在，直接用本次更新列表覆盖
		local sfile, dfile = fileCurrent .. ".lua", g_ExtUpdateHistory .. ".lua"
		local ret = GameUtil:rename(sfile, dfile)
		if ret ~= 0 then
			Logger.warning("rename file:%s to %s failed", sfile, dfile)
		end
		return ret == 0
	end
	Logger.debug("saveUpdateHistory upHistory = %s", upHistory)

	-- 依据本次更新列表，刷新历史列表
	for path, ver in pairs(upCurrent) do
		Logger.debug("file = %s, cur.ver = %s, h.ver = %s", path, ver, tostring(upHistory[path]))
		-- 历史更新不包含本次更新的某个文件 或者 某个文件本次更新比历史更新版本高，则刷新历史记录
		if (not upHistory[path] or Helper.compareVersion(ver, upHistory[path])) then 
			upHistory[path] = ver
		end
	end
	Logger.debug("saveUpdateHistory upHistory2 = %s", upHistory)

	Helper.saveUpdateHistory(upHistory)
	Util.removeDir(fileCurrent .. ".lua")
end

-- zhangqi, 2014-12-10
-- 每次在线更新后，将本次更新列表和历史更新列表做对比，将本次更新的列表和历史更新和并，然后重写回历史更新文件
function Helper.saveUpdateHistory( tbUpHistory )
	local file = io.open(g_ExtUpdateHistory .. ".lua", 'w+')
	file:write("local UpdateHistory = {\n")
	for k, v in pairs(tbUpHistory) do
		file:write(string.format('\t["%s"] = "%s",\n', k, v))
	end
	file:write("}\n")
	file:write("return UpdateHistory")
	file:close()

	return true
end

---
-- 保存版本信息
-- @function [parent=#Helper] saveVersion
-- @param #string pkgV表示底包版本号 #string resV表示资源版本号
function Helper.saveVersion(pkgV, resV)
	Helper.setVersion(pkgV, resV)

	local path = CCFileUtils:sharedFileUtils():getWritablePath()
	local segments = {
		g_ProjName, "/Resources", "/script/", -- "/app/"
	}

	for i = 1, #segments do
		path = path .. segments[i]
		if not GameUtil:isDir(path) then
			if not GameUtil:mkdir(path,Util.octal2Decimal("0700")) then
				Logger.warning("mkdir:%s failed", path)
				return
			end
		end
	end

	path = path .. 'version.lua'
	-- local path = string.format("%s%s/%s/version.lua", g_ResPath, g_ProjName, g_ResRoot) -- writablePath/fknpirate/Resources
	local file = io.open(path, 'w+')
	-- file:write(string.format('gVersion="%s"',v))
	--[[
		local version = {package = "1.5.6", script = "1.0.0"}
		return version
	]]
	local content = string.format("local version = {package = \"%s\", script = \"%s\"}\nreturn version", pkgV, resV)
	file:write(content)
	file:close()
end

function Helper.setVersion( pkgV, resV )
	Helper.pkgVer, Helper.resVer = pkgV, resV
	Logger.debug("Helper.pkgVer = %s, Helper.resVer = %s", Helper.pkgVer, Helper.resVer)
end

function Helper.getVersion( ... )
	local ver = require "script/version"
	package.loaded["script/version"] = nil
	
	Logger.debug("read version.lua: pkgVer = %s, resVer = %s", ver.package, ver.script)
	return ver.package, ver.script
	-- return Helper.pkgVer, Helper.resVer
end

---
-- 返回退出游戏的Button事件函数
-- @function [parent=#Helper] onExitGame
-- @param
-- @return #function
function Helper.onExitGame( ... )
	-- zhangqi, 2015-03-31, 允许传入一个参数作为异常检测的action name，以便在玩家选择退出时结束当前异常检测，避免误收集
	local actionName = ...
	Logger.debug("actionName = " .. actionName)
	return  function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					if (actionName) then
						local expCollect = ExceptionCollect:getInstance()
						expCollect:finish(actionName)
					end

					CCDirector:sharedDirector():endToLua()
                    os.exit()
				end
			end
end

function Helper.exitGameCallback( ... )
	local actionName = ...
	Logger.debug("actionName = " .. actionName)
	return function ( ... )
		if (actionName) then
			local expCollect = ExceptionCollect:getInstance()
			expCollect:finish(actionName)
		end
					
		CCDirector:sharedDirector():endToLua()
        os.exit()
	end
end

---
-- 返回打开浏览器的Button事件函数
-- @function [parent=#Helper] openExplore
-- @param #string url
-- @return #function
function Helper.openExplore( url )
	return	function ( sender, eventType )
				if (eventType == TOUCH_EVENT_ENDED) then
					PlatformUtil:openUrl(url)
					-- CCDirector:sharedDirector():endToLua()
				end
			end
end
