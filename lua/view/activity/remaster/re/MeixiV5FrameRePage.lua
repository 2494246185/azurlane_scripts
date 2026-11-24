local MeixiV5FrameRePage = class("MeixiV5FrameRePage", import("view.activity.subPages.MeixiV5FramePage"))

function MeixiV5FrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	MeixiV5FrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function MeixiV5FrameRePage:OnFirstFlush()
	MeixiV5FrameRePage.super.OnFirstFlush(self)

	self.inPhase2 = true

	self:UpdateTime()
end

function MeixiV5FrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return MeixiV5FrameRePage
