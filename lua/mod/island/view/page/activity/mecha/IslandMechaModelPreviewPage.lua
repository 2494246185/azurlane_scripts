local IslandMechaModelPreviewPage = class("IslandMechaModelPreviewPage", import("Mod.Island.View.page.ship.IslandBaseShipDisplayPage"))

function IslandMechaModelPreviewPage:getUIName()
	return "IslandMechaModePreviewUI"
end

function IslandMechaModelPreviewPage:NeedCache()
	return false
end

function IslandMechaModelPreviewPage:GetActiveCamName()
	return IslandConst.MODEL_PREVIEW_CAMERA_NAME
end

function IslandMechaModelPreviewPage:OnLoaded()
	self.backBtn = self._tf:Find("adapt/left_panel/back")

	setText(self._tf:Find("adapt/left_panel/title/Text"), i18n("island_dressup_titile"))
end

function IslandMechaModelPreviewPage:OnInit()
	onButton(self, self.backBtn, function()
		self:Hide()
	end, SFX_PANEL)
end

function IslandMechaModelPreviewPage:Show()
	IslandMechaModelPreviewPage.super.Show(self)
	self:LoadCharacter({
		model = pg.island_unit_character[0].model,
		animator = pg.island_unit_character[0].animator
	}, false)
end

function IslandMechaModelPreviewPage:GetSmoothRotateObject()
	return self._tf:Find("adapt/char")
end

function IslandMechaModelPreviewPage:Hide()
	IslandMechaModelPreviewPage.super.Hide(self)

	if self.timer then
		self.timer:Stop()
	end
end

function IslandMechaModelPreviewPage:SetObjInitRotaion(arg_10_1)
	local var_10_0 = GetOrAddComponent(self:GetSmoothRotateObject(), typeof(SmoothRotateObject))

	var_10_0.rotationSpeed = 5

	ReflectionHelp.RefSetProperty(typeof(SmoothRotateObject), "targetRotation", var_10_0, arg_10_1)

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function()
		var_10_0.rotationSpeed = pg.island_set.character_detail_camera_speed.key_value_int
	end, 0.5, 1)

	self.timer:Start()
end

function IslandMechaModelPreviewPage:IsPreviewScene()
	return true
end

function IslandMechaModelPreviewPage:GetDressByType()
	return {
		[IslandShipDressHelperNew.DressType.Body] = 1060013
	}
end

return IslandMechaModelPreviewPage
