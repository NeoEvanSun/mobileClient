-- FileName: ConfigMainCtrl.lua
-- Author: menghao
-- Date: 2014-06-08
-- Purpose: 系统设置ctrl


module("ConfigMainCtrl", package.seeall)


require "script/module/config/ConfigMainView"
require "script/module/config/AnnounceCtrl"


-- UI控件引用变量 --


-- 模块局部变量 --


local function init(...)

end


function destroy(...)
	package.loaded["ConfigMainCtrl"] = nil
end


function moduleName()
	return "ConfigMainCtrl"
end


function create(...)
	local tbEvent = {}

	tbEvent.onMusic = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			local flag = AudioHelper.isMusicOn()
			AudioHelper.setMusic(not flag)
			ConfigMainView.switchBtnMusicByStatus(not flag)
		end
	end

	tbEvent.onEffect = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			local flag = AudioHelper.isEffectOn()
			AudioHelper.setEffect(not flag)
			ConfigMainView.switchBtnEffectByStatus(not flag)
		end
	end

	tbEvent.onAnnounce = function ( sender, eventType )
		if (eventType == TOUCH_EVENT_ENDED) then
			AudioHelper.playCommonEffect()
			AnnounceCtrl.create()
		end
	end

	local tbInfo = {}

	tbInfo.musicOn = AudioHelper.isMusicOn()
	tbInfo.effectOn = AudioHelper.isEffectOn()

	local layMain = ConfigMainView.create(tbEvent, tbInfo)
	return layMain
end

