local IslandVirtualInteractUnit = class("IslandVirtualInteractUnit", import(".IslandInteractUnit"))

function IslandVirtualInteractUnit:Ctor(arg_1_1, arg_1_2)
	IslandVirtualInteractUnit.super.Ctor(self, arg_1_1, arg_1_2)

	self.attach = "AgoraMainStage/furniture/" .. (function()
		return math.floor(self.id / 10)
	end)() .. "/" .. arg_1_2.config.attach
end

function IslandVirtualInteractUnit:OnAttach(arg_3_1)
	IslandVirtualInteractUnit.super.OnAttach(self, arg_3_1)
	self.signalReceiver:SetCommonEvent(function(arg_4_0)
		if self.ignoreSignal then
			return
		end

		switch(arg_4_0.stringParameter, {
			TimelineEnd = function()
				self:Op("AgoraVirtualInterActionEnd", self.id, self.view.player.id)
			end
		})
	end)
end

function IslandVirtualInteractUnit:GetTargetRoot()
	if self.attachGo then
		return self.attachGo.transform
	else
		self.attachGo = GameObject.Find(self.attach)

		return self.attachGo.transform
	end
end

function IslandVirtualInteractUnit:GetPlayerParent(arg_7_1)
	local var_7_0 = self.data:GetPlayerParentPath(arg_7_1)

	if var_7_0 == nil then
		return self:GetTargetRoot()
	else
		local var_7_1 = self:GetTargetRoot():Find(var_7_0)

		assert(var_7_1, "can't find player parent with path: " .. var_7_0)

		return var_7_1
	end
end

return IslandVirtualInteractUnit
