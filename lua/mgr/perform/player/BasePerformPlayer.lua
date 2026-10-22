local BasePerformPlayer = class("BasePerformPlayer")

function BasePerformPlayer:Ctor(arg_1_1)
	self._go = arg_1_1
	self._tf = arg_1_1.transform
	self._anim = self._tf:GetComponent(typeof(Animation))

	self:Hide()
end

function BasePerformPlayer:Play(arg_2_1, arg_2_2)
	assert(nil, "Play方法必须由子类实现")
end

function BasePerformPlayer:Show()
	setActive(self._go, true)
end

function BasePerformPlayer:Hide()
	setActive(self._go, false)
end

function BasePerformPlayer:Clear()
	assert(nil, "Clear方法必须由子类实现")
end

function BasePerformPlayer:Dispose()
	return
end

return BasePerformPlayer
