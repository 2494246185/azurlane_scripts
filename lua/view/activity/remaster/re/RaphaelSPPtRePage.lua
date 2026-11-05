local RaphaelSPPtRePage = class("RaphaelSPPtRePage", import("view.activity.subPages.RaphaelSPPtPage"))

function RaphaelSPPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	RaphaelSPPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function RaphaelSPPtRePage:OnFirstFlush()
	RaphaelSPPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function RaphaelSPPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return RaphaelSPPtRePage
