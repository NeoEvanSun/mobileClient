-- FileName: PlayerPanel.lua
-- Author: zhangqi
-- Date: 2014-03-24
-- Purpose: 玩家信息面板

module("PlayerPanel", package.seeall)

-- 模块局部变量

function moduleName()
	return "PlayerPanel"
end

-- 初始函数，加载UI资源文件
function init( ... )
	logger:debug("PlayerPanel init ok")
end

-- 析构函数，释放纹理资源
function destroy( ... )
	logger:debug("PlayerPanel.destroy")
end

function addForMainShip( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/MainInfoBar"
		local infoBar = MainInfoBar:new()
		infoBar:create()
	end
end

function addForCopy( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/CopyInfoBar"
		local infoBar = CopyInfoBar:new()
		infoBar:create()
	end
end

function addForExplor( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/ExplorInfoBar"
		local infoBar = ExplorInfoBar:new()
		infoBar:create()
	end
end
function addForExplorMap( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/ExplorMapInfoBar"
		local infoBar = ExplorMapInfoBar:new()
		infoBar:create()
	end
end
function addForPartnerStrength( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/PartnerInfoBar"
		local infoBar = PartnerInfoBar:new()
		infoBar:create()
	end
end
function addForPublic( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/PublicInfoBar"
		local infoBar = PublicInfoBar:new()
		infoBar:create()
	end
end

function addForActivity( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/ActivityInfoBar"
		local infoBar = ActivityInfoBar:new()
		infoBar:create()
	end
end
function addForActivityCopy( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/ACopyInfoBar"
		local infoBar = ACopyInfoBar:new()
		infoBar:create()
	end
end

function addForArena( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/ArenaInfoBar"
		local infoBar = ArenaInfoBar:new()
		infoBar:create()
	end
end

function addForSkyPiea(  )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/SkyPieaInfoBar"
		local infoBar = SkyPieaInfoBar:new()
		infoBar:create()
	end
end

function addForGrab(  )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/GrabInfoBar"
		local infoBar = GrabInfoBar:new()
		infoBar:create()
	end
end

function addForUnionShop( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/UnionShopInfoBar"
		local infoBar = UnionShopInfoBar:new()
		infoBar:create()
	end
end

function addForUnionPublic( ... )
	local layRoot = LayerManager.getRootLayout()
	if (layRoot) then
		require "script/module/PlayerInfo/UnionPublicInfoBar"
		local infoBar = UnionPublicInfoBar:new()
		infoBar:create()
	end
end
