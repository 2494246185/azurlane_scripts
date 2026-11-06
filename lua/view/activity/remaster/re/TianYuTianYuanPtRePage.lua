local TianYuTianYuanPtRePage = class("TianYuTianYuanPtRePage", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanPtPage"))

function TianYuTianYuanPtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TianYuTianYuanPtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TianYuTianYuanPtRePage:OnFirstFlush()
	TianYuTianYuanPtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function TianYuTianYuanPtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return TianYuTianYuanPtRePage
