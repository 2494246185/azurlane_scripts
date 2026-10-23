local CarWashCarSystem = class("CarWashCarSystem", import("view.dorm3d.Game.CarWash.CarWashBaseSystem"))

CarWashCarSystem.UPDATE_PHASE2_TIP = "CarWashCarSystem.UPDATE_PHASE2_TIP"
CarWashCarSystem.PLAY_PHASE2_REACTION = "CarWashCarSystem.PLAY_PHASE2_REACTION"
CarWashCarSystem.MATERIAL_INDEX = 0
CarWashCarSystem.OPAQUE_INDEX = 1
CarWashCarSystem.TRANSPARENT_INDEX = 0
CarWashCarSystem.GENERATOR_NAME = "[DECALROOT]/[DECAL GENERATOR]"
CarWashCarSystem.CAR_PREFAB_PATH = "/[MainBlock]/[Model]/scene_root/no_bake/pre_db_cw_car"
CarWashCarSystem.GLASS_CONFIG = {
	{
		regionId = "zuoglass_01",
		vfx = "pre_db_cw_car01/all/con_1/L_men/L_Bl/vfx_nxmfdoorglass01_l",
		path = "pre_db_cw_car01/all/mod/fbx_db_cw_car01_doorglass01_l"
	},
	{
		regionId = "zuoglass_02",
		vfx = "pre_db_cw_car01/all/con_1/R_men/R_Bl/vfx_nxmfdoorglass01_r",
		path = "pre_db_cw_car01/all/mod/fbx_db_cw_car01_doorglass01_r"
	},
	{
		regionId = "glass_01",
		vfx = "pre_db_cw_car01/all/con_1/vfx_nxmfglass01",
		path = "pre_db_cw_car01/all/mod/fbx_db_cw_car01_glass01"
	}
}
CarWashCarSystem.PHASE_2_VFX = "pre_db_cw_car01/all/con_1/vfx_nxmfglass02"
CarWashCarSystem.PHASE_2_RENDER = "pre_db_cw_car01/all/mod/fbx_db_cw_car01_glass01"

function CarWashCarSystem:OnInit()
	self.mainCamera = self:GetMainCamera()
	self.gameState = CarWashConst.GAME_STATE.NONE
	self.carTouchClicked = false
end

function CarWashCarSystem:RegisterEvents()
	self:Bind(CarWashGameFlowSystem.SET_STAINS_COUNT_MAX, function(arg_3_0, arg_3_1)
		self:InitSceneRefs()
		self:RefreshAllGlassMaterialByRegion()
		self:PlayIdleAnim()
	end)
	self:Bind(CarWashGameFlowSystem.DECREASE_STAINS_COUNT, function(arg_4_0, arg_4_1)
		onNextTick(function()
			self:RefreshAllGlassMaterialByRegion(true)
		end)
	end)
	self:Bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_BEGIN, function(arg_6_0)
		self:SetAllGlassTransparent()
	end)
	self:Bind(CarWashTimelineSystem.TIMELINE_SEQUENCE_END, function(arg_7_0)
		self:RefreshAllGlassMaterialByRegion()
		self:PlayIdleAnim()
	end)
	self:Bind(CarWashGameFlowSystem.UPDATE_LADY_POS, function(arg_8_0, arg_8_1)
		self.posConfig = arg_8_1.newValue
		self.carTouchTF = nil

		self:PlayIdleAnim()
	end)
	self:Bind(CarWashGameFlowSystem.UPDATE_GAME_STATE, function(arg_9_0, arg_9_1)
		self.gameState = arg_9_1.newValue

		if arg_9_1.newValue == CarWashConst.GAME_STATE.PHASE_2 then
			self.carTouchClicked = false

			self:SetAllGlassTransparent()
		elseif arg_9_1.newValue == CarWashConst.GAME_STATE.PHASE_1 then
			self:RefreshAllGlassMaterialByRegion()

			local var_9_0

			if arg_9_1.newValue == CarWashConst.GAME_STATE.PHASE_2 then
				var_9_0 = self.posConfig and self.posConfig.phase2_glass_effect == 1
			end
		end

		self:EnablePhase2(var_9_0)
	end)
	self:Bind(CarWashCarSystem.PLAY_PHASE2_REACTION, function(arg_10_0)
		self:PlayPhase2Reaction()
	end)
end

function CarWashCarSystem:OnUpdate(arg_11_1)
	if self.gameState ~= CarWashConst.GAME_STATE.PHASE_2 then
		return
	end

	self:Emit(CarWashCarSystem.UPDATE_PHASE2_TIP, self:GetPhase2TipInfo())
end

function CarWashCarSystem:OnDispose()
	self.mainCamera = nil
	self.carTF = nil
	self.carAnimator = nil
	self.posConfig = nil
	self.carTouchTF = nil
	self.glassInfos = nil
	self.randomDecalGenerator = nil
	self.phase2VFX = nil
	self.phase2Render = nil
end

