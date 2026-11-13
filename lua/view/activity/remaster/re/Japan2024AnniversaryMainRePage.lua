local Japan2024AnniversaryMainRePage = class("Japan2024AnniversaryMainRePage", import("view.activity.subPages.Japan2024AnniversaryMainPage"))

function Japan2024AnniversaryMainRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	Japan2024AnniversaryMainRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function Japan2024AnniversaryMainRePage:OnFirstFlush()
	Japan2024AnniversaryMainRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function Japan2024AnniversaryMainRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return Japan2024AnniversaryMainRePage
