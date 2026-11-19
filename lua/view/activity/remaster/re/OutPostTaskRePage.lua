local OutPostTaskRePage = class("OutPostTaskRePage", import("view.activity.subPages.OutPostTaskPage"))

function OutPostTaskRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	OutPostTaskRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function OutPostTaskRePage:OnFirstFlush()
	OutPostTaskRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function OutPostTaskRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return OutPostTaskRePage
