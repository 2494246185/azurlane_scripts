local ValentineQteGameView = class("ValentineQteGameView", import("..BaseMiniGameView"))

function ValentineQteGameView:getUIName()
	return "ValentineQteGamePage"
end

function ValentineQteGameView:init()
	self.gameView = ValentineQteGamePage.New(self._tf)
end

function ValentineQteGameView:didEnter()
	self.gameView:SetUp(function()
		if self:GetMGHubData().count > 0 then
			self:SendSuccess(0)
		end
	end, function()
		if self.gameView then
			self.gameView = nil
		end

		self:emit(ValentineQteGameView.ON_BACK)
	end, self:GetMGHubData().usedtime == 0)
end

function ValentineQteGameView:onBackPressed()
	if self.gameView and self.gameView:onBackPressed() then
		return
	end

	ValentineQteGameView.super.onBackPressed(self)
end

function ValentineQteGameView:willExit()
	if self.gameView then
		self.gameView:Destroy()

		self.gameView = nil
	end
end

return ValentineQteGameView
