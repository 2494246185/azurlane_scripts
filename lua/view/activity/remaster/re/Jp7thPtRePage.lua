local Jp7thPtRePage = class("Jp7thPtRePage", import("view.activity.subPages.Jp7thPtPage"))

function Jp7thPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	Jp7thPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function Jp7thPtRePage:OnFirstFlush()
	Jp7thPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function Jp7thPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return Jp7thPtRePage
