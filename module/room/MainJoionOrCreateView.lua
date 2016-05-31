module("MainJoionOrCreateView", package.seeall)
 
local activity_list = "n_ui/joinorcreateroom_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local _editBoxText  --房间号
local _editBoxTextPw --房间密码
local inpRoomPw
local function init( ... )
    -- body
end

function destroy(...)
    package.loaded["MainJoionOrCreateView"] = nil
end

function moduleName()
    return "MainJoionOrCreateView"
end
function getInputText( ... )
    return _editBoxText:getText()
end
function getPassWText( ... )
    return _editBoxTextPw:getText()
end
--得到其坐标
function getProcessPos( layout ) 
    local parentNode = layout:getParent() 
    return ccp(layout:getPositionX(),layout:getPositionY())
   -- return parentNode:convertToWorldSpace(ccp(layout:getPositionX(),layout:getPositionY()))
end
local function editboxEventHandler(eventType, sender)
            if eventType == "began" then
                -- triggered when an edit box gains focus after keyboard is shown
                logger:debug("began, text = " .. sender:getText())
            elseif eventType == "ended" then
                -- triggered when an edit box loses focus after keyboard is hidden.
                logger:debug("ended, text = " .. sender:getText())
            elseif eventType == "changed" then
            -- triggered when the edit box text was changed.
            --logger:debug("changed, text = " .. sender:getText())
            elseif eventType == "return" then
                -- triggered when the return button was pressed or the outside area of keyboard was touched.
                logger:debug("return, text = " .. sender:getText())
            end
        end

-- 显示登陆场景
function create(tbEvent)
    local layBack = g_fnLoadUI(activity_list)
    local imgBack = m_fnGetWidget(layBack,"img_back")
    local btnCreateRoom = m_fnGetWidget(layBack,"btn_joinroom")
    local btnCancle = m_fnGetWidget(layBack,"BTN_CANCEL")
    local btnSure = m_fnGetWidget(layBack,"BTN_CONFIRM")
    local code = m_fnGetWidget(layBack,"img_input_code")
    code:setAnchorPoint(ccp(0, 0.5))
    local size = code:getSize()
    _editBoxText = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    _editBoxText:setAnchorPoint(ccp(0, 0.5))
    _editBoxText:setPlaceHolder("输入房间号")
    _editBoxText:setReturnType(kKeyboardReturnTypeDone)
    _editBoxText:setTouchPriority(g_tbTouchPriority.editbox)
    -- _editBoxText:setEnabled(false)
    -- _editBoxText:setTouchEnabled(false)
    code:addNode(_editBoxText )
    --inpRoomPw = m_fnGetWidget(layBack,"INP_PASSWORD")
    _editBoxTextPw = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    _editBoxTextPw:setAnchorPoint(ccp(0, 0.5))
    _editBoxTextPw:setPlaceHolder("输入房间密码")
    _editBoxTextPw:setInputFlag(kEditBoxInputFlagPassword)
    _editBoxTextPw:setReturnType(kKeyboardReturnTypeDone)
    _editBoxTextPw:setTouchPriority(g_tbTouchPriority.editbox)
    -- _editBoxTextPw:setEnabled(false)
    -- _editBoxTextPw:setTouchEnabled(false)
    
    local pw = m_fnGetWidget(layBack,"img_inp_pw")
    pw:setAnchorPoint(ccp(0, 0.5))
    pw:addNode(_editBoxTextPw )
    UIHelper.titleShadow(btnCreateRoom,"创建房间")
    UIHelper.titleShadow(btnCancle,"取消")
    UIHelper.titleShadow(btnSure,"加入房间")
   
    btnSure:addTouchEventListener(tbEvent.join)

    imgBack:addTouchEventListener(function ( sender, eventType ) 
        
    end)
    layBack:addTouchEventListener(tbEvent.close)
  --  btnCancle:addTouchEventListener(tbEvent.close)

    btnCreateRoom:addTouchEventListener(tbEvent.createroom)
    return layBack
end