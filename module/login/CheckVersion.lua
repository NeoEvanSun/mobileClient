-- FileName: CheckVersion.lua
-- Author: zhangqi
-- Date: 2014-06-18
-- Purpose: 在线更新的版本检测逻辑，基于放开那三国的方法
--[[TODO List]]

module("CheckVersion", package.seeall)

-- 模块局部变量 --

local function init(...)

end

function destroy(...)
	package.loaded["CheckVersion"] = nil
end

function moduleName()
	return "CheckVersion"
end

Code_NetWork_Error		= 0 	-- 网络请求出错
Code_WebClient_Error	= -1 	-- Web端出错，返回参数格式不对
Code_Version_Error		= -2 	-- 客户端的脚本版本号不在Web端的DB中
Code_Unkown_ErrorId 	= -3 	-- Web端的返回ErrorId 未知

Code_Update_None		= 1 	-- 无任何更新
Code_Update_Base		= 2 	-- 底包更新
Code_Update_Script		= 3		-- 脚本更新
function getCheckStat(client, response)
	Logger.debug("getCheckStat")

	local versionJsonString = response:getResponseData()
	local retCode = response:getResponseCode()

	local statusCode = Code_NetWork_Error
	local version_info = nil

	if( retCode ~= 200 )then -- -- http 返回错误
		statusCode = Code_NetWork_Error
		Logger.warning("retCode: %d", retCode)
	elseif type(versionJsonString) == "string" and string.len(versionJsonString) > 0 then
		local cjson = require "cjson"
		version_info = cjson.decode(versionJsonString)
		Logger.debug("version_info: %s", version_info)

		if( table.isEmpty(version_info) == true )then -- json 解析错误
			statusCode = Code_WebClient_Error
		else
			Logger.debug(version_info)
			if( version_info.error_id )then
				if(version_info.error_id == 200)then -- 不需要任何更新
					Logger.debug("need not update resources!")
					statusCode = Code_Update_None
				elseif(version_info.error_id == 401)then -- 客户端的脚本版本号不在Web端的DB中 低于Web端的最小scriptVersion
					statusCode = Code_Version_Error
					Logger.debug("客户端的脚本版本号不在Web端的DB中 低于Web端的最小scriptVersion")
				elseif(version_info.error_id == 402)then -- 客户端的脚本版本号不在Web端的DB中 超过了Web端的最大scriptVersion
					statusCode = Code_Version_Error
					Logger.debug("客户端的脚本版本号不在Web端的DB中 超过了Web端的最大scriptVersion")
				else -- Web端的返回ErrorId 未知
					statusCode = Code_Unkown_ErrorId
					Logger.warning("Web端的返回ErrorId 未知")
				end
			elseif( version_info.base and not table.isEmpty(version_info.base) and version_info.base.is_force == 1)then -- 更新底包
				Logger.debug("need update package!")
				statusCode = Code_Update_Base
			elseif(version_info.script and not table.isEmpty(version_info.script)  ) then -- 更新资源
				Logger.debug("need update resources!")
				statusCode = Code_Update_Script
			else -- 其他错误
				statusCode = Code_WebClient_Error
				Logger.debug("error: 请求出错或者 Web端出错，返回参数格式不对 error_id == %d", statusCode)
			end
		end
	else
		-- 返回值为空
		statusCode = Code_WebClient_Error
	end
	return statusCode, version_info
end
