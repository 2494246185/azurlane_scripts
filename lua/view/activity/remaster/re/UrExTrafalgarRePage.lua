local UrExTrafalgarRePage = class("UrExTrafalgarRePage", import("view.activity.subPages.UrExTrafalgarPage"))

function UrExTrafalgarRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	UrExTrafalgarRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function UrExTrafalgarRePage:OnFirstFlush()
	UrExTrafalgarRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function UrExTrafalgarRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return UrExTrafalgarRePage
