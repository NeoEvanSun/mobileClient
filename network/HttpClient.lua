module ("HttpClient", package.seeall)
require "script/module/main/LayerManager"
m_tbRpcBack = {} -- lizy, 2016-03-17, 记录一个rpc请求是否收到返回；发出请求记为 true, 收到返回记为nil
m_lastRpcFlag = "" -- 最近发出的rpc的自定义名称
local m_bShowLoading = false ---是否显示加载的那个框框
local tm_cbFuncs = {} -- 回调方法的tabl

 function setFalse( ... )
    m_bShowLoading = false
end
 
--调用网络接口
--cbFunc: 回调的方法 type->lua function
--url:请求地址
 --add by lizy
--return:无
function get( cbFunc,url,flag) --flag 不为空那么loading就不小事
    local function networkHandlerGet(sender, res )
        if (m_bShowLoading and flag== nil  ) then
            LayerManager.removeLoading()
            m_bShowLoading = false
        end
        if(res:getResponseCode()~=200)then
                LayerManager.removeLoading()
                m_bShowLoading = false
                -- local alert = UIHelper.createCommonDlg("网络异常",nil,call1,1,cancleCall)
                -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
                ShowNotice.showShellInfo("网络异常")
                return
            end
        cbFunc(sender, res)
         
    end
    
    local request = LuaHttpRequest:newRequest()
    request:setRequestType(CCHttpRequest.kHttpGet)
    request:setUrl(g_http .. url)
    request:setTimeoutForConnect(20)
    request:setResponseScriptFunc(networkHandlerGet)
    CCHttpClient:getInstance():send(request)
    request:release()  
    if (not m_bShowLoading) then
        LayerManager.addLoading() -- lizy, 显示网络请求Loading
        m_bShowLoading = true
    end
end
--调用网络接口
--cbFunc: 回调的方法 type->lua function
--url:请求地址
--add by lizy
--return:无
function post( cbFunc,url,postData,flag) --flag 不为空那么loading就不小事
    local function networkHandlerPost(sender, res )
        if (m_bShowLoading ) and flag== nil then

            LayerManager.removeLoading()
            m_bShowLoading = false
        end
        if(res:getResponseCode()~=200)then
            LayerManager.removeLoading()
            m_bShowLoading = false
            ShowNotice.showShellInfo("网络异常")
            -- local alert = UIHelper.createCommonDlg("网络异常",nil,call1,1,cancleCall)
            -- LayerManager.addLayout(alert,nil,g_tbTouchPriority.popDlg)
            return
        end
        cbFunc(sender, res)
         
    end
    
    local request = LuaHttpRequest:newRequest()
    request:setRequestType(CCHttpRequest.kHttpPost)
    request:setUrl(g_http .. url)
    request:setRequestData(postData, string.len(postData))
    local arrHeader = CCArray:create()
    arrHeader:addObject(CCString:create("Expect:"))
    arrHeader:addObject(CCString:create("Content-type:application/json"))
    request:setHeaders(arrHeader)
    request:setResponseScriptFunc(networkHandlerPost)
    request:setTimeoutForConnect(20)
    CCHttpClient:getInstance():send(request)
    request:release()  
    if (not m_bShowLoading) then
        LayerManager.addLoading() -- zhangqi, 2014-05-12, 显示网络请求Loading
        m_bShowLoading = true
    end
end