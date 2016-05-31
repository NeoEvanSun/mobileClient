-------------------------------------------------------------------------------
-- Sends the logging information through a socket using luasocket
--
-- @author Thiago Costa Ponte (thiago@ideais.com.br)
--
-- @copyright 2004-2013 Kepler Project
--
-------------------------------------------------------------------------------

local httptest = "http://192.168.1.56:8001/index.php?"
local httponline = "http://debug.zuiyouxi.com:17801/index.php?"

local function encodeURL(url)
   local aByte, zByte, AByte, ZByte, _Byte, dotByte, hypeByte, n0Byte, n9Byte = string.byte("azAZ_.-09", 1, 9)
    local ret = ""
    for i = 1, url:len() do
        local c = string.byte(url, i)
        if (c >= aByte and c <= zByte) or (c >= AByte and c <= ZByte) or (c>=n0Byte and  c<=n9Byte) or c == _Byte or c == dotByte or c == hypeByte then
            ret = ret .. string.char(c)
        else
            ret = ret .. '%'
            ret = ret .. string.format("%02x", c)
        end
    end
    return ret
end

local logging = require "script/libs/logging"


function logging.http( _httptype , logPattern )
	return logging.new( function(self, level, message)

		local str = logging.prepareLogMsg(logPattern, os.date("*t"), level, message)

		-- http send str
		function HttpResponse( client, response )
			local versionJsonString = response:getResponseData()
			print("versionJsonString: " .. versionJsonString)
			local retCode = response:getResponseCode()
		end

		local httpServer = _httptype
		if ( httpServer == nil) then
			httpServer = httponline -- logging.http.online
		end

		local pid = LoginHelper.debugUID() or "0000000"
		local urlParam = "&pl=zyxphone_default&gn=cp&os=ios"
		require "platform/Platform"
		if (Platform.isPlatform()) then
			pid = Platform.getPid() or "0000001"
			urlParam = Platform.getUrlParam()
		end

		local verPkg, verScript = Helper.getVersion()
		local baseUrl = string.format("%spid=%s%s&env=lua&scriptVersion=%s&packageVersion=%s&fatal=", 
												tostring(httpServer), tostring(pid), tostring(urlParam), tostring(verScript), tostring(verPkg))
		
		local infoStr = encodeURL(str)
		print(baseUrl..infoStr)

		local request = LuaHttpRequest:newRequest()
		request:setRequestType(CCHttpRequest.kHttpGet)
		request:setUrl(baseUrl..infoStr)
		request:setResponseScriptFunc(HttpResponse)
	
		local httpClient = CCHttpClient:getInstance()
		httpClient:send(request)
		request:release()

		return true
	end)
end

return logging.http

