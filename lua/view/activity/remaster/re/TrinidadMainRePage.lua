local TrinidadMainRePage = class("TrinidadMainRePage", import("view.activity.subPages.TrinidadMainPage"))

function TrinidadMainRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TrinidadMainRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TrinidadMainRePage:OnFirstFlush()
	TrinidadMainRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function TrinidadMainRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return TrinidadMainRePage
