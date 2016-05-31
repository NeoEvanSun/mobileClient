-- 登录页

module("LoginView", package.seeall)

-- 资源文件setAnchorPoint
local activity_list = "n_ui/loginnew_1.json"
local m_fnGetWidget = g_fnGetWidgetByName
local _editBoxTextName  --用户名
local _editBoxTextPw --用户密码
local function init( ... )
	-- body
end

function destroy(...)
	package.loaded["LoginView"] = nil
end

function moduleName()
    return "LoginView"
end

function getUserName( ... )
    return _editBoxTextName:getText()
end

function getPwd( ... )
    return _editBoxTextPw:getText()
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
    local btnLogin = m_fnGetWidget(layBack,"btn_login")
    local imgUser  = m_fnGetWidget(layBack,"img_input_user")
    local imgPwd  = m_fnGetWidget(layBack,"img_input_pw")
    local btnReg  = m_fnGetWidget(layBack,"btn_reg")
    btnReg:setTitleText("注册")
    btnReg:setTitleFontName(g_sFontName) 
    -- local tfdReg  = m_fnGetWidget(layBack,"tfd_reg")
    -- tfdReg:setText("注册")
    -- tfdReg:setFontName(g_sFontName)
    imgUser:setAnchorPoint(ccp(0, 0.5))
    btnLogin:addTouchEventListener(tbEvent.login)
  --  btnLogin:setTitleText("进入游戏")
    UIHelper.titleShadow(btnLogin,"进入游戏")
    btnLogin:setTitleFontName(g_sFontName) 
    imgPwd:setAnchorPoint(ccp(0, 0.5))
    local size = imgUser:getSize()
    _editBoxTextName = UIHelper.createEditBox(size,"n_ui/zhanwei.png",false)
    _editBoxTextName:setAnchorPoint(ccp(0, 0.5))
    _editBoxTextName:setPlaceHolder("输入用户名")
    _editBoxTextName:setReturnType(kKeyboardReturnTypeDone)
    _editBoxTextName:setTouchPriority(g_tbTouchPriority.editbox)
    imgUser:addNode(_editBoxTextName )

    _editBoxTextPw = UIHelper.createEditBox(size,"n_ui/zhanwei.png",false)
    _editBoxTextPw:setAnchorPoint(ccp(0, 0.5))
    _editBoxTextPw:setPlaceHolder("输入密码") -- 
    _editBoxTextPw:setInputFlag(kEditBoxInputFlagPassword)
    -- _editBoxTextPw:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    _editBoxTextPw:setReturnType(kKeyboardReturnTypeDone)
    _editBoxTextPw:setTouchPriority(g_tbTouchPriority.editbox)
    imgPwd:addNode(_editBoxTextPw )
    local username =  CCUserDefault:sharedUserDefault():getStringForKey("username")
    local password =  CCUserDefault:sharedUserDefault():getStringForKey("password")
    if username~= nil and username~="" then
        _editBoxTextName:setText(username)
    end
    if password~= nil and password~="" then
        _editBoxTextPw:setText(password)
    end
    btnReg:addTouchEventListener(function (  sender, eventType )
            if (eventType == TOUCH_EVENT_ENDED) then
                require "script/module/config/AudioHelper"
                AudioHelper.playCommonEffect()
                require "script/module/register/MainRegisterCtrl"
                MainRegisterCtrl.create()
            end
    end)
	return layBack
end