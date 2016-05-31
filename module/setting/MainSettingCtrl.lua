module("MainSettingCtrl", package.seeall)


require "script/model/DataCache"
require "script/module/setting/MainSettingView"
-- 按钮事件
local tbBtnEvent = {}
local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainSettingCtrl"] = nil
end

function moduleName()
    return "MainSettingCtrl"
end

function create(  )
    MainSettingView.create(tbBtnEvent)
end