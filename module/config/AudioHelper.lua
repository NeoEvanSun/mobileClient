-- FileName: AudioHelper.lua
-- Author: lzy 
-- Purpose: 音乐音效


module("AudioHelper", package.seeall)


-- UI控件引用变量 --


-- 模块局部变量 --
local m_curMusic
local m_isMusicOn
local m_isEffectOn


function destroy(...)
	package.loaded["AudioHelper"] = nil
end


function moduleName()
	return "AudioHelper"
end


function initAudioInfo()
	m_curMusic = nil
	if (CCUserDefault:sharedUserDefault():getBoolForKey("isAudioInit") == false) then
		CCUserDefault:sharedUserDefault():setBoolForKey("isAudioInit",true)
		CCUserDefault:sharedUserDefault():setBoolForKey("m_isMusicOn",true)
		CCUserDefault:sharedUserDefault():setBoolForKey("m_isEffectOn",true)
		CCUserDefault:sharedUserDefault():flush()

		m_isMusicOn = true
		m_isEffectOn = true
	else
		m_isMusicOn = CCUserDefault:sharedUserDefault():getBoolForKey("m_isMusicOn")
		if (m_isMusicOn) then
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
		else
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
		end

		m_isEffectOn = CCUserDefault:sharedUserDefault():getBoolForKey("m_isEffectOn")
		if (m_isEffectOn)then
			SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
		else
			SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
		end
	end
end


--播放背景音乐
function playMusic(strMusic, isLoop)
	if (m_isMusicOn == nil) then
		initAudioInfo()
	end

	if (strMusic ~= m_curMusic or isLoop == false) then
		if (isLoop == nil) then
			isLoop = true
		end

		m_curMusic = strMusic
		SimpleAudioEngine:sharedEngine():playBackgroundMusic(m_curMusic, isLoop)
	end
end


--停止背景音乐
function stopMusic()
	SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
end


function resumeMusic( ... )
	SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
end


-- 停止指定effect
function stopEffect(effectID)
	if(effectID) then
		SimpleAudioEngine:sharedEngine():stopEffect(effectID)
	end
end


-- 停止所有音效
function stopAllEffects()
	SimpleAudioEngine:sharedEngine():stopAllEffects()
end


--播放音效
function playEffect(effect, isLoop)
	if (m_isEffectOn == nil) then
		initAudioInfo()
	end

	isLoop = isLoop or false
	if(m_isEffectOn)then
		return SimpleAudioEngine:sharedEngine():playEffect(effect,isLoop)
	end
end


-- 设置音乐音量
function setMusicVolume( nVolume )
	if m_isMusicOn then
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(nVolume)
	end
end


-- 设置音乐开关
function setMusic( bValue )
	if (m_isMusicOn == bValue) then
		return
	end

	m_isMusicOn = bValue
	CCUserDefault:sharedUserDefault():setBoolForKey("m_isMusicOn", bValue)
	CCUserDefault:sharedUserDefault():flush()
	if m_isMusicOn then
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
	else
		SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
	end
end


-- 设置音效开关
function setEffect( bValue )
	if (m_isEffectOn == bValue) then
		return
	end

	m_isEffectOn = bValue
	CCUserDefault:sharedUserDefault():setBoolForKey("m_isEffectOn", bValue)
	CCUserDefault:sharedUserDefault():flush()
	if m_isEffectOn then
		SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
	else
		SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
	end
end


function isMusicOn( ... )
	return m_isMusicOn
end


function isEffectOn( ... )
	return m_isEffectOn
end


-- 播放游戏主音乐
function playMainMusic()
	playMusic("audio/bgm/chengzhen.mp3")
end


-- 播放场景音乐，传入文件名
function playSceneMusic(fileName)
	playMusic("audio/bgm/" .. fileName)
end


-- 播放动画音效，传入文件名
function playSpecialEffect(fileName)
	--playEffect("audio/effect/" .. fileName)
end


-- 播放按钮音效
function playBtnEffect(fileName)
	playEffect("audio/btn/" .. fileName)
end


-- 关闭按钮音效
function playCloseEffect( ... )
	playBtnEffect("guanbi.mp3")
end


-- 页签按钮音效
function playTabEffect( ... )
	playBtnEffect("yeqian.mp3")
end


-- 返回按钮音效
function playBackEffect( ... )
	playBtnEffect("fanhui.mp3")
end


-- 弹出信息面板按钮音效
function playInfoEffect( ... )
	playBtnEffect("jieshao.mp3")
end


-- 主界面活动ui的
function playMainUIEffect( ... )
	playBtnEffect("zhujiemian_mid.mp3")
end


-- 二级按钮音效
function playCommonEffect( ... )
	playBtnEffect("anniu.mp3")
end


-- 进入游戏音效
function playEnter( ... )
	playBtnEffect("jinruyouxi.mp3")
end


-- 进入副本音效
function playEnterCopy( ... )
	playBtnEffect("fuben.mp3")
end


-- 主界面底部菜单按钮音效
function playMainMenuBtn( ... )
	playBtnEffect("zhujiemian_bottom.mp3")
end




