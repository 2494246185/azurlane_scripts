local MabuerheideshengdanPage = class("MabuerheideshengdanPage", import(".TemplatePage.PtTemplatePage"))

function MabuerheideshengdanPage:OnFirstFlush()
	MabuerheideshengdanPage.super.OnFirstFlush(self)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.SPECIAL_BATTLE_OPERA)
	end, SFX_PANEL)
end

return MabuerheideshengdanPage
