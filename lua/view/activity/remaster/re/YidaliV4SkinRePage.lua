local YidaliV4SkinRePage = class("YidaliV4SkinRePage", import("view.activity.subPages.YidaliV4SkinPage"))

function YidaliV4SkinRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	YidaliV4SkinRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function YidaliV4SkinRePage:OnFirstFlush()
	YidaliV4SkinRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function YidaliV4SkinRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return YidaliV4SkinRePage
