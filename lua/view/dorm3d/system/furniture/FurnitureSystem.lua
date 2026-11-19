local FurnitureSystem = class("FurnitureSystem", import("view.dorm3d.Core.BaseSystem"))

FurnitureSystem.REFRESH_SLOTS = "FurnitureSystem.REFRESH_SLOTS"
FurnitureSystem.REFRESH_SLOTS_EMPTY = "FurnitureSystem.REFRESH_SLOTS_EMPTY"
FurnitureSystem.DISPLAY_SLOTS = "FurnitureSystem.DISPLAY_SLOTS"
FurnitureSystem.HIDE_SLOTS = "FurnitureSystem.HIDE_SLOTS"
FurnitureSystem.UPDATE_DISPLAY_SLOTS = "FurnitureSystem.UPDATE_DISPLAY_SLOTS"
FurnitureSystem.REFRESH_DONE = "FurnitureSystem.REFRESH_DONE"

function FurnitureSystem:OnInit()
	self.slotRoot = self:GetFurnitureSlotRoot()

	assert(self.slotRoot, "FurnitureSystem requires FurnitureSlots root")

	self.slotDict = {}
	self.displaySlots = nil
	self.slotTriggers = {}
	self.artSceneChanging = false

	self:InitSlots()
end

function FurnitureSystem:RegisterEvents()
	self:Bind(FurnitureSystem.REFRESH_SLOTS, function(arg_3_0, arg_3_1, arg_3_2)
		self:RefreshSlots(arg_3_1, arg_3_2)
	end)
	self:Bind(FurnitureSystem.REFRESH_SLOTS_EMPTY, function(arg_4_0, arg_4_1)
		self:RefreshSlotsEmpty(arg_4_1)
	end)
	self:Bind(FurnitureSystem.DISPLAY_SLOTS, function(arg_5_0, arg_5_1)
		self:DisplayFurnitureSlots(arg_5_1)
	end)
	self:Bind(FurnitureSystem.HIDE_SLOTS, function()
		self:HideFurnitureSlots()
	end)
	self:Bind(FurnitureSystem.UPDATE_DISPLAY_SLOTS, function(arg_7_0, arg_7_1)
		self:UpdateDisplaySlots(arg_7_1)
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, function()
		self.artSceneChanging = true

		for iter_8_0, iter_8_1 in pairs(self.slotDict or {}) do
			iter_8_1.model = nil
			iter_8_1.sceneHides = {}
		end
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, function()
		self.artSceneChanging = false

		self:RebindModels()
	end)
end

function FurnitureSystem:InitSlots()
	local var_10_0 = self:GetRoom()

	assert(var_10_0, "FurnitureSystem requires room")

	local var_10_1 = self:GetModelRoot():GetComponentsInChildren(typeof(Transform), true):ToTable()

	_.each(var_10_0:GetSlots(), function(arg_11_0)
		local var_11_0 = arg_11_0:GetFurnitureName()
		local var_11_1 = arg_11_0:GetConfigID()
		local var_11_2 = self.slotRoot:Find(tostring(var_11_1))

		if not var_11_2 then
			errorMsg("Not Find Slot: " .. var_11_1)

			return
		end

		local var_11_3 = {
			trans = var_11_2,
			name = var_11_0,
			sceneHides = {}
		}
		local var_11_4 = var_11_2:Find("Selector")

		if var_11_4 then
			local var_11_5 = GetOrAddComponent(var_11_4, typeof(EventTriggerListener))

			var_11_5:AddPointClickFunc(function()
				self:Emit(Dorm3dRoomMediator.ON_CLICK_FURNITURE_SLOT, var_11_1)
			end)
			setActive(var_11_4, false)

			self.slotTriggers[var_11_1] = var_11_5
		end

		for iter_11_0, iter_11_1 in ipairs(var_10_1) do
			if iter_11_1.name == var_11_0 then
				var_11_3.model = iter_11_1

				break
			end
		end

		self.slotDict[var_11_1] = var_11_3
	end)
end

function FurnitureSystem:RefreshSlots(arg_13_1, arg_13_2)
	if self.artSceneChanging then
		existCall(arg_13_2)

		return
	end

	arg_13_1 = arg_13_1 or self:GetRoom()

	assert(arg_13_1, "FurnitureSystem requires room")

	local var_13_0 = arg_13_1:GetFurnitures()
	local var_13_1 = self:GetModelRoot()
	local var_13_2 = self:GetLoader()

	self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
	table.ParallelIpairsAsync(arg_13_1:GetSlots(), function(arg_14_0, arg_14_1, arg_14_2)
		local var_14_0 = arg_14_1:GetConfigID()
		local var_14_1 = self.slotDict[var_14_0]

		if not self.slotDict[var_14_0] then
			return arg_14_2()
		end

		local var_14_2 = _.detect(var_13_0, function(arg_15_0)
			return arg_15_0:GetSlotID() == var_14_0
		end)
		local var_14_3 = var_14_2 and var_14_2:GetModel(self:GetTimeIndex()) or false
		local var_14_4 = var_14_1.model

		var_14_1.displayModelName = var_14_3
		var_14_1.furnitureId = var_14_2 and var_14_2:GetConfigID()

		local function var_14_5(arg_16_0)
			if var_14_4 then
				setActive(var_14_4, var_14_3 == "")
			end

			table.Foreach(var_14_1.sceneHides or {}, function(arg_17_0, arg_17_1)
				setActive(arg_17_1.trans, arg_17_1.visible)
			end)

			var_14_1.sceneHides = {}

			if not arg_16_0 then
				return
			end

			local var_16_0 = arg_16_0:getConfig("scene_hides")

			if type(var_16_0) == "table" and #var_16_0 > 0 then
				table.Ipairs(var_16_0, function(arg_18_0, arg_18_1)
					local var_18_0 = var_13_1:Find(arg_18_1)

					assert(var_18_0, string.format("dorm3d_furniture_template:%d scene_hides missing scene item :%s", arg_16_0:GetConfigID(), arg_18_1))
					table.insert(var_14_1.sceneHides, {
						name = arg_18_1,
						trans = var_18_0,
						visible = isActive(var_18_0)
					})
					setActive(var_18_0, false)
				end)
			end
		end

		if var_14_3 == false or var_14_3 == "" then
			var_13_2:ClearRequest("slot_" .. var_14_0)
			var_14_5()

			return arg_14_2()
		end

		local var_14_6 = var_14_1.trans

		if var_13_2:GetLoadingRP("slot_" .. var_14_0) then
			self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		end

		var_13_2:GetPrefabBYStopLoading("dorm3d/furniture/prefabs/" .. var_14_3, "", function(arg_19_0)
			assert(arg_19_0)
			setParent(arg_19_0, var_14_6)
			var_14_5(var_14_2)
			arg_14_2()
		end, "slot_" .. var_14_0)
	end, function()
		self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		existCall(arg_13_2)
		warning("RefreshSlots", "Done")
		self:Emit(FurnitureSystem.REFRESH_DONE)
	end)
