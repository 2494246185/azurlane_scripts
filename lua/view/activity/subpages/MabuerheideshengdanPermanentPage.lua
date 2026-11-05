local MabuerheideshengdanPermanentPage = class("MabuerheideshengdanPermanentPage", import(".TemplatePage.PtTemplatePage"))

function MabuerheideshengdanPermanentPage:OnFirstFlush()
	MabuerheideshengdanPermanentPage.super.OnFirstFlush(self)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.SPECIAL_BATTLE_OPERA)
	end, SFX_PANEL)
end

return MabuerheideshengdanPermanentPage
