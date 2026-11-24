local Dorm3dLightingSystem = class("Dorm3dLightingSystem", import("view.dorm3d.Core.BaseSystem"))

Dorm3dLightingSystem.APPLY_DAY_NIGHT = "Dorm3dLightingSystem.APPLY_DAY_NIGHT"
Dorm3dLightingSystem.SET_CAMERA_SETTINGS = "Dorm3dLightingSystem.SET_CAMERA_SETTINGS"
Dorm3dLightingSystem.REVERT_CAMERA_SETTINGS = "Dorm3dLightingSystem.REVERT_CAMERA_SETTINGS"
Dorm3dLightingSystem.SET_VOLUME_PROFILE = "Dorm3dLightingSystem.SET_VOLUME_PROFILE"
Dorm3dLightingSystem.REVERT_VOLUME_PROFILE = "Dorm3dLightingSystem.REVERT_VOLUME_PROFILE"
Dorm3dLightingSystem.REVERT_CHARACTER_LIGHT = "Dorm3dLightingSystem.REVERT_CHARACTER_LIGHT"

function Dorm3dLightingSystem:OnInit()
	local var_1_0 = GameObject.Find("[MainBlock]")

	assert(var_1_0, "Dorm3dLightingSystem requires [MainBlock]")

	self.daynightCtrlComp = var_1_0:GetComponent("DayNightCtrl")
	self.volumeRequest = nil
end

function Dorm3dLightingSystem:RegisterEvents()
	self:Bind(Dorm3dLightingSystem.APPLY_DAY_NIGHT, function(arg_3_0, arg_3_1)
		self:ApplyDayNight(arg_3_1)
	end)
	self:Bind(Dorm3dLightingSystem.SET_CAMERA_SETTINGS, function(arg_4_0, arg_4_1)
		self:SettingCamera(arg_4_1)
	end)
	self:Bind(Dorm3dLightingSystem.REVERT_CAMERA_SETTINGS, function()
		self:RevertCameraSettings()
	end)
	self:Bind(Dorm3dLightingSystem.SET_VOLUME_PROFILE, function(arg_6_0, arg_6_1, arg_6_2)
		self:SetVolumeProfile(arg_6_1, arg_6_2)
	end)
	self:Bind(Dorm3dLightingSystem.REVERT_VOLUME_PROFILE, function()
		self:RevertVolumeProfile()
	end)
	self:Bind(Dorm3dLightingSystem.REVERT_CHARACTER_LIGHT, function()
		self:RevertCharacterLight()
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_WILL_CHANGE, function()
		self:RevertVolumeProfile()

		self.daynightCtrlComp = nil
	end)
	self:Bind(Dorm3dRoomTemplateScene.ART_SCENE_CHANGED, function()
		self:RefreshArtSceneRefs()
		self:ApplyDayNight(self:GetTimeIndex())
	end)
end

function Dorm3dLightingSystem:RefreshArtSceneRefs()
	local var_11_0 = GameObject.Find("[MainBlock]")

	assert(var_11_0, "Dorm3dLightingSystem requires [MainBlock]")

	self.daynightCtrlComp = var_11_0:GetComponent("DayNightCtrl")
end

function Dorm3dLightingSystem:ApplyDayNight(arg_12_1)
	if not IsNil(self.daynightCtrlComp) then
		self.daynightCtrlComp:SwitcherToIndex(arg_12_1 - 1)
	end

	self:RefreshLightSettings()
end

function Dorm3dLightingSystem:FindGlobalVolume()
	local var_13_0 = GameObject.Find("GlobalVolume")

	assert(var_13_0, "Dorm3dLightingSystem requires GlobalVolume")

	return var_13_0
end

function Dorm3dLightingSystem:FindCharacterLight()
	local var_14_0 = GameObject.Find("CharacterLight")

	assert(var_14_0, "Dorm3dLightingSystem requires CharacterLight")

	return var_14_0
end

function Dorm3dLightingSystem:FindLightingRoot()
	local var_15_0 = GameObject.Find("[Lighting]")

	assert(var_15_0, "Dorm3dLightingSystem requires [Lighting]")

	return var_15_0.transform
end

function Dorm3dLightingSystem:RefreshLightSettings()
	self:RegisterGlobalVolume((self:FindGlobalVolume()))
	self:RecordCharacterLight((self:FindCharacterLight()))
	table.IpairsCArray(self:FindLightingRoot():GetComponentsInChildren(typeof(Light), true), function(arg_17_0, arg_17_1)
		arg_17_1.shadows = UnityEngine.LightShadows.None
	end)
end

