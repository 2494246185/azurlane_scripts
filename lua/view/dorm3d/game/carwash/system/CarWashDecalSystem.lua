local CarWashDecalSystem = class("CarWashDecalSystem", import("view.dorm3d.Game.CarWash.CarWashBaseSystem"))

CarWashDecalSystem.GENERATE_DECALS = "CarWashDecalSystem.GENERATE_DECALS"
CarWashDecalSystem.GENERATOR_NAME = "[DECALROOT]/[DECAL GENERATOR]"
CarWashDecalSystem.ON_SHOOT_INTERVAL = 0.1

function CarWashDecalSystem:OnInit()
	self:InitSceneRefs()

	self.selectedCarDecalType = nil
	self.selectedLadyDecalType = nil
	self.isShooting = false
end

function CarWashDecalSystem:RegisterEvents()
	self:Bind(CarWashDecalSystem.GENERATE_DECALS, function(arg_3_0)
		self:RegenerateAll(System.Action_int(function(arg_4_0)
			self:Emit(CarWashGameFlowSystem.SET_STAINS_COUNT_MAX, arg_4_0)
			self:Emit(CarWashGameFlowSystem.SET_STAINS_COUNT, arg_4_0)
		end))
	end)
	self:Bind(CarWashGameFlowSystem.UPDATE_IS_SHOOTING, function(arg_5_0, arg_5_1)
		self.isShooting = arg_5_1.newValue
	end)
	self:Bind(CarWashGameFlowSystem.UPDATE_CURRENT_GUN_TYPE, function(arg_6_0, arg_6_1)
		self:OnSwitchGun(arg_6_1.newValue)
	end)
	self:Bind(CarWashRaycastSystem.UPDATE_DECAL_RAYCAST, function(arg_7_0, arg_7_1)
		self:OnShootLogic(arg_7_1)
	end)
	self:Bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_BEGIN, function(arg_8_0)
		self:EnableDecalRoot(false)
	end)
	self:Bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_END, function(arg_9_0)
		self:EnableDecalRoot(true)
	end)
	self:Bind(CarWashGameFlowSystem.UPDATE_GAME_STATE, function(arg_10_0, arg_10_1)
		if arg_10_1.newValue == CarWashConst.GAME_STATE.PHASE_2 then
			self:EnableDecalRoot(false)
		elseif arg_10_1.newValue == CarWashConst.GAME_STATE.PHASE_1 then
			self:EnableDecalRoot(true)
		end
	end)
end

function CarWashDecalSystem:OnDispose()
	self.randomDecalGenerator = nil
	self.generatorTF = nil
	self.decalParent = nil
end

function CarWashDecalSystem:InitSceneRefs()
	local var_12_0 = GameObject.Find(CarWashDecalSystem.GENERATOR_NAME)

	assert(var_12_0, "CarWash RandomDecalGenerator object not found: " .. CarWashDecalSystem.GENERATOR_NAME)

	self.generatorTF = var_12_0.transform
	self.decalParent = self.generatorTF
	self.randomDecalGenerator = var_12_0:GetComponent(typeof(RandomDecalGenerator))

	assert(self.randomDecalGenerator, "RandomDecalGenerator component not found on " .. CarWashDecalSystem.GENERATOR_NAME)
end

function CarWashDecalSystem:EnableDecalRoot(arg_13_1)
	if self.randomDecalGenerator then
		self.randomDecalGenerator:SetGeneratedActive(arg_13_1)
	end

	if self.decalParent then
		setActive(self.decalParent, arg_13_1)
	end
end

function CarWashDecalSystem:GenerateDecals()
	return self:GenerateAll()
end

function CarWashDecalSystem:OnSwitchGun(arg_15_1)
	local var_15_0 = CarWashConst.GetGunConfig(arg_15_1)

	assert(var_15_0, "CarWash gun config not found: " .. tostring(arg_15_1))
	assert(var_15_0.decalType, "CarWash decal types not found for gun type: " .. tostring(arg_15_1))
	assert(var_15_0.decalType.onCar, "CarWash car decal type not found for gun type: " .. tostring(arg_15_1))
	assert(var_15_0.decalType.onLady, "CarWash lady decal type not found for gun type: " .. tostring(arg_15_1))

	self.currentGunType = arg_15_1
	self.selectedCarDecalType = var_15_0.decalType.onCar
	self.selectedLadyDecalType = var_15_0.decalType.onLady
