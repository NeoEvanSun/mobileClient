
module("MainRegisterView", package.seeall)
local activity_list = "n_ui/register_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local editName,editPw,editMobile,editEmail
local nBtnefftag =10987
local function init( ... )
    -- body
end

function destroy(...)
    package.loaded["MainRegisterView"] = nil
end
function getNameText( ... )
   return editName:getText()
end
function getPwText( ... )
   return editPw:getText()
end
function getMobileText( ... )
   return editMobile:getText()
end
function getEmailText( ... )
   return editEmail:getText()
end
function moduleName()
    return "MainRegisterView"
end
function createEdit(parent,edit,hintText )
    parent:setAnchorPoint(ccp(0, 0.5))
    local size = parent:getSize()
    
    edit:setAnchorPoint(ccp(0, 0.5))
    edit:setPlaceHolder(hintText)
    edit:setReturnType(kKeyboardReturnTypeDone)
    edit:setTouchPriority(g_tbTouchPriority.editbox)
    parent:addNode(edit )
end


-- 显示登陆场景
function create(tbEvent)
    local layBack = g_fnLoadUI(activity_list)
    local imgBack = m_fnGetWidget(layBack,"img_back")
    local btnCancle = m_fnGetWidget(layBack,"btn_cancle")
    local btnSure = m_fnGetWidget(layBack,"btn_sure")
    local imgUsername = m_fnGetWidget(layBack,"img_username")
    local imgPw = m_fnGetWidget(layBack,"img_pw")
    local imgMobile = m_fnGetWidget(layBack,"img_mobile")
    local imgEmail = m_fnGetWidget(layBack,"img_email")
    local tfdName = m_fnGetWidget(layBack,"tfd_username")
    local tfdPw = m_fnGetWidget(layBack,"tfd_pw")
    local tfdMobile = m_fnGetWidget(layBack,"tfd_mobile")
    local tfdEmail = m_fnGetWidget(layBack,"tfd_email")
    local size = imgUsername:getSize()
    tfdName:setText("用户名")
    tfdName:setFontName(g_sFontName)
    tfdPw:setText("密码")
    tfdPw:setFontName(g_sFontName)
    tfdMobile:setText("手机号")
    tfdMobile:setFontName(g_sFontName)
    tfdEmail:setText("邮箱")
    tfdEmail:setFontName(g_sFontName)
    editName = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    editPw = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    editMobile = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    editEmail = UIHelper.createEditBox(size,"n_ui/login_text_bg.png",false)
    createEdit(imgUsername,editName,"请填写用户名")
    createEdit(imgPw,editPw,"请填写密码")
    createEdit(imgMobile,editMobile,"请填写手机号")
    createEdit(imgEmail,editEmail,"请填写email")
    UIHelper.titleShadow(btnCancle,"取消")
    UIHelper.titleShadow(btnSure,"注册")
    btnCancle:addTouchEventListener(tbEvent.close)
     
    btnSure:addTouchEventListener(tbEvent.sure)
 
    --LayerManager.addLayout(layBack,nil,g_tbTouchPriority.popDlg)
LayerManager.addLayout(layBack,nil,10000)


    
end