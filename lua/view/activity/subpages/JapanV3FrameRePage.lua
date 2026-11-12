local JapanV3FrameRePage = class("JapanV3FrameRePage", import(".TemplatePage.FrameReTemplatePage"))

function JapanV3FrameRePage:OnInit()
	self.super.OnInit(self)

	self.bar = self.bg:Find("frame/barContent/bar")
end

return JapanV3FrameRePage