end

function CarWashDecalSystem:OnShootLogic(arg_16_1)
	local var_16_4
	local var_16_2
	local var_16_1
	local var_16_0
	local var_16_5
	local var_16_3

	if not self.isShooting then
		do return end

		var_16_0 = false
		var_16_2 = false
		var_16_3 = {}
		var_16_4 = 16191
		var_16_5 = 16191
	end

	for iter_16_0, iter_16_1 in ipairs(arg_16_1.targets) do
		if iter_16_1.gameObject.layer == CarWashConst.CAR_LAYER then
			var_16_2 = true
			var_16_4 = math.min(var_16_4, iter_16_0)
		end

		if iter_16_1.gameObject.layer == CarWashConst.LADY_LAYER then
			var_16_0 = true
			var_16_1 = iter_16_1.gameObject.transform
			var_16_5 = math.min(var_16_5, iter_16_0)
		end

		local var_16_6 = iter_16_1.gameObject:GetComponent(typeof(DecalController))

		if var_16_6 then
			table.insert(var_16_3, var_16_6)
		end
	end

	if arg_16_1.hit and var_16_0 and var_16_5 < var_16_4 and not table.contains(self:GetGameConfig().non_decal_colliders, arg_16_1.hitInfo.collider.name) then
		assert(arg_16_1.hitInfo, "CarWash decal hitInfo is nil")

		if not _.any(var_16_3, function(arg_17_0)
			return arg_17_0.decalType == self.selectedLadyDecalType
		end) then
			self:GenerateDecalAtScreenCenter(self.selectedLadyDecalType, arg_16_1.hitInfo, self:GetColliderBone(var_16_1), self:GetCapsuleColliderRadius(var_16_1))
		end
	end

	if arg_16_1.hit and var_16_2 and var_16_4 < var_16_5 then
		assert(arg_16_1.hitInfo, "CarWash decal hitInfo is nil")

		local var_16_7 = self:FindDecalFaceFilter(arg_16_1.hitInfo.collider)

		if var_16_7 and not var_16_7:IsAllowed(arg_16_1.hitInfo.normal) then
			return
		end

		if not _.any(var_16_3, function(arg_18_0)
			return arg_18_0.decalType == self.selectedCarDecalType
		end) then
			self:GenerateDecalAtScreenCenter(self.selectedCarDecalType, arg_16_1.hitInfo)
		end

		for iter_16_2, iter_16_3 in ipairs(var_16_3) do
			local var_16_8 = CarWashConst.GetStainsConfig(iter_16_3.decalType)

			if var_16_8 then
				local var_16_10 = self.currentGunType == var_16_8.targetGunType
				local var_16_12 = 0 + ((var_16_10 or nil) and (var_16_8.fadePerSec or 0)) + ((var_16_10 and var_16_8.coverDecal and _.any(var_16_3, function(arg_19_0)
					return arg_19_0.decalType == var_16_8.coverDecal
				end) or nil) and (var_16_8.coverBuff or 0))

				if var_16_12 > 0 then
					iter_16_3:SetAlpha(iter_16_3.Alpha - var_16_12 * CarWashDecalSystem.ON_SHOOT_INTERVAL)
				end

				if iter_16_3.Alpha <= 0 then
					StaticDecalSpawner.Despawn(iter_16_3)
					self:Emit(CarWashGameFlowSystem.DECREASE_STAINS_COUNT, 1)
				end
			end
		end
	end
end

function CarWashDecalSystem:FindDecalFaceFilter(arg_20_1)
	if not arg_20_1 then
		return nil
	end

	return arg_20_1:GetComponentInChildren(typeof(DecalFaceFilter), true)
end

function CarWashDecalSystem:GetColliderBone(arg_21_1)
	return arg_21_1.parent
