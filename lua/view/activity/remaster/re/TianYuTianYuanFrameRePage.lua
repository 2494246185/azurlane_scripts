local TianYuTianYuanFrameRePage = class("TianYuTianYuanFrameRePage", import("view.activity.CorePage.TianYuTianYuan.TianYuTianYuanFramePage"))

function TianYuTianYuanFrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	TianYuTianYuanFrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function TianYuTianYuanFrameRePage:OnFirstFlush()
	TianYuTianYuanFrameRePage.super.OnFirstFlush(self)

	self.inPhase2 = true

	self:UpdateTime()
end

function TianYuTianYuanFrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

function TianYuTianYuanFrameRePage:CheckSwitch2Phase2()
	GetOrAddComponent(self.phases[1], typeof(CanvasGroup)).alpha = 0
	GetOrAddComponent(self.phases[2], typeof(CanvasGroup)).alpha = 1
end

return TianYuTianYuanFrameRePage
