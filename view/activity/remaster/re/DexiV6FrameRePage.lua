local DexiV6FrameRePage = class("DexiV6FrameRePage", import("view.activity.subPages.DexiV6FramePage"))

function DexiV6FrameRePage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	DexiV6FrameRePage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function DexiV6FrameRePage:OnFirstFlush()
	DexiV6FrameRePage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function DexiV6FrameRePage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

function DexiV6FrameRePage:Switch(arg_4_1)
	return
end

return DexiV6FrameRePage
