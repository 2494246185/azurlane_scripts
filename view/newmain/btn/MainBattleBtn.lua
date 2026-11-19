local MainBattleBtn = class("MainBattleBtn", import(".MainBaseBtn"))

function MainBattleBtn:OnClick()
	getProxy(ChapterAutoProxy):MarkBattleExpiredTip()

	local var_1_0 = getProxy(ChapterProxy):getActiveChapter()

	self:emit(NewMainMediator.GO_SCENE, SCENE.LEVEL, {
		chapterId = var_1_0 and var_1_0.id,
		mapIdx = var_1_0 and var_1_0:getConfig("map")
	})
end

function MainBattleBtn:Flush(arg_2_1)
	SetActive(self:GetTarget():Find("LevelDropUpTag"), LevelDropUpActUtil.EixstLevelDropUpAct())
end

function MainBattleBtn:IsFixed()
	return true
end

function MainBattleBtn:ShowOrHideBtnEffect(arg_4_1)
	local var_4_0 = self._tf:Find("FX")

	if IsNil(var_4_0) then
		return
	end

	setActive(var_4_0, arg_4_1)
end

return MainBattleBtn
