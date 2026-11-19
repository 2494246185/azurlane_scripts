local SyncLocalPlayer = class("SyncLocalPlayer")

SyncLocalPlayer.ANIMATOR_LAYER = {
	0,
	1,
	2
}

function SyncLocalPlayer:Ctor(arg_1_1, arg_1_2)
	self.id = arg_1_1
	self.sceneObject = arg_1_2
	self.animator = arg_1_2:GetAnimator()
end

function SyncLocalPlayer:GetStatus()
	local var_2_0 = {}

	for iter_2_0, iter_2_1 in ipairs(self.ANIMATOR_LAYER) do
		var_2_0[iter_2_0] = self.animator:GetCurrentAnimatorStateInfo(iter_2_1).shortNameHash
	end

	return var_2_0
end

function SyncLocalPlayer:IsLoaded()
	return self.sceneObject and self.sceneObject:IsLoaded()
end

function SyncLocalPlayer:CreateSyncData()
	return (SyncUnitData.New({
		id = self.id,
		pos = self:GetPosition(),
		dir = self:GetRotation(),
		status = self:GetStatus()
	}))
end

function SyncLocalPlayer:GetPosition()
	return self.sceneObject._go.transform.position
end

function SyncLocalPlayer:GetRotation()
	return self.sceneObject._go.transform.rotation
end

return SyncLocalPlayer
