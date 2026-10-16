local TianYuTianYuanURExchangeRePage = class("TianYuTianYuanURExchangeRePage", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanURExchangePage"))

function TianYuTianYuanURExchangeRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TianYuTianYuanURExchangeRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TianYuTianYuanURExchangeRePage:OnFirstFlush()
	TianYuTianYuanURExchangeRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function TianYuTianYuanURExchangeRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return TianYuTianYuanURExchangeRePage
