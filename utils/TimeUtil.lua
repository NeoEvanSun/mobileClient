--Filename:timeUtil.lua
--Author：hechao
--Date：2013/4/18
--Purpose:公用方法集合
module("TimeUtil",package.seeall)

require "script/utils/LuaUtil"
local m_i18n = gi18n
----------------------------newtimeutil合并-------------------

m_daySec = 86400
m_hourSec = 3600

-- 根据索引返回周几对应的数字，从 1 ～ 7
m_wdayI18n = {m_i18n[1956], m_i18n[1957], m_i18n[1958], m_i18n[1959], m_i18n[1960], m_i18n[1961], m_i18n[1962], }

-- 给定 lua os.date("*t") 得到table中的wday字段值，返回实际对应的星期几
function getRealwday( wday )
	local day = {7, 1, 2, 3, 4, 5, 6}
	return day[wday]
end

function getTodayWday( ... )
	local tbDate = getServerDateTime()
	return getRealwday(tbDate.wday)
end

-- 返回本地时间和服务器时间的快慢偏差（非时区偏差），单位秒
function getDiffFromLocalToSvr( ... )
	local diff = os.time() - getSvrTimeByOffset() 
	--logger:debug("getDiffFromLocalToSvr-diff = %d", diff)
	return diff
end

-- 返回本地和服务器时区的时间偏差，单位秒
function getOffsetFromLocalToSvr( ... )
	local localZone = os.date("%z")  -- 本地时区和格林威治时间(GMT)相差的时间信息，如东八区 "+0800"， 其他 "-1100"
	local sign, hour, min = string.match(localZone, "(.)(%d%d)(%d%d)")
	--logger:debug("localZone = %s, sign = %s, hour = %s, min = %s", localZone, sign, hour, min)

	local localOffset = (tonumber(hour)*60*60 + tonumber(min)*60) * tonumber(sign .. "1")
	-- 当前时间本地时区和服务器时区偏差的秒数 = 本地和格林威治时区偏差秒数 + 服务器时区和格林威治时区偏差秒数
	local localSvrOffset = localOffset + gi18nTimeOffset()
	--logger:debug("svrOffset = %d, localOffset = %d, localSvrOffset = %d", gi18nTimeOffset(), localOffset, localSvrOffset)

	return localSvrOffset
end

-- zhangqi, 2015-01-19, 返回根据配置的时区偏移秒数以及设备当前时间计算得出的游戏服务器时间
-- return 1, 当前时间table， {year = , month = , day = , yday = , wday = , hour = , min = , sec = , isdst = false}
-- return 2, 当前时间戳
function getServerDateTime( timeInt )
	local now = timeInt or getSvrTimeByOffset() - getOffsetFromLocalToSvr()
	return os.date("*t", now), now
end

-- timeInterval, 时间戳
-- strFmt, 表示转换时间字符串的格式字符串，如: "%Y-%m-%d %H:%M:%S"
function getTimeStringWithFormat( timeInterval, strFmt )
	return os.date(strFmt, tonumber(timeInterval))
end

-- m_time：时间戳  return：时间格式：2014-06-01
function getTimeFormatYMD( m_time )
	return getTimeStringWithFormat(m_time, "%Y-%m-%d")
end

-- para：时间戳  return：时间格式：2014-06-01 01:01
function getTimeFormatYMDHM( m_time )
	return getTimeStringWithFormat(m_time, "%Y-%m-%d %H:%M")
end

----------------------------newtimeutil end-------------------

-- 将一个时间戳转换成"00:00:00"格式
function getTimeString(timeInt)
	local ret = string.format("%02d:%02d:%02d", math.floor(timeInt/(60*60)), math.floor((timeInt/60)%60), timeInt%60)
	return (tonumber(timeInt) <= 0) and "00:00:00" or ret
end

-- 将一个时间数转换成"00时00分00秒"格式
function getTimeStringFont(timeInt)
	local def = string.format("00%s00%s00%s", m_i18n[1977], m_i18n[1976], m_i18n[1981])
	local ret = string.format("%02d%s%02d%s%02d%s", 
			math.floor(timeInt/(60*60)), m_i18n[1977], math.floor((timeInt/60)%60), m_i18n[1976], timeInt%60, m_i18n[1981])
	return (tonumber(timeInt) <= 0) and def or ret
