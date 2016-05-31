-- FileName: EffectHelper.lua
-- Author: zhangqi
-- Date: 2014-07-07
-- Purpose: 提供播放各种UI特效的方法
--[[TODO List]]

-- module("EffectHelper", package.seeall)

-- UI控件引用变量 --

-- 模块局部变量 --
local m_effect = "images/effect"

UIEffect = class("UIEffect")

function UIEffect:Armature( ... )
	return self.mArmature
end

-------------- 强化特效 --------------
EffStrenth = class("EffStrenth", UIEffect)

function EffStrenth:ctor(tbInfo)
	self.mBoneIdx = 0 -- 强化等级数字bone的index
	local m_strenthen = "strenthen/tishengji"
	tbInfo.imagePath = m_effect .. m_strenthen .. "0.pvr"
	tbInfo.plistPath = m_effect .. m_strenthen .. "0.plist"
	tbInfo.filePath = m_effect .. m_strenthen .. ".ExportJson"

	tbInfo.fnMovementCall = function ( sender, MovementEventType )
		if (MovementEventType == START) then
		elseif (MovementEventType == COMPLETE) then
			self.mBone:removeDisplay(self.mBoneIdx)
		elseif (MovementEventType == LOOP_COMPLETE) then
		end
	end





	self.mArmature = UIHelper.createArmatureNode(tbInfo)
	self.mBone = self.mArmature:getBone("no9")
end

function EffStrenth:playWithData( tbData )
	local numFile = string.format("%s/digital/%d.png", m_effect, tbData.num)
	local ccSkin = CCSkin:create(numFile)
	ccSkin:setAnchorPoint(ccp(0.5, 0)) -- 设置锚点和强化动画的锚点一致
	self.mBone:addDisplay(ccSkin, self.mBoneIdx) -- 替换

	self.mArmature:getAnimation():play("tishengji", 0, -1, tbData.loop or -1)
end

-------------- add by zhaoqiangjun  创建套装的亮闪闪的框 --------------
EffLightCircle = class("EffLightCircle", UIEffect)
function EffLightCircle:ctor( quality )
	local res = {[1] = 1, [2] = 2, -- 占位
		[3] = {path = "green", anim = "guang2"}, [4] = {path = "blue", anim = "guang"},
		[5] = {path = "purple", anim = "guang3"}, [6] = {path = "orange", anim = "guang4"},
	}
	local mainPath = string.format("%s/suit_highlight/%s", m_effect, "guang")
	self.mArmature = UIHelper.createArmatureNode({
		filePath = mainPath .. ".ExportJson",
		plistPath = mainPath .. "0.plist",
		imagePath = mainPath .. "0.png",
		animationName = res[quality].anim,
		loop = 1,
	-- fnMovementCall = animationCallBack,
	})
	-- local animation = self.mArmature:getAnimation()
	-- local speed = animation:getSpeedScale()
	-- animation:setSpeedScale(speed*0.9)
end

------------   喝可乐特效 add by huxiaozhou  ---------
EffCoke = class("EffCoke", UIEffect)

function EffCoke:ctor(  )
	self.mArmature = UIHelper.createArmatureNode({
		filePath = m_effect .. "/coke/coke.ExportJson",
		animationName = "coke",
		loop = 0,
	})
	self.mArmature:setAnchorPoint(ccp(0.5,0))
end


------------- 掠夺特效 add by huxiaozhou ------------
EffLueDuo = class("EffLueDuo", UIEffect)
function EffLueDuo:ctor( widget, endCallback)
	self.mBoneIdx = 0
	self.endCallback = endCallback
	self.mArmature = UIHelper.createArmatureNode({
		filePath = m_effect .. "/lueduo/lueduo1.ExportJson",
		fnMovementCall = function ( armature,movementType,movementID  )
			if (movementType == 0) then
			elseif (movementType == 1) then
				armature:removeFromParentAndCleanup(true)
			elseif (movementType == 2) then

			end
		end,
		fnFrameCall = function ( bone,frameEventName,originFrameIndex,currentFrameIndex )
			logger:debug("frameEventName : " .. frameEventName)
			logger:debug("originFrameIndex : " .. originFrameIndex)
			logger:debug("currentFrameIndex : " .. currentFrameIndex)
			if (frameEventName == "lueduo1_10") then
				local rmb = self:rmb()
				rmb:setScale(g_fScaleX)
				rmb:setPosition(ccp(g_winSize.width*.5,g_winSize.height*.5))
				widget:addNode(rmb)
			end
		end
	})
	self.mArmature:setAnchorPoint(ccp(0.5,0.5))
