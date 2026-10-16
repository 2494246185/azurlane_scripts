local DachaolifuSkinPage = class("DachaolifuSkinPage", import(".TemplatePage.SkinTemplatePage"))

function DachaolifuSkinPage:OnInit()
	DachaolifuSkinPage.super.OnInit(self)

	self.step_txt = self.bg:Find("step_text")
end

function DachaolifuSkinPage:OnUpdateFlush()
	DachaolifuSkinPage.super.OnUpdateFlush(self)
	setText(self.step_txt, setColorStr(self.nday, "#89FF59FF") .. "/" .. #self.taskGroup)
end

return DachaolifuSkinPage
