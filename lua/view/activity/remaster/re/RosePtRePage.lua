local RosePtRePage = class("RosePtRePage", import("view.activity.subPages.RosePtPage"))

function RosePtRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	RosePtRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function RosePtRePage:OnFirstFlush()
	RosePtRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function RosePtRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return RosePtRePage
