local LadyEnv = class("LadyEnv", import("view.dorm3d.Core.BaseLadyEnv"))

function LadyEnv:Ctor(arg_1_1)
	self.super.Ctor(self, arg_1_1.event, arg_1_1)
end

function LadyEnv:InitCharacter(arg_2_1)
	self:InitCharacterRoot()
	self:InitCharacterAimIK()
	self:InitCharacterAnimator()
	self:InitCharacterHierarchy()
	self:InitCharacterCollider()
	self:InitCharacterCloth()
	self:InitCharacterIKRoot()
	self:InitCharacterTouchEvent(arg_2_1)
	self:InitCharacterAnimationEvent()
	self:InitCharacterEffects()
	self:InitCharacterBlackboard(arg_2_1)
	self:InitCharacterLayer()
	self:InitCharacterController()
	self:InitCharacterTransparency()
	self:InitCharacterAnimationDispatcher()
end

function LadyEnv:InitCharacterRoot()
	self.lady = self.ladyGameObject.transform

	self.lady:SetParent(self:Get("mainCameraTF"))
	self.lady:SetParent(nil)
end

function LadyEnv:InitCharacterAimIK()
	self.ladyHeadIKComp = self.lady:GetComponent(typeof(HeadAimIK))
	self.ladyHeadIKComp.AimTarget = self:Get("mainCameraTF"):Find("AimTarget")
	self.ladyHeadIKData = {
		DampTime = self.ladyHeadIKComp.DampTime,
		blinkSpeed = self.ladyHeadIKComp.blinkSpeed,
		BodyWeight = self.ladyHeadIKComp.BodyWeight,
		HeadWeight = self.ladyHeadIKComp.HeadWeight
	}
end

function LadyEnv:InitCharacterAnimator()
	self.ladyAnimator = self.lady:GetComponent(typeof(Animator))
	self.ladyAnimBaseLayerIndex = self.ladyAnimator:GetLayerIndex("Base Layer")
	self.ladyAnimFaceLayerIndex = self.ladyAnimator:GetLayerIndex("Face")
end

function LadyEnv:InitCharacterHierarchy()
	local var_6_0 = {}

	table.Foreach(DormConst.boneMap, function(arg_7_0, arg_7_1)
		var_6_0[arg_7_1] = arg_7_0
	end)

	self.ladyBoneMaps = {}

	table.IpairsCArray(self.lady:GetComponentsInChildren(typeof(Transform), true), function(arg_8_0, arg_8_1)
		if arg_8_1.name == "BodyCollider" then
			self.ladyCollider = arg_8_1

			setActive(arg_8_1, true)
		elseif arg_8_1.name == "SafeCollider" then
			self.ladySafeCollider = arg_8_1

			setActive(arg_8_1, false)
		elseif arg_8_1.name == "Interest" then
			self.ladyInterestRoot = arg_8_1
		elseif arg_8_1.name == "Head Center" then
			self.ladyHeadCenter = arg_8_1
		end

		if var_6_0[arg_8_1.name] then
			self.ladyBoneMaps[var_6_0[arg_8_1.name]] = arg_8_1
		end
	end)
end

function LadyEnv:InitCharacterCollider()
	self.ladyColliders = {}
	self.ladyTouchColliders = {}

	table.IpairsCArray(self.lady:GetComponentsInChildren(typeof(UnityEngine.Collider), true), function(arg_10_0, arg_10_1)
		if arg_10_1:GetType():Equals(typeof(UnityEngine.MeshCollider)) then
			return
		end

		local var_10_0 = tf(arg_10_1)
		local var_10_1 = string.sub(var_10_0.name, 1, (var_10_0.name and string.find(var_10_0.name, "Collider") or -1) - 1)

		if DormConst.BONE_TO_TOUCH[var_10_1] == nil then
			return
		end

		self.ladyColliders[var_10_1] = var_10_0

		table.insert(self.ladyTouchColliders, var_10_0)
		setActive(var_10_0, false)
	end)
