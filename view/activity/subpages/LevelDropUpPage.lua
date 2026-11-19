local LevelDropUpPage = class("LevelDropUpPage", import("...base.BaseActivityPage"))

function LevelDropUpPage:OnInit()
	onButton(self, self._tf:Find("go"), function()
		local var_2_0

		for iter_2_0, iter_2_1 in ipairs(getProxy(ChapterProxy):getMapsByType(Map.SCENARIO)) do
			if iter_2_1:isUnlock() and (not var_2_0 or var_2_0 < iter_2_1.id) then
				var_2_0 = iter_2_1.id
			end
		end

		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.LEVEL, {
			entranceStatus = false,
			mapIdx = var_2_0
		})
	end, SFX_PANEL)
end

function LevelDropUpPage:OnFirstFlush()
	LevelDropUpActUtil.MarkTipLevelDropUpAct(self.activity.id)
end

return LevelDropUpPage
