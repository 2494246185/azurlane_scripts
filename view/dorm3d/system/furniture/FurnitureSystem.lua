local FurnitureSystem = class("FurnitureSystem", import("view.dorm3d.Core.BaseSystem"))

FurnitureSystem.REFRESH_SLOTS = "FurnitureSystem.REFRESH_SLOTS"
FurnitureSystem.REFRESH_SLOTS_DEFAULT = "FurnitureSystem.REFRESH_SLOTS_DEFAULT"
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
	self:Bind(FurnitureSystem.REFRESH_SLOTS_DEFAULT, function(arg_4_0, arg_4_1)
		self:RefreshSlotsDefault(arg_4_1)
	end)
	self:Bind(FurnitureSystem.REFRESH_SLOTS_EMPTY, function(arg_5_0, arg_5_1)
		self:RefreshSlotsEmpty(arg_5_1)
	end)
	self:Bind(FurnitureSystem.DISPLAY_SLOTS, function(arg_6_0, arg_6_1)
		self:DisplayFurnitureSlots(arg_6_1)
	end)
	self:Bind(FurnitureSystem.HIDE_SLOTS, function()
		self:HideFurnitureSlots()
	end)
	self:Bind(FurnitureSystem.UPDATE_DISPLAY_SLOTS, function(arg_8_0, arg_8_1)
		self:UpdateDisplaySlots(arg_8_1)
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, function()
		self.artSceneChanging = true

		for iter_9_0, iter_9_1 in pairs(self.slotDict or {}) do
			iter_9_1.model = nil
			iter_9_1.sceneHides = {}
		end
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, function()
		self.artSceneChanging = false

		self:RebindModels()
	end)
end

function FurnitureSystem:InitSlots()
	local var_11_0 = self:GetRoom()

	assert(var_11_0, "FurnitureSystem requires room")

	local var_11_1 = self:GetModelRoot():GetComponentsInChildren(typeof(Transform), true):ToTable()

	_.each(var_11_0:GetSlots(), function(arg_12_0)
		local var_12_0 = arg_12_0:GetFurnitureName()
		local var_12_1 = arg_12_0:GetConfigID()
		local var_12_2 = self.slotRoot:Find(tostring(var_12_1))

		if not var_12_2 then
			errorMsg("Not Find Slot: " .. var_12_1)

			return
		end

		local var_12_3 = {
			trans = var_12_2,
			name = var_12_0,
			sceneHides = {}
		}
		local var_12_4 = var_12_2:Find("Selector")

		if var_12_4 then
			local var_12_5 = GetOrAddComponent(var_12_4, typeof(EventTriggerListener))

			var_12_5:AddPointClickFunc(function()
				self:Emit(Dorm3dRoomMediator.ON_CLICK_FURNITURE_SLOT, var_12_1)
			end)
			setActive(var_12_4, false)

			self.slotTriggers[var_12_1] = var_12_5
		end

		for iter_12_0, iter_12_1 in ipairs(var_11_1) do
			if iter_12_1.name == var_12_0 then
				var_12_3.model = iter_12_1

				break
			end
		end

		self.slotDict[var_12_1] = var_12_3
	end)
end

function FurnitureSystem:RefreshSlots(arg_14_1, arg_14_2)
	if self.artSceneChanging then
		existCall(arg_14_2)

		return
	end

	arg_14_1 = arg_14_1 or self:GetRoom()

	assert(arg_14_1, "FurnitureSystem requires room")

	local var_14_0 = arg_14_1:GetFurnitures()
	local var_14_1 = self:GetModelRoot()
	local var_14_2 = self:GetLoader()

	self:Emit(Dorm3dRoomTemplateScene.SHOW_BLOCK)
	table.ParallelIpairsAsync(arg_14_1:GetSlots(), function(arg_15_0, arg_15_1, arg_15_2)
		local var_15_0 = arg_15_1:GetConfigID()
		local var_15_1 = self.slotDict[var_15_0]

		if not self.slotDict[var_15_0] then
			return arg_15_2()
		end

		local var_15_2 = _.detect(var_14_0, function(arg_16_0)
			return arg_16_0:GetSlotID() == var_15_0
		end)
		local var_15_3 = var_15_2 and var_15_2:GetModel(self:GetTimeIndex()) or false
		local var_15_4 = var_15_1.model

		var_15_1.displayModelName = var_15_3
		var_15_1.furnitureId = var_15_2 and var_15_2:GetConfigID()

		local function var_15_5(arg_17_0)
			if var_15_4 then
				setActive(var_15_4, var_15_3 == "")
			end

			table.Foreach(var_15_1.sceneHides or {}, function(arg_18_0, arg_18_1)
				setActive(arg_18_1.trans, arg_18_1.visible)
			end)

			var_15_1.sceneHides = {}

			if not arg_17_0 then
				return
			end

			local var_17_0 = arg_17_0:getConfig("scene_hides")

			if type(var_17_0) == "table" and #var_17_0 > 0 then
				table.Ipairs(var_17_0, function(arg_19_0, arg_19_1)
					local var_19_0 = var_14_1:Find(arg_19_1)

					assert(var_19_0, string.format("dorm3d_furniture_template:%d scene_hides missing scene item :%s", arg_17_0:GetConfigID(), arg_19_1))
					table.insert(var_15_1.sceneHides, {
						name = arg_19_1,
						trans = var_19_0,
						visible = isActive(var_19_0)
					})
					setActive(var_19_0, false)
				end)
			end
		end

		if var_15_3 == false or var_15_3 == "" then
			var_14_2:ClearRequest("slot_" .. var_15_0)
			var_15_5()

			return arg_15_2()
		end

		local var_15_6 = var_15_1.trans

		if var_14_2:GetLoadingRP("slot_" .. var_15_0) then
			self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		end

		var_14_2:GetPrefabBYStopLoading("dorm3d/furniture/prefabs/" .. var_15_3, "", function(arg_20_0)
			assert(arg_20_0)
			setParent(arg_20_0, var_15_6)
			var_15_5(var_15_2)
			arg_15_2()
		end, "slot_" .. var_15_0)
	end, function()
		self:Emit(Dorm3dRoomTemplateScene.HIDE_BLOCK)
		existCall(arg_14_2)
		warning("RefreshSlots", "Done")
		self:Emit(FurnitureSystem.REFRESH_DONE)
	end)
