local IslandInteractUnit = class("IslandInteractUnit", import(".IslandSceneUnit"))

function IslandInteractUnit:OnAttach(arg_1_1)
	local var_1_0 = arg_1_1 or self._go

	self.signalReceiver = GetOrAddComponent(arg_1_1 or self._go, "DftCommonSignalReceiver")

	self.signalReceiver:SetCommonEvent(function(arg_2_0)
		if self.ignoreSignal then
			return
		end

		switch(arg_2_0.stringParameter, {
			TimelineEnd = function()
				self:Op("WorldObjectInterActionEnd", self.id, self.view.player.id)
			end
		})
	end)

	self.director = GetOrAddComponent(var_1_0, typeof(UnityEngine.Playables.PlayableDirector))
	self.cachePlayerTransformInfoDic = {}
end

function IslandInteractUnit:SetTimelineDic(arg_4_1)
	self.timelineDic = arg_4_1
end

function IslandInteractUnit:GetTargetRoot()
	return self._go.transform
end

function IslandInteractUnit:GetPlayerParent(arg_6_1)
	return self:GetTargetRoot()
end

function IslandInteractUnit:StartInteract(arg_7_1, arg_7_2, arg_7_3, arg_7_4, arg_7_5)
	local var_7_0 = self.data:GetTimeline()[arg_7_3]
	local var_7_1 = self.data:GetBlackboardParam()[arg_7_3]

	if arg_7_4 then
		self.director:Stop()
	end

	arg_7_1:ActiveOrDisactive(false)

	if arg_7_5 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue("inProgress", true)

		self.ignoreSignal = false
	else
		self.ignoreSignal = true
	end

	self:SetPlayerTransform(arg_7_1, self:GetPlayerParent(arg_7_2))

	if var_7_1 and #var_7_1 > 1 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue(var_7_1[1], var_7_1[2])
	end

	self.director.playableAsset = self.timelineDic[arg_7_3]

	if var_7_0.is_loop == 1 then
		self.director.extrapolationMode = UnityEngine.Playables.DirectorWrapMode.Loop or UnityEngine.Playables.DirectorWrapMode.None
	end

	self:BindPlayer(arg_7_2, arg_7_1)
	self:BindSelf(var_7_0)

	self.director.enabled = true

	self.director:Play()
end

function IslandInteractUnit:EndInteract(arg_8_1, arg_8_2, arg_8_3, arg_8_4)
	if arg_8_3 then
		if self.director.extrapolationMode == UnityEngine.Playables.DirectorWrapMode.None then
			self.director.time = self.director.duration or 0
		end

		self.director:Evaluate()
		self.director:Stop()

		self.director.enabled = false
	end

	self:BindPlayer(arg_8_2, nil)

	if arg_8_1 then
		arg_8_1:ActiveOrDisactive(true)
	end

	if arg_8_4 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue("inProgress", false)
	end

	self:RevertPlayerTransform(arg_8_1)
end

function IslandInteractUnit:InitStatus(arg_9_1, arg_9_2, arg_9_3)
	if arg_9_3 and #arg_9_3 > 1 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue(arg_9_3[1], arg_9_3[2])
	end

	self.director.playableAsset = self.timelineDic[arg_9_1]

	self:BindSelf(arg_9_2)

	self.ignoreSignal = true
	self.director.enabled = true

	self.director:Play()

	self.director.time = self.director.duration

	self.director:Evaluate()
	self.director:Stop()
end

function IslandInteractUnit:BindSelf(arg_10_1)
	local var_10_0 = TimelineHelper.GetGroupTracks(self.director):ToTable()

	if #var_10_0 > 0 then
		local var_10_1 = TimelineHelper.GetChildTracks(var_10_0[1]):ToTable()

		for iter_10_0, iter_10_1 in ipairs(var_10_1) do
			local var_10_2, var_10_3 = table.Find(arg_10_1.binding_track, function(arg_11_0, arg_11_1)
				return arg_11_1 == iter_10_0
			end)

			if var_10_3 ~= nil then
				if arg_10_1.binding_path[var_10_3] == "" then
					local var_10_4 = self:GetTargetRoot() or self:GetTargetRoot():Find(arg_10_1.binding_path[var_10_3])

					if var_10_4 then
						TimelineHelper.SetAutoBinding(self.director, iter_10_1, go(var_10_4))
					end
				end
			end
		end

		for iter_10_2, iter_10_3 in ipairs(arg_10_1.control_binding or {}) do
			local var_10_5 = iter_10_3[2]
			local var_10_6 = iter_10_3[3] or ""

			if var_10_1[iter_10_3[1]] and var_10_5 and var_10_5 > 0 then
				if var_10_6 == "" then
					local var_10_7 = self:GetTargetRoot() or self:GetTargetRoot():Find(var_10_6)

					if var_10_7 then
						TimelineHelper.SetControlBinding(self.director, var_10_1[iter_10_3[1]], var_10_5 - 1, go(var_10_7))
					end
				end
			end
		end
	end
