local ChuChunSkinPage = class("ChuChunSkinPage", import(".TemplatePage.SkinTemplatePage"))

function ChuChunSkinPage:OnUpdateFlush()
	ChuChunSkinPage.super.OnUpdateFlush(self)
	setText(self.dayTF, setColorStr(self.nday, COLOR_GREEN) .. "/" .. #self.taskGroup)
end

return ChuChunSkinPage
