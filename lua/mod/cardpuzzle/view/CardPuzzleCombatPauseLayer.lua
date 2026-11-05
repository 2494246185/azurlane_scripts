local CardPuzzleCombatPauseLayer = class("CardPuzzleCombatPauseLayer", BaseUI)

function CardPuzzleCombatPauseLayer:getUIName()
	return "CardTowerCombatPause"
end

function CardPuzzleCombatPauseLayer:init()
	CardPuzzleCombatPauseLayer.super.init(self)
	onButton(self, self._tf:Find("btn_quit"), function()
		self:emit(CardPuzzleCombatPauseMediator.QUIT_COMBAT, {})
	end, SFX_PANEL)
	onButton(self, self._tf:Find("btn_resume"), function()
		self:OnBackward()
	end, SFX_PANEL)
end

function CardPuzzleCombatPauseLayer:OnBackward()
	self:emit(CardPuzzleCombatPauseMediator.RESUME_COMBAT)
	self:closeView()

	return true
end

function CardPuzzleCombatPauseLayer:willExit()
	return
end

return CardPuzzleCombatPauseLayer