end

function IslandInteractUnit:BindPlayer(arg_12_1, arg_12_2)
	self:BindCharacterTracks(self:GetRootGroup(IslandInteractUnit.ROOT_GROUP_COMMANDER), arg_12_1, arg_12_2)
end

IslandInteractUnit.ROOT_GROUP_ITEM = 1
IslandInteractUnit.ROOT_GROUP_COMMANDER = 2
IslandInteractUnit.ROOT_GROUP_EXTROVERT = 3
IslandInteractUnit.ROOT_GROUP_INTROVERT = 4

function IslandInteractUnit:GetRootGroup(arg_13_1)
	local var_13_0 = TimelineHelper.GetGroupTracks(self.director):ToTable()[arg_13_1]

	if not var_13_0 then
		warning(string.format("timeline missing root group index=%d (unit=%s)", arg_13_1, tostring(self.id)))
	end

	return var_13_0
end

function IslandInteractUnit:BindCharacterTracks(arg_14_1, arg_14_2, arg_14_3)
	if not arg_14_1 then
		return
	end

	local var_14_0 = TimelineHelper.GetChildTracks(arg_14_1):ToTable()[arg_14_2]

	if not var_14_0 then
		return
	end

	local var_14_1 = TimelineHelper.GetChildTracks(var_14_0)
	local var_14_2 = arg_14_3 and arg_14_3._go
	local var_14_3 = arg_14_3 and go(arg_14_3._go.transform:GetChild(0))

	for iter_14_0, iter_14_1 in ipairs((var_14_1:ToTable())) do
		if iter_14_0 == 1 then
			TimelineHelper.SetAutoBinding(self.director, iter_14_1, var_14_2)
		else
			TimelineHelper.SetAutoBinding(self.director, iter_14_1, var_14_3)
		end
	end
end

function IslandInteractUnit:SetShipTransform(arg_15_1, arg_15_2)
	self.cacheShipTransformInfoDic = self.cacheShipTransformInfoDic or {}
	self.cacheShipTransformInfoDic[arg_15_1.id] = {
		position = arg_15_1._tf.position,
		rotation = arg_15_1._tf.rotation
	}

	setParent(arg_15_1._tf, self:GetPlayerParent(arg_15_2))

	arg_15_1._tf.localPosition = Vector3.zero
	arg_15_1._tf.localRotation = Quaternion.identity
end

function IslandInteractUnit:RevertShipTransform(arg_16_1)
	if not self.view or not arg_16_1 or not arg_16_1._tf then
		return
	end

	local var_16_0 = self.cacheShipTransformInfoDic and self.cacheShipTransformInfoDic[arg_16_1.id]

	if not var_16_0 then
		return
	end

	setParent(arg_16_1._tf, self.view.root)

	arg_16_1._tf.position = var_16_0.position
	arg_16_1._tf.rotation = var_16_0.rotation
	self.cacheShipTransformInfoDic[arg_16_1.id] = nil
end

