local GuildBossFormationShipCard = class("GuildBossFormationShipCard")

function GuildBossFormationShipCard:Ctor(arg_1_1)
	self._char = arg_1_1
	self._go = arg_1_1:GetModel()
	tf(self._go).pivot = Vector2(0.5, 0)
	tf(self._go).sizeDelta = Vector2(200, 300)

	arg_1_1:SetLocalScale(Vector3(0.6, 0.6, 0.6))
end

function GuildBossFormationShipCard:RefreshPosition(arg_2_1, arg_2_2)
	self.soltIndex = arg_2_1

	if arg_2_2 then
		self:UpdateLocalPosition()
	end
end

function GuildBossFormationShipCard:UpdateLocalPosition()
	self:SetLocalPosition(self._go.transform.parent:Find(self.soltIndex).localPosition)
end

function GuildBossFormationShipCard:SetLocalPosition(arg_4_1)
	self._go.transform.localPosition = arg_4_1
end

function GuildBossFormationShipCard:GetLocalPosition()
	return self._go.transform.localPosition
end

function GuildBossFormationShipCard:GetSoltIndex()
	return self.soltIndex
end

function GuildBossFormationShipCard:Update(arg_7_1, arg_7_2)
	self.shipId = arg_7_1.id
	self.teamType = arg_7_1:getTeamType()

	self:RefreshPosition(arg_7_2, true)
end

function GuildBossFormationShipCard:Dispose()
	if self._go then
		tf(self._go).pivot = Vector2(0.5, 0.5)
	end

	ClearEventTrigger(GetOrAddComponent(self._go, "EventTriggerListener"))

	if self._char then
		self._char:Dispose()
	end
end

return GuildBossFormationShipCard
