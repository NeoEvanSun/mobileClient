-- Filename: UserHandler.lua
-- Author: fang
-- Date: 2013-05-30
-- Purpose: 该文件用于登陆数据模型

require "script/network/Network"
require "script/utils/LuaUtil"
-- require "script/ui/create_user/UserLayer"
module ("UserHandler", package.seeall)

local m_ExpCollect = ExceptionCollect:getInstance()

newPid = tostring(os.time()) -- zhangqi, 20140414, 临时保存新pid号，用于创建测试用新号

isNewUser = false

local  _utid   = 1
local _curName = ""

local function createuserAction( cbFlag, dictData, bRet )
	-- print("createuserAction : dictData =")
	-- print_t(dictData)

	RequestCenter.user_getUsers(fnGetUsers)
end

-- 获取网络请求的网络回调函数
local function randomNameAction(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	-- print(os.time())
	_UserName = dictData.ret
	if(table.isEmpty(_UserName)) then
		print("随机名已用完")
		-- print(os.time())
		_UserName = os.time()
	end
	_curName = _UserName[1].name


	local args = CCArray:create()
	args:addObject(CCInteger:create(_utid))
	args:addObject(CCString:create("" .. _curName))

	RequestCenter.user_createUser(createuserAction,args)

end

-- 获取随即名字的网络请求
local function getRandomName( )
	local args = CCArray:create()
	args:addObject(CCInteger:create(20))
	args:addObject(CCInteger:create(_utid))
	require "script/network/Network"
	RequestCenter.user_getRandomName(randomNameAction, args)
end

-- 玩家登陆到游戏服务器
function login(cbName, dictData, bRet)
	if (cbName ~= "user.login") then
		m_ExpCollect:info("connectAndLogin", "cbName = " .. cbName)
		return
	end
	if (bRet) then
		if (dictData.ret == "ok") then
			RequestCenter.user_getUsers(fnGetUsers)
		else
			m_ExpCollect:info("connectAndLogin", "UserHandler.login ret = " .. tostring(dictData.ret))
		end
	end
end


-- 得到玩家所有的用户（支持一个帐户有多个角色）
function fnGetUsers(cbName, dictData, bRet)
	print("haha_fnGetUsers bRet: ", bRet)
	if (bRet) then
		local ret = dictData.ret

		m_ExpCollect:info("connectAndLogin", "fnGetUsers #ret = " .. tostring(#ret))

		if (#ret > 0) then
			local dictUserInfo = ret[1]
			local ccsUid = dictUserInfo.uid

			local args = CCArray:createWithObject(CCString:create(ccsUid) )
			Network.rpc(fnUserLogin,"user.userLogin", "user.userLogin", args, true)
		else
			isNewUser = true

			-- 新号未创建角色
			logger:debug("我是新号")
			LayerManager.removeLoginLoading()

			require "script/module/login/NewGuyHelper"
			NewGuyHelper.showLuojie(function ( ... )
				m_ExpCollect:finish("NewGuyHelper")

				require "script/module/login/UserNameCtrl"
				local layName = UserNameCtrl.create(m_isNanSelected)
				LayerManager.changeModule( layName, UserNameCtrl.moduleName(), {}, true)
			end)
		end
	end
end

-- 使用uid用户进入游戏
function fnUserLogin(cbName, dictData, bRet)
	if (bRet) then
		local ret = dictData.ret
		m_ExpCollect:info("connectAndLogin", "fnUserLogin ret = " .. tostring(ret) .. "ret.ret = " .. tostring(ret.ret))
		print("haha_fnUserLogin ret: ", ret)
		if (ret == "ok") then
			print("玩家角色登录成功")
			require "script/network/RequestCenter"
			RequestCenter.user_getUser(fnGetUser, nil)

			-- require "script/module/config/AnnounceCtrl"  -- 2014-09-13, 从web端读取公告信息
			-- AnnounceCtrl.fetchNotice02FromServer()
		elseif ret.ret == "timeout" then
			LoginHelper.fnServerIsTimeout()
		elseif ret.ret == "full" then
			LoginHelper.fnServerIsFull()
		elseif ret.ret == "ban" then
			LoginHelper.fnIsBanned(ret.info)
		end
	end
end

-- 得到用户信息
function fnGetUser(cbName, dictData, bRet)
	print("haha_fnGetUser bRet: ", bRet)
	m_ExpCollect:info("connectAndLogin", "fnGetUser bRet = " .. tostring(bRet))

	if (bRet) then
		require "script/model/user/UserModel"
		UserModel.setUserInfo(dictData.ret)

		-- 2013-03-27, 平台统计需求，创建新角色且拉到玩家信息后调用
		if (Platform.isPlatform() and isNewUser) then
			Platform.sendInformationToPlatform(Platform.kCreateNewRole)
		end

		LoginHelper.startPreRequest()
	end
end

function createUser( ... )

end

local _bIsLoginStatus=false
function fnIsLoginStatus(rpcName)
	if rpcName == "user.login" then
		_bIsLoginStatus = true
	elseif rpcName=="user.getUser" then

	elseif _bIsLoginStatus and string.find(rpcName, "user") == 1 then
		return false
	elseif _bIsLoginStatus then
		return true
	end

	return false
end