end

function LadyEnv:InitCharacterCloth()
	self.clothComps = {}
	self.ladyClothCompSettings = {}

	table.IpairsCArray(self.lady:GetComponentsInChildren(typeof("MagicaCloth2.MagicaCloth"), true), function(arg_12_0, arg_12_1)
		table.insert(self.clothComps, arg_12_1)

		self.ladyClothCompSettings[arg_12_1] = {
			enabled = arg_12_1.enabled
		}
	end)

	self.clothColliderDict = {}
	self.ladyClothColliderSettings = {}

	table.IpairsCArray(self.lady:GetComponentsInChildren(typeof("MagicaCloth2.MagicaCapsuleCollider"), true), function(arg_13_0, arg_13_1)
		local var_13_0 = arg_13_1:GetSize()

		self.clothColliderDict[arg_13_1.name] = arg_13_1
		self.ladyClothColliderSettings[arg_13_1] = {
			enabled = arg_13_1.enabled,
			StartRadius = var_13_0.x,
			EndRadius = var_13_0.y
		}
	end)
	self:EnableCloth(false)
end

function LadyEnv:InitCharacterIKRoot()
	self.ladyIKRoot = self.lady:Find("IKLayers")

	eachChild(self.ladyIKRoot, function(arg_15_0)
		setActive(arg_15_0, false)
	end)
end

function LadyEnv:InitCharacterTouchEvent(arg_16_1)
	GetComponent(self.lady, typeof(EventTriggerListener)):AddPointClickFunc(function(arg_17_0, arg_17_1)
		if arg_17_1.rawPointerPress.transform == self.ladyCollider then
			self:Emit(Dorm3dRoomTemplateScene.CLICK_CHARACTER, arg_16_1)
		end
	end)
end

function LadyEnv:InitCharacterAnimationEvent()
	self.ladyAnimator:GetComponent("DftAniEvent"):SetCommonEvent(function(arg_19_0)
		if self.nowState and arg_19_0.animatorStateInfo:IsName(self.nowState) then
			existCall(self.stateCallback)

			return
		end

		local var_19_0 = arg_19_0.animatorStateInfo

		for iter_19_0, iter_19_1 in pairs(self.animCallbacks) do
			if var_19_0:IsName(iter_19_0) then
				warning("Active", iter_19_0)
				existCall((table.removebykey(self.animCallbacks, iter_19_0)))

				return
			end
		end

		if arg_19_0.stringParameter ~= "" then
			self:Func("OnAnimationEvent", arg_19_0)
		end
	end)

	self.animEventCallbacks = {}
	self.animCallbacks = {}
end

function LadyEnv:InitCharacterEffects()
	local function var_20_0(arg_21_0, arg_21_1, arg_21_2)
		self:Get("loader"):GetPrefab(arg_21_0, arg_21_1, function(arg_22_0)
			arg_22_0.name = arg_21_2
			self[arg_21_2] = tf(arg_22_0)

			setActive(arg_22_0, false)
			onNextTick(function()
				setParent(self[arg_21_2], self.ladyHeadCenter)
			end)
		end)
	end

	self.effectHeart = self.ladyHeadCenter:Find("effectHeart")

	if not self.effectHeart then
		var_20_0("dorm3d/effect/prefab/function/vfx_function_aixin02", "vfx_function_aixin02", "effectHeart")
	end

	self.ladyWatchFloat = self.ladyHeadCenter:Find("ladyWatchFloat")

	if not self.ladyWatchFloat then
		var_20_0("dorm3d/effect/prefab/function/vfx_talk_mark", "vfx_talk_mark", "ladyWatchFloat")
	end

	if self.tfPendintItem then
		onNextTick(function()
			setParent(self.tfPendintItem, self.lady)
		end)
	end
end

