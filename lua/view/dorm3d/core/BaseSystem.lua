local BaseSystem = class("BaseSystem")

function BaseSystem:Ctor(arg_1_1, arg_1_2)
	self.event = arg_1_1
	self.scene = arg_1_2
	self.context = self:WrapContext(arg_1_2)
	self.bindings = {}
	self.isInitialized = false
end

function BaseSystem:WrapContext(arg_2_1)
	return {
		GetModelRoot = function()
			return arg_2_1:GetModelRoot()
		end,
		GetCurrentLadyEnv = function()
			return arg_2_1:GetCurrentLadyEnv()
		end,
		GetLadyBaseZone = function(arg_5_0)
			return arg_2_1:GetLadyBaseZone(arg_5_0)
		end,
		GetSceneItem = function(arg_6_0)
			return arg_2_1:GetSceneItem(arg_6_0)
		end,
		GetFurnitureSlotRoot = function()
			return arg_2_1.slotRoot
		end,
		GetZoneByName = function(arg_8_0)
			return arg_2_1:GetZoneByName(arg_8_0)
		end,
		GetIKPointByName = function(arg_9_0)
			return arg_2_1:GetIKPointByName(arg_9_0)
		end,
		GetLoader = function()
			return arg_2_1.loader
		end,
		GetRoom = function()
			return arg_2_1.room
		end,
		GetTimeIndex = function()
			return arg_2_1.contextData and arg_2_1.contextData.timeIndex
		end,
		CheckSceneItemActive = function(arg_13_0)
			if arg_2_1.CheckSceneItemActive then
				return arg_2_1:CheckSceneItemActive(arg_13_0)
			end

			return true
		end,
		IsModeInHidePending = function(arg_14_0)
			if arg_2_1.IsModeInHidePending then
				return arg_2_1:IsModeInHidePending(arg_14_0)
			end

			return false
		end,
		GetIsInFurnitureSelect = function()
			return arg_2_1.isInFurnitureSelect
		end,
		GetSceneRaycaster = function()
			return arg_2_1.sceneRaycaster
		end,
		GetPlayer = function()
			return arg_2_1.player
		end,
		GetLadyDict = function()
			return arg_2_1.ladyDict
		end,
		GetSkinDict = function()
			return arg_2_1.skinDict
		end,
		GetMainCameraTF = function()
			return arg_2_1.mainCameraTF
		end,
		GetPosConfigRoot = function()
			return arg_2_1.posConfigRoot
		end,
		GetCameraRoot = function()
			return arg_2_1.cameraRoot
		end,
		GetApartment = function()
			return arg_2_1.apartment
		end,
		GetUIState = function()
			return arg_2_1.uiState
		end,
		GetCamBrain = function()
			return arg_2_1.camBrain
		end,
		GetCameras = function()
			return arg_2_1.cameras
		end,
		GetRaycastCamera = function()
			return arg_2_1.raycastCamera
		end,
		GetNowTimelinePlayer = function()
			return arg_2_1.nowTimelinePlayer
		end,
		_raw = arg_2_1
	}
end

function BaseSystem:Init()
	if self.isInitialized then
		warning(self.__cname .. " already initialized")

		return
	end

	self.isInitialized = true

	self:OnInit()
	self:RegisterEvents()
end

function BaseSystem:OnInit()
	return
end

function BaseSystem:RegisterEvents()
	return
end

function BaseSystem:Emit(arg_32_1, ...)
	self.event:emit(arg_32_1, ...)
end

function BaseSystem:Bind(arg_33_1, arg_33_2)
	self.bindings[arg_33_1] = self.bindings[arg_33_1] or {}

	table.insert(self.bindings[arg_33_1], arg_33_2)
	self.event:connect(arg_33_1, arg_33_2)
end

function BaseSystem:Unbind(arg_34_1)
	if not self.bindings[arg_34_1] then
		return
	end

	for iter_34_0, iter_34_1 in ipairs(self.bindings[arg_34_1]) do
		self.event:disconnect(arg_34_1, iter_34_1)
	end

	self.bindings[arg_34_1] = nil
end

function BaseSystem:UnbindAll()
	for iter_35_0, iter_35_1 in pairs(self.bindings) do
		self:Unbind(iter_35_0)
	end

	self.bindings = {}
end

