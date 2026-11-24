local GongHaiPtPage = class("GongHaiPtPage", import(".TemplatePage.PtTemplatePage"))

function GongHaiPtPage:OnFirstFlush()
	GongHaiPtPage.super.OnFirstFlush(self)
	setText(self.bg:Find("title"), i18n("pt_count_tip"))
end

return GongHaiPtPage
