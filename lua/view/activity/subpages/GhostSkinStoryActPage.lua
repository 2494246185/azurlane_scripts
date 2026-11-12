local GhostSkinStoryActPage = class("GhostSkinStoryActPage", import(".TemplatePage.PreviewTemplatePage"))

function GhostSkinStoryActPage:OnFirstFlush()
	self.super.OnFirstFlush(self)
	onButton(self, self.btnList:Find("activity"), function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GHOSTSKINPAGE)
	end)
end

function GhostSkinStoryActPage:OnUpdateFlush()
	setActive(self._tf:Find("AD/redDot"), GhostSkinPageLayer.IsShowRed())
end

return GhostSkinStoryActPage