function LadyEnv:InitCharacterBlackboard(arg_25_1)
	self.ladyOwner = GetComponent(self.lady, "GraphOwner")
	self.ladyBlackboard = GetComponent(self.lady, "Blackboard")

	self:SetBlackboardValue("groupId", arg_25_1)
	onNextTick(function()
		self.ladyOwner.enabled = true
	end)
end

function LadyEnv:InitCharacterLayer()
	pg.ViewUtils.SetLayer(self.lady, Layer.Character3D)
end

function LadyEnv:InitCharacterController()
	self.characterController = GetOrAddComponent(self.ladyGameObject, typeof(CharacterController))
	self.characterController.enabled = false
	self.characterController.center = DormConst.CHARACTER_CONTROLLER.center
	self.characterController.radius = DormConst.CHARACTER_CONTROLLER.radius
	self.characterController.height = DormConst.CHARACTER_CONTROLLER.height
	self.characterController.stepOffset = DormConst.CHARACTER_CONTROLLER.stepOffset
end

function LadyEnv:InitCharacterTransparency()
	self.transparencyComp = GetOrAddComponent(self.lady, typeof(CharacterTransparency))
	self.transparencyComp.player = self:Get("player")
	self.transparencyComp.minDistance = DormConst.TRANSPARENCY_MIN_DISTANCE
	self.transparencyComp.maxDistance = DormConst.TRANSPARENCY_MAX_DISTANCE
end

function LadyEnv:InitCharacterAnimationDispatcher()
	self.animationEventDispatcher = GetOrAddComponent(self.lady, typeof(DormAnimationEventDispatcher))
	self.animationEventDispatcher.listenLayer = self.ladyAnimBaseLayerIndex
end

function LadyEnv:SwitchCharacterSkin(arg_31_1, arg_31_2, arg_31_3)
	assert(table.contains(self.skinIdList, arg_31_2))

	local var_31_0 = self:Get("skinDict")[self.skinId].ladyGameObject

	setActive(var_31_0, false)

	self.skinId = arg_31_2

	setActive(self:Get("skinDict")[arg_31_2].ladyGameObject, true)

	self.ladyGameObject = self:Get("skinDict")[arg_31_2].ladyGameObject
	self.ladyCollider = nil

	self:InitCharacter(arg_31_1)
	self:Func("HXCharacter", self.lady, self.skinId)
	pg.NodeCanvasMgr.GetInstance():CopyAllBlackBoardValue(self.ladyBlackboard, self.ladyBlackboard)
	self.ladyAnimator:Play(self:GetCurrentAnim(), self.ladyAnimBaseLayerIndex)
	self.ladyAnimator:Update(0)
	self.lady:SetPositionAndRotation(var_31_0.transform.position, var_31_0.transform.rotation)
	self:Func("InitHolyLight")
	existCall(arg_31_3)
end

function LadyEnv:SetBlackboardValue(arg_32_1, arg_32_2)
	self.blackboard = self.blackboard or {}
	self.blackboard[arg_32_1] = arg_32_2

	pg.NodeCanvasMgr.GetInstance():SetBlackboradValue(arg_32_1, arg_32_2, self.ladyBlackboard)
end

function LadyEnv:GetBlackboardValue(arg_33_1)
	self.blackboard = self.blackboard or {}

	return self.blackboard[arg_33_1]
end

function LadyEnv:GetCurrentAnim()
	return self.ladyAnimator:GetCurrentAnimatorStateInfo(self.ladyAnimBaseLayerIndex).shortNameHash
end

