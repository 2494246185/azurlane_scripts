local PittsburghPtRePage = class("PittsburghPtRePage", import("view.activity.subPages.PittsburghPtPage"))

function PittsburghPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	PittsburghPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function PittsburghPtRePage:OnFirstFlush()
	PittsburghPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function PittsburghPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return PittsburghPtRePage
