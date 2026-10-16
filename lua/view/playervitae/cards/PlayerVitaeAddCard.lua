local PlayerVitaeAddCard = class("PlayerVitaeAddCard", import(".PlayerVitaeBaseCard"))

function PlayerVitaeAddCard:OnInit()
	self.line1 = self._tf:Find("line1")
	self.line2 = self._tf:Find("line2")
	self.txt = self._tf:Find("Text")

	onButton(self, self._tf, function()
		if self.inEdit then
			return
		end

		if not self.canCilick then
			return
		end

		self:emit(PlayerVitaeMediator.CHANGE_PAINT, nil)
	end, SFX_PANEL)
end

function PlayerVitaeAddCard:OnUpdate(arg_3_1, arg_3_2, arg_3_3, arg_3_4)
	local var_3_0 = arg_3_4 == PlayerVitaeShipsPage.RANDOM_FLAG_SHIP_PAGE

	self.canCilick = arg_3_4 ~= PlayerVitaeShipsPage.RANDOM_FLAG_SHIP_PAGE

	setActive(self.line1, not var_3_0)
	setActive(self.line2, not var_3_0)
	setActive(self.txt, not var_3_0)
end

function PlayerVitaeAddCard:EditCard(arg_4_1)
	self.inEdit = arg_4_1

	setActive(self.mask, arg_4_1)
end

function PlayerVitaeAddCard:Disable()
	PlayerVitaeAddCard.super.Disable(self)
	self:EditCard(false)
end

function PlayerVitaeAddCard:OnDispose()
	self:Disable()
end

return PlayerVitaeAddCard
