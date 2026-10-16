local MemphisHalloweenPage = class("MemphisHalloweenPage", import(".TemplatePage.PtTemplatePage"))

function MemphisHalloweenPage:OnFirstFlush()
	MemphisHalloweenPage.super.OnFirstFlush(self)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.SPECIAL_BATTLE_OPERA)
	end, SFX_PANEL)
end

return MemphisHalloweenPage
