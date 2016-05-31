module("MainMessageCtrl", package.seeall)

local activity_list = "n_ui/shop_1.json"
require "script/model/DataCache"
require "script/module/message/MainMessageView"
-- 按钮事件
local tbBtnEvent = {}
local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainMessageCtrl"] = nil
end

function moduleName()
    return "MainMessageCtrl"
end

function create(  )
    MainMessageView.create(tbBtnEvent)
end