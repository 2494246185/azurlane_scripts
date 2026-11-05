local DeXiV6TaskRePage = class("DeXiV6TaskRePage", import("view.activity.subPages.DeXiV6TaskPage"))

function DeXiV6TaskRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	DeXiV6TaskRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function DeXiV6TaskRePage:OnFirstFlush()
	DeXiV6TaskRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function DeXiV6TaskRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return DeXiV6TaskRePage
