local JapanV2framePage = class("JapanV2framePage", import(".TemplatePage.FrameTemplatePage"))

function JapanV2framePage:OnUpdateFlush()
	JapanV2framePage.super.OnUpdateFlush(self)
	setActive(self.gotBtn, false)
end

return JapanV2framePage
