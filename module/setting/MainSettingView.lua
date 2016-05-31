module("MainSettingView", package.seeall)

require "script/model/DataCache"
require "script/network/HttpClient"

local activity_list = "n_ui/setting_1.json"
 
local m_fnGetWidget = g_fnGetWidgetByName
 
local function init( ... )
    -- body wrong.json
end

function destroy(...)
    package.loaded["MainSettingView"] = nil
end

function moduleName()
    return "MainSettingView"
end
 
function create( tbEvent )
    local layBack    = g_fnLoadUI(activity_list)
    local imgBack = m_fnGetWidget(layBack,"img_back")
    local btnYinyue  = m_fnGetWidget(layBack,"btn_yinyue")
    local btnYinxiao = m_fnGetWidget(layBack,"btn_yinxiao")
    local btnChange = m_fnGetWidget(layBack,"btn_change")
    local m_isMusicOn = CCUserDefault:sharedUserDefault():getBoolForKey("m_isMusicOn")
    local m_isEffectOn = CCUserDefault:sharedUserDefault():getBoolForKey("m_isEffectOn")
    if m_isMusicOn == nil then
        CCUserDefault:sharedUserDefault():setBoolForKey("m_isMusicOn",true)
        CCUserDefault:sharedUserDefault():setBoolForKey("m_isEffectOn",true)
        m_isMusicOn = true
        m_isEffectOn = true
        btnYinxiao:loadTextureNormal("n_ui/btn_close_music_h")
        btnYinyue:loadTextureNormal("n_ui/btn_close_music_h")
    else
        if m_isMusicOn == false then
            btnYinyue:loadTextureNormal("n_ui/btn_close_music_h")
        else
            btnYinyue:loadTextureNormal("n_ui/btn_open_music_h.png")
        end
        if m_isEffectOn== false then
            btnYinxiao:loadTextureNormal("n_ui/btn_close_music_h")
        else
            btnYinxiao:loadTextureNormal("n_ui/btn_open_music_h.png")
        end
    end
    btnYinyue:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            m_isMusicOn =  CCUserDefault:sharedUserDefault():getBoolForKey("m_isMusicOn")
                                            AudioHelper.playCommonEffect()
                                            if m_isMusicOn then
                                                
                                                CCUserDefault:sharedUserDefault():setBoolForKey("m_isMusicOn",false)
                                                AudioHelper.setMusic(false)
                                               
                                                m_isMusicOn= false
                                                sender:loadTextureNormal("n_ui/btn_close_music_h.png")
                                                sender:loadTexturePressed("n_ui/btn_close_music_h.png")
                                             --   LayerManager.removeLayout()
                                                return  true
                                            else
                                                  
                                                CCUserDefault:sharedUserDefault():setBoolForKey("m_isMusicOn",true) 
                                                AudioHelper.setMusic(true)
                                                 m_isMusicOn= true
                                               
                                                sender:loadTextureNormal("n_ui/btn_open_music_h.png")
                                                sender:loadTexturePressed("n_ui/btn_open_music_h.png")
                                              --  LayerManager.removeLayout()
                                                 return true
                                            end
                                            
                                        end
                                  end)
    btnYinxiao:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                               AudioHelper.playCommonEffect()
                                            m_isEffectOn = CCUserDefault:sharedUserDefault():getBoolForKey("m_isEffectOn")
                                            if m_isEffectOn then
                                               
                                                CCUserDefault:sharedUserDefault():setBoolForKey("m_isEffectOn",false)
                                                 AudioHelper.setEffect(false)
                                               --  m_isEffectOn = false
                                                 sender:loadTextureNormal("n_ui/btn_close_music_h.png")
                                                 -- LayerManager.removeLayout()
                                                 return  true
                                            else
                                                CCUserDefault:sharedUserDefault():setBoolForKey("m_isEffectOn",true)
                                                 sender:loadTextureNormal("n_ui/btn_open_music_h.png")
                                                AudioHelper.setEffect(true)
                                               --  m_isEffectOn = true
                                               -- LayerManager.removeLayout()
                                                 return  true
                                            end
                                            
                                        end
                                  end)
    btnChange:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                               AudioHelper.playCommonEffect()
                                            local function fnConfirmEvent( sender, eventType )
                                                if (eventType == TOUCH_EVENT_ENDED) then
                                                    CCUserDefault:sharedUserDefault():setStringForKey("username", "")
                                                    CCUserDefault:sharedUserDefault():setStringForKey("password", "")
                                                    require "script/network/WebSocketClient"
                                                    WebSocketClient.close()
                                                    require "script/module/login/LoginCtrl"
                                                    local loginModule = LoginCtrl.create();
                                                    LayerManager.changeModule(loginModule, LoginCtrl.moduleName(), {}, true)
                                                end
                                            end
                                           
                                            local alert = UIHelper.createCommonDlg("确认更换账号吗？",nil,fnConfirmEvent,2,cancleCall)
                                            LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                                        end
                                  end)
    layBack:addTouchEventListener(function  ( sender, eventType)
                                        if (eventType == TOUCH_EVENT_ENDED) then
                                            LayerManager.removeLayout()
                                            
                                        end
                                  end)
    imgBack:addTouchEventListener(function ( sender, eventType ) 
        
    end)
    LayerManager.addLayout(layBack,nil,g_tbTouchPriority.popDlg)
end