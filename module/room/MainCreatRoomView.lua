module("MainCreatRoomView", package.seeall)
 
local activity_list = "n_ui/createroom_1.json"
require "script/model/DataCache"
require "script/network/HttpClient"
local cjson = require "cjson"
local _rules
local m_fnGetWidget = g_fnGetWidgetByName
local _editBoxText  --密码控件
local _moshi =4
local _playRuleIds={}
local cbxs ={}

local function init( ... )
    -- body 
end

function destroy(...)
    package.loaded["MainCreatRoomView"] = nil
end

function moduleName()
    return "MainCreatRoomView"
end
function getRules()
    local index = 1
    for i = 1, #_rules["rules"] do 
        local rule = _rules["rules"][i]
        local cbx = cbxs[i]
        if cbx:getSelectedState() then
            _playRuleIds[index] = rule.rule_id
            index = index + 1
        end      
    end  
    return _playRuleIds
end

function getPassWord( ... )
    return _editBoxText:getText()
end
function getMoshi( ... )
    return _moshi
end

function initListView( lsvRule ,_cell)
    local nIdx, cell = 0, _cell
 --   print("wwwwww" .. _rules["rules"])
 --   local rules = cjson.decode(_rules["rules"])
    
    for i, rule in ipairs(_rules["rules"]) do
        
        lsvRule:pushBackDefaultItem()
        nIdx = i - 1
        cell = lsvRule:getItem(nIdx)  -- cell 索引从 0 开始
        
        local name = m_fnGetWidget(cell, "tfd_name") --  
        UIHelper.labelEffect(name, rule.rule_name)
        name:setFontName(g_sFontName)
        local cbx = m_fnGetWidget(cell, "CBX_SURE") -- 
        cbx:setSelectedState(false)
        table.insert(cbxs,cbx)
    end
   
end
-- 显示登陆场景
function createView(tbEvent)
    local layBack = g_fnLoadUI(activity_list)
    local imgBack = m_fnGetWidget(layBack,"img_back")
 	local sure = m_fnGetWidget(layBack,"btn_sure") 
    local tfdMoshi = m_fnGetWidget(layBack,"tfd_moshi")
    local tfdChoose = m_fnGetWidget(layBack,"tfd_choose")
    local tfdPssWord = m_fnGetWidget(layBack,"tfd_password")
    local btnSiquan = m_fnGetWidget(layBack,"btn_siquan")
    local btnBaquan = m_fnGetWidget(layBack,"btn_baquan")
    local code = m_fnGetWidget(layBack,"img_input_pw")
    local lsvRule = m_fnGetWidget(layBack, "lsv_rules")
    local cell = m_fnGetWidget(layBack, "lay_item")
    local layChoose = m_fnGetWidget(layBack,"lay_choose")
    code:setAnchorPoint(ccp(0, 0.5))
    local size = code:getSize()
    _editBoxText = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    _editBoxText:setAnchorPoint(ccp(0, 0.5))
    _editBoxText:setPlaceHolder("输入密码") 
    _editBoxText:setInputFlag(kEditBoxInputFlagPassword)
    _editBoxText:setReturnType(kKeyboardReturnTypeDone)
    _editBoxText:setTouchPriority(g_tbTouchPriority.editbox)
    code:addNode(_editBoxText )
    tfdMoshi:setText("房间模式")
    tfdMoshi:setFontName(g_sFontName)
    tfdChoose:setText("选择玩法")
    tfdChoose:setFontName(g_sFontName)
    tfdPssWord:setText("房间密码")
    tfdPssWord:setFontName(g_sFontName)
  --  btnSiquan:setTitleText("四圈")
    UIHelper.titleShadow(btnSiquan,"四圈")
    btnSiquan:setTitleFontName(g_sFontName)
   -- btnBaquan:setTitleText("八圈")
    UIHelper.titleShadow(btnBaquan,"八圈")
    btnBaquan:setTitleFontName(g_sFontName) 
    sure:setTitleFontName(g_sFontName)
   -- sure:setTitleText("确认创建")
     UIHelper.titleShadow(sure,"确认创建")
    btnSiquan:addTouchEventListener(function ( sender, eventType)
                                            if (eventType == TOUCH_EVENT_ENDED) then
                                                AudioHelper.playCommonEffect()
                                                _moshi = 4
                                               btnSiquan:loadTextureNormal("n_ui/sign_bg_special.png")
                                               btnBaquan:loadTextureNormal("n_ui/king_photo_bg_normal.png")
                                            end
                                    end)
    btnBaquan:addTouchEventListener(function ( sender, eventType)
                                            if (eventType == TOUCH_EVENT_ENDED) then
                                                AudioHelper.playCommonEffect()
                                                _moshi = 8
                                               btnBaquan:loadTextureNormal("n_ui/sign_bg_special.png")
                                               btnSiquan:loadTextureNormal("n_ui/king_photo_bg_normal.png")
                                            end
                                    end)

    UIHelper.initListView(lsvRule)
  --  lsvRule:setViewSize(CCSizeMake(layChoose:getContentSize().width, layChoose:getContentSize().height)) updateInnerContainerSize
    imgBack:addTouchEventListener(function ( sender, eventType ) 
        
    end)

  --  UIHelper.reloadListView(lsvRule,#_rules,updateCellByIdex) getContentSize().width 
    initListView(lsvRule,cell)
    lsvRule:setInnerContainerSize(CCSizeMake(layChoose:getContentSize().width, layChoose:getContentSize().height))
    lsvRule:setClippingEnabled(true)  
    sure:addTouchEventListener(tbEvent.sure)
    layBack:addTouchEventListener(tbEvent.close)
    LayerManager.addLayout(layBack,nil,g_tbTouchPriority.popDlg)
     
end

function create(tbEvent)
    
    local rules = DataCache.getRules().rules
    if rules ~= nil then
         _rules = rules
        createView(tbEvent)
    else
        HttpClient.get(function ( sender, res)
                local cjson = require "cjson"
              
                local jsonInfo = cjson.decode(res:getResponseData()) 
                DataCache.setRules(jsonInfo)
                _rules = jsonInfo
                createView(tbEvent)
            end,"ref/get_refresh_info")
    end
end