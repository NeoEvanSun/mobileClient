-- FileName: MainChangeAvatar.lua
-- Author: zhangqi
-- Date: 2014-12-27
-- Purpose: 更换头像的逻辑控制模块
--[[TODO List]]

module("MainChangeAvatar", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --

local function init(...)

end

function destroy(...)
	package.loaded["MainChangeAvatar"] = nil
end

function moduleName()
    return "MainChangeAvatar"
end

local function showSelf( allHtid, fnCallback )
	local uHtid = UserModel.getAvatarHtid() -- 玩家头像htid
	-- 用于显示所有伙伴头像列表的数据，子table依次保存 风、雷、水、火 4种类别的伙伴
	local tbHeroes = {{}, {}, {}, {}}

	for k, htid in pairs(allHtid) do
        local db_hero = DB_Heroes.getDataById(htid)
        logger:debug(db_hero)
        if (db_hero.country > 0) then
	        local data = {}
	        data.sName = db_hero.name
	        data.nHtid = db_hero.id
	        data.bUsed = tonumber(htid) == tonumber(uHtid) -- 当前使用的伙伴，需要显示被选标志
	        data.heroQuality = db_hero.heroQuality

	        table.insert(tbHeroes[db_hero.country], data)
	    end
	end

	-- 2015-03-05, 对头像排序，第一优先级：按照资质排序，资质高的排在前面；第二优先级：按照id排序，id大的排在前面
	for i, tbHero in ipairs(tbHeroes) do
		table.sort(tbHero, function ( hero1, hero2 )
			if (hero1.heroQuality > hero2.heroQuality) then
				return true
			elseif (hero1.heroQuality == hero2.heroQuality) then
				if (hero1.nHtid > hero2.nHtid) then
					return true	
				else
					return false
				end
			end
		end)
	end

	logger:debug(tbHeroes)

	local tbData = {heroes = tbHeroes, callback = fnCallback}
	require "script/module/main/ChangeAvatarView"
	local ChangeAvatar = ChangeAvatarView:new()
	LayerManager.addLayout(ChangeAvatar:create(tbData))
end

function create( tbArgs )
	logger:debug("MainChangeAvatar.create")

	RequestCenter.hero_getHeroBook(function ( cbName, dictData, bRet )
		if (bRet) then
			logger:debug("MainChangeAvatar-hero_getHeroBook")
			logger:debug(dictData)

			showSelf(dictData.ret, tbArgs.updateCallback)
		end
	end, Network.argsHandlerOfTable({UserModel.getUserUid()}))
end
