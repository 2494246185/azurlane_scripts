local WakabaChrisSkinPage = class("WakabaChrisSkinPage", import(".TemplatePage.SkinTemplatePage"))

function WakabaChrisSkinPage:OnUpdateFlush()
	WakabaChrisSkinPage.super.OnUpdateFlush(self)
	setText(self.dayTF, self.nday .. "/" .. #self.taskGroup)
end

return WakabaChrisSkinPage
