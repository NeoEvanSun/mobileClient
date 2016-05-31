-- FileName: SwitchModel.lua
-- Author: huxiaozhou
-- Date: 2014-06-06
-- Purpose: function description of module
--[[TODO List]]
-- 功能节点的数据模块

module("SwitchModel", package.seeall)

local _switchCache 		= nil	-- 功能节点开启信息

------------------------------功能节点开启信息----------------------------
-- 设置功能节点开启信息
function saveSwitchCache( cache_info )
	_switchCache = cache_info
end

--打开功能节点
function addNewSwitchNode( switchNodeId )
	table.insert(_switchCache, tonumber(switchNodeId))
end

--查看功能节点是否开启
-- switchEnmu:功能节点的枚举值，在GlobalVars.lua中查看列表
-- isShow: 是否显示提示框 默认为不显示 false 是不显示
-- return: true 开启 false 关闭
function getSwitchOpenState( switchEnmu, _isShow )
	for k,v in pairs(_switchCache) do
		if(tonumber(v) == switchEnmu) then
			return true
		end
	end
	local isShow = _isShow or false
	if(isShow == true) then
		require "db/DB_Switch"
		local switchInfo = DB_Switch.getDataById(switchEnmu)
		local param = nil
		if(switchInfo.level ~= nil) then
			param = switchInfo.level
		elseif(switchInfo.copyId ~= nil) then
			require "db/DB_Stronghold"
			local strongInfo = DB_Stronghold.getDataById(switchInfo.copyId)
			param = strongInfo.name
		else
			param = switchInfo.explore_times
		end
		local desc = string.gsub(switchInfo.desc, "xx", param)
		require "script/module/public/ShowNotice"
		ShowNotice.showShellInfo(desc)
	end
	return false
end
