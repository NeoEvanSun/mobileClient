module("MainMessageView", package.seeall)

require "script/model/DataCache"
require "script/network/HttpClient"

local activity_list = "n_ui/shop_1.json"
local cell_list = "n_ui/shopcell_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local cell
local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainMessageView"] = nil
end

function moduleName()
    return "MainMessageView"
end
--初始化数据
function initListView( lsvRule ,_cell)
    local nIdx, cell = 0, _cell
 --   print("wwwwww" .. _rules["rules"])
 --   local rules = cjson.decode(_rules["rules"])
    for i=1,10 do
        lsvRule:pushBackDefaultItem()
        nIdx = i - 1
        cell = lsvRule:getItem(nIdx)  -- cell 索引从 0 开始
    end
     
   
end
function create( tbEvent )
    local layBack = g_fnLoadUI(activity_list)
    
    local layLsv= m_fnGetWidget(layBack,"lay_listview")
    local tfdMes= m_fnGetWidget(layBack,"tfd_message")
    layLsv:setVisible(false)
    tfdMes:setVisible(true)
    layBack:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            LayerManager.removeLayout()
                                            
                                        end
                                  end)
    LayerManager.addLayout(layBack,nil,g_tbTouchPriority.popDlg)
end