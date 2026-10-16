local BackYardEmptyCard = class("BackYardEmptyCard", import(".BackYardBaseCard"))

function BackYardEmptyCard:OnInit()
	onButton(self, self._content, function()
		self:emit(NewBackYardShipInfoMediator.OPEN_CHUANWU, self.type)
	end, SFX_PANEL)
end

return BackYardEmptyCard
