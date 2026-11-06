local NewYearGreetingPtPage = class("NewYearGreetingPtPage", import(".TemplatePage.PtTemplatePage"))

function NewYearGreetingPtPage:OnInit()
	NewYearGreetingPtPage.super.OnInit(self)

	self.awardGotTag = self.bg:Find("award_got")
end

function NewYearGreetingPtPage:OnFirstFlush()
	NewYearGreetingPtPage.super.OnFirstFlush(self)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.TASK, {
			page = "activity"
		})
	end, SFX_PANEL)
end

function NewYearGreetingPtPage:OnUpdateFlush()
	NewYearGreetingPtPage.super.OnUpdateFlush(self)
	setActive(self.awardGotTag, not self.ptData:CanGetNextAward())
end

return NewYearGreetingPtPage
