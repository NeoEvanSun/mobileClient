-- 登陆模块的控制器副本中的奖励宝箱有丰厚的奖励

module("LoginCtrl", package.seeall)
require "script/module/login/LoginView"
require "script/model/DataCache"
require "script/network/HttpClient"
require "script/module/public/ShowNotice"
require "script/module/config/AudioHelper"
-- 按钮事件
local tbBtnEvent = {}
local function init(...)

end

function destroy(...)
	package.loaded["LoginCtrl"] = nil
end

function moduleName()
    return "LoginCtrl"
end
tbBtnEvent.login = function ( sender, eventType)
    if (eventType == TOUCH_EVENT_ENDED) then
        AudioHelper.playCommonEffect()
        local username = LoginView.getUserName()
        local password = LoginView.getPwd()
        if username == nil or username == "" then
                -- local alert = UIHelper.createCommonDlg("请输入用户名",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                ShowNotice.showShellInfo("请输入用户名")
        elseif  password == nil or password == "" then
                -- local alert = UIHelper.createCommonDlg("请输入密码",nil,nil,1,nil)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                ShowNotice.showShellInfo("请输入密码")
        else
                require "script/module/login/LoginData"
                LoginData.loginUserData(username,password)
        end
       
        -- HttpClient.get(function ( sender, res) 跑马灯   CCUserDefault:sharedUserDefault():getString
        --     local cjson = require "cjson"
        --     local jsonInfo = cjson.decode(res:getResponseData())
             
        --     DataCache.setUserInfo(jsonInfo)
        --     require "script/module/mainTips/MainTipsCtrl"
        --     local tips = MainTipsCtrl.create() 
        --     LayerManager.changeModule(tips, MainTipsCtrl.moduleName(), {1}, true)
             
        --end,"users/user_info")
        -- local alert = UIHelper.createCommonDlg("您确定要创建房间？",nil,call1,2,cancleCall)
        -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
       
        
        
    end
end
function create( ... ) 
	local m_layMain =  LoginView.create(tbBtnEvent)
	return m_layMain
end