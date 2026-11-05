local MabuerheideshengdanRePage = class("MabuerheideshengdanRePage", import(".TemplatePage.PtTemplatePage"))

function MabuerheideshengdanRePage:OnFirstFlush()
	MabuerheideshengdanRePage.super.OnFirstFlush(self)
	onButton(self, self.battleBtn, function()
		self:emit(ActivityMediator.SPECIAL_BATTLE_OPERA)
	end, SFX_PANEL)
end

return MabuerheideshengdanRePage
