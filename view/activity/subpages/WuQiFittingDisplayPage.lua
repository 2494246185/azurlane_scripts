local WuQiFittingDisplayPage = class("WuQiFittingDisplayPage", import("view.base.BaseActivityPage"))

WuQiFittingDisplayPage.blueprintGroupId = 39904

function WuQiFittingDisplayPage:OnInit()
	self.btnClick = self._tf:Find("bg/click_area")
	self.rtAnim = self._tf:Find("bg/CircleBlue02")
end

function WuQiFittingDisplayPage:OnFirstFlush()
	self.rtAnim:GetComponent(typeof(DftAniEvent)):SetEndEvent(function(arg_3_0)
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.SHIPBLUEPRINT, {
			shipGroupId = self.blueprintGroupId
		})
	end)
	onButton(self, self.btnClick, function()
		local var_4_0, var_4_1 = pg.SystemOpenMgr.GetInstance():isOpenSystem(getProxy(PlayerProxy):getData().level, "TechnologyMediator")

		if not var_4_0 then
			pg.TipsMgr.GetInstance():ShowTips(var_4_1)

			return
		end

		setActive(self.rtAnim, true)
	end, SFX_PANEL)
end

return WuQiFittingDisplayPage
