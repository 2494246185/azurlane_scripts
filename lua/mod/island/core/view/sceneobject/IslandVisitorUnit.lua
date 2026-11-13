local IslandVisitorUnit = class("IslandVisitorUnit", import(".IslandNavigableUnit"))
local var_0_1 = 3
local var_0_2 = 6

function IslandVisitorUnit:OnUpdate()
	if self.delayTime == 0 then
		return
	end

	if self.isSleeping then
		return
	end

	self:MoveHandle()
	self:AnimHandle()
end

function IslandVisitorUnit:OnStart()
	self.behaviourTreeOwner.graph.blackboard:SetVariableValue("playerId", tostring(self.id))
end

function IslandVisitorUnit:OnLaterAttach(arg_3_1)
	IslandVisitorUnit.super.OnLaterAttach(self, arg_3_1)

	self.delayTime = 0
	self.syncData = nil
	self.animSpeed = 0
end

function IslandVisitorUnit:UpdateSyncData(arg_4_1)
	self.syncData = arg_4_1
	self.delayTime = IslandConst.SYNC_TIME_INTERVAL
end

function IslandVisitorUnit:Sleep()
	self.isSleeping = true
end

function IslandVisitorUnit:WakeUp()
	self.isSleeping = false
end

function IslandVisitorUnit:MoveHandle()
	local var_7_0
	local var_7_1

	if self.delayTime - Time.deltaTime > 0 then
		var_7_0 = Vector3.Lerp(self:GetPosition(), self.syncData.pos, Time.deltaTime / self.delayTime)
		var_7_1 = Quaternion.Lerp(self:GetRotation(), self:GetSyncDataRotation(), Time.deltaTime / self.delayTime)
		self.delayTime = self.delayTime - Time.deltaTime
	else
		var_7_0 = self.syncData.pos
		var_7_1 = self:GetSyncDataRotation()
		self.delayTime = 0
	end

	if Time.deltaTime > 0 then
		local var_7_2 = (var_7_0 - self:GetPosition()) / Time.deltaTime

		self.speed = Vector2(var_7_2.x, var_7_2.z).magnitude
	end

	self:SetPosition(var_7_0)
	self:SetRotation(var_7_1)
end

function IslandVisitorUnit:AnimHandle()
	local var_8_0 = self.speed or 0

	if var_8_0 < 0.1 then
		var_8_0 = 0
	end

	self.animSpeed = Mathf.Lerp(self.animSpeed, var_8_0, ((var_8_0 > self.animSpeed or nil) and (var_0_1 or var_0_2)) * Time.deltaTime)

	local var_8_1 = self:GetAnimator()

	var_8_1:SetFloat(IslandConst.SPEED_FLAG_HASH, self.animSpeed)

	for iter_8_0 = 1, var_8_1.layerCount do
		if not var_8_1:IsInTransition(iter_8_0 - 1) then
			if self.syncData.status[iter_8_0] and var_8_1:GetCurrentAnimatorStateInfo(iter_8_0 - 1).shortNameHash ~= self.syncData.status[iter_8_0] then
				var_8_1:CrossFadeInFixedTime(self.syncData.status[iter_8_0], 0.25, iter_8_0 - 1)
			end
		end
	end
end

function IslandVisitorUnit:GetSyncDataRotation()
	return self.syncData.dir
end

function IslandVisitorUnit:GetPosition()
	return self._go.transform.position
end

function IslandVisitorUnit:GetRotation()
	return self._go.transform.rotation
end

function IslandVisitorUnit:SetPosition(arg_12_1)
	self._go.transform.position = arg_12_1
end

function IslandVisitorUnit:SetRotation(arg_13_1)
	self._go.transform.rotation = arg_13_1
end

function IslandVisitorUnit:SetShipDressHelper(arg_14_1)
	self.shipDressHelper = arg_14_1
end

function IslandVisitorUnit:OnDetach()
	if self.shipDressHelper then
		self.shipDressHelper:Destroy()
	end
end

function IslandVisitorUnit:OnChangeDress(arg_16_1)
	for iter_16_0, iter_16_1 in pairs(arg_16_1) do
		if iter_16_1.changedDressColorId then
			if not iter_16_1.changeedDressId then
				self.shipDressHelper:ChangeCommanderPartColor(iter_16_0, iter_16_1.changedDressColorId)
			else
				self.shipDressHelper:ChangeDressByType(iter_16_0, {
					id = iter_16_1.changeedDressId,
					colorId = iter_16_1.changedDressColorId
				})
			end
		end
	end
end

return IslandVisitorUnit
