local ClassResourcePage = class("ClassResourcePage", import(".ResourcePage"))

function ClassResourcePage:getUIName()
	return "ClassResourcePage"
end

function ClassResourcePage:getResource()
	return {
		"ui/classresourcepage",
		"ui/resourcefieldui_atlas"
	}
end

function ClassResourcePage:Load(arg_3_1)
	if self._state ~= ClassResourcePage.STATES.NONE or self.isDownloadingResource then
		return
	end

	self.isDownloadingResource = true

	SplitPackConst.DownloadByLuaArr(self:getResource(), function()
		self.isDownloadingResource = nil

		if self._state == ClassResourcePage.STATES.DESTROY then
			return
		end

		ClassResourcePage.super.Load(self, arg_3_1)
	end)
end

function ClassResourcePage:OnUpgrade()
	self:emit(ClassMediator.UPGRADE_FIELD, (self.resourceField:GetUpgradeType()))
end

return ClassResourcePage
