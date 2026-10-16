local UrExchangeZ52RePage = class("UrExchangeZ52RePage", import("view.activity.subPages.UrExchangeZ52Page"))

function UrExchangeZ52RePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	UrExchangeZ52RePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function UrExchangeZ52RePage:OnFirstFlush()
	UrExchangeZ52RePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function UrExchangeZ52RePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return UrExchangeZ52RePage
