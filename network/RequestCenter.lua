-- Filename：	RequestCenter.lua
-- Author：		zhz
-- Date：		2013-6-6
-- Purpose：		请求分发

module ("RequestCenter", package.seeall)

require "script/network/Network"

-- zhangqi, 2015-01-05, 因账号别处登陆导致连接断开前的推送
function re_OtherLoginCallback( cbFlag, dictData, bRet )
	if (bRet) then
		logger:debug("re_OtherLoginCallback")
		logger:debug(dictData)
		Network.m_bOtherLogin = true
	end
end
function re_OtherLogin( ... )
	Network.re_rpc(re_OtherLoginCallback, "push.user.otherLogin", "push.user.otherLogin")
end
function test(cbFunc ,params)
	Network.re_rpc(cbFunc, "sysinfo", "sysinfo",params)
end
-- 获取每日任务信息  add by lizy
function  getActiveInfo( cbFunc,params)
	Network.rpc(cbFunc, "active.getActiveInfo","active.getActiveInfo", params, true)
end
--  每日任务领取奖励  add by lizy
function  getPrize ( cbFunc,params)
	Network.rpc(cbFunc, "active.getPrize","active.getPrize", params, true)
end
--  每日任务领取宝箱奖励  add by lizy
function  getTaskPrize  ( cbFunc,params)
	Network.rpc(cbFunc, "active.getTaskPrize","active.getTaskPrize", params, true)
end
function  sign_appendSignNor( cbFunc,params)
	Network.rpc(cbFunc, "sign.appendSignNor","sign.appendSignNor", params, true)
end

function  sign_gainNormalSignReward( cbFunc,params)
	Network.rpc(cbFunc, "sign.gainNormalSignReward","sign.gainNormalSignReward", params, true)
end

function  sign_getNormalInfo( cbFunc,params)
	Network.rpc(cbFunc, "sign.getNormalInfo","sign.getNormalInfo", params, true)
end


---------------------------------------reslove---------------------------------
--炼化伙伴碎片
function resolveHeroFrag(cbFunc,params)
	Network.rpc(cbFunc, "mysteryshop.resolveHeroFrag","mysteryshop.resolveHeroFrag", params, true)
end
--炼化装备
function resolveEquips(cbFunc,params)
	Network.rpc(cbFunc, "mysteryshop.resolveItem","mysteryshop.resolveItem", params, true)
end
--炼化宝物
function resolveTreasures(cbFunc,params)
	Network.rpc(cbFunc, "mysteryshop.resolveTreasure","mysteryshop.resolveTreasure", params, true)
end
--炼化时装
function resolveDress(cbFunc,params)
	Network.rpc(cbFunc, "mysteryshop.resolveDress","mysteryshop.resolveDress", params, true)
end
--炼化伙伴 2015-1-8 by zhangjunwu
function resolveHero(cbFunc,params)
	Network.rpc(cbFunc, "mysteryshop.resolveHero","mysteryshop.resolveHero", params, true)
end

---------------------------------------IMysteryShop---------------------------------
-- 拉去神秘商店信息
function mysteryShop_getShopInfo(fn_cb)
	Network.rpc(fn_cb, "mysteryshop.getShopInfo","mysteryshop.getShopInfo", nil, true)
end

-- 进行兑换
function mysteryShop_buyGoods(fn_cb,params)
	Network.rpc(fn_cb, "mysteryshop.buyGoods","mysteryshop.buyGoods", params, true)
end

-- 刷新
function mysteryShop_playerRfrGoodsList(fn_cb,params)
	Network.rpc(fn_cb, "mysteryshop.playerRfrGoodsList","mysteryshop.playerRfrGoodsList", params, true)
end

--------------------------------------- IBag ----------------------------------------
--获取背包信息
function bagInfo( cbFunc )
	Network.rpc(cbFunc, "bag.bagInfo", "bag.bagInfo", nil, true)
end
--宝物精炼
function evolveTreasure( cbFunc,params)
	Network.rpc(cbFunc, "forge.evolve", "forge.evolve", params, true)
end

--
--------------------------------------- ICopy ----------------------------------------
--获取当前战斗的副本与所在地图
function getLastNormalCopyList(cbFunc)
	Network.rpc(cbFunc, "ncopy.getLastWorldInfo", "ncopy.getLastWorldInfo", nil, true)
end

--获取世界地图的副本
function getNormalCopyList(cbFunc, params)
	Network.rpc(cbFunc, "ncopy.getCopyListByWorld", "ncopy.getCopyListByWorld", params, true)
end

function resetAtkNum( cbFunc, params )
	Network.rpc(cbFunc, "ncopy.resetAtkNum", "ncopy.resetAtkNum", params, true)
end

--获取活动副本
function getActiveCopyList(cbFunc)
-- Network.rpc(cbFunc, "acopy.getCopyList", "acopy.getCopyList", nil, true)
end

--获取精英副本
function getEliteCopyList(cbFunc)
	Network.rpc(cbFunc, "ecopy.getEliteCopyInfo", "ecopy.getEliteCopyInfo", nil, true)
end

--进入据点难度
function enderBaseLv( cbFunc, params )
	Network.rpc(cbFunc, "ncopy.enterBaseLevel", "ncopy.enterBaseLevel", params, true)
end

--扫荡
function copy_sweep( cbFunc, params )
	Network.rpc(cbFunc, "ncopy.sweep", "ncopy.sweep", params, true)
end

--消除扫荡后的cd
function clear_sweepCd( cbFunc )
	Network.rpc(cbFunc, "ncopy.clearSweepCd", "ncopy.clearSweepCd", nil, true)
end

--摇钱树
function copy_atkGoldTree( cbFunc, params )
-- Network.rpc(cbFunc, "acopy.atkGoldTree", "acopy.atkGoldTree", params, true)
end
-- 金币攻击摇钱树
function copy_atkGoldTreeByGold( cbFunc, params )
-- Network.rpc(cbFunc, "acopy.atkGoldTreeByGold", "acopy.atkGoldTreeByGold", params, true)
end

-- 经验宝物
function copy_atkExpTreasure( cbFunc, params )
-- Network.rpc(cbFunc, "acopy.atkExpTreasure", "acopy.atkExpTreasure", params, true)
end

-- 副本排行榜
function copy_rank( cbFunc, params )
	Network.rpc(cbFunc, "ncopy.getUserRankByCopy", "ncopy.getUserRankByCopy", params, true)
end
--------------------------------------- IFormation ---------------------------------
-- 获取阵型信息
function getFormationInfo( cbFunc)
	Network.rpc(cbFunc,"formation.getFormation","formation.getFormation", nil,true)
end

-- 获取阵型信息
function getSquadInfo(cbFunc)
	Network.rpc(cbFunc,"formation.getSquad","formation.getSquad",nil,true)
end

-- 更改阵型位置
function setFormationInfo(cbFunc, params)
	Network.rpc(cbFunc,"formation.setFormation","formation.setFormation",params,true)
end

-- 添加上阵英雄
function formation_addHero( cbFunc, params )
	Network.rpc(cbFunc,"formation.addHero","formation.addHero",params,true)
end

function formation_openExtra( cbFunc, params )
	Network.rpc(cbFunc,"formation.openExtra","formation.openExtra",params,true)
end

-- 保存用户设置的替补信息
function formation_setBench( cbFunc, params )
	Network.rpc(cbFunc,"formation.setBench","formation.setBench",params,true)
end

-- 移除某位置的替补
function formation_delBench( cbFunc, params )
	Network.rpc(cbFunc,"formation.delBench","formation.delBench",params,true)
end

-- 保存替补中某伙伴与阵容中某伙伴互换
function formation_swapForBen( cbFunc, params )
	Network.rpc(cbFunc,"formation.swapForBen","formation.swapForBen",params,true)
end

---------------------------------------IBattle 战斗 ----------------------------------------
-- 战斗
function doBattle( cbFunc, params )
	Network.rpc(cbFunc, "ncopy.doBattle", "ncopy.doBattle", params, false)
end

-- 测试战斗
function test(cbFunc, params )
	Network.rpc(cbFunc, "battle.test", "battle.test", params, false)
end




-- added by zhz
-- modified by huxiaozhou 2014-11-22 去掉 活动副本 相关接口调用
------------------------Iacopy-----------------------------------
--活动副本的战斗接口
function acopy_doBattle(fn_cb, params)
	Network.rpc(fn_cb, "acopy.atkACopy","acopy.atkACopy", params, true)
	return "acopy.atkACopy"
end
--进入某个据点的难度级别进行攻击(活动类别：活动据点)
function acopy_enterBaseLevel(fn_cb, params)
	Network.rpc(fn_cb, "acopy.enterACopy","acopy.enterACopy", params, true)
	return "acopy.enterACopy"
