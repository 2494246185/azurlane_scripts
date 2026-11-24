local JapaneseNewyearPage = class("JapaneseNewyearPage", import(".TemplatePage.PreviewTemplatePage"))

function JapaneseNewyearPage:OnFirstFlush()
	self:initBtn()
end

return JapaneseNewyearPage
