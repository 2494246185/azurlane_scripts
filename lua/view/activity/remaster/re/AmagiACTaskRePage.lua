local AmagiACTaskRePage = class("AmagiACTaskRePage", import("view.activity.subPages.AmagiACTaskPage"))

function AmagiACTaskRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	AmagiACTaskRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function AmagiACTaskRePage:OnFirstFlush()
	AmagiACTaskRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function AmagiACTaskRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return AmagiACTaskRePage