function LadyEnv:EnableCloth(arg_35_1, arg_35_2)
	arg_35_1 = arg_35_1 or {}

	table.Foreach(self.clothComps, function(arg_36_0, arg_36_1)
		if arg_36_1 == nil then
			return
		end

		setActive(arg_36_1, arg_35_1[arg_36_0] == 1)
	end)
	table.Foreach(self.clothColliderDict, function(arg_37_0, arg_37_1)
		if arg_37_1 == nil then
			return
		end

		setActive(arg_37_1, false)
	end)

	if arg_35_2 then
		table.Foreach(arg_35_2, function(arg_38_0, arg_38_1)
			local var_38_0 = self.clothColliderDict[arg_38_1[1]]

			if self.clothColliderDict[arg_38_1[1]] == nil then
				return
			end

			setActive(var_38_0, arg_38_1[2] == 1)

			if arg_38_1[2] ~= 1 then
				return
			end

			LadyEnv.SetMagicaCollider(var_38_0, arg_38_1[3], arg_38_1[4])
		end)
	end
end

function LadyEnv:PlaySingleAction(arg_39_1, arg_39_2, arg_39_3)
	warning("Play", arg_39_1)

	if tobool((string.find(arg_39_1, "^Face_"))) or tobool((string.find(arg_39_1, "^face_"))) then
		self:PlayFaceAnim(arg_39_1, arg_39_2)

		return
	end

	if self.ladyAnimator:GetCurrentAnimatorStateInfo(self.ladyAnimBaseLayerIndex):IsName(arg_39_1) then
		return
	end

	existCall(self.animExtraItemCallback)

	self.animExtraItemCallback = nil

	local var_39_0 = _.detect(pg.dorm3d_anim_extraitem.get_id_list_by_ship_id[self:GetBlackboardValue("groupId")] or {}, function(arg_40_0)
		return pg.dorm3d_anim_extraitem[arg_40_0].anim == arg_39_1
	end)
	local var_39_1 = var_39_0 and pg.dorm3d_anim_extraitem[var_39_0]
	local var_39_2

	arg_39_3 = arg_39_3 or DormConst.DEFAULT_ANIM_FADE_IN_TIME

	seriesAsync({
		function(arg_41_0)
			if not var_39_1 or var_39_1.item_prefab == "" then
				arg_41_0()

				return
			end

			self:Get("loader"):GetPrefab(string.lower("dorm3d/furniture/item/" .. var_39_1.item_prefab), "", function(arg_42_0)
				setParent(arg_42_0, self.lady)

				if var_39_1.item_shield ~= "" then
					var_39_2 = {}

					for iter_42_0, iter_42_1 in ipairs(var_39_1.item_shield) do
						local var_42_0 = self:Get("modelRoot"):Find(iter_42_1)

						if not var_42_0 then
							warning(string.format("dorm3d_anim_extraitem:%d without hide item:%s", var_39_1.id, iter_42_1))
						else
							var_39_2[iter_42_1] = isActive(var_42_0)

							setActive(var_42_0, false)
						end
					end
				end

				function self.animExtraItemCallback()
					self:Get("loader"):ClearRequest("AnimExtraItem")

					if var_39_2 then
						for iter_43_0, iter_43_1 in pairs(var_39_2) do
							setActive(self:Get("modelRoot"):Find(iter_43_0), iter_43_1)
						end
					end
				end

				arg_41_0()
			end, "AnimExtraItem")
		end,
		function(arg_44_0)
			self.nowState = arg_39_1
			self.stateCallback = arg_44_0

			if IsUnityEditor and not self.ladyAnimator:HasState(self.ladyAnimBaseLayerIndex, Animator.StringToHash(arg_39_1)) then
				errorMsg("！！！！！！！！动画不存在>>>>>>>>>>>>>", arg_39_1)
			end

			self.ladyAnimator:CrossFadeInFixedTime(arg_39_1, arg_39_3, self.ladyAnimBaseLayerIndex)
		end,
		function(arg_45_0)
			self.nowState = nil
			self.stateCallback = nil

			existCall(self.animExtraItemCallback)

			self.animExtraItemCallback = nil

			arg_45_0()
		end,
		arg_39_2
	})
end

