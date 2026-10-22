local LuminousPtRePage = class("LuminousPtRePage", import("view.activity.subPages.LuminousPtPage"))

function LuminousPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	LuminousPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function LuminousPtRePage:OnFirstFlush()
	LuminousPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function LuminousPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return LuminousPtRePage