end

-- nGenTime: 起始时间戳（也可以是一个未来的时间，比如CD时间戳）
-- nDuration: 固定的有效期间，单位秒，计算某个未来时间的剩余时间时不需要指定。
-- 返回3个结果，第一个是剩余到期时间的字符串，"HH:MM:SS", 不足2位自动补零；第二个是bool，标识nGenTime是否到期；第三个是剩余秒数
function expireTimeString( nGenTime, nDuration )
    local nNow = BTUtil:getSvrTimeInterval()
    --logger:debug("nGenTime = " .. nGenTime .. " nNow = " .. nNow)
    local nViewSec = (nDuration or 0) - (nNow - nGenTime)
    nViewSec = nViewSec<0 and 0 or nViewSec
    return getTimeString(nViewSec), nViewSec <= 0, nViewSec
end


--得到一个时间戳timeInt与当前时间的相隔天数
--offset是偏移量,例如凌晨4点:4*60*60
--return type is integer, 0--当天, n--不在同一天,相差n天
function getDifferDay(timeInt, offset)
	timeInt = tonumber(timeInt or 0)
	offset = tonumber(offset or 0)
    local curTime = tonumber(BTUtil:getSvrTimeInterval()) - offset
    if(os.date("%j",curTime) == 1 and os.date("%j",timeInt - offset) ~= 1)then
    	return os.date("%j",curTime) - (os.date("%j",timeInt - offset) - os.date("%j",curTime-24*60*60))
    else--if(os.date("%j",curTime) ~= os.date("%j",timeInt - offset))then
    	return os.date("%j",curTime) - os.date("%j",timeInt - offset)
    end
end

-- 指定一个日期时间字符串，返回与之对应的东八区（服务器时区）时间戳, zhangqi, 20130702
-- sTime: 格式 "2013-07-02 20:00:00"
-- modified: zhangqi, 2015-01-20, 将之前固定的东八区时间改为服务器时区
function getIntervalByTimeString( sTime )
	local t = string.split(sTime, " ")
	local tDate = string.split(t[1], "-")
	local tTime = string.split(t[2], ":")

	--------old--------
	-- local tt = os.time({year = tDate[1], month = tDate[2], day = tDate[3], hour = tTime[1], min = tTime[2], sec = tTime[3]})
	-- local ut = os.date("!*t", tt)
	-- -- local east8 = os.time(ut) + 8*60*60 -- UTC时间+8小时转为东八区北京时间
	-- local tv = os.time(ut) - gi18nTimeOffset()
	-- return tv

	--------new--------
	local localTv = os.time({year = tDate[1], month = tDate[2], day = tDate[3], hour = tTime[1], min = tTime[2], sec = tTime[3]})
	return localTv + getOffsetFromLocalToSvr()
end

--给一个时间如:153000,得到今天15:30:00的时间戳 
function getIntervalByTime( time )

	--------old--------
	-- local curTime = BTUtil:getSvrTimeInterval()
	-- local temp = os.date("*t",curTime)
	-- time = string.format("%06d", time)

	-- local h,m,s = string.match(time, "(%d%d)(%d%d)(%d%d)" )
	-- local timeString = temp.year .."-".. temp.month .."-".. temp.day .." ".. h ..":".. m ..":".. s
 --    local timeInt = getIntervalByTimeString(timeString)

 --    return timeInt

    --------new--------
	local temp = getServerDateTime()
	time = string.format("%06d", time)

	temp.hour, temp.min, temp.sec = string.match(time, "(%d%d)(%d%d)(%d%d)" )
    return os.time(temp)
end

--指定一个格式如：hh:mm:ss 的时间字符串，返回这个时间转换为秒后的整数值
function getSecondByTime( timeString )
	local timeInfo = string.split(timeString,":")
	return tonumber(timeInfo[1])*3600 + tonumber(timeInfo[2])*60 + tonumber(timeInfo[3])
end