end

function EffLueDuo:rmb( )
	local armatureRmb = UIHelper.createArmatureNode({
		filePath = m_effect .. "/rmb/rmb.ExportJson",
		fnMovementCall = function ( armature,movementType,movementID  )
			if (movementType == 0) then
			elseif (movementType == 1) then
			-- armature:removeFromParentAndCleanup(true)
			-- self.endCallback()
			elseif (movementType == 2) then

			end
		end,
		animationName = "rmb"

	})
	return armatureRmb
end


function EffLueDuo:playWithNumber(nNumber)
	local labTTF = UIHelper.createStrokeTTF(tostring(nNumber),ccc3(255,255,255),nil,nil,36,g_sFontPangWa)
	self.mArmature:getBone("lueduo1_2"):addDisplay(labTTF, self.mBoneIdx) -- 替换 成要显示的label
	self.mArmature:getAnimation():play("lueduo1", 0, -1, 0)
end

------------- 战斗结算面板成功特效 add by zhangjunwu 08-01------------
EffBattleWin = class("EffBattleWin", UIEffect)


-- local tbArgs = {imgTitle, imgRainBow, tbStars, starLv, callback}
function EffBattleWin:ctor(tbArgs)
	self.mBoneIdx = 0
	self.tbArmature = {}

	if (tbArgs.imgRainBow) then
		self.tbArmature.mRainBowArmature = UIHelper.createArmatureNode({
			filePath = m_effect .. "/battle_result/sheng_1.ExportJson",
			animationName = "sheng_1",
			loop = -1,
		})
		tbArgs.imgRainBow:addNode(self.tbArmature.mRainBowArmature)
	end

	if (tbArgs.imgTitle) then
		self.tbArmature.mLabelArmature = UIHelper.createArmatureNode({
			filePath = m_effect .. "/battle_result/sheng_2.ExportJson",
			animationName = "sheng_2",
			loop = 0,
			fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
				if frameEventName == "sheng_2_1" then
				end
				if (frameEventName == "1") then
					if (not tbArgs.tbStars) then
						if (tbArgs.callback) then
							tbArgs.callback()
						end
						return
					end
					local function playStar( index )
						if (index > tonumber(tbArgs.starLv)) then
							if (tbArgs.callback) then
								tbArgs.callback()
							end
							return
						end
						local armatureStar = UIHelper.createArmatureNode({
							filePath = m_effect .. "/battle_result/star_win.ExportJson",
							animationName = "star_win",
							loop = 0,
							fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
								if (frameEventName == "next") then
									playStar(index + 1)
								end
							end
						})
						local x, y = tbArgs.tbStars[index]:getPosition()
						armatureStar:setPosition(ccp(x, y))
						tbArgs.tbStars[index]:getParent():addNode(armatureStar)
						AudioHelper.playSpecialEffect("zhaojiangxingji.mp3")
					end
					playStar(1)
				end
			end,

			fnMovementCall = function ( armature,movementType,movementID )
				if (movementType == 1) then
					self:LabelCall(tbArgs.imgTitle)
				end
			end
		})

		tbArgs.imgTitle:addNode(self.tbArmature.mLabelArmature)
	end
	AudioHelper.playEffect("audio/effect/texiao_zhandoushengli.mp3", isLoop)
end

function EffBattleWin:LabelCall(imgTitle)
	self.tbArmature.mStarArmature = UIHelper.createArmatureNode({
		filePath = m_effect .. "/battle_result/sheng_3.ExportJson",
		animationName = "sheng_3",
		loop = -1,
		fnMovementCall = function ( armature,movementType,movementID  )
			if (movementType == START) then
			elseif (movementType == COMPLETE) then
			elseif (movementType == LOOP_COMPLETE) then

			end
		end
	})
	imgTitle:addNode(self.tbArmature.mStarArmature)