function CarWashCarSystem:InitSceneRefs()
	local var_13_0 = GameObject.Find(CarWashCarSystem.CAR_PREFAB_PATH)

	assert(var_13_0, "CarWash car prefab not found: " .. CarWashCarSystem.CAR_PREFAB_PATH)

	self.carTF = var_13_0.transform
	self.carAnimator = self.carTF:GetChild(0):GetComponent(typeof(Animator))
	self.glassInfos = {}

	local var_13_1 = GameObject.Find(CarWashCarSystem.GENERATOR_NAME)

	assert(var_13_1, "CarWash RandomDecalGenerator object not found: " .. CarWashCarSystem.GENERATOR_NAME)

	self.randomDecalGenerator = var_13_1:GetComponent(typeof(RandomDecalGenerator))

	assert(self.randomDecalGenerator, "RandomDecalGenerator component not found on " .. CarWashCarSystem.GENERATOR_NAME)

	for iter_13_0, iter_13_1 in ipairs(CarWashCarSystem.GLASS_CONFIG) do
		local var_13_2 = self.carTF:Find(iter_13_1.path)

		assert(var_13_2, "CarWash glass object not found: " .. tostring(iter_13_1.path))

		local var_13_3 = var_13_2:GetComponent(typeof(MaterialSwitcher))

		assert(var_13_3, "MaterialSwitcher component not found on " .. tostring(iter_13_1.path))

		local var_13_4 = self.randomDecalGenerator:GetRegionRootById(iter_13_1.regionId)

		assert(var_13_4, "CarWash glass decal region not found: " .. tostring(iter_13_1.regionId))

		local var_13_5 = self.carTF:Find(iter_13_1.vfx)

		assert(var_13_5, "CarWash glass vfx not found: " .. tostring(iter_13_1.vfx))
		setActive(var_13_5, false)
		table.insert(self.glassInfos, {
			switcher = var_13_3,
			regionId = iter_13_1.regionId,
			regionTF = var_13_4,
			vfxTF = var_13_5
		})
	end

	self.phase2VFX = self.carTF:Find(CarWashCarSystem.PHASE_2_VFX)

	local var_13_6 = self.carTF:Find(CarWashCarSystem.PHASE_2_RENDER)

	assert(self.phase2VFX, "CarWash phase2 vfx not found: " .. CarWashCarSystem.PHASE_2_VFX)
	assert(var_13_6, "CarWash phase2 renderer not found: " .. CarWashCarSystem.PHASE_2_RENDER)

	self.phase2Render = var_13_6:GetComponent(typeof(SkinnedMeshRenderer))

	assert(self.phase2Render, "CarWash phase2 MeshRenderer not found: " .. CarWashCarSystem.PHASE_2_RENDER)
end

function CarWashCarSystem:PlayIdleAnim()
	if not self.carAnimator or not self.posConfig then
		return
	end

	local var_14_0 = self.posConfig.car_idle_anim

	if not self.posConfig.car_idle_anim or var_14_0 == "" then
		return
	end

	self.carAnimator:CrossFadeInFixedTime(var_14_0, 0, 0)
end

function CarWashCarSystem:GetPhase2TipInfo()
	if self.carTouchClicked or not self.carTF or not self.posConfig then
		return nil
	end

	local var_15_0 = self.posConfig.car_touch_anim

	if not self.posConfig.car_touch_anim or not var_15_0[1] or var_15_0[1] == "" or not var_15_0[2] or var_15_0[2] == "" then
		return nil
	end

	if not self.carTouchTF then
		self.carTouchTF = self.carTF:Find(var_15_0[1])

		assert(self.carTouchTF, "CarWash car touch node not found: " .. tostring(var_15_0[1]))
	end

	local var_15_1 = self.mainCamera:WorldToScreenPoint(self.carTouchTF.position)

	return {
		isCar = true,
		screenPosition = var_15_1,
		visible = var_15_1.z > 0
	}
end

function CarWashCarSystem:PlayPhase2Reaction()
	if self.gameState ~= CarWashConst.GAME_STATE.PHASE_2 then
		return
	end

	if self.carTouchClicked or not self.posConfig then
		return
	end

	local var_16_0 = self.posConfig.car_touch_anim

	if not self.posConfig.car_touch_anim or not var_16_0[2] or var_16_0[2] == "" then
		return
	end

	self.carTouchClicked = true

	self:Emit(CarWashCarSystem.UPDATE_PHASE2_TIP, nil)

	if self.carAnimator then
		self.carAnimator:CrossFadeInFixedTime(var_16_0[2], 0, 0)
	end
end

function CarWashCarSystem:RefreshAllGlassMaterialByRegion(arg_17_1)
	if not self.glassInfos then
		return
	end

	for iter_17_0, iter_17_1 in pairs(self.glassInfos) do
		iter_17_1.regionTF = self.randomDecalGenerator and self.randomDecalGenerator:GetRegionRootById(iter_17_1.regionId) or nil

		if iter_17_1.regionTF then
			self:SetGlassTransparent(iter_17_1, iter_17_1.regionTF.childCount == 0, arg_17_1)
		else
			warning("CarWash glass decal region not found: " .. tostring(iter_17_1.regionId))
		end
	end
end

function CarWashCarSystem:SetAllGlassTransparent()
	if not self.glassInfos then
		return
	end

	for iter_18_0, iter_18_1 in pairs(self.glassInfos) do
		self:SetGlassTransparent(iter_18_1, true)
	end
end

function CarWashCarSystem:SetGlassTransparent(arg_19_1, arg_19_2, arg_19_3)
	if arg_19_3 and arg_19_2 and not arg_19_1.isTransparent then
		setActive(arg_19_1.vfxTF, true)
	end

	arg_19_1.switcher:ReplaceMaterial(CarWashCarSystem.MATERIAL_INDEX, (arg_19_2 or nil) and (CarWashCarSystem.TRANSPARENT_INDEX or CarWashCarSystem.OPAQUE_INDEX))

	arg_19_1.isTransparent = arg_19_2
end

function CarWashCarSystem:EnablePhase2(arg_20_1)
	if self.phase2VFX then
		setActive(self.phase2VFX, arg_20_1)
	end

	if self.phase2Render then
		self.phase2Render.enabled = not arg_20_1
	end
end

return CarWashCarSystem