-- 把一个时间戳转换为 ”n天n小时n分钟n秒“ 如果某一项为0则不显示这一项
-- timeInt:时间戳
function getTimeDesByInterval( timeInt )

	local result = ""
	local oh	 = math.floor(timeInt/3600)
	local om 	 = math.floor((timeInt - oh*3600)/60)
	local os 	 = math.floor(timeInt - oh*3600 - om*60)
	local hour = oh
	local day  = 0
	if(oh>=24) then
		day  = math.floor(hour/24)
		hour = oh - day*24
	end
	if(day ~= 0) then
		result = result .. day .. m_i18n[1937]
	end
	if(hour ~= 0) then
		result = result .. hour .. m_i18n[1977]
	end
	if(om ~= 0) then
		result = result .. om .. m_i18n[1976]
	end
	if(os ~= 0) then
		result = result .. os .. m_i18n[1981]
	end
	return result
end

--给一个时间如:153000,得到今天15:30:00的时间戳 相对于服务器的东八区时间 -- add by chengliang
-- modified: zhangqi, 2015-01-20, 由于修改 getIntervalByTimeString，改为得到相对于服务器时区的时间戳
function getSvrIntervalByTime( time )
	local curTime = getSvrTimeByOffset()
	local temp = os.date("*t",curTime)

	time = string.format("%06d", time)

	local h,m,s = string.match(time, "(%d%d)(%d%d)(%d%d)" )
	local timeString = temp.year .."-".. temp.month .."-".. temp.day .." ".. h ..":".. m ..":".. s
    local timeInt = getIntervalByTimeString(timeString)

    return timeInt
end

-- 得到服务器时间
-- 参数second_num:偏移的秒数  负数：比服务器慢，正数：比服务器快，默认-1
function getSvrTimeByOffset( second_num )
	-- 当前服务器时间
    local curServerTime = BTUtil:getSvrTimeInterval()
    local offset = tonumber(second_num) or -1
    return curServerTime+offset
end

-- para：时间戳  return：时间格式：2014-06-01 01:01:01  add by chengliang
function getTimeFormatYMDHMS( m_time )

	--------old--------
	-- local temp = os.date("*t",m_time)

	-- local m_month 	= string.format("%02d", temp.month)
	-- local m_day 	= string.format("%02d", temp.day)
	-- local m_hour 	= string.format("%02d", temp.hour)
	-- local m_min 	= string.format("%02d", temp.min)
	-- local m_sec 	= string.format("%02d", temp.sec)

	-- local timeString = temp.year .."-".. m_month .."-".. m_day .." ".. m_hour ..":".. m_min ..":".. m_sec
 --    return timeString

	--------new--------
    return getTimeStringWithFormat(m_time, "%Y-%m-%d %H:%M:%S")
end

-- para：时间戳  return：时间格式：2014-06-01 01:01  add by licong  精确到分钟
function getTimeToMin( m_time )
	local temp = os.date("*t",m_time)

	local m_month 	= string.format("%02d", temp.month)
	local m_day 	= string.format("%02d", temp.day)
	local m_hour 	= string.format("%02d", temp.hour)
	local m_min 	= string.format("%02d", temp.min)

	local timeString = temp.year .."-".. m_month .."-".. m_day .."  ".. m_hour ..":".. m_min 

    return timeString
end

-- para：时间戳  return：时间格式： 01:01  add by 李攀 只要 小时和分钟

function getTimeOnlyMin( m_time )
	local temp = os.date("*t",m_time)

	local m_hour 	= string.format("%02d", temp.hour)
	local m_min 	= string.format("%02d", temp.min)

	local timeString = m_hour ..":".. m_min 

    return timeString
end

-- modified, zhangqi, 2015-01-20
-- 参数 second, 秒数
-- 返回 second 表示的时间字符串，单位按 "分钟"， "小时"， "天"
function getTimeStringWithUnit( second )
	second = tonumber(second)
	if (second < 60*60) then
		return math.ceil(second/60) .. m_i18n[1976]
	elseif (second < 60*60*24) then
		return math.ceil(second/(60*60)) .. m_i18n[1977]
	else
		return math.ceil(second/(60*60*24) ) .. m_i18n[1937]
	end
end





