local ForestVacationSkinRePage = class("ForestVacationSkinRePage", import("view.activity.subPages.ForestVacationSkinPage"))

function ForestVacationSkinRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	ForestVacationSkinRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function ForestVacationSkinRePage:OnFirstFlush()
	ForestVacationSkinRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function ForestVacationSkinRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return ForestVacationSkinRePage
