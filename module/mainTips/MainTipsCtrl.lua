module("MainTipsCtrl", package.seeall)
require "script/module/mainTips/MainTipsView.lua"
-- 按钮事件
local tbBtnEvent = {}
local m_curAct
local m_layMain 
local function init(...)

end

function destroy(...)
    package.loaded["MainTipsCtrl"] = nil
end

function moduleName()
    return "MainTipsCtrl"
end
 
function create( ... ) 
    
    m_layMain =  MainTipsView.create()
    return m_layMain
end
--添加到 MainView上
function addLayChild( child )
	if (child ~= nil) then
		if(m_curAct ~= nil) then
			m_curAct:removeFromParent()
			m_curAct = nil
			m_curAct = child
  			m_layMain:addChild(m_curAct,0) 
  		else 
  			m_curAct = child
  			m_layMain:addChild(m_curAct,0) 
  		end
 
	end

end
