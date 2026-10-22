local CourtYardReversePacmanController = class("CourtYardReversePacmanController", import(".CourtYardController"))

function CourtYardReversePacmanController:SetUp()
	CourtYardReversePacmanController.super.SetUp(self)
	self:AddChatTimer()
end

function CourtYardReversePacmanController:Dispose()
	self:RemoveChatTimer()
	CourtYardReversePacmanController.super.Dispose(self)
end

function CourtYardReversePacmanController:AddChatTimer()
	self.chatTimer = Timer.New(function()
		local var_4_0 = self:GetShipChat()

		if var_4_0 == 0 then
			return
		end

		local var_4_1 = self.storey:GetShip(ShipGroup.getDefaultShipConfig(pg.ship_skin_template[pg.activity_chasing_character[var_4_0].skin_id].ship_group).id)

		if var_4_1 then
			var_4_1:ShowChatBubble()
		end
	end, math.random(CourtYardConst.REVERSE_PACMAN_CHAT_TIME[1], CourtYardConst.REVERSE_PACMAN_CHAT_TIME[2]), -1)

	self.chatTimer:Start()
end

function CourtYardReversePacmanController:GetShipChat()
	local var_5_0 = {}

	for iter_5_0, iter_5_1 in pairs(ReversePacmanTools.GetActivity():GetFavorabilityList()) do
		table.insert(var_5_0, iter_5_0)
	end

	if #var_5_0 <= 0 then
		return 0
	end

	return var_5_0[math.random(1, #var_5_0)]
end

function CourtYardReversePacmanController:RemoveChatTimer()
	if self.chatTimer then
		self.chatTimer:Stop()

		self.chatTimer = nil
	end
end

return CourtYardReversePacmanController
