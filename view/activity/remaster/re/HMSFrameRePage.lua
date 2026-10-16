local HMSFrameRePage = class("HMSFrameRePage", import("view.activity.subPages.HMSFramePage"))

function HMSFrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	HMSFrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function HMSFrameRePage:OnFirstFlush()
	HMSFrameRePage.super.OnFirstFlush(self)

	self.inPhase2 = true

	self:UpdateTime()
end

function HMSFrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return HMSFrameRePage
