local ManChaoSkinPage = class("ManChaoSkinPage", import(".TemplatePage.SkinTemplatePage"))

function ManChaoSkinPage:OnUpdateFlush()
	ManChaoSkinPage.super.OnUpdateFlush(self)
	setText(self.dayTF, setColorStr(self.nday, "#B67DA1FF") .. "/" .. #self.taskGroup)
end

return ManChaoSkinPage