end

function FurnitureSystem:RefreshSlotsEmpty(arg_21_1)
	local var_21_0 = Clone(self:GetRoom())

	var_21_0.furnitures = {}

	self:RefreshSlots(var_21_0, arg_21_1)
end

function FurnitureSystem:CheckSceneItemActive(arg_22_1)
	local var_22_0 = true
	local var_22_1

	table.Checkout(self.slotDict, function(arg_23_0, arg_23_1)
		if underscore.detect(arg_23_1.sceneHides, function(arg_24_0)
			return arg_24_0.trans == arg_22_1
		end) then
			var_22_0 = false
			var_22_1 = arg_23_1.furnitureId

			return false
		end
	end)

	return true, nil
end

function FurnitureSystem:GetSlotByID(arg_25_1)
	assert(self.isInitialized, "FurnitureSystem is not initialized")

	return self.displaySlots and self.displaySlots[arg_25_1] and self.displaySlots[arg_25_1].trans
end

function FurnitureSystem:HideFurnitureSlots()
	if not self.displaySlots then
		return
	end

	self:UpdateDisplaySlots({})
	table.Foreach(self.displaySlots, function(arg_27_0, arg_27_1)
		local var_27_0 = arg_27_1.trans:Find("Selector")

		if not IsNil(var_27_0) then
			setActive(var_27_0, false)
		end
	end)

	self.displaySlots = nil
end

function FurnitureSystem:DisplayFurnitureSlots(arg_28_1)
	self:HideFurnitureSlots()

	self.displaySlots = {}

	_.each(arg_28_1, function(arg_29_0)
		self.displaySlots[arg_29_0] = self.slotDict[arg_29_0]

		if not self.slotDict[arg_29_0] then
			errorMsg("Slot " .. arg_29_0 .. " Not Binding Scene Object")

			return
		end

		local var_29_0 = self.slotDict[arg_29_0].trans:Find("Selector")

		if var_29_0 then
			setActive(var_29_0, true)
		end
	end)
end

function FurnitureSystem:UpdateDisplaySlots(arg_30_1)
	table.Foreach(self.displaySlots, function(arg_31_0, arg_31_1)
		if not IsNil((arg_31_1.trans:Find("Selector"))) then
			setActive(arg_31_1.trans:Find("Selector/Normal"), arg_30_1[arg_31_0] == 0)
			setActive(arg_31_1.trans:Find("Selector/Active"), arg_30_1[arg_31_0] == 1)
			setActive(arg_31_1.trans:Find("Selector/Ban"), arg_30_1[arg_31_0] == 2)
		end

		local var_31_0 = arg_31_1.model

		if arg_31_1.displayModelName and arg_31_1.displayModelName ~= "" then
			var_31_0 = arg_31_1.trans:GetChild(arg_31_1.trans.childCount - 1)
		end

		if not var_31_0 then
			return
		end

		local var_31_1 = arg_30_1[arg_31_0] == 1 and Color.NewHex("3F83AE73") or Color.New(0, 0, 0, 0)

		table.IpairsCArray(var_31_0:GetComponentsInChildren(typeof(Renderer), true), function(arg_32_0, arg_32_1)
			if arg_32_1.material and arg_32_1.material:HasProperty("_FinalTint") then
				arg_32_1.material:SetColor("_FinalTint", var_31_1)
			end
		end)
	end)
end

function FurnitureSystem:OnDispose()
	for iter_33_0, iter_33_1 in pairs(self.slotTriggers or {}) do
		iter_33_1:RemovePointClickFunc()
	end

	self.slotTriggers = nil
	self.displaySlots = nil
	self.slotDict = nil
	self.slotRoot = nil
end

function FurnitureSystem:RebindModels()
	if not self.slotDict then
		return
	end

	local var_34_0 = self:GetModelRoot():GetComponentsInChildren(typeof(Transform), true):ToTable()

	table.Foreach(self.slotDict, function(arg_35_0, arg_35_1)
		arg_35_1.model = nil
		arg_35_1.sceneHides = {}

		for iter_35_0, iter_35_1 in ipairs(var_34_0) do
			if iter_35_1.name == arg_35_1.name then
				arg_35_1.model = iter_35_1

				break
			end
		end
	end)
end

return FurnitureSystem
