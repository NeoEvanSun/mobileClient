module("MainRegisterCtrl", package.seeall)
require "script/module/register/MainRegisterView"
require "script/module/config/AudioHelper"
local cjson = require "cjson"
require "script/module/public/ShowNotice"

-- 按钮事件
local tbBtnEvent = {}
local function init(...)

end

function destroy(...)
    package.loaded["MainRegisterCtrl"] = nil
end

function moduleName()
    return "MainRegisterCtrl"
end

tbBtnEvent.close = function ( sender, eventType)
        if (eventType == TOUCH_EVENT_ENDED) then
            AudioHelper.playCloseEffect()
            LayerManager.removeLayout()
        end
    end
tbBtnEvent.sure = function ( sender, eventType)
       
        local username = MainRegisterView.getNameText()
        local password = MainRegisterView.getPwText()
        local mobile = MainRegisterView.getMobileText()
        local email = MainRegisterView.getEmailText()
        if (eventType == TOUCH_EVENT_ENDED) then
            require "script/module/config/AudioHelper"
            AudioHelper.playCommonEffect()
            if username == nil or username == "" then
                -- local alert = UIHelper.createCommonDlg("请输入用户名",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                 ShowNotice.showShellInfo("请输入用户名")
            elseif  password == nil or password == "" then
                ShowNotice.showShellInfo("请输入密码")
                -- local alert = UIHelper.createCommonDlg("请输入密码",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            elseif  email == nil or email == "" then
                ShowNotice.showShellInfo("请输入邮箱")
                -- local alert = UIHelper.createCommonDlg("请输入邮箱",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            elseif  mobile == nil or mobile == "" then
                ShowNotice.showShellInfo("请输入手机号")
                -- local alert = UIHelper.createCommonDlg("请输入手机号",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            else
                local postDataTable = {}
                postDataTable["userName"] = username
                postDataTable["userPwd"] = password
                postDataTable["mobile"] = mobile
                postDataTable["email"] = email
                local postData =  cjson.encode(postDataTable)
                print("postData---"..postData)
                HttpClient.post(function ( sender, res)
                    local cjson = require "cjson"
                    local jsonInfo = cjson.decode(res:getResponseData())
                    print("123---"..res:getResponseData())
                    if(jsonInfo.code == 0) then
                        require "script/module/login/LoginData"
                        LoginData.loginUserData(username,password)

                    else
                      --   ShowNotice.showShellInfo("注册失败")
                         -- local alert = UIHelper.createCommonDlg("注册失败",nil,nil,1,nil)
                         -- LayerManager.addLayout(alert,nil,99999999)
                         ShowNotice.showShellInfo("注册失败")
                          LayerManager.removeLoading()
                    end 
                 end,"users/register",postData,1)
            end
        end
    end
function create( ... )

    local m_layMain =  MainRegisterView.create(tbBtnEvent)
     
end