function BaseSystem:Update(arg_36_1)
	if not self.isInitialized then
		return
	end

	self:OnUpdate(arg_36_1)
end

function BaseSystem:OnUpdate(arg_37_1)
	return
end

function BaseSystem:LateUpdate(arg_38_1)
	if not self.isInitialized then
		return
	end

	self:OnLateUpdate(arg_38_1)
end

function BaseSystem:OnLateUpdate(arg_39_1)
	return
end

function BaseSystem:HandleNotification(arg_40_1, arg_40_2)
	if not self.isInitialized then
		return
	end

	self:OnHandleNotification(arg_40_1, arg_40_2)
end

function BaseSystem:OnHandleNotification(arg_41_1, arg_41_2)
	return
end

function BaseSystem.GetInterests()
	return {}
end

function BaseSystem:Func(arg_43_1, ...)
	if not self.isInitialized then
		return nil
	end

	local var_43_0 = self.scene

	if not self.scene then
		warning("Scene is nil")

		return nil
	end

	local var_43_1 = var_43_0[arg_43_1]

	if not var_43_0[arg_43_1] then
		warning("Method " .. arg_43_1 .. " not found in scene")

		return nil
	end

	return var_43_1(var_43_0, ...)
end

function BaseSystem:Get(arg_44_1)
	if not self.isInitialized then
		return nil
	end

	return self.scene[arg_44_1]
end

function BaseSystem:GetModelRoot()
	return self.context.GetModelRoot()
end

function BaseSystem:GetCurrentLadyEnv()
	return self.context.GetCurrentLadyEnv()
end

function BaseSystem:GetLadyBaseZone(arg_47_1)
	return self.context.GetLadyBaseZone(arg_47_1)
end

function BaseSystem:GetSceneItem(arg_48_1)
	return self.context.GetSceneItem(arg_48_1)
end

function BaseSystem:GetFurnitureSlotRoot()
	return self.context.GetFurnitureSlotRoot()
end

function BaseSystem:GetZoneByName(arg_50_1)
	return self.context.GetZoneByName(arg_50_1)
end

function BaseSystem:GetIKPointByName(arg_51_1)
	return self.context.GetIKPointByName(arg_51_1)
end

function BaseSystem:GetLoader()
	return self.context.GetLoader()
end

function BaseSystem:GetRoom()
	return self.context.GetRoom()
end

function BaseSystem:GetTimeIndex()
	return self.context.GetTimeIndex()
end

function BaseSystem:CheckSceneItemActive(arg_55_1)
	return self.context.CheckSceneItemActive(arg_55_1)
end

function BaseSystem:IsModeInHidePending(arg_56_1)
	return self.context.IsModeInHidePending(arg_56_1)
end

function BaseSystem:GetIsInFurnitureSelect()
	return self.context.GetIsInFurnitureSelect()
end

function BaseSystem:GetSceneRaycaster()
	return self.context.GetSceneRaycaster()
end

function BaseSystem:GetPlayer()
	return self.context.GetPlayer()
end

function BaseSystem:GetLadyDict()
	return self.context.GetLadyDict()
end

function BaseSystem:GetSkinDict()
	return self.context.GetSkinDict()
end

function BaseSystem:GetMainCameraTF()
	return self.context.GetMainCameraTF()
end

function BaseSystem:GetPosConfigRoot()
	return self.context.GetPosConfigRoot()
end

function BaseSystem:GetCameraRoot()
	return self.context.GetCameraRoot()
end

function BaseSystem:GetApartment()
	return self.context.GetApartment()
end

function BaseSystem:GetUIState()
	return self.context.GetUIState()
end

function BaseSystem:GetCamBrain()
	return self.context.GetCamBrain()
end

function BaseSystem:GetCameras()
	return self.context.GetCameras()
end

function BaseSystem:GetRaycastCamera()
	return self.context.GetRaycastCamera()
end

function BaseSystem:GetNowTimelinePlayer()
	return self.context.GetNowTimelinePlayer()
end

function BaseSystem.IsOpen()
	return true
end

function BaseSystem:GetName()
	return self.__cname or "BaseSystem"
end

function BaseSystem:Dispose()
	self:OnDispose()
	self:UnbindAll()

	self.event = nil
	self.context = nil
	self.scene = nil
	self.isInitialized = false
end

function BaseSystem:OnDispose()
	return
end

return BaseSystem