end

function CarWashDecalSystem:GetCapsuleColliderRadius(arg_22_1)
	local var_22_0 = arg_22_1:GetComponent(typeof("UnityEngine.CapsuleCollider"))

	return math.min((var_22_0 or nil) and var_22_0.radius * 2 - 0.01, CarWashConst.DEFAULT_LADY_DECAL_SIZE)
end

function CarWashDecalSystem:GenerateDecalAtScreenCenter(arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	assert(arg_23_1, "CarWash decal type is nil")

	local var_23_0 = CarWashConst.GetDecalConfig(arg_23_1)

	assert(var_23_0, "CarWash decal config not found: " .. tostring(arg_23_1))

	local var_23_1, var_23_2 = DecalRaycastUtil.TryComputeDecalPlacement(arg_23_2.point, arg_23_2.normal, math.floor((arg_23_4 or math.random() * (CarWashConst.ORTHOGRAPHIC_SIZE_RANGE[2] - CarWashConst.ORTHOGRAPHIC_SIZE_RANGE[1]) + CarWashConst.ORTHOGRAPHIC_SIZE_RANGE[1]) * 100) / 100, var_23_0.aspectRatio, CarWashConst.LAYER_MASK, math.random() * (CarWashConst.ROTATE_RANGE[2] - CarWashConst.ROTATE_RANGE[1]) + CarWashConst.ROTATE_RANGE[1], self:FindDecalFaceFilter(arg_23_2.collider), nil)

	if not var_23_1 then
		return nil
	end

	local var_23_3 = self:GetSourceMaterial(var_23_0.sourceMaterial)

	if not var_23_3 then
		return nil
	end

	return DecalControllerPoolMgr.Inst:Acquire(var_23_2.position, var_23_2.rotation, arg_23_3 or self.decalParent, var_23_3, var_23_2.orthographicSize, var_23_0.aspectRatio, var_23_2.nearClip, var_23_2.farClip, var_23_0.renderQueue, var_23_0.decalType or arg_23_1, var_23_0.useAutoFade, var_23_0.autoFadeStartTime, var_23_0.autoFadeTime)
end

function CarWashDecalSystem:GetSourceMaterial(arg_24_1)
	assert(type(arg_24_1) == "table", "CarWash decal sourceMaterial config should be table")
	assert(#arg_24_1 > 0, "CarWash decal sourceMaterial config is empty")

	local var_24_0 = arg_24_1[math.random(1, #arg_24_1)]

	assert(DecalMaterialPoolMgr.Inst, "DecalMaterialPoolMgr.Inst not found")

	local var_24_1 = DecalMaterialPoolMgr.Inst.sourceMaterials

	assert(DecalMaterialPoolMgr.Inst.sourceMaterials, "DecalMaterialPoolMgr.sourceMaterials not found")
	assert(var_24_0 >= 0 and var_24_0 < var_24_1.Count, "Invalid decal sourceMaterial index: " .. tostring(var_24_0))

	return var_24_1:get_Item(var_24_0)
end

function CarWashDecalSystem:GenerateAll()
	if not self.randomDecalGenerator then
		return 0
	end

	return self.randomDecalGenerator:GenerateAll()
end

function CarWashDecalSystem:GenerateRegion(arg_26_1)
	if not self.randomDecalGenerator then
		return 0
	end

	return self.randomDecalGenerator:GenerateRegion(arg_26_1)
end

function CarWashDecalSystem:RegenerateAll(arg_27_1)
	if not self.randomDecalGenerator then
		return 0
	end

	return self.randomDecalGenerator:RegenerateAll(arg_27_1)
end

function CarWashDecalSystem:RegenerateRegion(arg_28_1)
	if not self.randomDecalGenerator then
		return 0
	end

	return self.randomDecalGenerator:RegenerateRegion(arg_28_1)
end

function CarWashDecalSystem:ClearGenerated()
	if not self.randomDecalGenerator then
		return
	end

	self.randomDecalGenerator:ClearGenerated()
end

return CarWashDecalSystem
