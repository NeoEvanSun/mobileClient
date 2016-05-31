--游戏中模块的控制器跑马灯

module("MainFightingCtrl", package.seeall)
require "script/module/fighting/MainFightingView"

local function init(...)

end

function destroy(...)
    package.loaded["MainFightingCtrl"] = nil
end

function moduleName()
    return "MainFightingCtrl"
end

function create( ... )
    
    local m_layMain =  MainFightingView.create()
    return m_layMain
end