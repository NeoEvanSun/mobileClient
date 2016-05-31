
local host = "mapicp.zuiyouxi.com1" -- 线上 platform_temp
if (g_debug_mode) then
	host = "172.10.1.86:8080"-- host = "192.168.1.113:17602" -- 测试服局域网
else
	host = "mapicp.zuiyouxi.com1" -- 线上
end

local ver = { pl = "ppphone",
	gn = "cp",
	os = "ios",
	param = "&packageVersion=%s&scriptVersion=%s&pl=%s&gn=%s&os=%s",
	domain = "http://" .. host .. "/phone/get3dVersion?"
}

-- local notice = { 	pl = "teshu_test",
-- 				  	gn = "cp",
-- 				  	os = "ios",
-- 				  	serverKey = "game70000001",
-- 				  	param = "&packageVersion=%s&scriptVersion=%s&pl=%s&gn=%s&os=%s&action=get&returntype=cardstr&serverKey=%s",
-- 				  	domain = "http://192.168.1.113:17601/phone/notice?"
-- 				}
local notice = "http://" .. host .. "/phone/notice?pl=ppphone&gn=cp&os=ios&action=get&returntype=cardstr&serverKey=game70000001"


local serverList = "http://" .. host .. "/phone/serverlistnotice?pl=ppphone&gn=cp&os=ios"

local gmReport = "http://" .. host .. "/phone/question?method=GET&serverID=%s&server_id=%s&content=%s&classID=%s&uid=%s&uname=%s&action=%s"
local gmReview = "http://" .. host .. "/phone/question?method=GET&serverID=%s&server_id=%s&uid=%s&action=%s"

return {ver, notice, serverList, gmReport, gmReview}

--update  http://192.168.1.113:17601/phone/get3dVersion?&packageVersion=1.1.4&scriptVersion=2.0.1&pl=test&gn=cp&os=ios
--notice  http://192.168.1.113:17601/phone/notice?pl=teshu_test&gn=cp&os=ios&action=get&returntype=cardstr&serverKey=game70000001
