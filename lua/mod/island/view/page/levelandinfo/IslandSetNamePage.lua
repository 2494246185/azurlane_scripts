local IslandSetNamePage = class("IslandSetNamePage", import(".IslandEditNamePage"))

function IslandSetNamePage:getUIName()
	return "IslandNewNameUI"
end

function IslandSetNamePage:OnLoaded()
	IslandSetNamePage.super.OnLoaded(self)
	setText(self._tf:Find("frame/title"), i18n("island_rename_subtitle"))
	setActive(self.closeBtn, false)
end

function IslandSetNamePage:OnInit()
	onButton(self, self.confirmBtn, function()
		self:emit(IslandMediator.SET_NAME, getInputText(self.input), 2)
	end, SFX_PANEL)
end

function IslandSetNamePage:UpdateContent()
	setText(self.content, "")
end

return IslandSetNamePage