function IslandInteractUnit:StartShipInteract(arg_17_1, arg_17_2, arg_17_3, arg_17_4)
	local var_17_0 = self.data:GetTimeline()[arg_17_3]
	local var_17_1 = self.data:GetBlackboardParam()[arg_17_3]

	arg_17_1:ActiveOrDisactive(false)

	if arg_17_4 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue("inProgress", true)

		self.ignoreSignal = false
	else
		self.ignoreSignal = true
	end

	self:SetPlayerTransform(arg_17_1, self:GetPlayerParent(1))

	for iter_17_0, iter_17_1 in ipairs(arg_17_2) do
		iter_17_1:ActiveOrDisactive(false)
		iter_17_1:PauseBt()
		self:SetShipTransform(iter_17_1, iter_17_0 + 1)
	end

	if var_17_1 and #var_17_1 > 1 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue(var_17_1[1], var_17_1[2])
	end

	self.director.playableAsset = self.timelineDic[arg_17_3]

	if var_17_0.is_loop == 1 then
		self.director.extrapolationMode = UnityEngine.Playables.DirectorWrapMode.Loop or UnityEngine.Playables.DirectorWrapMode.None
	end

	self:BindCharacterTracks(self:GetRootGroup(IslandInteractUnit.ROOT_GROUP_COMMANDER), 1, arg_17_1)

	for iter_17_2, iter_17_3 in ipairs(arg_17_2) do
		local var_17_2 = iter_17_3.data:GetPersonality()
		local var_17_3

		if var_17_2 == 1 then
			var_17_3 = IslandInteractUnit.ROOT_GROUP_EXTROVERT or var_17_2 == 2 and IslandInteractUnit.ROOT_GROUP_INTROVERT
		end

		assert(var_17_3, "ship personality invalid: " .. tostring(var_17_2))
		self:BindCharacterTracks(self:GetRootGroup(var_17_3), iter_17_2 + 1, iter_17_3)
	end

	self:BindSelf(var_17_0)

	self.director.enabled = true

	self.director:Play()
end

function IslandInteractUnit:EndShipInteract(arg_18_1, arg_18_2, arg_18_3, arg_18_4)
	if arg_18_3 then
		if self.director.extrapolationMode == UnityEngine.Playables.DirectorWrapMode.None then
			self.director.time = self.director.duration or 0
		end

		self.director:Evaluate()
		self.director:Stop()

		self.director.enabled = false
	end

	self:BindCharacterTracks(self:GetRootGroup(IslandInteractUnit.ROOT_GROUP_COMMANDER), 1, nil)

	for iter_18_0, iter_18_1 in ipairs(arg_18_2) do
		local var_18_1 = iter_18_1.data and iter_18_1.data.GetPersonality and iter_18_1.data:GetPersonality()

		if var_18_1 == 1 then
			local var_18_2 = IslandInteractUnit.ROOT_GROUP_EXTROVERT or var_18_1 == 2 and IslandInteractUnit.ROOT_GROUP_INTROVERT

			if var_18_2 then
				self:BindCharacterTracks(self:GetRootGroup(var_18_2), iter_18_0 + 1, nil)
			end
		end

		iter_18_1:ActiveOrDisactive(true)
		iter_18_1:RestartBt()
		self:RevertShipTransform(iter_18_1)
	end

	arg_18_1:ActiveOrDisactive(true)

	if arg_18_4 then
		self.behaviourTreeOwner.graph.blackboard:SetVariableValue("inProgress", false)
	end

	self:RevertPlayerTransform(arg_18_1)
end

function IslandInteractUnit:SetPlayerTransform(arg_19_1, arg_19_2)
	self.cachePlayerTransformInfoDic[arg_19_1.id] = {
		position = arg_19_1._tf.position,
		rotation = arg_19_1._tf.rotation
	}

	setParent(arg_19_1._tf, arg_19_2)

	arg_19_1._tf.localPosition = Vector3.zero
	arg_19_1._tf.localRotation = Quaternion.identity
	GetOrAddComponent(arg_19_1._go, typeof(UnityEngine.Animator)).enabled = true
end

function IslandInteractUnit:RevertPlayerTransform(arg_20_1)
	if not self.view or not arg_20_1 or not arg_20_1._tf or not self.cachePlayerTransformInfoDic[arg_20_1.id] then
		return
	end

	setParent(arg_20_1._tf, self.view.root)

	arg_20_1._tf.position = self.cachePlayerTransformInfoDic[arg_20_1.id].position
	arg_20_1._tf.rotation = self.cachePlayerTransformInfoDic[arg_20_1.id].rotation
	GetOrAddComponent(arg_20_1._go, typeof(UnityEngine.Animator)).enabled = false
	self.cachePlayerTransformInfoDic[arg_20_1.id] = nil
end

return IslandInteractUnit
