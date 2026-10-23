local GameRoomFushun2View = class("GameRoomFushun2View", import("..BaseMiniGameView"))

function GameRoomFushun2View:getUIName()
	return "GameRoomFushun2UI"
end

function GameRoomFushun2View:getBGM()
	return FushunAdventureGameConst.BGM_NAME
end

function GameRoomFushun2View:didEnter()
	self.game = FushunAdventureGame.New(self._go, self:GetMGHubData(), self:GetMGData())

	self.game:SetGameStateCallback(function()
		self:openCoinLayer(false)
	end, function()
		self:openCoinLayer(true)
	end)
	self.game:SetOnShowResult(function(arg_6_0)
		local var_6_0 = self:GetMGHubData()

		self:SendSuccess(arg_6_0)
	end)
	self.game:SetOnLevelUpdate(function()
		self:CheckAaward()
	end)
	self.game:setRoomTip(self:getGameRoomData().game_help)
	self.game:setRoomId(self:getGameRoomData().id)
	onButton(self, findTF(self._go, "back"), function()
		self:emit(GameRoomFushun2View.ON_BACK)
	end, SFX_PANEL)
	self:CheckAaward()
end

function GameRoomFushun2View:CheckAaward()
	return
end

function GameRoomFushun2View:willExit()
	if self.game then
		self.game:Dispose()

		self.game = nil
	end
end

function GameRoomFushun2View:OnSendMiniGameOPDone()
	if self.game then
		self.game:RefreshLevels()
	end
end

function GameRoomFushun2View:onBackPressed()
	if self.game and self.game:IsStarting() then
		self.game:ShowPauseMsgbox()
	end
end

return GameRoomFushun2View