function LadyEnv:PlayFaceAnim(arg_46_1, arg_46_2)
	if IsUnityEditor and not self.ladyAnimator:HasState(self.ladyAnimFaceLayerIndex, Animator.StringToHash(arg_46_1)) then
		errorMsg("！！！！！！！！动画不存在>>>>>>>>>>>>>", arg_46_1)
	end

	self.ladyAnimator:CrossFadeInFixedTime(arg_46_1, 0, self.ladyAnimFaceLayerIndex)
	existCall(arg_46_2)
end

function LadyEnv:SwitchAnim(arg_47_1, arg_47_2, arg_47_3)
	if tobool((string.find(arg_47_1, "^Face_"))) then
		self:PlayFaceAnim(arg_47_1, arg_47_2)

		return
	end

	existCall(self.animExtraItemCallback)

	self.animExtraItemCallback = nil

	local var_47_0 = {}

	table.insert(var_47_0, function(arg_48_0)
		self.nowState = arg_47_1
		self.stateCallback = arg_48_0

		self.ladyAnimator:PlayInFixedTime(arg_47_1, self.ladyAnimBaseLayerIndex, arg_47_3 and 0 or -math.huge)
	end)
	table.insert(var_47_0, function(arg_49_0)
		self.nowState = nil
		self.stateCallback = nil

		arg_49_0()
	end)
	seriesAsync(var_47_0, arg_47_2)
end

function LadyEnv:RevertClothComps()
	table.Foreach(self.ladyClothCompSettings, function(arg_51_0, arg_51_1)
		arg_51_0.enabled = arg_51_1.enabled
	end)
	table.Foreach(self.ladyClothColliderSettings, function(arg_52_0, arg_52_1)
		arg_52_0.enabled = arg_52_1.enabled

		LadyEnv.SetMagicaCollider(arg_52_0, arg_52_1.StartRadius, arg_52_1.EndRadius)
	end)
end

function LadyEnv:SetMagicaCollider(arg_53_1, arg_53_2)
	local var_53_0 = typeof("MagicaCloth2.MagicaCapsuleCollider")
	local var_53_1 = self:GetSize()

	var_53_1.x = arg_53_1
	var_53_1.y = arg_53_2

	self:SetSize(var_53_1)
end

function LadyEnv:MoveToTarget(arg_54_1, arg_54_2, arg_54_3)
	arg_54_2 = arg_54_2 or DormConst.LADY_MOVE_SPEED
	arg_54_3 = arg_54_3 or DormConst.LADY_ROTATE_SPEED

	local var_54_0 = arg_54_1 - self.lady.position

	var_54_0.y = 0

	if var_54_0 ~= Vector3.zero then
		self.lady.rotation = Quaternion.Slerp(self.lady.rotation, Quaternion.LookRotation(var_54_0), Time.deltaTime * arg_54_3)
	end

	self.characterController:Move(var_54_0.normalized * arg_54_2 * Time.deltaTime)
end

function LadyEnv:SetCollisible(arg_55_1)
	local var_55_0 = self.ladyCollider:GetComponent(typeof(UnityEngine.CapsuleCollider))

	if arg_55_1 then
		var_55_0.excludeLayers = LayerMask.GetMask("Nothing")
		self.characterController.excludeLayers = LayerMask.GetMask("Nothing")
	else
		var_55_0.excludeLayers = LayerMask.GetMask("Player")
		self.characterController.excludeLayers = LayerMask.GetMask("Player")
	end
end

function LadyEnv:EnableCharacterTransparency(arg_56_1)
	self.transparencyComp.Enable = arg_56_1
end

function LadyEnv:BlockCanWatch(arg_57_1)
	self.blockCanWatch = arg_57_1
end

function LadyEnv:SetPosition(arg_58_1)
	self.lady.position = arg_58_1
end

function LadyEnv:SetRotation(arg_59_1)
	self.lady.rotation = arg_59_1
end

return LadyEnv