end

------------- 战斗结算面板失败特效 add by zhangjunwu  08-01------------
EffBattleLose = class("EffBattleLose", UIEffect)

function EffBattleLose:ctor(layMain,widget, callback)
	layMain:setScale(0.0)
	local actionTo1 = CCScaleTo:create(5 / 60, 1.6)
	local actionTo2 = CCScaleTo:create(5 / 60, 0.8)
	local actionTo3 = CCScaleTo:create(2 / 60, 1.0)
	local arr = CCArray:create()
	arr:addObject(actionTo1)
	arr:addObject(actionTo2)
	arr:addObject(actionTo3)


	arr:addObject(CCCallFunc:create(function ( ... )


			self.mLoseArmature = UIHelper.createArmatureNode({
				filePath = m_effect .. "/battle_result/bai.ExportJson",
				animationName = "bai",
			})
			widget:addNode(self.mLoseArmature)
			--震屏
			local dis = 5.0
			local time = 0.03
			local move1 = CCMoveBy:create(time, ccp(dis,dis))
			local move2 = CCMoveBy:create(time ,ccp(-dis,-dis))
			local move3 = CCMoveBy:create(time, ccp(-dis,dis))
			local move4 = CCMoveBy:create(time ,ccp(dis,-dis))
			local arr1 = CCArray:create()
			for i=1,2 do
				arr1:addObject(move1)
				arr1:addObject(move2)
				arr1:addObject(move3)
				arr1:addObject(move4)
				if (i == 2 and callback) then
					arr1:addObject(CCCallFunc:create(callback))
				end
			end
			layMain:runAction(CCSequence:create(arr1))
	end)
	)

	local  pSequence = CCSequence:create(arr)

	layMain:runAction(pSequence)
	AudioHelper.playSpecialEffect("texiao_zhandoushibai.mp3")
end

-------------- add by huxiaozhou 2014-11-22 --------------
EffGuide = class("EffGuide", UIEffect)
function EffGuide:ctor(  )
	local mainPath = m_effect .. "/guide/zhishi_2"
	self.mArmature = UIHelper.createArmatureNode({
		filePath = mainPath .. ".ExportJson",
		plistPath = mainPath .. "0.plist",
		imagePath = mainPath .. "0.png",
		animationName = "zhishi_2",
		loop = 1,
	})

end


EffArrow = class("EffArrow", UIEffect)
function EffArrow:ctor(  )
	local mainPath = m_effect .. "/guide/arrow_tip"
	self.mArmature = UIHelper.createArmatureNode({
		filePath = mainPath .. ".ExportJson",
		plistPath = mainPath .. "0.plist",
		imagePath = mainPath .. "0.png",
		animationName = "arrow_tip",
		loop = 1,
	})

end
------------ add by huxiaozhou 2015-02-09 ------------- 竞技场水特效
EffArenaWater = class("EffArenaWater", UIEffect)
function EffArenaWater:ctor( )
	local mainPath = m_effect .. "/arena/falls"
	logger:debug(mainPath)
	self.mArmature = UIHelper.createArmatureNode({
		filePath = mainPath .. ".ExportJson",
		plistPath = mainPath .. "0.plist",
		imagePath = mainPath .. "0.png",
		animationName = "falls",
		loop = 1,
	})

end

------- add by huxiaozhou 2015-02-10 ----------------- 竞技场中小船的特效
EffArenaBoat = class("EffArenaBoat", UIEffect)
function EffArenaBoat:ctor( )
	self.mBoneIdx = 0
	local mainPath = m_effect .. "/arena/ship"
	logger:debug(mainPath)
	self.mArmature = UIHelper.createArmatureNode({
		filePath = mainPath .. ".ExportJson",
		plistPath = mainPath .. "0.plist",
		imagePath = mainPath .. "0.png",
	})
	self.mArmature:setAnchorPoint(ccp(0.5,0.5))
end

