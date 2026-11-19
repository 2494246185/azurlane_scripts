local YidaliV4FrameRePage = class("YidaliV4FrameRePage", import("view.activity.subPages.YidaliV4FramePage"))

function YidaliV4FrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	YidaliV4FrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function YidaliV4FrameRePage:OnFirstFlush()
	YidaliV4FrameRePage.super.OnFirstFlush(self)

	self.inPhase2 = true

	self:UpdateTime()
end

function YidaliV4FrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

function YidaliV4FrameRePage:CheckSwitch2Phase2()
	GetOrAddComponent(self.phases[1], typeof(CanvasGroup)).alpha = 0
	GetOrAddComponent(self.phases[2], typeof(CanvasGroup)).alpha = 1
end

function YidaliV4FrameRePage:Switch(arg_5_1)
	return
end

return YidaliV4FrameRePage
