local AnniV5FrameRePage = class("AnniV5FrameRePage", import("view.activity.subPages.AnniV5FramePage"))

function AnniV5FrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	AnniV5FrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function AnniV5FrameRePage:OnFirstFlush()
	AnniV5FrameRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function AnniV5FrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return AnniV5FrameRePage
