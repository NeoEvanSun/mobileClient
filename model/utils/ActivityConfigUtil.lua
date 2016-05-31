-- Filename：	ActivityConfigUtil.lua
-- Author：		lichenyang
-- Date：		2011-1-8
-- Purpose：		活动配置工具类

require "script/model/utils/ActivityConfig"
module("ActivityConfigUtil" , package.seeall)

-- 活动配置持久化文件路径
local persistentFile = CCFileUtils:sharedFileUtils():getWritablePath() .. "ActivityConfig.cfg" 
--[[
	@des	:	处理活动数据，并持久化数据
]]
function process( activity_data )

	--版本对比
	local serverVersion = tonumber(activity_data.version)
	if(serverVersion <= tonumber(ActivityConfig.ConfigCache.version)) then
		return
	end
	ActivityConfig.ConfigCache.version = serverVersion	--更新本地版本

	--添加缓存数据
	for k,v in pairs(activity_data.arrData) do
		ActivityConfig.ConfigCache[tostring(k)] 				= {}
		ActivityConfig.ConfigCache[tostring(k)].version 		= tonumber(v.version)
		ActivityConfig.ConfigCache[tostring(k)].start_time		= tonumber(v.start_time)
		ActivityConfig.ConfigCache[tostring(k)].end_time		= tonumber(v.end_time)
		ActivityConfig.ConfigCache[tostring(k)].need_open_time	= tonumber(v.need_open_time)
		if(v.data ~= nil or v.data ~= "") then
			ActivityConfig.ConfigCache[tostring(k)].data = assemble(ActivityConfig.keyConfig[k], v.data)
		end
	end
	--持久化新配置
	persistentActivity(ActivityConfig.ConfigCache)
end

--[[
	@des	:	把csv生成的数据数据转换成lua的带字符key的table
	@parm	:	keys 键值描述表，datas 数据表csv
	@return	:	table
--]]
function assemble( keys,datas )
	if(keys == nil) then
		return {}
	end

	local assembleLine = function ( keyTable, lineData )
		local rs= {}
		local i = 1
		for k,v in pairs(keyTable) do
			rs[tostring(v)] = lineData[tonumber(i)]
			i = i + 1
		end
		return rs
	end
	require "script/utils/CsvParse"
	local resTable 	= {}
	local luaData 	= CsvParse.parse(datas)
	print("luaData = :")
	print_t(luaData)
	for k,v in pairs(luaData) do
		if(v[1] ~= nil and v[1] ~= "") then
			resTable[tonumber(v[1])] = assembleLine(keys, v)
		else
			break
		end
	end
	return resTable
end

--[[
	@des	:	持久化活动数据
--]]
function persistentActivity( activity_data )
	--删除老的配置文件
	os.execute("rm -rf " .. persistentFile)
	--序列号活动配置数据
	local activityBuffer =  table.serialize(activity_data)
	print("persistentActivity activityBuffer = ", activityBuffer)
	--持久化新活动配置文件
	local file = io.open(persistentFile,"w")
	file:write(activityBuffer)
	file:close()
end

--[[
	@des	:	加载持久化的活动配置文件
--]]
function loadPersitentActivityConfig()

	--判断文件是否存在
	if(CCFileUtils:sharedFileUtils():isFileExist(persistentFile) == false) then
		--读取失败
		print("ActivityConfig file don't find")
		ActivityConfig.ConfigCache.version = 0
		return
	end
	--读取持久化的活动配置
	io.input(persistentFile)
	local activityBuffer = io.read("*all")
	print("loadPersitentActivityConfig activityBuffer:\n", activityBuffer)

	if(activityBuffer == nil or activityBuffer == "") then
		--读取失败
		ActivityConfig.ConfigCache.version = 0
		return
	end
	--加载配置数据
	ActivityConfig.ConfigCache = table.unserialize(activityBuffer)
end


