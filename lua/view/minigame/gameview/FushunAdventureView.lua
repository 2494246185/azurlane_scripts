local FushunAdventureView = class("FushunAdventureView", import("..BaseMiniGameView"))

function FushunAdventureView:getUIName()
	return "FushunAdventureUI"
end

function FushunAdventureView:getBGM()
	return FushunAdventureGameConst.BGM_NAME
end

function FushunAdventureView:didEnter()
	self.game = FushunAdventureGame.New(self._go, self:GetMGHubData(), self:GetMGData())

	self.game:SetOnShowResult(function(arg_4_0)
		if self:GetMGHubData().count > 0 then
			self:SendSuccess(0)
		end

		local var_4_0 = self:GetMGData():GetRuntimeData("elements")

		var_4_0 = var_4_0 or {}

		if (var_4_0[1] or 0) < arg_4_0 then
			self:StoreDataToServer({
				arg_4_0
			})
		end
	end)
	self.game:SetOnLevelUpdate(function()
		self:CheckAaward()
	end)
	onButton(self, findTF(self._go, "back"), function()
		self:emit(FushunAdventureView.ON_BACK)
	end, SFX_PANEL)
	self:CheckAaward()
end

function FushunAdventureView:CheckAaward()
	local var_7_0 = self:GetMGHubData()

	if var_7_0.ultimate == 0 and var_7_0:getConfig("reward_need") <= var_7_0.usedtime then
		pg.m02:sendNotification(GAME.SEND_MINI_GAME_OP, {
			hubid = var_7_0.id,
			cmd = MiniGameOPCommand.CMD_ULTIMATE,
			args1 = {}
		})
	end
end

function FushunAdventureView:willExit()
	if self.game then
		self.game:Dispose()

		self.game = nil
	end
end

function FushunAdventureView:OnSendMiniGameOPDone()
	if self.game then
		self.game:RefreshLevels()
	end
end

function FushunAdventureView:onBackPressed()
	if self.game and self.game:IsStarting() then
		self.game:ShowPauseMsgbox()
	end
end

return FushunAdventureView
