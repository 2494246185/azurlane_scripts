local SiChuanOperaPage = class("SiChuanOperaPage", import(".TemplatePage.LoginTemplatePage"))

function SiChuanOperaPage:OnInit()
	SiChuanOperaPage.super.OnInit(self)

	self.dayText = self._tf:Find("AD/DayText")
	self.url = self._tf:Find("AD/url")
end

function SiChuanOperaPage:OnFirstFlush()
	SiChuanOperaPage.super.OnFirstFlush(self)
	onButton(self, self.url, function()
		Application.OpenURL(self.activity:getConfig("config_client"))
	end, SFX_PANEL)
end

function SiChuanOperaPage:OnUpdateFlush()
	SiChuanOperaPage.super.OnUpdateFlush(self)
	setText(self.dayText, string.format("%02d", self.nday))
end

return SiChuanOperaPage
