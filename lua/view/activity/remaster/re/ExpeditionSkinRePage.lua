local ExpeditionSkinRePage = class("ExpeditionSkinRePage", import("view.activity.subPages.ExpeditionSkinPage"))

function ExpeditionSkinRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	ExpeditionSkinRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function ExpeditionSkinRePage:OnFirstFlush()
	ExpeditionSkinRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function ExpeditionSkinRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return ExpeditionSkinRePage
