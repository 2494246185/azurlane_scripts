local DexiV5PtPage = class("DexiV5PtPage", import(".TemplatePage.PtTemplatePage"))

function DexiV5PtPage:OnUpdateFlush()
	DexiV5PtPage.super.OnUpdateFlush(self)
end

return DexiV5PtPage