end

function FurnitureSystem:RefreshSlotsDefault(arg_22_1)
	local var_22_0 = Clone(self:GetRoom())

	var_22_0.furnitures = {}

	for iter_22_0, iter_22_1 in ipairs(var_22_0:GetSlots()) do
		local var_22_1 = iter_22_1:GetDefaultFurniture()

		if var_22_1 > 0 then
			table.insert(var_22_0.furnitures, Dorm3dFurniture.New({
				configId = var_22_1,
				slotId = iter_22_1:GetConfigID()
			}))
		end
	end

	self:RefreshSlots(var_22_0, arg_22_1)
end

function FurnitureSystem:RefreshSlotsEmpty(arg_23_1)
	local var_23_0 = Clone(self:GetRoom())

	var_23_0.furnitures = {}

	self:RefreshSlots(var_23_0, arg_23_1)
end

function FurnitureSystem:CheckSceneItemActive(arg_24_1)
	local var_24_0 = true
	local var_24_1

	table.Checkout(self.slotDict, function(arg_25_0, arg_25_1)
		if underscore.detect(arg_25_1.sceneHides, function(arg_26_0)
			return arg_26_0.trans == arg_24_1
		end) then
			var_24_0 = false
			var_24_1 = arg_25_1.furnitureId

			return false
		end
	end)

	return true, nil
end

function FurnitureSystem:GetSlotByID(arg_27_1)
	assert(self.isInitialized, "FurnitureSystem is not initialized")

	return self.displaySlots and self.displaySlots[arg_27_1] and self.displaySlots[arg_27_1].trans
end

function FurnitureSystem:HideFurnitureSlots()
	if not self.displaySlots then
		return
	end

	self:UpdateDisplaySlots({})
	table.Foreach(self.displaySlots, function(arg_29_0, arg_29_1)
		local var_29_0 = arg_29_1.trans:Find("Selector")

		if not IsNil(var_29_0) then
			setActive(var_29_0, false)
		end
	end)

	self.displaySlots = nil
end

function FurnitureSystem:DisplayFurnitureSlots(arg_30_1)
	self:HideFurnitureSlots()

	self.displaySlots = {}

	_.each(arg_30_1, function(arg_31_0)
		self.displaySlots[arg_31_0] = self.slotDict[arg_31_0]

		if not self.slotDict[arg_31_0] then
			errorMsg("Slot " .. arg_31_0 .. " Not Binding Scene Object")

			return
		end

		local var_31_0 = self.slotDict[arg_31_0].trans:Find("Selector")

		if var_31_0 then
			setActive(var_31_0, true)
		end
	end)
end

function FurnitureSystem:UpdateDisplaySlots(arg_32_1)
	table.Foreach(self.displaySlots, function(arg_33_0, arg_33_1)
		if not IsNil((arg_33_1.trans:Find("Selector"))) then
			setActive(arg_33_1.trans:Find("Selector/Normal"), arg_32_1[arg_33_0] == 0)
			setActive(arg_33_1.trans:Find("Selector/Active"), arg_32_1[arg_33_0] == 1)
			setActive(arg_33_1.trans:Find("Selector/Ban"), arg_32_1[arg_33_0] == 2)
		end

		local var_33_0 = arg_33_1.model

		if arg_33_1.displayModelName and arg_33_1.displayModelName ~= "" then
			var_33_0 = arg_33_1.trans:GetChild(arg_33_1.trans.childCount - 1)
		end

		if not var_33_0 then
			return
		end

		local var_33_1 = arg_32_1[arg_33_0] == 1 and Color.NewHex("3F83AE73") or Color.New(0, 0, 0, 0)

		table.IpairsCArray(var_33_0:GetComponentsInChildren(typeof(Renderer), true), function(arg_34_0, arg_34_1)
			if arg_34_1.material and arg_34_1.material:HasProperty("_FinalTint") then
				arg_34_1.material:SetColor("_FinalTint", var_33_1)
			end
		end)
	end)
end

function FurnitureSystem:OnDispose()
	for iter_35_0, iter_35_1 in pairs(self.slotTriggers or {}) do
		iter_35_1:RemovePointClickFunc()
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

	local var_36_0 = self:GetModelRoot():GetComponentsInChildren(typeof(Transform), true):ToTable()

	table.Foreach(self.slotDict, function(arg_37_0, arg_37_1)
		arg_37_1.model = nil
		arg_37_1.sceneHides = {}

		for iter_37_0, iter_37_1 in ipairs(var_36_0) do
			if iter_37_1.name == arg_37_1.name then
				arg_37_1.model = iter_37_1

				break
			end
		end
	end)
end

return FurnitureSystem
