local MetalWingMainRePage = class("MetalWingMainRePage", import("view.activity.subPages.MetalWingMainPage"))

function MetalWingMainRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	MetalWingMainRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function MetalWingMainRePage:OnFirstFlush()
	MetalWingMainRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function MetalWingMainRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return MetalWingMainRePage
