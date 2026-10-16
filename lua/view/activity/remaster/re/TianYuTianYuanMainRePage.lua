local TianYuTianYuanMainRePage = class("TianYuTianYuanMainRePage", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanMainPage"))

function TianYuTianYuanMainRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TianYuTianYuanMainRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TianYuTianYuanMainRePage:OnFirstFlush()
	TianYuTianYuanMainRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function TianYuTianYuanMainRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return TianYuTianYuanMainRePage
