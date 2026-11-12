local NewYearShrinePage2025 = class("NewYearShrinePage2025", import(".NewYearShrinePage"))

NewYearShrinePage2025.GO_MINI_GAME_ID = 71

function NewYearShrinePage2025:OnFirstFlush()
	NewYearShrinePage2025.super.OnFirstFlush(self)
	onButton(self, self.goBtn, function()
		pg.m02:sendNotification(GAME.GO_MINI_GAME, NewYearShrinePage2025.GO_MINI_GAME_ID, {})
	end, SFX_PANEL)
end

return NewYearShrinePage2025
