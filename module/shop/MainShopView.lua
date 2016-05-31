module("MainShopView", package.seeall)

require "script/model/DataCache"
require "script/network/HttpClient"

local activity_list = "n_ui/shop_1.json"
local cell_list = "n_ui/shopcell_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local cell
local goods
local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainShopView"] = nil
end

function moduleName()
    return "MainShopView"
end
--初始化数据
function initListView( lsvRule ,_cell)
    local nIdx, cell = 0, _cell
 --   print("wwwwww" .. _rules["rules"])
 --   local rules = cjson.decode(_rules["rules"])
  --  for i=1,10 do
    for i, good in ipairs(goods) do
        lsvRule:pushBackDefaultItem()
        nIdx = i - 1
        cell = lsvRule:getItem(nIdx)  -- cell 索引从 0 开始
        local name = m_fnGetWidget(cell, "tfd_good_name") --  
        name:setText(good.productName)
        local desc = m_fnGetWidget(cell, "tfd_good_desc") --  
        desc:setText(good.productDesc)
        local buy = m_fnGetWidget(cell, "btn_buy") --  
        buy:setTitleText(good.productPrice .. "元购买")
    end
     
   
end
function createView( tbEvent )
    local layBack = g_fnLoadUI(activity_list)
    cell          = g_fnLoadUI(cell_list)
    local listview= m_fnGetWidget(layBack,"lsv_goods")
    local layLsv= m_fnGetWidget(layBack,"lay_listview")
    local tfdMes= m_fnGetWidget(layBack,"tfd_message")
    layLsv:setVisible(true)
    tfdMes:setVisible(false)
    cell:setSize(CCSizeMake(800,210))
    listview:setItemModel(cell) -- 设置默认的cell
    listview:removeAllItems() -- 初始化清空列表
   -- UIHelper.initListView(listview)
   -- cell:setPosition(ccp(0,0))
    initListView(listview,cell)
    listview:setInnerContainerSize(CCSizeMake(layLsv:getContentSize().width, layLsv:getContentSize().height))
    listview:setClippingEnabled(true) 

    layBack:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            LayerManager.removeLayout()
                                            
                                        end
                                  end)
    LayerManager.addLayout(layBack,nil,g_tbTouchPriority.popDlg)
end

function create(tbEvent) 
        HttpClient.get(function ( sender, res)
                local cjson = require "cjson"
              
                local jsonInfo = cjson.decode(res:getResponseData()) 
                 
                goods = jsonInfo
                createView(tbEvent)
            end,"pro/getProducts")
 
end