module("MainShopCtrl", package.seeall)

local activity_list = "n_ui/shop_1.json"
require "script/model/DataCache"
require "script/module/shop/MainShopView"
-- 按钮事件
local tbBtnEvent = {}
local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainShopCtrl"] = nil
end

function moduleName()
    return "MainShopCtrl"
end

function create(  )
    MainShopView.create(tbBtnEvent)
end