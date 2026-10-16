local AnShanChangChunPage = class("AnShanChangChunPage", import(".TemplatePage.SkinTemplatePage"))

function AnShanChangChunPage:OnUpdateFlush()
	AnShanChangChunPage.super.OnUpdateFlush(self)
	setText(self.dayTF, self.nday .. "/" .. #self.taskGroup)
end

return AnShanChangChunPage
