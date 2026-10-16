local CageRePage = class("CageRePage", import("view.activity.subPages.CagePage"))

function CageRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	CageRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function CageRePage:OnFirstFlush()
	CageRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function CageRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return CageRePage
