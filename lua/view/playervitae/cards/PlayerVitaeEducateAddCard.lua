local PlayerVitaeEducateAddCard = class("PlayerVitaeEducateAddCard", import(".PlayerVitaeEducateBaseCard"))

function PlayerVitaeEducateAddCard:Flush()
	onButton(self, self._tf, function()
		self:emit(PlayerVitaeMediator.ON_SEL_EDUCATE_CHAR)
	end, SFX_PANEL)
end

function PlayerVitaeEducateAddCard:Clear()
	removeOnButton(self._tf)
end

return PlayerVitaeEducateAddCard
