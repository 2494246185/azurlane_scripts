local StarlightAccumulateRePage = class("StarlightAccumulateRePage", import("view.activity.Remaster.re.StarlightAccumulate"))

function StarlightAccumulateRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	StarlightAccumulateRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function StarlightAccumulateRePage:OnFirstFlush()
	StarlightAccumulateRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function StarlightAccumulateRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return StarlightAccumulateRePage