function Dorm3dLightingSystem:RegisterGlobalVolume(arg_18_1)
	local var_18_0 = GraphicsInterface.Instance.GetOrAddVolumeComponent(arg_18_1, typeof(BLHX.Rendering.CustomDepthOfField))
	local var_18_1 = GraphicsInterface.Instance.GetOrAddVolumeComponent(arg_18_1, typeof(UnityEngine.Rendering.Universal.ColorAdjustments))

	self.originalCameraSettings = {
		depthOfField = {
			enabled = var_18_0.enabled.value,
			focusDistance = {
				length = 2,
				min = var_18_0.gaussianStart.min,
				value = var_18_0.gaussianStart.value
			},
			blurRadius = {
				min = var_18_0.blurRadius.min,
				max = var_18_0.blurRadius.max,
				value = var_18_0.blurRadius.value
			}
		},
		postExposure = {
			value = var_18_1.postExposure.value
		},
		contrast = {
			min = var_18_1.contrast.min,
			max = var_18_1.contrast.max,
			value = var_18_1.contrast.value
		},
		saturate = {
			min = var_18_1.saturation.min,
			max = var_18_1.saturation.max,
			value = var_18_1.saturation.value
		}
	}
	self.originalCameraSettings.depthOfField.enabled = true
end

function Dorm3dLightingSystem:GetCameraSettings()
	return self.originalCameraSettings
end

function Dorm3dLightingSystem:SettingCamera(arg_20_1)
	self.activeCameraSettings = arg_20_1

	local var_20_0 = self:FindGlobalVolume()
	local var_20_1 = GraphicsInterface.Instance.GetOrAddVolumeComponent(var_20_0, typeof(BLHX.Rendering.CustomDepthOfField))
	local var_20_2 = GraphicsInterface.Instance.GetOrAddVolumeComponent(var_20_0, typeof(UnityEngine.Rendering.Universal.ColorAdjustments))

	var_20_1.enabled:Override(arg_20_1.depthOfField.enabled)
	var_20_1.gaussianStart:Override(arg_20_1.depthOfField.focusDistance.value)
	var_20_1.gaussianEnd:Override(arg_20_1.depthOfField.focusDistance.value + arg_20_1.depthOfField.focusDistance.length)
	var_20_1.blurRadius:Override(arg_20_1.depthOfField.blurRadius.value)
	var_20_2.postExposure:Override(arg_20_1.postExposure.value)
	var_20_2.contrast:Override(arg_20_1.contrast.value)
	var_20_2.saturation:Override(arg_20_1.saturate.value)
end

function Dorm3dLightingSystem:RevertCameraSettings()
	self:SettingCamera(self.originalCameraSettings)

	self.activeCameraSettings = nil
end

function Dorm3dLightingSystem:SetVolumeProfile(arg_22_1, arg_22_2)
	if self.cameraVolume then
		self:RevertVolumeProfile()
	end

	local var_22_0 = {}

	self.volumeRequest = var_22_0

	self:GetLoader():GetPrefab("dorm3d/effect/volume/" .. arg_22_1, "", function(arg_23_0)
		if self.volumeRequest ~= var_22_0 then
			self:GetLoader():ReturnPrefab(arg_23_0)

			return
		end

		self.cameraVolume = arg_23_0
	end)
end

function Dorm3dLightingSystem:RevertVolumeProfile()
	self.volumeRequest = nil

	if self.cameraVolume then
		self:GetLoader():ReturnPrefab(self.cameraVolume)

		self.cameraVolume = nil
	end
end

function Dorm3dLightingSystem:OnDispose()
	self:RevertVolumeProfile()
end

function Dorm3dLightingSystem:RecordCharacterLight(arg_26_1)
	tolua.loadassembly("Yongshi.BLRP.Runtime.AOT")

	local var_26_0 = arg_26_1:GetComponent(typeof("BLHX.Rendering.CharacterLight"))

	self.originalCharacterColor = {
		color = ReflectionHelp.RefGetProperty(typeof("BLHX.Rendering.CharacterLight"), "characterLightColor", var_26_0),
		intensity = ReflectionHelp.RefGetProperty(typeof("BLHX.Rendering.CharacterLight"), "characterLightIntensity", var_26_0)
	}
end

function Dorm3dLightingSystem:SetCharacterLight(arg_27_1, arg_27_2, arg_27_3)
	local var_27_0 = self:FindCharacterLight():GetComponent(typeof("BLHX.Rendering.CharacterLight"))

	ReflectionHelp.RefSetProperty(typeof("BLHX.Rendering.CharacterLight"), "characterLightColor", var_27_0, (Color.Lerp(self.originalCharacterColor.color, arg_27_1, arg_27_3)))
	ReflectionHelp.RefSetProperty(typeof("BLHX.Rendering.CharacterLight"), "characterLightIntensity", var_27_0, (math.lerp(self.originalCharacterColor.intensity, arg_27_2, arg_27_3)))
end

function Dorm3dLightingSystem:RevertCharacterLight()
	self:SetCharacterLight(self.originalCharacterColor.color, self.originalCharacterColor.intensity, 1)
end

return Dorm3dLightingSystem
