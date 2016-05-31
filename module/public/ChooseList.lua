-- FileName: ChooseList.lua
-- Author: zhangqi
-- Date: 14-5-25 
-- Purpose: 各种选择列表（伙伴，宝物），和更换选择列表（伙伴，装备，宝物）的基类
--[[TODOLIST
]]

require "script/GlobalVars"
require "script/module/public/HZListView"
require "script/module/public/class"

local m_i18n = gi18n
local m_i18nString = gi18nString
local m_fnGetWidget = g_fnGetWidgetByName

----------------------------- 定义类 ChooseList, 加载一次公用UI的json文件 -----------------------------
ChooseList = class("ChooseList")

CHOOSELIST = {
    PARTNER = "images/common/title_choose_shadow.png",
    TREASURE = "images/common/title_choose_treasure.png",
    LITTLE = "images/common/title_choose_small_partner.png",
    
    LOADEQUIP = "images/common/change_hero_equip.png",
    LOADPARTNER = "images/common/title_choose_partner.png",
    LOADTREASURE = "images/common/change_treasure.png",
    LOADCONCH = "images/common/title_wear_conch.png",
}

function ChooseList:ctor(...)
    self.MainTemp = g_fnLoadUI("ui/choose_common.json")
    self.ChooseTemp = g_fnLoadUI("ui/choose_common_bottom.json")
    GUIReader:purge() -- 加载完释放Reader
end

--[[
tbInfo = { sType = CHOOSELIST.PARTNER, onBack = func,
           tbState = {sChoose = "已经选择伙伴", sChooseNum = 0, sExp = "获得经验", sExpNum = "0", onOk = func},
           tbView = {szCell = CCSize, tbDataSource = table_array,
                     CellAtIndexCallback = func, CellTouchedCallback = func, didScrollCallback = func, didZoomCallback = func}
}
--]]
function ChooseList:create(tbInfo)
    local imgTitle = m_fnGetWidget(self.MainTemp, "IMG_CHOOSE_COMMON_TITLE_BG")
    imgTitle:loadTexture(tbInfo.sType)

    local imgTitleBg = m_fnGetWidget(self.MainTemp, "img_title_bg")
    imgTitleBg:setScale(g_fScaleX)

    local imgBg = m_fnGetWidget(self.MainTemp, "img_bg")
    imgBg:setScale(g_fScaleX)
    
    local btnBack = m_fnGetWidget(self.MainTemp, "BTN_BACK")
    UIHelper.titleShadow(btnBack, m_i18nString(1611, "  "))
    btnBack:addTouchEventListener(tbInfo.onBack)
    
    if (tbInfo.sType == CHOOSELIST.PARTNER or
        tbInfo.sType == CHOOSELIST.TREASURE)
    then -- 是选择列表，添加底部状态面板
        self.MainTemp:addChild(self.ChooseTemp)
         -- tbState = {sChoose = "已经选择伙伴", sChooseNum = 0, sExp = "获得经验", sExpNum = "0", onOk = func}
        self:initChooseState(tbInfo.tbState)
    end
    
    -- 初始化HZTableView
    local viewCfg = tbInfo.tbView
    if (viewCfg and #viewCfg.tbDataSource > 0) then
        local layList = m_fnGetWidget(self.MainTemp, "lay_choose")
        local szView = layList:getSize()
        viewCfg.szView = CCSizeMake(szView.width, szView.height) -- 给创建TableView的数据表加上szView字段
        
        self.objView = HZListView:new()
        if (self.objView:init(viewCfg)) then
            local hzLayout = TableViewLayout:create(self.objView:getView())
            layList:addChild(hzLayout)
            -- layList:addNode(self.objView:getView())
            self.objView:refresh()
        end
    end
    
    return self.MainTemp
end

function ChooseList:initChooseState(tbData)
    local i18nChoose = m_fnGetWidget(self.ChooseTemp, "TFD_CHOOSE_TXT")
    i18nChoose:setText(tbData.sChoose)
    
    local i18nExp = m_fnGetWidget(self.ChooseTemp, "tfd_choose_getexp_txt")
    i18nExp:setText(tbData.sExp)

    local imgBg = m_fnGetWidget(self.ChooseTemp, "img_sell_bottom_bg")
    imgBg:setScale(g_fScaleX) -- 2015-04-29
    
    local btnOk = m_fnGetWidget(self.ChooseTemp, "BTN_SURE")
    UIHelper.titleShadow(btnOk, m_i18n[1324])
    btnOk:addTouchEventListener(tbData.onOk)
    
    self:refreshChooseStateNum(tbData)
end

function ChooseList:refreshChooseStateNum(tbData)
    self.labChooseNum = m_fnGetWidget(self.ChooseTemp, "TFD_CHOOSE_NUM")
    self.labChooseNum:setText(tbData.sChooseNum)
    
    self.labExpNum = m_fnGetWidget(self.ChooseTemp, "TFD_GET_EXP_NUM")
    self.labExpNum:setText(tbData.sExpNum)
end
