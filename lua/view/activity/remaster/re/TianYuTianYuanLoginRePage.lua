local TianYuTianYuanLoginRePage = class("TianYuTianYuanLoginRePage", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanLoginPage"))

function TianYuTianYuanLoginRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TianYuTianYuanLoginRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TianYuTianYuanLoginRePage:OnFirstFlush()
	TianYuTianYuanLoginRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function TianYuTianYuanLoginRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return TianYuTianYuanLoginRePage