end
--进入副本
function acopy_enterCopy(fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.enterCopy","acopy.enterCopy", params, true)
	return "acopy.enterCopy"
end
--获取某个副本的信息
function acopy_getCopyInfo(fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.getCopyInfo","acopy.getCopyInfo", params, true)
	return "acopy.getCopyInfo"
end
--获取所有的副本类活动
function acopy_getCopyList(fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.getCopyList","acopy.getCopyList", params, true)
	return "acopy.getCopyList"
end
--离开某个副本的据点难度级别(活动类型：活动据点）
function acopy_leaveBaseLevel(fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.leaveBaseLevel","acopy.leaveBaseLevel", params, true)
	return "acopy.leaveBaseLevel"
end
--重新攻击某据点难度级别 应用场景：攻击失败之后点击重新攻击按钮
function acopy_reFight(fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.reFight","acopy.reFight", params, true)
	return "acopy.reFight"
end
--复活战斗死亡的卡牌
function acopy_reviveCard (fn_cb, params)
	-- Network.rpc(fn_cb, "acopy.reviveCard","acopy.reviveCard", params, true)
	return "acopy.reviveCard "
end

------------------------Iactivity-----------------------------------
--登录后第一次调用时，会返回所有活动的数据。 之后调用只返回有改变的活动的配置
function activity_getAllConf(fn_cb, params)
	Network.rpc(fn_cb, "activity.getAllConf","activity.getAllConf", params, true)
	return "activity.getAllConf"
end

function activity_getConf(fn_cb, params)
	Network.rpc(fn_cb, "activity.getActivityConf", "activity.getActivityConf", params, true)
end

------------------------Iarena-----------------------------------

-- 向后端发送拉去竞技场奖励接口
function arena_sendRankReward( fn_cb, params)
	Network.rpc(fn_cb, "arena.sendRankReward","arena.sendRankReward", params, true)
	return "arena.sendRankReward"
end
--兑换声望
function arena_buy(fn_cb, params)
	Network.rpc(fn_cb, "arena.buy","arena.buy", params, true)
	return "arena.buy"
end
--挑战某个排名的用户
function arena_challenge(fn_cb, params)
	Network.rpc(fn_cb, "arena.challenge","arena.challenge", params, true)
	return "arena.challenge"
end
--进入竞技场
function arena_enterArena(fn_cb, params)
	Network.rpc(fn_cb, "arena.enterArena","arena.enterArena", params, true)
	return "arena.enterArena"
end
--获取竞技场信息
function arena_getArenaInfo(fn_cb, params)
	Network.rpc(fn_cb, "arena.getArenaInfo","arena.getArenaInfo", params, true)
	return "arena.getArenaInfo"
end
--领取排名奖励
function arena_getPositionReward(fn_cb, params)
	Network.rpc(fn_cb, "arena.getPositionReward","arena.getPositionReward", params, true)
	return "arena.getPositionReward"
end
--获取竞技排行榜
function arena_getRankList(fn_cb, params)
	Network.rpc(fn_cb, "arena.getRankList","arena.getRankList", params, true)
	return "arena.getRankList"
end

-- 获取王者对战
function arena_getReplayList(fn_cb, params)
	Network.rpc(fn_cb, "arena.getReplayList","arena.getReplayList", params, true)
	return "arena.getReplayList"
end

-- 竞技场 神秘商店信息
function arenamystshop_getShopInfo( fn_cb, params )
	Network.rpc(fn_cb, "arenamysteryshop.getShopInfo","arenamysteryshop.getShopInfo", params, true)
	return "arenamysteryshop.getShopInfo"
end

-- 进行兑换
function arenamystshop_buyGoods(fn_cb,params)
	Network.rpc(fn_cb, "arenamysteryshop.buyGoods","arenamysteryshop.buyGoods", params, true)
	return "arenamysteryshop.buyGoods"
end

-- 刷新
function arenamystshop_rfrGoodsList(fn_cb,params)
	Network.rpc(fn_cb, "arenamysteryshop.rfrGoodsList","arenamysteryshop.rfrGoodsList", params, true)
	return "arenamysteryshop.rfrGoodsList"
end

--是有可以领取奖励
function arena_hasReward(fn_cb, params)
	Network.rpc(fn_cb, "arena.hasReward","arena.hasReward", params, true)
	return "arena.hasReward"
end
--离开竞技场
function arena_leaveArena(fn_cb, params)
	Network.rpc(fn_cb, "arena.leaveArena","arena.leaveArena", params, true)
	return "arena.leaveArena"
end
-- 竞技场幸运排名
function arena_getLuckyList(fn_cb, params)
	Network.rpc(fn_cb, "arena.getLuckyList","arena.getLuckyList", params, true)
	return "arena.getLuckyList"
end

-- 购买竞技场挑战次数
function arena_buyArenaNum( fn_cb, params )
	Network.rpc(fn_cb, "arena.buyArenaNum","arena.buyArenaNum", params, true)
	return "arena.buyArenaNum"
end

-----------------------------------------------------------------------------------------------
-- 宝物合成
function trea_fuse( fn_cb, params )
	Network.rpc(fn_cb, "fragseize.fuse", "fragseize.fuse", params, true)
	return "fragseize.fuse"
end

-- 抢夺宝物
function fragseize_seizeRicher(fn_cb, params)
	Network.rpc(fn_cb, "fragseize.seizeRicher","fragseize.seizeRicher", params, true)
	return "fragseize.seizeRicher"
end

-- 购买夺宝次数
function fragseize_buySeizeNum(fn_cb, params)
	Network.rpc(fn_cb, "fragseize.buySeizeNum","fragseize.buySeizeNum", params, true)
	return "fragseize.buySeizeNum"
end

function fragseize_getEnemyFragInfo(fn_cb, params)
	Network.rpc(fn_cb, "fragseize.getEnemyFragInfo","fragseize.getEnemyFragInfo", params, true)
	return "fragseize.getEnemyFragInfo"
end

function fragseize_robEnemy(fn_cb, params)
	Network.rpc(fn_cb, "fragseize.robEnemy","fragseize.robEnemy", params, true)
	return "fragseize.robEnemy"
end

-- 宝物碎片信息
function fragseize_getSeizerInfo(fn_cb, params)
	Network.rpc(fn_cb, "fragseize.getSeizerInfo", "fragseize.getSeizerInfo", params, true)
end

------------------------Ibag-----------------------------------
--背包数据
function bag_bagInfo(fn_cb, params)
	Network.rpc(fn_cb, "bag.bagInfo","bag.bagInfo", params, true)
	return "bag.bagInfo"
end
--摧毁物品
function bag_destoryItem(fn_cb, params)
	Network.rpc(fn_cb, "bag.destoryItem","bag.destoryItem", params, true)
	return "bag.destoryItem"
end
--格子数据
function bag_gridInfo(fn_cb, params)
	Network.rpc(fn_cb, "bag.gridInfo","bag.gridInfo", params, true)
	return "bag.gridInfo"
end
--格子数据
function bag_gridInfos(fn_cb, params)
	Network.rpc(fn_cb, "bag.gridInfos","bag.gridInfos", params, true)
	return "bag.gridInfos"
end
--开启格子
function bag_openGridByGold(fn_cb, params)
	Network.rpc(fn_cb, "bag.openGridByGold","bag.openGridByGold", params, true)
	return "bag.openGridByGold"
end
--开启格子
function bag_openGridByItem(fn_cb, params)
	Network.rpc(fn_cb, "bag.openGridByItem","bag.openGridByItem", params, true)
	return "bag.openGridByItem"
end
--卖出物品
function bag_sellItem(fn_cb, params)
	Network.rpc(fn_cb, "bag.sellItem","bag.sellItem", params, true)
	return "bag.sellItem"
end
-- 批量出售
function bag_sellItems(fn_cb, params)
	Network.rpc(fn_cb, "bag.sellItems","bag.sellItems", params, true)
	return "bag.sellItems"
end
--使用物品
function bag_useItem(fn_cb, params)
	Network.rpc(fn_cb, "bag.useItem","bag.useItem", params, true)
	return "bag.useItem"
end

------------------------Ibater-----------------------------------
--
function bater_bater(fn_cb, params)
	Network.rpc(fn_cb, "bater.bater","bater.bater", params, true)
	return "bater.bater"
end
--
function bater_getBaterInfo(fn_cb, params)
	Network.rpc(fn_cb, "bater.getBaterInfo","bater.getBaterInfo", params, true)
	return "bater.getBaterInfo"
end

------------------------Ibattle-----------------------------------
--根据战斗记录签名获取战斗录相
function battle_getRecord(fn_cb, params)
	Network.rpc(fn_cb, "battle.getRecord","battle.getRecord", params, true)
	return "battle.getRecord"
end
--战报录相，如果访问一次会将这个战报标记为永久
function battle_getRecordForWeb(fn_cb, params)
	Network.rpc(fn_cb, "battle.getRecordForWeb","battle.getRecordForWeb", params, true)
	return "battle.getRecordForWeb"
end
--获取录相的url
function battle_getRecordUrl(fn_cb, params)
	Network.rpc(fn_cb, "battle.getRecordUrl","battle.getRecordUrl", params, true)
	return "battle.getRecordUrl"
end
--普通pvp战斗
function battle_test(fn_cb, params)
	Network.rpc(fn_cb, "battle.test","battle.test", params, true)
	return "battle.test"
end

------------------------Ichat-----------------------------------
--聊天模板参数
function chat_chatTemplate(fn_cb, params)
	Network.rpc(fn_cb, "chat.chatTemplate","chat.chatTemplate", params, true)
	return "chat.chatTemplate"
end
--发送系统广播消息
function chat_sendBroadCast(fn_cb, params)
	Network.rpc(fn_cb, "chat.sendBroadCast","chat.sendBroadCast", params, true)
	return "chat.sendBroadCast"
end
--同一个副本的消息
function chat_sendCopy(fn_cb, params)
	Network.rpc(fn_cb, "chat.sendCopy","chat.sendCopy", params, true)
	return "chat.sendCopy"
end
--同一个工会的消息
function chat_sendGuild(fn_cb, params)
	Network.rpc(fn_cb, "chat.sendGuild","chat.sendGuild", params, true)
	return "chat.sendGuild"
end
--私人聊天
function chat_sendPersonal(fn_cb, params)
	Network.rpc(fn_cb, "chat.sendPersonal","chat.sendPersonal", params, true)
	return "chat.sendPersonal"
end
--世界消息
function chat_sendWorld(fn_cb, params)
	Network.rpc(fn_cb, "chat.sendWorld","chat.sendWorld", params, true)
	return "chat.sendWorld"
end

------------------------Idivine-----------------------------------
--占卜一颗星星
function divine_divi(fn_cb, params)
	Network.rpc(fn_cb, "divine.divi","divine.divi", params, true)
	return "divine.divi"
end
--领取奖励
function divine_drawPrize(fn_cb, params)
	Network.rpc(fn_cb, "divine.drawPrize","divine.drawPrize", params, true)
	return "divine.drawPrize"
end
--获取占星信息
function divine_getDiviInfo(fn_cb, params)
	Network.rpc(fn_cb, "divine.getDiviInfo","divine.getDiviInfo", params, true)
	return "divine.getDiviInfo"
end
--刷新当前占星星座
function divine_refreshCurstar(fn_cb, params)
	Network.rpc(fn_cb, "divine.refreshCurstar","divine.refreshCurstar", params, true)
	return "divine.refreshCurstar"
end
--升级奖励表
function divine_upgrade(fn_cb, params)
	Network.rpc(fn_cb, "divine.upgrade","divine.upgrade", params, true)
	return "divine.upgrade"
end
--刷新奖励表
function divine_refPrize(fn_cb, params)
	Network.rpc(fn_cb, "divine.refPrize","divine.refPrize", params, true)
	return "divine.refPrize"
end
------------------------Iecopy-----------------------------------
--精英副本的战斗接口
function ecopy_doBattle(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.doBattle","ecopy.doBattle", params, true)
	return "ecopy.doBattle"
end
--判断是否能够进入某副本进行攻击
function ecopy_enterCopy(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.enterCopy","ecopy.enterCopy", params, true)
	return "ecopy.enterCopy"
end
--返回副本攻击的攻略以及排名信息
function ecopy_getCopyDefeatInfo(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.getCopyDefeatInfo","ecopy.getCopyDefeatInfo", params, true)
	return "ecopy.getCopyDefeatInfo"
end
--返回精英副本模块的信息 包括可以挑战次数、副本的攻击进度
function ecopy_getEliteCopyInfo(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.getEliteCopyInfo","ecopy.getEliteCopyInfo", params, true)
	return "ecopy.getEliteCopyInfo"
end
--离开副本 应用场景：战斗成功或者失败之后点击返回按钮
function ecopy_leaveCopy(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.leaveCopy","ecopy.leaveCopy", params, true)
	return "ecopy.leaveCopy"
end
--重新攻击某据点难度级别 应用场景：攻击失败之后点击重新攻击按钮
function ecopy_reFight(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.reFight","ecopy.reFight", params, true)
	return "ecopy.reFight"
end
--更新在某个战斗中死亡的卡牌的血量为满血
function ecopy_reviveCard(fn_cb, params)
	Network.rpc(fn_cb, "ecopy.reviveCard","ecopy.reviveCard", params, true)
	return "ecopy.reviveCard"
end

------------------------Iforge-----------------------------------

--装备附魔
function forge_enchant(fn_cb, params)
	Network.rpc(fn_cb, "forge.enchant","forge.enchant", params, true)
	return "forge.enchant"
end

--固定洗练：银币洗练、专家洗练、大师洗练、宗师洗练
function forge_fixedRefresh(fn_cb, params)
	Network.rpc(fn_cb, "forge.fixedRefresh","forge.fixedRefresh", params, true)
	return "forge.fixedRefresh"
end
--固定洗练确认
function forge_fixedRefreshAffirm(fn_cb, params)
	Network.rpc(fn_cb, "forge.fixedRefreshAffirm","forge.fixedRefreshAffirm", params, true)
	return "forge.fixedRefreshAffirm"
end
--获得潜能转移的信息
function forge_getPotenceTransferInfo(fn_cb, params)
	Network.rpc(fn_cb, "forge.getPotenceTransferInfo","forge.getPotenceTransferInfo", params, true)
	return "forge.getPotenceTransferInfo"
end
--潜能转移
function forge_potenceTransfer(fn_cb, params)
	Network.rpc(fn_cb, "forge.potenceTransfer","forge.potenceTransfer", params, true)
	return "forge.potenceTransfer"
end
--随机洗练：银币洗练、金币洗练
function forge_randRefresh(fn_cb, params)
	Network.rpc(fn_cb, "forge.randRefresh","forge.randRefresh", params, true)
	return "forge.randRefresh"
end
--随机洗练确认
function forge_randRefreshAffirm(fn_cb, params)
	Network.rpc(fn_cb, "forge.randRefreshAffirm","forge.randRefreshAffirm", params, true)
	return "forge.randRefreshAffirm"
end
--强化物品
function forge_reinforce(fn_cb, params)
	Network.rpc(fn_cb, "forge.reinforce","forge.reinforce", params, true)
	return "forge.reinforce"
end
-- 强化宝物
function forge_upgradeTreas(fn_cb, params)
	Network.rpc(fn_cb, "forge.upgrade","forge.upgrade", params, true)
	return "forge.upgrade"
end

-- 装备自动强化
function forge_autoReinforceArm(fn_cb, params)
	Network.rpc(fn_cb, "forge.autoReinforce","forge.autoReinforce", params, true)
	return "forge.autoReinforce"
end

-- 强化大师－一键强化身上所有装备
function forge_autoReinforceAll(fn_cb, params)
	Network.rpc(fn_cb, "forge.autoReinforceAll","forge.autoReinforceAll", params, true)
	return "forge.autoReinforceAll"
end

------------------------Iformation-----------------------------------
--在我的阵容中添加一个武将
function formation_addHero(fn_cb, params)
	Network.rpc(fn_cb, "formation.addHero","formation.addHero", params, true)
end
--在我的阵容中添加一个小伙伴
function formation_addExtra(fn_cb, params)
	Network.rpc(fn_cb, "formation.addExtra","formation.addExtra", params, true)
end
--在我的阵容中删除一个小伙伴
function formation_delExtra(fn_cb, params)
	Network.rpc(fn_cb, "formation.delExtra","formation.delExtra", params, true)
end
--从我的阵容中删除一个武将
function formation_delHero(fn_cb, params)
	Network.rpc(fn_cb, "formation.delHero","formation.delHero", params, true)
end
--返回阵型信息
function formation_getFormation(fn_cb, params)
	Network.rpc(fn_cb, "formation.getFormation","formation.getFormation", params, true)
end
--返回“我的阵容”
function formation_getSquad(fn_cb, params)
	Network.rpc(fn_cb, "formation.getSquad","formation.getSquad", params, true)
end
--返回“我的小伙伴”
function formation_getExtraFriend(fn_cb, params)
	Network.rpc(fn_cb, "formation.getExtra","formation.getExtra", params, true)
end
--保存用户设置的阵型信息
function formation_setFormation(fn_cb, params)
	Network.rpc(fn_cb, "formation.setFormation","formation.setFormation", params, true)
end
--在我的小伙伴一键上阵最好的伙伴
function formation_bestExtra(fn_cb, params)
	Network.rpc(fn_cb, "formation.bestExtra","formation.bestExtra", params, true)
end
--添加一个替补
function formation_addBench(fn_cb, params)
	Network.rpc(fn_cb, "formation.addBench","formation.addBench", params, true)
end
--返回“替补”
function formation_getBench(fn_cb, params)
	Network.rpc(fn_cb, "formation.getBench","formation.getBench", params, true)
end
------------------------IFightSoul--------------------------------
function hero_equipBestFightSoul(fn_cb, params)
	Network.rpc(fn_cb, "hero.equipBestFightSoul" ,"hero.equipBestFightSoul", params, true)
end
------------------------Ifriend-----------------------------------
--添加好友
function friend_addFriend (fn_cb, params)
	Network.rpc(fn_cb, "friend.addFriend","friend.addFriend", params, true)
end
--申请好友
function friend_applyFriend(fn_cb, params)
	Network.rpc(fn_cb, "friend.applyFriend","friend.applyFriend", params, true)
end
--删除好友
function friend_delFriend(fn_cb, params)
	Network.rpc(fn_cb, "friend.delFriend","friend.delFriend", params, true)
end
--获取单个好友信息
function friend_getFriendInfo(fn_cb, params)
	Network.rpc(fn_cb, "friend.getFriendInfo","friend.getFriendInfo", params, true)
end
--获取系统推荐好友信息
function friend_getFriendInfoList(fn_cb, params)
	Network.rpc(fn_cb, "friend.getFriendInfoList","friend.getFriendInfoList", params, true)
end

-- 获取好友申请数据(使用的邮件好友)
function friend_getFriendApplyInfo( fn_cb, params )
	Network.rpc(fn_cb, "mail.getPlayMailList","mail.getPlayMailList", params, true)
end


--随机洗练确认
function friend_getRecomdFriends(fn_cb, params)
	Network.rpc(fn_cb, "friend.getRecomdFriends","friend.getRecomdFriends", params, true)
end
--根据用户名模糊搜索
function friend_getRecomdByName(fn_cb, params)
	Network.rpc(fn_cb, "friend.getRecomdByName","friend.getRecomdByName", params, true)
end
--是否为自己的好友
function friend_isFriend(fn_cb, params)
	Network.rpc(fn_cb, "friend.isFriend","friend.isFriend", params, true)
end
--拒绝好友
function friend_rejectFriend(fn_cb, params)
	Network.rpc(fn_cb, "friend.rejectFriend","friend.rejectFriend", params, true)
end
--赠送好友耐力
function friend_loveFriend(fn_cb, params)
	Network.rpc(fn_cb, "friend.loveFriend", "friend.loveFriend", params, true)
end
--可领取耐力列表
function friend_receiveLoveList(fn_cb)
	Network.rpc(fn_cb, "friend.unreceiveLoveList", "friend.unreceiveLoveList", nil, true)
end
--领取所有耐力
function friend_reveiveAllLove(fn_cb)
	Network.rpc(fn_cb, "friend.receiveAllLove", "friend.receiveAllLove", nil, true)
end
--领取某一被赠体力
function friend_reveiveLove(fn_cb,params)
	Network.rpc(fn_cb, "friend.receiveLove", "friend.receiveLove", params, true)
end

------------------------Igm-----------------------------------
--获取服务器时间
function gm_getTime(fn_cb, params)
	Network.rpc(fn_cb, "gm.getTime","gm.getTime", params, true)
	return "gm.getTime"
end
--通知前端收到新的公告
function gm_newBroadCast(fn_cb, params)
	Network.rpc(fn_cb, "gm.newBroadCast","gm.newBroadCast", params, true)
	return "gm.newBroadCast"
end
--通知前端收到新的测试公告
function gm_newBroadCastTest(fn_cb, params)
	Network.rpc(fn_cb, "gm.newBroadCastTest","gm.newBroadCastTest", params, true)
	return "gm.newBroadCastTest"
end
--前端的错误信息
function gm_reportClientError(fn_cb, params)
	Network.rpc(fn_cb, "gm.reportClientError","gm.reportClientError", params, true)
	return "gm.reportClientError"
end
--发送开服竞技场排行奖励
function gm_sendRankingActivityArenaReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityArenaReward","gm.sendRankingActivityArenaReward", params, true)
	return "gm.sendRankingActivityArenaReward"
end
--发送开服副本排行奖励
function gm_sendRankingActivityCopyReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityCopyReward","gm.sendRankingActivityCopyReward", params, true)
	return "gm.sendRankingActivityCopyReward"
end
--发送开服公会排行奖励
function gm_sendRankingActivityGuildReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityGuildReward","gm.sendRankingActivityGuildReward", params, true)
	return "gm.sendRankingActivityGuildReward"
end
--发送开服等级排行奖励
function gm_sendRankingActivityLevelReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityLevelReward","gm.sendRankingActivityLevelReward", params, true)
	return "gm.sendRankingActivityLevelReward"
end
--发送开服悬赏排行奖励
function gm_sendRankingActivityOfferReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityOfferReward","gm.sendRankingActivityOfferReward", params, true)
	return "gm.sendRankingActivityOfferReward"
end
--发送开服声望排行奖励
function gm_sendRankingActivityPrestigeReward(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendRankingActivityPrestigeReward","gm.sendRankingActivityPrestigeReward", params, true)
	return "gm.sendRankingActivityPrestigeReward"
end
--发送系统邮件(一个邮件最多携带5个物品)
function gm_sendSysMail(fn_cb, params)
	Network.rpc(fn_cb, "gm.sendSysMail","gm.sendSysMail", params, true)
	return "gm.sendSysMail"
end

------------------------IgrowUp-----------------------------------
--激活计划
function growUp_activation(fn_cb, params)
	Network.rpc(fn_cb, "growup.activation","growup.activation", params, true)
	return "growup.activation"
end
--获取奖励
function growup_fetchPrize(fn_cb, params)
	Network.rpc(fn_cb, "growup.fetchPrize","growup.fetchPrize", params, true)
	return "growup.fetchPrize"
end
--获取用户成长计划
function growUp_getInfo(fn_cb, params)
	Network.rpc(fn_cb, "growup.getInfo","growup.getInfo", params, true)
	return "growup.getInfo"
end

------------------------Ihero-----------------------------------
--一键装备
function hero_equipBestArming( fn_cb, params)
	Network.rpc(fn_cb, "hero.equipBestArming","hero.equipBestArming", params, true)
	return "hero.equipBestArming"
end
--一键装备空岛贝
function hero_equipBestConch( fn_cb, params)
	Network.rpc(fn_cb, "hero.equipBestConch","hero.equipBestConch", params, true)
	return "hero.equipBestConch"
end
--升级空岛贝
function upgradeConch( fn_cb,params)
	Network.rpc(fn_cb, "forge.promote", "forge.promote", params, true)
	return "forge.promote"
end

--装备装备
function hero_addArming(fn_cb, params)
	Network.rpc(fn_cb, "hero.addArming","hero.addArming", params, true)
	return "hero.addArming"
end
--装备空岛贝
function hero_addConch(fn_cb, params)
	Network.rpc(fn_cb, "hero.addConch","hero.addConch", params, true)
	return "hero.addConch"
end
--装备宝物
function hero_addTreasure(fn_cb, params)
	Network.rpc(fn_cb, "hero.addTreasure","hero.addTreasure", params, true)
	return "hero.addTreasure"
end
--强化武将--将魂
function hero_enforce(fn_cb, params)
	Network.rpc(fn_cb, "hero.enforce","hero.enforce", params, true)
	return "hero.enforce"
end
--强化武将--将魂
function hero_enforce(fn_cb, params)
	Network.rpc(fn_cb, "hero.enforce","hero.enforce", params, true)
	return "hero.enforce"
end
--强化武将--影子--update by xianghuiZhang at 20140704
function hero_enforceByHeroFrag(fn_cb, params)
	Network.rpc(fn_cb, "hero.enforceByHeroFrag","hero.enforceByHeroFrag", params, true)
	return "hero.enforceByHero"
end
--武将进化
function hero_evolve(fn_cb, params)
	Network.rpc(fn_cb, "hero.evolve","hero.evolve", params, true)
	return "hero.evolve"
end
--武将突破
function hero_heroBreak(fn_cb, params)
	Network.rpc(fn_cb, "hero.heroBreak","hero.heroBreak", params, true)
	return "hero.heroBreak"
end
-- 武将书, 获取所有招募过的武将信息
function hero_getHeroBook(fn_cb, params)
	Network.rpc(fn_cb, "hero.getHeroBook","hero.getHeroBook", params, true)
	return "hero.getHeroBook"
end
--这个接口不用实现，前端可以从背包数据中得到所有的武将碎片数据
function hero_getAllFragments(fn_cb, params)
	Network.rpc(fn_cb, "hero.getAllFragments","hero.getAllFragments", params, true)
	return "hero.getAllFragments"
end
--返回用户所有的武将. 这个接口最好只在登录时调用一次，之后都传增量数据
function hero_getAllHeroes(fn_cb, params)
	print("haha RequestCenter hero_getAllHeroes")
	Network.rpc(fn_cb, "hero.getAllHeroes","hero.getAllHeroes", params, true)
	return "hero.getAllHeroes"
end
--开启技能书栏位
function hero_openSkillBookPos(fn_cb, params)
	Network.rpc(fn_cb, "hero.openSkillBookPos","hero.openSkillBookPos", params, true)
	return "hero.openSkillBookPos"
end
--卸载装备
function hero_removeArming(fn_cb, params)
	Network.rpc(fn_cb, "hero.removeArming","hero.removeArming", params, true)
	return "hero.removeArming"
end
--卸载空岛贝
function hero_removeConch(fn_cb, params)
	Network.rpc(fn_cb, "hero.removeConch","hero.removeConch", params, true)
	return "hero.removeConch"
end
--卸载宝物
function hero_removeTreasure(fn_cb, params)
	Network.rpc(fn_cb, "hero.removeTreasure","hero.removeTreasure", params, true)
	return "hero.removeTreasure"
end
--移除某个栏位的技能书
function hero_removeSkillBook(fn_cb, params)
	Network.rpc(fn_cb, "hero.removeSkillBook","hero.removeSkillBook", params, true)
	return "hero.removeSkillBook"
end
--分解武将
function hero_resolve(fn_cb, params)
	Network.rpc(fn_cb, "hero.resolve","hero.resolve", params, true)
	return "hero.resolve"
end
--卖出武将
function hero_sell(fn_cb, params)
	Network.rpc(fn_cb, "hero.sell","hero.sell", params, true)
	return "hero.sell"
end

------------------------IILevelfund ----------------------------
-- 'ok' gainLevelfundPrize (int $id)
function levelfund_gainLevelfundPrize(fn_cb, params)
	Network.rpc(fn_cb, "levelfund.gainLevelfundPrize","levelfund.gainLevelfundPrize", params, true)
	return "levelfund.gainLevelfundPrize"
end
-- 获取升级嘉奖活动信息
function levelfund_getLevelfundInfo(fn_cb, params)
	Network.rpc(fn_cb, "levelfund.getLevelfundInfo","levelfund.getLevelfundInfo", params, true)
	return "levelfund.getLevelfundInfo"
end

------------------------Ipet -----------------------------------
-- 添加宠物
function pet_addPet(fn_cb, params)
	Network.rpc(fn_cb, "pet.addPet","pet.addPet", params, true)
	return "pet.addPet"
end
-- 添加宠物
function pet_addPetUseItem(fn_cb, params)
	Network.rpc(fn_cb, "pet.addPetUseItem","pet.addPetUseItem", params, true)
	return "pet.addPetUseItem"
end
-- 获取金币喂养的次数
function pet_getGoldFeedTimes(fn_cb, params)
	Network.rpc(fn_cb, "pet.getGoldFeedTimes","pet.getGoldFeedTimes", params, true)
	return "pet.getGoldFeedTimes"
end
--喂养宠物（金币）
function pet_feedPetByGold(fn_cb, params)
	Network.rpc(fn_cb, "pet.feedPetByGold","pet.feedPetByGold", params, true)
	return "pet.feedPetByGold"
end
-- 喂养宠物（物品）
function pet_feedPetByItem(fn_cb, params)
	Network.rpc(fn_cb, "pet.feedPetByItem","pet.feedPetByItem", params, true)
	return "pet.feedPetByItem"
end
-- 喂养宠物 （一键喂养）
function pet_feedToLimitation(fn_cb, params)
	Network.rpc(fn_cb, "pet.feedToLimitation","pet.feedToLimitation", params, true)
	return "pet.feedToLimitation"
end
--获取宠物
function pet_getAllPet(fn_cb, params)
	Network.rpc(fn_cb, "pet.getAllPet","pet.getAllPet", params, true)
	return "pet.getAllPet"
end

------------------------Ilevelfund-----------------------------------
--获取升级嘉奖活动信息
function levelfund_getLevelfundInfo(fn_cb, params)
	Network.rpc(fn_cb, "levelfund.getLevelfundInfo","levelfund.getLevelfundInfo", params, true)
	return "levelfund.getLevelfundInfo"
end
--获取奖励
function levelfund_getLevelfundPrize(fn_cb, params)
	Network.rpc(fn_cb, "levelfund.getLevelfundPrize","levelfund.getLevelfundPrize", params, true)
	return "levelfund.getLevelfundPrize"
end

------------------------Imail-----------------------------------
--删除所有战报邮件
function mail_deleteAllBattleMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.deleteAllBattleMail","mail.deleteAllBattleMail", params, true)
	return "mail.deleteAllBattleMail"
end
--删除所有收件箱邮件
function mail_deleteAllMailBoxMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.deleteAllMailBoxMail","mail.deleteAllMailBoxMail", params, true)
	return "mail.deleteAllMailBoxMail"
end
--删除所有用户邮件
function mail_deleteAllPlayerMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.deleteAllPlayerMail","mail.deleteAllPlayerMail", params, true)
	return "mail.deleteAllPlayerMail"
end
--删除所有系统邮件
function mail_deleteAllSystemMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.deleteAllSystemMail","mail.deleteAllSystemMail", params, true)
	return "mail.deleteAllSystemMail"
end
--删除邮件
function mail_deleteMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.deleteMail","mail.deleteMail", params, true)
	return "mail.deleteMail"
end
--获取某个邮件里的所有物品
function mail_fetchAllItems(fn_cb, params)
	Network.rpc(fn_cb, "mail.fetchAllItems","mail.fetchAllItems", params, true)
	return "mail.fetchAllItems"
end
--获取某个邮件里的物品
function mail_fetchItem(fn_cb, params)
	Network.rpc(fn_cb, "mail.fetchItem","mail.fetchItem", params, true)
	return "mail.fetchItem"
end
--得到战报邮件列表
function mail_getBattleMailList(fn_cb, params)
	Network.rpc(fn_cb, "mail.getBattleMailList","mail.getBattleMailList", params, true)
	return "mail.getBattleMailList"
end
--获取收件箱列表
function mail_getMailBoxList(fn_cb, params)
	Network.rpc(fn_cb, "mail.getMailBoxList","mail.getMailBoxList", params, true)
	return "mail.getMailBoxList"
end
--得到用户邮件列表
function mail_getPlayMailList(fn_cb, params)
	Network.rpc(fn_cb, "mail.getPlayMailList","mail.getPlayMailList", params, true)
	return "mail.getPlayMailList"
end
--获取物品邮件列表
function mail_getSysItemMailList(fn_cb, params)
	Network.rpc(fn_cb, "mail.getSysItemMailList","mail.getSysItemMailList", params, true)
	return "mail.getSysItemMailList"
end
--获取系统邮件列表
function mail_getSysMailList(fn_cb, params)
	Network.rpc(fn_cb, "mail.getSysMailList","mail.getSysMailList", params, true)
	return "mail.getSysMailList"
end
--发送普通邮件
function mail_sendMail(fn_cb, params)
	Network.rpc(fn_cb, "mail.sendMail","mail.sendMail", params, true)
	return "mail.sendMail"
end

------------------------Imineral-----------------------------------
--占领某个矿坑
function mineral_capturePit(fn_cb, params)
	Network.rpc(fn_cb, "mineral.capturePit","mineral.capturePit", params, true)
	return "mineral.capturePit"
end
--探索空旷（一键探索） 找出没有空旷的矿页 返回此页的矿信息
function mineral_explorePit(fn_cb, params)
	Network.rpc(fn_cb, "mineral.explorePit","mineral.explorePit", params, true)
	return "mineral.explorePit"
end
--获得信息
function mineral_getPitInfo(fn_cb, params)
	Network.rpc(fn_cb, "mineral.getPitInfo","mineral.getPitInfo", params, true)
	return "mineral.getPitInfo"
end
--获取某个资源区的所有矿坑信息
function mineral_getPitsByDomain(fn_cb, params)
	Network.rpc(fn_cb, "mineral.getPitsByDomain","mineral.getPitsByDomain", params, true)
	return "mineral.getPitsByDomain"
end
--获取玩家占领的矿坑的信息
function mineral_getSelfPitsInfo(fn_cb, params)
	Network.rpc(fn_cb, "mineral.getSelfPitsInfo","mineral.getSelfPitsInfo", params, true)
	return "mineral.getSelfPitsInfo"
end
--放弃某个矿坑
function mineral_giveUpPit(fn_cb, params)
	Network.rpc(fn_cb, "mineral.giveUpPit","mineral.giveUpPit", params, true)
	return "mineral.giveUpPit"
end

------------------------Incopy-----------------------------------
--战斗接口
function ncopy_doBattle(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.doBattle","ncopy.doBattle", params, true)
	return "ncopy.doBattle"
end
--判断是否可以进入某据点
function ncopy_enterBase(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.enterBase","ncopy.enterBase", params, true)
	return "ncopy.enterBase"
end
--判断是否可以进入某据点某难度级别进行攻击
function ncopy_enterBaseLevel(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.enterBaseLevel","ncopy.enterBaseLevel", params, true)
	return "ncopy.enterBaseLevel"
end
--判断是否可以进入副本 返回副本的具体信息
function ncopy_enterCopy(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.enterCopy","ncopy.enterCopy", params, true)
	return "ncopy.enterCopy"
end
--非正常方式退出游戏之后 在进入游戏 返回给前端上次的进度
function ncopy_getAtkInfoOnEnterGame(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.getAtkInfoOnEnterGame","ncopy.getAtkInfoOnEnterGame", params, true)
	return "ncopy.getAtkInfoOnEnterGame"
end
--返回据点攻击的攻略以及排名信息
function ncopy_getBaseDefeatInfo(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.getBaseDefeatInfo","ncopy.getBaseDefeatInfo", params, true)
	return "ncopy.getBaseDefeatInfo"
end
--获取玩家的所有普通副本
function ncopy_getCopyList(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.getCopyList","ncopy.getCopyList", params, true)
	return "ncopy.getCopyList"
end
--获取攻击据点的玩家排名信息（前十通关据点的玩家信息）
function ncopy_getCopyRank(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.getCopyRank","ncopy.getCopyRank", params, true)
	return "ncopy.getCopyRank"
end
--领取副本奖励
function ncopy_getPrize(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.fetchStarBoxReward","ncopy.fetchStarBoxReward", params, true)
	return "ncopy.fetchStarBoxReward"
end
--领取副本据点通关奖励
function ncopy_getPassPrize(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.fetchPassBoxReward","ncopy.fetchPassBoxReward", params, true)
	return "ncopy.fetchPassBoxReward"
end
--离开据点某难度级别 应用场景：攻击成功或者失败后点击返回按钮
function ncopy_leaveBaseLevel(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.leaveBaseLevel","ncopy.leaveBaseLevel", params, true)
	return "ncopy.leaveBaseLevel"
end
--获取物品邮件列表
function ncopy_leaveNCopy(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.leaveNCopy","ncopy.leaveNCopy", params, true)
	return "ncopy.leaveNCopy"
end
--退出普通副本 清空服务器中session信息
function ncopy_getSysMailList(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.getSysMailList","ncopy.getSysMailList", params, true)
	return "ncopy.getSysMailList"
end
--重新攻击某据点难度级别 应用场景：攻击失败之后点击重新攻击按钮
function ncopy_reFight(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.reFight","ncopy.reFight", params, true)
	return "ncopy.reFight"
end
--重新攻击某据点难度级别 应用场景：攻击失败之后点击重新攻击按钮
function ncopy_reviveCard(fn_cb, params)
	Network.rpc(fn_cb, "ncopy.reviveCard","ncopy.reviveCard", params, true)
	return "ncopy.reviveCard"
end

------------------------Ionline-----------------------------------
--领取在线奖励
function online_gainGift(fn_cb, params)
	Network.rpc(fn_cb, "online.gainGift","online.gainGift", params, true)
	return "online.gainGift"
end
--获取在线奖励信息
function online_getOnlineInfo(fn_cb, params)
	Network.rpc(fn_cb, "online.getOnlineInfo","online.getOnlineInfo", params, true)
	return "online.getOnlineInfo"
end

------------------------Ireward-----------------------------------
-- 礼包卡换礼品
function reward_getGiftByCode(fn_cb, params)
	Network.rpc(fn_cb, "reward.getGiftByCode","reward.getGiftByCode", params, true)
	return "reward.getGiftByCode"
end
--获取玩家未领取的奖励列表
function reward_getRewardList(fn_cb, params)
	Network.rpc(fn_cb, "reward.getRewardList","reward.getRewardList", params, true)
	return "reward.getRewardList"
end
-- 批量领取奖励
function reward_receiveByRidArr(fn_cb, params)
	Network.rpc(fn_cb, "reward.receiveByRidArr","reward.receiveByRidArr", params, true)
	return "reward.receiveByRidArr"
end
--领取奖励
function reward_receiveReward(fn_cb, params)
	Network.rpc(fn_cb, "reward.receiveReward","reward.receiveReward", params, true)
	return "reward.receiveReward"
end

------------------------Ishop-----------------------------------
-- 酒馆获取神秘招募信息
function shop_getRecruitInfo( fn_cb, params )
	Network.rpc(fn_cb, "shop.getRecruitInfo","shop.getRecruitInfo", params, true)
	return "shop.getRecruitInfo"
end

-- 酒馆神秘招募
function shop_mysteryRecruit( fn_cb, params )
	Network.rpc(fn_cb, "shop.mysteryRecruit","shop.mysteryRecruit", params, true)
	return "shop.mysteryRecruit"
end

--酒馆青铜招将
function shop_bronzeRecruit(fn_cb, params)
	Network.rpc(fn_cb, "shop.bronzeRecruit","shop.bronzeRecruit", params, true)
	return "shop.bronzeRecruit"
end
--获取用户酒馆信息
function shop_getShopInfo(fn_cb, params)
	Network.rpc(fn_cb, "shop.getShopInfo","shop.getShopInfo", params, true)
	return "shop.getShopInfo"
end
--领取VIP奖励
function shop_getVipReward(fn_cb, params)
	Network.rpc(fn_cb, "shop.getVipReward","shop.getVipReward", params, true)
	return "shop.getVipReward"
end
--酒馆黄金招将
function shop_goldRecruit(fn_cb, params)
	Network.rpc(fn_cb, "shop.goldRecruit","shop.goldRecruit", params, true)
	return "shop.goldRecruit"
end
--酒馆白银招将
function shop_silverRecruit(fn_cb, params)
	Network.rpc(fn_cb, "shop.silverRecruit","shop.silverRecruit", params, true)
	return "shop.silverRecruit"
end
--酒馆黄金招将确认
function shop_goldRecruitConfirm(fn_cb, params)
	Network.rpc(fn_cb, "shop.goldRecruitConfirm","shop.goldRecruitConfirm", params, true)
	return "shop.goldRecruitConfirm"
end
--酒馆黄金招将确认
function shop_buyGoods(fn_cb, params)
	Network.rpc(fn_cb, "shop.buyGoods","shop.buyGoods", params, true)
	return "shop.buyGoods"
end

--购买物品时 连续发送两个同样的请求,为了防止第二个请求返回有问题，做一个区分
function shop_buyKey(fn_cb, params)
	Network.rpc(fn_cb, "shop.buyKey","shop.buyGoods", params, true)
	return "shop.buyGoods"
end

--获取购买箱子的信息
function shop_getBoxInfo(fn_cb, params)
	Network.rpc(fn_cb, "shop.getBoxInfo","shop.getBoxInfo", params, true)
	return "shop.getBoxInfo"
end

--购买并开启箱子
function shop_openBox(fn_cb, params)
	Network.rpc(fn_cb, "shop.openBox","shop.openBox", params, true)
	return "shop.openBox"
end
-------------------------  IShopExchange ------------------------
--商店兑换武将碎片
function shopexchange_buy(fn_cb, params)
	Network.rpc(fn_cb, "shopexchange.buy","shopexchange.buy", params, true)
	return "shopExchange.buy"
end

------------------------Isign-----------------------------------
-- 签到基本信息
function sign_getNormalInfo(fn_cb, params)
	Network.rpc(fn_cb, "sign.getNormalInfo" , "sign.getNormalInfo", params , true)
end
--领取累积签到奖励
function sign_gainAccSignReward(fn_cb, params)
	Network.rpc(fn_cb, "sign.gainAccSignReward","sign.gainAccSignReward", params, true)
	return "sign.gainAccSignReward"
end
--领取连续签到奖励
function sign_gainNormalSignReward(fn_cb, params)
	Network.rpc(fn_cb, "sign.gainNormalSignReward","sign.gainNormalSignReward", params, true)
	return "sign.gainNormalSignReward"
end
--获取签到信息
function sign_getSignInfo(fn_cb, params)
	Network.rpc(fn_cb, "sign.getSignInfo","sign.getSignInfo", params, true)
	return "sign.getSignInfo"
end
--签到
function sign_signToday(fn_cb, params)
	Network.rpc(fn_cb, "sign.signToday","sign.signToday", params, true)
	return "sign.signToday"
end
--连续签到奖励升级
function sign_signUpgrade(fn_cb, params)
	Network.rpc(fn_cb, "sign.signUpgrade","sign.signUpgrade", params, true)
	return "sign.signUpgrade"
end
-- 礼包
function sign_getAccInfo(fn_cb, params)
	Network.rpc(fn_cb, "sign.getAccInfo" , "sign.getAccInfo", params , true)
end

------------------------Ispend-----------------------------------
--得到消费累计信息
function spend_getInfo(fn_cb, params)
	Network.rpc(fn_cb, "spend.getInfo","spend.getInfo", params, true)
	return "spend.getInfo"
end
--得到奖励
function spend_getReward(fn_cb, params)
	Network.rpc(fn_cb, "spend.getReward","spend.getReward", params, true)
	return "spend.getReward"
end

------------------------Istar-----------------------------------
--通过行为事件增进名将的感情
function star_addFavorByAct(fn_cb, params)
	Network.rpc(fn_cb, "star.addFavorByAct","star.addFavorByAct", params, true)
	return "star.addFavorByAct"
end
--通过赠送礼物增加名将的好感度
function star_addFavorByGift(fn_cb, params)
	Network.rpc(fn_cb, "star.addFavorByGift","star.addFavorByGift", params, true)
	return "star.addFavorByGift"
end
--通过赠送金币增加名将的好感度
function star_addFavorByGold(fn_cb, params)
	Network.rpc(fn_cb, "star.addFavorByGold","star.addFavorByGold", params, true)
	return "star.addFavorByGold"
end
--答题
function star_answer(fn_cb, params)
	Network.rpc(fn_cb, "star.answer","star.answer", params, true)
	return "star.answer"
end
--进入后宫，获取用户拥有的所有名将信息
function star_getAllStarInfo(fn_cb, params)
	Network.rpc(fn_cb, "star.getAllStarInfo","star.getAllStarInfo", params, true)
	return "star.getAllStarInfo"
end
--获取用户的仇人列表
function star_getFoeList(fn_cb, params)
	Network.rpc(fn_cb, "star.getFoeList","star.getFoeList", params, true)
	return "star.getFoeList"
end
--获取用户的打劫玩家列表
function star_getRobList(fn_cb, params)
	Network.rpc(fn_cb, "star.getRobList","star.getRobList", params, true)
	return "star.getRobList"
end
--离开后宫
function star_leaveHarem(fn_cb, params)
	Network.rpc(fn_cb, "star.leaveHarem","star.leaveHarem", params, true)
	return "star.leaveHarem"
end
--刷新用户的打劫玩家列表
function star_refreshRobList(fn_cb, params)
	Network.rpc(fn_cb, "star.refreshRobList","star.refreshRobList", params, true)
	return "star.refreshRobList"
end
--打劫
function star_rob(fn_cb, params)
	Network.rpc(fn_cb, "star.rob","star.rob", params, true)
	return "star.rob"
end

------------------------ ISupply --------------------------------
--获取补给信息； 暂定体力领取时间为每日的12点至13点，18点至19点； 根据用户领取时间来判定是否领取过
function supply_getSupplyInfo(fn_cb, params)
	Network.rpc(fn_cb, "supply.getSupplyInfo","supply.getSupplyInfo", params, true)
	return "supply.getSupplyInfo"
end
--补给：加体力50点
function supply_supplyExecution(fn_cb, params)
	Network.rpc(fn_cb, "supply.supplyExecution","supply.supplyExecution", params, true)
	return "supply.supplyExecution"
end

------------------------Itower-----------------------------------
--购买挑战次数
function tower_buyDefeatNum(fn_cb, params)
	Network.rpc(fn_cb, "tower.buyDefeatNum","tower.buyDefeatNum", params, true)
	return "tower.buyDefeatNum"
end
--击败塔层中的怪物
function tower_defeatMonster(fn_cb, params)
	Network.rpc(fn_cb, "tower.defeatMonster","tower.defeatMonster", params, true)
	return "tower.defeatMonster"
end
--通关某个塔层之后进行抽奖
function tower_doLottery(fn_cb, params)
	Network.rpc(fn_cb, "tower.doLottery","tower.doLottery", params, true)
	return "tower.doLottery"
end
--通关某个塔层之后使用金币进行抽奖
function tower_doLotteryByGold(fn_cb, params)
	Network.rpc(fn_cb, "tower.doLotteryByGold","tower.doLotteryByGold", params, true)
	return "tower.doLotteryByGold"
end
--进入某个塔层进行攻击
function tower_enterLevel(fn_cb, params)
	Network.rpc(fn_cb, "tower.enterLevel","tower.enterLevel", params, true)
	return "tower.enterLevel"
end
--获取某个用户的爬塔系统的信息
function tower_getTowerInfo(fn_cb, params)
	Network.rpc(fn_cb, "tower.getTowerInfo","tower.getTowerInfo", params, true)
	return "tower.getTowerInfo"
end
-- 重置爬塔
function tower_resetTower( fn_cb, params )
	Network.rpc(fn_cb, "tower.resetTower","tower.resetTower", params, true)
	return "tower.resetTower"
end
--获取用户的仇人列表
function tower_goldPass(fn_cb, params)
	Network.rpc(fn_cb, "tower.goldPass","tower.goldPass", params, true)
	return "tower.goldPass"
end
--离开某个塔层
function tower_leaveLevel(fn_cb, params)
	Network.rpc(fn_cb, "tower.leaveTowerLv","tower.leaveTowerLv", params, true)
	return "tower.leaveLevel"
end
--离开爬塔系统
function tower_leaveTower (fn_cb, params)
	Network.rpc(fn_cb, "tower.leaveTower","tower.leaveTower", params, true)
	return "tower.leaveTower "
end
--爬塔排行榜
function tower_getTowerRank (fn_cb, params)
	Network.rpc(fn_cb, "tower.getTowerRank ","tower.getTowerRank", params, true)
	return "tower.getTowerRank"
end
-- 爬塔扫荡
function tower_sweep (fn_cb, params)
	Network.rpc(fn_cb, "tower.sweep ","tower.sweep", params, true)
	return "tower.sweep"
end
-- 取消扫荡
function tower_endSweep (fn_cb, params)
	Network.rpc(fn_cb, "tower.endSweep ","tower.endSweep", params, true)
	return "tower.endSweep"
end

------------------------Iuser-----------------------------------
--验证数值
function user_checkValue(fn_cb, params,flag)
	flag = flag==nil and "user.checkValue" or flag
	Network.rpc(fn_cb, flag,"user.checkValue", params, true)
	return "user.checkValue"
end
-- 更换头像
function user_setFigure( fn_cb, params )
	Network.rpc(fn_cb, "user.setFigure","user.setFigure", params, true)
	return "user.setFigure"
end
--加金币
function user_addGold4BBpay(fn_cb, params)
	Network.rpc(fn_cb, "user.addGold4BBpay","user.addGold4BBpay", params, true)
	return "user.addGold4BBpay"
end
--购买体力
function user_buyExecution(fn_cb, params)
	Network.rpc(fn_cb, "user.buyExecution","user.buyExecution", params, true)
	return "user.buyExecution"
end
--创建角色
function user_createUser(fn_cb, params)
	Network.rpc(fn_cb, "user.createUser","user.createUser", params, true)
	return "user.createUser"
end
--得到随机名字
function user_getRandomName(fn_cb, params)
	Network.rpc(fn_cb, "user.getRandomName","user.getRandomName", params, true)
	return "user.getRandomName"
end
-- 修改昵称
function user_changeName(fn_cb, params)
	Network.rpc(fn_cb, "user.changeName","user.changeName", params, true)
	return "user.changeName"
end
--得到用户信息
function user_getUser(fn_cb, params)
	Network.rpc(fn_cb, "user.getUser","user.getUser", params, true)
	return "user.getUser"
end
--得到对方玩家的所有阵容信息
function user_getBattleDataOfUsers(fn_cb,params)
	Network.rpc(fn_cb, "user.getBattleDataOfUsers","user.getBattleDataOfUsers", params, true)
	return "user.getBattleDataOfUsers"
end
--得到玩家所有的用户(支持一个帐号有多个角色)
function user_getUsers(fn_cb, params)
	Network.rpc(fn_cb, "user.getUsers","user.getUsers", params, true)
	return "user.getUsers"
end
--是否充值过
function user_isPay(fn_cb, params)
	Network.rpc(fn_cb, "user.isPay","user.isPay", params, true)
	return "user.isPay"
end
--玩家登录到游戏服务器
function user_login(fn_cb, params)
	Network.rpc(fn_cb, "user.login","user.login", params, true)
	return "user.login"
end
--设置静音
function user_setMute(fn_cb, params)
	Network.rpc(fn_cb, "user.setMute","user.setMute", params, true)
	return "user.setMute"
end
--保存设置
function user_setVaConfig(fn_cb, params)
	Network.rpc(fn_cb, "user.setVaConfig","user.setVaConfig", params, true)
	return "user.setVaConfig"
end

--使用用户名获取用户ID
function user_unameToUid(fn_cb, params)
	Network.rpc(fn_cb, "user.unameToUid","user.unameToUid", params, true)
	return "user.unameToUid"
end

--使用用户名获取用户信息
function user_getUserInfoByUname(fn_cb, params)
	Network.rpc(fn_cb, "user.getUserInfoByUname","user.getUserInfoByUname", params, true)
	return "user.getUserInfoByUname"
end

--开启武将格子
function user_openHeroGrid(fn_cb, params)
	Network.rpc(fn_cb, "user.openHeroGrid","user.openHeroGrid", params, true)
	return "user.openHeroGrid"
end

-- 前端保存设置用。 可单独设置某个key
function user_setArrConfig(fn_cb, params)
	Network.rpc(fn_cb, "user.setArrConfig","user.setArrConfig", params, true)
	return "user.setArrConfig"
end

-- 返回所有的配置
function user_getArrConfig(fn_cb, params)
	Network.rpc(fn_cb, "user.getArrConfig", "user.getArrConfig", params, true)
	return "user.getArrConfig"
end

-- 用户充值的金币数量
function user_getChargeGold(fn_cb, params)
	Network.rpc(fn_cb, "user.getChargeGold" , "user.getChargeGold", params , true)
end

-- 功能开启信息
function user_getSwitchInfo(fn_cb, params)
	Network.rpc(fn_cb, "user.getSwitchInfo", "user.getSwitchInfo", params, true)
end

----------------------------------- IMineral -------------------
--获得一页的数据
function mineral_getPitsByDomain(fn_cb, params)
	Network.rpc(fn_cb, "mineral.getPitsByDomain","mineral.getPitsByDomain", params, true)
	return "mineral.getPitsByDomain"
end

--放弃矿
function mineral_giveUpPit (fn_cb, params)
	Network.rpc(fn_cb, "mineral.giveUpPit","mineral.giveUpPit", params, true)
	return "mineral.giveUpPit"
end

--抢别人矿
function mineral_grabPit (fn_cb, params)
	Network.rpc(fn_cb, "mineral.grabPit","mineral.grabPit", params, true)
	return "mineral.grabPit"
end

--花钱抢别人矿
function mineral_grabPitByGold (fn_cb, params)
	Network.rpc(fn_cb, "mineral.grabPitByGold","mineral.grabPitByGold", params, true)
	return "mineral.grabPitByGold"
end

--占领空矿
function mineral_capturePit (fn_cb, params)
	Network.rpc(fn_cb, "mineral.capturePit","mineral.capturePit", params, true)
	return "mineral.capturePit"
end

--获取我的矿的信息
function mineral_getSelfPitsInfo (fn_cb, params)
	Network.rpc(fn_cb, "mineral.getSelfPitsInfo","mineral.getSelfPitsInfo", params, true)
	return "mineral.getSelfPitsInfo"
end

--一键找矿
function mineral_explorePit (fn_cb, params)
	Network.rpc(fn_cb, "mineral.explorePit","mineral.explorePit", params, true)
	return "mineral.explorePit"
end


---------------------------------------- 联盟系统 -----------------------------------------
-- 获取所在军团的成员信息
function guild_getMemberInfo (fn_cb, params)
	Network.rpc(fn_cb, "guild.getMemberInfo", "guild.getMemberInfo", params, true)
	return "guild.getMemberInfo"
end

-- 获取军团信息
function guild_getGuildInfo (fn_cb, params)
	Network.rpc(fn_cb, "guild.getGuildInfo", "guild.getGuildInfo", params, true)
	return "guild.getGuildInfo"
end

-- 申请加入某个军团
function guild_applyGuild (fn_cb, params)
	Network.rpc(fn_cb, "guild.applyGuild", "guild.applyGuild", params, true)
	return "guild.applyGuild"
end

-- 取消申请加入某个军团
function guild_cancelApply (fn_cb, params)
	Network.rpc(fn_cb, "guild.cancelApply", "guild.cancelApply", params, true)
	return "guild.cancelApply"
end

-- 创建军团
function guild_createGuild (fn_cb, params)
	Network.rpc(fn_cb, "guild.createGuild", "guild.createGuild", params, true)
	return "guild.createGuild"
end

-- 获取军团列表
function guild_getGuildList (fn_cb, params)
	Network.rpc(fn_cb, "guild.getGuildList", "guild.getGuildList", params, true)
	return "guild.getGuildList"
end

-- 查询军团
function guild_getGuildListByName (fn_cb, params)
	Network.rpc(fn_cb, "guild.getGuildListByName", "guild.getGuildListByName", params, true)
	return "guild.getGuildListByName"
end

-- 获取成员列表
function guild_getMemberList (fn_cb, params)
	Network.rpc(fn_cb, "guild.getMemberList", "guild.getMemberList", params, true)
	return "guild.getMemberList"
end

-- 获取军团的申请列表
function guild_getGuildApplyList (fn_cb, params)
	Network.rpc(fn_cb, "guild.getGuildApplyList", "guild.getGuildApplyList", params, true)
	return "guild.getGuildApplyList"
end

-- 获取用户申请记录
function guild_getUserApplyList (fn_cb, params)
	Network.rpc(fn_cb, "guild.getUserApplyList", "guild.getUserApplyList", params, true)
	return "guild.getUserApplyList"
end

-- 弹劾团长
function guild_impeach (fn_cb, params)
	Network.rpc(fn_cb, "guild.impeach", "guild.impeach", params, true)
	return "guild.impeach"
end

-- 踢出成员
function guild_kickMember (fn_cb, params)
	Network.rpc(fn_cb, "guild.kickMember", "guild.kickMember", params, true)
	return "guild.kickMember"
end

-- 修改密码
function guild_modifyPasswd (fn_cb, params)
	Network.rpc(fn_cb, "guild.modifyPasswd", "guild.modifyPasswd", params, true)
	return "guild.modifyPasswd"
end

-- 修改图标
function guild_modifyLogo( fn_cb, params )
	Network.rpc(fn_cb, "guild.modifyLogo", "guild.modifyLogo", params, true)
	return "guild.modifyLogo"
end

-- 修改宣言
function guild_modifySlogan (fn_cb, params)
	Network.rpc(fn_cb, "guild.modifySlogan", "guild.modifySlogan", params, true)
	return "guild.modifySlogan"
end

-- 退出军团
function guild_quitGuild (fn_cb, params)
	Network.rpc(fn_cb, "guild.quitGuild", "guild.quitGuild", params, true)
	return "guild.quitGuild"
end

-- 拒绝申请
function guild_refuseApply (fn_cb, params)
	Network.rpc(fn_cb, "guild.refuseApply", "guild.refuseApply", params, true)
	return "guild.refuseApply"
end

-- 同意申请
function guild_agreeApply (fn_cb, params)
	Network.rpc(fn_cb, "guild.agreeApply", "guild.agreeApply", params, true)
	return "guild.agreeApply"
end

-- 领取奖励
function guild_reward (fn_cb, params)
	Network.rpc(fn_cb, "guild.reward", "guild.reward", params, true)
	return "guild.reward"
end

-- 任命副团长
function guild_setVicePresident (fn_cb, params)
	Network.rpc(fn_cb, "guild.setVicePresident", "guild.setVicePresident", params, true)
	return "guild.setVicePresident"
end

-- 转让团长
function guild_transPresident (fn_cb, params)
	Network.rpc(fn_cb, "guild.transPresident", "guild.transPresident", params, true)
	return "guild.transPresident"
end

-- 取消副团长
function guild_unsetVicePresident (fn_cb, params)
	Network.rpc(fn_cb, "guild.unsetVicePresident", "guild.unsetVicePresident", params, true)
	return "guild.unsetVicePresident"
end

-- 升级建筑
function guild_upgradeGuild (fn_cb, params)
	Network.rpc(fn_cb, "guild.upgradeGuild", "guild.upgradeGuild", params, true)
	return "guild.upgradeGuild"
end

-- 修改公告
function guild_modifyPost(fn_cb, params)
	Network.rpc(fn_cb, "guild.modifyPost", "guild.modifyPost", params, true)
	return "guild.modifyPost"
end

-- 捐献
function guild_contribute (fn_cb, params)
	Network.rpc(fn_cb, "guild.contribute", "guild.contribute", params, true)
	return "guild.contribute"
end

-- 贡献记录
function guild_record(fn_cb, params)
	Network.rpc(fn_cb, "guild.getRecordList", "guild.getRecordList", params, true)
	return "guild.getRecordList"
end

--解散军团
function guild_dissmissGuild(fn_cb,params)
	Network.rpc(fn_cb, "guild.dismiss", "guild.dismiss", params, true)
	return "guild.dismiss"
end

-- 军团动态
function guild_getDynamicList(fn_cb,params)
	Network.rpc(fn_cb, "guild.getDynamicList", "guild.getDynamicList", params, true)
	return "guild.getDynamicList"
end

-- 一键拒绝
function guild_refuseAllApply(fn_cb,params)
	Network.rpc(fn_cb, "guild.refuseAllApply", "guild.refuseAllApply", params, true)
	return "guild.refuseAllApply"
end
-- 获得留言列表
function guild_getMessageList(fn_cb,params)
	Network.rpc(fn_cb, "guild.getMessageList", "guild.getMessageList", params, true)
	return "guild.getMessageList"
end
-- l留言板 留言
function guild_leaveMessage(fn_cb,params)
	Network.rpc(fn_cb, "guild.leaveMessage", "guild.leaveMessage", params, true)
	return "guild.leaveMessage"
end

-------------------------------- 联盟商店 --------------------------------
-- 联盟商店 购买
function guildShop_buy(fn_cb,params)
	Network.rpc(fn_cb, "guildshop.buy", "guildshop.buy", params, true)
	return "guildShop.buy"
end

-- 获得商店信息
function guildShop_getShopInfo(fn_cb,params)
	Network.rpc(fn_cb, "guildshop.getShopInfo", "guildshop.getShopInfo", params, true)
	return "guildshop.getShopInfo"
end

-- 刷新珍品类商品列表
function guildShop_refreshList(fn_cb,params)
	Network.rpc(fn_cb, "guildshop.refreshList", "guildshop.refreshList", params, true)
	return "guildshop.refreshList"
end

-------------------------------------------------------------------------

--活动副本信息
function activityCopyInfo(fn_cb,params)
	Network.rpc(fn_cb, "acopy.getCopyList", "acopy.getCopyList", params, true)
	return "acopy.getCopyList"
end
--购买活动副本攻打次数
function buyActivityCopyTimes(fn_cb,params)
	Network.rpc(fn_cb, "acopy.buyAtkNum", "acopy.buyAtkNum", params, true)
	return "acopy.buyAtkNum"
end
--更改伙伴影子副本掉落物品
function changeActivityDropGet(fn_cb,params)
	Network.rpc(fn_cb, "acopy.changeDropGet", "acopy.changeDropGet", params, true)
	return "acopy.changeDropGet"
end
--领取伙伴影子副本奖励
function getchangeActivityDropGet(fn_cb,params)
	Network.rpc(fn_cb, "acopy.fetchReward", "acopy.fetchReward", params, true)
	return "acopy.changeDropGet"
end
------------------------------探索系统----------------------------

--探索信息
function explorInfo(fn_cb,params)
	Network.rpc(fn_cb, "explore.getExploreInfo", "explore.getExploreInfo", params, true)
	return "explore.getExploreInfo"
end

--执行探索请求
function exploreReq(fn_cb,params)
	Network.rpc(fn_cb, "explore.explores", "explore.explores", params, true)
	return "explore.explores"
end
--执行购买探索次数请求
function buyExploreTimeReq(fn_cb,params)
	Network.rpc(fn_cb, "explore.buyExploreNum", "explore.buyExploreNum", params, true)
	return "explore.buyExploreNum"
end
--领取探索进度奖励
function getExploreProgressReward(fn_cb,params)
	Network.rpc(fn_cb, "explore.getReward", "explore.getReward", params, true)
	return "explore.getReward"
end

-- 奇遇事件完成请求：array doEvent (int $index, [array $param = array()])
function exploreDoEvent(fn_cb,params)
	Network.rpc(fn_cb, "explore.doEvent", "explore.doEvent", params, true)
	return "explore.doEvent"
end


------------------------------成就系统----------------------------
-- 拉去成就系统信息
function getAchieInfo( fn_cb )
	Network.rpc(fn_cb,"achieve.getInfo","achieve.getInfo",nil,true)
	return "achieve.getInfo"
end

--成就系统领奖
function getRewardAchie( fn_cb, params )
	Network.rpc(fn_cb, "achieve.obtainReward", "achieve.obtainReward", params, true)
	return "achieve.obtainReward"
end

------------------------------最游戏帐号登陆礼包----------------------------
function getBoundingReward( fnCallback )
	Network.rpc(fnCallback,"user.fetchBoundingReward","user.fetchBoundingReward",nil,true)
	return "user.fetchBoundingReward"
end

function getBoundingRewardTime( fnCallback )
	Network.rpc(fnCallback,"user.getBoundingRewardTime","user.getBoundingRewardTime",nil,true)
	return "user.getBoundingRewardTime"
end

------------------------------新版本主船系统---------------------------------
--获取主船信息
function ship_getShipInfo( cbFunc )
	Network.rpc(cbFunc, "ship.getShipInfo","ship.getShipInfo", nil, true)
end
--主船改造
function ship_shipBreak( cbFunc )
	Network.rpc(cbFunc, "ship.shipBreak","ship.shipBreak", nil, true)
end

-----------------------------空岛爬塔 系统 -----------------------------------
--空岛爬塔 进入拉去信息
function skyPieaEnter( fn_cb, params )
	Network.rpc(fn_cb, "pass.enter", "pass.enter", params, true)
	return "pass.enter"
end

-- 获取对手信息
function skyPieaGetOpponentList( fn_cb, params )
	Network.rpc(fn_cb, "pass.getOpponentList", "pass.getOpponentList", params, true)
	return "pass.getOpponentList"
end

-- 获取排行榜信息
function skyPieaGetRankList( fn_cb, params )
	Network.rpc(fn_cb, "pass.getRankList", "pass.getRankList", params, true)
	return "pass.getRankList"
end

-- 攻击某个
function skyPieaAttack( fn_cb, params )
	Network.rpc(fn_cb, "pass.attack", "pass.attack", params, true)
	return "pass.attack"
end

-- 处理宝箱
function skyPieaDealChest( fn_cb, params )
	Network.rpc(fn_cb, "pass.dealChest", "pass.dealChest", params, true)
	return "pass.dealChest"
end

-- 离开购买宝箱
function skyPieaLeaveChest( fn_cb, params )
	Network.rpc(fn_cb, "pass.leaveLuxuryChest", "pass.leaveLuxuryChest", params, true)
	return "pass.leaveLuxuryChest"
end

-- 获取buff点的信息
function skyPieaGetBuffInfo( fn_cb, params)
	Network.rpc(fn_cb, "pass.getBuffInfo", "pass.getBuffInfo", params, true)
	return "pass.getBuffInfo"
end

-- 处理buff
function skyPieaDealBuff( fn_cb, params)
	Network.rpc(fn_cb, "pass.dealBuff", "pass.dealBuff", params, true)
	return "pass.dealBuff"
end

-- 设置爬塔的阵型信息
function skyPieaSetFormation( fn_cb, params )
	Network.rpc(fn_cb, "pass.setPassFormation", "pass.setPassFormation", params, true)
	return "pass.setPassFormation"
end

-- 拉取商店信息
function skyPieaGetShopInfo( fn_cb, params )
	Network.rpc(fn_cb, "pass.getShopInfo", "pass.getShopInfo", params, true)
	return "pass.getShopInfo"
end

-- 商店刷新信息
function skyPieaRfrGoodsList( fn_cb, params )
	Network.rpc(fn_cb, "pass.refreshGoodsList", "pass.refreshGoodsList", params, true)
	return "pass.refreshGoodsList"
end

-- 商店购买
function skyPieaBuyGoods( fn_cb, params )
	Network.rpc(fn_cb, "pass.buyGoods", "pass.buyGoods", params, true)
	return "pass.buyGoods"
end

------------------- 世界Boss -----------
-- 进入世界Boss模块要拉的初始化信息
function boss_enterBoss( fn_cb, params )
	Network.rpc(fn_cb, "boss.getBossInfo", "boss.getBossInfo", params, true)
	return "boss.getBossInfo"
end
-- 世界Boss活动时间结束后拉取的伤害排名和奖励信息
function boss_over( fn_cb, params )
	Network.rpc(fn_cb, "boss.over", "boss.over", params, true)
	return "boss.over"
end
-- 注册后端推送的Boss更新随机数据
function re_bossUpdate( fn_cb)
	Network.re_rpc(fn_cb, "push.boss.update", "push.boss.update")
	return "push.boss.update"
end
-- 注册后端推送的Boss被击杀
function re_bossKilled( fn_cb)
	Network.re_rpc(fn_cb, "push.boss.kill", "push.boss.kill")
	return "push.boss.kill"
end
-- 离开世界Boss模块
function boss_leaveBoss( fn_cb, params )
	Network.rpc(fn_cb, "boss.leaveBoss", "boss.leaveBoss", params, true)
	return "boss.leaveBoss"
end
-- boss开启时间偏移
function boss_getBossOffset( fn_cb, params )
	Network.rpc(fn_cb, "boss.getBossOffset", "boss.getBossOffset", params, true)
	return "boss.getBossOffset"
end
-- 获取boss的攻击血量排行
function boss_getAtkerRank( fn_cb, params )
	Network.rpc(fn_cb, "boss.getAtkerRank", "boss.getAtkerRank", params, true)
	return "boss.getAtkerRank"
end
--
function boss_getMyRank( fn_cb, params )
	Network.rpc(fn_cb, "boss.getMyRank", "boss.getMyRank", params, true)
	return "boss.getMyRank"
end
-- 获取当前Boss伤害阵容
function boss_getSuperHero( fn_cb, params )
	Network.rpc(fn_cb, "boss.getSuperHero", "boss.getSuperHero", params, true)
	return "boss.getSuperHero"
end
-- 金币鼓舞
function boss_inspireByGold( fn_cb, params )
	Network.rpc(fn_cb, "boss.inspireByGold", "boss.inspireByGold", params, true)
	return "boss.inspireByGold"
end
-- 银币鼓舞
function boss_inspireBySilver( fn_cb, params )
	Network.rpc(fn_cb, "boss.inspireBySilver", "boss.inspireBySilver", params, true)
	return "boss.inspireBySilver"
end
-- 攻击Bosss
function boss_attackBoss( fn_cb, params )
	Network.rpc(fn_cb, "boss.attack", "boss.attack", params, true)
	return "boss.attack"
end
-- 立即复活
function boss_revive( fn_cb, params )
	Network.rpc(fn_cb, "boss.revive", "boss.revive", params, true)
	return "boss.revive"
end