function EffArenaBoat:playWithBoat(sBoneName)
	logger:debug("sBoneName = %s", sBoneName)
	local ccSkin = CCSkin:create(sBoneName)
	self.mBone = self.mArmature:getBone("ship")
	self.mBone:addDisplay(ccSkin, self.mBoneIdx) -- 替换
	self.mArmature:getAnimation():play("ship", -1, -1, 1)

end


-- menghao 20150305 伙伴进阶和宝物精精炼属性提升的动画
EffNumUp = class("EffNumUp", UIEffect)

function EffNumUp:ctor( tbImgJiantous, tbTfdNums )
	local function createAni( pName , ploop , callback)
		local armature = UIHelper.createArmatureNode({
			filePath = "images/effect/" .. pName .. "/" .. pName .. ".ExportJson",
			animationName = pName,
			loop = ploop or -1,
			fnMovementCall = callback or nil
		})
		return armature
	end

	for i=1,#tbTfdNums do
		local tfdNum = tbTfdNums[i]
		local imgJiantou = tbImgJiantous[i]

		if (tfdNum) then
			local actionArr = CCArray:create()
			actionArr:addObject(CCDelayTime:create(0.1 * i))
			actionArr:addObject(CCCallFunc:create(function ( ... )
				if (imgJiantou) then
					imgJiantou:addNode(createAni("jinjie_zhizhen"))
				end

				tfdNum:setEnabled(true)
				local ani = createAni("jinjie_shuzi")
				ani:setPositionX(tfdNum:getContentSize().width * 0.5)
				tfdNum:addNode(ani)
			end))

			tfdNum:runAction(CCSequence:create(actionArr))
		end
	end
end


-- menghao 2015-03-06  宝物强化和精炼相关动画效果
EffTreaForge = class("EffTreaForge", UIEffect)

function EffTreaForge:ctor( ... )

end

function EffTreaForge:bigTreaEff( imgTreaBig )
	local actionArr1 = CCArray:create()
	actionArr1:addObject(CCMoveBy:create(1.5, ccp(0, 10)))
	actionArr1:addObject(CCMoveBy:create(1.5, ccp(0, -10)))
	local sequence1 = CCSequence:create(actionArr1)

	local actionArr2 = CCArray:create()
	actionArr2:addObject(CCScaleTo:create(1.5, 1.06))
	actionArr2:addObject(CCScaleTo:create(1.5, 1))
	local sequence2 = CCSequence:create(actionArr2)

	imgTreaBig:runAction(CCRepeatForever:create(sequence1))
	imgTreaBig:runAction(CCRepeatForever:create(sequence2))
end

function EffTreaForge:smallTreaEff( imgTreaSmall )
	local actionArr1 = CCArray:create()
	actionArr1:addObject(CCMoveBy:create(0.75, ccp(0, 10)))
	actionArr1:addObject(CCMoveBy:create(0.75, ccp(0, -10)))
	local sequence1 = CCSequence:create(actionArr1)

	imgTreaSmall:runAction(CCRepeatForever:create(sequence1))
end

function EffTreaForge:guangzhen( img, bValue )
	local str = bValue and "guangzheng_xiao" or "guangzheng_xiao_wu"
	local armature = UIHelper.createArmatureNode({
		filePath = "images/effect/hero_transfer/qh2_guangquan/qh2_guangquan.ExportJson",
		animationName = "guangzheng_xiao",
	})

	img:addNode(armature)
end

function EffTreaForge:qianghua( img, callback )
	local armature = UIHelper.createArmatureNode({
		filePath = "images/effect/hero_transfer/qh2_qianghua/qh2_qianghua.ExportJson",
		animationName = "qh2_qianghua",
		fnFrameCall = function ( bone, frameEventName, originFrameIndex, currentFrameIndex )
			if (frameEventName == "1") then
				callback()
			end
		end
	})

	img:addNode(armature)
end

function EffTreaForge:lizi( img )
	local lizi = CCParticleSystemQuad:create("images/effect/hero_transfer/qh2_lizi.plist")
	lizi:setAutoRemoveOnFinish(true)

	img:addNode(lizi)
end




