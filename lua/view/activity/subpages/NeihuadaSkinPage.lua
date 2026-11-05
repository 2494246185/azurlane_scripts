local NeihuadaSkinPage = class("NeihuadaSkinPage", import(".TemplatePage.SkinTemplatePage"))

function NeihuadaSkinPage:OnUpdateFlush()
	NeihuadaSkinPage.super.OnUpdateFlush(self)
	setText(self.dayTF, setColorStr(self.nday, "#edb46b") .. "/" .. #self.taskGroup)
end

function NeihuadaSkinPage:GetProgressColor()
	return "#edb46b"
end

return NeihuadaSkinPage
