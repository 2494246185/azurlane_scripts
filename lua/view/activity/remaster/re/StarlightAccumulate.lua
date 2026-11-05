local StarlightAccumulate = class("StarlightAccumulate", import("view.activity.subPages.StarlightAccumulate"))

function StarlightAccumulate:Ctor(arg_1_1, arg_1_2, arg_1_3)
	StarlightAccumulate.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function StarlightAccumulate:OnFirstFlush()
	StarlightAccumulate.super.OnFirstFlush(self)
	self:UpdateTime()
end

function StarlightAccumulate:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return StarlightAccumulate
